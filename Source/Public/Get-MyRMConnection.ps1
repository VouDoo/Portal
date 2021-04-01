function Get-MyRMConnection {

    <#
    .SYNOPSIS
        Gets MyRemoteManager connections.
    .DESCRIPTION
        Gets available connections from the MyRemoteManager inventory file.
        connections can be filtered by their name and/or client name.
    .PARAMETER Name
        Filters connections by name.
    .INPUTS
        None. You cannot pipe objects to Get-MyRMConnection.
    .OUTPUTS
        PSCustomObject. Get-MyRMConnection returns objects with details of the available connections.
    .EXAMPLE
        PS> Get-MyRMConnection
        (shows objects)
    .EXAMPLE
        PS> Get-MyRMConnection -Name "myproject_*" -Client "*_myproject"
        (shows filtered objects)
    #>

    [OutputType([PSCustomObject[]])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Filter by connection name."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name = "*",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Filter by client name."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Client = "*"
    )
    begin {
        $Inventory = New-Object -TypeName Inventory
        $Inventory.ReadFile()
    }
    process {
        $Connections = @()
        foreach ($c in $Inventory.Connections) {
            $Connections += [PSCustomObject] @{
                Name        = $c.Name
                Hostname    = $c.Hostname
                Port        = if ($c.Port -eq 0) {
                    $c.Client.DefaultPort
                }
                else {
                    $c.Port
                }
                Client      = $c.Client.Name
                Description = $c.Description
            }
        }
        $Connections = $Connections | Where-Object {
            $_.Name -like $Name -and $_.Client -Like $Client
        } | Sort-Object -Property Name
    }
    end {
        $Connections
    }
}