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
    [switch]$Compress,
    [switch]$SortObjects
)

if ($VerbosePreference -ne 'SilentlyContinue') {
    $InformationPreference = $VerbosePreference
}

$renderTypeConverter = {
    param ($outObj,$inputName,$outputName)
    $parts = $inputName.Split('_')
    if ($parts.Length -ne 2 -or $parts[0] -ne $outputName) {
        throw "Failed to convert renderType. Invalid input name: '$inputName' (output name is: '$outputName')."
    }
    $subType = $parts[1]
    $value = [string]$input
    if ($outObj.Contains($outputName)) {
        $outObj[$outputName].Add($subType, [PSCustomObject]@{type = $value})
    } else {
        $outObj[$outputName] = [ordered]@{"$subType" = [PSCustomObject]@{type = $value}}
    }
}

$expressionConverter = {
    param ($outObj,$inputName,$outputName)
    $parts = $inputName.Split('_')
    if ($parts.Length -ne 2 -or $parts[0] -ne $outputName) {
        throw "Failed to convert validation rule expression. Invalid input name: '$inputName' (output name is: '$outputName')."
    }
    $subType = $parts[1]
    if ($subType -eq 'slidingWindow') {
        $value = [bool]$input
    } else {
        $value = [string]$input
    }
    if ($outObj.Contains($outputName)) {
        $outObj[$outputName].Add($subType, $value)
    } else {
        $outObj[$outputName] = [ordered]@{"$subType" = $value}
    }
}

function Convert-MetadataObjects {
    param(
        [string[]]$BoolProperties,
        [string[]]$IntProperties,
        [string[]]$StringProperties,
        [string[]]$IdProperties,
        [string[]]$IntArrayProperties,
        [string[]]$StringArrayProperties,
        [string[]]$IdArrayProperties,
        [hashtable[]]$OtherProperties,
        [object]$DefaultConversion
    )
    process {
        $inObj = $_
        $outObj = [ordered]@{}
        $inObj.psobject.properties |
            ForEach-Object {
                $name = $_.Name
                $value = $_.Value
                if($value -eq '') {
                    return
                }
                switch -Exact -CaseSensitive ($name) {
                    {$name -in $BoolProperties} {
                        $outObj[$name] = [bool]::Parse($value)
                        return
                    }
                    {$name -in $IntProperties} {
                        $outObj[$name] = [int]$value
                        return
                    }
                    {$name -in $StringProperties} {
                        $outObj[$name] = $value
                        return
                    }
                    {$name -in $IdProperties} {
                        $outObj[$name] = [PSCustomObject]@{id = $value}
                        return
                    }
                    {$name -in $IntArrayProperties} {
                        $outObj[$name] = @($value.Split(' ') |
                            ForEach-Object {[int]$_})
                        return
                    }
                    {$name -in $StringArrayProperties} {
                        $outObj[$name] = @($value.Split(' '))
                        return
                    }
                    {$name -in $IdArrayProperties} {
                        $outObj[$name] = @($value.Split(' ') |
                            ForEach-Object {[PSCustomObject]@{id = $_}})
                        return
                    }
                    Default {
                        foreach ($otherProp in $OtherProperties) {
                            if ($name -eq $otherProp['l']) {
                                $value | Invoke-Command $otherProp['e'] -ArgumentList $outObj,$name,$otherProp['n'] | Out-Null
                                return
                            }
                        }
                        switch -Exact -CaseSensitive ($DefaultConversion) {
                            {$null -ne $_ -and $_.GetType() -eq [scriptblock]} {
                                $value | Invoke-Command $DefaultConversion -ArgumentList $outObj,$name | Out-Null
                                return
                            }
                            bool {
                                $outObj[$name] = [bool]::Parse($value)
                                return
                            }
                            int {
                                $outObj[$name] = [int]$value
                                return
                            }
                            Default {
                                $outObj[$name] = $value
                                return
                            }
                        }
                    }
                }
        }
        Write-Output $outObj
    }
}

