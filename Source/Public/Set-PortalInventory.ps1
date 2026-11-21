function Set-PortalInventory {

    <#

    .SYNOPSIS
    Sets Portal inventory path.

    .DESCRIPTION
    Sets the specific environment variable to overwrite default path to the Portal inventory file.

    .PARAMETER Path
    Path to the inventory file.
    This path is set in an environment variable.
    Pass an empty string or null to reset to the default path.

    .PARAMETER Target
    Target scope where the environment variable will be saved.
    "User" can only be persisted on Windows. On other OSes, the variable is set
    for the current session and a warning explains how to persist it in your profile.

    .INPUTS
    None. You cannot pipe objects to Set-PortalInventory.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Set-PortalInventory C:\MyCustomInventory.json

    .EXAMPLE
    PS> Set-PortalInventory -Path C:\MyCustomInventory.json

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Path to the inventory file."
        )]
        [AllowEmptyString()]
        [string] $Path,

        [Parameter(
            HelpMessage = "Target scope of the environment variable."
        )]
        [ValidateSet("Process", "User")]
        [string] $Target = "User"
    )

    process {
        $EnvVar = [Inventory]::EnvVariable

        # User environment variables can only be persisted on Windows.
        # Elsewhere, set it for the current session and explain how to persist it.
        if ($Target -eq "User" -and -not [System.OperatingSystem]::IsWindows()) {
            $Target = "Process"
            $Persist = if ($Path) {
                "To keep it, add this line to your PowerShell profile ({0}): `$env:{1} = '{2}'"
            }
            else {
                "To keep the default path, remove the `$env:{1} line from your PowerShell profile ({0}), if any."
            }
            Write-Warning -Message (
                (
                    "User environment variables cannot be persisted on this OS. " +
                    "The path is only set for the current session. " +
                    $Persist
                ) -f (
                    $PROFILE.CurrentUserAllHosts, $EnvVar, $Path
                )
            )
        }

        if ($PSCmdlet.ShouldProcess(
                ("{0} environment variable {1}" -f $Target, $EnvVar),
                "Set value {0}" -f $Path
            )
        ) {
            [System.Environment]::SetEnvironmentVariable(
                $EnvVar,
                $Path,
                [System.EnvironmentVariableTarget]::"$Target"
            )
            Write-Verbose -Message ("{0} environment variable `"{1}`" has been set to `"{2}`"." -f $Target, $EnvVar, $Path)
        }
    }
}
