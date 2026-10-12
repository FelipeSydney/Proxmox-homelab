#!/usr/bin/env bash
# Create a read-only Proxmox API user + token for the Claude MCP server.
# Run on the Proxmox host as root. Prints the token secret ONCE — store it safely.
set -euo pipefail

USER_ID="${1:-claude@pve}"
TOKEN_ID="${2:-mcp}"
ROLE="${3:-PVEAuditor}"   # read-only; use PVEVMAdmin later if you want VM control

if ! pveum user list --output-format json | grep -q "\"userid\":\"${USER_ID}\""; then
  pveum user add "${USER_ID}" --comment "Claude MCP"
fi

pveum acl modify / --users "${USER_ID}" --roles "${ROLE}"
pveum user token add "${USER_ID}" "${TOKEN_ID}" --privsep 0

echo
echo "Token ID: ${USER_ID}!${TOKEN_ID}  (role: ${ROLE})"
echo "Copy the 'value' above into claude_desktop_config.json — do not commit it."
