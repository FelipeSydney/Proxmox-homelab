# 03 — Networking (vmbr0)

## Model
`vmbr0` is a Linux bridge. The **host's IP lives on the bridge**; the physical NIC is just a bridge port with **no IP** (`manual`). VMs plug into `vmbr0` and appear directly on the LAN.

## Working config
See [`configs/network/interfaces.example`](../configs/network/interfaces.example).

```
auto lo
iface lo inet loopback

iface enx98fc84e0457e inet manual

auto vmbr0
iface vmbr0 inet static
    address 192.168.86.20/24
    gateway 192.168.86.1
    bridge-ports enx98fc84e0457e
    bridge-stp off
    bridge-fd 0
```

Apply with `ifreload -a`. Then update `/etc/hosts` to `192.168.86.20`.

## Problems found and fixed (2026-10-11)
1. Leftover installer IP `192.168.2.100` → wrong subnet. Replaced with `192.168.86.20/24`.
2. A DHCP address was sitting directly on `enx98fc84e0457e` → removed; the NIC is `manual`.
3. `ifreload` failed because of a broken Wi-Fi `wpa_supplicant` stanza → commented out (Wi-Fi can't be a bridge port anyway, see [04](04-wifi.md)).

Verify:
```bash
ip -br addr
ip route            # default via 192.168.86.1 dev vmbr0
ping -c3 1.1.1.1
```

## Open: Proxmox VE 9 NIC pinning (`nic0`)
PVE 9 can pin interface names to `nic0`, `nic1`… If the config says `bridge-ports nic0` but the rename hasn't happened, `ifreload` errors with **"bridge port does not exist"**.

Diagnose:
```bash
ip -br link
ls /etc/systemd/network/
cat /etc/network/interfaces
```
Fix either by putting the real name (e.g. `enx98fc84e0457e`) in `bridge-ports`, **or** reboot so pinning takes effect and keep `nic0`. Pick one and make the config consistent.

> USB Ethernet adapters can change names/MACs between ports — another reason pinning (or a fixed port) matters here.

## DHCP from the CLI
Target the bridge, not the NIC: `dhclient vmbr0` / `dhclient -r vmbr0`. Leases don't persist unless the stanza is `inet dhcp`.

## Remaining
- [ ] DHCP reservation for `.20` on the router
- [ ] Decide on VLAN-aware bridge if labbing VLANs later
