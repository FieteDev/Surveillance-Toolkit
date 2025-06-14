[CmdletBinding(PositionalBinding, SupportsShouldProcess)]
param(
    [Parameter(Position=0)]#, Mandatory)]
    [string]$LiteralPath = '/home/brar/dev/NeoIPC/Surveillance-Toolkit/metadata/testing',
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
            categoryCombos {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties skipTotal)
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
                        -IdProperties optionSet,categoryCombo)
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
                        -IdArrayProperties trackedEntityTypeAttributes `
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
            trackedEntityTypeAttributes {
                $ret[$objName] = @($objValues |
                    Convert-MetadataObjects `
                        -BoolProperties externalAccess,displayInList,mandatory,searchable,favorite `
                        -IdProperties trackedEntityAttribute,trackedEntityType)
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

function New-UidGenerator {
    $abc = 'abcdefghijklmnopqrstuvwxyz'
    $letters = $abc + $abc.ToUpperInvariant()
    $ALLOWED_CHARS = "0123456789$letters"
    $NUMBER_OF_CODEPOINTS = $ALLOWED_CHARS.Length
    $CODESIZE = 11
    $existingUids = [System.Collections.Generic.HashSet[string]]::new();

    {
        do {
            $randomChars = $script:letters[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($script:letters.Length)]
            for ($i = 1; $i -lt $script:CODESIZE; $i++) {
                $randomChars += $script:ALLOWED_CHARS[[System.Security.Cryptography.RandomNumberGenerator]::GetInt32($script:NUMBER_OF_CODEPOINTS)]
            }
        } until ($script:existingUids.Add($randomChars))

        $randomChars
    }.GetNewClosure()
}

function Test-Uid {
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $UID,
        [Parameter(Position = 1)]
        [switch]
        $Invert
    )
    if ($Invert) {
        $UID -cnotmatch '^[a-zA-Z]{1}[a-zA-Z0-9]{10}$'
    } else {
        $UID -cmatch '^[a-zA-Z]{1}[a-zA-Z0-9]{10}$'
    }
}

function Repair-Ids {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [object]
        $InputObject,
        [scriptblock]
        $Generator,
        [hashtable]
        $FixProperties,
        [hashtable]
        $FixIdProperties,
        [hashtable]
        $FixIdArrayProperties,
        [hashtable]
        $FixFullTypeArrayProperties
    )
    begin {
        $map = @{}
    }
    process {
        if ($null -ne $InputObject) {
            if ($Generator -and (Test-Uid $InputObject.id -Invert)) {
                $oldId = $InputObject.id
                $newId = Invoke-Command $Generator
                Write-Debug "Replacing invalid UID '$oldId' with newly generated value '$newId'"
                $map[$oldId] = $newId
                $InputObject.id = $newId
            }
            if ($null -ne $FixProperties) {
                $FixProperties.GetEnumerator() | ForEach-Object {
                    $key = $_.Key
                    $current = $InputObject[$key]
                    if ($current -and $_.Value.Contains($current)) {
                        $new = $_.Value[$current]
                        Write-Debug "Replacing invalid UID reference '$current' with new value '$new'"
                        $InputObject[$key] = $new
                    }
                }
            }
            if ($null -ne $FixIdProperties) {
                $FixIdProperties.GetEnumerator() | ForEach-Object {
                    $current = $InputObject[$_.Key]
                    $oldId = $current.id
                    if ($oldId -and $_.Value.Contains($oldId)) {
                        $newId = $_.Value[$oldId]
                        Write-Debug "Replacing invalid UID reference '$oldId' with new value '$newId'"
                        $current.Id = $newId
                    }
                }
            }
            if ($null -ne $FixIdArrayProperties) {
                $FixIdArrayProperties.GetEnumerator() | ForEach-Object {
                    $current = $InputObject[$_.Key]
                    $map = $_.Value
                    for ($i = 0; $i -lt $current.Count; $i++) {
                        $o = $current[$i]
                        $oldId = $o.id
                        if ($oldId -and $map.Contains($oldId)) {
                            $newId = $map[$oldId]
                            Write-Debug "Replacing invalid UID reference '$oldId' with new value '$newId'"
                            $o.id = $newId
                        }
                    }
                }
            }
            if ($null -ne $FixFullTypeArrayProperties) {
                $FixFullTypeArrayProperties.GetEnumerator() | ForEach-Object {
                    $current = $InputObject[$_.Key]
                    $map = $_.Value.Map
                    $fullObjects = $_.Value.Objects
                    for ($i = 0; $i -lt $current.Count; $i++) {
                        $o = $current[$i]
                        $oldId = $o.id
                        if ($oldId -and $map.Contains($oldId)) {
                            $newId = $map[$oldId]
                            Write-Debug "Replacing invalid UID reference '$oldId' with new value '$newId'"
                            $o.id = $newId
                        }
                        $current[$i] =  $fullObjects[$o.id]
                    }
                }
            }
        }
    }
    end {
        return $map
    }
}

function Repair-Metadata {
    param ([
        Parameter(Mandatory, Position = 0)]
        $metadata
    )

    $uidGenerator = New-UidGenerator

    $fixedOptionSetIds =  $metadata.optionSets |
        Repair-Ids -Generator $uidGenerator

    $fixedOptionIds =  $metadata.options |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{optionSet = $fixedOptionSetIds}

    $fixedOptionGroupIds = $metadata.optionGroups |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            optionSet = $fixedOptionSetIds
        } -FixIdArrayProperties @{
            options = $fixedOptionIds
        }

    $fixedOptionGroupSetIds = $metadata.optionGroupSets |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            optionSet = $fixedOptionSetIds
        } -FixIdArrayProperties @{
            optionGroups = $fixedOptionGroupIds
        }

    $fixedCategoryComboIds = $metadata.categoryCombos |
        Repair-Ids -Generator $uidGenerator

    $fixedDataElementIds = $metadata.dataElements |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            optionSet = $fixedOptionSetIds
            categoryCombo = $fixedCategoryComboIds
        }

    $fixedTrackedEntityAttributeIds = $metadata.trackedEntityAttributes |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            optionSet = $fixedOptionSetIds
            categoryCombo = $fixedCategoryComboIds
        }

    $trackedEntityAttributes = @{}
    $metadata.trackedEntityAttributes |
        ForEach-Object {
            $trackedEntityAttributes[$_.id] = $_
        }


    $fixedTrackedEntityTypeIds = $metadata.trackedEntityTypes |
        Repair-Ids -Generator $uidGenerator

    # trackedEntityTypeAttributes is a csv file to store the children inside trackedEntityTypes
    # we have to reintegrate it there instead of making it a separate metadata object
    $fixedTrackedEntityTypeAttributeIds = $metadata.trackedEntityTypeAttributes |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            trackedEntityAttribute = $fixedTrackedEntityAttributeIds
            trackedEntityType = $fixedTrackedEntityTypeIds
        }
    $trackedEntityTypeAttributes = @{}
    $metadata.trackedEntityTypeAttributes |
        ForEach-Object {
            $trackedEntityTypeAttributes[$_.id] = $_
        }
    $metadata.Remove('trackedEntityTypeAttributes')

    $metadata.trackedEntityTypes |
        Repair-Ids -Generator $uidGenerator -FixFullTypeArrayProperties @{
            trackedEntityTypeAttributes = @{
                Map = $fixedTrackedEntityTypeAttributeIds
                Objects = $trackedEntityTypeAttributes
            }} |
        Out-Null

    $fixedProgramIds = $metadata.programs |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            categoryCombo = $fixedCategoryComboIds
            trackedEntityType = $fixedTrackedEntityTypeIds
        }

    $fixedProgramTrackedEntityAttributeIds = $metadata.programTrackedEntityAttributes |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            program = $fixedProgramIds
            trackedEntityAttribute = $fixedTrackedEntityAttributeIds
        }

    # Bring the programTrackedEntityAttributes back as nested object inside programs
    # because otherwise the import won't recognize them
    foreach ($program in $metadata.programs) {
        $program.programTrackedEntityAttributes = @(
            $metadata.programTrackedEntityAttributes |
                Where-Object { $_.program.id -eq $program.id } |
                Sort-Object sortOrder)
    }

    $fixedProgramSectionIds = $metadata.programSections |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            program = $fixedProgramIds
        } -FixIdArrayProperties @{
            trackedEntityAttribute = $fixedTrackedEntityAttributeIds
        }

    $fixedUserGroupsIds = $metadata.userGroups |
        Repair-Ids -Generator $uidGenerator
    $metadata.userGroups |
        Repair-Ids -Generator $uidGenerator -FixIdArrayProperties @{
            managedGroups = $fixedUserGroupsIds
        } |
        Out-Null

    $fixedProgramNotificationTemplateIds = $metadata.programNotificationTemplates |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            recipientUserGroup = $fixedUserGroupsIds
        }

    $fixedProgramStageIds = $metadata.programStages |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            program = $fixedProgramIds
        } -FixIdArrayProperties @{
            notificationTemplates = $fixedProgramNotificationTemplateIds
        }

    # Bring the programStages back as nested object (ids only) inside programs
    # because otherwise the import won't recognize them
    foreach ($program in $metadata.programs) {
        $program.programStages = @(
            $metadata.programStages |
                Where-Object { $_.program.id -eq $program.id } |
                Sort-Object sortOrder |
                Select-Object @{l='id';e={$_.id}})
    }

    $fixedProgramStageDataElementIds = $metadata.programStageDataElements |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            programStage = $fixedProgramStageIds
            dataElement = $fixedDataElementIds
        }

    # Bring the programStageDataElements and programStageSections back as nested object inside
    # programStages because otherwise the import won't recognize them
    foreach ($programStage in $metadata.programStages) {
        $programStage.programStageDataElements = @(
            $metadata.programStageDataElements |
                Where-Object { $_.programStage.id -eq $programStage.id } |
                Sort-Object sortOrder)
        $programStage.programStageSections = @(
            $metadata.programStageSections |
                Where-Object { $_.programStage.id -eq $programStage.id } |
                Sort-Object sortOrder |
                Select-Object @{l='id';e={$_.id}})
    }

    $fixedProgramStageSectionIds = $metadata.programStageSections |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            programStage = $fixedProgramStageIds
        } -FixIdArrayProperties @{
            dataElements = $fixedDataElementIds
        }

    $fixedProgramRuleVariableIds = $metadata.programRuleVariables |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            program = $fixedProgramIds
            programStage = $fixedProgramStageIds
            dataElement = $fixedDataElementIds
            trackedEntityAttribute = $fixedTrackedEntityAttributeIds
        }

    $fixedProgramRuleIds = $metadata.programRules |
        Repair-Ids -Generator $uidGenerator -FixIdProperties @{
            program = $fixedProgramIds
            programStage = $fixedProgramStageIds
        }

    $fixedProgramRuleActionIds = $metadata.programRuleActions |
        Repair-Ids -Generator $uidGenerator -FixProperties @{
            templateUid = $fixedProgramNotificationTemplateIds
        } -FixIdProperties @{
            programRule = $fixedProgramRuleIds
            programStageSection = $fixedProgramStageSectionIds
            dataElement = $fixedDataElementIds
            trackedEntityAttribute = $fixedTrackedEntityAttributeIds
        }

    # Bring the programRuleActions back as nested object (ids only) inside programRules
    # because otherwise the import won't recognize them
    foreach ($programRule in $metadata.programRules) {
        $programRule.programRuleActions = @(
            $metadata.programRuleActions |
                Where-Object { $_.programRule.id -eq $programRule.id } |
                Select-Object @{l='id';e={$_.id}})
    }
}

$inDir = Resolve-Path -LiteralPath $LiteralPath -Relative
$inputData = Get-ChildItem -LiteralPath $inDir -File -Filter '*.csv' |
    Import-MetadataCsv

Repair-Metadata $inputData

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
