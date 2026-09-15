/**
 * Agents banner — append an [Agents] section under pi's welcome banner,
 * listing custom agents from the same dirs pi-subagents discovers:
 * <cwd>/.pi/agents (project) and ~/.pi/agent/agents (global).
 *
 * pi core has no extension hook into the welcome banner itself, so this
 * appends a custom entry styled to match (mdHeading header, dim list).
 */

import { readdirSync, readFileSync } from "node:fs";
import { basename, join } from "node:path";
import { getAgentDir, parseFrontmatter } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const TYPE = "agents-banner";

function loadAgentNames(cwd: string): string[] {
	const names = new Set<string>();
	// global first, project overwrites on name clash — same precedence as pi-subagents
	for (const dir of [join(getAgentDir(), "agents"), join(cwd, ".pi", "agents")]) {
		let files: string[];
		try {
			files = readdirSync(dir).filter((f) => f.endsWith(".md"));
		} catch {
			continue;
		}
		for (const f of files) {
			let name = basename(f, ".md");
			try {
				const { frontmatter } = parseFrontmatter(readFileSync(join(dir, f), "utf8"));
				if (typeof frontmatter.name === "string" && frontmatter.name.trim()) name = frontmatter.name.trim();
			} catch {
				// unreadable file — filename is the name
			}
			names.add(name);
		}
	}
	return [...names].sort((a, b) => a.localeCompare(b));
}

export default function agentsBanner(pi: ExtensionAPI) {
	pi.registerEntryRenderer(TYPE, (entry, _opts, theme) => {
		const agents = (entry.data as { agents: string[] }).agents;
		return new Text(
			`${theme.fg("mdHeading", "[Agents]")}\n${theme.fg("dim", `  ${agents.join(", ")}`)}`,
			0,
			1,
		);
	});

	pi.on("session_start", async (event, ctx) => {
		if (event.reason !== "startup" && event.reason !== "reload") return;
		const agents = loadAgentNames(process.cwd());
		if (agents.length === 0) return;
		// skip if a previous session (resume) already has one in the transcript
		const already = ctx.sessionManager
			.getEntries()
			.some((e) => e.type === "custom" && e.customType === TYPE);
		if (already) return;
		pi.appendEntry(TYPE, { agents });
	});
}
