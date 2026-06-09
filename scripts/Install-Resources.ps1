# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Restarting in an elevated session..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

. "$PSScriptRoot\Install-Lib.ps1"

$confirm = $Host.UI.PromptForChoice(
    "Windows Resources Installation",
    "This will install Windows resources on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Installation cancelled." -ForegroundColor Red
    Exit
}


# ==========================================
# WINDOWS RESOURCES
# ==========================================

# Enable Developer Mode
# Write-Host "=== Enabling Developer Mode ===" -ForegroundColor Magenta
# if (-not (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock").AllowDevelopmentWithoutDevLicense) {
#     Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1
#     Write-Host "-> Developer Mode enabled." -ForegroundColor Green
# } else {
#     Write-Host "-> Developer Mode is already enabled." -ForegroundColor Green
# }

# Enable WSL (Windows Subsystem for Linux) - Optional, but recommended for development
Write-Host "=== Enabling Windows Subsystem for Linux (WSL) ===" -ForegroundColor Magenta
if (-not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled') {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Host "-> WSL enabled. Please restart your computer to complete the installation." -ForegroundColor Green
} else {
    Write-Host "-> WSL is already enabled." -ForegroundColor Green
}

# Hyper-V (Optional, but required for Docker Desktop with Hyper-V backend)
Write-Host "=== Enabling Hyper-V ===" -ForegroundColor Magenta
if (-not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All).State -eq 'Enabled') {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
    Write-Host "-> Hyper-V enabled. Please restart your computer to complete the installation." -ForegroundColor Green
} else {
    Write-Host "-> Hyper-V is already enabled." -ForegroundColor Green
}

# Sandbox (Optional, but recommended for testing and development)
Write-Host "=== Enabling Windows Sandbox ===" -ForegroundColor Magenta
if (-not (Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM").State -eq 'Enabled') {
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -NoRestart
    Write-Host "-> Windows Sandbox enabled. Please restart your computer to complete the installation." -ForegroundColor Green
} else {
    Write-Host "-> Windows Sandbox is already enabled." -ForegroundColor Green
}

Write-Host "=== Installation of Windows Resources Complete! ===" -ForegroundColor Magenta
