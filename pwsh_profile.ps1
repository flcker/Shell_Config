# 这个文件是 PowerShell 的本仓库配置的入口文件
# 需要在 Microsoft.PowerShell_profile.ps1 中加载这个文件，以便在 PowerShell 中使用这些配置


# 输出当前目录调试信息，确保正确加载了配置文件
# Write-Host "Loading PowerShell profile"
# Write-Host "Current directory: $PSScriptRoot"

# prompt.ps1 定义了 PowerShell 的提示符样式和窗口标题
. $PSScriptRoot\sh\prompt.ps1

# starship.ps1 配置了 starship 提示符的样式和切换功能
. $PSScriptRoot\sh\starship.ps1

# modules.ps1 导入了 PSReadLine、posh-git 和 PSFzf 等模块
. $PSScriptRoot\sh\modules.ps1

# aliases_and_functions.ps1 定义了一些常用的别名和函数
. $PSScriptRoot\sh\aliases_and_functions.ps1

# nvim.ps1 配置了 nvim 的环境变量和别名
. $PSScriptRoot\sh\nvim.ps1

# config.ps1 加载配置
. $PSScriptRoot\sh\config.ps1
