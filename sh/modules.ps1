################################################################################
# modules 

# PSReadLine 是一个流行的模块，用于增强 PowerShell 中的命令行编辑体验。
# 它提供了语法高亮、多行编辑和命令历史导航等功能。
# 通过导入 PSReadLine，用户可以提高在 PowerShell 终端中工作的效率和生产力。
# 检查是否已加载 PSReadLine 模块，如果没有则尝试导入它。
# 对于某些环境（如 VS Code 的 PowerShell 主机），可能已经预加载了 PSReadLine 的程序集，因此在导入失败时不会抛出错误，而是记录一个详细信息级别的消息。
if (-not (Get-Module -Name PSReadLine)) {
	try {
		Import-Module PSReadLine -ErrorAction Stop
	}
	catch {
		# VS Code PowerShell host may preload PSReadLine assemblies; skip hard failure.
		Write-Verbose "Skip importing PSReadLine: $($_.Exception.Message)"
	}
}

# posh-git 是一个 PowerShell 模块，提供了 Git 仓库的状态信息和命令提示功能。
# 它在 PowerShell 提示符中显示当前 Git 仓库的分支、状态（如未提交的更改）和其他相关信息，使得在命令行中使用 Git 更加方便和高效。
# 通过导入 posh-git 模块，用户可以在 PowerShell 中获得更丰富的 Git 集成体验。
# 检查是否已安装 posh-git 模块，如果存在则导入它。
if (Get-Module -ListAvailable -Name posh-git) {
	Import-Module posh-git -ErrorAction SilentlyContinue
}


# PSFzf 是一个 PowerShell 模块，提供了基于 fzf 的模糊查找功能。
# 它允许用户在 PowerShell 中使用 fzf 来快速搜索文件、命令历史和其他列表，提高在命令行中的导航效率。
# 通过导入 PSFzf 模块，用户可以在 PowerShell 中获得强大的模糊查找功能，提升工作效率。
# 检查是否已安装 PSFzf 模块，如果存在则导入它。
if (Get-Module -ListAvailable -Name PSFzf) {
	Import-Module PSFzf -ErrorAction SilentlyContinue
}


################################################################################
# PSReadLine settings
if (Get-Command -Name Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    # 设置预测来源为历史记录
	Set-PSReadLineOption -PredictionSource History

    # 设置历史记录搜索行为，使光标移动到行尾
	Set-PSReadLineOption -HistorySearchCursorMovesToEnd

    # 设置显示为内联幽灵文本 (按 → 键补全)
    Set-PSReadLineOption -PredictionViewStyle InlineView
    
    # 设置按键绑定，启用 Tab 键进行菜单补全，Ctrl+d 退出 Vi 模式，Ctrl+z 撤销，使用上下箭头进行历史搜索
	Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete
	Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit
	Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
	Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
	Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # 开启编辑时的颜色高亮
    Set-PSReadLineOption -Colors @{
        Command            = 'White'
        Parameter          = 'DarkGray'
        Operator           = 'DarkGray'
        Variable           = 'Green'
        String             = 'DarkCyan'
        Number             = 'DarkCyan'
        Type               = 'DarkGray'
        Comment            = 'DarkGreen'
    }
}


# PSFzf settings
if (Get-Command -Name Set-PSFzfOption -ErrorAction SilentlyContinue) {
    Set-PSFzfOption -Name "DefaultCommand" -Value "fd --type f --hidden --follow --exclude .git"
    Set-PSFzfOption -Name "DefaultDirCommand" -Value "fd --type d --hidden --follow --exclude .git"
    Set-PSFzfOption -Name "DefaultHistoryCommand" -Value "Get-History | Select-Object -ExpandProperty CommandLine"
}
