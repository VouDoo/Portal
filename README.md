# Portal

Portal is a PowerShell module that contains a collection of functions for managing and opening remote connections from your terminal.

_Think of Portal as a very basic version of mRemoteNG or MobaXterm, integrated directly into your shell..._

---

Table of contents:

- [Portal](#portal)
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
    - [Get help](#get-help)
  - [License](#license)
  - [Support](#support)

---

## Installation

To install the PowerShell module, follow one of these methods:

- [Install from PowerShell Gallery](#install-from-powershell-gallery)
- [Get released versions](#get-released-versions)
- [Build from Source](#build-from-source)

Please note that the module is only available for PowerShell Core (7.1 or later).

Get the latest version of PS Core from [the official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

### Install from PowerShell Gallery

The module is published on PowerShell Gallery.
See <https://www.powershellgallery.com/packages/Portal>.

To install it, run:

```powershell
Install-Module -Name Portal -Repository PSGallery
```

### Get released versions

Download `Portal.zip` from [the "Releases" page](https://github.com/VouDoo/Portal/releases).
Extract it to the `~\Documents\PowerShell\Modules\` directory.

### Build from Source

1. Unblock downloaded scripts _(optional)_

    ```powershell
    Get-ChildItem -Filter *.ps1 | Unblock-File
    ```

2. Build the module

    ```powershell
    .\build.ps1 build -Bootstrap
    ```

3. Remove any old versions of the module

    ```powershell
    Remove-Item "$HOME\Documents\PowerShell\Modules\Portal" -Force
    ```

4. Install the freshly built module

    ```powershell
    Copy-Item ".\Out\Portal" "$HOME\Documents\PowerShell\Modules\" -Recurse
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
# Add the following lines to your Microsoft.PowerShell_profile.ps1 file
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

By default, the inventory file is created as `%APPDATA%\Portal\inventory.json`.

To use a custom path, run:

```powershell
Set-PortalInventory "C:\path\to\your\inventory.json"
```

_The inventory uses the JSON format, do not forget the file extension._

### Add a client

Clients are defined programs that are interpreted and executed when you open a connection.

To add a client, use `Add-PortalClient`.
For instance:

```powershell
Add-PortalClient -Name MySSH -Executable "ssh.exe" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "My first SSH client"
```

Find examples [here](examples/clients.md).

The `-Arguments` parameter takes a tokenized string which represents the arguments passed to the executable.

_Some tokens must be present in this string._

| Token    | Required | Description |
|:--------:|:--------:| :---------- |
| `<host>` | Yes      | Name of the remote host. |
| `<port>` | Yes      | Port to connect to on the remote host. |
| `<user>` | No       | Name of the user to log in with.</br>If set, `Open-Portal` will ask for a username at each execution. |

The `-Scope` parameter defines in which scope a connection will be opened by default.

| Scope       | Description |
|:-----------:| :---------- |
| `Console`   | Open the connection process in the current console. **(Default)** |
| `External`  | Open the connection process as an independant process (external window). |
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

### Get help

Read help files in [docs/cmdlet-help](docs/cmdlet-help).

You can also use [the `Get-Help` Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) to obtain more information about a command.

---

## License

Portal is released under the terms of the MIT license.
See [LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>.

## Support

If you have any bug reports, log them on [the issue tracker](https://github.com/VouDoo/Portal/issues).

If you have some suggestions, please don't hesitate to contact me (find email on [my GitHub profile](https://github.com/VouDoo)).
