BeforeAll {
    $Module = Get-Item -Path $env:PESTER_FILE_TO_TEST
    Import-Module -Name $Module.FullName -Force

    $env:PORTAL_INVENTORY = Join-Path -Path $TestDrive -ChildPath "portal/inventory.json"
}
Describe "New-PortalInventory" {
    It "Creates a new inventory file" {
        New-PortalInventory -PassThru | Should -BeExactly $env:PORTAL_INVENTORY
    }
    It "Creates a new inventory file even if it already exists, and fails" {
        { New-PortalInventory -PassThru } | Should -Throw -ExceptionType "System.IO.IOException"
    }
    It "Forces the creation of a new inventory file" {
        New-PortalInventory -Force -PassThru | Should -BeExactly $env:PORTAL_INVENTORY
    }
    It "Checks if a backup file has been created" {
        $TestInventoryBackupFile = $env:PORTAL_INVENTORY + ".backup"
        Test-Path -Path $TestInventoryBackupFile -PathType Leaf | Should -BeTrue
    }
    It "Validates the JSON content from the inventory file" {
        $PSObject = Get-Content -Path $env:PORTAL_INVENTORY | ConvertFrom-Json -AsHashtable
        $PSObject.ContainsKey("Connections") | Should -BeTrue
        $PSObject.ContainsKey("Clients") | Should -BeTrue
        $PSObject.ContainsKey("Foo") | Should -BeFalse
    }
}
Describe "Get-PortalInventory" {
    BeforeAll {
        New-PortalInventory -Force
    }
    It "Collects information about the inventory" {
        $Info = Get-PortalInventory
        $Info.Path | Should -BeExactly $env:PORTAL_INVENTORY
        $Info.EnvVariable | Should -BeExactly "PORTAL_INVENTORY"
        $Info.FileExists | Should -BeTrue
        # Default clients depend on the OS
        $ExpectedClients = if ($IsWindows) { 3 } elseif ($IsLinux) { 2 } else { 1 }
        $Info.NumberOfClients | Should -BeExactly $ExpectedClients
        $Info.NumberOfConnections | Should -BeExactly 0
    }
    It "Collects information about the inventory with a different path" {
        $env:PORTAL_INVENTORY = Join-Path -Path $TestDrive -ChildPath "OtherInventory.json"
        $Info = Get-PortalInventory
        $Info.Path | Should -BeExactly $env:PORTAL_INVENTORY
        $Info.EnvVariable | Should -BeExactly "PORTAL_INVENTORY"
        $Info.FileExists | Should -BeFalse
        $Info.NumberOfClients | Should -BeExactly 0
        $Info.NumberOfConnections | Should -BeExactly 0
    }
}
Describe "Set-PortalInventory" {
    It "Sets the inventory path and creates a new file" {
        $CustomPath = Join-Path -Path $TestDrive -ChildPath "other_inventory.json"
        Set-PortalInventory -Path $CustomPath -Target "Process"
        New-PortalInventory -Force -PassThru | Should -BeExactly $CustomPath
    }
}
Describe "Default inventory path" {
    BeforeAll {
        $SavedInventory = $env:PORTAL_INVENTORY
        $SavedXdgConfigHome = $env:XDG_CONFIG_HOME
        Remove-Item -Path Env:PORTAL_INVENTORY -ErrorAction SilentlyContinue
    }
    AfterAll {
        $env:PORTAL_INVENTORY = $SavedInventory
        $env:XDG_CONFIG_HOME = $SavedXdgConfigHome
    }
    # Skipped when a custom path is set for the user or the machine (Windows only), as it takes precedence
    It "Uses the usual settings directory of the OS" -Skip:([bool](
            [System.Environment]::GetEnvironmentVariable("PORTAL_INVENTORY", "User") -or
            [System.Environment]::GetEnvironmentVariable("PORTAL_INVENTORY", "Machine")
        )) {
        $Expected = if ($IsWindows) {
            Join-Path -Path $env:APPDATA -ChildPath "Portal\inventory.json"
        }
        elseif ($IsMacOS) {
            Join-Path -Path $HOME -ChildPath "Library/Application Support/Portal/inventory.json"
        }
        else {
            Remove-Item -Path Env:XDG_CONFIG_HOME -ErrorAction SilentlyContinue
            Join-Path -Path $HOME -ChildPath ".config/portal/inventory.json"
        }
        (Get-PortalInventory).Path | Should -Be $Expected
    }
    It "Uses XDG_CONFIG_HOME on Linux when it is set" -Skip:(-not $IsLinux) {
        $env:XDG_CONFIG_HOME = Join-Path -Path $TestDrive -ChildPath "xdg"
        (Get-PortalInventory).Path | Should -Be (Join-Path -Path $TestDrive -ChildPath "xdg/portal/inventory.json")
    }
}
