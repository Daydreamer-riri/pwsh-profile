# in profile:
# . $env:USERPROFILE\.config\pwsh-profile\user_profile.ps1

# Encoding
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [Text.UTF8Encoding]::UTF8

# Location
# ~/.config/powershell/user_profile.ps1

function Get-ScriptDirectory {
  Split-Path $MyInvocation.ScriptName
}
# Load prompt config
Invoke-Expression (&starship init powershell)

# PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -BellStyle None
# Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
Set-PSReadLineOption -Colors @{ "Selection" = "`e[7m" }

# Alias
Set-Alias vim nvim
Remove-Item Alias:ni -Force -ErrorAction Ignore # remove `ni` to use @antfu/ni
Remove-Item Alias:ls -Force -ErrorAction Ignore # remove `ls` to use eza
function d { nr dev }
function s { nr start }
function b { nr build }
function t { nr test }
function tu { nr test -u }
function c { nr typecheck }
function l { nr lint }
function lf { nr lint --fix }
function release { nr release }

function pull { git pull }
function push { git push }
function lg { lazygit }

function ll {
  eza -s=type --icons -1
}

function ls {
  eza -s=type --icons -l
}
# Utilities
function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function qrcode {
  param (
    $InputValue
  )
  curl -d "$InputValue" https://qrcode.show
}

function kill_port ($port) {
  netstat -ano | findstr "$port"
}

function clone ($url) {
  git clone ("$url" + ".git")
  Set-Location (Split-Path -Leaf $url)
}

function .. {
  Set-Location ..
}

# ---

# ENV
$ENV:CURRENT_SHELL = "pwsh"

$ENV:XDG_CONFIG_HOME = "$env:USERPROFILE\.config"

$ENV:BAT_CONFIG_PATH = "$env:USERPROFILE\.config\bat.conf"
$ENV:BAT_THEME = "gruvbox-dark"

# ---

# FZF
function _fzf_open_path
{
  param (
    [Parameter(Mandatory=$true)]
    [string]$input_path
  )
  if ($input_path -match "^.*:\d+:.*$")
  {
    $input_path = ($input_path -split ":")[0]
  }
  if (-not (Test-Path $input_path))
  {
    return
  }
  $cmds = @{
    'bat' = { bat $input_path }
    'cat' = { Get-Content $input_path }
    'cd' = {
      if (Test-Path $input_path -PathType Leaf)
      {
        $input_path = Split-Path $input_path -Parent
      }
      Set-Location $input_path
    }
    'nvim' = { nvim $input_path }
    'remove' = { Remove-Item -Recurse -Force $input_path }
    'echo' = { Write-Output $input_path }
  }
  $cmd = $cmds.Keys | fzf --prompt 'Select command> '
  & $cmds[$cmd]
}

