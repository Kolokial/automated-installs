import {
  to = proxmox_virtual_environment_container.uptimekuma
  id = "kipp/117"
}

# Helper script: Uptime Kuma LXC (see docs/inventory.md)
resource "proxmox_virtual_environment_container" "uptimekuma" {
  node_name     = "kipp"
  vm_id         = 117
  tags          = ["analytics", "community-script", "monitoring"]
  start_on_boot = true
  unprivileged  = true

  console {
    enabled   = true
    tty_count = 2
    type      = "tty"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  features {
    keyctl  = true
    nesting = true
  }

  initialization {
    hostname = "uptimekuma"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  memory {
    dedicated = 1024
    swap      = 512
  }

  network_interface {
    name        = "eth0"
    bridge      = "vmbr0"
    mac_address = "BC:24:11:0F:81:11"
  }

  operating_system {
    template_file_id = ""
    type             = "debian"
  }

  lifecycle {
    # description: HTML written by the helper script.
    # timeout_start, vm_id: left unset in state by import; vm_id still applies on create.
    ignore_changes = [description, timeout_start, vm_id]
  }
}
