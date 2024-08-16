# in profile:
# . $env:USERPROFILE\.config\pwsh-profile\user_profile.ps1

# Location
# ~/.config/powershell/user_profile.ps1

# Load prompt config
function Get-ScriptDirectory {
  Split-Path $MyInvocation.ScriptName
}
# $PROMPT_CONFIG = Join-Path (Get-ScriptDirectory) 'pure-moded.omp.json'
# oh-my-posh init pwsh --config $PROMPT_CONFIG | Invoke-Expression

# Import-Module Terminal-Icons
Invoke-Expression (&starship init powershell)

$LazyLoadProfile = [PowerShell]::Create()
[void]$LazyLoadProfile.AddScript(@'
    Import-Module posh-git
    Import-Module -Name CompletionPredictor
'@)
$LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()

$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
    Import-Module -Name posh-git
    Import-Module -Name CompletionPredictor
    $global:GitPromptSettings.EnableFileStatus = $false
    $LazyLoadProfile.Dispose()
    $LazyLoadProfileRunspace.Close()
    $LazyLoadProfileRunspace.Dispose()
}
Import-Module -Name PsFzf
# Import-Module posh-git

# $env:POSH_GIT_ENABLED = $true

# Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord



# pnpm  (https://github.com/g-plane/pnpm-shell-completion)
$PNPM_COMPLETION_SCRIPT = Join-Path (Get-ScriptDirectory) 'pnpm-shell-completion\pnpm-shell-completion.ps1'
. $PNPM_COMPLETION_SCRIPT

# fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell | Out-String) })



# for duplicate pane
function Invoke-Starship-PreCommand {
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