function _fzf_get_path_using_rg
{
  $INITIAL_QUERY = "${*:-}"
  $RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case"
  $input_path = "" |
    fzf --ansi --disabled --query "$INITIAL_QUERY" `
      --bind "start:reload:$RG_PREFIX {q}" `
      --bind "change:reload:sleep 0.1 & $RG_PREFIX {q} || rem" `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%" == "1. ripgrep> " (echo ^rebind^(change^)^+^change-prompt^(1. ripgrep^> ^)^+^disable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-f ^& type %TEMP%\rg-fzf-r) else (echo ^unbind^(change^)^+^change-prompt^(2. fzf^> ^)^+^enable-search^+^transform-query:echo ^{q^} ^> %TEMP%\rg-fzf-r ^& type %TEMP%\rg-fzf-f)' `
      --color 'hl:-1:underline,hl+:-1:underline:reverse' `
      --delimiter ':' `
      --prompt '1. ripgrep> ' `
      --preview-label 'Preview' `
      --header 'CTRL-S: Switch between ripgrep/fzf' `
      --header-first `
      --preview 'bat --color=always {1} --highlight-line {2} --style=plain' `
      --preview-window 'up,60%,border-bottom,+{2}+3/3'
  return $input_path
}

function _fzf_get_path_using_fd
{
  $input_path = fd --type file --follow --hidden --exclude .git |
    fzf --prompt 'Files> ' `
      --header-first `
      --header 'CTRL-S: Switch between Files/Directories' `
      --bind 'ctrl-s:transform:if not "%FZF_PROMPT%"=="Files> " (echo ^change-prompt^(Files^> ^)^+^reload^(fd --type file^)) else (echo ^change-prompt^(Directory^> ^)^+^reload^(fd --type directory^))' `
      --preview 'if "%FZF_PROMPT%"=="Files> " (bat --color=always {} --style=plain) else (eza -T --colour=always --icons=always {})'
  return $input_path
}

function fdg
{
  try {
    _fzf_open_path $(_fzf_get_path_using_fd)
  }
  catch {
    <#Do this if a terminating exception happens#>
  }
}

function rgg
{
  try {
    _fzf_open_path $(_fzf_get_path_using_rg)
  }
  catch {
    <#Do this if a terminating exception happens#>
  }
}

function fe {
  try {
    $input_path = _fzf_get_path_using_fd
    if ($input_path -match "^.*:\d+:.*$")
    {
      $input_path = ($input_path -split ":")[0]
    }
    if (-not (Test-Path $input_path))
    {
      return
    }
    nvim $input_path
  }
  catch {
    <#Do this if a terminating exception happens#>
  }
}

# Set-PSReadLineKeyHandler -Key "Ctrl+f" -ScriptBlock {
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("fdg")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }
#
# Set-PSReadLineKeyHandler -Key "Ctrl+g" -ScriptBlock {
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("rgg")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }
#
# Set-PSReadLineKeyHandler -Key "Ctrl+n" -ScriptBlock {
#   [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#   [Microsoft.PowerShell.PSConsoleReadLine]::Insert("nvf")
#   [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
# }
# ---

# Yazi
function yy {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"
# $env:YAZI_CONFIG_HOME = "$env:USERPROFILE\.config\yazi"
$env:YAZI_CONFIG_HOME = "~\.config\yazi"

# --- 
carapace _carapace | Out-String | Invoke-Expression
# fnm
fnm env --use-on-cd | Out-String | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# windows terminal integration
if ($IsWindows -and (Get-Item Env:\WT_SESSION -ErrorAction SilentlyContinue)) {
    # bellow script originally from these 2 places:
    # 1. https://learn.microsoft.com/windows/terminal/tutorials/shell-integration#powershell-pwshexe
    # 2. https://github.com/starship/starship/blob/885241114a933ae97820030cd28c97dc31670d3a/src/init/starship.ps1
    # more info: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_prompts
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

    function Initialize-Prompt {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', "", Scope = 'function', Justification = 'This is necessary for the prompt to work.')]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', "", Scope = 'function', Justification = 'This is a global var.')]
        param()
        Copy-Item Function:\prompt Function:\global:oldPrompt
        $Global:__LastHistoryId = -1
    }
    Initialize-Prompt
    Remove-Item -Path Function:\Initialize-Prompt

    function prompt {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', "", Scope = 'function', Justification = 'This is supposed to hide the function')]
        param()
        # First, emit a mark for the _end_ of the previous command.
        $originalDollarQuestion = $global:?
        $originalLastExitCode = $global:LASTEXITCODE;
        $LastHistoryEntry = $(Get-History -Count 1)
        # Skip finishing the command if the first command has not yet started
        if ($Global:__LastHistoryId -ne -1) {
            if ($LastHistoryEntry.Id -eq $Global:__LastHistoryId) {
                # Don't provide a command line or exit code if there was no history entry (eg. ctrl+c, enter on no command)
                $out += "`e]133;D`a"
            } else {
                $Global:__LastHistoryId = $LastHistoryEntry.Id
                $out += "`e]133;D;$originalLastExitCode`a"
            }
        }

        $loc = $($executionContext.SessionState.Path.CurrentLocation);

        # Prompt started
        $out += "`e]133;A$([char]07)";

        # CWD
        $out += "`e]9;9;`"$loc`"$([char]07)";

        # your prompt here:
        $global:LASTEXITCODE = $originalLastExitCode
        if ($global:? -ne $originalDollarQuestion) {
            if ($originalDollarQuestion) {
                # Simple command which will execute successfully and set $? = True without any other side affects.
                1 + 1
            } else {
                # Write-Error will set $? to False.
                # ErrorAction Ignore will prevent the error from being added to the $Error collection.
                Write-Error '' -ErrorAction 'Ignore'
            }
        }
        $out += oldPrompt

        # Prompt ended, Command started
        $out += "`e]133;B$([char]07)";

        return $out
    }
}

$_ScriptsDirectory = "$env:USERPROFILE\.config\pwsh-profile\customs"
Get-ChildItem -Path $_ScriptsDirectory -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}
