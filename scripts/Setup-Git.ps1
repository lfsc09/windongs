$confirm = $Host.UI.PromptForChoice(
    "Git Setup",
    "This will setup Git on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Git setup cancelled." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

# Define the path to the GitHub folder in the User's Home
$githubDir = Join-Path $HOME "Github"

# Check if the directory does not exist yet
if (-not (Test-Path $githubDir)) {
    New-Item -Path $githubDir -ItemType Directory | Out-Null
    Write-Host "Github directory created at $githubDir..." -ForegroundColor Green
} else {
    Write-Host "Github directory already exists at $githubDir." -ForegroundColor Green
}

$confirm = $Host.UI.PromptForChoice(
    "Configure Git Globals",
    "This will configure Git --global on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -eq 0) {
    do { $gitName  = Read-Host "Enter your Git username" }  while ([string]::IsNullOrWhiteSpace($gitName))
    do { $gitEmail = Read-Host "Enter your Git email" }     while ([string]::IsNullOrWhiteSpace($gitEmail))

    # Set global Git configurations
    git config --global user.name "$gitName"
    git config --global user.email "$gitEmail"

    git config --global init.defaultBranch main

    git config --global diff.algorithm histogram
    git config --global color.ui auto
    git config --global diff.mnemonicPrefix true

    git config --global branch.sort -committerdate
    git config --global tag.sort -version:refname
}

$confirm = $Host.UI.PromptForChoice(
    "Git SSH Key",
    "This will create a Git SSH key on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -eq 0) {
    if ([string]::IsNullOrWhiteSpace($gitEmail)) {
        do { $gitEmail = Read-Host "Enter your Git email" } while ([string]::IsNullOrWhiteSpace($gitEmail))
    }

    # Clean the email string by replacing '@' and '.' with '_'
    $cleanEmail = $gitEmail.Replace('@', '_').Replace('.', '_')

    # Ensure the .ssh folder exists in user's home before creating files inside it
    $sshDir = Join-Path $HOME ".ssh"
    if (-not (Test-Path $sshDir)) {
        New-Item -Path $sshDir -ItemType Directory | Out-Null
    }

    # Construct the full path to the SSH key file
    $sshKeyFile = Join-Path $HOME ".ssh\github_${cleanEmail}_ed25519"

    # Generate SSH keys only if this specific file doesn't exist yet
    if (-not (Test-Path $sshKeyFile)) {
        ssh-keygen -t ed25519 -C "$gitEmail" -f "$sshKeyFile" -N ""
    } else {
        Write-Host "SSH key file already exists at $sshKeyFile." -ForegroundColor Green
    }
}

$confirm = $Host.UI.PromptForChoice(
    "Setup GPG Signed Commits",
    "This will create a Git GPG key on your system and configure Git to use it for signing commits. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -eq 0) {
    # Install GnuPG Core via Winget if missing
    if (-not (winget list --id GnuPG.GnuPG --exact 2>$null)) {
        Write-Host "Installing GnuPG..." -ForegroundColor Yellow
        winget install --id GnuPG.GnuPG --silent --accept-source-agreements --accept-package-agreements
        
        # Refresh environment variables so PowerShell instantly sees 'gpg'
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }

    if ([string]::IsNullOrWhiteSpace($gitName)) {
        do { $gitName  = Read-Host "Enter your Git username" }  while ([string]::IsNullOrWhiteSpace($gitName))
    }
    if ([string]::IsNullOrWhiteSpace($gitEmail)) {
        do { $gitEmail = Read-Host "Enter your Git email" } while ([string]::IsNullOrWhiteSpace($gitEmail))
    }

    # Configure Git to look at the correct Windows path for GPG
    $gpgPath = "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
    git config --global gpg.program $gpgPath

    # Check if a GPG key already exists for this email to keep it idempotent
    $existingKey = gpg --list-secret-keys --keyid-format LONG 2>$null | Select-String $gitEmail

    if (-not $existingKey) {
        Write-Host "No existing GPG key found. Generating a new one silently..." -ForegroundColor Yellow

        # Create a temporary batch file configuration for GPG automation
        $gpgBatchFile = "$env:TEMP\gpg-batch.txt"
    @'
    Key-Type: ed25519
    Key-Usage: sign
    Name-Real: YOUR_NAME_REPLACE
    Name-Email: YOUR_EMAIL_REPLACE
    Expire-Date: 0
    %commit
'@ -replace 'YOUR_NAME_REPLACE', $gitName -replace 'YOUR_EMAIL_REPLACE', $gitEmail | Out-File $gpgBatchFile -Encoding ascii

        # Generate the key using the batch file completely unattended
        & $gpgPath --batch --generate-key $gpgBatchFile
        Remove-Item $gpgBatchFile -ErrorAction SilentlyContinue
    } else {
        Write-Host "GPG key for $gitEmail already exists." -ForegroundColor Green
    }

    # Extract the Key ID reliably using a Regex Match instead of Split
    $gpgSecrets = gpg --list-secret-keys --keyid-format LONG
    if ($gpgSecrets -match 'sec\s+\w+\/([A-F0-9]+)\s') {
        $keyId = $Matches[1]
        
        # Apply to Git config
        git config --global user.signingkey $keyId
        git config --global commit.gpgsign true
        
        Write-Host "Git successfully configured to sign commits with GPG Key ID: $keyId" -ForegroundColor Green
    } else {
        Write-Warning "Failed to extract GPG Key ID."
    }
}
