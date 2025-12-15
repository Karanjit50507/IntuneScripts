Connect-AzureAD

$Names = Import-Csv -Path "C:\temp\AAFSupportPersonnel.csv" #replace with path of .CSV


foreach ($Person in $Names) {

$UPN = $Person.email
$DN = $Person.name

$UPNusernameLength = ($UPN.length) - 17
$UPNusername = $UPN.Substring(0,$UPNusernameLength)

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "<Password>"

#create user
New-AzureADUser -DisplayName $DN -UserPrincipalName $UPN -PasswordProfile $PasswordProfile -AccountEnabled $true -MailNickName $UPNusername

$NU = Get-AzureADUser -ObjectId $UPN | Select -Property DisplayName, UserPrincipalName, ObjectId

#Add user to group

Add-AzureADGroupMember -objectId "92e585c3-58eb-467e-8f9a-34cc33ec2d19" -RefObjectId $NU.objectId 

}
