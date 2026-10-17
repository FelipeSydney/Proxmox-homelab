
# 10-Installing Wazuh

## Documentation
Setting up Wazuh (SIEM/XDR) in Proxmox using the official OVA, then deploying agents to endpoints from the web dashboard.

Official docs: https://documentation.wazuh.com/current/deployment-options/virtual-machine/virtual-machine.html

## Wazuh - OVA (all-in-one VM)

The Wazuh OVA is a pre-built virtual machine with all the central components already installed and configured, so there is no manual install of each module:

| Component | Role |
|-----------|------|
| Wazuh manager (server) | Receives and analyses data from agents, runs rules/decoders |
| Filebeat-OSS | Ships alerts from the manager to the indexer |
| Wazuh indexer | Stores and indexes alerts (OpenSearch-based) |
| Wazuh dashboard | Web UI for alerts, agents and configuration |

### Prerequisites
- Proxmox host running
- Default VM sizing: **4 vCPU, 8 GB RAM, 50 GB disk** (adjust for number of endpoints)
- x86_64/AMD64 only
- OVA downloaded from `https://packages.wazuh.com/4.x/vm/wazuh-<version>.ova` (check the docs page for the current version)

### Import the OVA into Proxmox
Proxmox can't use the `.ova` file directly. Copy it to the host, extract it and import the OVF.

```bash
mkdir -p /root/wazuh && cd /root/wazuh
tar -xvf wazuh-<version>.ova
qm importovf <VMID> wazuh-<version>.ovf local-lvm
```

Alternatively, on Proxmox VE 8.2+ upload the OVA to a storage with the **Import** content type and use **Import** from the GUI.

After import, check the VM in the Proxmox GUI:
- Network: add a network device on `vmbr0` if none was created
- Set the CPU/RAM to match the sizing above
- Start the VM

### First login (console)
Default VM credentials:
- User: `wazuh-user`
- Password: `wazuh`

SSH root login is disabled — use `sudo -i` to become root.

Get the VM's IP address:

```bash
ip a
```

Set a static IP (or DHCP reservation) so agents always reach the same manager address.

### Log in to the web dashboard
Browse to:

```
https://<WAZUH_SERVER_IP>
```

Default dashboard credentials:
- User: `admin`
- Password: `admin`

The dashboard can take a few minutes to finish initialising after first boot.

### Change default passwords
Every copy of the OVA ships with the same defaults, so change them straight away:
- System password: run `passwd` as `wazuh-user`
- Wazuh/dashboard passwords: follow the Wazuh *Password management* guide

## Deploy agents (via GUI)
Once logged in to the dashboard, agents are deployed from the web UI — it builds the install command for you.

1. Dashboard → **Agents management → Summary** → **Deploy new agent**
2. Select the endpoint OS and package (Windows MSI, Linux DEB/RPM, macOS PKG)
3. Enter the **server address** (the Wazuh VM IP / FQDN)
4. Optional: set an agent name and assign a group
5. Copy the generated command and run it on the endpoint (PowerShell as Administrator on Windows, `sudo` on Linux/macOS)
6. Start the agent service using the command shown in the wizard

### Verify agents
- The agent should appear in the dashboard with status **Active** within a minute or two
- If it stays **Never connected** / **Disconnected**, check that the endpoint can reach the manager on ports **1514/TCP** (agent comms) and **1515/TCP** (enrollment)

## Config file locations
| Component | File |
|-----------|------|
| Manager | `/var/ossec/etc/ossec.conf` |
| Indexer | `/etc/wazuh-indexer/opensearch.yml` |
| Filebeat | `/etc/filebeat/filebeat.yml` |
| Dashboard | `/etc/wazuh-dashboard/opensearch_dashboards.yml` |

## Troubleshooting

### Agent on the Proxmox host not connecting — set the server IP manually
When deploying the agent on the Proxmox machine, the manager address wasn't set correctly, so the agent couldn't reach the Wazuh server. Fixed by editing the agent config by hand.

Open the agent config on the Proxmox host:

```bash
nano /var/ossec/etc/ossec.conf
```

Find the `<client>` → `<server>` block and set `<address>` to the Wazuh server IP:

```xml
<client>
  <server>
    <address><WAZUH_SERVER_IP></address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
</client>
```

Save, then restart the agent:

```bash
systemctl restart wazuh-agent
systemctl status wazuh-agent
```

Check the agent log if it still won't connect:

```bash
tail -f /var/ossec/logs/ossec.log
```

The agent should then show as **Active** in the dashboard.

## Notes
- The OVA is a single-node deployment — no high availability or scaling out of the box.
