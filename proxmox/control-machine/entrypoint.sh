#!/usr/bin/env bash
set -uo pipefail

REPO_URL="${REPO_URL:-https://github.com/Kolokial/automated-installs.git}"
IAC_DIR=/work/proxmox

# Clone into the empty /work volume on first start; never touch an existing checkout
if [[ -d /work/.git ]]; then
  :
elif [[ -n "$(ls -A /work)" ]]; then
  echo "entrypoint: /work is not empty and not a git repo; skipping clone" >&2
else
  gh auth setup-git 2>/dev/null
  echo "entrypoint: cloning $REPO_URL into /work"
  if ! git clone "$REPO_URL" /work; then
    echo "entrypoint: clone failed. Run 'gh auth login' (or set GH_TOKEN), then: git clone $REPO_URL /work" >&2
  fi
fi

cd "$IAC_DIR" 2>/dev/null || cd /work
exec "$@"
