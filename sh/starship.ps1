################################################################################
# starship 
$profileRoot = Split-Path $PSScriptRoot -Parent
$starshipConfigs = @(
    "$profileRoot\submodule\starship\starship_custom.toml",
    "$profileRoot\submodule\starship\starship_powerline.toml",
    "$profileRoot\submodule\starship\starship_plaintextsymbols.toml",
    ""
)
$selectedConfig = Get-Random -InputObject $starshipConfigs
$env:STARSHIP_CONFIG = $selectedConfig
Invoke-Expression (&starship init powershell)

function Switch-StarshipConfig {
    param(
        [ValidateSet("custom", "powerline", "plaintextsymbols", "default", "c", "p", "t", "d")]
        [string]$Config = "default"
    )
    $configPaths = @{
        "custom" = "$profileRoot\submodule\starship\starship_custom.toml"
        "c" = "$profileRoot\submodule\starship\starship_custom.toml"
        "powerline" = "$profileRoot\submodule\starship\starship_powerline.toml"
        "p" = "$profileRoot\submodule\starship\starship_powerline.toml"
        "plaintextsymbols" = "$profileRoot\submodule\starship\starship_plaintextsymbols.toml"
        "t" = "$profileRoot\submodule\starship\starship_plaintextsymbols.toml"
        "default" = ""
        "d" = ""
    }
    $env:STARSHIP_CONFIG = $configPaths[$Config]
    Invoke-Expression (&starship init powershell)
    Write-Host "Switched to starship config: $Config" -ForegroundColor Green
}
Set-Alias ssc Switch-StarshipConfig
