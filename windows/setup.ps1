Write-Host "Checking if Chocolatey is installed..."
$isChocoInstalled = Get-Command -Name choco.exe -ErrorAction SilentlyContinue

if ($null -eq $isChocoInstalled) {
    Write-Host "Nope, it's not...Let's install that now!"
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

Write-Host "Yes, it is. Let's continue..."

choco install packages.config -y

Write-Host "Okay, let's setup WSL with Debian."
wsl --install -d Debian

Write-Host "Okay, let's install DotNet packages"
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://dot.net/v1/dotnet-install.ps1'))