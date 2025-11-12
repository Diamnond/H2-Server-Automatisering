# Script that creates a comma separated CSV report of system information from the defined Targets

# Define the target servers
$Targets = @("winsrv02", "WIN-PH6NQ0JNGS4")
# Path to save the report to MUST END WITH A BACKSLASH
$ReportPath = ".\Case4\"


# Accumulator for reports from all servers
$AllReports = @()

foreach ($Target in $Targets) {

    # Get relevant Processor Information
    $ProcessorInfo = Get-CimInstance -ClassName Win32_Processor -ComputerName $Target | `
    Select-Object @(
        @{n="Name";e={$_.Name}}
    )

    # Get relevant Network Adapter Configuration
    $NetworkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ComputerName $Target | `
    Select-Object @(
        @{n="NIC Description";e={$_.Description}},
        @{n="IP Addresses";e={$_.IPAddress}},
        @{n="Subnet masks";e={$_.IPSubnet}},
        @{n="MAC Address";e={$_.MACAddress}},
        @{n="Defaut Gateway";e={$_.DefaultIPGateway}},
        @{n="DNS Hostname";e={$_.DNSHostName}},
        @{n="Search Domains";e={$_.DNSDomainSuffixSearchOrder}},
        @{n="DNS Servers";e={$_.DNSServerSearchOrder}},
        @{n="DHCP Enabled";e={$_.DHCPEnabled}},
        @{n="DHCP Server";e={$_.DHCPServer}},
        @{n="DHCP Lease Obtained";e={$_.DHCPLeaseObtained}},
        @{n="DHCP Lease Expires";e={$_.DHCPLeaseExpires}}
    )

    # Get relevant Physical Memory Information
    $MemoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $Target | `
    Select-Object @(
        @{n="Manufacturer";e={$_.Manufacturer}},
        @{n="Capacity";e={$_.Capacity/1GB}},
        @{n="Speed";e={$_.Speed}},
        @{n="SerialNumber";e={$_.SerialNumber}},
        @{n="PartNumber";e={$_.PartNumber}}
    )

    # Get relevant Operating System Information
    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Target | `
    Select-Object @(
        @{n="Caption";e={$_.Caption}},
        @{n="Version";e={$_.Version}},
        @{n="Build Number";e={$_.BuildNumber}},
        @{n="Architecture";e={$_.OSArchitecture}},
        @{n="Last Boot Up Time";e={$_.LastBootUpTime}},
        @{n="Total Memory (GB)";e={$_.TotalVisibleMemorySize/1024/1024}},
        @{n="Free Memory (GB)";e={$_.FreePhysicalMemory/1024/1024}}
    )


    # Create a custom object to hold all system information
    $SystemReport = [PSCustomObject]@{
        ComputerName = $Target
        CollectionTime = Get-Date
    }

    # Helper function to add properties recursively
    function Add-PropertiesToReport {
        param (
            [PSCustomObject]$Report,
            [object]$Data,
            [string]$Prefix = ""
        )
        
        $Data | ForEach-Object {
            $currentObject = $_
                $currentObject | Get-Member -MemberType NoteProperty | ForEach-Object {
                    $propertyName = $_.Name
                    $value = $currentObject.$propertyName

                    # Handle arrays by joining with ", "
                    if ($value -is [array]) {
                        $value = $value -join ", "
                    }

                    # Create property name with prefix if specified
                    $displayName = if ($Prefix) { "$Prefix $propertyName" } else { $propertyName }

                    # If the property already exists on the report, combine values instead of overwriting
                    $existing = $null
                    if ($Report.PSObject.Properties.Match($displayName)) {
                        $existing = $Report.$displayName
                    }

                    if ($null -ne $existing -and $existing -ne "") {
                        # Build combined array of existing and new values
                        if ($existing -is [array]) { $combined = $existing } else { $combined = @($existing) }
                        if ($null -ne $value -and $value -ne "") { $combined += $value }
                        # Remove empties and duplicates, then join
                        $finalValue = ($combined | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Unique) -join "; "
                    } else {
                        $finalValue = $value
                    }

                    $Report | Add-Member -NotePropertyName $displayName -NotePropertyValue $finalValue -Force
                }
        }
    }

    # Add all collected information recursively
    Add-PropertiesToReport -Report $SystemReport -Data $ProcessorInfo -Prefix "CPU"
    Add-PropertiesToReport -Report $SystemReport -Data $NetworkInfo
    Add-PropertiesToReport -Report $SystemReport -Data $MemoryInfo -Prefix "RAM"
    Add-PropertiesToReport -Report $SystemReport -Data $OSInfo -Prefix "OS"

    # Append this server's report to the accumulator
    $AllReports += $SystemReport

}

# Export all collected reports to a single CSV file (one row per server)
$CsvPath = $ReportPath + "System-Report-$((Get-Date).ToString("dd-MM-yyyy")).csv"
if ($AllReports.Count -eq 0) {
    Write-Warning "No reports collected; nothing to export."
} else {
    $AllReports | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8 -Force
    Write-Host "System report exported to: $CsvPath" -ForegroundColor Green
}
