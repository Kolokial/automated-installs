# Proxmox API token for OpenTofu

Run everything below on the Proxmox host shell as root. Replace `iac@pve` and
`tofu` with your own user and token name.

## 1. Create a dedicated user and token

```bash
pveum user add iac@pve
pveum user token add iac@pve tofu --privsep 1
```

The command prints the token secret **once**. Store it now; it cannot be
retrieved later.

Don't use `root@pam`. A dedicated user lets you scope permissions and revoke
the token without touching anything else.

## 2. Grant permissions

With privilege separation on (`--privsep 1`), the token's effective
permissions are the **intersection** of the user's and the token's ACLs.
Granting a role to only one of them leaves the token with nothing, which shows
up as 403 responses or empty guest lists.

Read-only is enough for discovery, `tofu plan`, and `import` blocks:

```bash
pveum acl modify / --users iac@pve --roles PVEAuditor
pveum acl modify / --tokens 'iac@pve!tofu' --roles PVEAuditor
```

`/` with the default propagation covers all nodes, guests and storage.

## 3. Verify

```bash
pveum user permissions 'iac@pve!tofu'
```

Empty output means step 2 didn't apply. Both ACL lines are required.

## 4. Use it

Set these on the host before launching the container (`run.sh` / `run.ps1`
passes them through):

```
PROXMOX_VE_ENDPOINT=https://<proxmox-host>:8006/
PROXMOX_VE_API_TOKEN=iac@pve!tofu=<secret>
```

Keep the secret out of the repo. It belongs in environment variables, or in
SOPS once that's set up.

## Troubleshooting 403

The response body names the missing privilege, e.g.
`Permission check failed (/cluster/backup, Sys.Audit)`. Add just that
privilege with a custom role rather than widening to `Administrator`:

```bash
pveum role add IaCRead --privs "VM.Audit Sys.Audit Datastore.Audit Pool.Audit SDN.Audit Mapping.Audit"
pveum acl modify / --users iac@pve --roles IaCRead
pveum acl modify / --tokens 'iac@pve!tofu' --roles IaCRead
```

Privilege names vary by Proxmox version; check them against `pveum role list`.

## Later: write access for `tofu apply`

`PVEAuditor` is read-only by design. When you're ready to apply, create a
separate role with only the privileges the provider needs (`VM.Allocate`,
`VM.Config.*`, `VM.PowerMgmt`, `Datastore.AllocateSpace`, `Sys.Modify`, and
others depending on the resources used), and attach it to both the user and
the token. Avoid `Administrator`.

Some `bpg/proxmox` operations (file uploads, certain disk and passthrough
changes) go over SSH rather than the API, so they need an SSH key on the
Proxmox host as well as these permissions.
