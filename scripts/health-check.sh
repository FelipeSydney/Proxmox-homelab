#!/usr/bin/env bash
# Quick Proxmox host status. Run on the host as root.
set -uo pipefail

section() { printf '\n=== %s ===\n' "$1"; }

section "Version / uptime";  pveversion; uptime
section "Network";           ip -br addr; ip route | head -5
section "Hostname";          echo "fqdn: $(hostname --fqdn)  ip: $(hostname --ip-address)"
section "Storage";           pvesm status
section "VMs";               qm list
section "Containers";        pct list
if command -v zpool >/dev/null; then section "ZFS"; zpool status -x; fi
section "Recent errors";     journalctl -p err -b --no-pager | tail -20
