function Get-PortalInventory {

    <#

    .SYNOPSIS
    Gets Portal inventory information.

    .DESCRIPTION
    Gets detailed information about the Portal inventory.

    .INPUTS
    None. You cannot pipe objects to Get-PortalInventory.

    .OUTPUTS
    PSCustomObject. Get-PortalInventory returns an object with detailed information.

    .EXAMPLE
    PS> Get-PortalInventory
    (objects)

    #>

    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param ()

    process {
        $Inventory = New-Object -TypeName Inventory
        $FileExists = $false

        if (Test-Path -Path $Inventory.Path -PathType Leaf) {
            $Inventory.ReadFile()
            $FileExists = $true
        }

        [PSCustomObject] @{
            Path                = $Inventory.Path
            EnvVariable         = [Inventory]::EnvVariable
            FileExists          = $FileExists
            NumberOfClients     = $Inventory.Clients.Count
            NumberOfConnections = $Inventory.Connections.Count
        }
    }
}
