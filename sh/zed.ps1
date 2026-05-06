################################################################################
# zed
# 解决 zed 编辑器在 Windows 上打开文件时总是新窗口的问题或者覆盖当前窗口的问题
# 如果 zed 已经在运行，并且用户尝试打开一个已经在 zed 中打开的目录，则在当前窗口中打开该目录
# 否则，在新窗口中打开该目录
$_zed = Get-Command zed -Type Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($_zed) {
    $Global:_ZedBin = $_zed.Source

    function global:zed {
        param([Parameter(ValueFromRemainingArguments)][string[]]$Paths)

        $pathArgs = @($Paths | Where-Object { $_ -notmatch '^-' })
        if ($Paths.Count -eq 0 -or
            ($Paths | Where-Object { $_ -match '^-' }) -or
            $pathArgs.Count -ne 1) {
            & $Global:_ZedBin @Paths
            return
        }

        $path = $pathArgs[0]
        $resolved = Resolve-Path $path -ErrorAction SilentlyContinue
        $fullPath = if ($resolved) { $resolved.Path } else { $path }

        if (Test-Path $fullPath -PathType Container) {
            if (-not $Global:_ZedWorkspaces) {
                $Global:_ZedWorkspaces = [System.Collections.Generic.HashSet[string]]::new(
                    [System.StringComparer]::OrdinalIgnoreCase)
            }

            $zedRunning = [bool](Get-Process zed -ErrorAction SilentlyContinue)
            if (-not $zedRunning) { $Global:_ZedWorkspaces.Clear() }

            if ($zedRunning -and $Global:_ZedWorkspaces.Contains($fullPath)) {
                & $Global:_ZedBin $fullPath
            } else {
                $Global:_ZedWorkspaces.Add($fullPath) | Out-Null
                & $Global:_ZedBin --new $fullPath
            }
        } else {
            & $Global:_ZedBin $fullPath
        }
    }
}
