################################################################################
# functions and aliases

# refresh profile without restart terminal
function global:repwsh { . $PROFILE }


# http proxy
function global:set_proxy_fun {
    $env:HTTP_PROXY = "http://127.0.0.1:7890"
    $env:HTTPS_PROXY = "http://127.0.0.1:7890"
    # $env:ALL_PROXY = "socks5://127.0.0.1:7890"
}
Set-Alias -Name setproxy -Value set_proxy_fun -Scope Global

function global:unset_proxy_fun {
    Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
}
Set-Alias -Name unsetproxy -Value unset_proxy_fun -Scope Global


# Batch alias registration helper for direct command names.
function global:Set-AliasBatch {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$AliasMap,
        [System.Management.Automation.ScopedItemOptions]$Option = [System.Management.Automation.ScopedItemOptions]::AllScope
    )

    foreach ($name in $AliasMap.Keys) {
        $spec = $AliasMap[$name]

        if ($spec -is [string]) {
            Set-Alias -Name $name -Value $spec -Option $Option -Scope Global -Force
            continue
        }

        $items = @($spec)
        if ($items.Count -lt 1) { continue }

        $commandName = $items[0]
        [object[]]$fixedArgs = if ($items.Count -gt 1) { @($items[1..($items.Count - 1)]) } else { @() }
        $proxyFunctionName = "__alias_$name"

        # Copy values per alias so closures do not share loop variables.
        $cmd = $commandName
        [object[]]$presetArgs = @($fixedArgs)

        $proxy = {
            param([Parameter(ValueFromRemainingArguments = $true)]$RemainingArgs)
            & $cmd @presetArgs @RemainingArgs
        }.GetNewClosure()

        Set-Item -Path "Function:Global:$proxyFunctionName" -Value $proxy -Force
        Set-Alias -Name $name -Value $proxyFunctionName -Option $Option -Scope Global -Force
    }
}


# lsd aliases
Set-AliasBatch @{
    ls    = @('lsd.exe')
    ll    = @('lsd.exe', '-alF')
    la    = @('lsd.exe', '-a')
    lr    = @('lsd.exe', '-R')
}


# git aliases
Set-AliasBatch @{
    gs   = @('git', 'status')
    ga   = @('git', 'add')
    gc   = @('git', 'commit')
    gca  = @('git', 'commit', '--amend')
    gp   = @('git', 'push')
    gl   = @('git', 'log')
    gco  = @('git', 'checkout')
    gb   = @('git', 'branch')
    gd   = @('git', 'diff')
    gpl  = @('git', 'pull')
    gcl  = @('git', 'clone')
    gcm  = @('git', 'commit', '-m')
    gst  = @('git', 'stash')
    gsta = @('git', 'stash', 'apply')
    gsp  = @('git', 'stash', 'pop')
    gr   = @('git', 'remote')
    grv  = @('git', 'remote', '-v')
    gsw  = @('git', 'switch')
    gsu  = @('git', 'submodule', 'update', '--init', '--recursive')
    gwt  = @('git', 'worktree')
}


# other aliases
Set-AliasBatch @{
    clcb  = @('Set-Clipboard', '')
    '~'   = 'Set-Location'
    grep  = 'Select-String'
    rm    = 'Remove-Item'
    mv    = 'Move-Item'
    cp    = 'Copy-Item'
    mkdir = 'New-Item'
    rmdir = 'Remove-Item'
    touch = 'New-Item'
    find  = 'Get-ChildItem'
    cat   = 'bat.exe'
    htop  = 'pstop'
    zo    = 'zoxide'
    lg    = 'lazygit'
    btop  = 'btop4win'
}
