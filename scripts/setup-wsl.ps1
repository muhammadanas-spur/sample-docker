# Function to check if the script is running with administrative privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if the script is running with administrative privileges
if (-not (Test-Admin)) {
    Write-Output "This script needs to be run as an administrator. Please run it with elevated privileges."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
    exit
}

# Check if WSL is installed
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslFeature.State -eq "Enabled") {
    Write-Output "WSL is already installed."
    # Wait for key press to continue
    Read-Host "Press Enter to continue..."
}
else {
    Write-Output "WSL is not installed. Installing WSL..."
    # Enable WSL using DISM
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
}

# Check if Virtual Machine Platform is installed
$vmPlatformFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

if ($vmPlatformFeature.State -eq "Enabled") {
    Write-Output "Virtual Machine Platform is already enabled."
    # Wait for key press to continue
    Read-Host "Press Enter to continue..."
}
else {
    Write-Output "Virtual Machine Platform is not enabled. Enabling Virtual Machine Platform..."
    # Enable Virtual Machine Platform using DISM
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
}

# # Restart the computer to apply changes
# Write-Output "Restarting the computer to apply changes..."
# # Wait for key press to continue
# Read-Host "Press Enter to restart the computer..."
# # Restart-Computer -Force

# Ask the user for confirmation before restarting
$confirmation = Read-Host "Do you want to restart the computer to apply changes? (y/n)"
if ($confirmation -eq 'y') {
    Write-Output "Restarting the computer to apply changes..."
    Restart-Computer
}
else {
    Write-Output "Please restart the computer manually to apply changes."
}