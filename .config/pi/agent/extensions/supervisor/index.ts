/**
 * supervisor — persistent, messagable background workers with a live viewer.
 *
 * Workers are `pi --mode rpc` subprocesses. The extension communicates via
 * JSONL: commands to stdin (prompt, steer, abort), events from stdout
 * (message_end, tool_execution_end, agent_settled, etc.).
 *
 * Tools:
 *   spawn_worker({cwd, prompt, model?, tools?}) → workerId (non-blocking)
 *   message_worker({workerId, message, mode?}) → sends prompt/steer/followUp
 *   worker_status({workerId?}) → current state of one or all workers
 *
 * Viewer (Alt+S): list + transcript views, kill support.
 */

import { spawn, type ChildProcess } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { Message } from "@earendil-works/pi-ai";
import {
	type ExtensionAPI,
	withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { matchesKey, Key, truncateToWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const VIEWER_SHORTCUT = "alt+s";
const KEEP_COMPLETED = 30;
const STATUS_DISPLAY_LEN = 80;

/* ----------------------------- types ----------------------------- */

interface UsageStats {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
	contextTokens: number;
	turns: number;
}

interface WorkerSession {
	id: string;
	cwd: string;
	prompt: string;
	status: "starting" | "running" | "idle" | "done" | "error";
	messages: Message[];
	usage: UsageStats;
	model?: string;
	sessionId?: string;
	startedAt: number;
	endedAt?: number;
	lastSettledAt?: number;
	error?: string;
	stderr: string;
	proc: ChildProcess | null;
	listeners: Set<() => void>;
	abort?: () => void;
}

/* ----------------------------- registry ----------------------------- */

const workers = new Map<string, WorkerSession>();
let workerCounter = 0;
let statusFn: ((key: string, value: string | undefined) => void) | undefined;
let notifyFn: ((msg: string, level: "info" | "warning" | "error") => void) | undefined;
let sendMsgFn: ((msg: string) => void) | undefined;

function notify(w: WorkerSession) {
	for (const l of w.listeners) l();
}

function pruneCompleted() {
	const done = [...workers.values()].filter((w) => w.status === "done" || w.status === "error");
	if (done.length <= KEEP_COMPLETED) return;
	done.sort((a, b) => (a.endedAt ?? a.startedAt) - (b.endedAt ?? b.startedAt));
	for (const w of done.slice(0, done.length - KEEP_COMPLETED)) {
		w.listeners.clear();
		workers.delete(w.id);
	}
}

function updateStatus() {
	const running = [...workers.values()].filter((w) => w.status === "running" || w.status === "starting").length;
	if (running > 0) {
		statusFn?.("supervisor", `▶ ${running} worker${running > 1 ? "s" : ""} running • ${VIEWER_SHORTCUT} to view`);
	} else {
		statusFn?.("supervisor", undefined);
	}
}

/* ----------------------------- formatting ----------------------------- */

function formatTokens(n: number): string {
	if (n < 1000) return n.toString();
	if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
	if (n < 1000000) return `${Math.round(n / 1000)}k`;
	return `${(n / 1000000).toFixed(1)}M`;
}

function formatUsage(u: UsageStats, model?: string): string {
	const p: string[] = [];
	if (u.turns) p.push(`${u.turns}t`);
	if (u.input) p.push(`↑${formatTokens(u.input)}`);
	if (u.output) p.push(`↓${formatTokens(u.output)}`);
	if (u.cost) p.push(`$${u.cost.toFixed(4)}`);
	if (u.contextTokens > 0) p.push(`ctx:${formatTokens(u.contextTokens)}`);
	if (model) p.push(model);
	return p.join(" ");
}

function shorten(p: string): string {
	const home = os.homedir();
	return p.startsWith(home) ? `~${p.slice(home.length)}` : p;
}

type DisplayItem = { type: "text"; text: string } | { type: "toolCall"; name: string; args: Record<string, any> };

function displayItems(msgs: Message[]): DisplayItem[] {
	const items: DisplayItem[] = [];
	for (const m of msgs) {
		if (m.role !== "assistant") continue;
		for (const part of m.content) {
			if (part.type === "text" && part.text) items.push({ type: "text", text: part.text });
			else if (part.type === "toolCall") items.push({ type: "toolCall", name: part.name, args: part.arguments });
		}
	}
	return items;
}

function lastOutput(msgs: Message[]): string {
	for (let i = msgs.length - 1; i >= 0; i--) {
		if (msgs[i].role !== "assistant") continue;
		for (const part of msgs[i].content) if (part.type === "text" && part.text) return part.text;
	}
	return "";
}

function fmtToolCall(name: string, args: Record<string, unknown>, fg: (c: any, t: string) => string): string {
	switch (name) {
		case "bash": {
			const c = (args.command as string) || "...";
			return fg("muted", "$ ") + fg("toolOutput", c.slice(0, 60));
		}
		case "read": {
			const p = shorten((args.file_path || args.path || "...") as string);
			return fg("muted", "read ") + fg("accent", p);
		}
		case "write":
			return fg("muted", "write ") + fg("accent", shorten((args.file_path || args.path || "...") as string));
		case "edit":
			return fg("muted", "edit ") + fg("accent", shorten((args.file_path || args.path || "...") as string));
		case "ls":
			return fg("muted", "ls ") + fg("accent", shorten((args.path || ".") as string));
		case "grep":
			return fg("muted", "grep ") + fg("accent", `/${(args.pattern || "") as string}/`);
		case "find":
			return fg("muted", "find ") + fg("accent", (args.pattern || "*") as string);
		default: {
			const s = JSON.stringify(args).slice(0, 50);
			return fg("accent", name) + fg("dim", ` ${s}`);
		}
	}
}

function statusIcon(w: WorkerSession, theme: any): string {
	switch (w.status) {
		case "starting": return theme.fg("muted", "○");
		case "running": return theme.fg("warning", "⏳");
		case "idle": return theme.fg("accent", "●");
		case "done": return theme.fg("success", "✓");
		case "error": return theme.fg("error", "✗");
	}
}

function statusLabel(w: WorkerSession): string {
	return w.status;
}

/* ----------------------------- worker process ----------------------------- */

function getPiArgs(model?: string, tools?: string[]): string[] {
	const args = ["--mode", "rpc", "--no-session"];
	if (model) args.push("--model", model);
	if (tools && tools.length > 0) args.push("--tools", tools.join(","));
	return args;
}

function getPiInvocation(args: string[]): { command: string; args: string[] } {
	const script = process.argv[1];
	if (script && !script.startsWith("/$bunfs/root/") && fs.existsSync(script)) {
		return { command: process.execPath, args: [script, ...args] };
	}
	const exec = path.basename(process.execPath).toLowerCase();
	if (!/^(node|bun)(\.exe)?$/.test(exec)) return { command: process.execPath, args };
	return { command: "pi", args };
}

async function writeSystemPrompt(prompt: string): Promise<{ dir: string; file: string }> {
	const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-supervisor-"));
	const file = path.join(dir, "sysprompt.md");
	await withFileMutationQueue(file, () => fs.promises.writeFile(file, prompt, { encoding: "utf-8", mode: 0o600 }));
	return { dir, file };
}

function startWorker(
	cwd: string,
	prompt: string,
	model?: string,
	tools?: string[],
	systemPrompt?: string,
): WorkerSession {
	const id = `w${++workerCounter}`;
	const w: WorkerSession = {
		id, cwd, prompt,
		status: "starting",
		messages: [],
		usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, contextTokens: 0, turns: 0 },
		startedAt: Date.now(),
		stderr: "",
		proc: null,
		listeners: new Set(),
	};

	const args = getPiArgs(model, tools);
	let tmpDir: string | null = null;
	let tmpFile: string | null = null;

	// async init
	(async () => {
		if (systemPrompt?.trim()) {
			const tmp = await writeSystemPrompt(systemPrompt);
			tmpDir = tmp.dir;
			tmpFile = tmp.file;
			args.push("--append-system-prompt", tmpFile);
		}

		const invocation = getPiInvocation(args);
		const proc = spawn(invocation.command, invocation.args, {
			cwd: path.resolve(cwd),
			shell: false,
			stdio: ["pipe", "pipe", "pipe"],
		});
		w.proc = proc;

		w.abort = () => {
			try { proc.stdin.write(JSON.stringify({ type: "abort" }) + "\n"); } catch {}
			setTimeout(() => {
				try { proc.kill("SIGTERM"); } catch {}
				setTimeout(() => { try { proc.kill("SIGKILL"); } catch {} }, 3000);
			}, 2000);
		};

		let buf = "";
		const handleLine = (line: string) => {
			if (!line.trim()) return;
			let ev: any;
			try { ev = JSON.parse(line); } catch { return; }
			handleEvent(w, ev);
		};

		proc.stdout.on("data", (data) => {
			buf += data.toString();
			let idx: number;
			while ((idx = buf.indexOf("\n")) !== -1) {
				const line = buf.slice(0, idx);
				buf = buf.slice(idx + 1);
				if (line.endsWith("\r")) line.slice(0, -1);
				handleLine(line);
			}
		});

		proc.stderr.on("data", (data) => { w.stderr += data.toString(); });

		proc.on("close", (code) => {
			if (buf.trim()) handleLine(buf);
			if (w.status !== "done" && w.status !== "error") {
				w.status = code === 0 ? "done" : "error";
				if (code !== 0 && !w.error) w.error = `exited with code ${code}`;
			}
			w.endedAt = Date.now();
			w.abort = undefined;
			notify(w);
			updateStatus();
			notifyCompletion(w);
			pruneCompleted();
		});

		proc.on("error", () => {
			w.status = "error";
			w.error = "failed to start process";
			w.endedAt = Date.now();
			notify(w);
			updateStatus();
		});

		// send initial prompt
		try {
			proc.stdin.write(JSON.stringify({ type: "prompt", message: prompt }) + "\n");
		} catch {}

		notify(w);
	})();

	// cleanup tmp on shutdown
	w.listeners.add(() => {});

	return w;
}

function handleEvent(w: WorkerSession, ev: any) {
	switch (ev.type) {
		case "session":
			w.sessionId = ev.id;
			break;
		case "agent_start":
			w.status = "running";
			updateStatus();
			break;
		case "agent_settled":
			if (w.status === "running" || w.status === "starting") {
				w.status = "idle";
				w.lastSettledAt = Date.now();
				notifyCompletion(w);
			}
			updateStatus();
			break;
		case "message_end":
			if (ev.message) {
				w.messages.push(ev.message as Message);
				if (ev.message.role === "assistant") {
					w.usage.turns++;
					const u = ev.message.usage;
					if (u) {
						w.usage.input += u.input || 0;
						w.usage.output += u.output || 0;
						w.usage.cacheRead += u.cacheRead || 0;
						w.usage.cacheWrite += u.cacheWrite || 0;
						w.usage.cost += u.cost?.total || 0;
						w.usage.contextTokens = u.totalTokens || 0;
					}
					if (!w.model && ev.message.model) w.model = ev.message.model;
					if (ev.message.stopReason === "error") {
						w.status = "error";
						if (ev.message.errorMessage) w.error = ev.message.errorMessage;
					}
				}
			}
			break;
		case "extension_ui_request":
			handleUIRequest(w, ev);
			break;
	}
	notify(w);
}

function handleUIRequest(w: WorkerSession, req: any) {
	if (!w.proc?.stdin) return;
	const id = req.id;
	const method = req.method;
	const respond = (payload: Record<string, unknown>) => {
		try {
			w.proc?.stdin.write(JSON.stringify({ type: "extension_ui_response", id, ...payload }) + "\n");
		} catch {}
	};
	switch (method) {
		case "confirm":
			respond({ confirmed: true });
			break;
		case "select":
			respond({ value: req.options?.[0] ?? null });
			break;
		case "input":
		case "editor":
			respond({ value: "" });
			break;
		case "notify":
			// surface worker notifications in main session
			notifyFn?.(`[${w.id}] ${req.message ?? ""}`, (req.notifyType as any) ?? "info");
			break;
		default:
			// fire-and-forget (setStatus, setWidget, etc.) — ignore
			break;
	}
}

function notifyCompletion(w: WorkerSession) {
	if (w.status !== "idle" && w.status !== "done" && w.status !== "error") return;
	// avoid duplicate notifications for idle (agent_settled fires multiple times if worker gets re-prompted)
	if (w.status === "idle" && w.lastSettledAt && Date.now() - w.lastSettledAt > 1000) return;
	const out = lastOutput(w.messages).slice(0, STATUS_DISPLAY_LEN);
	const msg = w.status === "error"
		? `[${w.id}] error: ${w.error ?? w.stderr.slice(0, 100) ?? "unknown"}`
		: `[${w.id}] ${w.status === "done" ? "finished" : "idle"}: ${out || "(no output)"}`;
	notifyFn?.(msg, w.status === "error" ? "error" : "info");
	// also inject a follow-up message so the LLM can pick it up
	sendMsgFn?.(msg);
}

function sendCommand(w: WorkerSession, cmd: Record<string, unknown>): boolean {
	if (!w.proc?.stdin || w.proc.killed) return false;
	try {
		w.proc.stdin.write(JSON.stringify(cmd) + "\n");
		return true;
	} catch {
		return false;
	}
}

function killWorker(w: WorkerSession) {
	if (w.abort) w.abort();
	else if (w.proc) { try { w.proc.kill("SIGTERM"); } catch {} }
}

/* ----------------------------- worker status formatting ----------------------------- */

function formatWorkerStatus(w: WorkerSession): string {
	const lines: string[] = [];
	lines.push(`Worker ${w.id} [${statusLabel(w)}] in ${shorten(w.cwd)}`);
	lines.push(`  Task: ${w.prompt.slice(0, 100)}`);
	if (w.model) lines.push(`  Model: ${w.model}`);
	lines.push(`  Messages: ${w.messages.length}, Turns: ${w.usage.turns}, Cost: $${w.usage.cost.toFixed(4)}`);
	const out = lastOutput(w.messages);
	if (out) lines.push(`  Last output: ${out.slice(0, 500)}`);
	if (w.error) lines.push(`  Error: ${w.error}`);
	return lines.join("\n");
}

function formatAllWorkers(): string {
	const all = [...workers.values()];
	if (all.length === 0) return "No workers.";
	all.sort((a, b) => {
		const order = ["running", "starting", "idle", "done", "error"];
		return order.indexOf(a.status) - order.indexOf(b.status);
	});
	return all.map((w) => {
		const out = lastOutput(w.messages).slice(0, 80);
		return `${w.id} [${w.status}] ${shorten(w.cwd)} — ${w.prompt.slice(0, 40)}\n  ${out || "(no output yet)"}`;
	}).join("\n");
}

/* ----------------------------- live viewer ----------------------------- */

function sortedWorkers(): WorkerSession[] {
	return [...workers.values()].sort((a, b) => {
		const order = ["running", "starting", "idle", "done", "error"];
		const d = order.indexOf(a.status) - order.indexOf(b.status);
		if (d !== 0) return d;
		return (b.endedAt ?? b.startedAt) - (a.endedAt ?? a.startedAt);
	});
}

function transcriptLines(w: WorkerSession, theme: any, width: number): string[] {
	const fg = theme.fg.bind(theme);
	const lines: string[] = [];
	lines.push(fg("accent", theme.bold(w.id)) + fg("muted", ` ${statusLabel(w)} `) + statusIcon(w, theme) + fg("dim", `  ${shorten(w.cwd)}`));
	lines.push(fg("dim", w.prompt.slice(0, width - 2)));
	const u = formatUsage(w.usage, w.model);
	if (u) lines.push(fg("dim", u));
	lines.push(fg("muted", "─".repeat(Math.max(0, width - 2))));
	const items = displayItems(w.messages);
	if (items.length === 0) lines.push(fg("muted", "(waiting for output...)"));
	for (const item of items) {
		if (item.type === "text") {
			for (const ln of item.text.split("\n").slice(0, 4)) lines.push(fg("toolOutput", truncateToWidth(ln, width - 2)));
		} else {
			lines.push(fg("muted", "→ ") + truncateToWidth(fmtToolCall(item.name, item.args, fg), width - 2));
		}
	}
	return lines;
}

function createLiveViewer(tui: any, theme: any, _kb: any, done: (v: any) => void) {
	let view: "list" | "transcript" = "list";
	let selected = 0;
	let scrollBack = 0;
	let confirmKill = false;
	const subscribed = new Set<string>();
	const onChange = () => tui.requestRender();

	function ensureSubscribed() {
		for (const w of sortedWorkers()) {
			if (!subscribed.has(w.id)) { subscribed.add(w.id); w.listeners.add(onChange); }
		}
	}

	function termHeight(): number { return Math.max(10, process.stdout.rows || 24); }

	return {
		render(width: number): string[] {
			ensureSubscribed();
			const all = sortedWorkers();
			const innerW = Math.max(10, width - 2);
			if (all.length === 0) return [theme.fg("muted", "No workers. Use spawn_worker to start one.")];
			if (view === "list") {
				if (selected >= all.length) selected = all.length - 1;
				if (selected < 0) selected = 0;
				const lines: string[] = [theme.fg("accent", theme.bold("Workers")) + theme.fg("muted", ` — ${all.length} • up/down select • enter view • x kill • esc close`)];
				lines.push(theme.fg("muted", "─".repeat(Math.max(0, innerW - 2))));
				for (let i = 0; i < all.length; i++) {
					const w = all[i];
					const prefix = i === selected ? theme.fg("accent", "▶ ") : "  ";
					const label = `${statusIcon(w, theme)} ${theme.fg("accent", w.id)} ${theme.fg("dim", shorten(w.cwd).slice(0, 30))} ${theme.fg("muted", w.prompt.slice(0, 30))}`;
					lines.push(prefix + truncateToWidth(label, innerW - 2));
				}
				if (confirmKill) {
					const w = all[selected];
					if (w && (w.status === "running" || w.status === "idle" || w.status === "starting")) {
						lines.push("");
						lines.push(theme.fg("warning", `Kill ${w.id}? y to confirm • n/esc cancel`));
					} else confirmKill = false;
				}
				lines.push(theme.fg("dim", `${VIEWER_SHORTCUT} to open • esc close`));
				return lines;
			}
			// transcript view
			if (selected >= all.length) selected = all.length - 1;
			if (selected < 0) selected = 0;
			const w = all[selected];
			if (!w) return [theme.fg("muted", "(no worker)")];
			const allLines = transcriptLines(w, theme, innerW);
			const visible = Math.max(8, termHeight() - 6);
			const maxBack = Math.max(0, allLines.length - visible);
			if (scrollBack > maxBack) scrollBack = maxBack;
			const start = Math.max(0, allLines.length - visible - scrollBack);
			const win = allLines.slice(start, start + visible);
			const lines: string[] = [];
			if (start > 0) lines.push(theme.fg("muted", `… ${start} line${start === 1 ? "" : "s"} above`));
			for (const ln of win) lines.push(ln);
			lines.push(theme.fg("muted", "─".repeat(Math.max(0, innerW - 2))));
			const killable = w.status === "running" || w.status === "idle" || w.status === "starting";
			const killHint = killable ? " • x kill" : "";
			const nav = all.length > 1 ? " • tab next" : "";
			lines.push(theme.fg("dim", `up/down scroll • enter bottom${nav} • esc ${all.length > 1 ? "back" : "close"} • q close${killHint}`));
			if (confirmKill && killable) {
				lines.push("");
				lines.push(theme.fg("warning", `Kill ${w.id}? y to confirm • n/esc cancel`));
			}
			return lines;
		},
		invalidate() {},
		handleInput(data: string) {
			ensureSubscribed();
			const all = sortedWorkers();
			if (all.length === 0) {
				if (matchesKey(data, "escape") || matchesKey(data, "q")) done(null);
				tui.requestRender();
				return;
			}
			if (confirmKill) {
				if (matchesKey(data, "y")) {
					const w = all[selected];
					if (w) killWorker(w);
					confirmKill = false;
				} else if (matchesKey(data, "n") || matchesKey(data, "escape")) {
					confirmKill = false;
				}
				tui.requestRender();
				return;
			}
			if (view === "list") {
				if (matchesKey(data, Key.up) || matchesKey(data, Key.left)) selected = Math.max(0, selected - 1);
				else if (matchesKey(data, Key.down) || matchesKey(data, Key.right)) selected = Math.min(all.length - 1, selected + 1);
				else if (matchesKey(data, Key.enter)) { view = "transcript"; scrollBack = 0; }
				else if (matchesKey(data, "x")) {
					const w = all[selected];
					if (w && (w.status === "running" || w.status === "idle" || w.status === "starting")) confirmKill = true;
				}
				else if (matchesKey(data, "escape") || matchesKey(data, "q")) done(null);
			} else {
				if (matchesKey(data, Key.up)) scrollBack += 1;
				else if (matchesKey(data, Key.down)) scrollBack = Math.max(0, scrollBack - 1);
				else if (matchesKey(data, Key.enter) || matchesKey(data, Key.home)) scrollBack = 0;
				else if (matchesKey(data, Key.tab) && all.length > 1) { selected = (selected + 1) % all.length; scrollBack = 0; }
				else if (matchesKey(data, "x")) {
					const w = all[selected];
					if (w && (w.status === "running" || w.status === "idle" || w.status === "starting")) confirmKill = true;
				}
				else if (matchesKey(data, "escape")) { if (all.length > 1) view = "list"; else done(null); }
				else if (matchesKey(data, "q")) done(null);
			}
			tui.requestRender();
		},
	};
}

/* ----------------------------- tool parameters ----------------------------- */

const SpawnWorkerParams = Type.Object({
	cwd: Type.String({ description: "Working directory for the worker" }),
	prompt: Type.String({ description: "Initial prompt (text or /template command)" }),
	model: Type.Optional(Type.String({ description: "Model pattern (e.g. anthropic/claude-sonnet-4-5)" })),
	tools: Type.Optional(Type.Array(Type.String(), { description: "Tool allowlist" })),
	systemPrompt: Type.Optional(Type.String({ description: "Optional system prompt text" })),
});

const MessageWorkerParams = Type.Object({
	workerId: Type.String({ description: "Worker ID (e.g. w1)" }),
	message: Type.String({ description: "Message to send" }),
	mode: Type.Optional(Type.String({ description: '"steer" (deliver after current turn) or "followUp" (wait until idle). Required if worker is running.' })),
});

const WorkerStatusParams = Type.Object({
	workerId: Type.Optional(Type.String({ description: "Worker ID. Omit for all workers." })),
});

/* ----------------------------- extension ----------------------------- */

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		statusFn = (key, val) => ctx.ui.setStatus(key, val);
		notifyFn = (msg, level) => ctx.ui.notify(msg, level);
		sendMsgFn = (msg) => {
			// inject as a follow-up so the LLM sees worker completions
			pi.sendUserMessage(msg, { deliverAs: "followUp" });
		};
	});

	pi.registerTool({
		name: "spawn_worker",
		label: "Spawn Worker",
		description: "Start a persistent background worker in a given workspace. Returns immediately with a worker ID. The worker runs independently and streams progress back. Use worker_status to check progress, message_worker to send instructions.",
		promptSnippet: "Spawn a persistent background worker in a workspace",
		promptGuidelines: ["Use spawn_worker to start long-running background work (e.g. execution loops, reviews). Use worker_status to check progress, message_worker to steer."],
		parameters: SpawnWorkerParams,
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			const w = startWorker(params.cwd, params.prompt, params.model, params.tools, params.systemPrompt);
			return {
				content: [{ type: "text", text: `Worker ${w.id} started in ${shorten(params.cwd)}\nStatus: ${statusLabel(w)}\nTask: ${params.prompt.slice(0, 100)}\n\nUse worker_status({workerId: "${w.id}"}) to check progress.` }],
				details: { workerId: w.id },
			};
		},
	});

	pi.registerTool({
		name: "message_worker",
		label: "Message Worker",
		description: "Send a message to a running worker. If the worker is idle, the message is delivered immediately. If running, specify mode: 'steer' (after current turn) or 'followUp' (when idle).",
		promptSnippet: "Send a message to a background worker",
		parameters: MessageWorkerParams,
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			const w = workers.get(params.workerId);
			if (!w) return { content: [{ type: "text", text: `Unknown worker: ${params.workerId}` }], isError: true };
			if (!w.proc || w.proc.killed) return { content: [{ type: "text", text: `Worker ${params.workerId} is not running` }], isError: true };
			const cmd: Record<string, unknown> = { type: "prompt", message: params.message };
			const isRunning = w.status === "running";
			if (isRunning) {
				if (!params.mode) return { content: [{ type: "text", text: `Worker ${params.workerId} is running. Specify mode: "steer" or "followUp".` }], isError: true };
				cmd.streamingBehavior = params.mode;
			}
			const ok = sendCommand(w, cmd);
			if (!ok) return { content: [{ type: "text", text: `Failed to send message to ${params.workerId}` }], isError: true };
			return { content: [{ type: "text", text: `Sent to ${params.workerId}${isRunning ? ` (${params.mode})` : " (immediate)"}: ${params.message.slice(0, 80)}` }] };
		},
	});

	pi.registerTool({
		name: "worker_status",
		label: "Worker Status",
		description: "Check the status of a worker (or all workers). Returns current state, last output, usage, and progress. Call this when the user asks 'how's it going?' or before reviewing completed work.",
		promptSnippet: "Check status of background workers",
		parameters: WorkerStatusParams,
		async execute(_id, params, _signal, _onUpdate, _ctx) {
			if (params.workerId) {
				const w = workers.get(params.workerId);
				if (!w) return { content: [{ type: "text", text: `Unknown worker: ${params.workerId}` }], isError: true };
				return { content: [{ type: "text", text: formatWorkerStatus(w) }] };
			}
			return { content: [{ type: "text", text: formatAllWorkers() }] };
		},
	});

	pi.registerShortcut(VIEWER_SHORTCUT, {
		description: "Drop into the live worker viewer",
		handler: async (ctx) => {
			if (ctx.mode !== "tui") return;
			if (workers.size === 0) { ctx.ui.notify("No workers running", "info"); return; }
			await ctx.ui.custom<any>((tui, theme, kb, done) => createLiveViewer(tui, theme, kb, done), {
				overlay: true,
				overlayOptions: { width: "90%", maxHeight: "90%", anchor: "center" },
			});
		},
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		for (const w of workers.values()) {
			if (w.proc && !w.proc.killed) {
				try { w.proc.stdin?.write(JSON.stringify({ type: "abort" }) + "\n"); } catch {}
				setTimeout(() => { try { w.proc?.kill("SIGTERM"); } catch {} }, 500);
			}
			w.listeners.clear();
		}
		workers.clear();
		ctx.ui.setStatus("supervisor", undefined);
		statusFn = undefined;
		notifyFn = undefined;
		sendMsgFn = undefined;
	});
}
