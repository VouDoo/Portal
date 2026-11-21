class Item {
    # Name
    [ValidateLength(1, 50)]
    [ValidatePattern("^([a-zA-Z0-9_\-]+)$")]
    [string] $Name
    # Description
    [string] $Description

    [System.Collections.Specialized.OrderedDictionary] Splat() {
        # Properties in declaration order (keeps the inventory file readable)
        $Dictionary = [ordered] @{}
        foreach ($p in $this.PSObject.Properties) {
            $Dictionary[$p.Name] = $p.Value
        }
        return $Dictionary
    }
}
