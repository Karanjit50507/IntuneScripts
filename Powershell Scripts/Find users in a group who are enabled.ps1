Connect-AzureAD

$groupnameObjID = "b0343ce6-d211-490f-b491-d626b89b5b45"
$users = Get-AzureADGroupMember -ObjectId $groupnameObjID -All $true 
$userupn = $users.objectid


foreach ($activeusers in $userupn) { Get-AzureADUser -objectId $activeusers  | WHERE {$_.accountEnabled -eq $false}  | select DisplayName, UserPrincipalName, accountEnabled } 