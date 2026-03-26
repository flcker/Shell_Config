################################################################################
# config.ps1 加载配置

# zoxide is a smarter cd command, inspired by z and autojump.
Invoke-Expression (& { (zoxide init powershell | Out-String) })