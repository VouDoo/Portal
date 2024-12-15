---
external help file: Portal-help.xml
Module Name: Portal
online version:
schema: 2.0.0
---

# Open-Portal

## SYNOPSIS
Opens Portal connection.

## SYNTAX

```
Open-Portal [-Name] <String> [-Client <String>] [-User <String>] [-Scope <Scopes>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Opens Portal connection which is defined in the inventory.

## EXAMPLES

### EXAMPLE 1
```
Open-Portal myconn
```

### EXAMPLE 2
```
Open-Portal -Name myconn -Client SSH -User root -Scope Console
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

### -Client
Name of the client to use to initiate the connection.

```yaml
Type: String
Parameter Sets: (All)
Aliases: c

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -User
Name of the user to connect with.

```yaml
Type: String
Parameter Sets: (All)
Aliases: u

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Scope in which the connection will be opened.

```yaml
Type: Scopes
Parameter Sets: (All)
Aliases: x
Accepted values: Undefined, Console, External

Required: False
Position: Named
Default value: None
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

### None. You cannot pipe objects to Open-Portal.
## OUTPUTS

### System.Void. None.
## NOTES

## RELATED LINKS
