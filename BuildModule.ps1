<#
.Description
Build the PSM1 script (the module file that an/should be installed in to the ENV:PSModulePath)
Written by Stig.joergensen, inspired by module.build.ps1 script

#>


[cmdletbinding()]
param(
    [string]$CodeBase = "\RestPS\",
    [string]$OutputFilename = "RestPS.PSM1"
)
Write-Verbose "This psm1 is replaced in the build output. This file is only used for debugging."
Write-Verbose $PSScriptRoot

$PSM1File = ""
$Exports = ""

Write-Verbose 'Import everything in sub folders'
foreach ($folder in @('classes', 'private', 'public', 'includes', 'internal'))
{
    #$root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    $root = Join-Path -Path $PSScriptRoot -ChildPath $CodeBase | Join-Path -ChildPath $Folder
    #$root = [IO.Path]::Combine($PSScriptRoot,$CodeBase,$folder)

    Write-Verbose "processing folder $root"
    if (Test-Path -Path $root)
    {
        $files = Get-ChildItem -Path $root -Filter *.ps1 -Recurse

        # dot source each file
        $files | where-Object { $_.name -NotLike '*.Tests.ps1' } |
        ForEach-Object {
            Write-Verbose $_.basename; . $_.FullName
            $PSM1File += "`n`n## $($Folder)\$($_.Name)`n"
            $PSM1File += get-content "$($_.FullName)" -raw

            if ($folder -eq "public")
            {
                $Exports += "Export-ModuleMember -Function $($_.BaseName)`n"
            }
        }
    }
}

$PSM1File += "`n`n## Exports:`n$Exports"

write-host $PSM1File
set-content -path ".\$([System.IO.Path]::GetFileNameWithoutExtension($OutputFilename)).psm1" -value $PSM1File

