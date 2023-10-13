function Import-RouteSet
{
    <#
	.DESCRIPTION
		This function imports the specified routes file.
    .PARAMETER RoutesFilePath
        Provide a valid path to a .json file
    .EXAMPLE
        Invoke-AvailableRouteSet -RoutesFilePath $env:systemdrive/RestPS/endpoints/routes.json
	.NOTES
        This will return null.
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]

    param(
        [Parameter(Mandatory = $true)][String]$RoutesFilePath
    )

    function AlterJson($Obj, $Filepath)
    {
        Foreach ($route in $obj)
        {
            $route.RequestCommand = [string]($route.RequestCommand) -replace [regex]::escape("`$home"), "$(Split-Path -parent $FilePath)"
        }
    }

    if (Test-Path -Path $RoutesFilePath)
    {
        #$script:Routes = Get-Content -Raw $RoutesFilePath | ConvertFrom-Json
        $script:Routes = get-CachedJson -FilePath $RoutesFilePath -AlterJson AlterJson
    }
    else
    {
        Throw "Import-RouteSet - Could not validate Path $RoutesFilePath"
    }
}