# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator."
    Start-Sleep -Seconds 3
    Exit
}

$confirm = $Host.UI.PromptForChoice(
    "Terminal Setup",
    "This will set up your terminal environment. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Terminal setup cancelled." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

function Install-WingetApp {
    param ([string]$PackageId)
    winget install --id $PackageId
}

# ==========================================
# TERMINAL SETUP & FIX
# ==========================================

# Windows Terminal
Install-WingetApp "Microsoft.WindowsTerminal"

# Powershell 7
Install-WingetApp "Microsoft.PowerShell"

# Git Engine
Install-WingetApp "Git.Git"

# GitHub CLI
Install-WingetApp "GitHub.cli"

# Starship
Install-WingetApp "Starship.Starship"

# ==========================================
# FONTS
# ==========================================

$fontsFolder = "C:\Windows\Fonts"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

function Register-FontFile {
    param ([System.IO.FileInfo]$File)
    $targetPath = Join-Path $fontsFolder $File.Name
    
    # Copy file to Windows Fonts directory if it doesn't exist
    if (-not (Test-Path $targetPath)) {
        Copy-Item -Path $File.FullName -Destination $targetPath -Force
    }

    # Add to Windows Registry so the OS recognizes it
    $fontRegistryName = if ($File.Extension -eq ".ttf") { "$($File.BaseName) (TrueType)" } else { "$($File.BaseName) (OpenType)" }
    if (-not (Get-ItemProperty -Path $registryPath -Name $fontRegistryName -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $registryPath -Name $fontRegistryName -Value $File.Name -PropertyType String -Force | Out-Null
    }
}

# ==========================================
# FIRA CODE NERD FONT (Latest Release)
# ==========================================
if (-not (Get-ItemProperty -Path $registryPath -Name "*FiraCode*" -ErrorAction SilentlyContinue)) {
    Write-Host "Downloading and installing FiraCode Nerd Font..." -ForegroundColor Yellow
    
    $firaZip = "$env:TEMP\FiraCode.zip"
    $firaExtract = "$env:TEMP\FiraCodeFont"

    # Download latest release directly from Nerd Fonts repo
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" -OutFile $firaZip
    Expand-Archive -Path $firaZip -DestinationPath $firaExtract -Force

    # Find and copy all .ttf files (Equivalent to find -name "*.ttf" -exec cp)
    Get-ChildItem -Path $firaExtract -Recurse -Filter "*.ttf" | ForEach-Object {
        Register-FontFile -File $_
    }

    # Clean up (Equivalent to rm -rf)
    Remove-Item $firaZip -ErrorAction SilentlyContinue
    Remove-Item $firaExtract -Recurse -ErrorAction SilentlyContinue
} else {
    Write-Host "FiraCode Nerd Font is already installed. Skipping." -ForegroundColor Green
}

# ==========================================
# JETBRAINS MONO (Latest from GitHub API)
# ==========================================
if (-not (Get-ItemProperty -Path $registryPath -Name "*JetBrainsMono*" -ErrorAction SilentlyContinue)) {
    Write-Host "Fetching latest JetBrains Mono version from GitHub API..." -ForegroundColor Yellow

    # Query GitHub API and parse out the clean version number (Equivalent to your curl + grep logic)
    $apiResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest"
    $jetbrains_version = $apiResponse.tag_name.TrimStart('v') # Removes the 'v' prefix

    Write-Host "Latest JetBrains Mono version found: v$jetbrains_version" -ForegroundColor Cyan

    $jbZip = "$env:TEMP\JetBrainsMono-$jetbrains_version.zip"
    $jbExtract = "$env:TEMP\JetBrainsMonoFont"

    # Download using the dynamic version string
    $jbUrl = "https://github.com/JetBrains/JetBrainsMono/releases/download/v${jetbrains_version}/JetBrainsMono-${jetbrains_version}.zip"
    Invoke-WebRequest -Uri $jbUrl -OutFile $jbZip
    Expand-Archive -Path $jbZip -DestinationPath $jbExtract -Force

    # Find and copy all .ttf files
    Get-ChildItem -Path $jbExtract -Recurse -Filter "*.ttf" | ForEach-Object {
        Register-FontFile -File $_
    }

    # Clean up
    Remove-Item $jbZip -ErrorAction SilentlyContinue
    Remove-Item $jbExtract -Recurse -ErrorAction SilentlyContinue
} else {
    Write-Host "JetBrains Mono is already installed. Skipping." -ForegroundColor Green
}

# Base config files url
$rawBase = "https://raw.githubusercontent.com/lfsc09/windongs/main/configs"

# ==========================================
# STARSHIP CONFIG
# ==========================================

$baseUrl = "https://raw.githubusercontent.com/lfsc09/windongs/main/configs"

# --------------------------------------------------
# Starship Config
# --------------------------------------------------
$starshipDir  = Join-Path $HOME ".config"
$starshipPath = Join-Path $starshipDir "starship.toml"

if (-not (Test-Path $starshipPath)) {
    Write-Host "Downloading starship.toml..." -ForegroundColor Yellow
    if (-not (Test-Path $starshipDir)) { New-Item -ItemType Directory -Path $starshipDir -Force | Out-Null }
    Invoke-WebRequest -Uri "$baseUrl/starship.toml" -OutFile $starshipPath
} else {
    Write-Host "starship.toml already exists." -ForegroundColor Green
}

# --------------------------------------------------
# PowerShell 7 Profile
# --------------------------------------------------
# $PROFILE.CurrentUserAllHosts typically points to Documents\PowerShell\Microsoft.PowerShell_profile.ps1 in PWSH 7
$pwshProfileDir  = Join-Path $HOME "Documents\PowerShell"
$pwshProfilePath = Join-Path $pwshProfileDir "Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $pwshProfilePath)) {
    Write-Host "Downloading PowerShell 7 profile..." -ForegroundColor Yellow
    if (-not (Test-Path $pwshProfileDir)) { New-Item -ItemType Directory -Path $pwshProfileDir -Force | Out-Null }
    Invoke-WebRequest -Uri "$baseUrl/Microsoft.PowerShell_profile.ps1" -OutFile $pwshProfilePath
} else {
    Write-Host "PowerShell 7 profile already exists." -ForegroundColor Green
}

# --------------------------------------------------
# Windows Terminal Settings
# --------------------------------------------------
$wtDir  = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$wtPath = Join-Path $wtDir "settings.json"

Write-Host "Downloading Windows Terminal settings.json..." -ForegroundColor Yellow
if (-not (Test-Path $wtDir)) { New-Item -ItemType Directory -Path $wtDir -Force | Out-Null }
Invoke-WebRequest -Uri "$baseUrl/windows-terminal-settings.json" -OutFile $wtPath
