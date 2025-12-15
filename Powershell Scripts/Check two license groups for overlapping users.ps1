# Connect to Azure AD
Connect-AzureAD

# Option 1: Get by DisplayName if possible
#$group1 = Get-AzureADGroup -All $true | Where-Object { $_.DisplayName -eq "M365 E3 License Group" }
#$group2 = Get-AzureADGroup -All $true | Where-Object { $_.DisplayName -eq "Power BI License Group" }

# Option 2: If you know the object IDs of the groups
$group1 = Get-AzureADGroup -ObjectId "db26ad89-8bb1-4446-ab4d-3e969bf2d362"
$group2 = Get-AzureADGroup -ObjectId "5e06eba7-e0bc-4296-94cd-7df2ae10b460"

# Get members of each group
$group1Members = Get-AzureADGroupMember -all $true -ObjectId $group1.ObjectId | Where-Object { $_.ObjectType -eq "User" }
$group2Members = Get-AzureADGroupMember -All $true -ObjectId $group2.ObjectId | Where-Object { $_.ObjectType -eq "User" }

# Compare users
$group1UPNs = $group1Members | Select-Object -ExpandProperty UserPrincipalName
$group2UPNs = $group2Members | Select-Object -ExpandProperty UserPrincipalName

$usersInBoth = $group1UPNs | Where-Object { $group2UPNs -contains $_ }

# Output
Write-Host "`nUsers in both groups:`n"
$usersInBoth | ForEach-Object { Write-Host $_ }
