# Install required module if not already installed
Install-Module -Name AzureAD
Connect-AzureAD

$filepath = "C:\Temp\user-groups.csv"

# Load emails from CSV
$emails = Import-Csv -Path $filepath | Select-Object -ExpandProperty Email

# Check account status
foreach ($email in $emails) {
    $user = Get-AzureADUser -ObjectId $email -ErrorAction SilentlyContinue
    if ($user) {
        if ($user.AccountEnabled -eq $false) {
            Write-host "$email is DISABLED" -ForegroundColor Red
        } else {
            Write-host "$email is ENABLED" -ForegroundColor Green
        }
    } else {
        Write-Output "$email not found in Azure AD"
    }
}