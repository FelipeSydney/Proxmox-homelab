
# 08-Setting up Pi-Hole

## Documentation
Setting up Pi-Hole in Proxmox as a VM or CT.

## Pi-Hole - Debian CT

### Prerequisites
- Proxmox host running
- Debian CT or VM created in Proxmox
- Root access or sudo privileges
- Network access to install packages

### Install required packages
The official Pi-hole installer expects `curl` and `bash` to be available. On a minimal Debian installation, these may not be installed.

```bash
apt-get update
apt-get install -y curl bash ca-certificates
```

If needed, install `curl` alone:

```bash
apt-get install -y curl
```

### Install Pi-Hole
Once the required packages are installed, run the installer:

```bash
curl -sSL https://install.pi-hole.net | bash
```

Follow the prompts in the installer to complete the setup.

### Configure networking
Set static IPv4 and IPv6 addresses for the Pi-Hole CT/VM.

Recommended settings:
- Use a static IP address outside the DHCP range
- Set the correct gateway
- Set the correct DNS servers
- Ensure IPv6 is configured if your network uses it

### Configure router DNS
Configure your router to use Pi-hole as the DNS server for devices on your network.

Typical setup:
- Set Pi-hole's IP address as the primary DNS server in the router or DHCP configuration
- Ensure devices receive this DNS server via DHCP
- Test connectivity after changing settings

### Verify installation
After installation, verify that Pi-hole is responding:

```bash
nslookup google.com <PI_HOLE_IP>
```

Open the Pi-hole admin dashboard:

```text
http://<PI_HOLE_IP>/admin
```

### Troubleshooting
If the installer fails because `bash` or `curl` is missing:

```bash
apt-get update
apt-get install -y curl bash
```

Then rerun:

```bash
curl -sSL https://install.pi-hole.net | bash
```

If clients are not using Pi-hole:
- Check DHCP settings on the router
- Confirm the firewall allows DNS traffic
- Ensure the Pi-hole IP is set as the DNS server
- Restart devices if needed

## Notes
This setup is ideal for network-wide ad blocking and DNS filtering. Pi-hole works best when it is the default DNS server for your home network.
