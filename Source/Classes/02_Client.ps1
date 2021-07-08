class Client : Item {
    # Executable
    [string] $Executable
    # Command template
    [string] $TokenizedArgs
    # Default port
    [UInt16] $DefaultPort
    # Default connection scope
    [Scopes] $DefaultScope
    # Is this client requires a user
    [bool] $RequiresUser
    # Tokens
    static [string] $HostToken = "<host>"
    static [string] $PortToken = "<port>"
    static [string] $UserToken = "<user>"

    Client(
        [string] $Name,
        [string] $Executable,
        [string] $TokenizedArgs,
        [UInt16] $DefaultPort,
        [Scopes] $DefaultScope,
        [string] $Description
    ) {
        $this.Name = $Name
        $this.Executable = $Executable
        [Client]::ValidateTokenizedArgs($TokenizedArgs)
        $this.TokenizedArgs = $TokenizedArgs
        $this.DefaultPort = $DefaultPort
        $this.DefaultScope = $DefaultScope
        $this.RequiresUser = [Client]::UserTokenExists($TokenizedArgs)
        $this.Description = $Description
    }

    hidden static [void] ValidateTokenizedArgs([string] $TokenizedArgs) {
        @(
            [Client]::HostToken,
            [Client]::PortToken
        ) | ForEach-Object -Process {
            if ($TokenizedArgs -notmatch $_) {
                throw "The argument line does not contain the following token: {0}." -f $_
            }
        }
    }

    hidden static [bool] UserTokenExists([string] $TokenizedArgs) {
        return $TokenizedArgs -match [Client]::UserToken
    }

    [string] ToString() {
        return "{0}, Description: `"{1}`", Scope: {2}, Command: `"{3} {4}`"" -f (
            $this.Name,
            $this.Description,
            $this.DefaultScope,
            $this.Executable,
            $this.TokenizedArgs.Replace("<port>", "<port:{0}>" -f $this.DefaultPort)
        )
    }
}
