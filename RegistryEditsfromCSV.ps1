param (
    [Parameter(Mandatory = $true)]
    [string]$csvFile
)
function Set_or_Create-Registry_Value {
    param (
        [Parameter(Mandatory = $true)]
        [string]$keyPath,
        [Parameter(Mandatory = $true)]
        [string]$keyPropertyName,
        [Parameter(Mandatory = $true)]
        [string]$keyType,
        [Parameter(Mandatory = $true)]
        [string]$keyValue

    )
    $ParentPath = $keyPath.Remove($keyPath.LastIndexOf('\'))

    if (-not (Test-Path $keyPath)) {
        New-Item $keyPath -Force
    }
    if ($null -ne (Get-ItemProperty $keyPath).$keyPropertyName) {
        Set-ItemProperty $keyPath -Name $keyPropertyName -Value $keyValue
    }
    else {
        New-ItemProperty -Path $keyPath -Name "$keyPropertyName" -Value $keyValue -PropertyType $keyType
    }
}

$workingCSV = Import-Csv $csvFile
$workingCSV | ForEach-Object { 
    if ($_.type -eq "REG_DWORD") {
        $_.type = "DWord"
    }
    elseif ($_.type -eq "REG_SZ") {
        $_.type = "String"
    }
    elseif ($_.type -eq "REG_EXPAND_SZ") {
        $_.type = "ExpandString"
    }
    elseif ($_.type -eq "REG_MULTI_SZ") {
        $_.type = "MultiString"
    }
    elseif ($_.type -eq "REG_BINARY") {
        $_.type = "Binary"
    }
    elseif ($_.type -eq "REG_QWORD") {
        $_.type = "Qword"
    }
    elseif ($_.type -eq "REG_RESOURCE-LIST") {
        $_.type = "Unknown"
    }
}

#Make registry edits
Write-Host "Modifying Registry"
$workingCSV | ForEach-Object { Set_or_Create-Registry_Value -keyPath $_.path -keyProperty $_.property -keyType $_.type -keyValue $_.value }