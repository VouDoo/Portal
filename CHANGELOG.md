<!-- markdownlint-disable-file MD024 -->
# Changelog

All notable changes to Portal is documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Hostnames may contain underscores (e.g. `host_name.local`)

### Fixed

- IPv6 addresses (e.g. `::1`, `fe80::1`, `2001:db8::10`) are accepted as hostnames.
  When a client uses `<host>:<port>`, IPv6 addresses are put in brackets (e.g. `/v:[::1]:3389`) ([#13](https://github.com/VouDoo/Portal/issues/13))
- An invalid hostname in the inventory file does not block the whole inventory anymore:
  it is reported with a warning, and only the commands opening or testing this connection fail ([#13](https://github.com/VouDoo/Portal/issues/13))

## [0.5.0]

### Added

- Support for Linux and macOS
  - The default inventory file is stored in the usual settings directory of the OS:
    `%APPDATA%\Portal` on Windows (unchanged),
    `$XDG_CONFIG_HOME/portal` (or `~/.config/portal`) on Linux,
    `~/Library/Application Support/Portal` on macOS
  - Default clients match the OS: OpenSSH (`ssh` from PATH) on Linux and macOS, and FreeRDP (`xfreerdp3`) on Linux
  - `Set-PortalInventory -Target User` sets the path for the current session and explains how to persist it in the PowerShell profile, as user environment variables cannot be persisted outside Windows
- Quotes in the `Arguments` of a client group several words into one argument
- `Force` parameter in `Remove-PortalClient` to remove a client even if it is the default client of some connections

### Changed

- `Open-Portal` does not use `Invoke-Expression` anymore:
  the arguments of a client are not interpreted by PowerShell, so variables such as `$env:USERNAME` are not expanded
- The inventory file stores the scope of a client by name (e.g. `"Console"`) instead of a number, and keeps the properties in a fixed order.
  Inventory files written by older versions are still supported

### Fixed

- `Get-Portal` showed the default port of the client instead of the port of the connection
- `Open-Portal` allowed command injection through values such as the user (Console scope)
- `Open-Portal` failed with executable paths containing spaces (Console scope)
- `Open-Portal` split arguments containing spaces, such as the user (External scope)
- `Remove-PortalClient` left connections without their default client: it now refuses to remove a client used by connections, unless `-Force` is used

## [0.4.1]

### Fixed

- Fix missing parent directory error when creating the inventory file.

## [0.4.0]

### Changed

- Rebrand to "Portal"
  - Cmdlet `Add-MyRMConnection` renamed to `Add-Portal`
  - Cmdlet `Add-MyRMClient` renamed to `Add-PortalClient`
  - Cmdlet `Get-MyRMConnection` renamed to `Get-Portal`
  - Cmdlet `Get-MyRMClient` renamed to `Get-PortalClient`
  - Cmdlet `Get-MyRMInventoryInfo` renamed to `Get-PortalInventory`
  - Cmdlet `New-MyRMInventory` renamed to `New-PortalInventory`
  - Cmdlet `Invoke-MyRMConnection` renamed to `Open-Portal`
  - Cmdlet `Remove-MyRMConnection` renamed to `Remove-Portal`
  - Cmdlet `Remove-MyRMClient` renamed to `Remove-PortalClient`
  - Cmdlet `Set-MyRMInventoryPath` renamed to `Set-PortalInventory`
  - Cmdlet `Test-MyRMConnection` renamed to `Test-Portal`

### Added

- `Rename-Portal` renames a connection entry
- `Rename-PortalClient` renames a client entry

## [0.3.3]

### Fixed

- Bug in `Invoke-MyRMConnection`: null-valued client when the default client does not exist for a connection

## [0.3.2]

### Patch note

- Added more exception handlers

## [0.3.1]

### Patch note

- Code optimization
- Enhanced parameter validators
- Improved exception handlers

## [0.3.0]

### Added

- Scopes in which connections can be invoked
- `DefaultScope` parameter in `Add-MyRMClient` to define a default scope associated to the new client
- Default user for connections
- `DefaultUser` parameter in `Add-MyRMConnection` to define a default user associated to the new connection
- `DefaultClient` parameter in `Add-MyRMConnection` to define a default client associated to the new connection
- `Client` parameter (alias `c`) in `Invoke-MyRMConnection` to define a client to use to initiate the connection
- `User` parameter (alias `u`) in `Invoke-MyRMConnection` to define a user to connect with
- `Scope` parameter (alias `x`) in `Invoke-MyRMConnection` to define a scope in which the connection will be invoked
- Debug messages in `Invoke-MyRMConnection` Cmdlet
- Markdown help files in [docs/cmdlet-help](docs/cmdlet-help) generated with [platyPS module](https://github.com/PowerShell/platyPS)

### Changed

- Connections have a default client instead of a "fixed" client

### Removed

- `RunInCurrentScope` parameter (alias `X`) in `Invoke-MyRMConnection` to start the connection process in the current console

## [0.2.0]

### Added

- `Hostname` parameter in `Get-MyRMConnection` to filter connections by hostname
- `Get-MyRMInventoryInfo` shows whether the inventory file exists or not
- Check and warn if duplicates exist at inventory file access
- `Test-MyRMConnection` Cmdlet to test a connection defined in the inventory
- `RunInCurrentScope` parameter (alias `X`) in `Invoke-MyRMConnection` to start the connection process in the current console

### Changed

- The maximum length of the Client/Connection Name has been increased from 30 to 50
- Module is supported for PowerShell version 7 and later

### Fixed

- `Get-MyRMInventoryInfo` does not fail anymore if the inventory file does not exist

## [0.1.0]

### Added

- Initial release of the module
