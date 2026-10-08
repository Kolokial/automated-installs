#!/usr/bin/env bash
set -euo pipefail

IMAGE=homelab-iac
cd "$(dirname "$0")"

# Load known variables from .env; anything already set in the shell wins
if [[ -f .env ]]; then
  while IFS='=' read -r key value || [[ -n $key ]]; do
    case $key in
      PROXMOX_VE_ENDPOINT|PROXMOX_VE_API_TOKEN|GH_TOKEN|REPO_URL|AGE_KEY_FILE) ;;
      *) continue ;;
    esac
    value="${value%$'\r'}"
    value="${value#[\"\']}"
    value="${value%[\"\']}"
    if [[ -n $value && -z "${!key:-}" ]]; then
      export "$key=$value"
    fi
  done < .env
fi

docker build -t "$IMAGE" control-machine

# Optional: AGE_KEY_FILE=/path/to/key.txt ./run.sh
age_args=()
if [[ -n "${AGE_KEY_FILE:-}" ]]; then
  age_args=(-v "$AGE_KEY_FILE:/home/dev/.age/key.txt:ro" -e SOPS_AGE_KEY_FILE=/home/dev/.age/key.txt)
fi

# Prompt for unset Proxmox credentials when interactive; nothing is saved
if [[ -t 0 ]]; then
  if [[ -z "${PROXMOX_VE_ENDPOINT:-}" ]]; then
    read -r -p "PROXMOX_VE_ENDPOINT (e.g. https://pve.lan:8006/): " PROXMOX_VE_ENDPOINT
  fi
  if [[ -z "${PROXMOX_VE_API_TOKEN:-}" ]]; then
    read -r -s -p "PROXMOX_VE_API_TOKEN (user@realm!tokenid=secret): " PROXMOX_VE_API_TOKEN
    echo
  fi
fi
export PROXMOX_VE_ENDPOINT PROXMOX_VE_API_TOKEN

docker run -it --rm \
  -v homelab-repo:/work \
  -v homelab-gh:/home/dev/.config/gh \
  -v homelab-claude:/home/dev/.claude \
  -e PROXMOX_VE_ENDPOINT -e PROXMOX_VE_API_TOKEN -e GH_TOKEN -e REPO_URL \
  "${age_args[@]}" \
  "$IMAGE" "$@"
