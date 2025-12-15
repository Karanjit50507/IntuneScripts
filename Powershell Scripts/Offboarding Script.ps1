#--------------------------AAF ACCOUNT-------------------------------
#--------------------------------------------------------------------

Connect-AzureAD
Connect-ExchangeOnline

#User who is being offboarded
$OFFAccount = Get-AzureADUser -All $true | Select -Property DisplayName, UserPrincipalName, ObjectId, state | Sort DisplayName | Out-GridView -PassThru -Title "Select user who requires offboarding"
$OFFAccount

Start-Sleep -Seconds 1.5

#Disable user, Remove State and Company name
Set-AzureADUser -ObjectId $OFFAccount.objectId -AccountEnabled $false -State " " -CompanyName " "
Write-Output "Account disabled, user removed from All Employee and State dyanmic DLs"
Get-AzureADUser -ObjectId $OFFAccount.objectId |Select DisplayName, AccountEnabled, State, CompanyName

#Remove manager
Remove-AzureADUserManager -ObjectId $OFFAccount.objectId
Write-Output "User removed from Teams Org Chart"

#Get user's shared mailboxes
$OFFAccountMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | Get-MailboxPermission -User $OFFAccount.DisplayName #Get-EXOMailbox -ResultSize Unlimited | Get-EXOMailboxPermission -Identity $_.Identity | Where {$_.User -eq $MirrorAccount.UserPrincipalName}
$SMIdentities = $OFFAccountMailboxes.identity

#Remove user from all shared mailboxes
Write-Output "Removing user from all shared mailboxes..."
foreach ($SM in $SMIdentities){

$SM
Remove-MailboxPermission -Identity $SM -User $OFFAccount.Displayname -AccessRights FullAccess -InheritanceType All -Confirm:$false

}

#Remove user from all DLs
$DistributionGroups= Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | foreach {$_.PrimarySmtpAddress}) -contains $OFFAccount.UserPrincipalName}
$DistributionGroupsNames = $DistributionGroups.DisplayName
Write-Output "Removing user from all DLs"
foreach ($DL in $DistributionGroupsNames) {

$DL
Remove-DistributionGroupMember -Identity $DL -Member $OFFAccount.UserPrincipalName

}


#Check is user still requires license
$AAFA = @("Yes","No")
$AAFQ = $AAFA | Out-GridView -PassThru -Title "Has the user's phone been wiped?"

if$AAFQ -eq "Yes"

#Remove user from license group
Write-Output "Removing user from License group..."
Remove-AzureADGroupMember -objectId "5e06eba7-e0bc-4296-94cd-7df2ae10b460" -MemberId $OFFaccount.objectId  #LG - M365 E5

# Get User's Group Memberships
$Memberships = Get-AzureADUserMembership -ObjectId $OFFAccount.ObjectId | Where-Object { $_.ObjectType -eq "Group" } | Sort DisplayName

# Remove user from all SG groups
Write-Output "Removing user from all SG groups..."
foreach ($group in $Memberships) {
    Write-Output "Removing from: $($group.DisplayName)"
    Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $OFFAccount.ObjectId
}

# Add user to "User Offboarding Group"
Write-Output "Adding user to 'User Offboarding Group'..."
Add-AzureADGroupMember -ObjectId "2460b26d-a257-4d48-97cc-cf1dc4614a08" -RefObjectId $OFFAccount.ObjectId
