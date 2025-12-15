Install-Module -Name PowerShellGet -Force -AllowClobber

Get-CsOnlineUser | Where-Object {$_.TeamsFeedbackPolicy -like "Test Feedback Policy"} | Select DisplayName, UserPrincipalName

Get-CsOnlineUser | Select-Object DisplayName, UserPrincipalName, TeamsFeedbackPolicy





Connect-MicrosoftTeams


Get-CsTeamsFeedbackPolicy

New-CsTeamsFeedbackPolicy -identity "Test Feedback Policy" -userInitiatedMode disabled -receiveSurveysMode disabled

Grant-CsTeamsFeedbackPolicy -Identity Mel-Boardroom@angleauto.com.au -PolicyName "Test Feedback Policy"

