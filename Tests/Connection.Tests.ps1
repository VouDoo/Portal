BeforeAll {
    $Module = Get-Item -Path $env:PESTER_FILE_TO_TEST
    Import-Module -Name $Module.FullName -Force

    $env:PORTAL_INVENTORY = Join-Path -Path $TestDrive -ChildPath "inventory.json"
    New-PortalInventory -NoDefaultClients

    @(
        @{
            Name        = "TestClient"
            Executable  = "client.exe"
            Arguments   = "-p <port> <host>"
            DefaultPort = 1234
        },
        @{
            Name        = "ClientTest"
            Executable  = "client.exe"
            Arguments   = "--host <host> --port <port> --user <user>"
            DefaultPort = 5678
        }
    ) | ForEach-Object -Process {
        Add-PortalClient @_
    }
}
Describe "Add-Portal" {
    It "Adds a connection" {
        $Arguments = @{
            Name          = "TestConnection1"
            Hostname      = "conn1.test"
            Port          = 1234
            DefaultClient = "TestClient"
            Description   = "A test connection."
        }
        Add-Portal @Arguments | Should -BeNullOrEmpty
    }
    It "Adds another connection" {
        $Arguments = @{
            Name          = "TestConnection2"
            Hostname      = "conn2.test"
            DefaultClient = "TestClient"
        }
        Add-Portal @Arguments | Should -BeNullOrEmpty
    }
    It "Adds a connection with an already used name, and fails" {
        $Arguments = @{
            Name          = "TestConnection2"
            Hostname      = "conn2.test"
            Port          = 2468
            DefaultClient = "TestClient"
        }
        { Add-Portal @Arguments } | Should -Throw -ExpectedMessage "Cannot add Connection `"TestConnection2`" as it already exists."
    }
}
Describe "Get-Portal" {
    BeforeAll {
        @(
            @{
                Name          = "TestConnection3"
                Hostname      = "Hostname.test"
                DefaultClient = "ClientTest"
            },
            @{
                Name          = "ConnectionTest4"
                Hostname      = "Hostname.test"
                Port          = 6666
                DefaultClient = "TestClient"
            }
        ) | ForEach-Object -Process {
            Add-Portal @_
        }
    }
    It "Gets Connections" {
        Get-Portal | Should -BeOfType PSCustomObject
    }
    It "Gets Connections with exact count" {
        (Get-Portal).count | Should -BeExactly 4
    }
    It "Gets Connections filtered by name" {
        (Get-Portal -Name "ConnectionTest*")[0].Name | Should -BeExactly "ConnectionTest4"
    }
    It "Gets Connections filtered by client name" {
        (Get-Portal -Client "ClientTest")[0].Name | Should -BeExactly "TestConnection3"
    }
    It "Gets Connections filtered by hostname" {
        (Get-Portal -Hostname "conn2*")[0].Name | Should -BeExactly "TestConnection2"
    }
    It "Gets Connections filtered by name and client name" {
        (Get-Portal -Name "*tion2" -Client "TestClient")[0].Name | Should -BeExactly "TestConnection2"
    }
    It "Gets Connections filtered by name and hostname name" {
        (Get-Portal -Name "*tion3" -Hostname "*.test")[0].Name | Should -BeExactly "TestConnection3"
    }
    It "Gets Connections filtered by name and client name that do not exist" {
        (Get-Portal -Name "*Test3" -Client "TestClient") | Should -BeNullOrEmpty
    }
    It "Gets Connections filtered by name and hostname name that do not exist" {
        (Get-Portal -Name "*Test2" -Hostname "do.not.exist") | Should -BeNullOrEmpty
    }
}
Describe "Remove-Portal" {
    It "Removes an existing connection" {
        Remove-Portal -Name "TestConnection1" | Should -BeNullOrEmpty
    }
    It "Removes a connection that does not exist, and fails" {
        { Remove-Portal -Name "TestConnection0" } | Should -Throw
    }
}
