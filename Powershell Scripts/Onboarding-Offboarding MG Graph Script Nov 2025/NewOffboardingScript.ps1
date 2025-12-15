# Install required modules if not already installed
# Install-Module Microsoft.Graph -Scope CurrentUser
# Install-Module ExchangeOnlineManagement -Scope CurrentUser

# --------------------------AAF ACCOUNT DIACTIVATION SCRIPT (Graph)-------------------------------
# This script un-assigns licenses, group memberships, and shared mailbox access
# -------------------------------------------------------------------------------

#Connecting to Microsoft Graph
Write-Output "Connecting to Microsoft Graph"
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"
Write-Output "Connected to Microsoft Graph"



# Select user to be offboarded
$Username = Get-MgUser -All | Select DisplayName, UserPrincipalName, Id | Sort DisplayName | Out-GridView -PassThru -Title "Select user to be offboarded"
$Username

# Only required if you want to provide a manager contact in the out of office message, disabled user mailbox permissions etc.
# $Manager = Get-MgUser -All | Select DisplayName, UserPrincipalName, Id | Sort DisplayName | Out-GridView -PassThru -Title "Select user to mirror access"
# $Manager

Write-Output "Disabled User:" $Username.UserPrincipalName
$User = Get-MgUser -UserId $Username.Id

#Remove user from all groups (owner)
Write-Output "Removing user from Office365 Groups with Owner Role"
Write-Output "Getting groups where user is owner"

$OwnerInGroups = Get-MgUserOwnedObject -UserId $User.Id
foreach ($Group in $OwnerInGroups){
    Remove-MgGroupOwnerByRef -GroupId $Group.Id -DirectoryObjectId $User.Id
    #Remove-MgGroupOwnerByRef -DirectoryObjectId $User.Id -GroupId $Group.Id
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
Update-MgUser -UserId $User.Id -AccountEnabled:$false

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
#Disconnect-MgGraph
#Write-Output "Disconnected"

#-----------------------------------------------------------------------------------------------------------------#
#Part 2

#Connecting to Exchange Online, you will need specific permissions for this, they are documented in the ReadMe
Write-Output "Connecting to Exchange Online"
Connect-ExchangeOnline

$Mailbox = Get-Mailbox | Where {$_.PrimarySmtpAddress -eq $Username.UserPrincipalName} #Get the offboarding employee's mailbox

#Write your own default out-of-office auto-reply when someone emails the employee that has been terminated. 
$OutOfOfficeBody = @"
Hello,

Thank you for your email. I am no longer with Angle Auto Finance. Please direct all future inquiries to $Manager. 
He/she will be happy to assist you. Your email will not be forwarded automatically.

Thanks!
Angle Auto Finance
"@

#Remove Calendar Events
#Remove-CalendarEvents -Identity $Username.UserPrincipalName -CancelOrganizedMeetings -QueryWindowInDays 1825
#Write-Output "Cancelled Calendar Events"

#Set Out Of Office
#Set-MailboxAutoReplyConfiguration -Identity $Mailbox.Alias -ExternalMessage $OutOfOfficeBody -InternalMessage $OutOfOfficeBody -AutoReplyState Enabled -ExternalAudience All -AutoDeclineFutureRequestsWhenOOF $true

# #Setting mailbox to Shared Mailbox(Upon Request only)
# Write-Output "Setting mailbox to Shared Mailbox"
# Set-Mailbox $Username -Type Shared

# #Assign Manager to Shared Mailbox(Upon Request only)
# Write-Output "Assign Manager to Shared Mailbox"
# Add-MailboxPermission -Identity $Username -User $Manager -AccessRights FullAccess -InheritanceType All

#Hiding user from GAL
Write-Output "Hiding user from GAL"
Set-Mailbox $Username.UserPrincipalName -HiddenFromAddressListsEnabled $true

#Removing users from Distribution Groups
Write-Output "Removing users from Distribution Groups"
$OffboardingDN = (get-mailbox -Identity $Username.UserPrincipalName -IncludeInactiveMailbox).DistinguishedName
Get-Recipient -Filter "Members -eq '$OffboardingDN'" | foreach-object { 
    Write-Output "Removing user from $($_.name)"
    Remove-DistributionGroupMember -Identity $_.ExternalDirectoryObjectId -Member $OffboardingDN -BypassSecurityGroupManagerCheck -Confirm:$false }

#Disconnect from Exchange Online
# Write-Output "Disconnecting from Exchange Online"
# Disconnect-ExchangeOnline
#Write-Output "Disconnected from Exchange Online"
