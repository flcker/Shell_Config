################################################################################
# starship
$profileRoot = Split-Path $PSScriptRoot -Parent
$starshipConfigs = @(
    ""
    "$profileRoot\submodule\starship\starship_custom.toml",
    "$profileRoot\submodule\starship\starship_powerline.toml",
    "$profileRoot\submodule\starship\starship_plaintextsymbols.toml",
    "$profileRoot\submodule\starship\starship_nerdfontsymbols.toml",
    "$profileRoot\submodule\starship\starship_pastelpowerline.toml",
    "$profileRoot\submodule\starship\starship_nerdpowerline.toml"
)
$selectedConfig = Get-Random -InputObject $starshipConfigs
$env:STARSHIP_CONFIG = $selectedConfig
Invoke-Expression (&starship init powershell)

function global:Get-CurrentStarshipConfigName {
    switch ($env:STARSHIP_CONFIG) {
        "" { return "default" }
        "$profileRoot\submodule\starship\starship_custom.toml" { return "custom" }
        "$profileRoot\submodule\starship\starship_powerline.toml" { return "powerline" }
        "$profileRoot\submodule\starship\starship_plaintextsymbols.toml" { return "plaintextsymbols" }
        "$profileRoot\submodule\starship\starship_nerdfontsymbols.toml" { return "nerdfontsymbols" }
        "$profileRoot\submodule\starship\starship_pastelpowerline.toml" { return "pastelpowerline" }
        "$profileRoot\submodule\starship\starship_nerdpowerline.toml" { return "nerdpowerline" }
        default { return [System.IO.Path]::GetFileNameWithoutExtension($env:STARSHIP_CONFIG) }
    }
}

# Function to show usage instructions for switching starship configs
function global:Show-StarshipUsage {
    $currentConfig = Get-CurrentStarshipConfigName
    Write-Host @"
Switch-StarshipConfig (alias: ssc)
Current config:
    $currentConfig

Usage:
    ssc [-h] [Config]

Help:
    -h, -Help              - Show this help message

Config options:
    custom (c)             - Use starship_custom.toml
    powerline (pl)         - Use starship_powerline.toml
    plaintextsymbols (pts) - Use starship_plaintextsymbols.toml
    nerdfontsymbols (nfs)  - Use starship_nerdfontsymbols.toml
    pastelpowerline (ppl)  - Use starship_pastelpowerline.toml
    nerdpowerline (npl)    - Use starship_nerdpowerline.toml
    default (d)            - Use Starship's default config

Example:
    ssc powerline
    ssc nfs
    ssc d
"@ -ForegroundColor Cyan
}

function global:Switch-StarshipConfig {
    param(
        [ValidateSet("custom", "powerline", "plaintextsymbols", "nerdfontsymbols", "pastelpowerline", "nerdpowerline", "default", "c", "pl", "pts", "nfs", "ppl", "npl", "d")]
        [string]$Config = "default",
        [Alias("h")]
        [switch]$Help
    )

    if ($Help) {
        Show-StarshipUsage
        return
    }

    $configPaths = @{
        "custom" = "$profileRoot\submodule\starship\starship_custom.toml"
        "c" = "$profileRoot\submodule\starship\starship_custom.toml"
        "powerline" = "$profileRoot\submodule\starship\starship_powerline.toml"
        "pl" = "$profileRoot\submodule\starship\starship_powerline.toml"
        "plaintextsymbols" = "$profileRoot\submodule\starship\starship_plaintextsymbols.toml"
        "pts" = "$profileRoot\submodule\starship\starship_plaintextsymbols.toml"
        "nerdfontsymbols" = "$profileRoot\submodule\starship\starship_nerdfontsymbols.toml"
        "nfs" = "$profileRoot\submodule\starship\starship_nerdfontsymbols.toml"
        "pastelpowerline" = "$profileRoot\submodule\starship\starship_pastelpowerline.toml"
        "ppl" = "$profileRoot\submodule\starship\starship_pastelpowerline.toml"
        "nerdpowerline" = "$profileRoot\submodule\starship\starship_nerdpowerline.toml"
        "npl" = "$profileRoot\submodule\starship\starship_nerdpowerline.toml"
        "default" = ""
        "d" = ""
    }
    $env:STARSHIP_CONFIG = $configPaths[$Config]
    Invoke-Expression (&starship init powershell)
    Write-Host "Switched to starship config: $(Get-CurrentStarshipConfigName)" -ForegroundColor Green
}
Set-Alias -Name ssc -Value Switch-StarshipConfig -Scope Global
