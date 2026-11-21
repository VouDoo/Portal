class Connection : Item {
    # Hostname (validated by ValidateHostname when the connection is added,
    # not when the inventory is read, so one bad entry does not block the others)
    [string] $Hostname
    # Port
    [UInt16] $Port
    # Default client
    [string] $DefaultClient
    # Default user
    [string] $DefaultUser
    # Pattern for DNS names and IPv4 addresses: dot-separated labels made of letters,
    # digits, hyphens and underscores, which do not start or end with a hyphen
    # (a leading hyphen could be read as an option by the client)
    hidden static [string] $HostnamePattern = "^([a-zA-Z0-9_]([a-zA-Z0-9_\-]*[a-zA-Z0-9_])?\.)*[a-zA-Z0-9_]([a-zA-Z0-9_\-]*[a-zA-Z0-9_])?$"

    Connection(
        [String] $Name,
        [String] $Hostname,
        [UInt16] $Port,
        [string] $DefaultClient,
        [string] $DefaultUser,
        [string] $Description
    ) {
        $this.Name = $Name
        $this.Hostname = if ($Hostname) { $Hostname.ToLower() } else { "" }
        $this.Port = $Port
        $this.DefaultClient = $DefaultClient
        $this.DefaultUser = $DefaultUser
        $this.Description = $Description
    }

    static [bool] IsIPv6Address([string] $Hostname) {
        # IPv6 address without brackets (e.g. "::1", "fe80::1", "2001:db8::10")
        $Address = $null
        return (
            $Hostname -match ":" -and
            $Hostname -notmatch "[\[\]]" -and
            [System.Net.IPAddress]::TryParse($Hostname, [ref] $Address) -and
            $Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6
        )
    }

    static [bool] IsValidHostname([string] $Hostname) {
        if (-not $Hostname -or $Hostname.Length -gt 253) {
            return $false
        }
        return (
            [Connection]::IsIPv6Address($Hostname) -or
            $Hostname -match [Connection]::HostnamePattern
        )
    }

    static [void] ValidateHostname([string] $Hostname) {
        if (-not [Connection]::IsValidHostname($Hostname)) {
            throw (
                "The hostname `"{0}`" is not valid. " +
                "Use a DNS name, an IPv4 address or an IPv6 address (without brackets)."
            ) -f $Hostname
        }
    }

    [bool] HasValidHostname() {
        return [Connection]::IsValidHostname($this.Hostname)
    }

    [bool] IsDefaultPort() {
        return $this.Port -eq 0
    }

    [string] ToString() {
        return "{0}, Description `"{1}`", Default client {2}, Target {3}:{4}" -f (
            $this.Name,
            $this.Description,
            $this.DefaultClient,
            $(
                if ([Connection]::IsIPv6Address($this.Hostname)) {
                    "[{0}]" -f $this.Hostname
                }
                else {
                    $this.Hostname
                }
            ),
            $(
                if ($this.IsDefaultPort()) {
                    "default"
                }
                else {
                    $this.Port.ToString()
                }
            )
        )
    }
}
