<#
    .DESCRIPTION
	This script will return all IP Authentication available.
    .EXAMPLE
        Invoke-GetIPAuth.ps1
    .NOTES
        This will return a json object
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", '')]
param(
    $RequestArgs,
    $body
)

. $RestPSLocalRoot\bin\Get-RestIPAuth.ps1
return (get-RestIPAuth | ConvertTo-Json) | ConvertFrom-Json

