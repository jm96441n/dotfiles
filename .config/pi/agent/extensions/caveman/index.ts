/**
 * Caveman Extension for pi
 *
 * Port of JuliusBrussee/caveman: compress agent output tokens by speaking
 * terse caveman-speak. All technical substance stays; only fluff dies.
 *
 * Usage:
 *   /caveman            toggle on (full) / off
 *   /caveman lite       terse but grammatical
 *   /caveman full       classic caveman (default)
 *   /caveman ultra      maximum compression, English
 *   /caveman wenyan     classical Chinese (文言), max char compression
 *   /caveman off        back to normal
 *
 * Active per-session. A status line shows the current level.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

type Level = "lite" | "full" | "ultra" | "wenyan";

const LEVELS: Record<Level, { label: string; prompt: string }> = {
	lite: {
		label: "lite",
		prompt: `Respond tight and professional. No filler, no hedging, no pleasantries ("sure", "happy to", "basically"). Keep full sentences and articles. Every word earns its place. Code, commands, errors unchanged.`,
	},
	full: {
		label: "full",
		prompt: `Respond terse like smart caveman. All technical substance stays. Only fluff dies.
Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries, hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). No tool-call narration before/after calls — fire direct.
Pattern: [thing] [action] [reason]. [next step]. Not: "Sure! I'd be happy to help..." — Yes: "Bug in auth middleware. Token expiry uses \`<\` not \`<=\`. Fix:".
Technical terms, code, API names, CLI commands, exact error strings: never touch. Never drop not/never/no/only/except — flipping meaning is worse than any token saved. Numbers, units exact.
No invented abbreviations (cfg/impl/req/fn) — tokenizer splits them like the full word, zero saved, reader still decodes. No causal arrows (→). Standard acronyms OK (DB/API/HTTP).
Reply in the user's dominant language — compress the style, never switch the language.`,
	},
	ultra: {
		label: "ultra",
		prompt: `Respond in maximum compression. Strip conjunctions when cause-then-effect stays unambiguous. One word when one word is enough. State each fact once.
No prose abbreviations (cfg/impl/req/res/fn/auth) and no arrows (X → Y): measured zero token saving, cost decode clarity. Code symbols, function names, API names, error strings: never touch.
Code, commands, exact errors unchanged. Never drop not/never/no/only/except. Reply in the user's dominant language.`,
	},
	wenyan: {
		label: "wenyan",
		prompt: `Respond in classical Chinese (文言文). Maximum classical terseness — 80–90% character reduction. Classical patterns: verbs precede objects, subjects often omitted, classical particles (之/乃/為/其). Fully 文言 prose.
Technical terms, code, API names, CLI commands, exact error strings: keep verbatim. Never drop negation or qualifiers.`,
	},
};

const HEADER = `## Caveman Mode (ACTIVE EVERY RESPONSE)

Persist across every reply. No drift back to filler after many turns. Off only when user says "stop caveman" or "normal mode".`;

const AUTO_CLARITY = `Drop caveman when: security warnings, irreversible-action confirmations, multi-step sequences where omitted conjunctions risk misread, or compression itself creates technical ambiguity. Resume caveman after the clear part. Code, commits, PR text, docs, memory files: always normal prose — caveman governs chat replies only.`;

export default function caveman(pi: ExtensionAPI) {
	let level: Level | null = null;
	const status = () => (level ? `⛏ caveman:${LEVELS[level].label}` : "");

	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setStatus("caveman", status());
	});

	pi.on("before_agent_start", async (event) => {
		if (!level) return undefined;
		return {
			systemPrompt: `${event.systemPrompt}

${HEADER}

${LEVELS[level].prompt}

${AUTO_CLARITY}
`,
		};
	});

	pi.registerCommand("caveman", {
		description: "Caveman mode: terse output, fewer tokens (lite|full|ultra|wenyan|off)",
		getArgumentCompletions: (prefix: string) => {
			const opts = ["lite", "full", "ultra", "wenyan", "off"];
			const items = opts.map((o) => ({ value: o, label: o }));
			const filtered = items.filter((i) => i.value.startsWith(prefix));
			return filtered.length > 0 ? filtered : null;
		},
		handler: async (args, ctx) => {
			const arg = args.trim().toLowerCase();
			if (!arg) {
				// Toggle: off -> full (default), on -> off
				level = level ? null : "full";
			} else if (arg === "off" || arg === "normal" || arg === "stop") {
				level = null;
			} else if (arg in LEVELS) {
				level = arg as Level;
			} else {
				ctx.ui.notify(`Unknown level: ${arg}. Use lite|full|ultra|wenyan|off`, "error");
				return;
			}
			ctx.ui.setStatus("caveman", status());
			ctx.ui.notify(level ? `Caveman ${LEVELS[level].label} on` : "Caveman off", "info");
		},
	});
}
