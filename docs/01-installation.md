# 01 — Installation

1. Download the Proxmox VE ISO from proxmox.com/downloads (current stable).
2. Write it to USB (Rufus on Windows, Etcher, or `dd`).
3. Enable **Intel VT-x and VT-d** in the HP BIOS (F10), disable Secure Boot if the installer won't boot; boot from USB.
4. Installer → *Install Proxmox VE (Graphical)* → pick target disk (it gets wiped).
5. Country / timezone (`Australia/Sydney`) / keyboard.
6. Set the `root` password and notification email.
7. Network: FQDN (see [02](02-hostname-fqdn.md)), **static** IP, gateway, DNS.
8. Install, remove USB, reboot.
9. Browse to `https://<ip>:8006`, accept the self-signed cert, log in as `root` with realm **Linux PAM standard authentication**.

There is no default password — it's whatever was set in step 6.

## Gotcha hit on this build
The installer IP (`192.168.2.100`) didn't match the real LAN (`192.168.86.0/24`). Fix is in [03-networking.md](03-networking.md).

## Post-install checklist
- [ ] Switch to the no-subscription repo and `apt update && apt full-upgrade`
- [ ] Confirm IP/hostname in `/etc/network/interfaces` and `/etc/hosts`
- [ ] DHCP reservation on the router for the host IP
- [ ] Create a non-root admin user and enable 2FA
