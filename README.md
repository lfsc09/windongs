# windongs

An Idempotent Windows installation script for Windows 11.

As `admin` open PowerShell and run the following command.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

Setup Terminal.

- Windows Terminal w/ settings.
- Powershell v7 w/ profile.
- Git.
- GitHub CLI.
- Starship w/ config file.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Setup-Terminal.ps1 | iex
```

Install Apps.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Install-Apps-Tools.ps1 | iex
```

Setup Git.

- Create `Github` folder in user's home.
- Ask for `Name` and `Email` to config git.
- Ask to create SSH ed25519 key.
- Ask to create GPG key *(for signed commits)*
  - Install GnuPG from Gpg4win.
  - Use created key as signKey for git.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Setup-Git.ps1 | iex
```

Check generated SSH and GPG:

```powershell
Get-Content "$HOME\.ssh\github_$((git config --global user.email).Replace('@','_').Replace('.','_'))_ed25519.pub"
```

```powershell
gpg --armor --export $((gpg --list-secret-keys --keyid-format LONG "$(git config --global user.email)" 2>$null) -match 'sec\s+\w+\/([A-F0-9]+)\s' ? $Matches[1] : "")
```

