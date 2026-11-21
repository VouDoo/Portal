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
It works on Windows, Linux and macOS.

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
Extract it to your user modules directory:

- Windows: `~\Documents\PowerShell\Modules\`
- Linux and macOS: `~/.local/share/powershell/Modules/`

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
Add-PortalClient -Name MySSH -Executable "ssh.exe" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "My first SSH client"
```

Find examples [here](examples/clients.md).

The `-Arguments` parameter takes a tokenized string which represents the arguments passed to the executable.

_Some tokens must be present in this string._
_Arguments are separated by spaces. Use quotes to keep several words in one argument (e.g. `-i "~/my keys/id_ed25519"`). The string is not interpreted by PowerShell, so variables like `$env:USERNAME` are not expanded._

| Token    | Required | Description |
|:--------:|:--------:| :---------- |
| `<host>` | Yes      | Name of the remote host. |
| `<port>` | Yes      | Port to connect to on the remote host. |
| `<user>` | No       | Name of the user to log in with.</br>If set, `Open-Portal` will ask for a username at each execution. |

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
