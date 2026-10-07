# Endpoint and token come from PROXMOX_VE_ENDPOINT and PROXMOX_VE_API_TOKEN.
provider "proxmox" {
  # Self-signed cert for now.
  insecure = true
}
