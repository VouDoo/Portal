# Clients

The list below shows you various examples of clients, which can be added in your inventory.

Arguments are separated by spaces, and quotes keep several words in one argument.
The arguments are not interpreted by PowerShell: variables (e.g. `$env:USERNAME`) are not expanded.

- [Clients](#clients)
  - [Windows](#windows)
    - [OpenSSH from Microsoft Windows features](#openssh-from-microsoft-windows-features)
    - [PuTTY SSH](#putty-ssh)
    - [Remote Desktop](#remote-desktop)
    - [SSH in a new Windows Terminal tab](#ssh-in-a-new-windows-terminal-tab)
    - [Google Chrome](#google-chrome)
    - [Telnet from Microsoft Windows features](#telnet-from-microsoft-windows-features)
  - [Linux](#linux)
    - [OpenSSH](#openssh)
    - [FreeRDP](#freerdp)
    - [SSH in a new kitty window](#ssh-in-a-new-kitty-window)
    - [SSH in a new GNOME Terminal window](#ssh-in-a-new-gnome-terminal-window)
  - [macOS](#macos)
    - [OpenSSH](#openssh-1)
    - [SSH in a new Terminal window](#ssh-in-a-new-terminal-window)
  - [All systems](#all-systems)
    - [SSH with a specific key](#ssh-with-a-specific-key)

## Windows

### OpenSSH from Microsoft Windows features

Note: _This is part of the default clients when a new inventory is created on Windows._

- Executable: `C:\Windows\System32\OpenSSH\ssh.exe`
- Arguments: `-l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name OpenSSH -Executable "C:\Windows\System32\OpenSSH\ssh.exe" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "OpenSSH (Microsoft Windows feature)"
```

### PuTTY SSH

Note: _This is part of the default clients when a new inventory is created on Windows._

- Executable: `putty.exe` (from PATH)
- Arguments: `-ssh -P <port> <user>@<host>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name PuTTY_SSH -Executable "putty.exe" -Arguments "-ssh -P <port> <user>@<host>" -DefaultPort 22 -DefaultScope External -Description "PuTTY using SSH protocol"
```

### Remote Desktop

Note: _This is part of the default clients when a new inventory is created on Windows._

- Executable: `C:\Windows\System32\mstsc.exe`
- Arguments: `/v:<host>:<port> /fullscreen`
- Default port: `3389`
- Default Scope: `External`

```powershell
Add-PortalClient -Name RD -Executable "C:\Windows\System32\mstsc.exe" -Arguments "/v:<host>:<port> /fullscreen" -DefaultPort 3389 -DefaultScope External -Description "Microsoft Remote Desktop"
```

### SSH in a new Windows Terminal tab

- Executable: `wt.exe` (from PATH)
- Arguments: `ssh -l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name WindowsTerminal_SSH -Executable "wt.exe" -Arguments "ssh -l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope External -Description "SSH in a new Windows Terminal tab"
```

### Google Chrome

- Executable: `C:\Program Files\Google\Chrome\Application\chrome.exe`
- Arguments: `https://<host>:<port>`
- Default port: `443`
- Default Scope: `External`

```powershell
Add-PortalClient -Name Chrome -Executable "C:\Program Files\Google\Chrome\Application\chrome.exe" -Arguments "https://<host>:<port>" -DefaultPort 443 -DefaultScope External -Description "Google Chrome"
```

### Telnet from Microsoft Windows features

Note: _The Telnet client is an optional Windows feature, which must be enabled first._

- Executable: `C:\Windows\System32\telnet.exe`
- Arguments: `<host> <port>`
- Default port: `23`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name Telnet -Executable "C:\Windows\System32\telnet.exe" -Arguments "<host> <port>" -DefaultPort 23 -DefaultScope Console -Description "Telnet (Microsoft Windows feature)"
```

## Linux

### OpenSSH

Note: _This is part of the default clients when a new inventory is created on Linux._

- Executable: `ssh` (from PATH)
- Arguments: `-l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name OpenSSH -Executable "ssh" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "OpenSSH client"
```

### FreeRDP

Note: _This is part of the default clients when a new inventory is created on Linux._

- Executable: `xfreerdp3` (from PATH, FreeRDP 3)
- Arguments: `/v:<host>:<port> /u:<user> /f`
- Default port: `3389`
- Default Scope: `External`

```powershell
Add-PortalClient -Name FreeRDP -Executable "xfreerdp3" -Arguments "/v:<host>:<port> /u:<user> /f" -DefaultPort 3389 -DefaultScope External -Description "FreeRDP (Remote Desktop client)"
```

### SSH in a new kitty window

On Linux, a terminal program (like `ssh`) opened in the `External` scope does not get its own window.
Use your terminal emulator as the executable instead.

- Executable: `kitty` (from PATH)
- Arguments: `ssh -l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name Kitty_SSH -Executable "kitty" -Arguments "ssh -l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope External -Description "SSH in a new kitty window"
```

### SSH in a new GNOME Terminal window

- Executable: `gnome-terminal` (from PATH)
- Arguments: `-- ssh -l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name GnomeTerminal_SSH -Executable "gnome-terminal" -Arguments "-- ssh -l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope External -Description "SSH in a new GNOME Terminal window"
```

## macOS

### OpenSSH

Note: _This is part of the default clients when a new inventory is created on macOS._

- Executable: `ssh` (from PATH)
- Arguments: `-l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name OpenSSH -Executable "ssh" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "OpenSSH client"
```

### SSH in a new Terminal window

`open` passes the `ssh://` URL to its default application (Terminal), which opens a new window.

- Executable: `open`
- Arguments: `ssh://<user>@<host>:<port>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name Terminal_SSH -Executable "open" -Arguments "ssh://<user>@<host>:<port>" -DefaultPort 22 -DefaultScope External -Description "SSH in a new Terminal window"
```

## All systems

### SSH with a specific key

Quotes keep a path containing spaces in one argument.
Use a full path: `~` is only expanded if the program itself does it.

- Executable: `ssh` (from PATH)
- Arguments: `-i "<path to the key>" -l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `Console`

```powershell
# Windows
Add-PortalClient -Name OpenSSH_Key -Executable "ssh" -Arguments '-i "C:\Users\me\my keys\id_ed25519" -l <user> -p <port> <host>' -DefaultPort 22 -DefaultScope Console -Description "OpenSSH with a specific key"

# Linux and macOS
Add-PortalClient -Name OpenSSH_Key -Executable "ssh" -Arguments '-i "/home/me/my keys/id_ed25519" -l <user> -p <port> <host>' -DefaultPort 22 -DefaultScope Console -Description "OpenSSH with a specific key"
```
