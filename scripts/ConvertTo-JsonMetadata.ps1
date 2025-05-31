[CmdletBinding(PositionalBinding, SupportsShouldProcess)]
param(
    [Parameter(Position=0)]#, Mandatory)]
    [string]$LiteralPath = '/home/brar/dev/NeoIPC/Surveillance-Toolkit/metadata/20250531T0640332698Z',
    [Parameter(Position=1)]
    [string]$OutputFile = (
        Join-Path -Path (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'metadata'
                ) -Relative
            ) -ChildPath "metadata_$(
                Get-Date -Format FileDateTimeUniversal
            ).json"
        ),
    [switch]$Compress
)

if ($VerbosePreference -ne 'SilentlyContinue') {
    $InformationPreference = $VerbosePreference
}

$inDir = Resolve-Path -LiteralPath $LiteralPath -Relative
$inFiles = Get-ChildItem -LiteralPath $inDir -File -Filter '*.csv' |
    Sort-Object -Property BaseName
$metadata = [ordered]@{}

foreach ($file in $inFiles) {
    $objName = $file.BaseName
    $objList = $file | Import-Csv
    $final = [System.Collections.ArrayList]::new()

    switch -Exact -CaseSensitive ($objName) {
        attributes {
            $objList |
            ForEach-Object {
                $inObj = $_
                $outObj = [ordered]@{}
                $inObj.psobject.properties | ForEach-Object {
                    $name = $_.Name
                    $value = $_.Value
                    if($value -eq '') {
                        return
                    }
                    switch -Exact -CaseSensitive ($name) {
                        objectTypes {
                            $outObj[$name] = $value.Split(' ')
                            break
                        }
                        {$_ -in 'id','code','name','shortName','description','valueType'}{
                            $outObj[$name] = $value
                            break
                        }
                        Default {
                            $outObj[$name] = [bool]$value
                            break
                        }
                    }
                }
                $final.Add($outObj) | Out-Null
            }
        }
        dataElementGroups {
            $objList |
            ForEach-Object {
                $inObj = $_
                $outObj = [ordered]@{}
                $inObj.psobject.properties | ForEach-Object {
                    $name = $_.Name
                    $value = $_.Value
                    if($value -eq '') {
                        return
                    }
                    switch -Exact -CaseSensitive ($name) {
                        dataElements {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        Default {
                            $outObj[$name] = $value
                            break
                        }
                    }
                }
                $final.Add($outObj) | Out-Null
            }
        }
        Default {
            #$final = $objList
            throw "Unhandled object type: $objName"
        }
    }
    $metadata[$objName] = $final
}

$metadata |
    ConvertTo-Json -Depth 100 -Compress:$Compress |
    Set-Content -LiteralPath $OutputFile
