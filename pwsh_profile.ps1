# 这个文件是 PowerShell 的本仓库配置的入口文件
# 需要在 Microsoft.PowerShell_profile.ps1 中加载这个文件，以便在 PowerShell 中使用这些配置


# 输出当前目录调试信息，确保正确加载了配置文件
# Write-Host "Loading PowerShell profile"
# Write-Host "Current directory: $PSScriptRoot"

# 需要加载的ps list
$psFiles = @(
    "prompt",
    "starship",
    "modules",
    "aliases_and_functions",
    "nvim",
    "coreutils",
    "config"
)

# 循环加载每个 ps 文件
foreach ($psFile in $psFiles) {
    $filePath = Join-Path $PSScriptRoot "sh\$psFile.ps1"
    if (Test-Path $filePath) {
        . $filePath
        # Write-Host "Loaded $psFile" -ForegroundColor Green
    } else {
        Write-Host "Warning: $psFile not found at $filePath" -ForegroundColor Yellow
    }
}
