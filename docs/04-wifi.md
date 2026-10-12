# 04 — Wi-Fi on the Proxmox host

Proxmox has no Wi-Fi management and officially recommends wired. Use Wi-Fi only as a fallback for the **host**.

## Why VMs can't simply bridge to Wi-Fi
In client (station) mode an access point only accepts frames from the MAC that authenticated. Bridged VMs have their own MACs, so their traffic is dropped. Workaround: a **NAT/routed bridge** (`vmbr1`) — VMs get a private subnet and the host masquerades out of the Wi-Fi interface.

## Hardware
Intel CNVi card, driver `iwlwifi`. Interface has appeared as `wlp0s20f3` (also seen `wlp0s2` / `wlp2s0` in other sessions — confirm with `ip -br link`).

## Getting packages onto an offline host
A `.tar.gz` of wpa_supplicant is **source** and needs a compiler — not useful. Instead, USB-tether a phone:

1. Plug in phone, enable USB tethering → new `usb0`/`enx…` interface.
2. If it gets `169.254.x.x`: `ip addr flush dev <if>`, toggle tethering off/on, `dhclient <if>`.
3. If traffic still goes nowhere, the default route is via `vmbr0`. Find the phone gateway in `/var/lib/dhcp/dhclient*.leases`, then:
   ```bash
   ip route del default
   ip route add default via <phone-gw> dev <if>
   ```
4. Install:
   ```bash
   apt update
   apt install firmware-iwlwifi wpasupplicant iw rfkill
   ```
5. Restore the normal default route afterwards.

## Connect
```bash
rfkill list ; rfkill unblock wifi
modprobe -r iwlwifi && modprobe iwlwifi    # after firmware install
wpa_passphrase "SSID" "PASSPHRASE" > /etc/wpa_supplicant/wpa_supplicant.conf
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
```
Interface stanza: [`configs/network/interfaces.wifi-nat.example`](../configs/network/interfaces.wifi-nat.example).

## No `iw`?
`ip link` or `ls /sys/class/net` shows interface names. If there's no `wl…` interface at all, it's a driver/firmware issue: check `lspci -k`, `lsusb`, `dmesg | grep -i iwl`.

## Current state
Wi-Fi stanza is **commented out** in `/etc/network/interfaces` because it broke `ifreload`; wired `vmbr0` is the primary path.
