$ADServer = "WIN-PH6NQ0JNGS4.sko.butik"


$Session = New-PSSession -ComputerName $ComputerName -Authentication Negotiate -Credential (Get-Credential)

Invoke-Command -Session $Session -ScriptBlock {


}