<#
    .DESCRIPTION
	This script will return all IP Access Control List available.
    .EXAMPLE
        Invoke-GetIPACL.ps1
    .NOTES
        This will return a json object
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
param(
    $RequestArgs,
    $body
)

$path = Split-Path -Parent $PSScriptRoot 
$file = Get-Content -path ([IO.Path]::Combine($path, "ipACL.json")) -raw

return ($file | ConvertFrom-Json)

