# Proxmox Homelab

Personal Proxmox VE homelab: build notes, configs, scripts and a running log of what's been done.
Built up from troubleshooting sessions from March 2026 onward.

## At a glance

| Item | Value |
|---|---|
| Host hardware | HP G8 laptop (Intel), Proxmox installed bare metal |
| Hypervisor | Proxmox VE 9 (NIC pinning in use, so interfaces may show as `nic0`) |
| Management IP | `192.168.86.161/24` on `vmbr0`, gateway `192.168.86.1` |
| Web UI | `https://192.168.86.161:8006` (login `root`, realm *Linux PAM*) |
| Wired uplink | USB Ethernet adapter `enx98fc84e0457e` → bridged on `vmbr0` |
| Wi-Fi | Intel CNVi (`iwlwifi`), host connectivity only |
| Hostname plan | `pve01.home.arpa` (recommended; confirm what's actually set) |
| Client machine | Windows PC (`pc1`) |
| Other hardware | Ryzen 5 3600 / MSI B550 Tomahawk (AM4) box — possible future node |

### Laptop-as-host notes
- No built-in RJ45, hence the USB Ethernet adapter. Use a fixed USB port so the interface name stays stable.
- Set the lid to not suspend: `HandleLidSwitch=ignore` in `/etc/systemd/logind.conf`, then `systemctl restart systemd-logind`.
- Keep it on AC; consider capping battery charge in BIOS if the option exists, as it'll sit plugged in 24/7.
- Intel CPU: nested virtualisation uses `kvm_intel`, not `kvm_amd`.

## Status

- [x] Proxmox VE installed, web UI reachable
- [x] `vmbr0` fixed: IP moved off the physical NIC onto the bridge, correct subnet (`192.168.86.x`)
- [x] Wi-Fi tooling installed offline via USB phone tethering
- [ ] Resolve `nic0` pinning mismatch (`bridge port does not exist`) — see [docs/03-networking.md](docs/03-networking.md)
- [ ] DHCP reservation for `.20` on the router
- [ ] Update `/etc/hosts` to the new IP and final FQDN
- [ ] Get the Proxmox MCP server loading in Claude Desktop — see [docs/05-claude-mcp.md](docs/05-claude-mcp.md)
- [ ] First workloads (Debian LXC, Rocky VM, storage) — see [docs/06-roadmap.md](docs/06-roadmap.md)

## Repo layout

```
docs/
  01-installation.md      Install steps and first login
  02-hostname-fqdn.md     FQDN choice and how to change it
  03-networking.md        vmbr0 bridge, NIC pinning, IP change
  04-wifi.md              Wi-Fi on the host, NAT bridge, offline package install
  05-claude-mcp.md        Connecting Claude via a Proxmox MCP server
  06-roadmap.md           Planned VMs/LXCs, storage, GNS3, remote access
  11-Windows Sharedrive.md  Share Windows D: drive and mount it on Proxmox (SMB/CIFS)
  troubleshooting.md      Problems hit so far and how they were fixed
configs/                  Sanitised example configs (no secrets)
scripts/                  Helper scripts to run on the Proxmox host
LOG.md                    Dated log of work done
```

## Conventions

- **No secrets in this repo.** API token secrets, Wi-Fi PSKs and passwords stay out; examples use placeholders. `.gitignore` blocks the obvious files.
- Every change to the host gets a line in [LOG.md](LOG.md).
