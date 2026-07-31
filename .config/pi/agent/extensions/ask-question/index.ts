import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// Mirrors the opencode `question` tool surface so prompt templates port over
// with minimal changes. Registers `ask_question` as a tool the LLM can call.
//
// Interactive-only: ctx.ui dialogs are no-ops in print/JSON/RPC modes, so this
// tool returns a "not available" message when ctx.hasUI is false (e.g. inside
// `pi -p` sub-agents). Sub-agents must report back, not ask questions.

type Question = {
  header: string;
  question: string;
  options: string[];
  multiple?: boolean;
};

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_question",
    label: "Ask",
    description:
      "Ask the user one or more multiple-choice questions. Each question has a short header, the full question text, and a list of selectable options. The user may also type a custom answer. Returns the selected answer(s). Only works in interactive TUI mode — no-op in print/JSON/RPC mode.",
    parameters: Type.Object({
      questions: Type.Array(
        Type.Object({
          header: Type.String({ description: "Very short label (max ~30 chars) for the question" }),
          question: Type.String({ description: "The full question text to ask the user" }),
          options: Type.Array(Type.String(), {
            description: "Selectable choices. The user can also type a custom answer.",
          }),
          multiple: Type.Optional(
            Type.Boolean({
              description: "If true, allow multiple selections (comma-separated). Default false.",
            }),
          ),
        }),
        { description: "One or more questions to ask in a single batch" },
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text: "ask_question is unavailable in non-interactive mode. Proceed with a reasonable default and state the assumption.",
            },
          ],
          details: { asked: false, reason: "no interactive UI" },
        };
      }

      const results: Array<{ header: string; answer: string }> = [];

      for (const q of params.questions as Question[]) {
        const wantMulti = q.multiple === true;

        if (wantMulti) {
          // ctx.ui has no native multiselect; present options and take free-text
          // input so the user can type comma-separated selections or custom text.
          const prompt = `${q.header}\n${q.question}\nOptions: ${q.options.join(", ")}\nEnter one or more (comma-separated), or type your own:`;
          const raw = await ctx.ui.input(prompt, q.options.join(", "));
          const rawVal = raw === undefined ? "" : raw;
          results.push({ header: q.header, answer: rawVal.trim() || (q.options[0] || "") });
        } else {
          let choice = await ctx.ui.select(`${q.header}\n${q.question}`, q.options);
          if (choice === undefined) {
            // User cancelled the menu; fall back to free-text input.
            const raw = await ctx.ui.input(`${q.header}\n${q.question}\nType your answer:`, "");
            const rawVal = raw === undefined ? "" : raw;
            choice = rawVal.trim() || q.options[0];
          }
          results.push({ header: q.header, answer: choice === undefined ? "" : choice });
        }
      }

      const text = results
        .map((r) => `${r.header}: ${r.answer}`)
        .join("\n");

      return {
        content: [{ type: "text", text }],
        details: { asked: true, answers: results },
      };
    },
  });
}
