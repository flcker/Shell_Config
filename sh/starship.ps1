################################################################################
# starship
$profileRoot = Split-Path $PSScriptRoot -Parent

# ── Config registry ───────────────────────────────────────────────────────────
$script:starshipRegistry = @{ "default" = ""; "d" = "" }
$script:starshipPool = @("")  # empty = starship default

# ── Detect submodule/starship (static configs) ────────────────────────────────
$staticDir = "$profileRoot\submodule\starship"
if (Test-Path $staticDir) {
    $staticMappings = @{
        "custom"           = "starship_custom.toml"
        "c"                = "starship_custom.toml"
        "powerline"        = "starship_powerline.toml"
        "pl"               = "starship_powerline.toml"
        "plaintextsymbols" = "starship_plaintextsymbols.toml"
        "pts"              = "starship_plaintextsymbols.toml"
        "nerdfontsymbols"  = "starship_nerdfontsymbols.toml"
        "nfs"              = "starship_nerdfontsymbols.toml"
        "pastelpowerline"  = "starship_pastelpowerline.toml"
        "ppl"              = "starship_pastelpowerline.toml"
        "nerdpowerline"    = "starship_nerdpowerline.toml"
        "npl"              = "starship_nerdpowerline.toml"
    }
    foreach ($entry in $staticMappings.GetEnumerator()) {
        $fullPath = Join-Path $staticDir $entry.Value
        if (Test-Path $fullPath) {
            $script:starshipRegistry[$entry.Key] = $fullPath
        }
    }
    $script:starshipPool += (
        $staticMappings.Values | Select-Object -Unique | ForEach-Object {
            $p = Join-Path $staticDir $_
            if (Test-Path $p) { $p }
        }
    )
}

# ── Detect submodule/starshipauto (generated configs) ─────────────────────────
$_autoModule = "$profileRoot\submodule\starshipauto\engines\pwsh\starshipauto.psm1"
if (Test-Path $_autoModule) {
    Import-Module $_autoModule -Global -ArgumentList $profileRoot
    $autoConfigs = Get-StarshipAutoConfigs
    foreach ($entry in $autoConfigs.GetEnumerator()) {
        $script:starshipRegistry[$entry.Key] = $entry.Value
        $script:starshipPool += $entry.Value
    }
    # Legacy aliases
    if ($autoConfigs.ContainsKey("p10k-powerline-rainbow")) {
        $script:starshipRegistry["p10kr"] = $autoConfigs["p10k-powerline-rainbow"]
        $script:starshipRegistry["p10krainbow"] = $autoConfigs["p10k-powerline-rainbow"]
    }
    if ($autoConfigs.ContainsKey("p10k-powerline-classic")) {
        $script:starshipRegistry["p10kc"] = $autoConfigs["p10k-powerline-classic"]
        $script:starshipRegistry["p10kclassic"] = $autoConfigs["p10k-powerline-classic"]
    }
    if ($autoConfigs.ContainsKey("p10k-lean-lean")) {
        $script:starshipRegistry["p10kl"] = $autoConfigs["p10k-lean-lean"]
        $script:starshipRegistry["p10klean"] = $autoConfigs["p10k-lean-lean"]
    }
}

# ── Random selection ──────────────────────────────────────────────────────────
$env:STARSHIP_CONFIG = Get-Random -InputObject $script:starshipPool

# ── Functions ─────────────────────────────────────────────────────────────────
function global:Get-CurrentStarshipConfigName {
    if (-not $env:STARSHIP_CONFIG) { return "default" }
    foreach ($entry in $script:starshipRegistry.GetEnumerator()) {
        if ($entry.Value -eq $env:STARSHIP_CONFIG -and $entry.Key.Length -gt 3) {
            return $entry.Key
        }
    }
    return [System.IO.Path]::GetFileNameWithoutExtension($env:STARSHIP_CONFIG)
}

