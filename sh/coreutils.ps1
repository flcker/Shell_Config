################################################################################
# coreutils.ps1 加载配置

# coreutils 兼容GNU coreutils 的 Rust 版本，提供一些常用的命令行工具，如 ls、cat、cp 等，增强 PowerShell 的功能和用户体验。
# 但是会与 PowerShell 内置命令或者Alias冲突，所以需要先检查相关工具是否存在，然后覆盖PowerShell内置命令的Alias。

$script:coreutilsKnownCommands = @(
    'arch',
    'b2sum',
    'base32',
    'base64',
    'basename',
    'basenc',
    'cat',
    'cksum',
    'comm',
    'cp',
    'csplit',
    'cut',
    'date',
    'dd',
    'df',
    'dir',
    'dircolors',
    'dirname',
    'du',
    'echo',
    'env',
    'expand',
    'expr',
    'factor',
    'false',
    'fmt',
    'fold',
    'head',
    'hostname',
    'join',
    'link',
    'ln',
    'ls',
    'md5sum',
    'mkdir',
    'mktemp',
    'more',
    'mv',
    'nl',
    'nproc',
    'numfmt',
    'od',
    'paste',
    'pathchk',
    'pr',
    'printenv',
    'printf',
    'ptx',
    'pwd',
    'readlink',
    'realpath',
    'rm',
    'rmdir',
    'seq',
    'sha1sum',
    'sha224sum',
    'sha256sum',
    'sha384sum',
    'sha512sum',
    'shred',
    'shuf',
    'sleep',
    'sort',
    'split',
    'sum',
    'sync',
    'tac',
    'tail',
    'tee',
    'test',
    'touch',
    'tr',
    'true',
    'truncate',
    'tsort',
    'uname',
    'unexpand',
    'uniq',
    'unlink',
    'vdir',
    'wc',
    'whoami',
    'yes'
)

$script:coreutilsCommandCategories = [ordered]@{
    '文件与路径' = @(
        'basename',
        'dirname',
        'cp',
        'mv',
        'rm',
        'mkdir',
        'rmdir',
        'ln',
        'link',
        'unlink',
        'readlink',
        'realpath',
        'touch',
        'mktemp',
        'ls',
        'dir',
        'vdir',
        'pwd',
        'pathchk',
        'truncate',
        'sync'
    )
    '文本与输出' = @(
        'cat',
        'head',
        'tail',
        'tac',
        'nl',
        'more',
        'pr',
        'fmt',
        'fold',
        'expand',
        'unexpand',
        'cut',
        'paste',
        'join',
        'comm',
        'uniq',
        'sort',
        'split',
        'csplit',
        'wc',
        'tee',
        'ptx',
        'od',
        'tr'
    )
    '编码与校验' = @(
        'base32',
        'base64',
        'basenc',
        'cksum',
        'sum',
        'md5sum',
        'sha1sum',
        'sha224sum',
        'sha256sum',
        'sha384sum',
        'sha512sum',
        'b2sum'
    )
    '系统与环境' = @(
        'arch',
        'hostname',
        'uname',
        'whoami',
        'nproc',
        'date',
        'env',
        'printenv',
        'dircolors',
        'df',
        'du'
    )
    '执行与控制' = @(
        'true',
        'false',
        'sleep',
        'test'
    )
    '数据与计算' = @(
        'dd',
        'expr',
        'factor',
        'printf',
        'echo',
        'numfmt',
        'seq',
        'shuf',
        'shred',
        'tsort',
        'yes'
    )
}

$script:coreutilsCategoryAliases = @{
    '文件与路径' = '文件与路径'
    'fs'         = '文件与路径'
    'f'          = '文件与路径'
    '文本与输出' = '文本与输出'
    'text'       = '文本与输出'
    't'          = '文本与输出'
    '编码与校验' = '编码与校验'
    'hash'       = '编码与校验'
    'h'          = '编码与校验'
    '系统与环境' = '系统与环境'
    'sys'        = '系统与环境'
    's'          = '系统与环境'
    '执行与控制' = '执行与控制'
    'exec'       = '执行与控制'
    'x'          = '执行与控制'
    '数据与计算' = '数据与计算'
    'data'       = '数据与计算'
    'd'          = '数据与计算'
}

