function Remove-Portal {

    <#

    .SYNOPSIS
    Removes Portal connection.

    .DESCRIPTION
    Removes connection entry from the Portal inventory file.

    .PARAMETER Name
    Name of the connection.

    .INPUTS
    None. You cannot pipe objects to Remove-Portal.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Remove-Portal myconn

    .EXAMPLE
    PS> Remove-Portal -Name myconn

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Name of the connection."
        )]
        [ValidateSet([ValidateSetConnectionName])]
        [ValidateConnectionName()]
        [string] $Name
    )

    begin {
        $ErrorActionPreference = "Stop"
    }

    process {
        try {
            $Inventory = Import-Inventory
        }
        catch {
            Write-Error -Message (
                "Cannot open inventory: {0}" -f $_.Exception.Message
            )
        }

        if ($PSCmdlet.ShouldProcess(
                "Inventory file {0}" -f $Inventory.Path,
                "Remove Connection {0}" -f $Name
            )
        ) {
            $Inventory.RemoveConnection($Name)

            try {
                $Inventory.SaveFile()
                Write-Verbose -Message (
                    "Connection `"{0}`" has been removed from the inventory." -f $Name
                )
            }
            catch {
                Write-Error -Message (
                    "Cannot save inventory: {0}" -f $_.Exception.Message
                )
            }
        }
    }
}
