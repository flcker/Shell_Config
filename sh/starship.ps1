################################################################################
# starship
$profileRoot = Split-Path $PSScriptRoot -Parent
$starshipConfigs = @(
    ""
    "$profileRoot\submodule\starship\starship_custom.toml",
    "$profileRoot\submodule\starship\starship_powerline.toml",
    "$profileRoot\submodule\starship\starship_plaintextsymbols.toml",
    "$profileRoot\submodule\starship\starship_nerdfontsymbols.toml",
    "$profileRoot\submodule\starship\starship_pastelpowerline.toml"
)
$selectedConfig = Get-Random -InputObject $starshipConfigs
$env:STARSHIP_CONFIG = $selectedConfig
Invoke-Expression (&starship init powershell)

# Function to show usage instructions for switching starship configs
function global:Show-StarshipUsage {
    Write-Host @"
Switch-StarshipConfig (alias: ssc)
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
    default (d)            - Use Starship's default config

Example:
    ssc powerline
    ssc nfs
    ssc d
"@ -ForegroundColor Cyan
}

function global:Switch-StarshipConfig {
    param(
        [ValidateSet("custom", "powerline", "plaintextsymbols", "nerdfontsymbols", "pastelpowerline", "default", "c", "pl", "pts", "nfs", "ppl", "d")]
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
        "default" = ""
        "d" = ""
    }
    $env:STARSHIP_CONFIG = $configPaths[$Config]
    Invoke-Expression (&starship init powershell)
    Write-Host "Switched to starship config: $Config" -ForegroundColor Green
}
Set-Alias -Name ssc -Value Switch-StarshipConfig -Scope Global
