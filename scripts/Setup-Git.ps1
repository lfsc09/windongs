$confirm = $Host.UI.PromptForChoice(
    "Git Setup",
    "This will setup Git on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -ne 0) {
    Write-Host "Git setup cancelled." -ForegroundColor Red
    Exit
}

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

$confirm = $Host.UI.PromptForChoice(
    "Git SSH Key",
    "This will create a Git SSH key on your system. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -eq 0) {
    # Generate SSH keys
    ssh-keygen -t ed25519 -C "$gitEmail" -f "$env:USERPROFILE\.ssh\id_ed25519" -N ""
}

$confirm = $Host.UI.PromptForChoice(
    "Setup GPG Signed Commits",
    "This will create a Git GPG key on your system and configure Git to use it for signing commits. Proceed?",
    @("&Yes", "&No"),
    1  # Default: No
)
if ($confirm -eq 0) {
    # Generate GPG keys
    gpg --full-generate-key

    # Install Gpg4win and set the GPG program path for Git
    # Only core GnuPG
    winget install --id GnuPG.GnuPG --exact
    # Should prompt the installation
    # winget install --id GnuPG.Gpg4win --interactive

    git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"

    # Sign commits
    git config --global commit.gpgsign true
    git config --global user.signingkey (gpg --list-secret-keys --keyid-format LONG | Select-String "sec" | ForEach-Object { $_.ToString().Split()[1].Split("/")[1] })
}
