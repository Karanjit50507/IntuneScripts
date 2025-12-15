# Connect to Exchange Online if not already connected
# Ensure ExchangeOnlineManagement module is installed and imported

# Connect if not connected
if (-not (Get-PSSession | Where-Object {$_.ComputerName -like "*outlook.office365.com*"})) {
    Connect-ExchangeOnline -
}

# Replace with the target mailbox or use a variable
$MailboxIdentity = "Wholesale@angleauto.com.au"

# Get mailbox archive status
$mailbox = Get-Mailbox -Identity $MailboxIdentity

# Get auto-expanding archive setting (only works if archive is enabled)
$archiveConfig = Get-Mailbox -Identity $MailboxIdentity | Select-Object ArchiveStatus, AutoExpandingArchiveEnabled

# Output results
if ($archiveConfig.ArchiveStatus -eq "Active") {
    Write-Host "Archive mailbox is ENABLED for $MailboxIdentity" -ForegroundColor Green

    if ($archiveConfig.AutoExpandingArchiveEnabled -eq $true) {
        Write-Host "Auto-Expanding Archive is ENABLED." -ForegroundColor Green
    } else {
        Write-Host "Auto-Expanding Archive is DISABLED." -ForegroundColor Yellow
    }
} else {
    Write-Host "Archive mailbox is NOT enabled for $MailboxIdentity" -ForegroundColor Red
}

# Enable archive mailbox if not already enabled
$mailbox = Get-Mailbox -Identity $MailboxIdentity
if ($mailbox.ArchiveStatus -ne "Active") {
    Enable-Mailbox $MailboxIdentity -AutoExpandingArchive
    Write-Host "Archive mailbox has been enabled for $MailboxIdentity" -ForegroundColor Green
    Start-Sleep -Seconds 5 # brief pause before continuing
}

# Enable auto-expanding archive
Write-Host "Auto-Expanding Archive has been ENABLED for $MailboxIdentity" -ForegroundColor Green


