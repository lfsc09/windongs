# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator."
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

function Get-TerminalMultiSelect {
    param (
        [string[]]$Options,
        [string]$Title = "Select items:"
    )

    $selectedIndex = 0
    # Keep track of checked items (hashtable)
    $checked = @{}
    foreach ($opt in $Options) { $checked[$opt] = $false }

    # Save original cursor visibility status and clear screen space
    $oldCursorVisible = $Host.UI.RawUI.CursorSize
    Write-Host "`n$Title" -ForegroundColor Magenta
    Write-Host "(Use Up/Down Arrows, SPACE to toggle, ENTER to finish)`n" -ForegroundColor DarkGray

    # Record starting line so we can overwrite cleanly
    $startTop = [Console]::CursorTop

    while ($true) {
        # Render the menu
        [Console]::SetCursorPosition(0, $startTop)
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $opt = $Options[$i]
            $isCurrent = ($i -eq $selectedIndex)
            $isChecked = $checked[$opt]

            # Build row indicator
            $pointer = if ($isCurrent) { "> " } else { "  " }
            $box     = if ($isChecked) { "[x] " } else { "[ ] " }
            
            # Formatting highlights
            if ($isCurrent) {
                Write-Host "$pointer$box$opt" -ForegroundColor Cyan
            } else {
                Write-Host "$pointer$box$opt" -ForegroundColor Gray
            }
        }

        # Handle user input
        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow" {
                $selectedIndex--
                if ($selectedIndex -lt 0) { $selectedIndex = $Options.Count - 1 }
            }
            "DownArrow" {
                $selectedIndex++
                if ($selectedIndex -ge $Options.Count) { $selectedIndex = 0 }
            }
            "Spacebar" {
                $currentOpt = $Options[$selectedIndex]
                $checked[$currentOpt] = -not $checked[$currentOpt]
            }
            "Enter" {
                # Break loop and collect selections
                break
            }
        }
    }

    # Clean up console view and return array
    Write-Host ""
    return $Options | Where-Object { $checked[$_] }
}

$apps = @(
    "7zip", "Bruno", "Chocolatey", "Claude", "Claude Code",
    "Docker Desktop", "Google Chrome", "JetBrains Toolbox",
    "Lightshot", "Logitech Options+", "NVIDIA App", "OBS Studio",
    "Paint.NET", "VS Code", "WinDirStat"
)

# Run the menu inline
$selectedNames = Get-TerminalMultiSelect -Options $apps -Title "Select apps to install:"

if (-not $selectedNames) {
    Write-Host "No apps selected. Installation cancelled." -ForegroundColor Red
    Exit
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
