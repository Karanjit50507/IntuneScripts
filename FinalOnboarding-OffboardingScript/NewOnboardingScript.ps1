# Install required modules if not already installed
# Install-Module Microsoft.Graph -Scope CurrentUser
# Install-Module ExchangeOnlineManagement -Scope CurrentUser

# --------------------------AAF ACCOUNT SETUP SCRIPT (Graph)-------------------------------
# This script assigns licenses, group memberships, and shared mailbox access
# to a new user based on a selected "mirror" user.
# -------------------------------------------------------------------------------

# Connect to Microsoft Graph(Primary account)(Please ensure the account has sufficient permissions Role required: Application Administrator)
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Directory.ReadWrite.All"

# Connect to Exchange Online (still needed for mailbox permissions)
#Connect-ExchangeOnline

# Prompt for user requiring access
$NewAccount = Get-MgUser -All | Select DisplayName, UserPrincipalName, Id | Sort DisplayName | Out-GridView -PassThru -Title "Select user who requires access"
$NewAccount

# Prompt for mirror user
$MirrorAccount = Get-MgUser -All | Select DisplayName, UserPrincipalName, Id | Sort DisplayName | Out-GridView -PassThru -Title "Select user to mirror access"
$MirrorAccount

# Define license and group constants
$e5SkuPartNumber = "SPE_E5"
$groupAAId = "013db407-b96b-4dfd-8818-e65d3d60c4f0" # LG - E5 + Teams Contractors
$groupABId = "db26ad89-8bb1-4446-ab4d-3e969bf2d362" # LG - E5 + Teams Perm
$groupAId = "b0343ce6-d211-490f-b491-d626b89b5b45" # LG - E5 Contractor
$groupBId = "5e06eba7-e0bc-4296-94cd-7df2ae10b460" # LG - E5 Perm
$newUserId = $NewAccount.Id

# Step 1: Check available E5 licenses
$sku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq $e5SkuPartNumber }
$available = $sku.PrepaidUnits.Enabled - $sku.ConsumedUnits
Write-Host "$available E5 licenses found"

# Step 2: Get disabled users in AAF with E5 licenses
$users = Get-MgUser -All | Where-Object { $_.CompanyName -eq "Angle Auto Finance" -and $_.AccountEnabled -eq $false } | Sort UserPrincipalName

# Step 3: Get current E5 group members and check for disabled users
$groupMembersA = Get-MgGroupMember -GroupId $groupAId -All | Sort UserPrincipalName
$groupMemberIdsA = $groupMembersA.Id
$usersInGroup = @()

foreach ($user in $users) {
    try {
        if ($groupMemberIdsA -contains $user.Id) {
            Remove-MgGroupMember -GroupId $groupAId -MemberId $user.Id
            Write-Host "$($user.DisplayName) removed from LG - E5 Contractor"
            $usersInGroup += $user
        }
    } catch {}
}

$groupMembersB = Get-MgGroupMember -GroupId $groupBId -All | Sort UserPrincipalName
$groupMemberIdsB = $groupMembersB.Id

foreach ($user in $users) {
    try {
        if ($groupMemberIdsB -contains $user.Id) {
            Remove-MgGroupMember -GroupId $groupBId -MemberId $user.Id
            Write-Host "$($user.DisplayName) removed from LG - M365 E5"
            $usersInGroup += $user
        }
    } catch {}
}

If ($usersInGroup.count -lt 1){
    Write-host "No disabled users found in license groups"
}

# Step 4: Determine user type and assign license accordingly
$options = @("Permanent", "Contractor")
$porc = $options | Out-GridView -Title "Permanent or Contractor?" -PassThru

if ($porc -eq "Permanent") {
    if ($available -gt 0) {
        New-MgGroupMember -GroupId $groupBId -DirectoryObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    } 
    elseif ($usersInGroup.Count -gt 0) {
        Start-Sleep -Seconds 15
        New-MgGroupMember -GroupId $groupBId -DirectoryObjectId $newUserId
        Write-Host "Reclaimed license - User added to LG - M365 E5."
    } 
    else {
        Write-Host "No E5 licenses found"
        New-MgGroupMember -GroupId $groupABId -DirectoryObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
    }
} elseif ($porc -eq "Contractor") {
    if ($available -gt 0) {
        New-MgGroupMember -GroupId $groupAId -DirectoryObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    } 
    elseif ($usersInGroup.Count -gt 0) {
        Start-Sleep -Seconds 15
        New-MgGroupMember -GroupId $groupAId -DirectoryObjectId $newUserId
        Write-Host "Reclaimed license - User added to LG - M365 E5."
    } 
    else {
        Write-Host "No E5 licenses found"
        New-MgGroupMember -GroupId $groupAAId -DirectoryObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
    }
}

