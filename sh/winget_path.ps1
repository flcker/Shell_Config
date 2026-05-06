################################################################################
# winget_path.ps1 — Keep winget CLI paths in WINGET_PATH, separate from PATH
#
# USAGE
#   syncwp              扫描 User PATH，迁移 winget 路径 → WINGET_PATH（持久化）
#   syncwp -WhatIf      预览，不做实际修改
#
# BACKUP / RESTORE
#   每次 syncwp 写操作前自动备份，保留最近 10 条。
#   backupwp            手动创建备份快照
#   restwp -List        列出所有备份
#   restwp [-Index N]   恢复（省略 -Index 则交互选择）
#
# HOW IT WORKS
#   WINGET_PATH 是用户级环境变量，存储 winget 管理的路径（分号分隔）。
#   syncwp 迁移后，User PATH 写入 %WINGET_PATH% 引用（REG_EXPAND_SZ），
#   Windows 启动时自动展开，无需 profile 额外注入。
#   Import-WingetPath 在首次 syncwp 之前负责注入（之后为幂等 no-op）。
#
# DETECTION
#   路径以 $script:_WingetRoots 中的根目录为前缀即视为 winget 管理。
#
# INSPECT
#   $env:WINGET_PATH -split ';'          当前会话条目
#   [Environment]::GetEnvironmentVariable('WINGET_PATH','User')   持久化值

$script:_WingetRoots = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
)
$script:_BackupFile = "$env:LOCALAPPDATA\winget_path_backups.json"
$script:_MaxBackups = 10


function global:Import-WingetPath {
    <#
    .SYNOPSIS
        将 WINGET_PATH 注入当前会话的 $env:Path（去重）。
    .DESCRIPTION
        读取用户级 WINGET_PATH 环境变量，把其中不在 $env:Path 的条目追加进去。
        在 profile 加载时自动调用，reenv/Update-Env 后也会调用。
    #>
    $wp = [System.Environment]::GetEnvironmentVariable('WINGET_PATH', 'User')
    if (-not $wp) { return }

    $wpEntries   = $wp -split ';' | Where-Object { $_ -ne '' }
    $pathEntries = $env:Path -split ';' | Where-Object { $_ -ne '' }
    $toAdd       = $wpEntries | Where-Object { $_ -notin $pathEntries }
    if ($toAdd) { $env:Path = ($pathEntries + $toAdd) -join ';' }
}

Import-WingetPath


