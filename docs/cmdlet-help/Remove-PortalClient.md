---
external help file: Portal-help.xml
Module Name: Portal
online version:
schema: 2.0.0
---

# Remove-PortalClient

## SYNOPSIS
Removes Portal client.

## SYNTAX

```
Remove-PortalClient [-Name] <String> [-Force] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Removes client entry from the Portal inventory file.

## EXAMPLES

### EXAMPLE 1
```
Remove-PortalClient SSH
```

### EXAMPLE 2
```
Remove-PortalClient -Name SSH
```

### EXAMPLE 3
```
Remove-PortalClient -Name SSH -Force
```

## PARAMETERS

### -Name
Name of the client.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Removes the client even if it is the default client of some connections.
These connections must then be opened with another client (Open-Portal -Client).

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

### None. You cannot pipe objects to Remove-PortalClient.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS
