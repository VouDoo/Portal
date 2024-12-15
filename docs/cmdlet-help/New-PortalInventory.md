---
external help file: Portal-help.xml
Module Name: Portal
online version:
schema: 2.0.0
---

# New-PortalInventory

## SYNOPSIS
Creates Portal inventory file.

## SYNTAX

```
New-PortalInventory [-NoDefaultClients] [-Force] [-PassThru] [-ProgressAction <ActionPreference>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new inventory file where Portal saves items.

## EXAMPLES

### EXAMPLE 1
```
New-PortalInventory
```

### EXAMPLE 2
```
New-PortalInventory -NoDefaultClients
```

### EXAMPLE 3
```
New-PortalInventory -Force
```

### EXAMPLE 4
```
New-PortalInventory -PassThru
C:\Users\MyUsername\Portal.json
```

### EXAMPLE 5
```
New-PortalInventory -NoDefaultClients -Force -PassThru
C:\Users\MyUsername\Portal.json
```

## PARAMETERS

### -NoDefaultClients
Does not add defaults clients to the new inventory.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Overwrites existing inventory file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Indicates that the cmdlet sends items from the interactive window down the pipeline as input to other commands.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to New-PortalInventory.
## OUTPUTS

### System.Void. None.
###     or if PassThru is set,
### System.String. New-PortalInventory returns a string with the path to the created inventory.
## NOTES

## RELATED LINKS
