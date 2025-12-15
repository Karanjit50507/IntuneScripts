# Function to check for Teams in the uninstall registry keys
function Get-InstalledClassicTeams {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $registryPaths) {
        $apps = Get-ChildItem -Path $path -ErrorAction SilentlyContinue |
            ForEach-Object {
                try {
                    Get-ItemProperty $_.PSPath
                } catch {
                    $null
                }
            }

        foreach ($app in $apps) {
            if ($app.DisplayName -like "Microsoft Teams" -and $app.DisplayVersion -notlike "4*") {
                return $true  # Classic Teams (not version 24000+ which is New Teams)
            }
        }
    }

    return $false
}

# Check per-user install (local app data)
function Check-PerUserClassicTeams {
    $users = Get-ChildItem "C:\Users" -Directory | Where-Object {
        Test-Path "$($_.FullName)\AppData\Local\Microsoft\Teams\Update.exe"
    }

    if ($users.Count -gt 0) {
        return $true
    }

    return $false
}

# Run both checks
$classicInstalled = Get-InstalledClassicTeams
$perUserTeams     = Check-PerUserClassicTeams

if ($classicInstalled -or $perUserTeams) {
    Write-Output "Classic Teams detected"
    exit 1  # Non-compliant
} else {
    Write-Output "Classic Teams not found"
    exit 0  # Compliant
}
