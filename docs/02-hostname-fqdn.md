# 02 — Hostname / FQDN

## Decision
Use the reserved home-network domain **`home.arpa`** (RFC 8375): e.g. `pve01.home.arpa`.

- Won't clash with real public domains.
- Avoid `.local` (conflicts with mDNS) and invented TLDs.
- If you later want valid Let's Encrypt certs, use a subdomain of a domain you own instead (e.g. `pve01.lab.example.com`).

Set this **before** creating a cluster or adding VMs — renaming a node afterwards is painful.

## Where it lives
```
/etc/hostname        pve01
/etc/hosts           192.168.86.20  pve01.home.arpa  pve01
```

Check with:
```bash
hostname --fqdn
hostname --ip-address   # must return 192.168.86.20, not 127.0.1.1
```