function global:Backup-WingetPath {
    <#
    .SYNOPSIS
        备份当前 User PATH 和 WINGET_PATH 到本地 JSON 文件。
    .DESCRIPTION
        syncwp 写操作前自动调用；也可手动执行（别名 backupwp）。
        最多保留 $script:_MaxBackups 条记录，超出后自动移除最旧的。
        备份文件：$env:LOCALAPPDATA\winget_path_backups.json
    .EXAMPLE
        backupwp
        手动创建一条备份快照。
    .NOTES
        别名：backupwp
    #>
    param(
        [ValidateSet('manual', 'auto')]
        [string]$Type = 'manual',
        [string]$Description = ''
    )

    $regKey    = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
    $rawPath   = if ($regKey) {
        $regKey.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    } else { '' }
    if ($regKey) { $regKey.Close() }
    $curWinget = [System.Environment]::GetEnvironmentVariable('WINGET_PATH', 'User') ?? ''

    # 加载已有备份（diff 需要在创建新条目前完成；用 .NET API 确保句柄立即释放）
    $backups = @()
    if (Test-Path $script:_BackupFile) {
        try   { $backups = @([System.IO.File]::ReadAllText($script:_BackupFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json) }
        catch { $backups = @() }
    }

    # 手动备份且未提供描述时，自动与上一条 diff
    if ($Type -eq 'manual' -and $Description -eq '') {
        $prev = if ($backups.Count -gt 0) { $backups[0] } else { $null }
        if (-not $prev) {
            $Description = '初始备份'
        } else {
            $prevWp  = @($prev.wingetPath -split ';' | Where-Object { $_ })
            $curWp   = @($curWinget       -split ';' | Where-Object { $_ })
            $added   = @($curWp  | Where-Object { $_ -notin $prevWp })
            $removed = @($prevWp | Where-Object { $_ -notin $curWp  })
            $parts   = @()
            if ($added.Count)   { $parts += "WINGET_PATH +$($added.Count)" }
            if ($removed.Count) { $parts += "WINGET_PATH -$($removed.Count)" }
            $prevRef = $prev.userPath -match '%WINGET_PATH%'
            $curRef  = $rawPath      -match '%WINGET_PATH%'
            if (-not $prevRef -and $curRef) { $parts += 'PATH 新增引用' }
            if ($prevRef -and -not $curRef) { $parts += 'PATH 移除引用' }
            $Description = if ($parts.Count) { $parts -join '，' } else { '无变化' }
        }
    }

    $entry = [ordered]@{
        timestamp   = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        type        = $Type
        description = $Description
        userPath    = $rawPath
        wingetPath  = $curWinget
    }

    $backups = [object[]](@($entry) + $backups | Select-Object -First $script:_MaxBackups)
    $json    = ConvertTo-Json -InputObject $backups -Depth 3

    # 写入时重试（应对杀毒软件短暂占锁）
    $saved = $false
    for ($i = 0; $i -lt 5 -and -not $saved; $i++) {
        try {
            [System.IO.File]::WriteAllText($script:_BackupFile, $json, [System.Text.Encoding]::UTF8)
            $saved = $true
        } catch [System.IO.IOException] {
            Start-Sleep -Milliseconds (100 * [math]::Pow(2, $i))
        }
    }
    if (-not $saved) { Write-Warning "备份文件写入失败（文件持续被占用）。"; return }
    Write-Host "备份已创建：[$Type] $($entry.description)" -ForegroundColor DarkGray
}

Set-Alias -Name backupwp -Value Backup-WingetPath -Scope Global


function global:Restore-WingetPath {
    <#
    .SYNOPSIS
        恢复 User PATH 和 WINGET_PATH 至指定备份。
    .EXAMPLE
        restwp
        列出备份并交互选择。
    .EXAMPLE
        restwp -List
        仅列出备份，不做恢复。
    .EXAMPLE
        restwp -Index 0
        直接恢复最新备份（无需交互）。
    .EXAMPLE
        restwp -WhatIf
        预览恢复操作，不做实际修改。
    .NOTES
        别名：restwp
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Alias('l')] [switch]$List,
        [Alias('i')] [int]$Index = -1,
        [Alias('h')] [switch]$Help
    )

    if ($Help) {
        Write-Host
        Write-Host "用法：" -ForegroundColor Cyan
        Write-Host "  restwp              列出备份并交互选择"
        Write-Host "  restwp -List / -l   仅列出备份"
        Write-Host "  restwp -Index N     直接恢复编号 N 的备份"
        Write-Host "  restwp -WhatIf      预览，不做实际修改"
        Write-Host "  restwp -Help / -h   显示此帮助"
        Write-Host
        Write-Host "备份文件：" -ForegroundColor Cyan
        Write-Host "  $($script:_BackupFile)" -ForegroundColor DarkGray
        Write-Host
        return
    }

    if (-not (Test-Path $script:_BackupFile)) {
        Write-Host "无备份记录（文件不存在）。" -ForegroundColor Yellow
        return
    }

    $backups = @()
    try   { $backups = @(Get-Content $script:_BackupFile -Raw -Encoding UTF8 | ConvertFrom-Json) }
    catch { Write-Host "备份文件解析失败：$_" -ForegroundColor Red; return }

    if ($backups.Count -eq 0) {
        Write-Host "无备份记录。" -ForegroundColor Yellow
        return
    }

    $printList = {
        Write-Host "备份列表：" -ForegroundColor Cyan
        for ($i = 0; $i -lt $backups.Count; $i++) {
            $b       = $backups[$i]
            $wpCount = ($b.wingetPath -split ';' | Where-Object { $_ }).Count
            $refTag  = if ($b.userPath -match '%WINGET_PATH%') { ' [含引用]' } else { '' }
            $typeTag = if ($b.type -eq 'auto') { '[自动]' } else { '[手动]' }
            $desc    = if ($b.description) { $b.description } else { '' }
            $mark    = if ($i -eq 0) { ' ← 最新' } else { '' }
            Write-Host ("  [{0}] {1} {2}  {3}  WINGET_PATH: {4} 条{5}{6}" -f $i, $b.timestamp, $typeTag, $desc, $wpCount, $refTag, $mark)
        }
    }

    if ($List) { & $printList; return }

    if ($Index -eq -1) {
        & $printList
        Write-Host
        $sel = Read-Host "请输入要恢复的编号（Enter 取消）"
        if ($sel -eq '') { Write-Host "已取消。" -ForegroundColor DarkGray; return }
        if ($sel -notmatch '^\d+$') { Write-Host "无效输入。" -ForegroundColor Red; return }
        $Index = [int]$sel
    }

    if ($Index -lt 0 -or $Index -ge $backups.Count) {
        Write-Host "编号 $Index 不存在。" -ForegroundColor Red
        return
    }

    $backup  = $backups[$Index]
    $wpCount = ($backup.wingetPath -split ';' | Where-Object { $_ }).Count
    Write-Host "恢复备份 [$Index] $($backup.timestamp)（WINGET_PATH: $wpCount 条）..." -ForegroundColor Yellow

    if ($PSCmdlet.ShouldProcess('User 环境变量', "恢复 PATH 和 WINGET_PATH 至 $($backup.timestamp)")) {
        $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
        $regKey.SetValue('Path', $backup.userPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        $regKey.Close()

        [System.Environment]::SetEnvironmentVariable('WINGET_PATH', $backup.wingetPath, 'User')

        $env:WINGET_PATH = $backup.wingetPath
        $machinePath     = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') ?? ''
        $expandedUser    = [System.Environment]::ExpandEnvironmentVariables($backup.userPath)
        $env:Path        = ($machinePath, $expandedUser | Where-Object { $_ }) -join ';'

        Write-Host "已恢复。建议执行 reenv 刷新所有环境变量。" -ForegroundColor Green
    }
}

