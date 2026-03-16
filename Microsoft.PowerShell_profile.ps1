# Microsoft.PowerShell_profile.ps1
# 这个文件是 PowerShell 的 profile 脚本，在 PowerShell 启动时自动执行。它用于设置环境变量、加载模块、定义函数和别名等。
# profile 脚本的路径可以通过 $PROFILE 变量查看。这个文件通常位于用户的文档目录下的 PowerShell 文件夹中。
# 例如，Windows 上的路径可能是：
# C:\Users\<用户名>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# prompt.ps1 定义了 PowerShell 的提示符样式和窗口标题
. $PSScriptRoot\sh\prompt.ps1

# starship.ps1 配置了 starship 提示符的样式和切换功能
. $PSScriptRoot\sh\starship.ps1

# modules.ps1 导入了 PSReadLine、posh-git 和 PSFzf 等模块
. $PSScriptRoot\sh\modules.ps1

# aliases_and_functions.ps1 定义了一些常用的别名和函数
. $PSScriptRoot\sh\aliases_and_functions.ps1