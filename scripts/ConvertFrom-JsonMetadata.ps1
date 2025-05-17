[CmdletBinding(PositionalBinding, SupportsShouldProcess)]
param(
    [Parameter(Position=0)]#, Mandatory)]
    [string]$LiteralPath = '/home/brar/Downloads/metadata.json',
    [Parameter(Position=1)]
    [string]$OutputDirectory = (Join-Path -Path (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..' -AdditionalChildPath 'metadata') -Relative) -ChildPath (Get-Date -Format FileDateTimeUniversal))
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

if ($metadata.optionSets)
{
    $metadata.optionSets |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,valueType |
        Export-ConditionalCsv -ObjectName optionSets
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

if ($metadata.options) {
    $metadata.options |
        Sort-Object -Property {$_.optionSet.id},sortOrder |
        Select-Object -Property @{l='optionSet';e={$_.optionSet.id}},id,code,name,sortOrder |
        Export-ConditionalCsv -ObjectName options
}

if ($metadata.categories) {
    $metadata.categories |
        Where-Object id -NE 'GLevLNI9wkl' |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,shortName,dataDimension,dataDimensionType |
        Export-ConditionalCsv -ObjectName categories
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

if ($metadata.categoryCombos) {
    $metadata.categoryCombos |
        Where-Object id -NE 'bjDvmb4bfuf' |
        Sort-Object -Property code |
        Select-Object -Property id,code,name,dataDimensionType,skipTotal |
        Export-ConditionalCsv -ObjectName categoryCombos
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

if ($metadata.trackedEntityTypes) {
    $metadata.trackedEntityTypes |
        Sort-Object -Property name |
        Select-Object -Property @(
            'id'
            'name'
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
