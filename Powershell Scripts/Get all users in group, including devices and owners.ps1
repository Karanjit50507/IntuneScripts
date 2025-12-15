#Install-Module Microsoft.Graph.DeviceManagement -Force

Connect-MgGraph
Connect-AzureAD

$group = Get-AzureADGroup -All $true | Select -Property DisplayName, ObjectId | Sort DisplayName | Out-GridView -PassThru -Title "Select group"

$GroupUsers = Get-AzureADGroupMember -ObjectId $group.ObjectId

# Retrieve devices in the group
$GroupDevices = Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object { $_.ObjectType -eq "Device" }

$DeviceOwners = @()

# Get owners for each device
foreach ($device in $GroupDevices) {
    $owners = Get-AzureADDeviceRegisteredOwner -ObjectId $device.ObjectId
    foreach ($owner in $owners) {
        $DeviceOwners += [PSCustomObject]@{
            DeviceName = $device.DisplayName
            DeviceId = $device.ObjectId
            OwnerName = $owner.DisplayName
            OwnerId = $owner.ObjectId
        }
    }
}

# Combine Users and Device Owners into a final list
$FinalGroupMembers = @()

foreach ($user in $GroupUsers) {
    $deviceOwner = $DeviceOwners | Where-Object { $_.DeviceId -eq $user.ObjectId }
    
    # Check if the device has a valid owner before adding to the final list
    if ($deviceOwner -and $deviceOwner.OwnerName) {
        $FinalGroupMembers += [PSCustomObject]@{
            Name = $user.DisplayName
            ObjectId = $user.ObjectId
            Type = $user.ObjectType
            DeviceOwner = $deviceOwner.OwnerName
        }
    }
    else {
        $FinalGroupMembers += [PSCustomObject]@{
            Name = $user.DisplayName
            ObjectId = $user.ObjectId
            Type = $user.ObjectType
            DeviceOwner = $null
        }
    }
}

# Display the final list
$FinalGroupMembers | SORT DeviceOwner | Out-GridView -Title $group.DisplayName
