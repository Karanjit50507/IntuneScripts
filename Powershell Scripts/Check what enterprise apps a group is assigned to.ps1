# Connect to Azure AD
Connect-AzureAD

# Set the group display name (or use ObjectId if preferred)
$groupDisplayName = "LG - M365 E5 Contractors"

# Get group object
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupDisplayName'"

if (-not $group) {
    Write-Host "Group '$groupDisplayName' not found." -ForegroundColor Red
    return
}

$groupId = $group.ObjectId

# Get all service principals (enterprise apps)
$servicePrincipals = Get-AzureADServicePrincipal -All $true

# List to collect matches
$matchedApps = @()

foreach ($sp in $servicePrincipals) {
    $appRoles = Get-AzureADServiceAppRoleAssignment -ObjectId $sp.ObjectId

    foreach ($assignment in $appRoles) {
        if ($assignment.PrincipalId -eq $groupId) {
            $matchedApps += [PSCustomObject]@{
                ApplicationName = $sp.DisplayName
                ApplicationId   = $sp.AppId
                ServicePrincipalId = $sp.ObjectId
            }
            break
        }
    }
}

if ($matchedApps.Count -eq 0) {
    Write-Host "No enterprise applications found with group '$groupDisplayName' assigned." -ForegroundColor Yellow
} else {
    Write-Host "Enterprise applications with group '$groupDisplayName' assigned:`n" -ForegroundColor Green
    $matchedApps | Format-Table ApplicationName, ApplicationId, ServicePrincipalId
}