class Client : Item {
    # Executable
    [string] $Executable
    # Command template
    [string] $TokenizedArgs
    # Default port
    [UInt16] $DefaultPort
    # Default connection scope
    [Scopes] $DefaultScope
    # Does this client require a user
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

    static [void] ValidateTokenizedArgs(
        [string] $TokenizedArgs
    ) {
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

    hidden static [string[]] SplitArgs([string] $ArgumentLine) {
        # Splits an argument line on whitespace. Single or double quotes group
        # several words into one argument (the quotes themselves are removed).
        $Arguments = [System.Collections.Generic.List[string]]::new()
        $Current = [System.Text.StringBuilder]::new()
        $InArgument = $false
        $Quote = [char] 0
        foreach ($Char in $ArgumentLine.ToCharArray()) {
            if ($Quote) {
                if ($Char -eq $Quote) { $Quote = [char] 0 }
                else { [void] $Current.Append($Char) }
            }
            elseif ($Char -eq '"' -or $Char -eq "'") {
                $Quote = $Char
                $InArgument = $true
            }
            elseif ([char]::IsWhiteSpace($Char)) {
                if ($InArgument) {
                    $Arguments.Add($Current.ToString())
                    [void] $Current.Clear()
                    $InArgument = $false
                }
            }
            else {
                [void] $Current.Append($Char)
                $InArgument = $true
            }
        }
        if ($Quote) {
            throw "The argument line contains an unclosed quote."
        }
        if ($InArgument) {
            $Arguments.Add($Current.ToString())
        }
        return $Arguments.ToArray()
    }

    [string[]] GenerateArgs(
        [string] $Hostname,
        [UInt16] $Port
    ) {
        return $this.GenerateArgs($Hostname, $Port, "")
    }

    [string[]] GenerateArgs(
        [string] $Hostname,
        [UInt16] $Port,
        [string] $User
    ) {
        # The argument line is split BEFORE the tokens are replaced, so the
        # values (host, port, user) always stay inside their own argument and
        # are never interpreted by a shell.
        return [Client]::SplitArgs($this.TokenizedArgs) | ForEach-Object -Process {
            $_.Replace(
                [Client]::HostToken, $Hostname
            ).Replace(
                [Client]::PortToken, $Port
            ).Replace(
                [Client]::UserToken, $User
            )
        }
    }

    [string] ToString() {
        return "{0}, Description: `"{1}`", Scope: {2}, Command: `"{3} {4}`"" -f (
            $this.Name,
            $this.Description,
            $this.DefaultScope,
            $this.Executable,
            $this.TokenizedArgs.Replace(
                "<port>", "<port:{0}>" -f $this.DefaultPort
            )
        )
    }
}
