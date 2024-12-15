---
external help file: Portal-help.xml
Module Name: Portal
online version:
schema: 2.0.0
---

# Test-Portal

## SYNOPSIS
Tests Portal connection.

## SYNTAX

```
Test-Portal [-Name] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Tests Portal connection which is defined in the inventory.

## EXAMPLES

### EXAMPLE 1
```
Test-Portal myconn
(status)
```

### EXAMPLE 2
```
Test-Portal -Name myconn
(status)
```

## PARAMETERS

### -Name
Name of the connection.

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

### None. You cannot pipe objects to Test-Portal.
## OUTPUTS

### System.String. Test-Portal returns a string with the status of the remote host.
## NOTES

## RELATED LINKS
