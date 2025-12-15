# Connect to Azure AD
Connect-AzureAD


$SoftwareName = "Postman" # <----- Replace "Postman" with the software name


# Base name for the group
$BaseName = "ADG - $SoftwareName - "

# Suffixes to append
$Suffixes = @("Install", "Available", "Uninstall")

foreach ($Suffix in $Suffixes) {
    $GroupName = "$BaseName$Suffix"
    
    # Check if the group already exists
    $ExistingGroup = Get-AzureADGroup -SearchString $GroupName | Where-Object { $_.DisplayName -eq $GroupName }

    if ($ExistingGroup) {
        Write-Warning "⚠️ Group '$GroupName' already exists. Skipping."
    } else {
        try {
            New-AzureADGroup -DisplayName $GroupName `
                             -MailEnabled $false `
                             -MailNickname ($GroupName -replace '\s', '') `
                             -SecurityEnabled $true `
                             -Description "Auto-created group for $BaseName $Suffix"
                             
            Write-Host "✅ Group '$GroupName' created successfully."
        } catch {
            Write-Error "❌ Failed to create group '$GroupName': $_"
        }
    }
}
