# TODO: Remove Clock

# TODO: Remove Feedback Hub

# TODO: Remove Microsoft 365 Copilot

# TODO: Remove Microsoft Bing

# TODO: Remove Microsoft ToDo

# TODO: Remove Microsoft Clipchamp

# TODO: Remove News 

# TODO: Remove Notepad 

# TODO: Remove Paint 

# TODO: Remove Power Automate 

# TODO: Remove Quick Assist

# TODO: Remove Snipping Tool

# TODO: Remove Solitaire Games

# TODO: Remove Sound Recorder

# TODO: Remove Sticky Notes

# TODO: Remove Weather

# Remove Gamebar Package
Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay | Remove-AppxPackage

# Remove all Xbox bloatware
Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage
