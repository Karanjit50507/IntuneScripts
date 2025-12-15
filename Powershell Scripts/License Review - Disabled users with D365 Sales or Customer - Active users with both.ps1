Connect-AzureAD

$DSales = "1e1a282c-9c54-43a2-9310-98ef728faace"
$DCust = "749742bf-0d37-4158-a120-33567104deeb"

# Get disabled and enabled users
$users = Get-AzureADUser -All $true -Filter "AccountEnabled eq false"
$usersEnabled = Get-AzureADUser -All $true -Filter "AccountEnabled eq true"

# Refine list to users with the E5 SKU assigned to them
$licensedUsersDSales = $users | Where-Object { $_.AssignedLicenses.SkuID -contains $DSales }

# Refine list to users with the E3 SKU assigned to them
$licensedUsersDCust = $users | Where-Object { $_.AssignedLicenses.SkuID -contains $DCust }

# Refine list to users with both E5 and E3 SKUs assigned to them
$licensedUserDSalesCust = $usersEnabled | Where-Object { 
    $_.AssignedLicenses.SkuID -contains $DSales -and 
    $_.AssignedLicenses.SkuID -contains $DCust
}

# Helper function to get manager
function Get-Manager {
    param ($UserId)
    try {
        $manager = Get-AzureADUserManager -ObjectId $UserId
        return $manager.DisplayName
    } catch {
        return $null  # return null instead of "No Manager" if desired
    }
}

# Safely select and handle potential nulls
$DSalesUsers = $licensedUsersDSales | Select-Object `
    @{Name="AccountEnabled"; Expression={"False"}}, `
    @{Name="DisplayName"; Expression={ $_.DisplayName -as [string] }}, `
    @{Name="UserPrincipalName"; Expression={ $_.UserPrincipalName -as [string] }}, `
    @{Name="License"; Expression={"D365 Sales"}}, `
    @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

$DCustsUsers = $licensedUsersDCust | Select-Object `
    @{Name="AccountEnabled"; Expression={"False"}}, `
    @{Name="DisplayName"; Expression={ $_.DisplayName -as [string] }}, `
    @{Name="UserPrincipalName"; Expression={ $_.UserPrincipalName -as [string] }}, `
    @{Name="License"; Expression={"D365 Customer"}}, `
    @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

$Both = $licensedUserDSalesCust | Select-Object `
    @{Name="AccountEnabled"; Expression={"True"}}, `
    @{Name="DisplayName"; Expression={ $_.DisplayName -as [string] }}, `
    @{Name="UserPrincipalName"; Expression={ $_.UserPrincipalName -as [string] }}, `
    @{Name="License"; Expression={"D365 Sales/Customer"}}, `
    @{Name="Manager"; Expression={ Get-Manager $_.ObjectId }}

# Combine all outputs
$All = @()
$All += $DSalesUsers
$All += $DCustUsers
$All += $Both

# Display the results in a grid view
if (-not $All){
    Write-Host "No available licenses found" -ForegroundColor Red
    }else{
    $All | Out-GridView
    }
