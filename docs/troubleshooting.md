# Troubleshooting log

| Symptom | Cause | Fix |
|---|---|---|
| Can't log in to web UI | Wrong realm / expecting a default password | User `root`, realm *Linux PAM*, password set at install |
| Host unreachable after install | Installer IP `192.168.2.100` on wrong subnet | Static `192.168.86.20/24` on `vmbr0` |
| Odd IP on physical NIC | DHCP lease on `enx98fc84e0457e` instead of bridge | NIC `manual`, IP only on `vmbr0` |
| `ifreload -a` fails | Broken Wi-Fi `wpa_supplicant` stanza | Comment out Wi-Fi stanza |
| `bridge port does not exist` | PVE 9 NIC pinning: config says `nic0`, not yet renamed | Use real name or reboot — **open** |
| Can't `apt install` (offline) | No internet on host | USB-tether phone |
| Tether gets 169.254.x.x | DHCP failed | Flush address, toggle tethering, `dhclient` |
| Tether up but no internet | Default route still via `vmbr0` | Route default via phone gateway temporarily |
| `.tar.gz` wpa_supplicant won't install | It's source code | Install `.deb` via apt instead |
| Wi-Fi interface down | RF-kill / missing `iwlwifi` firmware | `rfkill unblock wifi`, install `firmware-iwlwifi` |
| VMs on Wi-Fi bridge get no traffic | AP drops non-authenticated MACs | NAT bridge `vmbr1` |
| No Proxmox tools in Claude | MCP server not loading | See [05-claude-mcp.md](05-claude-mcp.md) — **open** |
| No Connectivity | Network settings not configured| Run the following commands  |

## Hardware (pre-Proxmox, Ryzen box)
| Symptom | Cause | Fix |
|---|---|---|
| BSODs, MemTest86 failures | XMP applying 1.20 V instead of 1.35 V | Set DRAM voltage manually |
