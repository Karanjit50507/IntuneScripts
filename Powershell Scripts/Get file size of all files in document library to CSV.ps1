
Connect-SPOService -url https://angleauto-admin.sharepoint.com

$Allsites = Get-SPOSite -Limit All | Select URL

$Connections = Connect-PnPOnline https://angleauto.sharepoint.com/sites/finance -Interactive -ReturnConnection

#Parameters
$SiteURL = "https://angleauto.sharepoint.com/sites/finance"
$SiteURL
$SiteLength = ($SiteURL.length)-39
$SiteN = $SiteURL.Substring(39,$SiteLength)
$Date = Get-date -Format "yyyyMMdd"
$ListName= "Documents"
$ReportPath = "C:\Temp\$Date\"
$ReportOutput = "C:\Temp\$Date\$SiteN.csv"
   
Connect-PnPOnline $SiteURL -Interactive -ClientId $Connections.ClientId
 
#Array to store results
$Results = @()
   
#Get all Items from the document library
$List  = Get-PnPList -Identity $ListName
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 | Where {$_.FileSystemObjectType -eq "File"}
Write-host "Total Number of Items in the List:"$List.ItemCount
 
$ItemCounter = 0 
#Iterate through each item
Foreach ($Item in $ListItems)
{
        $Results += New-Object PSObject -Property ([ordered]@{
            FileName          = $Item.FieldValues.FileLeafRef
            RelativeURL       = $Item.FieldValues.FileRef
            FileSize          = $Item.FieldValues.File_x0020_Size
            TotalFileSize     = $Item.FieldValues.SMTotalSize.LookupId
        })
    $ItemCounter++
    Write-Progress -PercentComplete ($ItemCounter / ($List.ItemCount) * 100) -Activity "Processing Items $ItemCounter of $($List.ItemCount)" -Status "Getting data from Item '$($Item['FileLeafRef'])"
}
  
#Export the results to CSV

if (!(Test-Path $ReportPath -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $ReportPath
}
$Results | Export-Csv -Path $ReportOutput -NoTypeInformation
Write-host "File Size Report Exported to CSV Successfully!"

