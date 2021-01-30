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
function Invoke-TestsInModuleScope
{
	param(
		[Parameter(HelpMessage="Tests in scope to invoke")]
		[ScriptBlock]$TestScope
	)
	if($PSVersionTable.PSVersion.major -eq 2) {
		$PSCommandPath = [ref]$MyInvocation.MyCommand.Definition
	}
	$scriptPath = $PSCommandPath
	$repoPath = (Split-Path (Split-Path( Split-Path $scriptPath -Parent) -Parent) -Parent)
	$moduleName = Split-Path $repoPath -Leaf
	$modulePath = Join-Path (Split-Path (Split-Path (Split-Path $scriptPath -Parent) -Parent) -Parent) "\src\$moduleName.psm1"
	if(Get-Module $moduleName -ErrorAction SilentlyContinue) {
		Remove-Module $moduleName -Force
	}
	Import-Module $modulePath -Force -Scope Global -ErrorAction Stop
	if(!$TestScope) {
		#$TestScope = "$repoPath\tests" #{-Script @{ Path = './tests/*'}}
		
		#$TestScope = Invoke-Command -ScriptBlock {Get-Module $moduleName}
		$DefaultTestScope = [scriptblock]::Create("PesterInvoker")
		Write-Output "DefaultTestScope:$DefaultTestScope"
		$TestScope = $DefaultTestScope
		if(!$TestScope) {
			Write-Error "TestScope is null"
			EXIT 1
		}
	}
	InModuleScope $moduleName $TestScope
}