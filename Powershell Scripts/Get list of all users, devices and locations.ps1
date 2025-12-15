Install-Module Microsoft.Graph.DeviceManagement -Force

Connect-MgGraph
Connect-AzureAD

$devices = Get-MgDeviceManagementManagedDevice | 
    Where-Object { $_.UserDisplayName -ne "" -and $_.Manufacturer -eq "HP" } | 
    Select-Object UserDisplayName, UserPrincipalName, EmployeeID, UserId, Manufacturer, Model, SerialNumber | 
    Sort-Object UserDisplayName

$locations = @()

foreach ($device in $devices) {
    $userId = $device.UserId

    if ($userId -eq $null) {
        $locations += "null"
    } else {
        $user = Get-AzureADUser -Filter "ObjectId eq '$userId'"
        if ($user -and $user.State) {
            $locations += $user.State
        } else {
            $locations += "unknown"
        }
    }
}

# Add the Location column to the devices
$AllDevices = $devices | 
    ForEach-Object {
        $index = [Array]::IndexOf($devices, $_)
        $_ | Add-Member -MemberType NoteProperty -Name "Location" -Value $locations[$index]
        $_
    }

# Display the result in Out-GridView
$AllDevices | Export-Csv -Path "C:\Temp\AlldevicesHP.csv" -NoTypeInformation