################################################################################
# functions and aliases

# refresh profile without restart terminal
function repwsh { . $PROFILE }

function ls_fun { lsd.exe @args }
function ll_fun { lsd.exe -alF @args }
function la_fun { lsd.exe -a @args }
function lr_fun { lsd.exe -R @args }

# clear clipboard
function clcb_fun { Set-Clipboard "" }

# http proxy
function set_proxy_fun {
    $env:HTTP_PROXY = "http://127.0.0.1:7890"
    $env:HTTPS_PROXY = "http://127.0.0.1:7890"
    # $env:ALL_PROXY = "socks5://127.0.0.1:7890"
}
Set-Alias setproxy set_proxy_fun

function unset_proxy_fun {
    Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
}
Set-Alias unsetproxy unset_proxy_fun

Set-Alias ls ls_fun -Option AllScope
Set-Alias ll ll_fun -Option AllScope
Set-Alias la la_fun -Option AllScope
Set-Alias lr lr_fun -Option AllScope
Set-Alias ~ Set-Location -Option AllScope
Set-Alias cat bat.exe
Set-Alias clcb clcb_fun -Option AllScope
Set-Alias grep Select-String -Option AllScope
Set-Alias rm Remove-Item -Option AllScope
Set-Alias mv Move-Item -Option AllScope
Set-Alias cp Copy-Item -Option AllScope
Set-Alias mkdir New-Item -Option AllScope
Set-Alias rmdir Remove-Item -Option AllScope
Set-Alias touch New-Item -Option AllScope
Set-Alias find Get-ChildItem -Option AllScope
Set-Alias htop pstop
Set-Alias zo zoxide
Set-Alias lg lazygit
Set-Alias btop btop4win
