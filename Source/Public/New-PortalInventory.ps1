function New-PortalInventory {

    <#

    .SYNOPSIS
    Creates Portal inventory file.

    .DESCRIPTION
    Creates a new inventory file where Portal saves items.

    .PARAMETER NoDefaultClients
    Does not add defaults clients to the new inventory.

    .PARAMETER Force
    Overwrites existing inventory file.

    .PARAMETER PassThru
    Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands.

    .INPUTS
    None. You cannot pipe objects to New-PortalInventory.

    .OUTPUTS
    System.Void. None.
        or if PassThru is set,
    System.String. New-PortalInventory returns a string with the path to the created inventory.

    .EXAMPLE
    PS> New-PortalInventory

    .EXAMPLE
    PS> New-PortalInventory -NoDefaultClients

    .EXAMPLE
    PS> New-PortalInventory -Force

    .EXAMPLE
    PS> New-PortalInventory -PassThru
    C:\Users\MyUsername\Portal.json

    .EXAMPLE
    PS> New-PortalInventory -NoDefaultClients -Force -PassThru
    C:\Users\MyUsername\Portal.json

    #>

    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(
            HelpMessage = "Do not add defaults clients."
        )]
        [switch] $NoDefaultClients,

        [Parameter(
            HelpMessage = "Overwrite existing inventory file."
        )]
        [switch] $Force,

        [Parameter(
            HelpMessage = "Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands."
        )]
        [switch] $PassThru
    )

    begin {
        $ErrorActionPreference = "Stop"
    }

    process {
        $Inventory = New-Object -TypeName Inventory

        if ((Test-Path -Path $Inventory.Path -PathType Leaf) -and -not ($Force.IsPresent)) {
            Write-Error -ErrorAction Stop -Exception (
                [System.IO.IOException] "Inventory file already exists. Use `"-Force`" to overwrite it."
            )
        }

        if ($PSCmdlet.ShouldProcess($Inventory.Path, "Create inventory file")) {
            if (-not $NoDefaultClients.IsPresent) {
                New-DefaultClient | ForEach-Object -Process {
                    $Inventory.AddClient($_)
                }
            }
            try {
                $Inventory.SaveFile()
                Write-Verbose -Message (
                    "Inventory file has been created: {0}" -f $Inventory.Path
                )
            }
            catch {
                Write-Error -Message (
                    "Cannot save inventory: {0}" -f $_.Exception.Message
                )
            }
        }

        if ($PassThru.IsPresent) {
            Resolve-Path $Inventory.Path | Select-Object -ExpandProperty Path
        }
    }
}
