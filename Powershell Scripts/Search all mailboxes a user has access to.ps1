Connect-ExchangeOnline

$MirrorAccountMailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | Get-MailboxPermission -User "Michael Takache" #Replace with user's display name
$SMIdentities = $MirrorAccountMailboxes.identity
$SMIdentities