# Usage:
#   powershell -File .\devtools_install.ps1 [-Tools <name,...>] [-All] [-Help|-h]
#
# 参数说明：
#   -Tools git,rust,python   只安装指定工具（逗号分隔，不区分大小写）
#   -All                     安装全部工具，不弹出选择菜单
#   -Help/-h                 打印帮助信息
#
# 不传参数时显示交互式选择菜单。
# Rust 不支持 --scope machine，将安装到当前用户。

param(
    [string[]]$Tools,
    [switch]$All,
    [Alias('h')]
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Usage:
  powershell -File .\devtools_install.ps1 [-Tools <name,...>] [-All] [-Help|-h]

参数说明：
  -Tools git,rust,python   只安装指定工具（逗号分隔，不区分大小写）
  -All                     安装全部工具，不弹出选择菜单
  -Help/-h                 打印帮助信息

不传参数时显示交互式选择菜单。
"@
    exit
}

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "需要管理员权限，正在请求提权..." -ForegroundColor Yellow
    $argList = @('-File', "`"$PSCommandPath`"")
    if ($All)   { $argList += '-All' }
    if ($Tools) { $argList += '-Tools'; $argList += ($Tools -join ',') }
    Start-Process pwsh -Verb RunAs -ArgumentList $argList
    exit
}

# 检查 winget 是否可用
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget 不可用，请先安装 App Installer。" -ForegroundColor Red
    exit 1
}

################################################################################
# 工具定义表

# Key        - 工具标识，用于 -Tools 参数筛选
# Name       - 显示名称
# Id         - winget ID（python 特殊处理，留空）
# Command    - 用于检测是否已安装的命令名
# Default    - 交互菜单中是否默认选中
# NoMachine  - 不支持 --scope machine（如 Rust）
# NoSilent   - 不支持 --silent（某些工具）
# Override   - 覆盖 winget 默认安装参数
#
# 备注：
# NanaZip 和 WinDbg 都是微软商店的 MSIX 包，不支持 `--scope machine`，把这两个改成 `NoMachine=$true`：

$toolDefinitions = @(
    [ordered]@{ Key='pwsh';    Name='PowerShell 7';     Id='Microsoft.PowerShell';            Command='pwsh';   Default=$true;  NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='git';     Name='Git';               Id='Git.Git';                         Command='git';    Default=$true;  NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='vscode';  Name='VSCode';            Id='Microsoft.VisualStudioCode';      Command='code';   Default=$true;  NoMachine=$false; NoSilent=$false; Override='/VERYSILENT /MERGETASKS=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath' }
    [ordered]@{ Key='nanazip'; Name='NanaZip';           Id='M2Team.NanaZip';                  Command='';       Default=$true;  NoMachine=$true;  NoSilent=$false }
    [ordered]@{ Key='rust';    Name='Rust (rustup)';     Id='Rustlang.Rustup';                 Command='rustup'; Default=$true; NoMachine=$true;  NoSilent=$false }
    [ordered]@{ Key='python';  Name='Python 3';          Id='';                                Command='python'; Default=$true; NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='node';    Name='Node.js LTS';       Id='OpenJS.NodeJS.LTS';               Command='node';   Default=$false; NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='go';      Name='Go';                Id='GoLang.Go';                       Command='go';     Default=$false; NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='java';    Name='Java (Temurin 21)'; Id='EclipseAdoptium.Temurin.21.JDK';  Command='java';   Default=$false; NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='cmake';   Name='CMake';             Id='Kitware.CMake';                   Command='cmake';  Default=$true; NoMachine=$false; NoSilent=$false }
    [ordered]@{ Key='windbg';  Name='WinDbg';            Id='Microsoft.WinDbg';                Command='';       Default=$true;  NoMachine=$true;  NoSilent=$false }
)

################################################################################
# 交互式选择菜单

function Show-SelectionMenu {
    param([array]$Definitions)

    $selected = 0..($Definitions.Count - 1) | ForEach-Object { $Definitions[$_].Default -eq $true }

    while ($true) {
        Clear-Host
        Write-Host "选择要安装的工具（输入序号切换，a=全选，n=全不选，回车确认）：" -ForegroundColor Cyan
        Write-Host ""
        for ($i = 0; $i -lt $Definitions.Count; $i++) {
            $mark = if ($selected[$i]) { '[x]' } else { '[ ]' }
            $color = if ($selected[$i]) { 'Green' } else { 'DarkGray' }
            Write-Host ("  $mark {0}. {1}" -f ($i + 1), $Definitions[$i].Name) -ForegroundColor $color
        }
        Write-Host ""

        $input = Read-Host "输入"
        $input = $input.Trim()

        if ($input -eq '') { break }
        if ($input -eq 'a') { $selected = @($true)  * $Definitions.Count; continue }
        if ($input -eq 'n') { $selected = @($false) * $Definitions.Count; continue }

        # 支持逗号分隔多个序号，如 "1,3,5"
        $tokens = $input -split '[,\s]+' | Where-Object { $_ -ne '' }
        foreach ($token in $tokens) {
            if ($token -match '^\d+$') {
                $idx = [int]$token - 1
                if ($idx -ge 0 -and $idx -lt $Definitions.Count) {
                    $selected[$idx] = -not $selected[$idx]
                }
            }
        }
    }

    return $Definitions | Where-Object { $selected[$Definitions.IndexOf($_)] }
}

################################################################################
# 辅助函数

function Get-LatestPython3Id {
    $lines = winget search --id "Python.Python.3" --source winget 2>$null
    $ids = $lines | ForEach-Object {
        if ($_ -match 'Python\.Python\.(3\.\d+)') { $matches[0] }
    } | Sort-Object { [version]($_ -replace 'Python\.Python\.', '') } -Descending
    return $ids | Select-Object -First 1
}

function Get-ToolVersion {
    param([string]$CommandName)
    foreach ($argSet in @(@('--version'), @('-V'), @('-v'), @('version'))) {
        try {
            $raw = & $CommandName @argSet 2>$null
            if ($LASTEXITCODE -eq 0 -and $raw) {
                $v = ($raw | Where-Object { $_ -and $_.Trim() } | Select-Object -First 1).Trim()
                if ($v) { return $v }
            }
        } catch {}
    }
    return ''
}

function Install-WingetTool {
    param([hashtable]$Tool)

    $id = $Tool.Id
    if ($Tool.Key -eq 'python') {
        $id = Get-LatestPython3Id
        if (-not $id) {
            Write-Host "未能查找到 Python 3 的 winget ID，跳过。" -ForegroundColor Yellow
            return [PSCustomObject]@{ Name = $Tool.Name; Result = '跳过'; Version = '' }
        }
    }

    # CLI 工具用 Get-Command 检测，GUI 工具（Command 为空）用 winget list 检测
    if ($Tool.Command) {
        $cmdObj = Get-Command $Tool.Command -ErrorAction SilentlyContinue
        if ($cmdObj) {
            $version = Get-ToolVersion $Tool.Command
            Write-Host "已安装，跳过：$($Tool.Name) $version" -ForegroundColor DarkGray
            return [PSCustomObject]@{ Name = $Tool.Name; Result = '已安装'; Version = $version }
        }
    } else {
        $listed = winget list --id $id --source winget 2>$null | Select-String ([regex]::Escape($id))
        if ($listed) {
            Write-Host "已安装，跳过：$($Tool.Name)" -ForegroundColor DarkGray
            return [PSCustomObject]@{ Name = $Tool.Name; Result = '已安装'; Version = '' }
        }
    }

    Write-Host "正在安装：$($Tool.Name) ..." -ForegroundColor Cyan

    $wingetArgs = @('install', '--id', $id, '-e', '--source', 'winget')
    if (-not $Tool.NoMachine) { $wingetArgs += @('--scope', 'machine') }
    if ($Tool.Override)       { $wingetArgs += @('--override', $Tool.Override) }
    elseif (-not $Tool.NoSilent) { $wingetArgs += '--silent' }

    & winget @wingetArgs | Out-Null

    if ($LASTEXITCODE -eq 0) {
        $version = if ($Tool.Command) { Get-ToolVersion $Tool.Command } else { '' }
        return [PSCustomObject]@{ Name = $Tool.Name; Result = '成功'; Version = $version }
    } else {
        return [PSCustomObject]@{ Name = $Tool.Name; Result = '失败'; Version = '' }
    }
}

################################################################################
# 确定要安装的工具列表

if ($All) {
    $toInstall = $toolDefinitions
} elseif ($Tools) {
    $keys = $Tools -join ',' -split ',' | ForEach-Object { $_.Trim().ToLower() }
    $toInstall = $toolDefinitions | Where-Object { $keys -contains $_.Key }
    $invalid = $keys | Where-Object { $k = $_; -not ($toolDefinitions | Where-Object { $_.Key -eq $k }) }
    if ($invalid) {
        Write-Host "未知工具：$($invalid -join ', ')" -ForegroundColor Yellow
        Write-Host "可用：$($toolDefinitions.Key -join ', ')" -ForegroundColor DarkGray
    }
} else {
    $toInstall = Show-SelectionMenu -Definitions $toolDefinitions
}

if (-not $toInstall) {
    Write-Host "未选择任何工具，退出。" -ForegroundColor Yellow
    exit
}

################################################################################
# 执行安装

$installResults = @()
foreach ($tool in $toInstall) {
    $installResults += Install-WingetTool -Tool $tool
}

################################################################################
# 输出结果

Write-Host ""
Write-Host "安装结果：" -ForegroundColor Blue
$installResults | ForEach-Object {
    $color = switch ($_.Result) {
        '成功'    { 'Green' }
        '失败'    { 'Red' }
        '已安装'  { 'White' }
        default   { 'DarkGray' }
    }
    Write-Host ("{0,-22} {1,-8} {2}" -f $_.Name, $_.Result, $_.Version) -ForegroundColor $color
}
Write-Host ""
Write-Host "完成！" -ForegroundColor Green
Write-Host "按任意键退出..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
