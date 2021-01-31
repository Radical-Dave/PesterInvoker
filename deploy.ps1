Set-StrictMode -Version Latest

$ErrorActionPreference = 'Stop'

#Clear-Host
$VerbosePreference = "Continue"

$scriptName = ($MyInvocation.MyCommand.Name.Replace(".ps1",""))
$scriptPath = $PSScriptRoot
#$moduleName = Split-Path (Split-Path $scriptPath -Parent) -Leaf
$moduleName = Split-Path $scriptPath -Leaf

#####################################################
#
#  deploy
#
#####################################################
Write-Verbose "$scriptName $moduleName started"
Push-Location $scriptPath
#$cwd = Get-Location

#if ($cwd -ne $scriptPath) {
#    Set-Location $scriptPath
#}
#$repoPath = [System.IO.Path]::GetFullPath("$cwd/../../..")
#$repoPath = System.IO.Path]::GetFullPath(($cwd + "\.." * 3))
#$repoPath = (Get-Item $cwd).parent.FullName
#Write-Verbose "repoPath:$repoPath"

try {
    if($PSVersionTable.PSVersion.major -eq 2) {
		$PSCommandPath = [ref]$MyInvocation.MyCommand.Definition
	}
    $repoPath = $PSCommandPath
    #Write-Verbose "$scriptName validating..."
    #if (!(Get-Module PSScriptAnalyzer -ErrorAction SilentlyContinue)) {
    #    Install-Module -Name PSScriptAnalyzer -Repository PSGallery -Force
    #}
    #
    #Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning
    #Import-Module .\src\SharedSitecore.SitecoreDocker.psm1
    Invoke-Pester

    #sign scripts
    $cert = "$moduleName.pfx"
    if (!(Test-Path (Join-Path (Join-Path $repoPath "certs") $cert))) {
        Write-Verbose "Creating:$cert"
        if (!(Test-Path "certs")) {
            mkdir "certs"
        }    
        Set-Location .\certs

        #if (!(Get-Command "choco")) {
            #Set-ExecutionPolicy Bypass -Scope Process -Force; 
            #[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
            #Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
        #}
        #if ((choco list -lo "mkcert").Split('\r')[1] -eq "0 packages installed.") {
        #    choco install "mkcert"
        #}
        #mkcert $cert -a sha1 -r
        #$certificate = Get-Certificate -dnsname $moduleName -SubjectName $moduleName -Template ""
        $certLocation = "cert:\LocalMachine\My"
        if(!(Test-Path $certLocation)) {
            Write-Verbose "Cant sign cert - certLocation not found:$certLocation"
        } else {
            $certificate = Get-ChildItem -Path $certLocation | Where-Object Subject -eq "CN=$moduleName"
            if(!$certificate) {
                $pfxCertificate = New-SelfSignedCertificate -CertStoreLocation $certLocation -FriendlyName $moduleName -DnsName $moduleName -Subject $moduleName -Type CodeSigningCert
                # -NotAfter [System.DateTime]::AddYears(3)
                Write-Output "Certificate generated:$($pfxCertificate.Thumbprint)"
                #$certTemplate = Get-CertificateTemplate $certificate
                $certificate = Get-ChildItem -Path $certLocation | Where-Object Subject -eq "CN=$moduleName"
                Write-Output "certificate:$certificate"

                $password = ConvertTo-SecureString -String $moduleName -Force -AsPlainText
                Export-PfxCertificate -cert $certificate -FilePath ".\$cert" -Password $password

                Set-AuthenticodeSignature -FilePath "$scriptPath\src\Public\*.ps1" -Certificate $certificate
            } else {
                Write-Verbose "Certificate found:$($certificate.Thumbprint)"
            }
        }
    }

    $updateManifest = $false
    if($updateManifest) {
        $ModuleScriptName = Split-Path $PSScriptRoot -Leaf
        $ModuleManifestName = "$ModuleScriptName.psd1"
        $ModuleManifestPath = Join-Path $PSScriptRoot "./src/$ModuleScriptName/$ModuleManifestName"

        #Add a new line to the markdown file.
        $date = Get-Date -Uformat "%D"

        #Update the manifest file
        $manifest = Import-PowerShellDataFile $ModuleManifestPath
        [version]$version = $Manifest.ModuleVersion
        # Add one to the build of the version number
        $NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
        # Update the manifest file
        Update-ModuleManifest -Path $ModuleManifestPath -ModuleVersion $NewVersion
        #Sleep Incase of update
        Start-Sleep -Seconds 5
        #Find the Nuspec File
        $MonolithFile = $ModuleManifestPath.Replace(".psd1", ".nuspec")
        #Import the New PSD file
        $newString = Import-PowerShellDataFile $ModuleManifestPath
        $xmlFile = New-Object xml
        # Load the Nuspec file and modify it
        $xmlFile.Load($MonolithFile)
        $xmlFile.package.metadata.version = $newString.ModuleVersion
        $xmlFile.package.metadata.releaseNotes = "Version $($newString.ModuleVersion) was modified by $($env:USERNAME) on $($date)"
        $xmlFile.Save($MonolithFile)

        # Update the Markdown file to have the version update
        Add-Content -Path .\README.md -Value "  **Version: $($newString.ModuleVersion)**"
        Add-Content -Path .\README.md -Value "  by: $($env:USERNAME) on $($date)"
        Write-Verbose "Updated manifest:$ModuleManifestPath"
    } else {
        Write-Verbose "updateManifest:false - skipped"
    }
}
finally {
    #Set-Location $cwd
    Pop-Location
}

#Set-Location ..

Write-Output "$scriptName $moduleName ended"