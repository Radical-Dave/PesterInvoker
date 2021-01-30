$ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
Get-Module $ModuleScriptName | Remove-Module -Force
Import-Module $PSScriptRoot\src\$ModuleScriptName
InModuleScope $ModuleScriptName {
    Describe 'Invoke-Tests.Tests' {
        $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
        Write-Output "ModuleScriptName:$ModuleScriptName"
        #$ModuleScriptName = $PSScriptRoot | Split-Path -Parent -Parent -Leaf
        $ModuleScriptPath = Join-Path $PSScriptRoot "\..\..\src\$ModuleScriptName.psm1"
        Write-Output "ModuleScriptPath:$ModuleScriptPath"

        It 'imports successfully' {
            #$ModuleScriptName = 'SharedSitecore.SitecoreDocker'
            #$ModuleScriptPath = "$PSScriptRoot\..\..\src\$ModuleScriptName.psm1"

            $ModuleScriptName = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Leaf
            Write-Output "ModuleScriptName:$ModuleScriptName"
            #$ModuleScriptName = $PSScriptRoot | Split-Path -Parent -Parent -Leaf
            $ModuleScriptPath = Join-Path $PSScriptRoot "\..\..\src\$ModuleScriptName.psm1"
            Write-Output "ModuleScriptPath:$ModuleScriptPath"

            { Import-Module -Name $ModuleScriptPath -ErrorAction Stop } | Should -Not -Throw
        }

        It 'not null' {
            { Invoke-Tests } | Should -Not -Throw
        }
    }
}