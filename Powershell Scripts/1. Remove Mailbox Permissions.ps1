# Connect to Exchange Online
Connect-ExchangeOnline

# Define the target user whose access you want to check/remove
$User = "remi.noubel@angleauto.com.au"

# Get all mailboxes where the user has FullAccess permissions
$Mailboxes = Get-Mailbox -ResultSize Unlimited | Get-MailboxPermission | Where-Object {
    $_.User.ToString() -eq $User -and $_.AccessRights -contains "FullAccess"
}

# Display the mailboxes for review
# $Mailboxes | Select Identity, User, AccessRights

# Remove FullAccess permissions from each mailbox
foreach ($Mailbox in $Mailboxes) {
    Remove-MailboxPermission -Identity $Mailbox.Identity -User $User -AccessRights FullAccess -Confirm:$false
    Write-Host "Removed FullAccess from $($Mailbox.Identity)"
}

