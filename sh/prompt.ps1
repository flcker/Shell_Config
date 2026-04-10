################################################################################
# windows title 
function global:prompt {
    $currentPath = (Get-Location).Path
    $shortPath = if ($currentPath -match '[^\\]+\\[^\\]+$') { $matches[0] } else { $currentPath }
    $Host.UI.RawUI.WindowTitle = "PS: $shortPath"
    "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}
