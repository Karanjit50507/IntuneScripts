
Connect-ExchangeOnline


$Mailboxes = 
@(
"crm_no_reply_prod@angleauto.com.au"
"Crm_no_reply_dev@angleauto.com.au"
"Crm_no_reply_sit@angleauto.com.au"
"Crm_no_reply_uat@angleauto.com.au"
)

$Users = 
@(
"esther.ayerakwa@angleauto.com.au"
"lordan.lim@angleauto.com.au"
"mardith.pascua@angleauto.com.au"
"cesar.castaneda@angleauto.com.au"
"patrick.ng@angleauto.com.au"
)


foreach ($SM in $Mailboxes){
Write-Output "Updating $SM..."
    foreach ($User in $Users){

    $User
    Add-MailboxFolderPermission -Identity "$($SM):\inbox" -User $user -AccessRights Reviewer
    }
}

get-mailboxfolderpersmission 