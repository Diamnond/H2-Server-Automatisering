# Get parameters for computer name and service name
param (
    [Parameter(Mandatory=$true)][string]$ComputerName,
    [Parameter(Mandatory=$true)][string]$ServiceName
)

# Create a new PowerShell session to the remote computer
$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)


Invoke-Command -Session $Session -ScriptBlock {
    # Get the service instance
    $Service = Get-CimInstance -Class Win32_Service -Filter "name='$Using:ServiceName'"
    
    # Prompt for confirmation before stopping the service
    $ConfirmTermination = Read-Host "Are you sure you want to stop the service $Service on $Using:ComputerName ? (Y/N)"
    # If confirmed, stop the service
    if ($ConfirmTermination -in ("Y", "y")) {
        Invoke-CimMethod -MethodName StopService -InputObject $Service
        # Output confirmation message
        Write-Host "Process $Using:ServiceName has been stopped on $Using:ComputerName."
    }

}

Remove-PSSession $Session