$ErrorActionPreference = 'Stop'

$Image = 'homelab-iac'
Set-Location $PSScriptRoot

# Load known variables from .env; anything already set in the environment wins
if (Test-Path .env) {
    $known = 'PROXMOX_VE_ENDPOINT', 'PROXMOX_VE_API_TOKEN', 'GH_TOKEN', 'REPO_URL', 'AGE_KEY_FILE'
    foreach ($line in Get-Content .env) {
        if ($line -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$' -and $known -contains $Matches[1]) {
            $name = $Matches[1]
            $value = $Matches[2].Trim().Trim('"', "'")
            if ($value -and -not [Environment]::GetEnvironmentVariable($name)) {
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            }
        }
    }
}

docker build -t $Image control-machine
if ($LASTEXITCODE -ne 0) { throw 'docker build failed' }

# Optional: $env:AGE_KEY_FILE = 'C:\path\to\key.txt'
$ageArgs = @()
if ($env:AGE_KEY_FILE) {
    $ageArgs = @('-v', "$($env:AGE_KEY_FILE):/home/dev/.age/key.txt:ro",
                 '-e', 'SOPS_AGE_KEY_FILE=/home/dev/.age/key.txt')
}

# Prompt for unset Proxmox credentials when interactive; nothing is saved
if (-not [Console]::IsInputRedirected) {
    if (-not $env:PROXMOX_VE_ENDPOINT) {
        $env:PROXMOX_VE_ENDPOINT = Read-Host 'PROXMOX_VE_ENDPOINT (e.g. https://pve.lan:8006/)'
    }
    if (-not $env:PROXMOX_VE_API_TOKEN) {
        $secure = Read-Host 'PROXMOX_VE_API_TOKEN (user@realm!tokenid=secret)' -AsSecureString
        $env:PROXMOX_VE_API_TOKEN = [System.Net.NetworkCredential]::new('', $secure).Password
    }
}

docker run -it --rm `
    -v homelab-repo:/work `
    -v homelab-gh:/home/dev/.config/gh `
    -v homelab-claude:/home/dev/.claude `
    -e PROXMOX_VE_ENDPOINT -e PROXMOX_VE_API_TOKEN -e GH_TOKEN -e REPO_URL `
    @ageArgs `
    $Image @args
