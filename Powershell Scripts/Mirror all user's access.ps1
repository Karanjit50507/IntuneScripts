Connect-AzureAD
Connect-ExchangeOnline

#User who's access needs to be mirrored
$MirrorAccount =  Get-AzureADUser -All $true | Select -Property DisplayName, UserPrincipalName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select user to mirror access"
$MirrorAccount

#User who requires access
$NewAccount = Get-AzureADUser -All $true | Select -Property DisplayName, UserPrincipalName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select user who requires access"
$NewAccount

#--------------------------------------------------------------------

#Get User's Group Memberships
$Memberships = Get-AzureADUserMembership -ObjectId $MirrorAccount.ObjectId | Where-object { $_.ObjectType -eq "Group" } | SORT DisplayName

foreach ($groups in $Memberships){

$groups.DisplayName
Add-AzureADGroupMember -objectId $groups.objectId -RefObjectId $NewAccount.ObjectId

}

