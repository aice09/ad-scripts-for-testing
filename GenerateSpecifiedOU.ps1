# Prompt the user to enter the parent OU
$parentOU = Read-Host "Enter the Distinguished Name (DN) of the parent OU (e.g., OU=SpecifiedLocation,DC=yourdomain,DC=com)"

# Define the list of new OUs to be created
$newOUs = @("Active Computers", "Active Servers", "Active Service Accounts", "Active Users")

# Loop through the list and create each OU
foreach ($ou in $newOUs) {
    # Construct the Distinguished Name (DN) for the new OU
    $ouDN = "OU=$ou,$parentOU"

    # Create the new OU
    try {
        New-ADOrganizationalUnit -Name $ou -Path $parentOU -ProtectedFromAccidentalDeletion $true
        Write-Host "Successfully created OU: $ouDN"
    } catch {
        Write-Host "Failed to create OU: $ouDN. Error: $_"
    }
}
