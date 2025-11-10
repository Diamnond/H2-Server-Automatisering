# Scheduled Task: Disk Usage Report Generation

$ComputerName = "winsrv02"
$TaskName = "Disk-Usage-Report"
$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)
$RemoteScriptPath = "C:\Scripts\Disk-Usage-Report.ps1"
$LocalScriptPath = ".\Disk-Usage-Report.ps1"
$TaskTime = "15:00"

# Ensure the script exists on the remote machine
if (-Not (Invoke-Command -Session $Session -ScriptBlock {Test-Path -Path $Using:RemoteScriptPath})) {
    Invoke-Command -Session $Session -ScriptBlock {
        New-Item -Path $Using:RemoteScriptPath -Force
    }
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
