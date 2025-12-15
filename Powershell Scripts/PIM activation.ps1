#Install required modules (if you are local admin) (only needed first time).
#Install-Module -Name DCToolbox -RequiredVersion 2.0.21 -Force
#Install-Module -Name AzureADPreview -Force
#Install-Package msal.ps -AcceptLicense -Force
Connect-AzureAD 

#If packages already installed run script from here
function Enable-PIM{

$PIMs= @('Teams Administrator','Application Administrator','User Administrator','Intune Administrator','SharePoint Administrator')

Foreach ($PIM in $PIMS){
Enable-DCAzureADPIMRole -RolesToActivate $PIM -Reason 'SD Work' -UseMaximumTimeAllowed -ErrorAction SilentlyContinue
}
}
Enable-PIM

#Get-InstalledModule -Name Dctoolbox