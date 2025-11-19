# Check for any version of Microsoft Teams in WindowsApps with ms-teams.exe

$teamsInstalled = $false
$windowsAppsPath = "C:\Program Files\WindowsApps"

try {
    # Get all folders matching the MSTeams version pattern
    $teamsFolders = Get-ChildItem -Path $windowsAppsPath -Directory -ErrorAction Stop | Where-Object {
        $_.Name -match "^MSTeams_\d+\.\d+\.\d+\.\d+_x64__8wekyb3d8bbwe$"
    }

    foreach ($folder in $teamsFolders) {
        $exePath = Join-Path $folder.FullName "ms-teams.exe"
        if (Test-Path $exePath) {
            $teamsInstalled = $true
            break
        }
    }
}
catch {
    Write-Host "Error accessing WindowsApps folder: $_"
    exit 1
}

# Output result
if ($teamsInstalled) {
    Write-Host "Microsoft Teams is installed."
    exit 0
} else {
    Write-Host "Microsoft Teams is NOT installed."
    exit 1
}
