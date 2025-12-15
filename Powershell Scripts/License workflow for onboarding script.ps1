# Connect to Azure AD
Connect-AzureAD

# Define constants
$e5SkuPartNumber = "SPE_E5"
$groupAAId = "013db407-b96b-4dfd-8818-e65d3d60c4f0" #LG - E5 + Teams Contractors
$groupABId = "db26ad89-8bb1-4446-ab4d-3e969bf2d362" #LG - E5 + Teams Perm
$groupAId = "b0343ce6-d211-490f-b491-d626b89b5b45" #LG - E5 Contractor
$groupBId = "5e06eba7-e0bc-4296-94cd-7df2ae10b460" #LG - E5 Perm
$newUserId = "<USER-OBJECT-ID>"

# 1. Check for available E5 licenses
$sku = Get-AzureADSubscribedSku | Where-Object { $_.SkuPartNumber -eq $e5SkuPartNumber }

$available = $sku.PrepaidUnits.Enabled - $sku.ConsumedUnits

# 2. Get all disabled users from the org with E5 license
$users = Get-AzureADUser -All $true | Where-Object {$_.CompanyName -eq "Angle Auto Finance" -and $_.AccountEnabled -eq $false} | Sort UserPrincipalName

# 3. Get group members and extract ObjectIds
$groupMembersA = Get-AzureADGroupMember -ObjectId $groupAId -All $true | Sort UserPrincipalName
$groupMemberIdsA = $groupMembersA | Select-Object -ExpandProperty ObjectId

# 4. Loop through users and remove if in group
$usersInGroup = @()

foreach ($user in $users) {
    try {
        $userObj = Get-AzureADUser -ObjectId $user.ObjectId        
        if ($groupMemberIdsA -contains $userObj.ObjectId) {
            Remove-AzureADGroupMember -ObjectId $groupAId -MemberId $userObj.ObjectId
            Write-Host "$($user.DisplayName) has been removed from LG - E5 Contractor group"
            $usersInGroup += $user
        }
    } catch {
    } v
}


$groupMembersB = Get-AzureADGroupMember -ObjectId $groupBId -All $true | Sort UserPrincipalName
$groupMemberIdsB = $groupMembersB | Select-Object -ExpandProperty ObjectId

foreach ($user in $users) {
    try {
        $userObj = Get-AzureADUser -ObjectId $user.ObjectId        
        if ($groupMemberIdsB -contains $userObj.ObjectId) {
            Remove-AzureADGroupMember -ObjectId $groupBId -MemberId $userObj.ObjectId
            Write-Host "$($user.DisplayName) has been removed from LG - M365 E5 group"
            $usersInGroup += $user
        }
    } catch {
    }
}

$options = @(
"Permanant",
"Contractor")

$porc = $options | Out-GridView -Title "Permanant or Contractor?" -PassThru

If ($porc -eq "Permanant") {
    if ($available -gt 0) {
        Add-AzureADGroupMember -ObjectId $groupBId -RefObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    }elseif ($userInGroup.Count -gt 0){
        Start-Sleep -Seconds 15
        Add-AzureADGroupMember -ObjectId $groupBId -RefObjectId $newUserId
        Write-Host "E5 license found previous assigned to disabled user"
        Write-Host "User added to LG - M365 E5."
    }else{
        Write-Host "No E5 licenses found"
        Add-AzureADGroupMember -ObjectId $groupABId -RefObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
        }
}elseif ($porc -eq "Contractor"){
    if ($available -gt 0) {
        Add-AzureADGroupMember -ObjectId $groupAId -RefObjectId $newUserId
        Write-Host "E5 license available - User added to LG - M365 E5."
    }elseif ($userInGroup.Count -gt 0){
        Start-Sleep -Seconds 15
        Add-AzureADGroupMember -ObjectId $groupAId -RefObjectId $newUserId
        Write-Host "E5 license found previous assigned to disabled user"
        Write-Host "User added to LG - M365 E5."
    }else{
        Write-Host "No E5 licenses found"
        Add-AzureADGroupMember -ObjectId $groupAAId -RefObjectId $newUserId
        Write-Host "User added to LG - M365 E5 + Teams."
    }
}











