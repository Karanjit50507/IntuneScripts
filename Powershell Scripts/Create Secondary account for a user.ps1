# Import the AzureAD module
#Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Function to generate a random two-digit number
function Get-RandomTwoDigitNumber {
    return (Get-Random -Minimum 10 -Maximum 99)
}

# Get the existing user's details
$existingUser = Get-AzureADUser -All $true | Select -Property DisplayName, UserPrincipalName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select user who requires access"


# Extract the first name and last name from the display name
$displayNameParts = $existingUser.DisplayName -split ' '
$firstName = $displayNameParts[0]
$lastName = $displayNameParts[-1]

# Generate new account details
$newDisplayName = "$($existingUser.DisplayName) (Secondary)"
$firstInitial = $firstName.Substring(0, 1).tolower()
$lastInitial = $lastName.Substring(0, 1).tolower()
$randomNumbers1 = Get-RandomTwoDigitNumber
$randomNumbers2 = Get-RandomTwoDigitNumber
$newUserName = "$firstInitial$randomNumbers1$lastInitial$randomNumbers2@angleauto.com.au"
$newUPN = $newUserName

# Define a temporary password for the new user
$tempPassword = "P@ssw0rd!$($randomNumbers1+1)$($randomNumbers2+1)"  # You can modify this as needed

# Create the new user
New-AzureADUser -DisplayName $newDisplayName `
                -UserPrincipalName $newUPN `
                -MailNickname $newUPN.Split('@')[0] `
                -PasswordProfile @{ Password = $tempPassword; ForceChangePasswordNextLogin = $true } `
                -AccountEnabled $true

Write-Host "New user created successfully with the following details:" -ForegroundColor Green
Write-Host "Display Name: $newDisplayName"
Write-Host "UPN: $newUPN"
Write-Host "Temporary Password: $tempPassword"