function global:Test-CoreutilsInstallDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path -PathType Container)) {
        return $false
    }

    foreach ($readmePath in @(
        (Join-Path $Path 'README.package.md'),
        (Join-Path $Path 'README.md')
    )) {
        if (-not (Test-Path $readmePath -PathType Leaf)) {
            continue
        }

        $preview = Get-Content $readmePath -TotalCount 10 -ErrorAction SilentlyContinue
        if (($preview -join "`n") -match 'coreutils') {
            return $true
        }
    }

    return (Test-Path (Join-Path $Path 'basename.exe') -PathType Leaf) -and
        (Test-Path (Join-Path $Path 'sha256sum.exe') -PathType Leaf) -and
        (Test-Path (Join-Path $Path 'yes.exe') -PathType Leaf)
}

function global:Get-CoreutilsInstallDirectory {
    $pathCandidate = Get-Command 'basename.exe' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($pathCandidate) {
        $pathDir = Split-Path $pathCandidate.Source -Parent
        if (Test-CoreutilsInstallDirectory -Path $pathDir) {
            return $pathDir
        }
    }

    $wingetPackagesRoot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
    if (-not (Test-Path $wingetPackagesRoot -PathType Container)) {
        return $null
    }

    $packageDir = Get-ChildItem $wingetPackagesRoot -Directory -Filter 'uutils.coreutils*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if (-not $packageDir) {
        return $null
    }

    $installDir = Get-ChildItem $packageDir.FullName -Directory -Filter 'coreutils-*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        Select-Object -First 1
    if (-not $installDir) {
        return $null
    }

    if (Test-CoreutilsInstallDirectory -Path $installDir.FullName) {
        return $installDir.FullName
    }

    return $null
}

function global:Get-CoreutilsExecutable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName,
        [string]$InstallDirectory
    )

    $application = Get-Command "$CommandName.exe" -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($application) {
        $appDir = Split-Path $application.Source -Parent
        if (Test-CoreutilsInstallDirectory -Path $appDir) {
            return $application
        }
    }

    $fallbackDir = if ($InstallDirectory) { $InstallDirectory } else { Get-CoreutilsInstallDirectory }
    if (-not $fallbackDir) {
        return $null
    }

    $exePath = Join-Path $fallbackDir "$CommandName.exe"
    if (-not (Test-Path $exePath -PathType Leaf)) {
        return $null
    }

    Get-Item $exePath
}

function global:Resolve-CoreutilsCategory {
    param([string]$Category)

    if (-not $Category) {
        return $null
    }

    $normalized = $Category.Trim().ToLowerInvariant()
    foreach ($key in $script:coreutilsCategoryAliases.Keys) {
        if ($key.ToLowerInvariant() -eq $normalized) {
            return $script:coreutilsCategoryAliases[$key]
        }
    }

    throw "未知分类：$Category。可用分类：文件与路径(fs)、文本与输出(text)、编码与校验(hash)、系统与环境(sys)、执行与控制(exec)、数据与计算(data)"
}

function global:Get-CoreutilsCommandCatalog {
    param(
        [Alias('c')]
        [string]$Category,
        [Alias('a')]
        [switch]$AvailableOnly
    )

    $categories = $script:coreutilsCommandCategories.Keys
    if ($Category) {
        $resolvedCategory = Resolve-CoreutilsCategory -Category $Category
        $categories = @($categories | Where-Object { $_ -eq $resolvedCategory })
    }

    $installDir = Get-CoreutilsInstallDirectory

    $commands = foreach ($categoryName in $categories) {
        foreach ($commandName in $script:coreutilsCommandCategories[$categoryName]) {
            $application = Get-CoreutilsExecutable -CommandName $commandName -InstallDirectory $installDir
            [PSCustomObject]@{
                Category  = $categoryName
                Name      = $commandName
                Available = $null -ne $application
            }
        }
    }

    if ($AvailableOnly) {
        $commands = $commands | Where-Object Available
    }

    $commands
}

function global:Get-CoreutilsCommands {
    param(
        [Alias('c')]
        [string]$Category,
        [Alias('a')]
        [switch]$AvailableOnly
    )

    Get-CoreutilsCommandCatalog -Category $Category -AvailableOnly:$AvailableOnly |
        Select-Object Category, Name, Available
}

