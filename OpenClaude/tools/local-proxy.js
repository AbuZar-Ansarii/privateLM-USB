/**
 * local-proxy.js
 * Sits between OpenClaude and Ollama.
 * Trims the system prompt to reduce token count and speed up local inference.
 *
 * OpenClaude -> localhost:11435 (this proxy) -> localhost:11434 (Ollama)
 *
 * All output goes to data/proxy.log — never stdout/stderr,
 * so it does not corrupt the OpenClaude TUI display.
 */

const http = require("http");
const fs   = require("fs");
const path = require("path");

const PROXY_PORT  = 11435;
const OLLAMA_HOST = "127.0.0.1";
const OLLAMA_PORT = 11434;

// Log to file only — never touch stdout/stderr (breaks OpenClaude TUI)
// This file is now in /tools, so we go up one level to find /data
const LOG_FILE = path.join(__dirname, "..", "data", "proxy.log");
function log(msg) {
  const line = `[${new Date().toISOString()}] ${msg}\n`;
  try { fs.appendFileSync(LOG_FILE, line); } catch {}
}

// ---------------------------------------------------------------------------
// System prompt trimmer
// ---------------------------------------------------------------------------
function trimSystemPrompt(content) {
  if (typeof content !== "string") return content;

  const MAX_CHARS = 1200; // ~300 tokens

  if (content.length <= MAX_CHARS) return content;

  const cut = content.lastIndexOf(". ", MAX_CHARS);
  const trimPoint = cut > MAX_CHARS * 0.6 ? cut + 1 : MAX_CHARS;

  return (
    content.slice(0, trimPoint).trimEnd() +
    "\n\n[System prompt truncated for local model performance]"
  );
}

function optimizeMessages(messages) {
  if (!Array.isArray(messages)) return messages;

  return messages.map((msg) => {
    if (msg.role !== "system") return msg;

    if (typeof msg.content === "string") {
      return { ...msg, content: trimSystemPrompt(msg.content) };
    }

    if (Array.isArray(msg.content)) {
      return {
        ...msg,
        content: msg.content.map((part) => {
          if (part.type === "text") {
            return { ...part, text: trimSystemPrompt(part.text) };
          }
          return part;
        }),
      };
    }

    return msg;
  });
}

// ---------------------------------------------------------------------------
// Proxy server
// ---------------------------------------------------------------------------
const server = http.createServer((req, res) => {
  let body = [];

  req.on("data", (chunk) => body.push(chunk));

  req.on("end", () => {
    let rawBody = Buffer.concat(body);
    let modifiedBody = rawBody;

    if (req.method === "POST" && req.url.includes("/chat/completions")) {
      try {
        const json = JSON.parse(rawBody.toString("utf8"));

        if (json.messages) {
          const before = JSON.stringify(json.messages).length;
          json.messages = optimizeMessages(json.messages);
          const after  = JSON.stringify(json.messages).length;
          const saved  = Math.round(((before - after) / before) * 100);
          if (saved > 0) {
            log(`Trimmed: ${before} -> ${after} chars (${saved}% reduction)`);
          }
        }

        modifiedBody = Buffer.from(JSON.stringify(json), "utf8");
      } catch {
        modifiedBody = rawBody;
      }
    }

    const options = {
      hostname: OLLAMA_HOST,
      port:     OLLAMA_PORT,
      path:     req.url,
      method:   req.method,
      headers: {
        ...req.headers,
        host:             `${OLLAMA_HOST}:${OLLAMA_PORT}`,
        "content-length": modifiedBody.length,
      },
    };

    const proxyReq = http.request(options, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res, { end: true });
    });

    proxyReq.on("error", (err) => {
      log(`Ollama connection error: ${err.message}`);
      res.writeHead(502);
      res.end(JSON.stringify({ error: "Ollama unreachable: " + err.message }));
    });

    proxyReq.write(modifiedBody);
    proxyReq.end();
  });
});

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    log(`Port ${PROXY_PORT} already in use - reusing existing proxy instance`);
    process.exit(0); // Exit cleanly, don't crash to stderr
  }
  log(`Server error: ${err.message}`);
  process.exit(1);
});

server.listen(PROXY_PORT, "127.0.0.1", () => {
  log(`Proxy started on :${PROXY_PORT} -> Ollama :${OLLAMA_PORT}`);
});
