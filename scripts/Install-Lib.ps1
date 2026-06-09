if ($MyInvocation.InvocationName -ne '.') {
    throw "This file is a library. Use `. '$PSCommandPath'` to load it."
}

# Helper function to run winget install with silent and agreement flags
function Install-WingetApp {
    param (
        [string]$AppName,
        [string]$PackageId
    )

    Write-Host "Checking status for $AppName..." -ForegroundColor Cyan

    # Check if already installed
    $installed = winget list --id $PackageId --exact 2>$null
    if ($installed) {
        Write-Host "-> $AppName is already installed. Skipping." -ForegroundColor Green
    } else {
        Write-Host "-> Installing $AppName..." -ForegroundColor Yellow
        winget install --id $PackageId --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "-> $AppName installed successfully!" -ForegroundColor Green
        } else {
            Write-Warning "-> Failed to install $AppName."
        }
    }
    Write-Host "--------------------------------------------------"
}

# Helper function to check if an app was selected
function Was-Selected($name) {
    return ($selected | Where-Object { $_.Name -eq $name }) -ne $null
}
