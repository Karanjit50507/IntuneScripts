# Detection Script for Microsoft Teams Installation

$teamsInstalled = $false

# Common install paths
$teamsPaths = @(
    "$env:ProgramFiles\Microsoft\Teams\current\Teams.exe",
    "$env:ProgramFiles(x86)\Microsoft\Teams\current\Teams.exe",
    "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
)

# Check standard install paths
foreach ($path in $teamsPaths) {
    if (Test-Path $path) {
        $teamsInstalled = $true
        break
    }
}

# Check WindowsApps folder recursively
if (-not $teamsInstalled) {
    $windowsAppsRoot = "C:\Program Files\WindowsApps"
    try {
        $teamsExecutables = Get-ChildItem -Path $windowsAppsRoot -Recurse -Filter "ms-Teams.exe" -ErrorAction SilentlyContinue
        foreach ($exe in $teamsExecutables) {
            if ($exe.FullName -match "MSTeams_*_x64__8wekyb3d8bbwe") {
                $teamsInstalled = $true
                break
            }
        }
    } catch {
        # In case of access denied or other errors
        Write-Host "Non-Compliant"
        exit 1
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
