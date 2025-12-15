Connect-AzureAD

# Get disabled and enabled users
$users = Get-AzureADUser -All $true -Filter "AccountEnabled eq false"
$usersEnabled = Get-AzureADUser -All $true -Filter "AccountEnabled eq true"

# Refine list to users with the E5 SKU assigned to them
$licensedUsersE5 = $users | Where-Object { $_.AssignedLicenses.SkuID -contains "06ebc4ee-1bb5-47dd-8120-11324bc54e06" }

# Refine list to users with the E3 SKU assigned to them
$licensedUsersE3 = $users | Where-Object { $_.AssignedLicenses.SkuID -contains "05e9a617-0261-4cee-bb44-138d3ef5d965" }

# Refine list to users with both E5 and E3 SKUs assigned to them
$licensedUserE5E3 = $usersEnabled | Where-Object { 
    $_.AssignedLicenses.SkuID -contains "06ebc4ee-1bb5-47dd-8120-11324bc54e06" -and 
    $_.AssignedLicenses.SkuID -contains "05e9a617-0261-4cee-bb44-138d3ef5d965" 
}

# Helper function to get manager
function Get-Manager {
    param ($UserId)
    try {
        $manager = Get-AzureADUserManager -ObjectId $UserId
        return $manager.DisplayName
    } catch {
        return "No Manager"
    }
}

# Include manager in the output
$E5s = $licensedUsersE5 | Select-Object @{Name="AccountEnabled"; Expression={"False"}}, DisplayName, UserPrincipalName, @{Name="License"; Expression={"E5"}}, @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

$E3s = $licensedUsersE3 | Select-Object @{Name="AccountEnabled"; Expression={"False"}}, DisplayName, UserPrincipalName, @{Name="License"; Expression={"E3"}}, @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

$Both = $licensedUserE5E3 | Select-Object @{Name="AccountEnabled"; Expression={"True"}}, DisplayName, UserPrincipalName, @{Name="License"; Expression={"E5,E3"}}, @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

# Combine all outputs
$All = $E5s + $E3s + $Both

# Display the results in a grid view
$All | Out-GridView


