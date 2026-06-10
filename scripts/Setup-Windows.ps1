# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Restarting in an elevated session..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$confirm = $Host.UI.PromptForChoice(
    "Windows Setup",
    "This will setup your Windows system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Windows setup cancelled." -ForegroundColor Red
    Exit
}

# ==========================================
# WINDOWS POWER OPTIONS
# ==========================================
# Find all configurations with `powercfg /query`

# Set as Balanced
powercfg /setactive SCHEME_BALANCED

# PowerButton - On Battery - Sleep (1)
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 1
# PowerButton - Plugged In - Sleep (1)
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 1

# Lid Closed - On Battery - Do Nothing (0)
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
# Lid Closed - Plugged In - Do Nothing (0)
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0

# Plugged In
powercfg /change monitor-timeout-ac 0
powercfg /change standby-timeout-ac 0

# On Battery
powercfg /change monitor-timeout-dc 30
powercfg /change standby-timeout-dc 45


# ==========================================
# WINDOWS MULTITASKING
# ==========================================
# Hide snap groups on hover
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableTaskGroups" -Value 0


# ==========================================
# WINDOWS CLIPBOARD
# ==========================================
# Enable clipboard history
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1


# ==========================================
# FILE EXPLORER
# ==========================================
Write-Host "Configuring File Explorer options..." -ForegroundColor Cyan

# Show hidden files, folders, and drives
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
# Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0


# ==========================================
# WINDOWS DEVICES
# ==========================================
# Mouse speed (Needs reboot/logout)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSensitivity" -Value 5

# Mouse pointer style
Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "(Default)" -Value "Windows Black"

# Mouse pointer size - Slide position (3)
Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name "CursorBaseSize" -Value 48

# Disable "Use print screen to open screen capture"
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "PrintScreenKeyForSnippingEnabled" -Value 0

# Set Flags value to 506 to disable Sticky Keys and its Shift key shortcut
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506"

# Set Flags value to 122 to disable Filter Keys and physical shortcut
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value 122


# ==========================================
# WINDOWS PERSONALIZATION
# ==========================================
# THEMES - Set to Windows Dark
# Set Windows system elements to Dark Mode
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Type Dword -Force
# Set installed applications to Dark Mode
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Type Dword -Force
Start-Process "C:\Windows\Resources\Themes\dark.theme"

# COLORS - Disable transparency effect
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name EnableTransparency -Value 0

# START - Disable "Show recently added apps"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

# START - Disable "Show recommended files"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

# START - Disable "Show recommendations for tips"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Value 0

# TASKBAR - Hide search box
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0 -Force

# TASKBAR - Hide task view
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0


# ==========================================
# WINDOWS GAMEBAR
# ==========================================
# Disable game DVR and Background recording
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0


# ==========================================
# WINDOWS EXPLORER SETTINGS
# ==========================================

