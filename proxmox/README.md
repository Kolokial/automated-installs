# Homelab IaC

Codifies a Proxmox homelab so it can be rebuilt after a catastrophic failure. OpenTofu provisions VMs/LXCs; Ansible configures the Proxmox host and guests. See `CLAUDE.md` for the project rules and order of work.

## Quick start

Needs Docker.

```
./run.sh        # Linux/macOS
.\run.ps1       # Windows PowerShell
```

This builds `control-machine/Dockerfile` and opens a shell in `/work/proxmox`. On first start, when the `homelab-repo` volume is empty, the entrypoint clones `https://github.com/Kolokial/automated-installs.git` into `/work` (override with `REPO_URL`). An existing checkout is never touched. For a private repo, authenticate first with `GH_TOKEN` or `gh auth login`. For SSH-agent setup in the VS Code dev container, see `docs/dev-container-ssh.md`.

## Environment variables

The scripts read these from your host shell and pass them into the container. They do not load `.env` (`.env.example` just lists the names).

| Variable | Required | Description |
|----------|----------|-------------|
| `PROXMOX_VE_ENDPOINT` | yes | Proxmox API URL, e.g. `https://pve.lan:8006/`. Prompted for if unset. |
| `PROXMOX_VE_API_TOKEN` | yes | API token in the form `user@realm!tokenid=secret`. Prompted for (hidden input) if unset. |
| `GH_TOKEN` | no | GitHub token for git over HTTPS. Not prompted for; after one `gh auth login` the `homelab-gh` volume keeps the credentials. |
| `AGE_KEY_FILE` | no | Host path to your age private key. Mounted read-only for SOPS. |

Prompts only appear when the script runs in an interactive terminal. Values are never written to disk; to avoid retyping the token, set it in your shell before running.

```
export PROXMOX_VE_API_TOKEN='...'     # bash
$env:PROXMOX_VE_API_TOKEN = '...'     # PowerShell
```

## Make targets

Run `make help`. All targets are read-only: there is deliberately no `apply` or `destroy`.

## Layout

- `tofu/`: OpenTofu config
- `ansible/`: roles, inventory, playbooks
- `discovery/`: raw dumps from the Proxmox host (gitignored)
- `docs/`: inventory and recovery notes

## Secrets

Credentials come from environment variables and are never written to files. State is local and gitignored; back it up manually.
