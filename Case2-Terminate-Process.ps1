param (
    [Parameter(Mandatory=$true)][string]$ProccessName,
    [Parameter(Mandatory=$true)][string]$ComputerName
)

$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)

Invoke-Command -Session $Session -ScriptBlock {
    $process = Get-CimInstance -Class Win32_Process -Filter "name='$ProccessName'"

    Invoke-CimMethod -MethodName Terminate
} -ArgumentList $ProccessName