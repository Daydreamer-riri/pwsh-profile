# in profile:
# . $env:USERPROFILE\.config\pwsh-profile\user_profile.ps1

# Location
# ~/.config/powershell/user_profile.ps1 

# Load prompt config
function Get-ScriptDirectory {
  Split-Path $MyInvocation.ScriptName
}
$PROMPT_CONFIG = Join-Path (Get-ScriptDirectory) 'pure-moded.omp.json'
oh-my-posh init pwsh --config $PROMPT_CONFIG | Invoke-Expression

# Import-Module
Import-Module Terminal-Icons
Import-Module z
Import-Module posh-git

$env:POSH_GIT_ENABLED = $true

Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# PSReadLine
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Alias
Set-Alias vim nvim
Remove-Item Alias:ni -Force -ErrorAction Ignore # remove `ni` to use @antfu/ni
function d { nr dev }
function s { nr start }
function b { nr build }
function t { nr test }
function tu { nr test -u }
function c { nr typecheck }
function lint { nr lint }
function lintf { nr lint --fix }
function release { nr release }

function pull { git pull }
function push { git push }

# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# Tab completion

# winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# pnpm  (https://github.com/g-plane/pnpm-shell-completion)
$PNPM_COMPLETION_SCRIPT = Join-Path (Get-ScriptDirectory) 'pnpm-shell-completion\pnpm-shell-completion.ps1'
. $PNPM_COMPLETION_SCRIPT

