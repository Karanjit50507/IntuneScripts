try  {
    Get-AzureADTenantDetail 
}
catch {
    Connect-AzureAD
}

if (Get-AzureADTenantDetail) {
    # Get All Enabled Users
    $users = Get-AzureADUser -All $true -Filter "AccountEnabled eq true" 

    # Refine list to users with the E5 sku assigned to them
    $licensedUsers = $users | ? { $_.AssignedLicenses.SkuID -contains "05e9a617-0261-4cee-bb44-138d3ef5d965" }

    # Generate an empty array
    $userSignInDetails = @()

    # An integer for progress monitoring
    $int = 1

    ForEach ($user in $licensedUsers) {

        Write-Host ("{0} of {1} - {2}%" -f $int, $licensedUsers.count,  ($int / $licensedUsers.count * 100))
        $upn = $user.UserPrincipalName

        #https://learn.microsoft.com/en-us/answers/questions/1015038/get-azureadauditsigninlogs-returns-no-results-for.html
    
        $signinDetails = Get-AzureADAuditSignInLogs -filter "startswith(userPrincipalName,'$upn')" -top 1 | select CreatedDateTime, UserPrincipalName, IsInteractive, AppDisplayName, IpAddress, TokenIssuerType
        
        if ($signinDetails) {
            Write-Host $signinDetails
        }
        else {
            Write-Host "No sign in log for $upn"
            $signinDetails = New-Object -TypeName PSObject -Property @{
                userPrincipalName = $upn
                AppDisplayName = "N/A"
            }
        }        

        $userSignInDetails += $signinDetails

        Write-Host "Sleeping.."
        # Rate Limit
        Start-Sleep -Seconds 2

        $int++
    }
}

$staleLicensedUsers = $licensedUsers | ? { $_.UserPrincipalName -in ($userSignInDetails | ? { $_.AppDisplayName -eq "N/A" }).UserPrincipalName }

$staleLicensedUsers | Select DisplayName, Mail, CompanyName, Department,  JobTitle, @{n="Manager";e={Get-AzureADUserManager -ObjectID $_.objectid | select -ExpandProperty DisplayName }} | Out-GridView
$licensedUsers  | Select DisplayName, Mail, CompanyName, Department,  JobTitle, @{n="Manager";e={Get-AzureADUserManager -ObjectID $_.objectid | select -ExpandProperty DisplayName }} | Out-GridView