@{
    PSDependOptions  = @{
        Target     = "CurrentUser"
        Repository = "PSGallery"
    }
    psake            = "latest"
    PSScriptAnalyzer = "latest"
    # SkipPublisherCheck: Windows ships an old Pester signed by Microsoft, which blocks updating it otherwise
    Pester           = @{
        Version    = "latest"
        Parameters = @{ SkipPublisherCheck = $true }
    }
    platyPS          = "latest"
}
