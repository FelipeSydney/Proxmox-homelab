# Work log

Newest first. Dates are when the work was discussed/done.

## 2026-10-12
- Created this repo to track the build.
- Confirmed the Proxmox host is an HP G8 laptop running bare metal (not the Ryzen box).

## 2026-10-11
- **Claude ↔ Proxmox MCP:** picked community MCP servers (gilby125/mcp-proxmox, ProxmoxMCP-Plus, @bldg-7/proxmox-mcp). Created plan for a dedicated API user + token with `PVEAuditor` (read-only). Merged an `mcpServers` block into `claude_desktop_config.json` on `pc1`. **Not working yet:** no Proxmox tools appear in Claude after restart.
- **vmbr0 review:** found three problems — leftover install IP `192.168.2.100` (wrong subnet), a DHCP IP sitting on the physical NIC `enx98fc84e0457e`, and `ifreload` failing because of a broken Wi-Fi `wpa_supplicant` stanza. Fixed config: NIC `manual`, `vmbr0` static `192.168.86.20/24` gw `192.168.86.1`, Wi-Fi stanza commented out.
- **NIC pinning:** Proxmox VE 9 config referenced `nic0` but the interface hadn't been renamed → `bridge port does not exist`. Next step: run `ip -br link`, then either substitute the real name or reboot to apply pinning.
- Asked about changing the web UI port (iptables redirect / nginx reverse proxy options) — went with changing the host IP instead.
- Asked about LXC vs VM benefits.
- Tried listing VMs from Claude — blocked until MCP works or the UI address is given to the browser.

## 2026-10-10 / 11
- **Wi-Fi on the host:** host was offline, so tethered a phone over USB to get internet. Fixed 169.254.x.x (failed DHCP) by flushing the address and toggling tethering; fixed default route pointing at `vmbr0` by routing via the phone's gateway (from `/var/lib/dhcp/dhclient*.leases`). Installed `wpasupplicant`, `firmware-iwlwifi`, `iw`, `rfkill`.
- Configured `wpa_supplicant` for the Intel CNVi card, cleared RF-kill, planned NAT bridge `vmbr1` for VM traffic over Wi-Fi.
- **FQDN:** chose to use `home.arpa` (e.g. `pve01.home.arpa`) — avoid `.local` and made-up TLDs. Set before clustering/VMs.
- Confirmed there's no default password: `root` + the password set at install, realm *Linux PAM*.
- Compared GNS3 vs Proxmox — plan to run GNS3 VM nested inside Proxmox.

## 2026-10-07
- Picked guest distros: Debian for LXCs/most VMs, Ubuntu for tutorial/Docker work, Rocky or Alma for RHEL skills (optionally a free RHEL developer VM).

## 2026-09
- Storage: plan TrueNAS as a VM with SATA controller/HBA passthrough (8–16 GB RAM) **or** Proxmox-native ZFS + a Samba LXC. Mirror two drives; keep an off-box backup.
- Jellyfin planned as an LXC with bind-mounted storage (3600 has no iGPU → software transcoding unless a GPU is added).
- Docker: day-to-day dev in WSL2, always-on services on Proxmox.

## 2026-03-29
- First look at Proxmox installation steps (ISO → USB → installer → `https://IP:8006`).

## Earlier (hardware)
- Ryzen 5 3600 / B550 Tomahawk: fixed RAM instability (XMP applying 1.20 V instead of 1.35 V), cleared a MemTest86 failure and BSODs via minidump analysis.
