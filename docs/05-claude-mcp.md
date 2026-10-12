# 05 — Connecting Claude to Proxmox (MCP)

## Approach
No official connector exists. Use a community MCP server that talks to the Proxmox API (port 8006):
- `gilby125/mcp-proxmox`
- `ProxmoxMCP-Plus`
- `@bldg-7/proxmox-mcp`

The server runs **locally on the PC with Claude Desktop** (`pc1`), not on the Proxmox host.

## 1. API user and token (on the Proxmox host)
Run [`scripts/create-claude-api-token.sh`](../scripts/create-claude-api-token.sh), or manually:
```bash
pveum user add claude@pve --comment "Claude MCP"
pveum acl modify / --users claude@pve --roles PVEAuditor
pveum user token add claude@pve mcp --privsep 0
```
Copy the token secret once — it's not shown again. Start **read-only** (`PVEAuditor`); widen only if you want Claude to start/stop VMs.

## 2. Claude Desktop config (on pc1)
File: `%APPDATA%\Claude\claude_desktop_config.json` (or Settings → Developer → Edit Config).
Template: [`configs/claude_desktop_config.example.json`](../configs/claude_desktop_config.example.json). Add `mcpServers` as a top-level key alongside the existing ones.

- Edit **while Claude Desktop is closed** — it can overwrite the file while running.
- Fully quit from the system tray, then reopen.

## Status: not loading (as of 2026-10-11)
No Proxmox tools appear in chat. Check in order:
1. App fully quit from the tray and reopened?
2. JSON valid? `python -m json.tool claude_desktop_config.json`
3. Does the server's command start by itself in a terminal? (Python/uv/Node installed and on PATH, path correct)
4. Logs: `%APPDATA%\Claude\logs\mcp*.log`
5. From `pc1`, can you reach `https://192.168.86.20:8006`? Self-signed cert may need the server's "verify SSL = false" option.

## Security
- Don't expose 8006 to the internet. Remote access via Tailscale or WireGuard.
- Never commit the token secret.
