param(
	[string]$OutputCsv = "$PSScriptRoot\AD-Users.csv",
	[string]$ReportFile = "$PSScriptRoot\AD-User-Report.txt",
    [int]$LastNDays = 30,
	[switch]$IncludeDisabled
)

# Quality and environment check
Write-Verbose "Script root: $PSScriptRoot"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
	Write-Error "The ActiveDirectory module is not installed or available. Install RSAT/ActiveDirectory and try again."
	return
}

Import-Module ActiveDirectory -ErrorAction Stop

try {
	# Retrieve relevant properties; WhenCreated is needed for the 30-day filter
	$adProperties = @('GivenName','Surname','DisplayName','Mail','SamAccountName','Enabled','WhenCreated','Department','Title')

	$users = Get-ADUser -Filter * -Properties $adProperties |
		Where-Object {
			if ($IncludeDisabled) { return $true }
			# Default: only enabled users
			$_.Enabled -eq $true
		} |
		Select-Object SamAccountName, GivenName, Surname, DisplayName, Mail, Department, Title, Enabled, @{Name='WhenCreated';Expression={$_.WhenCreated}} |
		Sort-Object -Property @{Expression={$_.Surname}}, @{Expression={$_.GivenName}}

	# Export to CSV
	$users | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

	# Statistics
	$totalCount = $users.Count
	$activeCount = ($users | Where-Object { $_.Enabled -eq $true }).Count
	$newUsersCount = ($users | Where-Object { $_.WhenCreated -gt (Get-Date).AddDays(-$LastNDays) }).Count

	$reportLines = [System.Collections.Generic.List[string]]::new()
	$reportLines.Add("AD User Overview Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
	$reportLines.Add("Output CSV: $OutputCsv")
	$reportLines.Add("Total users returned: $totalCount")
	$reportLines.Add("Active users: $activeCount")
	$reportLines.Add("Users created in last $LastNDays days: $newUsersCount")
	$reportLines.Add("")
	$reportLines.Add("Example (first 10 users):")
    $reportLines.Add("")
    $reportLines.Add(("{0,-20} {1,-15} {2}" -f ("Surname"), ("First Name"), ("Logon Name")))
    $reportLines.Add(("{0,-20}-{1,-15}-{2}" -f ("-"*20), ("-"*15), ("-"*20)))
	$users | Select-Object -First 10 | ForEach-Object {

		$reportLines.Add(("{0,-20} {1,-15} {2}" -f ($_.Surname -as [string]), ($_.GivenName -as [string]), ($_.SamAccountName -as [string])))
	}

	# Save report and write to console
	$reportLines | Out-File -FilePath $ReportFile -Encoding UTF8
	$reportLines | ForEach-Object { Write-Output $_ }

	Write-Host "CSV exported to: $OutputCsv" -ForegroundColor Green
	Write-Host "Report saved to: $ReportFile" -ForegroundColor Green
}
catch {
	Write-Error "An error occurred: $_"
	throw
}

# Tips:
# - Run this script on a machine with RSAT/ActiveDirectory installed (or on a domain controller).
# - To include disabled users, add -IncludeDisabled.