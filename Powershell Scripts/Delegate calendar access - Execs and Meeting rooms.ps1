Connect-ExchangeOnline

Get-Mailbox | % { Get-MailboxFolderPermission (($_.PrimarySmtpAddress.ToString())+”:\Calendar”) -User michele.norman@angleauto.com.au -ErrorAction SilentlyContinue} | select Identity,User,AccessRights

Get-MailboxFolderPermission

$User = "larissa.taylor@angleauto.com.au"

Add-MailboxFolderPermission -Identity jason.britt@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity sam.woods@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity david.nicholls@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity greg.white@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity aaron.baxter@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity allyson.carlile@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity craig.neville@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate

#Room access

Add-MailboxFolderPermission -Identity ADE-MeetingRoom01@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity BNE-Boardroom@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity BNE-MeetingRoom02@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity BNE-MeetingRoom03@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity Mel-Boardroom@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity Mel-MeetingRoom02@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity Mel-MeetingRoom03@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity PER-MeetingRoom01@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.02@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.01@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.03@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.04@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.09@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate
Add-MailboxFolderPermission -Identity SYD-MeetingRoom-L23.10@angleauto.com.au:\Calendar -User $User -AccessRights Editor -SharingPermissionFlags Delegate




























