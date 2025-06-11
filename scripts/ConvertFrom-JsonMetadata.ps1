[CmdletBinding(PositionalBinding, SupportsShouldProcess)]
param(
    [Parameter(Position=0)]#, Mandatory)]
    [string]$LiteralPath = '/home/brar/Downloads/metadata.json',
    [Parameter(Position=1)]
    [string]$OutputDirectory = (
        Join-Path -Path (
            Resolve-Path -LiteralPath (
                Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'metadata'
                ) -Relative
            ) -ChildPath (
                Get-Date -Format FileDateTimeUniversal
            )
        )
)

$resolvedPath = Resolve-Path -LiteralPath $LiteralPath -Relative

if ($VerbosePreference -ne 'SilentlyContinue') {
    $InformationPreference = $VerbosePreference
}

function Export-ConditionalCsv {
    param (
        [Parameter(Position=0,Mandatory,ValueFromPipeline)]
        $InputObject,
        [Parameter(Position=1,Mandatory)]
        [string]$ObjectName
        )
    process {
        if (-not $stream) {
            if ($_) {
                $outFile = Join-Path -Path $OutputDirectory -ChildPath "$ObjectName.csv"
                Write-Verbose "Creating file '$outFile'"
                $stream = [System.IO.StreamWriter]::new($outFile)
                $_ | ConvertTo-Csv -UseQuotes AsNeeded | ForEach-Object { $stream.WriteLine($_)}
            } else {
                Write-Verbose "Skipping empty $ObjectName object"
            }
        } else {
            $stream.WriteLine(($_ | ConvertTo-Csv -NoHeader -UseQuotes AsNeeded))
        }
    }
    clean {
        if ($stream) {
            $stream.Close()
        }
    }
}

Write-Information "Converting JSON metadata from $resolvedPath to CSV in directory $OutputDirectory"
$metadata = Get-Content -Raw -Path $resolvedPath | ConvertFrom-Json -AsHashtable -DateKind Utc -NoEnumerate

Write-Verbose "Creating directory '$OutputDirectory'"
New-Item -ItemType Directory -Path $OutputDirectory > $null

if ($metadata.system)
{
    $outFile = Join-Path -Path $OutputDirectory -ChildPath 'system.txt'
    Write-Verbose "Creating file '$outFile'"
    [PSCustomObject]$metadata.system |
        Format-List |
        Out-String |
        Set-Content -NoNewline -LiteralPath $outFile
}

##############
# Categories #
##############
if ($metadata.categories) {
    $metadata.categories |
        Where-Object id -NE 'GLevLNI9wkl' |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,shortName,dataDimension,dataDimensionType |
        Export-ConditionalCsv -ObjectName categories
}

if ($metadata.categoryCombos) {
    $metadata.categoryCombos |
        Where-Object id -NE 'bjDvmb4bfuf' |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,dataDimensionType,skipTotal |
        Export-ConditionalCsv -ObjectName categoryCombos
}

if ($metadata.categoryOptions) {
    $metadata.categoryOptions |
        Where-Object id -NE 'xYerKDKCefk' |
        Sort-Object -Property code |
        Select-Object -Property id,code,shortName,name |
        Export-ConditionalCsv -ObjectName categoryOptions
}

