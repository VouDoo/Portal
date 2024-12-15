BeforeAll {
    $Module = Get-Item -Path $env:PESTER_FILE_TO_TEST
    Import-Module -Name $Module.FullName -Force

    $env:PORTAL_INVENTORY = Join-Path -Path $TestDrive -ChildPath "Portal.json"
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
