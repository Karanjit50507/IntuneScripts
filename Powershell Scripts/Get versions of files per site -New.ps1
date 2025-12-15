# Import the PnP PowerShell module
Import-Module PnP.PowerShell

# Connect to the SharePoint site
$SiteURL = "https://angleauto.sharepoint.com/sites/‎test‎" # Replace with your SharePoint site URL
$SiteURL = $siteURL -replace "\u200E", ""
$SiteURL


$OutputFilePath = "C:\Temp\PricingFileDetails1212.csv" # Replace with the path to save the CSV file

Connect-PnPOnline -Url $SiteURL -Interactive -ClientId 0c9d8bda-6634-4a65-a898-92268c11e1ce

$DocumentLibraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } # 101 is the template ID for document libraries

# Initialize an empty array to store file details
$FileDetails = @()
$Versions = @()

# Get all document libraries in the site
foreach ($Library in $DocumentLibraries) {
    Write-Host "Processing Library: $($Library.Title)"
    
    # Get all files and folders in the library
    $Files = Get-PnPListItem -List $Library.Title -PageSize 5000 -Fields "FileRef", "FileLeafRef", "File_x0020_Size", "FileSystemObjectType"
    $ctx = Get-PnPContext

    # Total file count for progress bar
    $TotalFiles = $Files.Count
    $CurrentFileIndex = 0
    $StartTime = Get-Date  # Record start time for progress calculation

    foreach ($File in $Files) {
        # Update current file index
        $CurrentFileIndex++

        # Calculate elapsed time and estimated time remaining
        $ElapsedTime = (Get-Date) - $StartTime
        $AverageTimePerFile = $ElapsedTime.TotalSeconds / $CurrentFileIndex
        $TimeRemaining = $AverageTimePerFile * ($TotalFiles - $CurrentFileIndex)
        $TimeRemainingFormatted = [TimeSpan]::FromSeconds($TimeRemaining).ToString("hh\:mm\:ss")

        # Update progress bar
        $PercentComplete = ($CurrentFileIndex / $TotalFiles) * 100
        Write-Progress -Activity "Processing Files in $($Library.Title)" `
                       -Status "Processed $CurrentFileIndex of $TotalFiles. Time Remaining: $TimeRemainingFormatted" `
                       -PercentComplete $PercentComplete `
                       -CurrentOperation "Processing file: $($File['FileLeafRef'])"

        # Skip folders and invalid items
        if ($File.FileSystemObjectType -ne "File") {
            Write-Warning "Skipping folder or invalid item: $($File['FileLeafRef'])"
            continue
        }

        # Initialize TotalSize
        $TotalSize = 0

        # Safely load the File object
        try {
            $FileObject = $File.File
            if ($FileObject -ne $null) {
                $ctx.Load($FileObject)
                $ctx.Load($FileObject.Versions)  # Load versions if available
                $ctx.ExecuteQuery()

                # Sum up version sizes if Versions exist
                if ($FileObject.Versions -ne $null -and $FileObject.Versions.Count -gt 0) {
                    foreach ($Version in $FileObject.Versions) {
                        $TotalSize += $Version.Size
                    }
                }

                # Add the current file size (latest version)
                $CurrentFileSize = $File["File_x0020_Size"]
                $TotalSize += $CurrentFileSize

                # Check for UIVersionLabel
                $UIVersionLabel = if ([string]::IsNullOrEmpty($FileObject.UIVersionLabel)) { "null" } else { $FileObject.UIVersionLabel }

                # Add file details to the array
                $FileDetails += [PSCustomObject]@{
                    Name         = $File["FileLeafRef"]
                    FilePath     = $File["FileRef"]
                    FileSize     = $CurrentFileSize
                    TotalSize    = $TotalSize
                    Version      = $UIVersionLabel
                }
            }
            else {
                Write-Warning "File object is null for: $($File['FileLeafRef'])"
            }
        }
        catch {
            Write-Warning "Failed to process file: $($File['FileLeafRef']). Error: $_"
            # Add the file with fallback values
            $FileDetails += [PSCustomObject]@{
                Name         = $File["FileLeafRef"]
                FilePath     = $File["FileRef"]
                FileSize     = $File["File_x0020_Size"]
                TotalSize    = "Error"
                Version      = "Error"
            }
        }
    }
}

# Export the details to a CSV file
$FileDetails | Export-Csv -Path $OutputFilePath -NoTypeInformation -Encoding UTF8
Write-Host "Processing completed. File details exported to $OutputFilePath" -ForegroundColor Green



#disconnect-pnp