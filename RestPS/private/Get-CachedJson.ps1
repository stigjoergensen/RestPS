function Get-CachedJson
{
    <#
	.DESCRIPTION
		This function loads the jsonfile if needed
    .PARAMETER FilePath
        Provide a valid path to a .json file
    .PARAMETER AlterJson
        Provides a function that can alter the read json file.
        The declaration of the function must be x($Obj, $FilePath)
           where $Obj will be the converted json file
             and $FilePath will be the filename of the json file that was read
    .OUTPUTS
        The JSON Object from the file or from cache, if file havnt been updated
    .EXAMPLE
        Get-CachedJson -FilePath $env:systemdrive/RestPS/endpoints/routes.json
	.NOTES
        create an object on the $script scope that will handle the cashe.
        This will return null.
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]

    param(
        [Parameter(Mandatory = $true)][String]$FilePath,
        $AlterJson = $null
    )

    if ($null -eq $script:JsonCache)
    {
        $script:JsonCache = @{}
    }

    if (Test-Path -Path $FilePath)
    {
        if ($script:JsonCache[$filepath])
        {
            $FileTime = (Get-ChildItem $FilePath).LastWriteTime
            if ($FileTime -gt $script:JsonCache[$filepath].Date)
            {
                $script:JsonCache[$filepath] = @{
                    Content = (get-content $FilePath -Raw) | ConvertFrom-Json
                    Date    = $FileTime
                }
                if ($AlterJson)
                {
                    & $AlterJson -obj $script:JsonCache[$filepath].Content -FilePath $FilePath
                }
            }
        }
        else
        {
            $script:JsonCache[$filepath] = @{
                Content = (get-content $FilePath -Raw) | ConvertFrom-Json
                Date    = (Get-ChildItem $FilePath).LastWriteTime
            }
            if ($AlterJson)
            {
                & $AlterJson -obj $script:JsonCache[$filepath].Content -FilePath $FilePath
            }
        }
        $script:JsonCache[$filepath].Content
    }
    else
    {
        Throw "Get-CachedJson - File not found: $FilePath"
    }
}