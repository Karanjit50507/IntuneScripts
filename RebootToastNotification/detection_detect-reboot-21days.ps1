# Get current time and system boot time
$now = Get-Date
$bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Calculate uptime
$uptime = $now - $bootTime
$uptimeHours = [math]::Round($uptime.TotalHours, 2)

# Threshold in days
$thresholdDays = 21
$thresholdHours = $thresholdDays * 24

# Output
Write-Host "Current Time: $now"
Write-Host "Boot Time: $bootTime"
Write-Host "Uptime (Hours): $uptimeHours"

# Compare
if ($uptimeHours -gt $thresholdHours) {
    Write-Host "Machine has been on for more than $thresholdDays days"
    exit 1
} else {
    Write-Host "Machine has been on for less than $thresholdDays days"
    exit 0
}
