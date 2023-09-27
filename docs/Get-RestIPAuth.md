---
external help file: RestPS-help.xml
Module Name: RestPS
online version:
schema: 2.0.0
---

# Get-RestIPAuth

## SYNOPSIS

## SYNTAX

```
Get-RestIPAuth
```

## DESCRIPTION
The function will return a nested set of Objects describing what url a given IP address can access

## EXAMPLES

### EXAMPLE 1

## PARAMETERS
this function does not require or take any parameters.

### CommonParameters

## INPUTS

## OUTPUTS

### PSObject
The function returns a Object simelar to this structure
```
{
	"ACL": {
	  	"/comment":"All URLs should start with / and be written in lowercase",
		"127.0.0.1": {
		  	"/comment":"Localhost should have access to everything",
			"Name":": "Local Host",
			"Path": ["/"]
		},
		"192.168.22.18": {
		  	"/comment":"This IP can access these two URLS",
			"Name":": "Workstation 1",
			"Path": ["/endpoint/shutdown", "/endpoint/status"]
		},
		"192.168.22.5": {
		  	"/comment":"This ip can access any urls starting with /a or /b, eg. /Alpha, /Access or /Bravo would be valid",
			"Name":": "Workstation 1",
			"Path": ["/a", "/b"]
		},
		"192.168.22.5,192.168.22.18": {
		  	"/comment":"These two IP address can access URLS starting with /c or /d",
			"Name":": "Workstation 1 and 2",
			"Path": ["/c", "/d"]
		},
		"192.168.1.0/24": {
		  	"/comment":"This IP subnet have access to everything",
			"Name":": "Subnet 1",
			"Path": ["/"]
		}
	},
	"EnableSubnetSearch": 0,
	"/comment-EnableSubnetSearch":"Enable subnet seach, this will take a performance hit, how big depends on the number of subnets in the ACL list.",
	"EnableIPList": 0,
  	"/comment-EnableIPList":"Enable of comma list of ACL IPS, Cost a little performance. Consider this instead of subnets"
}
```

## NOTES
The above PSObject is represented as a JSON structure with comments, this is not exactly how the object is defined inside the function, but made to give you an idea on how the function works.

## RELATED LINKS
