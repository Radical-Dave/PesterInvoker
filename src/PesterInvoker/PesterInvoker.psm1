Set-StrictMode -Version Latest

#Requires -RunAsAdministrator

# Get Functions
$private = @()
if(Test-Path(Join-Path $PSScriptRoot Private)) {
    $private = @(Get-ChildItem -Path (Join-Path $PSScriptRoot Private) -Include *.ps1 -File -Recurse)
}
$public = @(Get-ChildItem -Path (Join-Path $PSScriptRoot Public) -Include *.ps1 -File -Recurse)

# Dot source to scope
# Private must be sourced first - usage in public functions during load
($private + $public) | ForEach-Object {
    try {
        if($_.FullName.EndsWith(".psd1")) { return }
        . $_.FullName
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}