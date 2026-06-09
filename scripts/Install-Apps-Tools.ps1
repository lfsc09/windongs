# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Restarting in an elevated session..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

. "$PSScriptRoot\Install-Lib.ps1"

$confirm = $Host.UI.PromptForChoice(
    "Apps & Tools Installation",
    "This will install apps and tools on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Installation cancelled." -ForegroundColor Red
    Exit
}

$apps = @(
    [PSCustomObject]@{ Name = "NVIDIA App";        Id = "NVIDIA.NVIDIAApp" }
    [PSCustomObject]@{ Name = "Google Chrome";     Id = "Google.Chrome" }
    [PSCustomObject]@{ Name = "Visual Studio Code";Id = "Microsoft.VisualStudioCode" }
    [PSCustomObject]@{ Name = "Paint.NET";         Id = "dotPDN.PaintDotNet" }
    [PSCustomObject]@{ Name = "JetBrains Toolbox"; Id = "JetBrains.Toolbox" }
    [PSCustomObject]@{ Name = "Logitech Options+"; Id = "Logitech.OptionsPlus" }
    [PSCustomObject]@{ Name = "Zoom";              Id = "Zoom.Zoom" }
    [PSCustomObject]@{ Name = "OBS Studio";        Id = "Obsproject.OBSStudio" }
    [PSCustomObject]@{ Name = "Docker Desktop";    Id = "Docker.DockerDesktop" }
    [PSCustomObject]@{ Name = "Notepad++";         Id = "Notepad++.Notepad++" }
    [PSCustomObject]@{ Name = "7zip";              Id = "7zip.7zip" }
)

$selected = $apps | Out-GridView -Title "Select apps to install" -PassThru

if (-not $selected) {
    Write-Host "No apps selected. Installation cancelled." -ForegroundColor Red
    Exit
}


# ==========================================
# APPS INSTALLATION
# ==========================================

Write-Host "=== Starting Apps Installation ===" -ForegroundColor Magenta

# NVIDIA App
if (Was-Selected "NVIDIA App") {
    Install-WingetApp "NVIDIA App" "NVIDIA.NVIDIAApp"
}

# Google Chrome
if (Was-Selected "Google Chrome") {
    Install-WingetApp "Google Chrome" "Google.Chrome"
}

# VSCode
if (Was-Selected "Visual Studio Code") {
    Install-WingetApp "Visual Studio Code" "Microsoft.VisualStudioCode"
}

# Paint.net
if (Was-Selected "Paint.NET") {
    Install-WingetApp "Paint.NET" "dotPDN.PaintDotNet"
}

# JetBrains Toolbox
if (Was-Selected "JetBrains Toolbox") {
    Install-WingetApp "JetBrains Toolbox" "JetBrains.Toolbox"
}

# Logitech Options+
if (Was-Selected "Logitech Options+") {
    Install-WingetApp "Logitech Options+" "Logitech.OptionsPlus"
}

# Zoom
if (Was-Selected "Zoom") {
    Install-WingetApp "Zoom" "Zoom.Zoom"
}

# OBS Studio
if (Was-Selected "OBS Studio") {
    Install-WingetApp "OBS Studio" "Obsproject.OBSStudio"
}

# Docker Desktop
if (Was-Selected "Docker Desktop") {
    Install-WingetApp "Docker Desktop" "Docker.DockerDesktop"
}

# Notepad++
if (Was-Selected "Notepad++") {
    Install-WingetApp "Notepad++" "Notepad++.Notepad++"
}

# 7zip
if (Was-Selected "7zip") {
    Install-WingetApp "7zip" "7zip.7zip"
}

# Lightshot
if (Was-Selected "Lightshot") {
    Install-WingetApp "Lightshot" "Skillbrains.Lightshot"
}

# TODO: Whatsapp (Requires special handling for silent install)


# ==========================================
# ADDITIONAL TOOLS & UTILITIES
# ==========================================

# TODO: Chocolatey (Requires special handling for installation)

# TODO:

Write-Host "=== Installation of Apps & Tools Complete! ===" -ForegroundColor Magenta
