# Import the PnP PowerShell module
Import-Module PnP.PowerShell

# Connect to the SharePoint site
$SiteURL = "https://angleauto.sharepoint.com/sites/Finance" # Replace with your SharePoint site URL
$OutputFilePath = "C:\Temp\FileDetails.csv" # Replace with the path to save the CSV file

Connect-PnPOnline -Url $SiteURL -Interactive -ClientId 0c9d8bda-6634-4a65-a898-92268c11e1ce

# Get all document libraries in the site
$DocumentLibraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } # 101 is the template ID for document libraries

# Initialize an array to hold file details
$FileDetails = @()
$Versions = @()

# Iterate through each library
foreach ($Library in $DocumentLibraries) {
    Write-Host "Processing Library: $($Library.Title)"
    
    # Get all files in the library
    $Files = Get-PnPListItem -List $Library.Title -PageSize 5000 -Fields "FileRef", "FileLeafRef", "File_x0020_Size"
    $ctx= Get-PnPContext

    foreach ($File in $Files) {
    $file
        # Add file details to the array
        $FileDetails += [PSCustomObject]@{
            Name     = $File["FileLeafRef"]
            FilePath = $File["FileRef"]
            FileSize = $File["File_x0020_Size"]
        }
        $files = $file.file
        $ctx.load($files)
        $ctx.ExecuteQuery()
        $Versions += $files.UIVersionLabel

    }

}

$AllFiles = $FileDetails | 
        ForEach-Object {
            $index = [Array]::IndexOf($FileDetails, $_)
            $_ | Add-Member -MemberType NoteProperty -Name "Version" -Value $versions[$index]
            $_
        }



Write-Host "File details exported to $OutputFilePath"

foreach ($Library in $DocumentLibraries) {

$ListItems = Get-PnPListItem -List Documents -PageSize 5000

foreach ($item in $ListItems)
{
        $file = $item.file
        $ctx.load($file)
        $ctx.ExecuteQuery()
        $FileDetails1 += [PSCustomObject]@{
            Name     = $File["Name"]
            Version = $File["UIVersionLabel"]
        }
        Write-Host $file.Name,$files.UIVersionLabel
}

}



# Export the details to a CSV file
$FileDetails | Export-Csv -Path $OutputFilePath -NoTypeInformation -Encoding UTF8