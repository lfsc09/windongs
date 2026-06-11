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

# TODO: Get rid of this ID since it is not used
$apps = @(
    [PSCustomObject]@{ Name = "NVIDIA App";        Id = "" }
    [PSCustomObject]@{ Name = "Google Chrome";     Id = "" }
    [PSCustomObject]@{ Name = "Visual Studio Code";Id = "" }
    [PSCustomObject]@{ Name = "Paint.NET";         Id = "" }
    [PSCustomObject]@{ Name = "JetBrains Toolbox"; Id = "" }
    [PSCustomObject]@{ Name = "Logitech Options+"; Id = "" }
    [PSCustomObject]@{ Name = "OBS Studio";        Id = "" }
    [PSCustomObject]@{ Name = "Docker Desktop";    Id = "" }
    [PSCustomObject]@{ Name = "7zip";              Id = "" }
    [PSCustomObject]@{ Name = "Lightshot";         Id = "" }
    [PSCustomObject]@{ Name = "WinDirStat";        Id = "" }
    [PSCustomObject]@{ Name = "Claude Suite";      Id = "" }
    [PSCustomObject]@{ Name = "Chocolatey";        Id = "" }
    [PSCustomObject]@{ Name = "Bruno";             Id = "" }
)

$selected = $apps | Out-GridView -Title "Select apps to install" -PassThru

if (-not $selected) {
    Write-Host "No apps selected. Installation cancelled." -ForegroundColor Red
    Exit
}


# ==========================================
# APPS INSTALLATION
# ==========================================

# TODO: Must address potential errors caused by "Installer has does not match", when winget hash id does not match the
#       updated program hash id. (Because of recent updates on the program)

Write-Host "=== Starting Apps Installation ===" -ForegroundColor Magenta

# NVIDIA App
if (Was-Selected "NVIDIA App") {
    # Uses https://github.com/emilwojcik93/Install-NvidiaApp
    irm https://github.com/emilwojcik93/Install-NvidiaApp/releases/latest/download/Install-NvidiaApp.ps1 | iex
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

# OBS Studio
if (Was-Selected "OBS Studio") {
    Install-WingetApp "OBS Studio" "OBSProject.OBSStudio"
}

# Docker Desktop
if (Was-Selected "Docker Desktop") {
    Install-WingetApp "Docker Desktop" "Docker.DockerDesktop"
}

# 7zip
if (Was-Selected "7zip") {
    Install-WingetApp "7zip" "7zip.7zip"
}

# Lightshot
if (Was-Selected "Lightshot") {
    Install-WingetApp "Lightshot" "Skillbrains.Lightshot"
}

# WinDirStat
if (Was-Selected "WinDirStat") {
    Install-WingetApp "WinDirStat" "WinDirStat.WinDirStat"
}

# Claude Suite
if (Was-Selected "Claude Suite") {
    Install-WingetApp "Claude" "Anthropic.Claude"
    Install-WingetApp "Claude Code" "Anthropic.ClaudeCode"
}

# Chocolatey
if (Was-Selected "Chocolatey") {
    Install-WingetApp "Chocolatey" "Chocolatey.Chocolatey"
}

# Bruno
if (Was-Selected "Bruno") {
    Install-WingetApp "Bruno" "Bruno.Bruno"
}

Write-Host "=== Installation of Apps & Tools Complete! ===" -ForegroundColor Magenta
