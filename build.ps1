[cmdletbinding(DefaultParameterSetName = "Task")]
param(
    [parameter(
        ParameterSetName = "task",
        position = 0,
        HelpMessage = "Build task(s) to execute"
    )]
    [string[]] $Task = "default",

    [parameter(
        HelpMessage = "Bootstrap dependencies"
    )]
    [switch] $Bootstrap,

    [parameter(
        ParameterSetName = "Help",
        HelpMessage = "List available build tasks"
    )]
    [switch] $Help
)

$ErrorActionPreference = "Stop"

#region Bootstrap dependencies
$RequirementsFile = Join-Path -Path $PSScriptRoot -ChildPath requirements.psd1
if ($Bootstrap.IsPresent) {
    Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
    # Trust PSGallery only while installing the dependencies, then restore the previous policy
    $PreviousInstallationPolicy = (Get-PSRepository -Name PSGallery).InstallationPolicy
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    try {
        if (-not (Get-Module -Name PSDepend -ListAvailable)) {
            Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser
        }
        Import-Module -Name PSDepend -Verbose:$false
        Invoke-PSDepend -Path $RequirementsFile -Install -Import -Force -WarningAction SilentlyContinue
    }
    finally {
        Set-PSRepository -Name PSGallery -InstallationPolicy $PreviousInstallationPolicy
    }
}
#endregion Bootstrap dependencies

#region Execute psake task(s)
$psakeFile = Join-Path -Path $PSScriptRoot -ChildPath "psakefile.ps1"
if ($PSCmdlet.ParameterSetName -eq "Help") {
    Invoke-psake -buildFile $psakeFile -docs
}
else {
    Invoke-psake -buildFile $psakeFile -taskList $Task -nologo
    # Non-zero exit code when the build fails (for CI and VS Code tasks)
    exit ([int](-not $psake.build_success))
}
#endregion Execute psake task(s)
