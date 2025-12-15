# Connect to Azure AD
Connect-AzureAD

# Get all enabled users
$enabledUsers = Get-AzureADUser -All $true | Where-Object { $_.AccountEnabled -eq $true -and $_.State -ne $null }

# Group and count by State
$stateCounts = $enabledUsers | Group-Object -Property State | Sort-Object Count -Descending

# Display results
$stateCounts | Format-Table Name, Count -AutoSize
