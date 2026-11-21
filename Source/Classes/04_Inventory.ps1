class Inventory {
    # Title for the inventory file
    [string] $Title = "Portal inventory"
    # description for the inventory file
    [string] $Description = "Portal inventory file where the connections and clients are stored"
    # Version of the inventory file
    [string] $Version = "0.1.0"
    # Path to the inventory file
    [string] $Path = [Inventory]::GetPath()
    # Collection of Clients
    [Client[]] $Clients
    # Collection of Connections
    [Connection[]] $Connections
    # Encoding for inventory file
    static [string] $Encoding = "utf-8"
    # Name of the environement variable to use a custom path to the inventory file
    static [string] $EnvVariable = "PORTAL_INVENTORY"

    static [string] GetPath() {
        foreach ($Target in @("Process", "User", "Machine")) {
            $Value = [System.Environment]::GetEnvironmentVariable(
                [Inventory]::EnvVariable,
                [System.EnvironmentVariableTarget]::"$Target"
            )
            if ($Value) { return $Value }
        }
        return Join-Path -Path ([Inventory]::GetDefaultDirectory()) -ChildPath "inventory.json"
    }

    static [string] GetDefaultDirectory() {
        # Usual location for application settings on each OS
        if ([System.OperatingSystem]::IsWindows()) {
            # %APPDATA%\Portal
            return Join-Path -Path ([System.Environment]::GetFolderPath("ApplicationData")) -ChildPath "Portal"
        }
        if ([System.OperatingSystem]::IsMacOS()) {
            # ~/Library/Application Support/Portal
            return Join-Path -Path $env:HOME -ChildPath "Library/Application Support/Portal"
        }
        # Linux and others: $XDG_CONFIG_HOME/portal, or ~/.config/portal
        $ConfigHome = if ($env:XDG_CONFIG_HOME) {
            $env:XDG_CONFIG_HOME
        }
        else {
            Join-Path -Path $env:HOME -ChildPath ".config"
        }
        return Join-Path -Path $ConfigHome -ChildPath "portal"
    }

    [void] ReadFile() {
        # Get content from the file
        $GetContentParams = @{
            Path        = $this.Path
            Raw         = $true
            Encoding    = [Inventory]::Encoding
            ErrorAction = "Stop"
        }
        try {
            $Items = Get-Content @GetContentParams | ConvertFrom-Json -AsHashtable
        }
        catch {
            throw "Cannot open inventory: {0}" -f $_.Exception.Message
        }

        # Check version of the inventory
        if ($Items.Version -ne $this.Version) {
            throw (
                "Version of the inventory file is not supported.",
                "Current version: `"{0}`", Expected version: `"{1}`"" -f (
                    $Items.Version, $this.Version
                )
            )
        }

        # Re-initialize Clients array
        $this.Clients = @()

        # Add every Client to inventory object
        foreach ($c in $Items.Clients) {
            $this.Clients += New-Object -TypeName Client -ArgumentList @(
                $c.Name,
                $c.Executable,
                $c.TokenizedArgs,
                $c.DefaultPort,
                $c.DefaultScope,
                $c.Description
            )
        }

        # Check if Client name duplicates exist
        if ($this.ClientNameDuplicatesExist()) {
            Write-Warning -Message ("Fix the inventory by renaming the duplicated client names in the inventory file: {0}" -f (
                    [Inventory]::GetPath()
                )
            )
        }

        # Re-initialize Connections array
        $this.Connections = @()

        # Add every Connection to inventory object
        foreach ($c in $Items.Connections) {
            $this.Connections += New-Object -TypeName Connection -ArgumentList @(
                $c.Name,
                $c.Hostname,
                $c.Port,
                $c.DefaultClient,
                $c.DefaultUser,
                $c.Description
            )
        }

        # Report invalid hostnames, without blocking the other connections
        foreach ($c in $this.Connections) {
            if (-not $c.HasValidHostname()) {
                Write-Warning -Message (
                    "Connection `"{0}`" has an invalid hostname `"{1}`". Fix it in the inventory file: {2}" -f (
                        $c.Name, $c.Hostname, $this.Path
                    )
                )
            }
        }

        # Check if Connection name duplicates exist
        if ($this.ConnectionNameDuplicatesExist()) {
            Write-Warning -Message (
                "Fix the inventory by renaming the duplicated connection names in the inventory file: {0}" -f (
                    [Inventory]::GetPath()
                )
            )
        }
    }

    [void] SaveFile() {
        $Items = [ordered] @{
            Title       = $this.Title
            Description = $this.Description
            Version     = $this.Version
            Clients     = @()
            Connections = @()
        }

        foreach ($c in $this.Clients) {
            $Items.Clients += $c.Splat()
        }

        foreach ($c in $this.Connections) {
            $Connection = $c.Splat()
            $Items.Connections += $Connection
        }

        $Json = ConvertTo-Json -InputObject $Items -Depth 3 -EnumsAsStrings

        $Directory = Split-Path -Path $this.Path -Parent
        if ($Directory -and -not (Test-Path -Path $Directory -PathType Container)) {
            New-Item -Path $Directory -ItemType Directory -Force | Out-Null
        }

        if (Test-Path -Path $this.Path -PathType Leaf) {
            $BackupPath = "{0}.backup" -f $this.Path
            Copy-Item -Path $this.Path -Destination $BackupPath -Force
        }

        # Write to a temporary file in the same directory, then move it over the inventory file.
        # The move is a rename on the same volume, so the inventory file is either the old one
        # or the new one, never a partially written file (e.g. if the process is killed or the disk is full).
        $TempPath = "{0}.{1}.tmp" -f $this.Path, [System.Guid]::NewGuid().ToString("N")
        try {
            Set-Content -Path $TempPath -Value $Json -Encoding ([Inventory]::Encoding) -Force -ErrorAction Stop
            [System.IO.File]::Move($TempPath, $this.Path, $true)
        }
        finally {
            if (Test-Path -Path $TempPath -PathType Leaf) {
                Remove-Item -Path $TempPath -Force -ErrorAction SilentlyContinue
            }
        }
    }

    hidden [bool] ClientNameDuplicatesExist() {
        $Duplicates = $this.Clients
        | Group-Object -Property Name
        | Where-Object -Property Count -GT 1

        if ($Duplicates) {
            $Duplicates | ForEach-Object -Process {
                Write-Warning -Message ("It exists more than one client named `"{0}`"." -f $_.Name)
            }
            return $true
        }
        return $false
    }

    hidden [bool] ConnectionNameDuplicatesExist() {
        $Duplicates = $this.Connections
        | Group-Object -Property Name
        | Where-Object -Property Count -GT 1

        if ($Duplicates) {
            $Duplicates | ForEach-Object -Process {
                Write-Warning -Message ("It exists more than one connection named `"{0}`"." -f $_.Name)
            }
            return $true
        }
        return $false
    }

    [Client] GetClient([string] $Name) {
        return $this.Clients | Where-Object -Property Name -EQ $Name
    }

    [Connection] GetConnection([string] $Name) {
        return $this.Connections | Where-Object -Property Name -EQ $Name
    }

    [Connection[]] GetConnectionsUsingClient([string] $Name) {
        return $this.Connections | Where-Object -Property DefaultClient -EQ $Name
    }

    [bool] ClientExists([string] $Name) {
        return $this.GetClient($Name).Count -gt 0
    }

    [bool] ConnectionExists([string] $Name) {
        return $this.GetConnection($Name).Count -gt 0
    }

    [void] AssertClientExists([string] $Name) {
        if (-not $this.ClientExists($Name)) {
            throw "Client `"{0}`" does not exist." -f $Name
        }
    }

    [void] AssertConnectionExists([string] $Name) {
        if (-not $this.ConnectionExists($Name)) {
            throw "Connection `"{0}`" does not exist." -f $Name
        }
    }

    [void] AddClient([Client] $Client) {
        if ($this.ClientExists($Client.Name)) {
            throw "Cannot add Client `"{0}`" as it already exists." -f $Client.Name
        }
        $this.Clients += $Client
    }

    [void] AddConnection([Connection] $Connection) {
        if ($this.ConnectionExists($Connection.Name)) {
            throw "Cannot add Connection `"{0}`" as it already exists." -f $Connection.Name
        }
        [Connection]::ValidateHostname($Connection.Hostname)
        $this.Connections += $Connection
    }

    [void] RemoveClient([string] $Name) {
        $this.Clients = $this.Clients | Where-Object -Property Name -NE $Name
    }

    [void] RemoveConnection([string] $Name) {
        $this.Connections = $this.Connections | Where-Object -Property Name -NE $Name
    }

    [void] RenameClient([string] $Name, [string] $NewName) {
        if ($Name -eq $NewName) {
            throw "The two names are similar."
        }
        elseif (-not $this.ClientExists($Name)) {
            throw "No Client `"{0}`" to rename." -f $Name
        }
        elseif ($this.ClientExists($NewName)) {
            throw "Cannot rename Client `"{0}`" to `"{1}`" as this name is already used." -f $Name, $NewName
        }

        for ($i = 0; $i -lt $this.Clients.count; $i++) {
            if ($this.Clients[$i].Name -eq $Name) {
                $this.Clients[$i].Name = $NewName
            }
        }

        for ($i = 0; $i -lt $this.Connections.count; $i++) {
            if ($this.Connections[$i].DefaultClient -eq $Name) {
                $this.Connections[$i].DefaultClient = $NewName
            }
        }
    }

    [void] RenameConnection([string] $Name, [string] $NewName) {
        if ($Name -eq $NewName) {
            throw "The two names are similar."
        }
        elseif (-not $this.ConnectionExists($Name)) {
            throw "No Connection `"{0}`" to rename." -f $Name
        }
        elseif ($this.ConnectionExists($NewName)) {
            throw "Cannot rename Connection `"{0}`" to `"{1}`" as this name is already used." -f $Name, $NewName
        }

        for ($i = 0; $i -lt $this.Connections.count; $i++) {
            if ($this.Connections[$i].Name -eq $Name) {
                $this.Connections[$i].Name = $NewName
            }
        }
    }
}
