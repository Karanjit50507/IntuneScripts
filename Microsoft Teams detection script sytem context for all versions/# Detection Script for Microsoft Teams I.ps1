# Detection Script for Microsoft Teams Installation

$teamsPaths = @(
    "$env:ProgramFiles\Microsoft\Teams\current\Teams.exe",
    "$env:ProgramFiles(x86)\Microsoft\Teams\current\Teams.exe",
    "$env:LOCALAPPDATA\Microsoft\Teams\current\Teams.exe"
    "C:\Program Files\WindowsApps\MSTeams_25290.205.4069.4894_x64__8wekyb3d8bbwe\ms-teams.exe"
)

$teamsInstalled = $false

foreach ($path in $teamsPaths) {
    if (Test-Path $path) {
        $teamsInstalled = $true
        break
    }
}

if ($teamsInstalled) {
    Write-Host "Compliant"
    exit 0
} else {
    Write-Host "Non-Compliant"
    exit 1
}
