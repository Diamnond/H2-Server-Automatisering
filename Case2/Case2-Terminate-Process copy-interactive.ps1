param (
    [Parameter(Mandatory=$true)][string]$ComputerName,
    [Parameter(Mandatory=$true)][string]$ProccessName
)

$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)

Invoke-Command -Session $Session -ScriptBlock {

    $Process = Get-CimInstance -Class Win32_Process -Filter "name='$Using:ProccessName'"
    
    $ConfirmTermination = Read-Host "Are you sure you want to terminate the process $Process on $env:COMPUTERNAME? (Y/N)"
    if ($ConfirmTermination -in ("Y", "y")) {
        Invoke-CimMethod -MethodName Terminate -InputObject $Process
        Write-Host "Process $Using:ProccessName has been terminated on $env:COMPUTERNAME."
    }

}

Remove-PSSession $Session