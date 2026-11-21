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
    It "Gets the custom port of a connection" {
        (Get-Portal -Name "ConnectionTest4").Port | Should -BeExactly 6666
    }
    It "Gets the default port of the client when the connection has no port" {
        (Get-Portal -Name "TestConnection3").Port | Should -BeExactly 5678
    }
    It "Gets Connections filtered by name and client name that do not exist" {
        (Get-Portal -Name "*Test3" -Client "TestClient") | Should -BeNullOrEmpty
    }
    It "Gets Connections filtered by name and hostname name that do not exist" {
        (Get-Portal -Name "*Test2" -Hostname "do.not.exist") | Should -BeNullOrEmpty
    }
}
Describe "Open-Portal" {
    BeforeAll {
        # Client running a script that writes each argument it receives on its own line.
        # The script lives in a directory with a space to check that quoted arguments stay intact.
        $ScriptDirectory = Join-Path -Path $TestDrive -ChildPath "echo args"
        New-Item -Path $ScriptDirectory -ItemType Directory | Out-Null
        $EchoScript = Join-Path -Path $ScriptDirectory -ChildPath "echo-args.ps1"
        Set-Content -Path $EchoScript -Value '$args | ForEach-Object -Process { $_ }'
        $Pwsh = (Get-Process -Id $PID).Path

        Add-PortalClient -Name "EchoClient" -Executable $Pwsh -DefaultPort 4242 -Arguments (
            "-NoProfile -File `"{0}`" <host> <port> <user>" -f $EchoScript
        )
        Add-Portal -Name "EchoConnection" -Hostname "echo.test" -DefaultClient "EchoClient" -DefaultUser "alice"
        Add-Portal -Name "EchoConnectionNoUser" -Hostname "echo.test" -Port 2222 -DefaultClient "EchoClient"
    }
    It "Opens a connection with the default user and the default port of the client" {
        Open-Portal -Name "EchoConnection" | Should -Be @("echo.test", "4242", "alice")
    }
    It "Opens a connection with a specified user and the port of the connection" {
        Open-Portal -Name "EchoConnectionNoUser" -User "bob" | Should -Be @("echo.test", "2222", "bob")
    }
    It "Opens a connection without a user when the client requires one, and fails" {
        { Open-Portal -Name "EchoConnectionNoUser" } | Should -Throw -ExpectedMessage "*A user must be specified*"
    }
    It "Keeps a user containing spaces and shell characters as a single argument" {
        $User = 'bob; Write-Output INJECTED'
        Open-Portal -Name "EchoConnection" -User $User | Should -Be @("echo.test", "4242", $User)
    }
    It "Does not open the connection with -WhatIf" {
        Open-Portal -Name "EchoConnection" -WhatIf | Should -BeNullOrEmpty
    }
}
Describe "Open-Portal in the External scope" {
    BeforeAll {
        # Client started as an independent process, writing the arguments it receives to a file
        $ScriptDirectory = Join-Path -Path $TestDrive -ChildPath "record args"
        New-Item -Path $ScriptDirectory -ItemType Directory | Out-Null
        $RecordScript = Join-Path -Path $ScriptDirectory -ChildPath "record-args.ps1"
        $RecordFile = Join-Path -Path $ScriptDirectory -ChildPath "args.txt"
        Set-Content -Path $RecordScript -Value (
            'Set-Content -Path "{0}.tmp" -Value $args; Move-Item -Path "{0}.tmp" -Destination "{0}"' -f $RecordFile
        )
        $Pwsh = (Get-Process -Id $PID).Path

        Add-PortalClient -Name "RecordClient" -Executable $Pwsh -DefaultPort 4242 -DefaultScope External -Arguments (
            "-NoProfile -NonInteractive -File `"{0}`" <host> <port> <user>" -f $RecordScript
        )
        Add-Portal -Name "RecordConnection" -Hostname "record.test" -DefaultClient "RecordClient"

        function Get-RecordedArgs {
            # Waits for the independent process to write the file
            $Deadline = (Get-Date).AddSeconds(30)
            while (-not (Test-Path -Path $RecordFile) -and (Get-Date) -lt $Deadline) {
                Start-Sleep -Milliseconds 200
            }
            Get-Content -Path $RecordFile
        }
    }
    BeforeEach {
        Remove-Item -Path $RecordFile -ErrorAction SilentlyContinue
    }
    It "Passes the user <User> as a single argument" -ForEach @(
        @{ User = "alice" }
        @{ User = "my user" }
        @{ User = 'C:\my dir\' }
        @{ User = 'bob "the builder"' }
        @{ User = 'bob; Write-Output INJECTED' }
    ) {
        Open-Portal -Name "RecordConnection" -User $User
        Get-RecordedArgs | Should -Be @("record.test", "4242", $User)
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
Describe "Remove-PortalClient used by connections" {
    BeforeAll {
        Add-PortalClient -Name "UsedClient" -Executable "client.exe" -Arguments "-p <port> <host>" -DefaultPort 1234
        Add-Portal -Name "UsingConnection1" -Hostname "using1.test" -DefaultClient "UsedClient"
        Add-Portal -Name "UsingConnection2" -Hostname "using2.test" -DefaultClient "UsedClient"
    }
    It "Removes a client used by connections, and fails" {
        { Remove-PortalClient -Name "UsedClient" }
        | Should -Throw -ExpectedMessage "*default client of these connections: UsingConnection1, UsingConnection2*"
        (Get-PortalClient -Name "UsedClient").Name | Should -BeExactly "UsedClient"
    }
    It "Forces the removal of a client used by connections, with a warning" {
        Remove-PortalClient -Name "UsedClient" -Force -WarningVariable Warnings -WarningAction SilentlyContinue
        $Warnings | Should -HaveCount 1
        $Warnings[0].Message | Should -BeLike "*UsingConnection1, UsingConnection2*"
        Get-PortalClient -Name "UsedClient" | Should -BeNullOrEmpty
    }
    It "Keeps the connections of the removed client" {
        (Get-Portal -Client "UsedClient").Name | Should -Be @("UsingConnection1", "UsingConnection2")
    }
}
