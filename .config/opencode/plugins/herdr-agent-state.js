// installed by herdr
// managed by herdr; reinstalling or updating the integration overwrites this file.
// add custom hooks/plugins beside this file instead of editing it.
// HERDR_INTEGRATION_ID=opencode
// HERDR_INTEGRATION_VERSION=11
// Hand-ported to the OpenCode V2 plugin API; `herdr integration install` will revert it to V1.

import net from "node:net";

const SOURCE = "herdr:opencode";
const AGENT = "opencode";
let reportSeq = Date.now() * 1000;
let requestChain = Promise.resolve();
let reportedRootSessionID;

// Track child sessions so their events cannot replace the pane's root session.
// User prompts carry the root id to preserve its identity and cross-talk guard.
const childSessions = new Map();
const CHILD_EVENT_STATES = new Map([
  ["permission.asked", "blocked"],
  ["question.asked", "blocked"],
  ["permission.replied", "working"],
  ["question.replied", "working"],
  ["question.rejected", "working"],
]);

function nextReportSeq() {
  reportSeq += 1;
  return reportSeq;
}

function sessionIDFromProperties(properties) {
  return typeof properties?.sessionID === "string" && properties.sessionID
    ? properties.sessionID
    : undefined;
}

const SESSION_STATE_BY_STATUS = new Map([
  ["idle", "idle"],
  ["active", "working"],
  ["busy", "working"],
  ["pending", "working"],
  ["retry", "working"],
  ["running", "working"],
  ["streaming", "working"],
  ["working", "working"],
]);

function stateFromSessionStatus(status) {
  const kind = typeof status === "string" ? status : status?.type;
  return typeof kind === "string"
    ? SESSION_STATE_BY_STATUS.get(kind.toLowerCase())
    : undefined;
}

function request(method, params) {
  const pending = requestChain.then(() => requestOnce(method, params));
  requestChain = pending.catch(() => {});
  return pending;
}

function requestOnce(method, params) {
  const paneId = process.env.HERDR_PANE_ID;
  const socketPath = process.env.HERDR_SOCKET_PATH;

  if (!paneId || !socketPath) {
    return Promise.resolve();
  }

  const socketEndpoint =
    process.platform === "win32" ? `\\\\.\\pipe\\${socketPath}` : socketPath;

  const requestId = `${SOURCE}:${Date.now()}:${Math.floor(Math.random() * 1_000_000)
    .toString()
    .padStart(6, "0")}`;
  const request = {
    id: requestId,
    method,
    params: {
      pane_id: paneId,
      source: SOURCE,
      agent: AGENT,
      seq: nextReportSeq(),
      ...params,
    },
  };

  return new Promise((resolve) => {
    const client = net.createConnection(socketEndpoint, () => {
      client.write(`${JSON.stringify(request)}\n`);
    });

    const finish = () => {
      client.destroy();
      resolve();
    };

    client.setTimeout(500, finish);
    client.on("data", finish);
    client.on("error", finish);
    client.on("end", finish);
    client.on("close", resolve);
  });
}

function reportSession(sessionID) {
  if (!sessionID) {
    return Promise.resolve();
  }
  return request("pane.report_agent_session", { agent_session_id: sessionID });
}

function reportState(state, sessionID) {
  const params = { state };
  if (sessionID) {
    reportedRootSessionID = sessionID;
    params.agent_session_id = sessionID;
  }
  return request("pane.report_agent", params);
}

// V2 renamed V1 events; normalize to the names the handler below uses.
const V2_EVENT_TYPES = new Map([
  ["form.created", "question.asked"],
  ["form.replied", "question.replied"],
  ["form.cancelled", "question.rejected"],
  ["session.tool.called", "tool.execute.before"],
  ["session.compaction.ended", "session.compacted"],
  ["session.execution.failed", "session.error"],
]);

async function handleEvent(event) {
  const type = V2_EVENT_TYPES.get(event?.type) ?? event?.type;
  const data = event?.data ?? {};
  const sessionID =
    sessionIDFromProperties(data) ?? sessionIDFromProperties(data.form);

  if (type === "session.created" && sessionID && data.parentID) {
    childSessions.set(sessionID, data.parentID);
  }
  if (sessionID && childSessions.has(sessionID)) {
    const state = CHILD_EVENT_STATES.get(type);
    if (state) {
      let rootSessionID = sessionID;
      while (childSessions.has(rootSessionID)) {
        rootSessionID = childSessions.get(rootSessionID);
      }
      await reportState(state, rootSessionID);
    }
    return;
  }

  switch (type) {
    case "session.created":
      // Creation is server-global, so an attached client may own it. The
      // TUI plugin separately reports the root selected in this pane.
      reportedRootSessionID = sessionID;
      break;
    case "session.status": {
      const state = stateFromSessionStatus(data.status);
      if (state) {
        await reportState(state, sessionID);
      } else if (sessionID !== reportedRootSessionID) {
        await reportSession(sessionID);
      }
      break;
    }
    case "tool.execute.before":
    case "permission.replied":
    case "question.replied":
    case "question.rejected":
    case "session.compacted":
      await reportState("working", sessionID);
      break;
    case "permission.asked":
    case "question.asked":
    case "session.error":
      await reportState("blocked", sessionID);
      break;
    case "session.idle":
      await reportState("idle", sessionID);
      break;
    default:
      break;
  }
}

export default {
  id: "herdr-agent-state",
  async setup(ctx) {
    if (
      process.env.HERDR_ENV !== "1" ||
      !process.env.HERDR_SOCKET_PATH ||
      !process.env.HERDR_PANE_ID
    ) {
      return;
    }

    await ctx.session.hook("prompt", async ({ sessionID }) => {
      if (sessionID && childSessions.has(sessionID)) {
        return;
      }
      await reportState("working", sessionID);
    });

    const controller = new AbortController();
    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
          await handleEvent(event).catch(() => {});
        }
      } catch {
        // stream aborted on unload
      }
    })();

    return () => controller.abort();
  },
};
