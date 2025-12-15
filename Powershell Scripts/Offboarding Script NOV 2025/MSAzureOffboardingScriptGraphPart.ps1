param (
    [Parameter (Mandatory = $true)] 
    [String]$Username, #User Email
    [Parameter (Mandatory = $true)] 
    [String]$Manager #Manager Email
)
#Install-Module Microsoft.Graph -Scope CurrentUser -AllowClobber

#Connecting to Microsoft Graph
Write-Output "Connecting to Microsoft Graph"
# Please activate your Application Administrator role to add graph permissions.
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
Write-Output "Connected to Microsoft Graph"
$User = Get-MgUser -UserId $Username

#Remove user from all groups (owner)
Write-Output "Removing user from Office365 Groups with Owner Role"
Write-Output "Getting groups where user is owner"

$OwnerInGroups = Get-MgGroup | Where-Object {(Get-MgGroupOwner -GroupId $_.Id | foreach {$_.Id}) -contains $User.Id}
foreach ($Group in $OwnerInGroups){
    Remove-MgGroupOwnerByRef -DirectoryObjectId $User.Id -GroupId $Group.Id
    Write-Output "Removing user from $($Group.DisplayName) as owner"
}

#Remove user from all groups (member)
Write-Output "Removing user from Office365 Groups with Member Role"

$MemberInGroups = Get-MgUserMemberOf -UserId $User.Id
foreach ($Group in $MemberInGroups){
    Remove-MgGroupMemberByRef -DirectoryObjectId $User.Id -GroupId $Group.Id
    Write-Output "Removing user from $((Get-MgGroup -GroupId $Group.Id).DisplayName) as member"
}

#Set Sign in Blocked; there are some comments that this command does not seem to work all the time; please test this thoroughly! GA permission is recommended for the runbook to disable privileged users.
Write-Output "Block Sign In"
Update-MgUser -UserId $User.Id -AccountEnabled $false 

#Disconnect Existing Sessions
Write-Output "Revoke Sessions"
Revoke-MgUserSignInSession -UserId $User.Id

#Remove Licenses(You must enable your User administrator role for this to work)
Write-Output "Remove License Details"
$LicenseList = Get-MgUserLicenseDetail -UserId $User.Id
foreach ($License in $LicenseList){
    Set-MgUserLicense -UserId $user.id -AddLicenses @() -RemoveLicenses @($License.skuId)
    Write-Output "Removing license $($License.SkuPartNumber) from user"
}

#Remove Manager
Write-Output "Removed Manager"
Remove-MgUserManagerByRef -UserId $User.Id

# Add user to offboarding group.
$Userid = $User.Id
$params = @{
	"@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/{$userid}"
}

$OffboardGroupId = '2460b26d-a257-4d48-97cc-cf1dc4614a08'
Write-Output "Adding user to offboarding group $OffboardGroupId"

try {
    $isMember = Get-MgGroupMember -GroupId $OffboardGroupId -All | Where-Object { $_.Id -eq $User.Id }
} catch {
    $isMember = $null
}

if (-not $isMember) {
    try {
        New-MgGroupMemberByRef -GroupId $OffboardGroupId -BodyParameter $params
        Write-Output "Added $($User.UserPrincipalName) to offboarding group $OffboardGroupId"
   } catch {
       Write-Output "Failed to add user to offboarding group: $($_.Exception.Message)"
   }
} else {
    Write-Output "User is already a member of offboarding group $OffboardGroupId"
}
#Disconnect
Disconnect-MgGraph
Write-Output "Disconnected"