################################################################################
# windows title 
function prompt {
    # 获取当前路径并截断为最后两级
    $currentPath = (Get-Location).Path
    $shortPath = if ($currentPath -match '[^\\]+\\[^\\]+$') { $matches[0] } else { $currentPath }
    
    # 设置窗口标题（示例格式：PS: C:\Users\Project）
    $Host.UI.RawUI.WindowTitle = "PS: $shortPath"
    
    # 保留默认提示符
    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}

################################################################################
# starship 
# configure files:
$starshipConfigs = @(
    "$HOME\.config\starship\starship_custom.toml",
    "$HOME\.config\starship\starship_powerline.toml",
    "$HOME\.config\starship\starship_plaintextsymbols.toml",
    ""
)
$selectedConfig = Get-Random -InputObject $starshipConfigs
$env:STARSHIP_CONFIG = $selectedConfig
Invoke-Expression (&starship init powershell)

# 添加命令用于切换 starship 配置
function Switch-StarshipConfig {
    param(
        [ValidateSet("custom", "powerline", "plaintextsymbols", "default", "c", "p", "t", "d")]
        [string]$Config = "default"
    )
    $configPaths = @{
        "custom" = "$HOME\.config\starship\starship_custom.toml"
        "c" = "$HOME\.config\starship\starship_custom.toml"
        "powerline" = "$HOME\.config\starship\starship_powerline.toml"
        "p" = "$HOME\.config\starship\starship_powerline.toml"
        "plaintextsymbols" = "$HOME\.config\starship\starship_plaintextsymbols.toml"
        "t" = "$HOME\.config\starship\starship_plaintextsymbols.toml"
        "default" = ""
        "d" = ""
    }
    $env:STARSHIP_CONFIG = $configPaths[$Config]
    Invoke-Expression (&starship init powershell)
    Write-Host "Switched to starship config: $Config" -ForegroundColor Green
}
Set-Alias ssc Switch-StarshipConfig

################################################################################
# modules 

# import ps-read-line
Import-Module PSReadLine

# import posh-git
Import-Module posh-git

# import psfzf
Import-Module PSFzf

# settings
# 设置预测文本来源为历史记录
Set-PSReadLineOption -PredictionSource History

# 每次回溯输入历史，光标定位于输入内容末尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# 设置 Tab 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

# 设置 Ctrl+d 为退出 PowerShell
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit

# 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

# 设置向下键为前向搜索历史纪录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

################################################################################
# functions and aliases
# 依赖于 lsd.exe，需将 lsd.exe 添加到系统 PATH 中
function ls_fun { lsd.exe @args } # 列出当前目录下的所有文件和文件夹，使用 lsd.exe 替代 Get-ChildItem
function ll_fun { lsd.exe -alF @args }  # 列出当前目录下的所有文件和文件夹 类似于 Linux 的 ls -l
function la_fun { lsd.exe -a @args } # 列出当前目录下的所有文件和文件夹，包括隐藏文件, 类似于 Linux 的 ls -a
function lr_fun { lsd.exe -R @args } # 递归列出当前目录下的所有文件和文件夹，类似于 Linux 的 ls -R

Set-Alias ls ls_fun -Option AllScope
Set-Alias ll ll_fun -Option AllScope
Set-Alias la la_fun -Option AllScope
Set-Alias lr lr_fun -Option AllScope

# 下边为 alias settings
Set-Alias ~ Set-Location -Option AllScope # 切换到用户主目录
Set-Alias vim nvim -Option AllScope # 将 vim 命令映射到 nvim.exe
Set-Alias cat bat.exe # 将 cat 命令映射到 bat.exe，提供更丰富的文件内容显示功能, 依赖于 bat.exe，需将 bat.exe 添加到系统 PATH 中

# function ListAll { Get-ChildItem -Force }
# Set-Alias la ListAll -Option AllScope   

# 清空剪贴板
function clcb_fun { Set-Clipboard "" } 
Set-Alias clcb clcb_fun -Option AllScope

# 类似于 Linux 的 grep、rm、mv 等命令
Set-Alias grep Select-String -Option AllScope
Set-Alias rm Remove-Item -Option AllScope
Set-Alias mv Move-Item -Option AllScope
Set-Alias cp Copy-Item -Option AllScope
Set-Alias mkdir New-Item -Option AllScope
Set-Alias rmdir Remove-Item -Option AllScope
Set-Alias touch New-Item -Option AllScope
Set-Alias find Get-ChildItem -Option AllScope

# pstop: htop alias for Windows
Set-Alias htop pstop
# zoxide: zo alias for Windows
Set-Alias zo zoxide
