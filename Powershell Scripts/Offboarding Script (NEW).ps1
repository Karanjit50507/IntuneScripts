#OFFBOARDING SCRIPT 2025

Connect-AzureAD
Connect-ExchangeOnline
Connect-MgGraph -Scopes "User.Read.All"

# User who is being offboarded
$OFFAccount = Get-MgUser -All | 
    Select-Object DisplayName, UserPrincipalName, Id, AccountEnabled | 
    Sort-Object DisplayName | 
    Out-GridView -PassThru -Title "Select user who requires offboarding"
$OFFAccount

Start-Sleep -Seconds 1.5

# Disable user, clear State and Company name
Update-MgUser -UserId $OFFAccount.Id -AccountEnabled:$false -State " " -CompanyName " "
Write-Output "Account disabled, user removed from All Employee and State dynamic DLs"

Get-MgUser -UserId $OFFAccount.Id | Select-Object DisplayName, AccountEnabled, State, CompanyName

# Remove manager
Remove-MgUserManager -UserId $OFFAccount.Id
Write-Output "User removed from Teams Org Chart"

# Get user's shared mailboxes (Exchange Online cmdlets still apply)
$OFFAccountMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | 
    Get-MailboxPermission -User $OFFAccount.DisplayName
$SMIdentities = $OFFAccountMailboxes.Identity

# Remove user from all shared mailboxes
Write-Output "Removing user from all shared mailboxes..."
foreach ($SM in $SMIdentities) {
    $SM
    Remove-MailboxPermission -Identity $SM -User $OFFAccount.DisplayName -AccessRights FullAccess -InheritanceType All -Confirm:$false
}

# Remove user from all DLs (Exchange Online cmdlets still apply)
$DistributionGroups = Get-DistributionGroup | Where-Object { 
    (Get-DistributionGroupMember $_.Name | ForEach-Object { $_.PrimarySmtpAddress }) -contains $OFFAccount.UserPrincipalName
}
$DistributionGroupsNames = $DistributionGroups.DisplayName
Write-Output "Removing user from all DLs"
foreach ($DL in $DistributionGroupsNames) {
    $DL
    Remove-DistributionGroupMember -Identity $DL -Member $OFFAccount.UserPrincipalName
}

# Check if user still requires license
$AAFA = @("Yes","No")
$AAFQ = $AAFA | Out-GridView -PassThru -Title "Has the user's phone been wiped?"

if ($AAFQ -eq "Yes") {
    # Remove user from license group
    Write-Output "Removing user from License group..."
    Remove-MgGroupMember -GroupId "5e06eba7-e0bc-4296-94cd-7df2ae10b460" -MemberId $OFFAccount.Id  # LG - M365 E5

    # Get User's Group Memberships
    $Memberships = Get-MgUserMemberOf -UserId $OFFAccount.Id | 
        Where-Object { $_.ODataType -eq "#microsoft.graph.group" } | 
        Sort-Object DisplayName

    # Remove user from all SG groups
    Write-Output "Removing user from all SG groups..."
    foreach ($group in $Memberships) {
        Write-Output "Removing from: $($group.DisplayName)"
        Remove-MgGroupMember -GroupId $group.Id -MemberId $OFFAccount.Id
    }

    # Add user to "User Offboarding Group"
    Write-Output "Adding user to 'User Offboarding Group'..."
    Add-MgGroupMember -GroupId "2460b26d-a257-4d48-97cc-cf1dc4614a08" -DirectoryObjectId $OFFAccount.Id
}
