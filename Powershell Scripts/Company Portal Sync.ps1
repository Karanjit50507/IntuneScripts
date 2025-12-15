$EnrollmentID = Get-ScheduledTask |
  Where-Object { $_.TaskPath -like "*Microsoft*Windows*EnterpriseMgmt\\*" } |
  Select-Object -ExpandProperty TaskPath -Unique |
  Where-Object { $_ -like "*-*-" } |
  Split-Path -Leaf

Start-Process -FilePath "C:\Windows\System32\deviceenroller.exe" -Wait -ArgumentList "/o $EnrollmentID /c /b"
