function Get-PortalClient {

    <#

    .SYNOPSIS
    Gets Portal clients.

    .DESCRIPTION
    Gets available clients from the Portal inventory file.
    Clients can be filtered by their name.

    .PARAMETER Name
    Filters clients by name.

    .INPUTS
    None. You cannot pipe objects to Get-PortalClient.

    .OUTPUTS
    PSCustomObject. Get-PortalClient returns objects with details of the available clients.

    .EXAMPLE
    PS> Get-PortalClient
    (objects)

    .EXAMPLE
    PS> Get-PortalClient -Name "custom_*"
    (filtered objects)

    #>

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = "Filter by client name."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name = "*"
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
                "Error import inventory: {0}" -f $_.Exception.Message
            )
        }

        $Clients = @()
        foreach ($c in $Inventory.Clients) {
            $Clients += [PSCustomObject] @{
                Name         = $c.Name
                Command      = "{0} {1}" -f $c.Executable, $c.TokenizedArgs
                DefaultPort  = $c.DefaultPort
                DefaultScope = $c.DefaultScope
                Description  = $c.Description
            }
        }

        $Clients
        | Where-Object -Property Name -Like $Name
        | Sort-Object -Property Name
    }
}
