#!/usr/bin/env bash
set -euo pipefail
time -p cd "$(dirname "$0")"
/usr/bin/time -p pwd
PROJECT_ROOT="$PWD"
DIST_DIR="$PROJECT_ROOT/dist"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
PORT="${PORT:-3000}"
export PORT PROJECT_ROOT
/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p node --version
if /usr/bin/time -p test -f "$PROJECT_ROOT/package.json"; then
  /usr/bin/time -p npm install --no-audit --no-fund
  /usr/bin/time -p npm run build --if-present
else
  /usr/bin/time -p echo "no package.json: static dist, skipping npm install/build"
fi
/usr/bin/time -p mkdir -p "$WEB_DIR"
/usr/bin/time -p sh -c 'printf "{\"project\":\"%s\",\"directory\":\"%s\"}" "$1" "$2" > "$3"' sh "$PROJECT_ROOT" "$DIST_DIR" "$WEB_DIR/deployment-output.json"
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p node -e '
const { createServer } = require("node:http");
const { readFileSync, statSync, existsSync } = require("node:fs");
const { resolve, join, extname } = require("node:path");
const root = resolve(process.env.PROJECT_ROOT || process.cwd(), "dist");
const port = Number(process.env.PORT || 3000);
const mime = { ".html":"text/html", ".js":"application/javascript", ".css":"text/css", ".json":"application/json", ".svg":"image/svg+xml", ".png":"image/png", ".jpg":"image/jpeg", ".webp":"image/webp", ".wasm":"application/wasm", ".glb":"model/gltf-binary" };
if (!existsSync(join(root, "index.html"))) { console.error("missing dist/index.html"); process.exit(1); }
createServer((req, res) => {
  try {
    const url = new URL(req.url, "http://localhost");
    let path = resolve(root, "." + decodeURIComponent(url.pathname));
    if (path !== resolve(root) && !path.startsWith(resolve(root) + "/")) { res.writeHead(404); res.end(); return; }
    try { if (statSync(path).isDirectory()) path = join(path, "index.html"); } catch { path = join(root, "index.html"); }
    res.setHeader("Content-Type", mime[extname(path)] || "application/octet-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.end(readFileSync(path));
  } catch { res.writeHead(404); res.end("Not found"); }
}).listen(port, "0.0.0.0", () => console.log("serving " + root + " on " + port));
'
