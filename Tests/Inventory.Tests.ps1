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
        $Info.NumberOfClients | Should -BeExactly 3
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
