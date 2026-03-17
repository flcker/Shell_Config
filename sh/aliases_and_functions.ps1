################################################################################
# functions and aliases
function ls_fun { lsd.exe @args }
function ll_fun { lsd.exe -alF @args }
function la_fun { lsd.exe -a @args }
function lr_fun { lsd.exe -R @args }

# clear clipboard
function clcb_fun { Set-Clipboard "" }

Set-Alias ls ls_fun -Option AllScope
Set-Alias ll ll_fun -Option AllScope
Set-Alias la la_fun -Option AllScope
Set-Alias lr lr_fun -Option AllScope
Set-Alias ~ Set-Location -Option AllScope
Set-Alias vim nvim -Option AllScope
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

