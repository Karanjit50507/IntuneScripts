# Detection Script for Microsoft Teams Installation

$teamsPaths = @(
    "$env:ProgramFiles\Microsoft\Teams\current\Teams.exe",
    "$env:ProgramFiles(x86)\Microsoft\Teams\current\Teams.exe",
    "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
    "C:\Program Files\WindowsApps\MSTeams_25290.205.4069.4894_x64__8wekyb3d8bbwe\ms-teams.exe"
)

# Check standard install paths
$teamsInstalled = $false
foreach ($path in $teamsPaths) {
    if (Test-Path $path) {
        $teamsInstalled = $true
        break
    }
}

# Check WindowsApps folder for any MSTeams version
if (-not $teamsInstalled) {
    $windowsAppsPath = "C:\Program Files\WindowsApps"
    $teamsFolders = Get-ChildItem -Path $windowsAppsPath -Directory -Filter "MSTeams_*.*.*.*_x64__8wekyb3d8bbwe" -ErrorAction SilentlyContinue
    foreach ($path in $teamsfolders) {
    if (Test-Path $path) {
        $teamsInstalled = $true
        break
    }
}
    foreach ($folder in $teamsFolders) {
        $teamsExe = Join-Path $folder.FullName "ms-teams.exe"
        Write-Output "Teams exe path is:$teamsExe"
        if (Test-Path $teamsExe) {
            $teamsInstalled = $true
            break
        }
    }
}

# Return compliance status
if ($teamsInstalled) {
    Write-Host "Compliant"
    exit 0
} else {
    Write-Host "Non-Compliant"
    exit 1
}
