# Scheduled Task: Disk Usage Report Generation

$Session = New-PSSession -ComputerName "winsrv02" -Credential (Get-Credential)

Copy-Item -ToSession $Session -Path ".\Disk-Usage-Report.ps1" -Destination "C:\Scripts\Disk-Usage-Report.ps1"

$Time=New-ScheduledTaskTrigger -At 15:00 -Once
$Action=New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\Disk-Usage-Report.ps1"
Register-ScheduledTask -TaskName "Disk-Usage-Report" -Trigger $Time -Action $Action