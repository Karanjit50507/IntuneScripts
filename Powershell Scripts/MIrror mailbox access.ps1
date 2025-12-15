Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

$MirrorAccountMailboxes = 
@(
"Novatedapplicationsupport@angleauto.com.au" ,
"MMSGInterface@angleauto.com.au" ,
"Novatedsettlementsupport@angleauto.com.au" ,
"Smartnovated@angleauto.com.au" ,
"Smartsettlements@angleauto.com.au" ,
"Flatcancellations@angleauto.com.au" 
#"NLI@angleauto.com.au" ,
#"Novatedpayouts@angleauto.com.au" ,
#"Novatedsupport@angleauto.com.au" ,
#"Novatedsalessupport@angleauto.com.au"
)


#Adds new user to all mirror user's shared mailboxes
Write-Output "Adding user to mirror user's shared mailboxes..."
foreach ($SM in $MirrorAccountMailboxes){

$SM
Add-MailboxPermission -Identity $SM -User amy.ford@angleauto.com.au -AccessRights FullAccess -InheritanceType All
}