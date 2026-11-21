BeforeAll {
    $Module = Get-Item -Path $env:PESTER_FILE_TO_TEST
    Import-Module -Name $Module.FullName -Force

    $env:PORTAL_INVENTORY = Join-Path -Path $TestDrive -ChildPath "inventory.json"
    New-PortalInventory -NoDefaultClients
}
Describe "Add-PortalClient" {
    It "Adds a client" {
        $Arguments = @{
            Name        = "TestClient1"
            Executable  = "client1.exe"
            Arguments   = "-p <port> <host>"
            DefaultPort = 1234
            Description = "A test client."
        }
        Add-PortalClient @Arguments | Should -BeNullOrEmpty
    }
    It "Adds another client" {
        $Arguments = @{
            Name         = "TestClient2"
            Executable   = "client2.exe"
            Arguments    = "<port>:<host> --with <user>"
            DefaultPort  = 5678
            DefaultScope = "External"
        }
        Add-PortalClient @Arguments | Should -BeNullOrEmpty
    }
    It "Adds a client with an already used name, and fails" {
        $Arguments = @{
            Name        = "TestClient2"
            Executable  = "client2.exe"
            Arguments   = "-p <port> -h <host>"
            DefaultPort = 2468
        }
        { Add-PortalClient @Arguments } | Should -Throw -ExpectedMessage "Cannot add Client `"TestClient2`" as it already exists."
    }
    It "Adds a client with incorrect tokens, and fails" {
        $Arguments = @{
            Name        = "IncorrectTestClient"
            Executable  = "incorrectclient.exe"
            Arguments   = "--port <prot> --host <host>"
            DefaultPort = 1234
        }
        { Add-PortalClient @Arguments } | Should -Throw -ExpectedMessage "*The argument line does not contain the following token: <port>*"
    }
    It "Adds a client with incorrect scope, and fails" {
        $Arguments = @{
            Name         = "IncorrectTestClient"
            Executable   = "incorrectclient.exe"
            Arguments    = "<port>:<host> --with <user>"
            DefaultPort  = 2546
            DefaultScope = "IncorrectScope"
        }
        { Add-PortalClient @Arguments } | Should -Throw -ExpectedMessage "*Unable to match the identifier name IncorrectScope to a valid enumerator name*"
    }
}
Describe "Get-PortalClient" {
    BeforeAll {
        @(
            @{
                Name        = "TestClient3"
                Executable  = "client3.exe"
                Arguments   = "-p <port> <host>"
                DefaultPort = 7654
            },
            @{
                Name        = "ClientTest4"
                Executable  = "client4.exe"
                Arguments   = "-h <host> -p <port> --user <user>"
                DefaultPort = 5678
            }
        ) | ForEach-Object -Process {
            Add-PortalClient @_
        }
    }
    It "Gets Clients" {
        Get-PortalClient | Should -BeOfType PSCustomObject
    }
    It "Gets Clients with exact count" {
        (Get-PortalClient).count | Should -BeExactly 4
    }
    It "Gets Clients filtered by name" {
        (Get-PortalClient -Name "ClientTest*")[0].Name | Should -BeExactly "ClientTest4"
    }
    It "Gets Clients filtered by name that do not exist" {
        (Get-PortalClient -Name "ClientTestt*") | Should -BeNullOrEmpty
    }
}
Describe "Remove-PortalClient" {
    It "Removes an existing Client" {
        Remove-PortalClient -Name "TestClient1" | Should -BeNullOrEmpty
    }
    It "Removes a client that does not exist, and fails" {
        { Remove-PortalClient -Name "TestClient0" } | Should -Throw
    }
}
Describe "Rename-PortalClient" {
    BeforeAll {
        @(
            @{
                Name        = "BadlyNamedClient"
                Executable  = "client.exe"
                Arguments   = "-p <port> <host>"
                DefaultPort = 12345
            },
            @{
                Name        = "WhateverClient"
                Executable  = "whatever.exe"
                Arguments   = "-h <host> -p <port>"
                DefaultPort = 666
            }
        ) | ForEach-Object -Process {
            Add-PortalClient @_
        }
    }
    It "Renames an existing client" {
        Rename-PortalClient -Name "BadlyNamedClient" -NewName "NicelyNamedClient"
        | Should -BeNullOrEmpty
    }
    It "Renames a client that does not exist, and fails" {
        { Rename-PortalClient -Name "MissingClient" -NewName "NopeClient" } | Should -Throw
    }
    It "Renames a client with a name already used, and fails" {
        { Rename-PortalClient -Name "NicelyNamedClient" -NewName "WhateverClient" }
        | Should -Throw -ExpectedMessage "Cannot rename Client `"NicelyNamedClient`" to `"WhateverClient`" as this name is already used."
    }
    It "Uses same name for renaming, and fails" {
        { Rename-PortalClient -Name "NicelyNamedClient" -NewName "NicelyNamedClient" }
        | Should -Throw -ExpectedMessage "The two names are similar."
    }
}
Describe "Client argument line" {
    It "Splits <ArgumentLine>" -ForEach @(
        @{ ArgumentLine = "-p <port> <host>"; Expected = @("-p", "<port>", "<host>") }
        @{ ArgumentLine = "  -p   <port>  "; Expected = @("-p", "<port>") }
        @{ ArgumentLine = '-i "C:\my keys\id" <host>'; Expected = @("-i", "C:\my keys\id", "<host>") }
        @{ ArgumentLine = "-i '/my keys/id' <host>"; Expected = @("-i", "/my keys/id", "<host>") }
        @{ ArgumentLine = '--title="My server" <host>'; Expected = @("--title=My server", "<host>") }
        @{ ArgumentLine = '-o "" <host>'; Expected = @("-o", "", "<host>") }
        @{ ArgumentLine = "-m `"it's`" <host>"; Expected = @("-m", "it's", "<host>") }
    ) {
        InModuleScope -ModuleName Portal -Parameters @{ ArgumentLine = $ArgumentLine } {
            [Client]::SplitArgs($ArgumentLine)
        } | Should -Be $Expected
    }
    It "Fails with an unclosed quote" {
        { InModuleScope -ModuleName Portal { [Client]::SplitArgs('-i "C:\my keys <host>') } }
        | Should -Throw -ExpectedMessage "*unclosed quote*"
    }
}
Describe "Client scope in the inventory file" {
    It "Writes the scope name in the inventory file" {
        Add-PortalClient -Name "ScopeClient" -Executable "client.exe" -Arguments "<host> <port>" -DefaultPort 1 -DefaultScope External
        $Client = (Get-Content -Path $env:PORTAL_INVENTORY -Raw | ConvertFrom-Json).Clients
        | Where-Object -Property Name -EQ "ScopeClient"
        $Client.DefaultScope | Should -BeExactly "External"
    }
    It "Reads a scope written as a number (older inventory files)" {
        $Inventory = Get-Content -Path $env:PORTAL_INVENTORY -Raw | ConvertFrom-Json
        ($Inventory.Clients | Where-Object -Property Name -EQ "ScopeClient").DefaultScope = 2
        $Inventory | ConvertTo-Json -Depth 3 | Set-Content -Path $env:PORTAL_INVENTORY
        (Get-PortalClient -Name "ScopeClient").DefaultScope | Should -Be "Console"
    }
}
