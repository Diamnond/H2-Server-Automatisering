# User Configuration
$CSVPath = ".\Case5\NewUsers.csv"
$domain = "sko.butik"
$LogPath = ".\Case5\log-$((get-date).ToString("dd-MM-yyyy")).txt"

# Start logging
Start-Transcript -Path $LogPath

# Get Credentials from the user
$Credentials = Get-Credential -Message "Enter credentials with permissions to create AD users in the $domain domain." -UserName "$domain\"

# Import the CSV file
write-Host "Importing users from CSV file: $CSVPath" -ForegroundColor Cyan
$Users = Import-Csv -Path $CSVPath

# Main Loop
$Users | ForEach-Object {
    # Define the Diffrent attributes needed
    $user = $_
    $samAccountName = $user.SamAccountName
    $givenName = $user.GivenName
    $surname = $user.Surname
    $displayName = "$givenName $surname"
    $email = $user.Email
    $department = $user.Department
    $title = $user.Title
    $groups = $user.Groups -split ';'  # Assuming groups are semicolon-separated
    $tempPassword = $user.TempPassword
    $OU = $user.OU


    try {
        # Check if the user already exists
        if (-Not ((Get-ADUser -Filter { SamAccountName -eq $samAccountName }) -eq $null)) {
            Write-Host "User $samAccountName already exists. Skipping creation." -ForegroundColor Yellow
        }
        else {
            # Create the new AD user
            New-ADUser -Credential $Credentials `
                -SamAccountName $samAccountName `
                -Name $givenName `
                -GivenName $givenName `
                -Surname $surname `
                -DisplayName $displayName `
                -EmailAddress $email `
                -Department $department `
                -Title $title `
                -AccountPassword (ConvertTo-SecureString "$tempPassword" -AsPlainText -Force) `
                -Enabled $true `
                -Path $OU `
                -UserPrincipalName "$samAccountName@$domain" `
                -ChangePasswordAtLogon $true 

            # Add user to specified groups
            foreach ($group in $groups) {
                if ($group.Trim() -ne "") {
                    Add-ADGroupMember -Identity $group.Trim() -Members $samAccountName
                }
            }
            Write-Host "Successfully created user: $samAccountName" -ForegroundColor Green
        }

       
    } 
    catch {
        Write-Host "Failed to create user: $samAccountName. Error: $_" -ForegroundColor Red
    }
      
}

Stop-Transcript