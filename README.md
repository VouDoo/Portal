# Portal

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/Portal)](https://www.powershellgallery.com/packages/Portal)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/Portal)](https://www.powershellgallery.com/packages/Portal)
[![CI](https://github.com/VouDoo/Portal/actions/workflows/ci.yml/badge.svg)](https://github.com/VouDoo/Portal/actions/workflows/ci.yml)

Portal is a PowerShell module for managing and opening remote connections (SSH, Remote Desktop...) from your terminal, on Windows, Linux and macOS.

_Think of Portal as a very basic version of mRemoteNG or MobaXterm, integrated directly into your shell..._

## Quick start

```powershell
Install-Module -Name Portal    # Install the module from PowerShell Gallery
New-PortalInventory            # Create your inventory, with default clients such as OpenSSH
Add-Portal -Name myserver -Hostname server.example.com -DefaultClient OpenSSH -DefaultUser me
Open-Portal myserver           # Connect!
```

![Portal demo](medias/intro.gif)

_This demo was recorded when Portal was still named MyRemoteManager:
`New-MyRMInventory`, `Add-MyRMConnection` and `Invoke-MyRMConnection` are now `New-PortalInventory`, `Add-Portal` and `Open-Portal`._

---

Table of contents:

- [Portal](#portal)
  - [Quick start](#quick-start)
  - [Installation](#installation)
    - [Install from PowerShell Gallery](#install-from-powershell-gallery)
    - [Get released versions](#get-released-versions)
    - [Build from Source](#build-from-source)
  - [Usage](#usage)
    - [Prepare your environment](#prepare-your-environment)
    - [Create an inventory file](#create-an-inventory-file)
    - [Add a client](#add-a-client)
    - [Add a connection](#add-a-connection)
    - [Open a connection](#open-a-connection)
    - [Commands](#commands)
    - [Get help](#get-help)
  - [Contributing](#contributing)
  - [License](#license)
  - [Support](#support)

---

## Installation

Portal requires PowerShell 7.1 or later, on Windows, Linux or macOS.
Get the latest version of PowerShell from [the official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

### Install from PowerShell Gallery

The module is published on PowerShell Gallery.
See <https://www.powershellgallery.com/packages/Portal>.

To install it, run:

```powershell
Install-Module -Name Portal -Repository PSGallery
```

_On PowerShell 7.4 or later, you can also run `Install-PSResource -Name Portal`._

### Get released versions

Download `Portal.zip` from [the "Releases" page](https://github.com/VouDoo/Portal/releases).
Extract it to your user modules directory:

- Windows: `~\Documents\PowerShell\Modules\`
- Linux and macOS: `~/.local/share/powershell/Modules/`

### Build from Source

1. Unblock downloaded scripts _(optional, Windows only)_

    ```powershell
    Get-ChildItem -Filter *.ps1 | Unblock-File
    ```

2. Build the module

    ```powershell
    ./build.ps1 Build -Bootstrap
    ```

3. Remove any old versions of the module

    ```powershell
    $ModulesDirectory = $env:PSModulePath.Split([System.IO.Path]::PathSeparator)[0]
    Remove-Item (Join-Path $ModulesDirectory "Portal") -Recurse -Force -ErrorAction SilentlyContinue
    ```

4. Install the freshly built module

    ```powershell
    Copy-Item (Join-Path "Out" "Portal") $ModulesDirectory -Recurse
    ```

---

## Usage

### Prepare your environment

1. Import the module

    ```powershell
    Import-Module -Name Portal
    ```

2. Get the available commands

    ```powershell
    Get-Command -Module Portal
    ```

The fastest way to use the module is to import it from your [PowerShell profile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).
Then, each time you will open your PowerShell console, the module will be automatically imported.

We also recommend that you create aliases for the most commonly used commands.

Here is an example of code that you can add to your profile file:

```powershell
# Add the following lines to your profile (run "$PROFILE" to get its path)
Import-Module -Name Portal
New-Alias -Name connect -Value Open-Portal
```

_Feel free to use your own aliases!_

### Create an inventory file

First, you need to create an inventory file, which stores your configuration.

Use `New-PortalInventory` to create the inventory file.
Simply run:

```powershell
New-PortalInventory
```

By default, the inventory file is created in the usual settings directory of your OS:

| OS      | Default path |
|:-------:| :----------- |
| Windows | `%APPDATA%\Portal\inventory.json` |
| Linux   | `$XDG_CONFIG_HOME/portal/inventory.json` (or `~/.config/portal/inventory.json`) |
| macOS   | `~/Library/Application Support/Portal/inventory.json` |

The default clients also depend on your OS: OpenSSH, PuTTY and Remote Desktop on Windows, OpenSSH and FreeRDP on Linux, OpenSSH on macOS.

To use a custom path, run:

```powershell
Set-PortalInventory "C:\path\to\your\inventory.json"
```

The path is stored in the `PORTAL_INVENTORY` environment variable.
On Linux and macOS, environment variables cannot be saved for your user, so add this line to your PowerShell profile instead:

```powershell
$env:PORTAL_INVENTORY = "/path/to/your/inventory.json"
```

_The inventory uses the JSON format, do not forget the file extension._

### Add a client

Clients are defined programs that are interpreted and executed when you open a connection.

To add a client, use `Add-PortalClient`.
For instance:

```powershell
Add-PortalClient -Name MySSH -Executable "ssh" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "My first SSH client"
```

Find examples [here](examples/clients.md).

The `-Arguments` parameter takes a tokenized string which represents the arguments passed to the executable.

_Some tokens must be present in this string._
_Arguments are separated by spaces. Use quotes to keep several words in one argument (e.g. `-i "~/my keys/id_ed25519"`). The string is not interpreted by PowerShell, so variables like `$env:USERNAME` are not expanded._

| Token    | Required | Description |
|:--------:|:--------:| :---------- |
| `<host>` | Yes      | Name of the remote host. |
| `<port>` | Yes      | Port to connect to on the remote host. |
| `<user>` | No       | Name of the user to log in with.</br>If set, `Open-Portal` needs a user: the `-User` parameter, or the default user of the connection. |

The `-DefaultScope` parameter defines in which scope a connection will be opened by default.

| Scope       | Description |
|:-----------:| :---------- |
| `Console`   | Open the connection process in the current console. **(Default)** |
| `External`  | Open the connection process as an independent process (external window).</br>On Linux and macOS, terminal programs (like `ssh`) do not get their own window: use your terminal emulator as the executable instead (e.g. `-Executable kitty -Arguments "ssh -p <port> <host>"`). |
| `Undefined` | Undefined scope.</br>A scope must be specified when the connection is opened. |

### Add a connection

To add a connection, use `Add-Portal`.
For instance:

```powershell
Add-Portal -Name Perseverance -Hostname perseverance.mars.solarsys -DefaultClient MySSH -DefaultUser nasa -Description "My connection to the Perseverance Rover"
```

_Press TAB key to autocomplete the name of the client._

### Open a connection

To open a connection, use `Open-Portal`.
For instance:

```powershell
Open-Portal Perseverance
```

_Press TAB key to autocomplete the name of the connection._

To use another user, client or scope for this time only, run:

```powershell
Open-Portal Perseverance -User root -Client MyOtherSSH -Scope External
```

### Commands

| Command | Description |
| :------ | :---------- |
| `New-PortalInventory` | Creates the inventory file. |
| `Get-PortalInventory` | Gets information about the inventory (path, number of clients and connections). |
| `Set-PortalInventory` | Sets a custom path for the inventory file. |
| `Add-PortalClient` | Adds a client. |
| `Get-PortalClient` | Gets clients, filtered by name. |
| `Rename-PortalClient` | Renames a client, and updates the connections using it. |
| `Remove-PortalClient` | Removes a client. |
| `Add-Portal` | Adds a connection. |
| `Get-Portal` | Gets connections, filtered by name, hostname and/or default client. |
| `Open-Portal` | Opens a connection. |
| `Test-Portal` | Tests if the remote host of a connection is reachable on its port. |
| `Rename-Portal` | Renames a connection. |
| `Remove-Portal` | Removes a connection. |

_Every command that changes the inventory supports `-WhatIf` and `-Confirm`._

### Get help

Read help files in [docs/cmdlet-help](docs/cmdlet-help).

You can also use [the `Get-Help` Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) to obtain more information about a command.

---

## Contributing

To build, test and contribute to the module, read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Portal is released under the terms of the MIT license.
See [LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>.

## Support

If you have any bug reports, log them on [the issue tracker](https://github.com/VouDoo/Portal/issues).

If you have some suggestions, please don't hesitate to contact me (find email on [my GitHub profile](https://github.com/VouDoo)).
