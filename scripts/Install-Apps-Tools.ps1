# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Restarting in an elevated session..."
}

$confirm = $Host.UI.PromptForChoice(
    "Apps & Tools Installation",
    "This will install apps and tools on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Installation cancelled." -ForegroundColor Red
}

$apps = @(
    [PSCustomObject]@{ Name = "7zip" }
    [PSCustomObject]@{ Name = "Bruno" }
    [PSCustomObject]@{ Name = "Chocolatey" }
    [PSCustomObject]@{ Name = "Claude" }
    [PSCustomObject]@{ Name = "Claude Code" }
    [PSCustomObject]@{ Name = "Docker Desktop" }
    [PSCustomObject]@{ Name = "Google Chrome" }
    [PSCustomObject]@{ Name = "JetBrains Toolbox" }
    [PSCustomObject]@{ Name = "Lightshot" }
    [PSCustomObject]@{ Name = "Logitech Options+" }
    [PSCustomObject]@{ Name = "NVIDIA App" }
    [PSCustomObject]@{ Name = "OBS Studio" }
    [PSCustomObject]@{ Name = "Paint.NET" }
    [PSCustomObject]@{ Name = "VS Code" }
    [PSCustomObject]@{ Name = "WinDirStat" }
)

# Show the GUI selection menu
$selected = $apps | Out-ConsoleGridView -Title "Select apps to install (Press SPACE to select, ENTER to confirm)" -OutputMode Multiple

if (-not $selected) {
    Write-Host "No apps selected. Installation cancelled." -ForegroundColor Red
}

function Install-WingetApp {
    param ([string]$PackageId)
    winget install --id $PackageId
}

# ==========================================
# APPS INSTALLATION
# ==========================================

foreach ($app in $selected) {
    switch ($app.Name) {
        # --------------------------------------------------
        # NON-WINGET APPS (Custom Installers)
        # --------------------------------------------------
        "NVIDIA App" {
            # Uses https://github.com/emilwojcik93/Install-NvidiaApp
            irm https://github.com/emilwojcik93/Install-NvidiaApp/releases/latest/download/Install-NvidiaApp.ps1 | iex
        }

        # --------------------------------------------------
        # WINGET APPS
        # --------------------------------------------------
        "7zip"                { Install-WingetApp "7zip.7zip" }
        "Bruno"               { Install-WingetApp "Bruno.Bruno" }
        "Chocolatey"          { Install-WingetApp "Chocolatey.Chocolatey" }
        "Claude"              { Install-WingetApp "Anthropic.Claude" }
        "Claude Code"         { Install-WingetApp "Anthropic.ClaudeCode" }
        "Docker Desktop"      { Install-WingetApp "Docker.DockerDesktop" }
        "Google Chrome"       { Install-WingetApp "Google.Chrome" }
        "JetBrains Toolbox"   { Install-WingetApp "JetBrains.Toolbox" }
        "Lightshot"           { Install-WingetApp "Skillbrains.Lightshot" }
        "Logitech Options+"   { Install-WingetApp "Logitech.OptionsPlus" }
        "OBS Studio"          { Install-WingetApp "OBSProject.OBSStudio" }
        "Paint.NET"           { Install-WingetApp "dotPDN.PaintDotNet" }
        "VS Code"             { Install-WingetApp "Microsoft.VisualStudioCode" }
        "WinDirStat"          { Install-WingetApp "WinDirStat.WinDirStat" }
        
        Default {
            Write-Warning "No installation rule defined for $($app.Name)"
        }
    }
}
