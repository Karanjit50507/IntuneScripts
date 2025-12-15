Connect-AzureAD
Connect-ExchangeOnline

$DeviceNames = Import-Csv -Path "C:\temp\ANGLE_-_Worker_Report_Operations -.csv" #replace with path of .CSV
$E = $DeviceNames.email


foreach ($DLUser in $E) {

$DLUser
Add-DistributionGroupMember -Identity "DL-AAF-Operations ALL" -Member $DLUser
}
