
# Input Parameters  
$siteURL="https://angleauto.sharepoint.com/sites/NovatedLeaseTeam"  
$tenantURL="https://angleauto-admin.sharepoint.com"  

# Connect to Microsoft Teams  
Connect-MicrosoftTeams 

# Connectto SharePoint Online Service  
Connect-SPOService -Url $tenantURL  
$site = Get-SPOSite -Identity $siteURL  

# Create Team from the Site associated O365 Group 
New-Team -GroupId $site.GroupId.Guid  