# Portal

Portal is a PowerShell module that contains a collection of functions for managing and opening remote connections from your terminal.

_It is a very (very) simplified version of tools like mRemoteNG or MobaXterm._

## License

Portal is released under the terms of the MIT license.
See [LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>.

---

## Installation

To install the PowerShell module, follow one of these methods:

- [Install from PS Gallery](#install-from-ps-gallery)
- [Get released versions](#get-released-versions)
- [Build from Source](#build-from-source)

Please note that the module is only available for PowerShell Core (7.1 or later).

Get the latest version of PS Core from [the official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

### Install from PS Gallery

The module is published on PowerShell Gallery.
See <https://www.powershellgallery.com/packages/Portal>.

To install it, run:

```powershell
Install-Module -Name Portal -Repository PSGallery
```

### Get released versions

Download `Portal.zip` from [the "Releases" page](https://github.com/VouDoo/Portal/releases).
Extract it in `C:\Users\<your_user>\Documents\PowerShell\Modules\`.

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

- [Portal](#portal)
  - [License](#license)
  - [Installation](#installation)
    - [Install from PS Gallery](#install-from-ps-gallery)
    - [Get released versions](#get-released-versions)
    - [Build from Source](#build-from-source)
  - [Usage](#usage)
    - [Prepare your environment](#prepare-your-environment)
    - [Create an inventory file](#create-an-inventory-file)
    - [Add a client](#add-a-client)
    - [Add a connection](#add-a-connection)
    - [Open a connection](#open-a-connection)
    - [Get help](#get-help)
  - [What's next?](#whats-next)
  - [Support](#support)

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
# Add in Microsoft.PowerShell_profile.ps1
Import-Module -Name Portal
New-Alias -Name co -Value Open-Portal
New-Alias -Name coTest -Value Test-Portal
New-Alias -Name coGet -Value Get-Portal
New-Alias -Name coAdd -Value Add-Portal
New-Alias -Name coRm -Value Remove-Portal
```

_Feel free to use your own aliases!_

### Create an inventory file

First, you need to create an inventory file, where your connections will be stored.

Use `New-PortalInventory` to create the inventory file.
Simply run:

```powershell
New-PortalInventory
```

By default, the inventory file is created in `%APPDATA%\Portal\inventory.json`.

To use a custom path, run:

```powershell
Set-PortalInventory "C:\path\to\your\inventory.json"
```

_The inventory uses the JSON format._

### Add a client

Clients are defined programs that are interpreted and executed when you open a connection.

To add a client, use `Add-PortalClient`.
For instance:

```powershell
Add-PortalClient -Name MySSH -Executable "ssh.exe" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "My first SSH client"
```

Find out more examples [here](examples/clients.md).

The `-Arguments` parameter takes a tokenized string which represents the arguments passed to the executable.

_Some tokens must be present in this string._

| Token    | Required | Description |
|:--------:|:--------:| :---------- |
| `<host>` | Yes      | Name of the remote host. |
| `<port>` | Yes      | Port to connect to on the remote host. |
| `<user>` | No       | Name of the user to log in with.</br>If set, `Open-Portal` will ask for a username at each execution. |

The `-Scope` parameter defines in which scope a connection will be opened by default.

_If not specified, the default scope is set as `Console`._

| Scope       | Default | Description |
|:-----------:| :-----: | :---------- |
| `Console`   | Yes     | Open the connection process in the current console. |
| `External`  | No      | Open the connection process as an independant process (external window). |
| `Undefined` | No      | Undefined scope.</br>A scope must be specified when the connection is opened. |

### Add a connection

To add a connection, use `Add-Portal`.
For instance:

```powershell
Add-Portal -Name Perseverance -Hostname perseverance.mars.solarsys -DefaultClient MySSH -DefaultUser nasa -Description "My connection to the Perseverance Rover"
```

**Tip**: _Use the `TAB` key to autocomplete the name of the client._

### Open a connection

To open a connection, use `Open-Portal`.
For instance:

```powershell
Open-Portal Perseverance
```

**Tip**: _Use the `TAB` key to autocomplete the name of the connection._

### Get help

Read help files in [docs/cmdlet-help](docs/cmdlet-help).

You can also use [the `Get-Help` Cmdlet](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-help) to obtain more information about a command.

---

## What's next?

Here are some ideas that future releases might cover:

- Make client arguments more flexible.
- Add extra tokens with custom features.
- Implement specific error exceptions.
- Optimize code.
- Provide better documentation.
- And more...

I [KISS](https://en.wikipedia.org/wiki/KISS_principle) it...

## Support

If you have any bug reports, log them on [the issue tracker](https://github.com/VouDoo/Portal/issues).

If you have some suggestions, please don't hesitate to contact me (find email on [my GitHub profile](https://github.com/VouDoo)).
