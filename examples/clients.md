# Clients

The list below shows you various examples of clients, which can be added in your inventory.

## OpenSSH from Microsoft Windows features

Note: _This is part of the default clients when a new inventory is created._

- Executable: `C:\Windows\System32\OpenSSH\ssh.exe`
- Arguments: `-l <user> -p <port> <host>`
- Default port: `22`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name OpenSSH -Executable "C:\Windows\System32\OpenSSH\ssh.exe" -Arguments "-l <user> -p <port> <host>" -DefaultPort 22 -DefaultScope Console -Description "OpenSSH (Microsoft Windows feature)"
```

## Putty SSH

Note: _This is part of the default clients when a new inventory is created._

- Executable: `putty.exe` (from PATH)
- Arguments: `-ssh -P <port> <user>@<host>`
- Default port: `22`
- Default Scope: `External`

```powershell
Add-PortalClient -Name PuTTY_SSH -Executable "putty.exe" -Arguments "-ssh -P <port> <user>@<host>" -DefaultPort 22 -DefaultScope External -Description "PuTTY using SSH protocol"
```

## Remote Desktop

Note: _This is part of the default clients when a new inventory is created._

- Executable: `C:\Windows\System32\mstsc.exe`
- Arguments: `/v:<host>:<port> /fullscreen`
- Default port: `3389`
- Default Scope: `External`

```powershell
Add-PortalClient -Name RD -Executable "C:\Windows\System32\mstsc.exe" -Arguments "/v:<host>:<port> /fullscreen" -DefaultPort 3389 -DefaultScope External -Description "Microsoft Remote Desktop"
```

## Google Chrome

- Executable: `C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`
- Arguments: `<host>:<port>`
- Default port: `443`
- Default Scope: `External`

```powershell
Add-PortalClient -Name Chrome -Executable "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -Arguments "<host>:<port>" -DefaultPort 443 -DefaultScope External -Description "Google Chrome"
```

## Telnet from Microsoft Windows features

- Executable: `C:\Windows\System32\telnet.exe`
- Arguments: `<host> <port>`
- Default port: `23`
- Default Scope: `Console`

```powershell
Add-PortalClient -Name Telnet -Executable "C:\Windows\System32\telnet.exe" -Arguments "<host> <port>" -DefaultPort 23 -DefaultScope Console -Description "Telnet (Microsoft Windows feature)"
```
