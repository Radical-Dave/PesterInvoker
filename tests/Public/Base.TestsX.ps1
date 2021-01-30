$ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
$ModuleScriptPath = Join-Path $PSScriptRoot "../../src/$ModuleScriptName.psm1"
Get-Module $ModuleScriptName | Remove-Module -Force
Import-Module $ModuleScriptPath
InModuleScope $ModuleScriptName {
    $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
    $ModuleScriptPath = Join-Path $PSScriptRoot "../../src/$ModuleScriptName.psm1"
    Describe "$ModuleScriptName.Module.Base.Tests" {
        $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
        $ModuleScriptPath = Join-Path $PSScriptRoot "../../src/$ModuleScriptName"
        It 'imports successfully' {
            $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
            $ModuleScriptPath = Join-Path $PSScriptRoot "../../src/$ModuleScriptName"
            Write-Verbose "Import-Module -Name $($ModuleScriptPath)"
            { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
        }
        It 'passes default PSScriptAnalyzer rules' {
            $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
            $ModuleScriptPath = Join-Path $PSScriptRoot "../../src/$ModuleScriptName"
            Invoke-ScriptAnalyzer -Path $ModuleScriptPath | Should -BeNullOrEmpty
        }
    }

    Describe "$ModuleScriptName.Module.Manifest.Base.Tests" {
        It 'passes Test-ModuleManifest' {
            $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
            $ModuleManifestName = "$ModuleScriptName.psd1"
            $ModuleManifestPath = Join-Path $PSScriptRoot "../../src/$ModuleManifestName"
            Write-Verbose $ModuleManifestPath
            Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should -Be $true
        }
    }
}