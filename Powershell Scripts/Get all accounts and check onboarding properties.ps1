Connect-MgGraph -Scopes User.ReadWrite.All 
Connect-AzureAD
$users = Get-MgUser -All -Select "displayName,employeetype,companyName,employeeId,employeeType,employeeHireDate,employeeOrgData,city,Id,manager,country,usageLocation,mobilePhone"

$userinfo = @()

foreach ($user in $users) { 
try{
$managerId = (Get-MgUserManager -UserId $user.Id).Id
$manager = Get-MgUser -UserId $managerId
$managerName = $manager.DisplayName
}catch{
$managerName = $null
}

$userinfo += [PSCustomObject]@{  
DisplayName = $user.DisplayName  
CompanyName = $user.CompanyName
EmployeeID = $user.EmployeeId
EmployeeType = $user.employeeType
EmployeeHireDate = $user.EmployeeHireDate
City = $user.city
Manager = $managerName
CountryOrRegion = $user.Country
UsageLocation = $user.UsageLocation
Mobile = $user.MobilePhone
}  
}

  
$userinfo | Export-Csv -Path "C:\Users\MichaelTakache\OneDrive - Angle Auto Finance\Documents\AAF Users\userinfo.csv" -NoTypeInformation