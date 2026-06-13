# windongs

An Idempotent Windows installation script for Windows 11.

As `admin` open PowerShell and run the following command.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

Install Apps.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Install-Apps-Tools.ps1 | iex
```

Setup Terminal.

- Windows Terminal w/ settings
- Powershell v7 w/ profile
- Git
- GitHub CLI
- Starship w/ config file

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Setup-Terminal.ps1 | iex
```

Setup Git.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/scripts/Setup-Git.ps1 | iex
```
