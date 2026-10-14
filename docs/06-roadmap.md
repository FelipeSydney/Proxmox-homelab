# 06 — Roadmap

## Guests
| Workload | Type | Notes |
|---|---|---|
| General services | Debian LXC | Default for most things; works with Proxmox community helper scripts |
| Docker host | Debian/Ubuntu VM | Portainer, Nginx Proxy Manager, Uptime Kuma, etc. Docker in a VM, not an LXC |
| RHEL practice | Rocky or AlmaLinux VM | dnf, SELinux, firewalld; optional free RHEL developer subscription (RHCSA) |
| Network lab | GNS3 VM (nested) | `kvm_intel nested=1` on the laptop host (`kvm_amd` if moved to the Ryzen box), CPU type `host`; GUI from `pc1`. EVE-NG is an alternative |
| Windows / Intune test clients | VM | Work-relevant lab |
| Local AI | LXC/VM | Open WebUI in front of Ollama |
| Monitoring | LXC | Prometheus + Grafana |
| Media | Jellyfin LXC | Bind-mounted storage; the laptop's Intel iGPU can do Quick Sync transcoding via `/dev/dri` passthrough to the LXC |
| Claude ops box | LXC | Claude Code for Ansible/Terraform/cloud-init — optional |
| Authentik | SSO | SSO Authentication service for home network |
| Remote Access | VPN | VPN service for remote access |

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
- [ ] Decide whether the Ryzen 5 3600 box becomes a second node or replaces the laptop (more RAM/disk slots, onboard Ethernet)

## Why LXC first
Shares the host kernel: ~20–50 MB idle RAM vs hundreds for a VM, near-native performance, boots in seconds. Use a VM when you need a different kernel/OS, strong isolation, or Docker.
