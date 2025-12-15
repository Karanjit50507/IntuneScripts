Connect-AzureAD

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"


# User who is being offboarded
$OFFAccount = Get-MgUser -All | 
    Select-Object DisplayName, UserPrincipalName, Id, AccountEnabled | 
    Sort-Object DisplayName | 
    Out-GridView -PassThru -Title "Select user who requires offboarding"
$OFFAccount

# Get User's Group Memberships (only groups)
$Memberships = Get-MgUserMemberOf -UserId $OFFAccount.Id | 
    Where-Object { $_.ODataType -eq "#microsoft.graph.group" } | 
    Sort-Object DisplayName

# Remove user from all SG groups
Write-Output "Removing user from all SG groups..."

foreach ($group in $Memberships) {
    Write-Output "Removing from: $($group.DisplayName)"
    Remove-MgGroupMemberByRef -GroupId $group.Id -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($OFFAccount.Id)" }
}


# Add user to "User Offboarding Group"
    Write-Output "Adding user to 'User Offboarding Group'..."
    New-MgGroupMemberByRef -GroupId "2460b26d-a257-4d48-97cc-cf1dc4614a08" -BodyParameter @{ "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($OFFAccount.Id)" }


    