function Import-MetadataCsv {
    begin {
        $ret = @{}
    }
    process {
        $objName = $_.BaseName
        $objValues = $_ | Import-Csv
        switch -Exact -CaseSensitive ($objName) {
            attributes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -StringProperties id,code,name,shortName,description,valueType `
                        -StringArrayProperties objectTypes `
                        -DefaultConversion bool)
                break
            }
            dataElementGroups {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects -IdArrayProperties dataElements)
                break
            }
            dataElements {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties zeroIsSignificant `
                        -IdArrayProperties optionSet,categoryCombo)
                break
            }
            indicatorTypes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties number `
                        -IntProperties factor)
                break
            }
            optionGroups {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IdProperties optionSet `
                        -IdArrayProperties options)
                break
            }
            optionGroupSets {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties dataDimension `
                        -IdProperties optionSet `
                        -IdArrayProperties optionGroups)
                break
            }
            options {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IntProperties sortOrder `
                        -IdProperties optionSet)
                break
            }
            optionSets {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects)
                break
            }
            organisationUnitGroups {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects)
                break
            }
            organisationUnitGroupSets {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties dataDimension,compulsory,includeSubhierarchyInAnalytics `
                        -IdArrayProperties organisationUnitGroups)
                break
            }
            programIndicators {
                # Skip for now
                break
            }
            programNotificationTemplates {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties notifyUsersInHierarchyOnly,sendRepeatable `
                        -IdProperties recipientUserGroup)
                break
            }
            programRuleActions {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IdProperties programRule,dataElement,trackedEntityAttribute,programStageSection)
                break
            }
            programRules {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IntProperties priority `
                        -IdProperties program,programStage)
                break
            }
            programRuleVariables {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties useCodeForOptionSet `
                        -IdProperties program,dataElement,programStage,trackedEntityAttribute)
                break
            }
            programs {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IntProperties expiryDays,completeEventsExpiryDays,openDaysAfterCoEndDate,minAttributesRequiredToSearch,maxTeiCountToReturn `
                        -BoolProperties displayIncidentDate,ignoreOverdueEvents,onlyEnrollOnce,selectEnrollmentDatesInFuture,selectIncidentDatesInFuture,skipOffline,displayFrontPageList,useFirstStageDuringRegistration `
                        -IdProperties trackedEntityType,categoryCombo)
                break
            }
            programSections {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IntProperties sortOrder `
                        -IdArrayProperties trackedEntityAttributes `
                        -IdProperties program `
                        -OtherProperties `
                        @{
                            l = 'renderType_MOBILE'
                            e = $renderTypeConverter
                            n = 'renderType'
                        },`
                        @{
                            l = 'renderType_DESKTOP'
                            e = $renderTypeConverter
                            n = 'renderType'
                        })
                break
            }
            programStageDataElements {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties compulsory,allowProvidedElsewhere,displayInReports,allowFutureDate,renderOptionsAsRadio,skipSynchronization,skipAnalytics `
                        -IntProperties sortOrder `
                        -IdProperties programStage,dataElement)
                break
            }
            programStages {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties repeatable,autoGenerateEvent,displayGenerateEventBox,blockEntryForm,preGenerateUID,remindCompleted,generatedByEnrollmentDate,allowGenerateNextVisit,openAfterEnrollment,hideDueDate,enableUserAssignment,referral `
                        -IntProperties sortOrder,minDaysFromStart `
                        -IdProperties program `
                        -IdArrayProperties notificationTemplates)
                break
            }
            programStageSections {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IntProperties sortOrder `
                        -IdProperties programStage `
                        -IdArrayProperties dataElements `
                        -OtherProperties `
                        @{
                            l = 'renderType_MOBILE'
                            e = $renderTypeConverter
                            n = 'renderType'
                        },`
                        @{
                            l = 'renderType_DESKTOP'
                            e = $renderTypeConverter
                            n = 'renderType'
                        })
                break
            }
            programTrackedEntityAttributes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties mandatory,displayInList,searchable,renderOptionsAsRadio `
                        -IntProperties sortOrder `
                        -IdProperties program,trackedEntityAttribute)
                break
            }
            trackedEntityAttributes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties unique,generated,confidential,inherit,skipSynchronization,displayOnVisitSchedule,displayInListNoProgram,orgunitScope `
                        -IdProperties optionSet)
                break
            }
            trackedEntityTypes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties allowAuditLog `
                        -IdArrayProperties trackedEntityTypeAttributes`
                        -OtherProperties `
                        @{
                            l = 'icon'
                            e = {
                                param ($outObj,$inputName,$outputName)
                                if ($outObj.Contains($outputName)) {
                                    $outObj[$outputName].Add($inputName, $value)
                                } else {
                                    $outObj[$outputName] = [ordered]@{"$inputName" = $value}
                                }
                            }
                            n = 'style'
                        })
                break
            }
            userGroups {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IdArrayProperties managedGroups)
                break
            }
            userRoles {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -StringArrayProperties authorities)
                break
            }
            validationRules {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -IdProperties programStage `
                        -IntArrayProperties organisationUnitLevels `
                        -BoolProperties skipFormValidation `
                        -OtherProperties `
                        @{
                            l = 'leftSide_slidingWindow'
                            e = $expressionConverter
                            n = 'leftSide'
                        },`
                        @{
                            l = 'leftSide_missingValueStrategy'
                            e = $expressionConverter
                            n = 'leftSide'
                        },`
                        @{
                            l = 'leftSide_expression'
                            e = $expressionConverter
                            n = 'leftSide'
                        },`
                        @{
                            l = 'rightSide_slidingWindow'
                            e = $expressionConverter
                            n = 'rightSide'
                        },`
                        @{
                            l = 'rightSide_missingValueStrategy'
                            e = $expressionConverter
                            n = 'rightSide'
                        },`
                        @{
                            l = 'rightSide_expression'
                            e = $expressionConverter
                            n = 'rightSide'
                        })
                break
            }
            Default {
                throw "Unhandled object type: $objName"
            }
        }
    }
    end {
        return $ret
    }
}

$inDir = Resolve-Path -LiteralPath $LiteralPath -Relative
$inputData = Get-ChildItem -LiteralPath $inDir -File -Filter '*.csv' |
    Import-MetadataCsv

if ($SortObjects) {
    $metadata = [ordered]@{}
    $keys = $inputData.Keys | Sort-Object
} else {
    $metadata = @{}
    $keys = $inputData.Keys
}

foreach ($key in $keys) {
    $objName = $key
    $objList = $inputData[$key]
    $metadata[$objName] = @($objList)
}

$metadata |
    ConvertTo-Json -Depth 100 -Compress:$Compress |
    Set-Content -LiteralPath $OutputFile
