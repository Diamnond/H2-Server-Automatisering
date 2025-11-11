# Case 4: Systemrapport med pipeline
# Du skal lave et script, der samler informationer om systemet (for eksempel CPU, RAM, netværkskort og
# operativsystem).
# Oplysningerne skal hentes via PowerShell og gemmes som en rapport i CSV-format.

# Mål for case:

# 1. Brug Get-CimInstance til at hente systemdata
# 2. Filtrer og formater output (Select-Object, Format-Table)
# 3. Gem data i CSV-fil

# Ekstra udfordring:
# 4. Udvid rapporten til at omfatte flere servere via PowerShell remoting

# (for eksempel CPU, RAM, netværkskort og
# operativsystem).



#Get-CimInstance -ClassName Win32_Processor
# Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True"
#Get-CimInstance -ClassName Win32_PhysicalMemory
Get-CimInstance -ClassName Win32_OperatingSystem


# Get relevant Processor Information
$ProcessoInfo = Get-CimInstance -ClassName Win32_Processor -ComputerName $Server | Select-Object Name
# Get relevant Network Adapter Configuration
$NetworkInfo = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ComputerName $Server | Select-Object Description, IPAddress, IPSubnet, MACAddress, DefaultIPGateway, DNSHostName, DNSDomainSuffixSearchOrder, DNSServerSearchOrder, DHCPEnabled, DHCPServer, DHCPLeaseObtained, DHCPLeaseExpires
# Get relevant Physical Memory Information
$MemoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $Server | Select-Object Manufacturer, @{n="Capacity";e={$_.Capacity/1GB}}, Speed, SerialNumber, PartNumber
# Get relevant Operating System Information
$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Server | Select-Object Caption, Version, BuildNumber, OSArchitecture, LastBootUpTime, @{n="TotalVisibleMemorySize (GB)";e={$_.TotalVisibleMemorySize/1024/1024}}, @{n="FreePhysicalMemory (GB)";e={$_.FreePhysicalMemory/1024/1024}}


# Combine all information into a single object
$SystemReport = [PSCustomObject]@{
    Processor = $ProcessoInfo
    NetworkAdapters = $NetworkInfo
    PhysicalMemory = $MemoryInfo
    OperatingSystem = $OSInfo
}

Write-Output $SystemReport

# Export the system report to a CSV file
$SystemReport | Export-Csv -Path ".\System-Report-$((get-date).ToString("dd-MM-yyyy")).csv" -NoTypeInformation