function global:Show-StarshipUsage {
    $currentConfig = Get-CurrentStarshipConfigName
    Write-Host "Switch-StarshipConfig (alias: ssc)" -ForegroundColor Cyan
    Write-Host "Current: $currentConfig" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: ssc [-h | --help] [-l | --list] [-r | --rebuild] [Config]" -ForegroundColor Cyan
    Write-Host ""

    # Helper: group keys by path, show canonical (longest) + aliases
    $formatGroup = {
        param($registry)
        $pathToKeys = @{}
        foreach ($entry in $registry.GetEnumerator()) {
            $path = $entry.Value
            if (-not $pathToKeys.ContainsKey($path)) { $pathToKeys[$path] = @() }
            $pathToKeys[$path] += $entry.Key
        }
        $pathToKeys.GetEnumerator() | Sort-Object { ($_.Value | Sort-Object { $_.Length } | Select-Object -Last 1) } | ForEach-Object {
            $keys = $_.Value | Sort-Object { $_.Length }
            $canonical = $keys[-1]
            $aliases = ($keys | Where-Object { $_ -ne $canonical }) -join ', '
            $marker = if ($_.Key -eq $env:STARSHIP_CONFIG) { " *" } else { "" }
            $aliasStr = if ($aliases) { " ($aliases)" } else { "" }
            Write-Host "    ${canonical}${aliasStr}${marker}" -ForegroundColor Cyan
        }
    }

    # starshipauto generated configs
    if (Get-Module starshipauto) {
        $autoRegistry = @{}
        $autoConfigs = Get-StarshipAutoConfigs
        foreach ($entry in $autoConfigs.GetEnumerator()) {
            $autoRegistry[$entry.Key] = $entry.Value
        }
        # Include legacy aliases that point to generated paths
        foreach ($entry in $script:starshipRegistry.GetEnumerator()) {
            if ($entry.Value -and $autoConfigs.Values -contains $entry.Value -and -not $autoRegistry.ContainsKey($entry.Key)) {
                $autoRegistry[$entry.Key] = $entry.Value
            }
        }
        if ($autoRegistry.Count -gt 0) {
            Write-Host "starshipauto:" -ForegroundColor Yellow
            & $formatGroup $autoRegistry
            Write-Host ""
        }
    }

    # starship static configs
    $staticRegistry = @{}
    foreach ($entry in $script:starshipRegistry.GetEnumerator()) {
        $isAuto = $false
        if (Get-Module starshipauto) {
            $autoConfigs = Get-StarshipAutoConfigs
            if ($autoConfigs.Values -contains $entry.Value) { $isAuto = $true }
        }
        if (-not $isAuto) {
            $staticRegistry[$entry.Key] = $entry.Value
        }
    }
    if ($staticRegistry.Count -gt 0) {
        Write-Host "starship:" -ForegroundColor Yellow
        & $formatGroup $staticRegistry
        Write-Host ""
    }

    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "    --list,  -l            - List all config keys" -ForegroundColor Cyan
    if (Get-Module starshipauto) {
        Write-Host "    --rebuild, -r          - Regenerate starshipauto configs" -ForegroundColor Cyan
    }
}

function global:Switch-StarshipConfig {
    param(
        [Parameter(Position = 0)]
        [string]$Config = "",
        [Alias("h")]
        [switch]$Help,
        [switch]$List,
        [switch]$Rebuild
    )

    # Handle -- style arguments passed as positional $Config
    if ($Config -in '--help', '-h') { $Help = $true; $Config = "" }
    if ($Config -in '--list', '-l') { $List = $true; $Config = "" }
    if ($Config -in '--rebuild', '-r') { $Rebuild = $true; $Config = "" }

    if ($Help -or (-not $Config -and -not $List -and -not $Rebuild)) {
        Show-StarshipUsage
        return
    }

    if ($Rebuild) {
        if (Get-Module starshipauto) {
            $success = Invoke-StarshipAutoBuild
            if ($success) {
                $autoConfigs = Get-StarshipAutoConfigs
                foreach ($entry in $autoConfigs.GetEnumerator()) {
                    $script:starshipRegistry[$entry.Key] = $entry.Value
                }
                Write-Host "Configs regenerated." -ForegroundColor Green
            }
        } else {
            Write-Warning "starshipauto module not loaded."
        }
        return
    }

    if ($List) {
        Write-Host "Available configs:" -ForegroundColor Yellow
        $script:starshipRegistry.Keys | Sort-Object | ForEach-Object {
            $marker = if ($script:starshipRegistry[$_] -eq $env:STARSHIP_CONFIG) { " *" } else { "" }
            Write-Host "  $_$marker" -ForegroundColor Cyan
        }
        return
    }

    if (-not $script:starshipRegistry.ContainsKey($Config)) {
        Write-Warning "Unknown config: '$Config'. Use 'ssc --list' to see available options."
        return
    }

    $env:STARSHIP_CONFIG = $script:starshipRegistry[$Config]
    Invoke-Expression (&starship init powershell)
    Write-Host "Switched to: $(Get-CurrentStarshipConfigName)" -ForegroundColor Green
}

Set-Alias -Name ssc -Value Switch-StarshipConfig -Scope Global

# ── Init ──────────────────────────────────────────────────────────────────────
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt
