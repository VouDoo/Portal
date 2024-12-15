function Open-Portal {

    <#

    .SYNOPSIS
    Opens Portal connection.

    .DESCRIPTION
    Opens Portal connection which is defined in the inventory.

    .PARAMETER Name
    Name of the connection.

    .PARAMETER Client
    Name of the client to use to initiate the connection.

    .PARAMETER User
    Name of the user to connect with.

    .PARAMETER Scope
    Scope in which the connection will be opened.

    .INPUTS
    None. You cannot pipe objects to Open-Portal.

    .OUTPUTS
    System.Void. None.

    .EXAMPLE
    PS> Open-Portal myconn

    .EXAMPLE
    PS> Open-Portal -Name myconn -Client SSH -User root -Scope Console

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
        [string] $Name,

        [Parameter(
            HelpMessage = "Name of the client to use to initiate the connection."
        )]
        [ValidateSet([ValidateSetClientName])]
        [ValidateClientName()]
        [Alias("c")]
        [string] $Client,

        [Parameter(
            HelpMessage = "Name of the user to connect with."
        )]
        [Alias("u")]
        [string] $User,

        [Parameter(
            HelpMessage = "Scope in which the connection will be opened."
        )]
        [Alias("x")]
        [Scopes] $Scope
    )

    begin {
        $ErrorActionPreference = "Stop"

        try {
            $Inventory = Import-Inventory
        }
        catch {
            Write-Error -Message (
                "Error import inventory: {0}" -f $_.Exception.Message
            )
        }
    }

    process {
        $Invocation = @{}

        $Invocation.Connection = $Inventory.GetConnection($Name)
        Write-Debug -Message ("Open connection {0}" -f $Invocation.Connection.ToString())

        $Invocation.Client = if ($Client) {
            if (-not $Inventory.ClientExists($Client)) {
                Write-Error -Message (
                    "Cannot open connection with the specified client `"{0}`" because it does not exist." -f (
                        $Client
                    )
                )
            }
            $Inventory.GetClient($Client)
        }
        else {
            if (-not $Inventory.ClientExists($Invocation.Connection.DefaultClient)) {
                Write-Error -Message (
                    "Cannot open connection with the default client `"{0}`" because it does not exist." -f (
                        $Invocation.Connection.DefaultClient
                    )
                )
            }
            $Inventory.GetClient($Invocation.Connection.DefaultClient)
        }
        Write-Debug -Message ("Open connection with client {0}" -f $Invocation.Client.ToString())

        $Invocation.Port = if ($Invocation.Connection.IsDefaultPort()) {
            $Invocation.Client.DefaultPort
        }
        else {
            $Invocation.Connection.Port
        }
        Write-Debug -Message ("Open connection on port {0}" -f $Invocation.Port)

        $Invocation.Executable = $Invocation.Client.Executable
        $Invocation.Arguments = if ($Invocation.Client.RequiresUser) {
            if ($User) {
                $Invocation.Client.GenerateArgs(
                    $Invocation.Connection.Hostname,
                    $Invocation.Port,
                    $User
                )
            }
            elseif ($Invocation.Connection.DefaultUser) {
                $Invocation.Client.GenerateArgs(
                    $Invocation.Connection.Hostname,
                    $Invocation.Port,
                    $Invocation.Connection.DefaultUser
                )
            }
            else {
                Write-Error -Message "Cannot open connection: A user must be specified."
            }
        }
        else {
            $Invocation.Client.GenerateArgs(
                $Invocation.Connection.Hostname,
                $Invocation.Port
            )
        }
        $Invocation.Command = "{0} {1}" -f $Invocation.Executable, $Invocation.Arguments
        Write-Debug -Message ("Open connection with command `"{0}`"" -f $Invocation.Command)

        $Invocation.Scope = if ($Scope) {
            $Scope
        }
        else {
            $Invocation.Client.DefaultScope
        }
        Write-Debug -Message ("Open connection in scope `"{0}`"" -f $Invocation.Scope)

        if ($PSCmdlet.ShouldProcess($Invocation.Connection.ToString(), "Initiate connection")) {
            switch ($Invocation.Scope) {
                ([Scopes]::Console) {
                    Invoke-Expression -Command $Invocation.Command
                }
                ([Scopes]::External) {
                    Start-Process -FilePath $Invocation.Executable -ArgumentList $Invocation.Arguments
                }
                ([Scopes]::Undefined) {
                    Write-Error -Message "Cannot open connection: Scope is undefined."
                }
                default {
                    Write-Error -Message "Cannot open connection: Scope is unknown."
                }
            }
        }
    }
}
