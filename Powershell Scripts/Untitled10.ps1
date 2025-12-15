# Import PnP PowerShell Module
Import-Module PnP.PowerShell

# Connect to SharePoint Online Admin Center
$AdminUrl = "https://angleauto-admin.sharepoint.com"
Connect-PnPOnline -Url $AdminUrl -Interactive -ClientId 0c9d8bda-6634-4a65-a898-92268c11e1ce

# Output file for results
$OutputFile = "C:\Temp\PreservationHoldLibrarySizes.csv"

# Initialize an array to hold results
$Results = @()

# Retrieve all site collections (excluding OneDrive)
Write-Host "Retrieving all site collections..." -ForegroundColor Cyan
$Sites = Get-PnPTenantSite -IncludeOneDriveSites:$false

# Initialize progress variables
$TotalSites = $Sites.Count
$ProcessedSites = 0
$StartTime = Get-Date

# Iterate through each site
foreach ($Site in $Sites) {
    $ProcessedSites++
    $SiteUrl = $Site.Url
    $ElapsedTime = (Get-Date) - $StartTime
    $AverageTimePerSite = $ElapsedTime.TotalSeconds / $ProcessedSites
    $TimeRemaining = $AverageTimePerSite * ($TotalSites - $ProcessedSites)
    $TimeRemainingFormatted = [TimeSpan]::FromSeconds($TimeRemaining).ToString("hh\:mm\:ss")

    # Update progress bar
    $PercentComplete = ($ProcessedSites / $TotalSites) * 100
    Write-Progress -Activity "Processing Sites" `
                   -Status "Processing $ProcessedSites of $TotalSites sites. ETA: $TimeRemainingFormatted" `
                   -PercentComplete $PercentComplete `
                   -CurrentOperation "Current Site: $SiteUrl"

    Write-Host "`nProcessing site: $SiteUrl" -ForegroundColor Yellow

    try {
        # Connect to the site
        Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId 0c9d8bda-6634-4a65-a898-92268c11e1ce

        # Check if the Preservation Hold Library exists
        $PreservationLibrary = Get-PnPList -Identity "Preservation Hold Library" -ErrorAction SilentlyContinue

        if ($PreservationLibrary -ne $null) {
            Write-Host "Found Preservation Hold Library in $SiteUrl. Calculating size..." -ForegroundColor Green

            # Retrieve all items in the Preservation Hold Library
            $Items = Get-PnPListItem -List $PreservationLibrary.Title -PageSize 5000 -Fields "FileLeafRef", "File_x0020_Size"

            # Initialize total size
            $TotalSize = 0
            $FileCount = $Items.Count
            $ProcessedFiles = 0
            $FileStartTime = Get-Date

            # Process only items that are files
            foreach ($Item in $Items) {
                $ProcessedFiles++
                $FileElapsedTime = (Get-Date) - $FileStartTime
                $AverageTimePerFile = $FileElapsedTime.TotalSeconds / $ProcessedFiles
                $FileTimeRemaining = $AverageTimePerFile * ($FileCount - $ProcessedFiles)
                $FileTimeRemainingFormatted = [TimeSpan]::FromSeconds($FileTimeRemaining).ToString("hh\:mm\:ss")

                # Update progress bar for files
                $FilePercentComplete = ($ProcessedFiles / $FileCount) * 100
                Write-Progress -Activity "Processing Files in Preservation Hold Library" `
                               -Status "Processed $ProcessedFiles of $FileCount files. ETA: $FileTimeRemainingFormatted" `
                               -PercentComplete $FilePercentComplete `
                               -CurrentOperation "Processing file $($Item['FileLeafRef'])"

                $File = $Item.File
                if ($File -ne $null) {
                    $ctx = Get-PnPContext
                    $ctx.Load($File)
                    $ctx.Load($File.Versions)  # Load all versions of the file
                    $ctx.ExecuteQuery()

                    # Sum up the size of all versions
                    $VersionSize = 0
                    if ($File.Versions.Count -gt 0) {
                        foreach ($Version in $File.Versions) {
                            $VersionSize += [int64]$Version.Size
                        }
                    }

                    # Add the current version's size
                    $CurrentSize = $Item["File_x0020_Size"]
                    if ($CurrentSize -ne $null) {
                        $VersionSize += [int64]$CurrentSize
                    }

                    # Add the file's total size to the overall total
                    $TotalSize += $VersionSize
                }
            }

            # Convert size to MB
            $TotalSizeMB = [Math]::Round($TotalSize / 1MB, 2)

            Write-Host "Total Size of Preservation Hold Library: $TotalSizeMB MB" -ForegroundColor Green

            # Add to results
            $Results += [PSCustomObject]@{
                SiteUrl      = $SiteUrl
                LibraryName  = $PreservationLibrary.Title
                TotalSizeMB  = $TotalSizeMB
            }
        }
        else {
            Write-Host "No Preservation Hold Library found in $SiteUrl" -ForegroundColor Gray
        }
    }
    catch {
        Write-Warning "Failed to process site: $SiteUrl. Error: $_"
    }
}

# Export results to CSV
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "`nResults exported to $OutputFile" -ForegroundColor Cyan
} else {
    Write-Host "`nNo Preservation Hold Libraries found." -ForegroundColor Red
}

Write-Host "Script completed." -ForegroundColor Green
