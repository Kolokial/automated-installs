#!/usr/bin/env bash
# Read-only dump of Proxmox state via the API into discovery/. GET requests only.
set -euo pipefail

: "${PROXMOX_VE_ENDPOINT:?set PROXMOX_VE_ENDPOINT}"
: "${PROXMOX_VE_API_TOKEN:?set PROXMOX_VE_API_TOKEN}"

endpoint="${PROXMOX_VE_ENDPOINT%/}"
BASE="${endpoint%/api2/json}/api2/json"
OUT="$(cd "$(dirname "$0")/.." && pwd)/discovery"
API="$OUT/api"
ERRORS="$API/_errors.log"
SAFE_NAME='^[A-Za-z0-9._-]+$'

mkdir -p "$API"
: > "$ERRORS"

# api_get PATH OUTFILE: save .data from a GET to $API/OUTFILE; log and return 1 on failure
api_get() {
  local path=$1 out=$2 tmp code
  tmp=$(mktemp)
  code=$(printf 'Authorization: PVEAPIToken=%s\n' "$PROXMOX_VE_API_TOKEN" |
    curl -ksS -X GET -H @- -o "$tmp" -w '%{http_code}' "$BASE$path") || code=000
  mkdir -p "$(dirname "$API/$out")"
  if [[ $code == 200 ]] && jq '.data' "$tmp" > "$API/$out" 2>/dev/null; then
    rm -f "$tmp"
    return 0
  fi
  rm -f "$tmp" "$API/$out"
  echo "$code GET $path" >> "$ERRORS"
  return 1
}

if ! api_get /version version.json; then
  echo "Cannot reach $BASE/version (HTTP $(cut -d' ' -f1 "$ERRORS" | head -1)). Check PROXMOX_VE_ENDPOINT and PROXMOX_VE_API_TOKEN." >&2
  exit 1
fi

api_get /nodes nodes.json || true
api_get /cluster/resources resources.json || true
api_get /storage storage.json || true
api_get /cluster/backup backup-jobs.json || true
api_get /cluster/backup-info/not-backed-up not-backed-up.json || true
api_get /pools pools.json || true
api_get /access/roles roles.json || true
api_get /access/users users.json || true
api_get /access/acl acl.json || true

if [[ -s "$API/nodes.json" ]]; then
  while read -r node; do
    [[ $node =~ $SAFE_NAME ]] || { echo "skipping odd node name: $node" >&2; continue; }
    api_get "/nodes/$node/network" "nodes/$node/network.json" || true
    api_get "/nodes/$node/storage" "nodes/$node/storage.json" || true
  done < <(jq -r '.[].node' "$API/nodes.json")
fi

: > "$OUT/guests.tsv"
if [[ -s "$API/resources.json" ]]; then
  printf 'type\tvmid\tname\tnode\tstatus\ttemplate\ttags\n' > "$OUT/guests.tsv"
  jq -r '.[] | select(.type == "qemu" or .type == "lxc")
         | [.type, .vmid, (.name // ""), .node, (.status // ""), (.template // 0), (.tags // "")] | @tsv' \
    "$API/resources.json" | sort -k2,2n >> "$OUT/guests.tsv"

  while IFS=$'\t' read -r type vmid _ node _; do
    [[ $vmid =~ ^[0-9]+$ && $node =~ $SAFE_NAME ]] || { echo "skipping odd guest: $type $vmid $node" >&2; continue; }
    api_get "/nodes/$node/$type/$vmid/config" "guests/$node/$type-$vmid.json" || true
  done < <(tail -n +2 "$OUT/guests.tsv")
fi

guests=$(( $(wc -l < "$OUT/guests.tsv") > 0 ? $(wc -l < "$OUT/guests.tsv") - 1 : 0 ))
errors=$(wc -l < "$ERRORS")
echo "Wrote $OUT: $guests guest(s), $errors failed request(s)."
if (( errors > 0 )); then
  echo "Failed requests (usually missing token permissions) are in $ERRORS:" >&2
  cat "$ERRORS" >&2
fi
echo "discovery/ is gitignored. Scrub secrets before committing anything from it."
