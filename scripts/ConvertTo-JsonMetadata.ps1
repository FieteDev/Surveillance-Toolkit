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
                            $outObj[$name] = [bool]::Parse($value)
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
        dataElements {
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
                        zeroIsSignificant {
                            $outObj[$name] = [bool]::Parse($value)
                            break
                        }
                        {$_ -in 'optionSet','categoryCombo'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
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
        indicatorTypes {
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
                        factor {
                            $outObj[$name] = [int]$value
                            break
                        }
                        number {
                            $outObj[$name] = [bool]::Parse($value)
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
        optionGroups {
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
                        options {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        optionSet {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
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
        optionGroupSets {
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
                        optionGroups {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        optionSet {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        dataDimension {
                            $outObj[$name] = [bool]::Parse($value)
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
        options {
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
                        optionSet {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        sortOrder {
                            $outObj[$name] = [int]$value
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
        optionSets {
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
                    $outObj[$name] = $value
                }
                $final.Add($outObj) | Out-Null
            }
        }
        organisationUnitGroups {
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
                    $outObj[$name] = $value
                }
                $final.Add($outObj) | Out-Null
            }
        }
        organisationUnitGroupSets {
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
                        organisationUnitGroups {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        {$_ -in 'dataDimension','compulsory','includeSubhierarchyInAnalytics'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        programIndicators {
            # Skip for now
            $final = $null
        }
        programNotificationTemplates {
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
                        recipientUserGroup {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        {$_ -in 'notifyUsersInHierarchyOnly','sendRepeatable'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        programRuleActions {
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
                        {$_ -in 'programRule','dataElement','trackedEntityAttribute','programStageSection'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
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
        programRules {
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
                        {$_ -in 'program','programStage'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        priority {
                            $outObj[$name] = [int]$value
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
        programRuleVariables {
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
                        {$_ -in 'program','dataElement','programStage','trackedEntityAttribute'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        useCodeForOptionSet {
                            $outObj[$name] = [bool]::Parse($value)
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
        programs {
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
                        {$_ -in 'trackedEntityType','categoryCombo'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        {$_ -in 'expiryDays','completeEventsExpiryDays','openDaysAfterCoEndDate','minAttributesRequiredToSearch','maxTeiCountToReturn'} {
                            $outObj[$name] = [int]$value
                            break
                        }
                        {$_ -in 'displayIncidentDate','ignoreOverdueEvents','onlyEnrollOnce','selectEnrollmentDatesInFuture','selectIncidentDatesInFuture','skipOffline','displayFrontPageList','useFirstStageDuringRegistration'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        programSections {
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
                        program {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        renderType_MOBILE {
                            if ($outObj.Contains('renderType')) {
                                $outObj['renderType'].Add('MOBILE', [PSCustomObject]@{type = $value})
                            } else {
                                $outObj['renderType'] = [ordered]@{MOBILE = [PSCustomObject]@{type = $value}}
                            }
                            break
                        }
                        renderType_DESKTOP {
                            if ($outObj.Contains('renderType')) {
                                $outObj['renderType'].Add('DESKTOP', [PSCustomObject]@{type = $value})
                            } else {
                                $outObj['renderType'] = [ordered]@{DESKTOP = [PSCustomObject]@{type = $value}}
                            }
                            break
                        }
                        trackedEntityAttributes {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        sortOrder {
                            $outObj[$name] = [int]$value
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
        programStageDataElements {
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
                        {$_ -in 'compulsory','allowProvidedElsewhere','displayInReports','allowFutureDate','renderOptionsAsRadio','skipSynchronization','skipAnalytics'} {
                            $outObj[$name] = [bool]::Parse($value)
                            break
                        }
                        {$_ -in 'programStage','dataElement'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        sortOrder {
                            $outObj[$name] = [int]$value
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
        programStages {
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
                        program {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        notificationTemplates {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        {$_ -in 'sortOrder','minDaysFromStart'} {
                            $outObj[$name] = [int]$value
                            break
                        }
                        {$_ -in 'repeatable','autoGenerateEvent','displayGenerateEventBox','blockEntryForm','preGenerateUID','remindCompleted','generatedByEnrollmentDate','allowGenerateNextVisit','openAfterEnrollment','hideDueDate','enableUserAssignment','referral'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        programStageSections {
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
                        programStage {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        dataElements {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        sortOrder {
                            $outObj[$name] = [int]$value
                            break
                        }
                        renderType_MOBILE {
                            if ($outObj.Contains('renderType')) {
                                $outObj['renderType'].Add('MOBILE', [PSCustomObject]@{type = $value})
                            } else {
                                $outObj['renderType'] = [ordered]@{MOBILE = [PSCustomObject]@{type = $value}}
                            }
                            break
                        }
                        renderType_DESKTOP {
                            if ($outObj.Contains('renderType')) {
                                $outObj['renderType'].Add('DESKTOP', [PSCustomObject]@{type = $value})
                            } else {
                                $outObj['renderType'] = [ordered]@{DESKTOP = [PSCustomObject]@{type = $value}}
                            }
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
        programTrackedEntityAttributes {
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
                        sortOrder {
                            $outObj[$name] = [int]$value
                            break
                        }
                        {$_ -in 'program','trackedEntityAttribute'} {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        {$_ -in 'mandatory','displayInList','searchable','renderOptionsAsRadio'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        trackedEntityAttributes {
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
                        optionSet {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        {$_ -in 'unique','generated','confidential','inherit','skipSynchronization','displayOnVisitSchedule','displayInListNoProgram','orgunitScope'} {
                            $outObj[$name] = [bool]::Parse($value)
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
        trackedEntityTypes {
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
                        trackedEntityTypeAttributes {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[PSCustomObject]@{id = $_}}
                            break
                        }
                        allowAuditLog {
                            $outObj[$name] = [bool]::Parse($value)
                            break
                        }
                        icon {
                            if ($outObj.Contains('style')) {
                                $outObj['style'].Add('icon', $value)
                            } else {
                                $outObj['style'] = [ordered]@{icon = $value}
                            }
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
        userGroups {
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
                        managedGroups {
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
        userRoles {
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
                        authorities {
                            $outObj[$name] = $value.Split(' ')
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
        validationRules {
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
                        programStage {
                            $outObj[$name] = [PSCustomObject]@{id = $value}
                            break
                        }
                        organisationUnitLevels {
                            $outObj[$name] = $value.Split(' ') |
                                ForEach-Object  {[int]$_}
                            break
                        }
                        leftSide_slidingWindow {
                            if ($outObj.Contains('leftSide')) {
                                $outObj['leftSide'].Add('slidingWindow', [bool]$value)
                            } else {
                                $outObj['leftSide'] = [ordered]@{slidingWindow = [bool]$value}
                            }
                            break
                        }
                        rightSide_slidingWindow {
                            if ($outObj.Contains('rightSide')) {
                                $outObj['rightSide'].Add('slidingWindow', [bool]$value)
                            } else {
                                $outObj['rightSide'] = [ordered]@{slidingWindow = [bool]$value}
                            }
                            break
                        }
                        leftSide_missingValueStrategy {
                            if ($outObj.Contains('leftSide')) {
                                $outObj['leftSide'].Add('missingValueStrategy', $value)
                            } else {
                                $outObj['leftSide'] = [ordered]@{missingValueStrategy = $value}
                            }
                            break
                        }
                        rightSide_missingValueStrategy {
                            if ($outObj.Contains('rightSide')) {
                                $outObj['rightSide'].Add('missingValueStrategy', $value)
                            } else {
                                $outObj['rightSide'] = [ordered]@{missingValueStrategy = $value}
                            }
                            break
                        }
                        leftSide_expression {
                            if ($outObj.Contains('leftSide')) {
                                $outObj['leftSide'].Add('expression', $value)
                            } else {
                                $outObj['leftSide'] = [ordered]@{expression = $value}
                            }
                            break
                        }
                        rightSide_expression {
                            if ($outObj.Contains('rightSide')) {
                                $outObj['rightSide'].Add('expression', $value)
                            } else {
                                $outObj['rightSide'] = [ordered]@{expression = $value}
                            }
                            break
                        }
                        skipFormValidation {
                            $outObj[$name] = [bool]::Parse($value)
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
            throw "Unhandled object type: $objName"
        }
    }
    if ($final -ne $null) {
        $metadata[$objName] = @($final)
    }
}

$metadata |
    ConvertTo-Json -Depth 100 -Compress:$Compress |
    Set-Content -LiteralPath $OutputFile
