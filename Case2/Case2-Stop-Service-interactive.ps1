param (
    [Parameter(Mandatory=$true)][string]$ComputerName,
    [Parameter(Mandatory=$true)][string]$ServiceName
)

$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)

Invoke-Command -Session $Session -ScriptBlock {

    $Service = Get-CimInstance -Class Win32_Service -Filter "name='$Using:ServiceName'"
    
    $ConfirmTermination = Read-Host "Are you sure you want to stop the service $Service on $Using:ComputerName ? (Y/N)"
    if ($ConfirmTermination -in ("Y", "y")) {
        Invoke-CimMethod -MethodName StopService -InputObject $Service
        Write-Host "Process $Using:ServiceName has been stopped on $Using:ComputerName."
    }

}

Remove-PSSession $Session