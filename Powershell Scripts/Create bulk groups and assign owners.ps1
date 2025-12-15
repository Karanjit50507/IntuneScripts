Connect-AzureAD

$SGs = 
@(
"SG - PBI Customer Data Workspace Viewer DEV"
"SG - PBI Data Model Workspace Viewer DEV"
"SG - PBI Dealer Sales Workspace Viewer DEV"
"SG - PBI Executive Reporting Workspace Viewer DEV"
"SG - PBI Finance Data & Reporting Workspace Viewer DEV"
"SG - PBI Finance Enterprise PPU Workspace Viewer DEV"
"SG - PBI Group Finance Workspace Viewer DEV"
"SG - PBI Novated Workspace Viewer DEV"
"SG - PBI OEM Workspace Viewer DEV"
"SG - PBI Product, Pricing & Performance Workspace Viewer DEV"
"SG - PBI Retail Credit Risk Workspace Viewer DEV"
"SG - PBI Retail Operations Workspace Viewer DEV"
"SG - PBI Risk & Compliance Workspace Viewer DEV"
"SG - PBI Status Monitor Workspace Viewer DEV"
"SG - PBI Wholesale Credit Risk Workspace Viewer DEV"
"SG - PBI Wholesale Operations Workspace Viewer DEV"
)

foreach ($group in $SGs){
$group
$groupId = (Get-AzureADGroup -SearchString $group).ObjectId
Get-AzureADGroupOwner -ObjectId $groupId
}

$owners = @(
"eef72303-79c0-43d8-ae87-96d8cbd7c45b"
"877c8d67-ce58-4af2-b048-b758ec57a257"
)


foreach ($group in $SGs){
Write-Output "creating $group..."
$cleanString = $group -replace '[^a-zA-Z0-9]', ''

New-AzureADGroup -DisplayName $group -SecurityEnabled $true -MailEnabled $false -MailNickName $cleanString
$g = Get-AzureADGroup -SearchString $group
foreach ($user in $owners){
Write-Output "Assign $user as owner"
Add-AzureADGroupOwner -ObjectId $g.ObjectId -RefObjectId $user
}
}

foreach ($group in $SGs){
$group
$groupId = (Get-AzureADGroup -SearchString $group).ObjectId
Get-AzureADGroupOwner -ObjectId $groupId
}