# Get parameters for computer name and process name
param (
    [Parameter(Mandatory=$true)][string]$ComputerName,
    [Parameter(Mandatory=$true)][string]$ProccessName
)

# Create a new PowerShell session to the remote computer
$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)


Invoke-Command -Session $Session -ScriptBlock {
    # Get the process instance
    $Process = Get-CimInstance -Class Win32_Process# -Filter "name='$Using:ProccessName'"
    
    # Prompt for confirmation before terminating the process
    $ConfirmTermination = Read-Host "Are you sure you want to terminate the process $Process on $env:COMPUTERNAME? (Y/N)"
    
    # If confirmed, terminate the process
    if ($ConfirmTermination -in ("Y", "y")) {
        Invoke-CimMethod -MethodName Terminate -InputObject $Process
        # Output confirmation message
        Write-Host "Process $Using:ProccessName has been terminated on $env:COMPUTERNAME."
    }

}

Remove-PSSession $Session