. $PSScriptRoot\..\..\src\PesterInvoker\Public\Invoke-Tests.ps1 {
    . $PSScriptRoot\..\..\src\PesterInvoker\Public\Test-Utils.ps1

    if (!(Get-Module PSScriptAnalyzer -ErrorAction SilentlyContinue)) {
        Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force
    }

    $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
    $ModuleScriptPath = "$PSScriptRoot\..\..\src\$ModuleScriptName"
    $ModuleManifestName = "$ModuleScriptName.psd1"
    $ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

    Describe "$ModuleScriptName.Module.Base.Tests" {
        $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
        $ModuleScriptPath = "$PSScriptRoot\..\..\src\$ModuleScriptName"

        It 'imports successfully' {
            Write-Verbose "Import-Module -Name $($ModuleScriptPath)"
            { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
        }

        It 'passes default PSScriptAnalyzer rules' {

            Invoke-ScriptAnalyzer -Path $ModuleScriptPath | Should -BeNullOrEmpty
        }
    }

    Describe "$ModuleScriptName.Module.Manifest.Base.Tests" {
        #$ModuleManifestName = "$ModuleScriptName.psd1"
        #$ModuleManifestPath = "$PSScriptRoot\..\..\src\$ModuleManifestName"

        It 'passes Test-ModuleManifest' {

            Write-Output $ModuleManifestPath
            Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should -Be $true
        }
    }
}