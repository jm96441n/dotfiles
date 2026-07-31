import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

// Bridges MCP servers into pi tools. Pi has no built-in MCP support by design,
// so this extension runs an MCP client per server and registers each remote
// tool as a native pi tool that forwards calls over the MCP client.
//
// Connections are deferred to session_start (factories may run without a
// session and must not spawn background resources) and torn down in
// session_shutdown. Each server connects independently; one failing does not
// affect the others.

type ConnectFn = (cwd: string) => Promise<Client>;

type ServerDef = {
  name: string;
  connect: ConnectFn;
};

const clients = new Map<string, Client>();

const servers: ServerDef[] = [
  {
    name: "codegraph",
    connect: (cwd) => {
      const transport = new StdioClientTransport({
        command: "codegraph",
        args: ["serve", "--mcp"],
        cwd,
      });
      const client = new Client(
        { name: "pi", version: "1" },
        { capabilities: {} },
      );
      return client.connect(transport).then(() => client);
    },
  },
  {
    name: "context7",
    connect: () => {
      const headers: Record<string, string> = {};
      const key = process.env.CONTEXT7_KEY;
      if (key) headers["CONTEXT7_API_KEY"] = key;
      const transport = new StreamableHTTPClientTransport(
        new URL("https://mcp.context7.com/mcp"),
        { requestInit: { headers } },
      );
      const client = new Client(
        { name: "pi", version: "1" },
        { capabilities: {} },
      );
      return client.connect(transport).then(() => client);
    },
  },
];

// Map an MCP content item to a pi content part.
function toPiContent(item: any): any {
  if (item?.type === "text") return { type: "text", text: item.text };
  if (item?.type === "image")
    return {
      type: "image",
      source: {
        type: "base64",
        mediaType: item.mimeType ?? "image/png",
        data: item.data,
      },
    };
  if (item?.type === "resource" && item.resource) {
    const r = item.resource;
    if (r.text) return { type: "text", text: r.text };
    if (typeof r.uri === "string")
      return { type: "text", text: `[resource: ${r.uri}]` };
  }
  return { type: "text", text: JSON.stringify(item) };
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    for (const server of servers) {
      try {
        const client = await server.connect(ctx.cwd);
        clients.set(server.name, client);

        const { tools } = await client.listTools();
        for (const tool of tools) {
          // Namespaced name so the tool's origin is unambiguous in the list.
          const namespaced = `${server.name}_${tool.name}`;
          // Embed the MCP tool's JSON schema directly via Type.Unsafe so the
          // LLM sees the real parameter shape without manual conversion.
          const parameters = Type.Unsafe(tool.inputSchema ?? { type: "object" });
          pi.registerTool({
            name: namespaced,
            label: `${server.name}: ${tool.name}`,
            description:
              tool.description ??
              `${server.name} MCP tool: ${tool.name}`,
            parameters: parameters as any,
            async execute(_id, params, _signal, _onUpdate, _ctx) {
              try {
                const result: any = await client.callTool({
                  name: tool.name,
                  arguments: params as Record<string, unknown>,
                });
                const content = (result?.content ?? []).map(toPiContent);
                if (content.length === 0)
                  content.push({ type: "text", text: "(no output)" });
                return {
                  content,
                  isError: result?.isError === true,
                  details: { server: server.name, tool: namespaced },
                };
              } catch (err: any) {
                return {
                  content: [
                    {
                      type: "text",
                      text: `${namespaced} failed: ${err?.message ?? String(err)}`,
                    },
                  ],
                  isError: true,
                  details: { server: server.name, tool: namespaced },
                };
              }
            },
          });
        }

        if (ctx.hasUI)
          ctx.ui.notify(
            `mcp: ${server.name} ready (${tools.length} tools)`,
            "info",
          );
      } catch (err: any) {
        const msg = `${server.name}: ${err?.message ?? String(err)}`;
        if (ctx.hasUI) ctx.ui.notify(`mcp: ${msg}`, "error");
      }
    }
  });

  pi.on("session_shutdown", async () => {
    for (const [name, client] of clients) {
      try {
        await client.close();
      } catch {
        // best-effort cleanup
      }
      clients.delete(name);
    }
  });
}
