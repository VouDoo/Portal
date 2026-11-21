function Remove-PortalClient {

    <#

    .SYNOPSIS
    Removes Portal client.

    .DESCRIPTION
    Removes client entry from the Portal inventory file.

    .PARAMETER Name
    Name of the client.

    .PARAMETER Force
    Removes the client even if it is the default client of some connections.
    These connections must then be opened with another client (Open-Portal -Client).

    .INPUTS
    None. You cannot pipe objects to Remove-PortalClient.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Remove-PortalClient SSH

    .EXAMPLE
    PS> Remove-PortalClient -Name SSH

    .EXAMPLE
    PS> Remove-PortalClient -Name SSH -Force

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Name of the client."
        )]
        [ArgumentCompleter([ClientNameCompleter])]
        [string] $Name,

        [Parameter(
            HelpMessage = "Remove the client even if it is the default client of some connections."
        )]
        [switch] $Force
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

        try {
            $Inventory.AssertClientExists($Name)
        }
        catch {
            Write-Error -Message $_.Exception.Message
        }

        # Connections that would be left without their default client
        $Dependents = ($Inventory.GetConnectionsUsingClient($Name) | ForEach-Object -Process { $_.Name }) -join ", "
        if ($Dependents -and -not $Force.IsPresent) {
            Write-Error -Message (
                "Cannot remove Client `"{0}`" as it is the default client of these connections: {1}. Use -Force to remove it anyway." -f (
                    $Name, $Dependents
                )
            )
        }

        if ($PSCmdlet.ShouldProcess(
                "Inventory file {0}" -f $Inventory.Path,
                "Remove Client {0}" -f $Name
            )
        ) {
            $Inventory.RemoveClient($Name)

            try {
                $Inventory.SaveFile()
                Write-Verbose -Message (
                    "Client `"{0}`" has been removed from the inventory." -f $Name
                )
                if ($Dependents) {
                    Write-Warning -Message (
                        "These connections have no default client anymore: {0}. Open them with another client (Open-Portal -Client)." -f (
                            $Dependents
                        )
                    )
                }
            }
            catch {
                Write-Error -Message (
                    "Cannot save inventory: {0}" -f $_.Exception.Message
                )
            }
        }
    }
}