function global:Show-CoreutilsCommands {
    param(
        [Alias('c')]
        [string]$Category,
        [Alias('a')]
        [switch]$AvailableOnly
    )

    $commands = @(Get-CoreutilsCommandCatalog -Category $Category -AvailableOnly:$AvailableOnly)
    if ($commands.Count -eq 0) {
        Write-Host '没有匹配的 coreutils 命令。' -ForegroundColor Yellow
        return
    }

    $cols    = 6
    $colW    = 12
    $totalOk = @($commands | Where-Object Available).Count
    $totalAll = $commands.Count

    if (-not $Category) {
        Write-Host "gcu [-a] [-c <fs|text|hash|sys|exec|data>] [command]" -ForegroundColor DarkGray
        Write-Host ''
    }

    foreach ($categoryName in $script:coreutilsCommandCategories.Keys) {
        $group = @($commands | Where-Object Category -eq $categoryName)
        if ($group.Count -eq 0) { continue }

        $short = switch ($categoryName) {
            '文件与路径' { 'fs' }
            '文本与输出' { 'text' }
            '编码与校验' { 'hash' }
            '系统与环境' { 'sys' }
            '执行与控制' { 'exec' }
            '数据与计算' { 'data' }
            default      { '' }
        }
        $groupOk = @($group | Where-Object Available).Count
        $header = if ($short) { "{0} ({1})  {2}/{3}" -f $categoryName, $short, $groupOk, $group.Count } else { "{0}  {1}/{2}" -f $categoryName, $groupOk, $group.Count }
        Write-Host $header -ForegroundColor Cyan

        for ($i = 0; $i -lt $group.Count; $i += $cols) {
            $end = [Math]::Min($i + $cols, $group.Count) - 1
            foreach ($cmd in $group[$i..$end]) {
                $cell = $cmd.Name.PadRight($colW)
                if ($cmd.Available) {
                    Write-Host $cell -NoNewline -ForegroundColor Green
                } else {
                    Write-Host $cell -NoNewline -ForegroundColor DarkGray
                }
            }
            Write-Host ''
        }
        Write-Host ''
    }

    Write-Host ("{0}/{1} available" -f $totalOk, $totalAll) -ForegroundColor DarkGray
}

function global:Get-CoreutilsUsage {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CommandName
    )

    if (-not ($script:coreutilsKnownCommands -contains $CommandName)) {
        throw "未知命令：$CommandName。使用 gcu 查看支持的 coreutils 命令。"
    }

    $application = Get-CoreutilsExecutable -CommandName $CommandName
    if (-not $application) {
        throw "未找到 $CommandName 对应的 coreutils 可执行文件。"
    }

    $commandPath = if ($application.PSObject.Properties.Match('Source').Count -gt 0) {
        $application.Source
    } else {
        $application.FullName
    }

    & $commandPath --help
}

function global:Show-Coreutils {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param(
        [Parameter(ParameterSetName = 'Usage', Position = 0)]
        [string]$CommandName,
        [Parameter(ParameterSetName = 'List')]
        [Alias('c')]
        [string]$Category,
        [Parameter(ParameterSetName = 'List')]
        [Alias('a')]
        [switch]$AvailableOnly
    )

    if ($PSCmdlet.ParameterSetName -eq 'Usage' -and $CommandName) {
        Get-CoreutilsUsage -CommandName $CommandName
        return
    }

    Show-CoreutilsCommands -Category $Category -AvailableOnly:$AvailableOnly
}

Set-Alias -Name gcu -Value Show-Coreutils -Scope Global -Force
Set-Alias -Name gcuu -Value Get-CoreutilsUsage -Scope Global -Force

$coreutilsAliasCandidates = @(
    # 'ls', # lsd 已经覆盖了 ls 的功能，且提供了更多选项，所以不设置 ls 的别名。
    'dir',
    # 'cat', # bat 已经覆盖了 cat 的功能，且提供了更好的输出格式，所以不设置 cat 的别名。
    'cp',
    'mv',
    'rm',
    'mkdir',
    'rmdir',
    'touch',
    'pwd',
    'echo',
    'sleep'
    # sort/tee 不覆盖：PowerShell 的 Sort-Object/Tee-Object 支持对象管道，覆盖后管道排序/分流会失效
)

$coreutilsAliasMap = @{}
$cachedInstallDir = Get-CoreutilsInstallDirectory

foreach ($commandName in $coreutilsAliasCandidates) {
    $application = Get-CoreutilsExecutable -CommandName $commandName -InstallDirectory $cachedInstallDir
    if (-not $application) {
        continue
    }

    $resolved = Get-Command $commandName -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $resolved -or $resolved.CommandType -eq [System.Management.Automation.CommandTypes]::Application) {
        continue
    }

    $coreutilsAliasMap[$commandName] = if ($application.Source) { $application.Source } else { $application.FullName }
}

if ($coreutilsAliasMap.Count -gt 0) {
    Set-AliasBatch $coreutilsAliasMap
}
