# Inventory

One row per VM/LXC on node `kipp`. For helper-script guests, record the script and its upstream URL; app data comes from vzdump backups.

Helper scripts come from https://github.com/community-scripts/ProxmoxVE (site: community-scripts.org). The "Helper script" column is the title Proxmox stored in the guest description. A script page URL is listed only where the description contains one; `-` means it isn't recorded.

| Name | Type | VMID | Helper script | Script page | Notes |
|------|------|------|---------------|-------------|-------|
| plex | lxc | 100 | Plex LXC | - | |
| sonarr | lxc | 101 | Sonarr LXC | - | |
| sabnzbd | lxc | 102 | SABnzbd LXC | - | |
| radarr | lxc | 103 | Radarr LXC | - | |
| pihole | lxc | 104 | unverified | - | Tagged community-script but no description. DHCP and DNS for the LAN. |
| grafana | lxc | 105 | Grafana LXC | - | |
| influxdb | lxc | 106 | InfluxDB LXC | - | |
| pfsense | qemu | 107 | none | - | Manual VM. WAN NIC passed through (`hostpci`). Import last. |
| node-red | lxc | 108 | Node-Red LXC | - | |
| airprint | lxc | 109 | Debian LXC | - | Generic Debian script plus manual AirPrint setup. |
| metube | lxc | 110 | MeTube LXC | - | |
| GameDockerHost | qemu | 111 | none | - | Manual VM. Stopped. |
| nginxproxymanager | lxc | 112 | Nginx Proxy Manager LXC | - | |
| bazarr | lxc | 113 | Bazarr LXC | - | |
| haos-17.2 | qemu | 114 | Homeassistant OS VM | - | |
| pelican-panel | lxc | 115 | Pelican-Panel LXC | - | Stopped. |
| pelican-wings | lxc | 116 | Pelican-Wings LXC | - | Stopped. |
| uptimekuma | lxc | 117 | Uptime Kuma LXC | https://community-scripts.org/scripts/uptime-kuma | First import. |
| staging-yait | qemu | 118 | Ubuntu 24.04 VM | https://community-scripts.org/scripts/ubuntu-vm | Generic Ubuntu VM script plus manual setup. |
| github-runner | lxc | 119 | GitHub-Runner LXC | https://community-scripts.org/scripts/github-runner | |
