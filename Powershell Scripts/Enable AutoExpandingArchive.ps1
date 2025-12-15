Connect-ExchangeOnline

Get-OrganizationConfig | FL AutoExpandingArchiveEnabled

Set-OrganizationConfig -AutoExpandingArchive

Get-Mailbox novatedapplicationsupport@angleauto.com.au | FL AutoExpandingArchiveEnabled
Enable-Mailbox novatedapplicationsupport@angleauto.com.au -AutoExpandingArchive

