# Ensure BurntToast is installed
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
}

# Import the module
Import-Module BurntToast

# Show the notification
New-BurntToastNotification -Text "Please Restart your Machine", "Your computer has been on for more than 7 days, please reboot when possible"