Set-Alias -Name restwp -Value Restore-WingetPath -Scope Global


function global:Sync-WingetPath {
    <#
    .SYNOPSIS
        扫描 User PATH，将 winget 管理的路径迁移到 WINGET_PATH 环境变量。
    .DESCRIPTION
        识别 User PATH 中属于已知 winget 安装目录的条目，将其从 PATH 移除，
        追加到 WINGET_PATH 并持久化（写入注册表）。同时刷新当前会话的 $env:Path。
        写操作前自动创建备份，可用 restwp 恢复。
    .EXAMPLE
        syncwp
        迁移所有检测到的 winget 路径。
    .EXAMPLE
        syncwp -WhatIf
        预览将要迁移的路径，不做任何实际修改。
    .EXAMPLE
        restwp -List
        查看所有备份记录。
    .NOTES
        别名：syncwp
        备份/恢复：backupwp / restwp
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Alias('h')]
        [switch]$Help
    )

    if ($Help) {
        Write-Host
        Write-Host "用法：" -ForegroundColor Cyan
        Write-Host "  syncwp              扫描 User PATH，将 winget 路径迁移到 WINGET_PATH（持久化）"
        Write-Host "  syncwp -WhatIf      预览将要迁移的路径，不做实际修改"
        Write-Host "  syncwp -Help / -h   显示此帮助"
        Write-Host
        Write-Host "备份 / 恢复：" -ForegroundColor Cyan
        Write-Host "  backupwp            手动创建备份快照"
        Write-Host "  restwp -List        列出所有备份"
        Write-Host "  restwp [-Index N]   恢复指定备份（省略则交互选择）"
        Write-Host
        Write-Host "检测根目录（\$script:_WingetRoots）：" -ForegroundColor Cyan
        $script:_WingetRoots | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
        Write-Host
        Write-Host "查看当前 WINGET_PATH：" -ForegroundColor Cyan
        Write-Host "  `$env:WINGET_PATH -split ';'"
        Write-Host
        return
    }

    $roots = $script:_WingetRoots

    # 读取原始 User PATH（不展开 %VAR%，保留 %WINGET_PATH% 字面引用）
    $regKey      = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
    $rawUserPath = $regKey.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    $regKey.Close()

    $wingetPath    = [System.Environment]::GetEnvironmentVariable('WINGET_PATH', 'User') ?? ''
    $allEntries    = $rawUserPath  -split ';' | Where-Object { $_ -ne '' }
    $wingetEntries = $wingetPath   -split ';' | Where-Object { $_ -ne '' }

    # 剔除已有的 %WINGET_PATH% 引用，只对真实路径做检测
    $alreadyRef  = $allEntries -contains '%WINGET_PATH%'
    $realEntries = $allEntries | Where-Object { $_ -ne '%WINGET_PATH%' }

    $keep   = [System.Collections.Generic.List[string]]::new()
    $moving = [System.Collections.Generic.List[string]]::new()

    foreach ($entry in $realEntries) {
        $expanded = [System.Environment]::ExpandEnvironmentVariables($entry)
        $isWinget = $roots | Where-Object {
            $expanded.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase)
        }
        if ($isWinget) { $moving.Add($entry) } else { $keep.Add($entry) }
    }

    if ($moving.Count -eq 0) {
        if ($wingetEntries.Count -gt 0 -and -not $alreadyRef) {
            Write-Host "WINGET_PATH 已有 $($wingetEntries.Count) 条，但 User PATH 未引用 %WINGET_PATH%，正在补充..." -ForegroundColor Yellow
            $keepStr     = $realEntries -join ';'
            $newUserPath = if ($keepStr) { "$keepStr;%WINGET_PATH%" } else { '%WINGET_PATH%' }
            if ($PSCmdlet.ShouldProcess('User PATH', '写入 %WINGET_PATH% 引用')) {
                Backup-WingetPath -Type auto -Description "补写 %WINGET_PATH% 引用（$($wingetEntries.Count) 条）"
                $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
                $regKey.SetValue('Path', $newUserPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
                $regKey.Close()
                Write-Host "完成 — User PATH 已写入 %WINGET_PATH% 引用（$($wingetEntries.Count) 条）。" -ForegroundColor Green
            }
            return
        }
        $ref = if ($alreadyRef) { "已含 %WINGET_PATH% 引用（$($wingetEntries.Count) 条）" } else { "无需迁移" }
        Write-Host "User PATH 中未检测到新的 winget 路径。WINGET_PATH：$ref" -ForegroundColor Cyan
        return
    }

    Write-Host "迁移 $($moving.Count) 条路径：PATH → WINGET_PATH" -ForegroundColor Yellow
    $moving | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

    $newWinget   = [string[]]($wingetEntries + $moving | Select-Object -Unique)
    $keepStr     = ($keep | Where-Object { $_ }) -join ';'
    $newUserPath = if ($keepStr) { "$keepStr;%WINGET_PATH%" } else { '%WINGET_PATH%' }

    if ($PSCmdlet.ShouldProcess('User 环境变量', "PATH 写入 %WINGET_PATH% 引用，移除 $($moving.Count) 条；WINGET_PATH 增加 $($moving.Count) 条")) {
        Backup-WingetPath -Type auto -Description "迁移 $($moving.Count) 条 winget 路径到 WINGET_PATH"
        $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
        $regKey.SetValue('Path', $newUserPath, [Microsoft.Win32.RegistryValueKind]::ExpandString)
        $regKey.Close()

        [System.Environment]::SetEnvironmentVariable('WINGET_PATH', ($newWinget -join ';'), 'User')

        $env:WINGET_PATH = $newWinget -join ';'
        $machinePath     = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') ?? ''
        $env:Path        = ($machinePath, $keepStr | Where-Object { $_ }) -join ';'
        Import-WingetPath

        Write-Host "完成 — WINGET_PATH：$($newWinget.Count) 条，PATH 减少 $($moving.Count) 条，已写入 %WINGET_PATH% 引用。" -ForegroundColor Green
    }
}

Set-Alias -Name syncwp -Value Sync-WingetPath -Scope Global
