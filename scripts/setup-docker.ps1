param (
    [string]$UserToAdd
)

# Function to check if the script is running with administrative privileges
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# If not running as admin, elevate the script with the argument
if (-not (Test-Admin)) {
    Write-Output "The script is not running with administrative privileges."
    Write-Output "Restarting the script with elevated privileges..."

    # Relaunch the script with elevated privileges
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -UserToAdd `"$UserToAdd`"" -Verb RunAs -Wait
    # Read-Host "Press Enter to exit."
    exit
}

if (-not $UserToAdd) {
    Write-Output "No username specified. Please run the script with a username argument."
    # Wait for user input before exiting. Press Enter to continue.
    Read-Host "Press Enter to exit."
    exit 1
}

# Define the URL and the installer file name
$url = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$installer = "Docker Desktop Installer.exe"

# Get the path to the folder where the script is being executed

# Make the downloads folder the windows Downloads folder for ther user passed in as argument. Also split by '/' to get the last element of the path which is the username
$downloadsFolder = "C:\Users\$($UserToAdd.Split('\')[1])\Downloads"
# $downloadsFolder = "C:\Users\$UserToAdd\Downloads" 
$installerPath = [System.IO.Path]::Combine($downloadsFolder, $installer)

# Check if Docker Desktop is already installed
Write-Output "Checking if Docker Desktop is already installed..."
$dockerPath = (Get-Command "docker" -ErrorAction SilentlyContinue).Path

if ($dockerPath) {
    Write-Output "Docker Desktop is already installed at $dockerPath. Skipping installation."
} else {
    # Write-Output "Docker Desktop is not installed. Starting the download of Docker Desktop Installer..."

    # # Download the installer with progress bar
    # try {
    #     $response = Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing -PassThru

    #     # Calculate the progress
    #     $totalBytes = $response.Headers["Content-Length"]
    #     $bytesRead = 0
    
    #     # Open the file stream
    #     $fileStream = [System.IO.File]::OpenRead($installerPath)
    #     $buffer = New-Object byte[] 1024
    #     $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
    
    #     while ($bytesRead -gt 0) {
    #         Write-Progress -Activity "Downloading Docker Desktop Installer" -Status "Downloading..."
    #         $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
    #     }
    
    #     $fileStream.Close()
    #     Write-Output "Download complete: $installerPath"
    # } catch {
    #     Write-Output "Failed to download Docker Desktop. Error: $($_.Exception.Message)"
    #     Read-Host "Press Enter to exit."
    #     exit 1
    # }

    # Check if the file exists at the specified location
    if (-not (Test-Path $installerPath)) {
        Write-Output "Docker Desktop Installer not found at $installerPath. Please download the installer manually."
        Read-Host "Press Enter to exit"
        exit 1
    }

    # Run the installer with the specified arguments
    Write-Output "Running the Docker Desktop Installer..."
    Start-Process -FilePath $installerPath -Wait -ArgumentList 'install', '--accept-license', '--always-run-service'
    Write-Output "Docker Desktop installation process completed."
}

# Check if the specified user is already in the docker-users group
Write-Output "Checking if the user ($UserToAdd) is in the docker-users group..."
$group = Get-LocalGroupMember -Group "docker-users" -ErrorAction SilentlyContinue
$userInGroup = $group | Where-Object { $_.Name -like "*$UserToAdd*" }

if (-not $userInGroup) {
    Write-Output "User ($UserToAdd) is not in the docker-users group."
    Write-Output "Adding the user to the docker-users group..."
    Try {
        net localgroup docker-users "$UserToAdd" /add
        Write-Output "Successfully added the user ($UserToAdd) to the docker-users group."
    } Catch {
        Write-Output "Failed to add the user ($UserToAdd) to the docker-users group. Error: $_"
    }
} else {
    Write-Output "User ($UserToAdd) is already in the docker-users group."
}

Write-Output "Script execution completed."

# Prompt to restart the computer
$restartResponse = Read-Host "Do you want to restart the computer now? (Default is No) [Yes/No]"
if ($restartResponse -eq "Yes") {
    Write-Output "Restarting the computer..."
    Restart-Computer
} else {
    Write-Output "Restart skipped. Please restart the computer later if required."
}
