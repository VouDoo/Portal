function Get-Portal {

    <#

    .SYNOPSIS
    Gets Portal connections.

    .DESCRIPTION
    Gets available connections from the Portal inventory file.
    connections can be filtered by their name and/or client name.

    .PARAMETER Name
    Filters connections by name.

    .INPUTS
    None. You cannot pipe objects to Get-Portal.

    .OUTPUTS
    PSCustomObject. Get-Portal returns objects with details of the available connections.

    .EXAMPLE
    PS> Get-Portal
    (objects)

    .EXAMPLE
    PS> Get-Portal -Name "myproject_*" -Hostname "*.mydomain" -Client "*_myproject"
    (filtered objects)

    #>

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(
            HelpMessage = "Filter by connection name."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name = "*",

        [Parameter(
            HelpMessage = "Filter by hostname."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Hostname = "*",

        [Parameter(
            HelpMessage = "Filter by client name."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Client = "*"
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

        $Connections = @()
        foreach ($c in $Inventory.Connections) {
            $Connections += [PSCustomObject] @{
                Name          = $c.Name
                Hostname      = $c.Hostname
                Port          = if ($c.IsDefaultPort) {
                    $Inventory.GetClient($c.DefaultClient).DefaultPort
                }
                else {
                    $c.Port
                }
                DefaultClient = $c.DefaultClient
                DefaultUser   = $c.DefaultUser
                Description   = $c.Description
            }
        }

        $Connections
        | Where-Object -Property Name -Like $Name
        | Where-Object -Property Hostname -Like $Hostname
        | Where-Object -Property DefaultClient -Like $Client
        | Sort-Object -Property Name
    }
}