if ($metadata.categoryOptionCombos) {
    $metadata.categoryOptionCombos |
        Where-Object id -NE 'HllvX50cXC0' |
        Sort-Object -Property code |
        Select-Object -Property  @(
            'id'
            'code'
            'name'
            'ignoreApproval'
            @{l='categoryCombo';e={$_.categoryCombo.id}}
            @{l='categoryOptions';e={$_.categoryOptions.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName categoryOptionCombos
}

#################
# Data Elements #
#################
if ($metadata.dataElements) {
    $metadata.dataElements |
        Sort-Object -Property code |
        Select-Object -Property  @(
            'id'
            'code'
            'shortName'
            'formName'
            'name'
            'description'
            'valueType'
            @{l='optionSet';e={$_.optionSet.id}}
            'aggregationType'
            'domainType'
            'zeroIsSignificant'
            @{l='categoryCombo';e={$_.categoryCombo.id}}
            ) |
        Export-ConditionalCsv -ObjectName dataElements
}

if ($metadata.dataElementGroups) {
    $metadata.dataElementGroups |
        Sort-Object -Property code |
        Select-Object -Property  @(
            'id'
            'code'
            'shortName'
            'name'
            @{l='dataElements';e={$_.dataElements.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName dataElementGroups
}

##############
# Indicators #
##############
if ($metadata.indicatorTypes) {
    $metadata.indicatorTypes |
        Sort-Object -Property name |
        Select-Object -Property  @(
            'id'
            'name'
            'factor'
            'number'
            ) |
        Export-ConditionalCsv -ObjectName indicatorTypes
}

###########
# Options #
###########
if ($metadata.options) {
    $metadata.options |
        Sort-Object -Property {$_.optionSet.id},sortOrder |
        Select-Object -Property @{l='optionSet';e={$_.optionSet.id}},id,code,name,sortOrder |
        Export-ConditionalCsv -ObjectName options
}

if ($metadata.optionSets) {
    $metadata.optionSets |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,valueType |
        Export-ConditionalCsv -ObjectName optionSets
}

if ($metadata.optionGroups) {
    $metadata.optionGroups |
        Sort-Object -Property {$_.optionSet.id},code |
        Select-Object -Property  @(
            @{l='optionSet';e={$_.optionSet.id}}
            'id'
            'code'
            'shortName'
            'name'
            'description'
            @{l='options';e={$_.options.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName optionGroups
}

if ($metadata.optionGroupSets) {
    $metadata.optionGroupSets |
        Sort-Object -Property {$_.optionSet.id},code |
        Select-Object -Property  @(
            @{l='optionSet';e={$_.optionSet.id}}
            'id'
            'code'
            'name'
            'dataDimension'
            @{l='optionGroups';e={$_.optionGroups.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName optionGroupSets
}

######################
# Organisation Units #
######################
if ($metadata.organisationUnitGroups) {
    $metadata.organisationUnitGroups |
        Sort-Object -Property code |
        Select-Object -Property id,code,shortName,name |
        Export-ConditionalCsv -ObjectName organisationUnitGroups
}

if ($metadata.organisationUnitGroupSets) {
    $metadata.organisationUnitGroupSets |
        Sort-Object -Property code |
        Select-Object -Property  @(
            'id'
            'code'
            'shortName'
            'name'
            'dataDimension'
            'compulsory'
            'includeSubhierarchyInAnalytics'
            @{l='organisationUnitGroups';e={$_.organisationUnitGroups.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName organisationUnitGroupSets
}

#########
# Other #
#########
if ($metadata.attributes) {
    $metadata.attributes |
        Sort-Object -Property {$_.optionSet.id},code |
        Select-Object -Property  @(
            'id'
            'code'
            'shortName'
            'name'
            'valueType'
            @{l='objectTypes';e={$_.objectTypes | Sort-Object | Join-String -Separator ' '}}
            'description'
            'mandatory'
            'unique'
            'categoryAttribute'
            'categoryOptionAttribute'
            'categoryOptionComboAttribute'
            'categoryOptionGroupAttribute'
            'categoryOptionGroupSetAttribute'
            'constantAttribute'
            'dataElementAttribute'
            'dataElementGroupAttribute'
            'dataElementGroupSetAttribute'
            'dataSetAttribute'
            'documentAttribute'
            'eventChartAttribute'
            'eventReportAttribute'
            'indicatorAttribute'
            'indicatorGroupAttribute'
            'legendSetAttribute'
            'mapAttribute'
            'optionAttribute'
            'optionSetAttribute'
            'organisationUnitAttribute'
            'organisationUnitGroupAttribute'
            'organisationUnitGroupSetAttribute'
            'programAttribute'
            'programIndicatorAttribute'
            'programStageAttribute'
            'relationshipTypeAttribute'
            'sectionAttribute'
            'sqlViewAttribute'
            'trackedEntityAttributeAttribute'
            'trackedEntityTypeAttribute'
            'userAttribute'
            'userGroupAttribute'
            'validationRuleAttribute'
            'validationRuleGroupAttribute'
            'visualizationAttribute'
            ) |
        Export-ConditionalCsv -ObjectName attributes
}

###########
# Program #
###########
if ($metadata.programs) {
    $metadata.programs |
        Sort-Object -Property code |
        Select-Object -Property  @(
            'id'
            'code'
            'shortName'
            'name'
            'description'
            'enrollmentDateLabel'
            'incidentDateLabel'
            'programType'
            'displayIncidentDate'
            'ignoreOverdueEvents'
            'onlyEnrollOnce'
            'selectEnrollmentDatesInFuture'
            'selectIncidentDatesInFuture'
            @{l='trackedEntityType';e={$_.trackedEntityType.id}}
            @{l='categoryCombo';e={$_.categoryCombo.id}}
            'skipOffline'
            'displayFrontPageList'
            'useFirstStageDuringRegistration'
            'expiryDays'
            'completeEventsExpiryDays'
            'openDaysAfterCoEndDate'
            'minAttributesRequiredToSearch'
            'maxTeiCountToReturn'
            'accessLevel'
            ) |
        Export-ConditionalCsv -ObjectName programs
}

if ($metadata.programIndicators) {
    $metadata.programIndicators |
        Sort-Object -Property {$_.program.id},code |
        Select-Object -Property @(
            @{l='program';e={$_.program.id}}
            'id'
            'code'
            'shortName'
            'name'
            'aggregationType'
            'analyticsType'
            'displayInForm'
            'filter'
            'expression'
            # ToDO: 'analyticsPeriodBoundaries'
            ) |
        Export-ConditionalCsv -ObjectName programIndicators
}

if ($metadata.programSections) {
    $metadata.programSections |
        Sort-Object -Property {$_.program.id},sortOrder |
        Select-Object -Property  @(
            @{l='program';e={$_.program.id}}
            'id'
            'name'
            @{l='renderType_MOBILE';e={$_.renderType.MOBILE.type}}
            @{l='renderType_DESKTOP';e={$_.renderType.DESKTOP.type}}
            'sortOrder'
            @{l='trackedEntityAttributes';e={$_.trackedEntityAttributes.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName programSections
}

if ($metadata.programStages) {
    $metadata.programStages |
        Sort-Object -Property {$_.program.id},sortOrder |
        Select-Object -Property @(
            @{l='program';e={$_.program.id}}
            'id'
            'name'
            'description'
            'executionDateLabel'
            'repeatable'
            'sortOrder'
            'minDaysFromStart'
            'autoGenerateEvent'
            'validationStrategy'
            'displayGenerateEventBox'
            'blockEntryForm'
            'preGenerateUID'
            'remindCompleted'
            'generatedByEnrollmentDate'
            'allowGenerateNextVisit'
            'openAfterEnrollment'
            'hideDueDate'
            'enableUserAssignment'
            'referral'
            @{l='notificationTemplates';e={$_.notificationTemplates.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName programStages
}

if ($metadata.programStageSections) {
    $metadata.programStageSections |
        Sort-Object -Property {$_.programStage.id},sortOrder |
        Select-Object -Property @(
            @{l='programStage';e={$_.programStage.id}}
            'id'
            'name'
            'description'
            'sortOrder'
            @{l='renderType_MOBILE';e={$_.renderType.MOBILE.type}}
            @{l='renderType_DESKTOP';e={$_.renderType.DESKTOP.type}}
            @{l='dataElements';e={$_.dataElements.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName programStageSections
}

if ($metadata.programNotificationTemplates) {
    $metadata.programNotificationTemplates |
        Sort-Object -Property notificationTrigger,notificationRecipient,name |
        Select-Object -Property @(
            'id'
            'name'
            'notificationTrigger'
            'notificationRecipient'
            'notifyUsersInHierarchyOnly'
            'sendRepeatable'
            @{l='recipientUserGroup';e={$_.recipientUserGroup.id}}
            'subjectTemplate'
            'messageTemplate'
            ) |
        Export-ConditionalCsv -ObjectName programNotificationTemplates
}

if ($metadata.programStageDataElements) {
    $metadata.programStageDataElements |
        Sort-Object -Property {$_.programStage.id},sortOrder |
        Select-Object -Property @(
            @{l='programStage';e={$_.programStage.id}}
            @{l='dataElement';e={$_.dataElement.id}}
            'id'
            'compulsory'
            'allowProvidedElsewhere'
            'displayInReports'
            'allowFutureDate'
            'renderOptionsAsRadio'
            'skipSynchronization'
            'skipAnalytics'
            'sortOrder'
            ) |
        Export-ConditionalCsv -ObjectName programStageDataElements
}

if ($metadata.programTrackedEntityAttributes) {
    $metadata.programTrackedEntityAttributes |
        Sort-Object -Property {$_.program.id},sortOrder |
        Select-Object -Property @(
            @{l='program';e={$_.program.id}}
            @{l='trackedEntityAttribute';e={$_.trackedEntityAttribute.id}}
            'id'
            'mandatory'
            'displayInList'
            'searchable'
            'renderOptionsAsRadio'
            'sortOrder'
            ) |
        Export-ConditionalCsv -ObjectName programTrackedEntityAttributes
}

#################
# Program Rules #
#################
if ($metadata.programRules) {
    $metadata.programRules |
        Sort-Object -Property {$_.program.id},{$_.programStage.id},priority,name |
        Select-Object -Property  @(
            @{l='program';e={$_.program.id}}
            @{l='programStage';e={$_.programStage.id}}
            'id'
            'priority'
            'name'
            'description'
            'condition'
            ) |
        Export-ConditionalCsv -ObjectName programRules
}

if ($metadata.programRuleActions) {
    $metadata.programRuleActions |
        Sort-Object -Property programRuleActionType,{$_.programRule.id},id |
        Select-Object -Property  @(
            'id'
            @{l='programRule';e={$_.programRule.id}}
            'programRuleActionType'
            'location'
            'content'
            'data'
            'templateUid'
            @{l='dataElement';e={$_.dataElement.id}}
            @{l='trackedEntityAttribute';e={$_.trackedEntityAttribute.id}}
            @{l='programStageSection';e={$_.programStageSection.id}}
            ) |
        Export-ConditionalCsv -ObjectName programRuleActions
}

if ($metadata.programRuleVariables) {
    $metadata.programRuleVariables |
        Sort-Object -Property {$_.program.id},programRuleVariableSourceType,name |
        Select-Object -Property @(
            @{l='program';e={$_.program.id}}
            'id'
            'name'
            'valueType'
            'useCodeForOptionSet'
            'programRuleVariableSourceType'
            @{l='dataElement';e={$_.dataElement.id}}
            @{l='programStage';e={$_.programStage.id}}
            @{l='trackedEntityAttribute';e={$_.trackedEntityAttribute.id}}
            ) |
        Export-ConditionalCsv -ObjectName programRuleVariables
}
####################
# Tracked Entities #
####################
if ($metadata.trackedEntityTypes) {
    $metadata.trackedEntityTypes |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'name'
            'shortName'
            'description'
            'featureType'
            'minAttributesRequiredToSearch'
            'maxTeiCountToReturn'
            'allowAuditLog'
            @{l='icon';e={$_.style.icon}}
            @{l='trackedEntityTypeAttributes';e={$_.trackedEntityTypeAttributes.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName trackedEntityTypes
}

if ($metadata.trackedEntityTypes.trackedEntityTypeAttributes) {
    $metadata.trackedEntityTypes.trackedEntityTypeAttributes |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'externalAccess'
            'displayInList'
            'mandatory'
            'searchable'
            'favorite'
            @{l='trackedEntityAttribute';e={$_.trackedEntityAttribute.id}}
            @{l='trackedEntityType';e={$_.trackedEntityType.id}}
            ) |
        Export-ConditionalCsv -ObjectName trackedEntityTypeAttributes
}

if ($metadata.trackedEntityAttributes) {
    $metadata.trackedEntityAttributes |
        Sort-Object -Property code |
        Select-Object -Property @(
            'id'
            'code'
            'shortName'
            'name'
            'formName'
            'description'
            'valueType'
            'pattern'
            'aggregationType'
            'unique'
            'generated'
            'confidential'
            'inherit'
            'skipSynchronization'
            'displayOnVisitSchedule'
            'displayInListNoProgram'
            'orgunitScope'
            @{l='optionSet';e={$_.optionSet.id}}
            ) |
        Export-ConditionalCsv -ObjectName trackedEntityAttributes
}

#########
# Users #
#########
if ($metadata.userGroups) {
    $metadata.userGroups |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'code'
            'name'
            @{l='managedGroups';e={$_.managedGroups.id | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName userGroups
}

if ($metadata.userRoles) {
    $metadata.userRoles |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'name'
            'description'
            @{l='authorities';e={$_.authorities | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName userRoles
}

##############
# Validation #
##############
if ($metadata.validationRules) {
    $metadata.validationRules |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'name'
            'importance'
            'operator'
            'periodType'
            'skipFormValidation'
            @{l='leftSide_slidingWindow';e={$_.leftSide.slidingWindow}}
            @{l='leftSide_missingValueStrategy';e={$_.leftSide.missingValueStrategy}}
            @{l='leftSide_expression';e={$_.leftSide.expression}}
            @{l='rightSide_slidingWindow';e={$_.rightSide.slidingWindow}}
            @{l='rightSide_missingValueStrategy';e={$_.rightSide.missingValueStrategy}}
            @{l='rightSide_expression';e={$_.rightSide.expression}}
            @{l='organisationUnitLevels';e={$_.organisationUnitLevels | Sort-Object | Join-String -Separator ' '}}
            ) |
        Export-ConditionalCsv -ObjectName validationRules
}
