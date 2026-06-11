# The first time the Terminal-Icons module needs to be installed:
# Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module Terminal-Icons

# Startup
Invoke-Expression (&starship init powershell)

# History

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
