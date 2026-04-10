# nvim 配置
# 这个文件是 nvim 的配置文件，位于 PowerShell 的 profile 脚本中。它用于设置 nvim 的环境变量、别名和函数等，以便在 PowerShell 中使用 nvim。  
# 如果安装了neovim 就设置nvim的配置（submodule/nvim）和 别名

function global:nvim_func {
    $profileRoot = Split-Path $PSScriptRoot -Parent
    $configPath = "$profileRoot\submodule\nvim"
    $initLua = Join-Path $configPath "init.lua"
    $initVim = Join-Path $configPath "init.vim"

    # 输出调试信息，确保正确加载了 nvim 配置文件
    # Write-Host "nvim_func called with arguments: $Args" -ForegroundColor Cyan
    # Write-Host "Looking for nvim config in: $configPath" -ForegroundColor Cyan
    # Write-Host "Checking for init.lua: $initLua" -ForegroundColor Cyan
    # Write-Host "Checking for init.vim: $initVim" -ForegroundColor Cyan

    if (Test-Path $initLua) {
        & nvim.exe -u $initLua @Args
    } elseif (Test-Path $initVim) {
        & nvim.exe -u $initVim @Args
    } else {
        & nvim.exe @Args
    }
}

Set-Alias -Name vim -Value nvim_func -Option AllScope -Scope Global
Set-Alias -Name vi -Value nvim_func -Option AllScope -Scope Global
# 用 function 而非 alias 覆盖 nvim，避免别名指向自身导致死循环；函数内调用 nvim_func，nvim_func 内部使用 nvim.exe 直接调用可执行文件
function global:nvim { nvim_func @Args }
