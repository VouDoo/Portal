# Module - Versioning

## Versioning

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Version must respect the format `<major>.<minor>.<patch>`.
In the examples, this is represented by `M.m.p`.

## How to bump the module version

To bump the version number of the module,
edit `ModuleVersion` in the module manifest `Source\Portal.psd1`:

```powershell
@{
    # ...
    ModuleVersion = 'M.m.p'
    # ...
}
```

The build (`build.settings.ps1`) reads the version from this file.
