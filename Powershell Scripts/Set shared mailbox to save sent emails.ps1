Connect-ExchangeOnline

Get-mailbox -Identity settlementassist@angleauto.com.au |select MessageCopyForSentAsEnabled

set-mailbox settlementassist@angleauto.com.au -MessageCopyForSentAsEnabled $True
