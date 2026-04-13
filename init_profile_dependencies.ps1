
# Usage:
#   powershell -File .\init_profile_dependencies.ps1 [-ModuleScope <CurrentUser|AllUsers|c|a>] [-s <CurrentUser|AllUsers|c|a>] [-u <c|a>] [-Help|-h]
#
# 参数说明：
#   -ModuleScope/-s/-u  指定 PowerShell 模块安装作用域
#     CurrentUser 或 c  当前用户
#     AllUsers   或 a  所有用户（需管理员权限）
#   -Help/-h      打印 usage 帮助信息

param(
    [Alias('s','u')]
    [ValidateSet('CurrentUser','AllUsers','c','a')]
    [string]$ModuleScope = 'CurrentUser',
    [Alias('h')]
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage:"
    Write-Host "  powershell -File .\\init_profile_dependencies.ps1 [-ModuleScope <CurrentUser|AllUsers|c|a>] [-s <CurrentUser|AllUsers|c|a>] [-u <c|a>] [-Help|-h]"
    Write-Host ""
    Write-Host "参数说明："
    Write-Host "  -ModuleScope/-s/-u  指定 PowerShell 模块安装作用域"
    Write-Host "    CurrentUser 或 c  当前用户"
    Write-Host "    AllUsers   或 a  所有用户（需管理员权限）"
    Write-Host "  -Help/-h      打印 usage 帮助信息"
    exit
}

# 参数值映射，支持 -u c（当前用户）和 -u a（所有用户）
switch ($ModuleScope) {
    'c' { $ModuleScope = 'CurrentUser' }
    'a' { $ModuleScope = 'AllUsers' }
}

# 记录安装项目与结果
$installResults = @()

function Install-PowerShellModule {
    param(
        [string]$ModuleName,
        [string]$Scope
    )
    $version = ''
    $moduleObj = Get-Module -ListAvailable -Name $ModuleName | Select-Object -First 1
    if (-not $moduleObj) {
        Write-Host "正在安装 PowerShell 模块：$ModuleName ..." -ForegroundColor Cyan
        try {
            Install-Module $ModuleName -Scope $Scope -Force
            $moduleObj = Get-Module -ListAvailable -Name $ModuleName | Select-Object -First 1
            $version = $moduleObj.Version.ToString()
            $script:installResults += [PSCustomObject]@{Name=$ModuleName; Result='成功'; Version=$version}
        } catch {
            $script:installResults += [PSCustomObject]@{Name=$ModuleName; Result='失败: ' + $_.Exception.Message; Version=''}
        }
    } else {
        $version = $moduleObj.Version.ToString()
        $script:installResults += [PSCustomObject]@{Name=$ModuleName; Result='已安装'; Version=$version}
    }
}

function Install-ToolWithWinget {
    param(
        [string]$ToolName,
        [string]$WingetId,
        [string]$CommandName = $ToolName
    )
    $version = ''
    $cmdObj = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $cmdObj) {
        Write-Host "正在安装工具：$ToolName ..." -ForegroundColor Cyan
        $result = & winget install --id $WingetId -e --source winget 2>&1
        # 刷新当前会话 PATH（winget 将新路径写入注册表，不会自动更新当前会话）
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        $cmdObj = Get-Command $CommandName -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -eq 0 -and $cmdObj) {
            foreach ($argSet in @(@('--version'), @('-v'), @('version'))) {
                try {
                    $raw = & $CommandName @argSet 2>$null
                    if ($LASTEXITCODE -eq 0 -and $raw) {
                        $version = ($raw | Where-Object { $_ -and $_.Trim() } | Select-Object -First 1).Trim()
                        if ($version) { break }
                    }
                } catch {}
            }
            $script:installResults += [PSCustomObject]@{Name=$ToolName; Result='成功'; Version=$version}
        } elseif ($result -match '已安装|找不到可用的升级|No applicable update found|已是最新版本|已安装的现有包') {
            $script:installResults += [PSCustomObject]@{Name=$ToolName; Result='已安装'; Version=$version}
        } else {
            $script:installResults += [PSCustomObject]@{Name=$ToolName; Result='失败'; Version=''}
        }
    } else {
        foreach ($argSet in @(@('--version'), @('-v'), @('version'))) {
            try {
                $raw = & $CommandName @argSet 2>$null
                if ($LASTEXITCODE -eq 0 -and $raw) {
                    $version = ($raw | Where-Object { $_ -and $_.Trim() } | Select-Object -First 1).Trim()
                    if ($version) { break }
                }
            } catch {}
        }
        $script:installResults += [PSCustomObject]@{Name=$ToolName; Result='已安装'; Version=$version}
    }
}



# PowerShell 模块列表
$psModules = @(
    'posh-git',
    'PSFzf',
    'PSReadLine'
)

foreach ($mod in $psModules) {
    Install-PowerShellModule -ModuleName $mod -Scope $ModuleScope
}

# winget 工具列表
$wingetTools = @(
    @{ Name = 'starship'; Id = 'Starship.Starship' },
    @{ Name = 'bat'; Id = 'Sharkdp.Bat' },
    @{ Name = 'LSDeluxe'; Id = 'lsd-rs.lsd'; Command = 'lsd' },
    @{ Name = 'nvim'; Id = 'Neovim.Neovim' },
    @{ Name = 'zoxide'; Id = 'ajeetdsouza.zoxide' },
    @{ Name = 'fzf'; Id = 'junegunn.fzf' },
    @{ Name = 'pstop'; Id = 'marlocarlo.pstop' },
    @{ Name = 'glow'; Id = 'charmbracelet.glow' },
    @{ Name = 'lazygit'; Id = 'JesseDuffield.lazygit' },
    @{ Name = 'btop4win'; Id = 'aristocratos.btop4win' },
    @{ Name = 'pnpm'; Id = 'pnpm.pnpm' },
    @{ Name = 'gping'; Id = 'orf.gping' },
    @{ Name = 'tlrc'; Id = 'tldr-pages.tlrc'; Command = 'tldr' }
)

# 检查 winget 是否可用
$wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
if ($wingetAvailable) {
    foreach ($tool in $wingetTools) {
        $cmdName = if ($tool.ContainsKey('Command')) { $tool.Command } else { $tool.Name }
        Install-ToolWithWinget -ToolName $tool.Name -WingetId $tool.Id -CommandName $cmdName
    }
} else {
    Write-Host "winget 不可用，已跳过所有非 PowerShell 依赖安装。" -ForegroundColor Yellow
}

Write-Host "PowerShell 模块安装结果：" -ForegroundColor Blue
$installResults | Where-Object { $psModules -contains $_.Name } | ForEach-Object {
    $color = if ($_.Result -eq '成功') {'Green'} elseif ($_.Result -like '失败*') {'Red'} else {'White'}
    Write-Host ("{0,-15} {1,-10} {2}" -f $_.Name, $_.Result, $_.Version) -ForegroundColor $color
}
Write-Host "winget 工具安装结果：" -ForegroundColor Blue
$installResults | Where-Object { $wingetTools.Name -contains $_.Name } | ForEach-Object {
    $color = if ($_.Result -eq '成功') {'Green'} elseif ($_.Result -like '失败*') {'Red'} else {'White'}
    Write-Host ("{0,-15} {1,-10} {2}" -f $_.Name, $_.Result, $_.Version) -ForegroundColor $color
}
Write-Host "所有依赖安装完成！" -ForegroundColor Green
