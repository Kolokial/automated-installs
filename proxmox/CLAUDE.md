# Homelab IaC

Codify a Proxmox homelab so it can be rebuilt after a catastrophic failure.
OpenTofu provisions VMs/LXCs; Ansible configures the Proxmox host and guests.
The repo started empty: scaffold everything.

## Environment
- Runs in a Docker container (Dockerfile + run.sh/run.ps1 in repo root) on a Windows desktop. WSL2 is not available.
- Proxmox provider: bpg/proxmox. Credentials come from env vars `PROXMOX_VE_ENDPOINT` and `PROXMOX_VE_API_TOKEN`. Never write them to files.
- Proxmox uses a self-signed cert: `insecure = true` in the provider block for now.
- Git remote is HTTPS; auth via `GH_TOKEN` / `gh auth setup-git`.
- OpenTofu state is local and gitignored (it contains secrets). Back it up manually for now.
- SOPS + age for secrets: add after the first imports work. Never commit plaintext secrets.

## Homelab
- Proxmox host runs VMs and LXCs: pfSense, Pi-hole, Uptime Kuma, Plex, others.
- pfSense is a full VM with the WAN NIC passed through (`hostpci`). Changes here can take the network down.
- Pi-hole handles DHCP and DNS for the LAN.
- Almost all LXCs were created with Proxmox community (helper) scripts. Record which script and upstream URL per container in `docs/inventory.md`. Don't re-implement the scripts in Ansible; only codify config worth rebuilding (config files, services). App data comes from vzdump backups.

## Rules
- Read-only discovery first. Never run `tofu apply`, `tofu destroy`, or state-changing commands on Proxmox or guests. Allowed: `tofu validate`, `tofu plan`, `ansible-lint`, `ansible-playbook --check --diff`.
- Import resources one at a time, using `import` blocks. Each must reach a clean `tofu plan` before the next.
- Start with a low-risk container (e.g. Uptime Kuma) to learn the loop; pfSense last.
- Ask when something is ambiguous instead of guessing.
- Code comments: short and to the point; don't describe previous behaviour.

## Layout
- `tofu/`: OpenTofu config
- `ansible/`: roles, inventory, playbooks
- `scripts/`: gather and helper scripts
- `discovery/`: raw dumps from `pvesh`, `qm config`, `pct config`, host config files (gitignored; scrub secrets before anything is committed)
- `docs/`: inventory, RECOVERY.md (bare-metal rebuild order, and what lives outside git: vzdump backups, age key, state)

## Order of work
1. Scaffold layout, .gitignore (state, *.tfvars, discovery/, .env, age keys), Makefile, README.
2. Read-only gather script into `discovery/`.
3. Generate HCL from the dumps, import one resource at a time.
4. Ansible roles for guests, then the Proxmox host (network, storage, backup jobs, users).
5. Write RECOVERY.md.
