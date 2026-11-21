class ClientNameCompleter : IArgumentCompleter {
    # Completes client names from the inventory (TAB key).
    # Validation is done by ValidateClientName, so this only runs on completion.
    [System.Collections.Generic.IEnumerable[CompletionResult]] CompleteArgument(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
    ) {
        $Results = [System.Collections.Generic.List[CompletionResult]]::new()
        try {
            $Inventory = Import-Inventory
        }
        catch {
            # No completion if the inventory cannot be read
            return $Results
        }
        foreach ($Item in $Inventory.Clients | Sort-Object -Property Name) {
            if ($Item.Name -like ("{0}*" -f $WordToComplete)) {
                $Results.Add([CompletionResult]::new($Item.Name, $Item.Name, "ParameterValue", $Item.ToString()))
            }
        }
        return $Results
    }
}
