# 06 — Roadmap

## Guests
| Workload | Type | Notes |
|---|---|---|
| General services | Debian LXC | Default for most things; works with Proxmox community helper scripts |
| Docker host | Debian/Ubuntu VM | Portainer, Nginx Proxy Manager, Uptime Kuma, etc. Docker in a VM, not an LXC |
| RHEL practice | Rocky or AlmaLinux VM | dnf, SELinux, firewalld; optional free RHEL developer subscription (RHCSA) |
| Network lab | GNS3 VM (nested) | `kvm_amd nested=1`, CPU type `host`; GUI from the ZBook. EVE-NG is an alternative |
| Windows / Intune test clients | VM | Work-relevant lab |
| Local AI | LXC/VM | Open WebUI in front of Ollama |
| Monitoring | LXC | Prometheus + Grafana |
| Media | Jellyfin LXC | Bind-mounted storage; software transcode on a 3600 (no iGPU) |
| Claude ops box | LXC | Claude Code for Ansible/Terraform/cloud-init — optional |

## Storage
Two options (pick one):
- **Proxmox ZFS mirror + Samba LXC** — fewer moving parts.
- **TrueNAS SCALE VM** with SATA controller/HBA (IT mode) passthrough, 8–16 GB RAM.

Mirror ≠ backup: keep an off-box copy. Add Proxmox Backup Server or scheduled `vzdump` to external storage.

## Platform
- [ ] Proxmox no-subscription repo + updates
- [ ] Non-root admin user + 2FA
- [ ] Tailscale/WireGuard for remote access (no port forwarding)
- [ ] Backups scheduled and a restore tested
- [ ] Debian & Ubuntu cloud-init templates
- [ ] Decide whether the Ryzen 5 3600 box becomes the main node (cluster later?)

## Why LXC first
Shares the host kernel: ~20–50 MB idle RAM vs hundreds for a VM, near-native performance, boots in seconds. Use a VM when you need a different kernel/OS, strong isolation, or Docker.
