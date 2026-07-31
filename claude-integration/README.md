# After Effects MCP Bridge - Omar Edition (with Claude)

This is [a-y-ibrahim/after-effects-mcp](https://github.com/a-y-ibrahim/after-effects-mcp) (MIT) plus a reliability layer
in `claude-integration/` that makes the bridge work on Windows machines running the
**Microsoft Store (MSIX) version of Claude Desktop** - built and battle-tested with Claude on 2026-07-31.

## Why this layer exists (3 real-world problems it solves)

1. **MSIX file virtualization**: the Store version of Claude writes `%LOCALAPPDATA%` files into an isolated
   package folder, so the AE panel never sees the command files. Fix: a neutral bridge folder outside
   AppData (`C:\Users\<you>\claude-tools\ae-bridge`) selected via the `AE_MCP_BRIDGE_DIR` env var (both sides honor it).
2. **Dead `app.scheduleTask`**: on some machines AE never fires its polling timer, so commands sit unprocessed.
   Fix: an external `FileSystemWatcher` (ae-bridge-watcher.ps1) that runs `AfterFX.exe -r tick2.jsx` the moment
   a command file appears (event-driven, ~1s latency, with a 2s polling fallback).
3. **Context-dependent script permissions**: panel/timer-context file writes can be denied while `-r` script
   writes are allowed. tick2.jsx executes commands in the allowed `-r` context, respects the panel's
   Auto-run checkbox (your kill switch), and never launches AE if it is not already running.

## Fresh machine setup (Windows)

1. `git clone` this repo to `C:\Users\<you>\claude-tools\after-effects-mcp`
2. `npm install` then `npm run install-bridge` (installs the panel into AE user ScriptUI Panels)
3. In AE: Preferences > Scripting & Expressions > enable "Allow Scripts to Write Files and Access Network"
4. Create `C:\Users\<you>\claude-tools\ae-bridge` and set user env var `AE_MCP_BRIDGE_DIR` to that path (`setx AE_MCP_BRIDGE_DIR ...`)
5. Register the server in `%APPDATA%\Claude\claude_desktop_config.json`:
   `{"mcpServers":{"after-effects":{"command":"node","args":["C:\\Users\\<you>\\claude-tools\\after-effects-mcp\\build\\index.js"],"env":{"AE_MCP_BRIDGE_DIR":"C:\\Users\\<you>\\claude-tools\\ae-bridge"}}}}`
6. Copy the 3 files from `claude-integration/` to `C:\Users\<you>\claude-tools\`
7. Auto-start the watcher: add a `HKCU\...\Run` value running `watcher-start.ps1` (see file header), or just run it manually
8. Restart Claude Desktop, open AE, open Window > mcp-bridge-auto.jsx (dock it in your workspace so it reopens)
9. Ask Claude to `check the After Effects bridge` - expect `ok: true`

## Kill switch

- Soft: uncheck **Auto-run commands** in the panel (tick2 respects it)
- Hard: kill the `ae-bridge-watcher` PowerShell process and/or delete its Run key

Verified end-to-end: compositions, RTL Arabic text layers, keyframes, effects, expressions, render queue to H.264.
