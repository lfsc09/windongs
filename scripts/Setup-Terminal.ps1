# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Restarting in an elevated session..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

. "$PSScriptRoot\Install-Lib.ps1"

$confirm = $Host.UI.PromptForChoice(
    "Terminal Setup",
    "This will set up your terminal environment. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Terminal setup cancelled." -ForegroundColor Red
    Exit
}

# Set progress bar preference to silent for cleaner output
$ProgressPreference = 'SilentlyContinue'

Write-Host "=== Starting Terminal Setup ===" -ForegroundColor Magenta


# ==========================================
# TERMINAL SETUP & FIX
# ==========================================

# Download Windows Terminal
Install-WingetApp "Windows Terminal" "Microsoft.WindowsTerminal"

# Git Engine
Install-WingetApp "Git" "Git.Git"

# GitHub CLI
Install-WingetApp "GitHub CLI" "GitHub.cli"

# Oh My Posh
Install-WingetApp "Oh My Posh" "JanDeDobbeleer.OhMyPosh"


# ==========================================
# FONTS
# ==========================================

# TODO: CHECK IF CORRECT
# JetBrains Mono Fonts (Uses Winget font package, which handles Windows font registration)
Install-WingetApp "JetBrains Mono Font" "JetBrains.JetBrainsMono"

# TODO: CHECK IF CORRECT
# FiraCode Nerd Font
oh-my-posh font install FiraCode


# ==========================================
# DOWNLOAD CONFIGS
# ==========================================

# Download the configs from the repository and place them in the appropriate locations
$rawBase = "https://raw.githubusercontent.com/lfsc09/windongs/main/configs"

$ompDest     = Join-Path (Split-Path $PROFILE) "windongs.omp.json"
$profileDest = $PROFILE
$termDest    = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Ensure directories exist
New-Item -ItemType Directory -Force -Path (Split-Path $profileDest) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $termDest)    | Out-Null

Write-Host "-> Downloading windongs.omp.json..." -ForegroundColor Yellow
Invoke-WebRequest "$rawBase/windongs.omp.json" -OutFile $ompDest

Write-Host "-> Downloading Microsoft.PowerShell_profile.ps1..." -ForegroundColor Yellow
Invoke-WebRequest "$rawBase/Microsoft.PowerShell_profile.ps1" -OutFile $profileDest

# Replace the placeholder path in the profile with the actual omp file location
$content = Get-Content $profileDest -Raw
$content = $content.Replace('<YourDrive>:\Users\<YourUsername>\Documents\PowerShell\posh-theme.json', $ompDest)
Set-Content $profileDest $content

Write-Host "-> Downloading settings.json (Windows Terminal)..." -ForegroundColor Yellow
Invoke-WebRequest "$rawBase/settings.json" -OutFile $termDest

Write-Host "=== Terminal Setup Complete! ===" -ForegroundColor Magenta
Write-Host "Note: You may need to restart your terminal for Oh My Posh and Git environment variables to take effect." -ForegroundColor Yellow
