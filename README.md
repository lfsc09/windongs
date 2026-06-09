# windongs

An Idempotent Windows installation script for Windows 11.

As `admin` open PowerShell and run the following command. *(It will auto-elevete to `admin` if you are not running as `admin`)*

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

Then run the following command to install `windongs`.

```powershell
iwr -useb https://raw.githubusercontent.com/lfsc09/windongs/main/install.ps1 | iex
```