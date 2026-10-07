# SSH agent setup for the dev container

The dev container uses SSH keys from the host's ssh-agent via VS Code's agent forwarding. The key never enters the container. Do this on the host before opening the container.

## Windows

1. Open PowerShell **as administrator** and enable the agent (one-off):
```powershell
   Set-Service ssh-agent -StartupType Automatic
   Start-Service ssh-agent
```
2. In a normal PowerShell, add your key (use your key's filename):
```powershell
   ssh-add $env:USERPROFILE\.ssh\id_ed25519
```
3. Auto-load keys in future by adding this to `%USERPROFILE%\.ssh\config`:
```
   Host *
       AddKeysToAgent yes
```
4. Check the key is loaded:
```powershell
   ssh-add -l
```

## Linux

1. Check an agent is running:
```bash
   echo $SSH_AUTH_SOCK
```
   If it's empty, start one for the session:
```bash
   eval "$(ssh-agent -s)"
```
   Most desktop environments (GNOME, KDE) start one at login, so this is rarely needed.
2. Add your key:
```bash
   ssh-add ~/.ssh/id_ed25519
```
3. Auto-load keys in future by adding this to `~/.ssh/config`:
```
   Host *
       AddKeysToAgent yes
```
4. Check the key is loaded:
```bash
   ssh-add -l
```

## Both: verify and open the container

1. Open VS Code only after the key is loaded. Restart VS Code if it was already open.
2. Open the repo in the dev container.
3. Inside the container, run:
```bash
   ssh-add -l
   ssh -T git@github.com
```
   Both should succeed. If `ssh-add -l` says it can't connect to the agent, the host agent isn't running. Fix it on the host, then reopen the container.

## Alternative: HTTPS remote

Avoids the agent entirely and uses Git Credential Manager forwarding instead:
```bash
git remote set-url origin https://github.com/<user>/<repo>.git
```
Sign in once when prompted.