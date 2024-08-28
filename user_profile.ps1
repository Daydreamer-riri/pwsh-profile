# in profile:
# . $env:USERPROFILE\.config\pwsh-profile\user_profile.ps1

# Location
# ~/.config/powershell/user_profile.ps1

# Load prompt config
function Get-ScriptDirectory {
  Split-Path $MyInvocation.ScriptName
}

Invoke-Expression (&starship init powershell)

# Import-Module -Name PsFzf
# Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -BellStyle None
# Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }
carapace _carapace | Out-String | Invoke-Expression

# fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# for windows terminal duplicate pane
function Invoke-Starship-PreCommand {
  if (!$env:WT_SESSION)
  {
    return
  }
  $loc = $executionContext.SessionState.Path.CurrentLocation;
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem")
  {
    $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}

$_ScriptsDirectory = Join-Path (Get-ScriptDirectory) 'customs'
Get-ChildItem -Path $_ScriptsDirectory -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
