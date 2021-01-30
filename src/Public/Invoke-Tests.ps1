Set-StrictMode -Version Latest
<#
#  Invoke-Tests
.SYNOPSIS
    Sets current working directory and returns original directory as string so it can be restored when ready
.DESCRIPTION
    Sets current working directory
.PARAMETER Path
    Specifies the path that needs to be set as current working directory
.PARAMETER Cwd
    Specifies the path that should be reset to return to original working directory.
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
		[Parameter(HelpMessage="Tests in scope to invoke")]
        [Alias('p')]
        [string] $Path = '.'
	)
	if($PSVersionTable.PSVersion.major -eq 2) {
		$PSCommandPath = [ref]$MyInvocation.MyCommand.Definition
	}
    $owd = $pwd
	$scriptPath = $PSCommandPath
	$repoPath = (Split-Path (Split-Path( Split-Path $scriptPath -Parent) -Parent) -Parent)
	$moduleName = Split-Path $repoPath -Leaf
	$modulePath = Join-Path (Split-Path (Split-Path (Split-Path $scriptPath -Parent) -Parent) -Parent) "\src\$moduleName.psm1"
	#if(Get-Module $moduleName -ErrorAction SilentlyContinue) {
	#	Remove-Module $moduleName -Force
	#}
    if(!(Get-Module $moduleName -ErrorAction SilentlyContinue)) {
        Import-Module $modulePath -Force -Scope Global -ErrorAction Stop
    }
	if (!$Path) {
        $Path = $pwd
    }
    Set-Location $Path
    Invoke-Pester
    Set-Location $owd
}