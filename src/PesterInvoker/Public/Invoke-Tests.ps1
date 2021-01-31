Set-StrictMode -Version Latest
<#
#  Invoke-Tests
.SYNOPSIS
    PowerShell Module for PowerShell Module development testing using Pester
.DESCRIPTION
    PowerShell Module for PowerShell Module development testing using Pester
.PARAMETER Path
    Specifies the path that needs to be set as current working directory to discover tests
.EXAMPLE
    PS C:\> Invoke-Tests -Path VAR1 -Cwd "value one"
.EXAMPLE
    PS C:\> "value one" | Invoke-Tests "VAR1"
.EXAMPLE
    PS C:\> Invoke-Tests -Variable VAR1 -Value "value one" -Path .\src\.env
.INPUTS
    System.String. You can pipe in the Value parameter.
.OUTPUTS
    None.
#>
function Invoke-Tests
{
	param(
		[Parameter(HelpMessage="Specifies the path that needs to be set as current working directory to discover tests")]
        [Alias('p')]
        [string] $Path = '.'
	)
	#if($PSVersionTable.PSVersion.major -eq 2) {
	#	$PSCommandPath = [ref]$MyInvocation.MyCommand.Definition
	#}
    $owd = $pwd
	#$scriptPath = $PSCommandPath
	#$repoPath = (Split-Path (Split-Path( Split-Path $scriptPath -Parent) -Parent) -Parent)
	#$moduleName = Split-Path $repoPath -Leaf
    #Write-Verbose "moduleName:$moduleName"
	#$modulePath = Join-Path (Split-Path (Split-Path (Split-Path $scriptPath -Parent) -Parent) -Parent) "/src/$moduleName.psm1"
	#Write-Verbose "modulePath:$modulePath"
    #if(Get-Module $moduleName -ErrorAction SilentlyContinue) {
	#	Remove-Module $moduleName -Force
	#}
    #if(!(Get-Module $moduleName -ErrorAction SilentlyContinue)) {
    #    Import-Module $modulePath -Force -Scope Global -ErrorAction Stop
    #}
	#if (!$Path) {
    #    $Path = $pwd
    #}
    Write-Verbose "Path:$Path"
    Set-Location $Path
    Invoke-Pester -verbose
    Set-Location $owd
}