Connect-ExchangeOnline

$mailboxes = @(
"DL-AAF-NSW All"
"DL-AAF-QLD All"
"DL-AAF-VIC All"
"DL-AAF-SA All"
"DL-AAF-WA All"
)

$Senders = @(
"delivery.pmo@angleauto.com.au"
"cyberseccomms@angleauto.com.au"
"comms@angleauto.com.au"
"jason.murray@angleauto.com.au"
"jason.britt@angleauto.com.au"
"aaron.baxter@angleauto.com.au"
"David.nicholls@angleauto.com.au"
"greg.white@angleauto.com.au"
"larissa.taylor@angleauto.com.au"
"gary.thursby@angleauto.com.au"
"matt.beaman@angleauto.com.au"
"Michele.Norman@angleauto.com.au"
"indira.sertovic@angleauto.com.au"
"emma.raven@angleauto.com.au"
"allyson.carlile@angleauto.com.au"
"ainsley.muir@angleauto.com.au"
"paul.green@angleauto.com.au"
)

foreach ($mailbox in $mailboxes) {

    $mailbox
    Set-DynamicDistributionGroup -Identity $mailbox -AcceptMessagesOnlyFrom $senders


}

