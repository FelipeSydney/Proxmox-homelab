# 11 - Windows Sharedrive (D:) → Proxmox

Mount the Windows PC's `D:` drive on the Proxmox host over SMB/CIFS, so it can be used for ISOs, backups, or general file storage (and passed into LXC containers).

## Overview

| Item | Value (replace with yours) |
|---|---|
| Windows PC (`pc1`) IP | `192.168.86.50` |
| Share name | `D` |
| Windows share user | `proxmox-smb` |
| Proxmox mount point | `/mnt/windows-d` |
| Proxmox storage ID (GUI method) | `windows-d` |

Two ways to mount on Proxmox:

- **Method A – Proxmox GUI storage (SMB/CIFS):** best for ISOs, CT templates, and backups. Proxmox manages the mount.
- **Method B – Manual mount via `/etc/fstab`:** best for general file access and bind-mounting into LXC containers.

---

## Part 1 – Windows: share the D: drive

### 1.1 Give the PC a fixed IP
Set a DHCP reservation on the router (preferred) or a static IP on the Windows NIC. The mount breaks if the IP changes.

### 1.2 Create a dedicated local user for the share
Use a local account rather than your Microsoft account — it avoids username/password headaches with SMB.

Run PowerShell **as Administrator**:

```powershell
$pw = Read-Host -AsSecureString "Password for proxmox-smb"
New-LocalUser -Name "proxmox-smb" -Password $pw -PasswordNeverExpires -Description "SMB access for Proxmox"
```

### 1.3 Share the drive

**GUI:**
1. File Explorer → right-click **D:** → **Properties** → **Sharing** tab → **Advanced Sharing**.
2. Tick **Share this folder**, share name: `D`.
3. **Permissions** → remove `Everyone` → **Add** `proxmox-smb` → tick **Full Control** (or Change + Read) → OK.
4. **Security** tab → **Edit** → **Add** `proxmox-smb` → **Modify** → OK.

**PowerShell (equivalent):**
```powershell
New-SmbShare -Name "D" -Path "D:\" -FullAccess "proxmox-smb"
icacls "D:\" /grant "proxmox-smb:(OI)(CI)M"
```

> Note: Windows already has a hidden admin share `D$`. Don't use it for this — create a normal share with its own user.

### 1.4 Network profile and firewall
1. **Settings → Network & Internet → (your adapter) → Network profile type: Private.**
2. Enable File and Printer Sharing through the firewall:
   ```powershell
   Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
   ```
3. Confirm SMB2/3 is on (SMB1 is not needed):
   ```powershell
   Get-SmbServerConfiguration | Select EnableSMB2Protocol
   ```

### 1.5 Power settings
If the PC sleeps, the share disappears and Proxmox may hang on I/O. Set **Sleep: Never** (or accept that the mount will be unavailable while it sleeps).

### 1.6 Verify on Windows
```powershell
Get-SmbShare -Name D
Get-SmbShareAccess -Name D
```

---

## Part 2 – Proxmox: test connectivity

SSH into the Proxmox host (or use the node **Shell** in the web UI):

```bash
# cifs-utils is normally already installed on PVE; install if missing
apt update && apt install -y cifs-utils smbclient

# Can we reach SMB?
ping -c 3 192.168.86.50

# List shares as the share user (should show "D")
smbclient -L //192.168.86.50 -U proxmox-smb
```

If `smbclient` lists the `D` share, the Windows side is good.

---

## Part 3A – Method A: add as Proxmox storage (GUI)

1. **Datacenter → Storage → Add → SMB/CIFS**
2. Fill in:
   - **ID:** `windows-d`
   - **Server:** `192.168.86.50`
   - **Username:** `proxmox-smb`
   - **Password:** (share user password)
   - **Share:** pick `D` from the dropdown
   - **Content:** select what you want (e.g. ISO image, Container template, VZDump backup file)
   - **Nodes:** your node
3. **Add.**

CLI equivalent:
```bash
pvesm add cifs windows-d \
  --server 192.168.86.50 \
  --share D \
  --username proxmox-smb \
  --password 'YourPasswordHere' \
  --content iso,vztmpl,backup \
  --smbversion 3.0
```

Proxmox mounts it at `/mnt/pve/windows-d` and creates its own folders on D: (`template/iso`, `template/cache`, `dump`).

Verify:
```bash
pvesm status
ls /mnt/pve/windows-d
```

---

## Part 3B – Method B: manual mount with `/etc/fstab`

### 3B.1 Create the mount point
```bash
mkdir -p /mnt/windows-d
```

### 3B.2 Store credentials securely
```bash
nano /root/.smbcredentials
```
```
username=proxmox-smb
password=YourPasswordHere
```
```bash
chmod 600 /root/.smbcredentials
```

### 3B.3 Test a one-off mount
```bash
mount -t cifs //192.168.86.50/D /mnt/windows-d \
  -o credentials=/root/.smbcredentials,vers=3.0,iocharset=utf8
ls /mnt/windows-d
umount /mnt/windows-d
```

### 3B.4 Make it persistent
```bash
nano /etc/fstab
```
Add:
```
//192.168.86.50/D  /mnt/windows-d  cifs  credentials=/root/.smbcredentials,vers=3.0,iocharset=utf8,uid=0,gid=0,file_mode=0770,dir_mode=0770,_netdev,nofail,x-systemd.automount  0  0
```

| Option | Why |
|---|---|
| `_netdev` | Wait for network before mounting |
| `nofail` | Proxmox still boots if the Windows PC is off |
| `x-systemd.automount` | Mounts on first access, recovers if PC was off at boot |
| `vers=3.0` | Force SMB3 |

Apply:
```bash
systemctl daemon-reload
mount -a
df -h | grep windows-d
```

### 3B.5 (Optional) Pass into an LXC container
**Privileged container:**
```bash
pct set <CTID> -mp0 /mnt/windows-d,mp=/mnt/d
```

**Unprivileged container:** container root maps to UID/GID `100000` on the host, so mount with that owner — change the fstab options to `uid=100000,gid=100000`, then:
```bash
umount /mnt/windows-d && mount -a
pct set <CTID> -mp0 /mnt/windows-d,mp=/mnt/d
pct reboot <CTID>
```

---

## Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| `mount error(13): Permission denied` | Wrong username/password, or user missing from share/NTFS permissions. Try `username=PCNAME\proxmox-smb` in credentials. |
| `mount error(112): Host is down` | SMB version mismatch or firewall. Check `vers=3.0`, firewall rule, Private network profile. |
| `mount error(2): No such file or directory` | Wrong share name — re-check with `smbclient -L`. |
| `ls` hangs / Proxmox GUI shows storage `?` | Windows PC asleep, off, or IP changed. |
| Can read but not write | NTFS (Security tab) permission missing, or `file_mode`/`uid` wrong for an LXC. |

Logs:
```bash
dmesg | grep -i cifs
journalctl -u mnt-windows\\x2dd.mount
```

---

## Remove / rollback

**Method A:** Datacenter → Storage → select `windows-d` → **Remove** (or `pvesm remove windows-d`). Files on D: are not deleted.

**Method B:**
```bash
umount /mnt/windows-d
# delete the line from /etc/fstab
systemctl daemon-reload
rm /root/.smbcredentials
```

**Windows:**
```powershell
Remove-SmbShare -Name D -Force
Remove-LocalUser -Name proxmox-smb
```