# Step 6: Mirror group memberships, excluding E5 license groups
Write-Output "Adding user to mirror user's groups..."
$excludedGroupIds = @($groupBId, $groupAId)


# $Memberships = Get-MgUserMemberOf -UserId $MirrorAccount.Id |
#     Where-Object { $_.ODataType -eq "#microsoft.graph.group" -and ($excludedGroupIds -notcontains $_.Id) } |
#     Sort-Object DisplayName


$rawMemberships = Get-MgUserMemberOf -UserId $MirrorAccount.Id |
    Where-Object { ($excludedGroupIds -notcontains $_.Id) } |
    Sort-Object DisplayName

# Expand each group to get full properties
$Memberships = foreach ($grp in $rawMemberships) {
    $fullGroup = Get-MgGroup -GroupId $grp.Id -Property Id,DisplayName,GroupTypes,MembershipRule

    # Only include if group is assigned (no dynamic membership rule)
    if (-not $fullGroup.MembershipRule -and ($fullGroup.GroupTypes -notcontains "DynamicMembership")) {
        $fullGroup
    }
}

# # Expand each group to get full properties
# $Memberships = foreach ($grp in $rawMemberships) {
#     $fullGroup = Get-MgGroup -GroupId $grp.Id -Property Id,DisplayName,GroupTypes,MembershipRule

#     # Only include if group is assigned (no dynamic membership rule)
#     if (-not $fullGroup.MembershipRule -and ($fullGroup.GroupTypes -notcontains "DynamicMembership") -and ( $fullGroup.GroupTypes -contains "Unified") ) {
#         $fullGroup
#     }
# }


# Sort the final list
#$Memberships = $Memberships | Sort-Object DisplayName

foreach ($group in $Memberships) {
    try {
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $NewAccount.Id
        Write-Host "Added to group: $($group.DisplayName)"
    } catch {
        Write-Warning "Failed to add user to group $($group.DisplayName): $($_.Exception.Message)"
    }
}

#Discconect-MgGraph
#------------------------------------------------------------------------------------------------------------------------------------------------------#
# Exchange Online parts below


Connect-ExchangeOnline # Secondary Account(Please ensure the account has sufficient permissions Role required: Exchange Administrator)

# Step 5: Mirror shared mailbox permissions (ExchangeOnline still required)
$MirrorAccountMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | 
    Where-Object {
        (Get-MailboxPermission -Identity $_.Identity | Where-Object {
            $_.User -eq $MirrorAccount.UserPrincipalName
        })
    }
$SMIdentities = $MirrorAccountMailboxes.Identity

Write-Output "Adding user to shared mailboxes..."
foreach ($SM in $SMIdentities) {
    Add-MailboxPermission -Identity $SM -User $NewAccount.UserPrincipalName -AccessRights FullAccess -InheritanceType All
    Write-Output "Added $($NewAccount.UserPrincipalName) to $SM"
}

# Step 7: Mirror distribution list memberships (ExchangeOnline still required)
Write-Output "Checking distribution groups for mirror user's memberships..."
$allDGs = Get-DistributionGroup -ResultSize Unlimited
$mirrorUPN = $MirrorAccount.UserPrincipalName
$newUPN = $NewAccount.UserPrincipalName

foreach ($dg in $allDGs) {
    try {
        $members = Get-DistributionGroupMember -Identity $dg.Identity -ResultSize Unlimited | Select-Object -ExpandProperty PrimarySmtpAddress
        if ($members -contains $mirrorUPN) {
            Write-Host "Adding to $($dg.DisplayName)"
            Add-DistributionGroupMember -Identity $dg.Identity -Member $newUPN
        }
    } catch {
        Write-Warning "Failed processing group $($dg.DisplayName): $($_.Exception.Message)"

    }
}

# Disconnect-ExchangeOnline
#------------------------------------------------------------------------------------------------------------------------------------------------------#