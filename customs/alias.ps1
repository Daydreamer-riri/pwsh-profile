
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
