# Install required module (uncomment if not already installed)
# Install-Module ExchangeOnlineManagement

# --------------------------AAF ACCOUNT SETUP SCRIPT-------------------------------
# This script assigns licenses, group memberships, and shared mailbox access
# to a new user based on a selected "mirror" user.
# -------------------------------------------------------------------------------

# Connect to AzureAD and Exchange Online
Connect-AzureAD
Connect-ExchangeOnline

# Prompt for user requiring access
$NewAccount = Get-AzureADUser -All $true | Select DisplayName, UserPrincipalName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select user who requires access"
$NewAccount

# Prompt for mirror user
$MirrorAccount = Get-AzureADUser -All $true | Select DisplayName, UserPrincipalName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select user to mirror access"
$MirrorAccount

# Define license and group constants
$e5SkuPartNumber = "SPE_E5"
$groupAAId = "013db407-b96b-4dfd-8818-e65d3d60c4f0" # LG - E5 + Teams Contractors
$groupABId = "db26ad89-8bb1-4446-ab4d-3e969bf2d362" # LG - E5 + Teams Perm
$groupAId = "b0343ce6-d211-490f-b491-d626b89b5b45" # LG - E5 Contractor
$groupBId = "5e06eba7-e0bc-4296-94cd-7df2ae10b460" # LG - E5 Perm
$newUserId = $NewAccount.objectId

# Step 1: Check available E5 licenses
$sku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $e5SkuPartNumber }
$available = $sku.PrepaidUnits.Enabled - $sku.ConsumedUnits

# Step 2: Get disabled users in AAF with E5 licenses
$users = Get-AzureADUser -All $true | Where-Object { $_.CompanyName -eq "Angle Auto Finance" -and $_.AccountEnabled -eq $false } | Sort UserPrincipalName

# Step 3: Get current E5 group members and check for disabled users
$groupMembersA = Get-AzureADGroupMember -ObjectId $groupAId -All $true | Sort UserPrincipalName
$groupMemberIdsA = $groupMembersA | Select-Object -ExpandProperty ObjectId
$usersInGroup = @()

foreach ($user in $users) {
    try {
        $userObj = Get-AzureADUser -ObjectId $user.ObjectId        
        if ($groupMemberIdsA -contains $userObj.ObjectId) {
            Remove-AzureADGroupMember -ObjectId $groupAId -MemberId $userObj.ObjectId
            Write-Host "$($user.DisplayName) removed from LG - E5 Contractor"
            $usersInGroup += $user
        }
    } catch {}
}

$groupMembersB = Get-AzureADGroupMember -ObjectId $groupBId -All $true | Sort UserPrincipalName
$groupMemberIdsB = $groupMembersB | Select-Object -ExpandProperty ObjectId

foreach ($user in $users) {
    try {
        $userObj = Get-AzureADUser -ObjectId $user.ObjectId        
        if ($groupMemberIdsB -contains $userObj.ObjectId) {
            Remove-AzureADGroupMember -ObjectId $groupBId -MemberId $userObj.ObjectId
            Write-Host "$($user.DisplayName) removed from LG - M365 E5"
            $usersInGroup += $user
        }
    } catch {}
}

# Step 4: Determine user type and assign license accordingly
$options = @("Permanent", "Contractor")
$porc = $options | Out-GridView -Title "Permanent or Contractor?" -PassThru

if ($porc -eq "Permanent") {
    if ($available -gt 0) {
        Add-AzureADGroupMember -ObjectId $groupBId -RefObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    } elseif ($usersInGroup.Count -gt 0) {
        Start-Sleep -Seconds 15
        Add-AzureADGroupMember -ObjectId $groupBId -RefObjectId $newUserId
        Write-Host "Reclaimed license - User added to LG - M365 E5."
    } else {
        Write-Host "No E5 licenses found"
        Add-AzureADGroupMember -ObjectId $groupABId -RefObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
    }
} elseif ($porc -eq "Contractor") {
    if ($available -gt 0) {
        Add-AzureADGroupMember -ObjectId $groupAId -RefObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    } elseif ($usersInGroup.Count -gt 0) {
        Start-Sleep -Seconds 15
        Add-AzureADGroupMember -ObjectId $groupAId -RefObjectId $newUserId
        Write-Host "Reclaimed license - User added to LG - M365 E5."
    } else {
        Write-Host "No E5 licenses found"
        Add-AzureADGroupMember -ObjectId $groupAAId -RefObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
    }
}

# Step 5: Mirror shared mailbox permissions
$MirrorAccountMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | 
    Where-Object {
        (Get-MailboxPermission -Identity $_.Identity | Where-Object {
            $_.User -eq $MirrorAccount.UserPrincipalName
        })
    }
$SMIdentities = $MirrorAccountMailboxes.Identity

Write-Output "Adding user to shared mailboxes..."
foreach ($SM in $SMIdentities) {
    $SM
    Add-MailboxPermission -Identity $SM -User $NewAccount.UserPrincipalName -AccessRights FullAccess -InheritanceType All
}

# Step 6: Mirror group memberships, excluding E5 license groups
Write-Output "Adding user to mirror user's groups..."
$excludedGroupIds = @("5e06eba7-e0bc-4296-94cd-7df2ae10b460", "b0343ce6-d211-490f-b491-d626b89b5b45")

$Memberships = Get-AzureADUserMembership -ObjectId $MirrorAccount.ObjectId |
    Where-Object { $_.ObjectType -eq "Group" -and ($excludedGroupIds -notcontains $_.ObjectId) } |
    Sort-Object DisplayName

foreach ($group in $Memberships) {
    try {
        Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $NewAccount.ObjectId
        Write-Host "Added to group: $($group.DisplayName)"
    } catch {
        Write-Warning "Failed to add user to group $($group.DisplayName): $($_.Exception.Message)"
    }
}

# Step 7: Mirror distribution list memberships
Write-Output "Checking distribution groups for mirror user's memberships..."
$allDGs = Get-DistributionGroup -ResultSize Unlimited
$mirrorUPN = $MirrorAccount.UserPrincipalName
$newUPN = $NewAccount.UserPrincipalName

foreach ($dg in $allDGs) {
    try {
        $members = Get-DistributionGroupMember -Identity $dg.Identity -ResultSize Unlimited | Select-Object -ExpandProperty PrimarySmtpAddress
        if ($members -contains $mirrorUPN) {
            Write-Host "Adding $newUPN to distribution group: $($dg.DisplayName)"
            Add-DistributionGroupMember -Identity $dg.Identity -Member $newUPN
        }
    } catch {
        Write-Warning "Failed processing group $($dg.DisplayName): $($_.Exception.Message)"
    }
}

# Step 8: Optional MFA exclusion
$AAFA = @("Yes", "No")
$AAFQ = $AAFA | Out-GridView -PassThru -Title "Does the user need to be added to the MFA exclusion group?"

if ($AAFQ -eq "Yes") {
    Write-Output "Adding user to MFA exclusion group..."
    Add-AzureADGroupMember -objectId "77279c55-6551-4219-878d-63f5bee5acce" -RefObjectId $NewAccount.objectId  # SG - MFA exclusion
}
