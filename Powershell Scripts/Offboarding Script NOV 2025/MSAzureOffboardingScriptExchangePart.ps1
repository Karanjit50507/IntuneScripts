param (
    [Parameter (Mandatory = $true)] 
    [String]$Username, #User Email
    [Parameter (Mandatory = $true)] 
    [String]$Manager #Manager Email
)

#Write-Output $Username

#Connecting to Exchange Online, you will need specific permissions for this, they are documented in the ReadMe
Write-Output "Connecting to Exchange Online(Use secondary account)"
Connect-ExchangeOnline

$Mailbox = Get-Mailbox | Where {$_.PrimarySmtpAddress -eq $Username} #Get the offboarding employee's mailbox

#Write your own default out-of-office auto-reply when someone emails the employee that has been terminated. 
$OutOfOfficeBody = @"
Hello,

Thank you for your email. I am no longer with Angle Auto Finance. Please direct all future inquiries to $Manager. 
He/she will be happy to assist you. Your email will not be forwarded automatically.

Thanks!
Angle Auto Finance
"@

#Remove Calendar Events
Remove-CalendarEvents -Identity $Username -CancelOrganizedMeetings -QueryWindowInDays 1825
Write-Output "Cancelled Calendar Events"

#Set Out Of Office
Set-MailboxAutoReplyConfiguration -Identity $Mailbox.Alias -ExternalMessage $OutOfOfficeBody -InternalMessage $OutOfOfficeBody -AutoReplyState Enabled -ExternalAudience All -AutoDeclineFutureRequestsWhenOOF $true

# #Setting mailbox to Shared Mailbox(Upon Request only)
# Write-Output "Setting mailbox to Shared Mailbox"
# Set-Mailbox $Username -Type Shared

# #Assign Manager to Shared Mailbox(Upon Request only)
# Write-Output "Assign Manager to Shared Mailbox"
# Add-MailboxPermission -Identity $Username -User $Manager -AccessRights FullAccess -InheritanceType All

#Hiding user from GAL
Write-Output "Hiding user from GAL"
Set-Mailbox $Username -HiddenFromAddressListsEnabled $true

#Removing users from Distribution Groups
Write-Output "Removing users from Distribution Groups"
$OffboardingDN = (get-mailbox -Identity $Username -IncludeInactiveMailbox).DistinguishedName
Get-Recipient -Filter "Members -eq '$OffboardingDN'" | foreach-object { 
    Write-Output "Removing user from $($_.name)"
    Remove-DistributionGroupMember -Identity $_.ExternalDirectoryObjectId -Member $OffboardingDN -BypassSecurityGroupManagerCheck -Confirm:$false }

#Disconnect from Exchange Online
Write-Output "Disconnecting from Exchange Online"
Disconnect-ExchangeOnline -Confirm:$true
#Write-Output "Disconnected from Exchange Online"