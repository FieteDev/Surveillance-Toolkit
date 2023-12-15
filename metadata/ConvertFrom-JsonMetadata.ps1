[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$LiteralPath = (Join-Path $PSScriptRoot -ChildPath 'metadata.json')
)

$json = Get-Content -Raw -Path $LiteralPath
$object = ConvertFrom-Json $json -AsHashtable

$optionSetDict = @{} 
foreach ($o in $object.optionSets) {
    $optionSetDict[$o.id] = $o.code
}

foreach ($item in $object.keys) {
    $currentValue = $object[$item]
    $outpath = Join-Path $PSScriptRoot -ChildPath "$item.csv"
    
    $excludedProps = @()
    
    switch ($item) {
        'options' {
            foreach ($o in $currentValue) {
                $o['optionSetCode'] = $optionSetDict[$o.optionSet.id] 
            }

            $excludedProps = @('attributeValues','created','id','lastUpdated','optionSet','translations')
        }
        'optionSets' {}
        'dataElements' {}
    }

    $currentValue | Select-Object -ExcludeProperty $excludedProps | Export-Csv -Path $outpath -NoTypeInformation -UseCulture
    
}