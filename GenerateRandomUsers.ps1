# Import the Active Directory module
Import-Module ActiveDirectory

# Function to generate a random alphanumeric string of uppercase letters and digits
function Generate-RandomString {
    param (
        [int]$length
    )
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()
    $randomChars = @()

    for ($i = 1; $i -le $length; $i++) {
        $randomIndex = Get-Random -Minimum 0 -Maximum $chars.Length
        $randomChars += $chars[$randomIndex]
    }

    $string = -join $randomChars
    return $string
}

# Function to extract the country code from the OU
function Get-CountryCode {
    param (
        [string]$ou
    )
    # Extract the country part of the OU
    $countryOU = ($ou -split ',') | Where-Object { $_ -match '^OU=[^-]+-[A-Z]{3}$' }
    $countryCode = ($countryOU -split '=')[-1] -split '-' | Select-Object -Last 1
    return $countryCode
}

# Function to extract the office from the last OU
function Get-OfficeFromOU {
    param (
        [string]$ou
    )
    $office = ($ou -split ',') | Where-Object { $_ -match '^OU=' } | Select-Object -First 1
    $office = $office.Substring(3) # Remove 'OU=' prefix
    return $office
}

# Read the CSV file
$csvFilePath = "C:\Data\Customer_Names.csv"
$users = Import-Csv -Path $csvFilePath

# Get user input
$numberToGenerate = [int](Read-Host "Numbers of users to generate")
$ou = Read-Host "Organizational Unit (OU) where users will be created (e.g., 'OU=Philippines-PHL,OU=Asia,OU=HOME-MAIN,DC=HOME-MAIN,DC=LAB')"

# Extract the country code
$countryCode = Get-CountryCode -ou $ou
if ($null -eq $countryCode) {
    Write-Host "Invalid OU format or country code not found."
    exit
}

# Extract the office from the OU
$office = Get-OfficeFromOU -ou $ou

# Generate and create the AD user accounts
for ($i = 0; $i -lt $numberToGenerate; $i++) {
    # Randomly select first name and last name from the CSV
    $firstName = $users | Get-Random | Select-Object -ExpandProperty 'First Name'
    $lastName = $users | Get-Random | Select-Object -ExpandProperty 'Last Name'

    # Generate sAMAccountName
    $randomString = Generate-RandomString -length 4
    $samAccountName = "$countryCode$randomString".ToUpper()

    # Generate Display Name
    $displayName = "$firstName $lastName - $samAccountName"

    # Display the generated user details
    Write-Host "Generated sAMAccountName: $samAccountName"
    Write-Host "Generated DisplayName: $displayName"

    # Create the user account in AD
    try {
        $userPrincipalName = "$samAccountName@$env:USERDNSDOMAIN"
        New-ADUser -Name $displayName -GivenName $firstName -Surname $lastName -DisplayName $displayName -Path $ou -SamAccountName $samAccountName -UserPrincipalName $userPrincipalName -Office $office -Enabled $true -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssw0rd!" -Force) -ChangePasswordAtLogon $true
        Write-Host "Created AD user account for $displayName successfully."
    } catch {
        Write-Host "Failed to create AD user account for $displayName. Error: $_"
    }
}
