# Import PnP PowerShell Module
Import-Module PnP.PowerShell

# Define site URL (change this to the specific site you want to analyze)
$SiteUrl = Read-Host "Enter the SharePoint Site URL"

# Output file for results
$OutputFile = "PreservationHoldLibrarySizeFinance.csv"

# Initialize an array to hold results
$Results = @()

# Connect to the specified SharePoint site
Write-Host "Connecting to site: $SiteUrl..." -ForegroundColor Cyan
try {
    Connect-PnPOnline -Url $SiteUrl -Interactive -ClientId 0c9d8bda-6634-4a65-a898-92268c11e1ce
} catch {
    Write-Error "Failed to connect to site: $SiteUrl. Error: $_"
    exit
}

# Start processing
Write-Host "Checking for Preservation Hold Library..." -ForegroundColor Yellow

try {
    # Check if the Preservation Hold Library exists
    $PreservationLibrary = Get-PnPList -Identity "Preservation Hold Library" -ErrorAction SilentlyContinue

    if ($PreservationLibrary -ne $null) {
        Write-Host "Preservation Hold Library found. Retrieving items..." -ForegroundColor Green

        # Retrieve all items in the Preservation Hold Library
        $Items = Get-PnPListItem -List $PreservationLibrary.Title -PageSize 5000 -Fields "FileLeafRef", "File_x0020_Size"

        # Initialize total size
        $TotalSize = 0
        $FileCount = $Items.Count
        $ProcessedFiles = 0
        $FileStartTime = Get-Date

        # Process files in the Preservation Hold Library
        foreach ($Item in $Items) {
            $ProcessedFiles++

            # Update progress bar
            $ElapsedTime = (Get-Date) - $FileStartTime
            $AverageTimePerFile = $ElapsedTime.TotalSeconds / $ProcessedFiles
            $TimeRemaining = $AverageTimePerFile * ($FileCount - $ProcessedFiles)
            $TimeRemainingFormatted = [TimeSpan]::FromSeconds($TimeRemaining).ToString("hh\:mm\:ss")

            $PercentComplete = ($ProcessedFiles / $FileCount) * 100
            Write-Progress -Activity "Processing Preservation Hold Library" `
                           -Status "Processed $ProcessedFiles of $FileCount files. ETA: $TimeRemainingFormatted" `
                           -PercentComplete $PercentComplete `
                           -CurrentOperation "Processing file $($Item['FileLeafRef'])"

            $File = $Item.File
            if ($File -ne $null) {
                # Load file and versions
                $ctx = Get-PnPContext
                $ctx.Load($File)
                $ctx.Load($File.Versions)
                $ctx.ExecuteQuery()

                # Calculate total size, including all versions
                $VersionSize = 0
                if ($File.Versions.Count -gt 0) {
                    foreach ($Version in $File.Versions) {
                        $VersionSize += [int64]$Version.Size
                    }
                }

                # Add current file size
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

        # Add result to array
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
    Write-Warning "Failed to process Preservation Hold Library for site: $SiteUrl. Error: $_"
}

# Export results to CSV
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "`nResults exported to $OutputFile" -ForegroundColor Cyan
} else {
    Write-Host "`nNo Preservation Hold Library details found." -ForegroundColor Red
}

Write-Host "Script completed." -ForegroundColor Green
