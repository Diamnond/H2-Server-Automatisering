# Scheduled Task: Add a scheduled task to a remote computer

# Define parameters
# Remote computer name
$ComputerName = "winsrv02"
# Name of the scheduled task
$TaskName = "Disk-Usage-Report"
# Path on the remote machine where the script will be stored
$RemoteScriptPath = "C:\Scripts\Disk-Usage-Report.ps1"
# Path to the local script to be copied
$LocalScriptPath = ".\Disk-Usage-Report.ps1"
# Time to run the task (24-hour format)
$TaskTime = "15:00"

# Create a new PowerShell session to the remote computer
$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)

# Ensure the script exists on the remote machine
if (-Not (Invoke-Command -Session $Session -ScriptBlock {Test-Path -Path $Using:RemoteScriptPath})) {
    # Create the file if it does not exist
    Invoke-Command -Session $Session -ScriptBlock {
        New-Item -Path $Using:RemoteScriptPath -Force
    }
    # Copy the local script to the remote machine
    Copy-Item -ToSession $Session -Path $LocalScriptPath -Destination $RemoteScriptPath
    Write-Output "Script copied successfully to $ComputerName."
}
else {
    Write-Output "Script already exists on $ComputerName."
}


# Create Scheduled Task if it does not exist
Invoke-Command -Session $Session -ScriptBlock {

if (Get-ScheduledTask -TaskPath "\" -TaskName $Using:TaskName -ErrorAction SilentlyContinue) {
    Write-Output "Scheduled Task '$Using:TaskName' already exists. No action taken."
}
else {
    Write-Output "Scheduled Task '$Using:TaskName' does not exist. Creating the task..."
    $Time=New-ScheduledTaskTrigger -At $Using:TaskTime -Once
    $Action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $Using:RemoteScriptPath"
    Register-ScheduledTask -TaskName $Using:TaskName -Trigger $Time -Action $Action
}

}
