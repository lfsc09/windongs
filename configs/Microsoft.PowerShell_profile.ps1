# The first time the Terminal-Icons module needs to be installed:
# Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module Terminal-Icons

# Startup
oh-my-posh init pwsh --config "<YourDrive>:\Users\<YourUsername>\Documents\PowerShell\posh-theme.json" | Invoke-Expression

# History

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
