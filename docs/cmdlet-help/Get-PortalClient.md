---
external help file: Portal-help.xml
Module Name: Portal
online version:
schema: 2.0.0
---

# Get-PortalClient

## SYNOPSIS
Gets Portal clients.

## SYNTAX

```
Get-PortalClient [[-Name] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Gets available clients from the Portal inventory file.
Clients can be filtered by their name.

## EXAMPLES

### EXAMPLE 1
```
Get-PortalClient
(objects)
```

### EXAMPLE 2
```
Get-PortalClient -Name "custom_*"
(filtered objects)
```

## PARAMETERS

### -Name
Filters clients by name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
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

### None. You cannot pipe objects to Get-PortalClient.
## OUTPUTS

### PSCustomObject. Get-PortalClient returns objects with details of the available clients.
## NOTES

## RELATED LINKS
