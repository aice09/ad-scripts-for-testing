# Import the Active Directory module
Import-Module ActiveDirectory

# Function to generate random alphanumeric string of uppercase letters and digits
function Generate-RandomString {
    param (
        [int]$length
    )

    # Define characters
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()

    # Create an empty array to store random characters
    $randomChars = @()

    # Generate random characters
    for ($i = 1; $i -le $length; $i++) {
        $randomIndex = Get-Random -Minimum 0 -Maximum $chars.Length
        $randomChars += $chars[$randomIndex]
    }

    # Concatenate characters into a string
    $string = -join $randomChars
    return $string
}

# Get user input
$numberToGenerate = [int](Read-Host "Numbers to generate")
$code = Read-Host "Code (max of three letters)"
$type = Read-Host "Type (server/vm/laptop/desktop)"
$ou = Read-Host "Organizational Unit (OU) where computers will be created (e.g., 'OU=Computers,DC=example,DC=com')"

# Determine the prefix based on the type
switch ($type.ToLower()) {
    "server" { $prefix = "SV" }
    "vm" { $prefix = "VM" }
    "laptop" { $prefix = "LT" }
    "desktop" { $prefix = "DK" }
    default { Write-Host "Invalid type entered. Please enter server, vm, laptop, or desktop."; exit }
}

# Validate the code input length
if ($code.Length -gt 3) {
    Write-Host "Code exceeds the maximum length of three letters."
    exit
}

# Generate and create the AD computer accounts
for ($i = 1; $i -le $numberToGenerate; $i++) {
    $randomString = Generate-RandomString -length 6
    $computerName = "$code-$prefix-$randomString"

    # Display the generated computer name
    Write-Host $computerName

    # Create the computer account in AD
    try {
        New-ADComputer -Name $computerName -Path $ou -SamAccountName $computerName -UserPrincipalName "$computerName@$env:USERDNSDOMAIN" -Enabled $true
        Write-Host "Created AD computer account for $computerName successfully."
    } catch {
        Write-Host "Failed to create AD computer account for $computerName. Error: $_"
    }
}
