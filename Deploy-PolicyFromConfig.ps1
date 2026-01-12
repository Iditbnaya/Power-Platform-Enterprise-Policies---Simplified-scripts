<#
.SYNOPSIS
    Orchestrator script to deploy policies using a configuration file.
    This allows you to separate configuration values (variables) from the logic.

.PARAMETER ConfigFilePath
    Path to the .psd1 configuration file.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ConfigFilePath
)

$ScriptPath = $PSScriptRoot

if (-not (Test-Path $ConfigFilePath)) {
    Write-Error "Configuration file not found at: $ConfigFilePath"
    exit 1
}

try {
    Write-Host "Reading configuration from $ConfigFilePath..." -ForegroundColor Cyan
    $config = Import-PowerShellDataFile -Path $ConfigFilePath

    if (-not $config.ContainsKey("PolicyType")) {
        Throw "Configuration file must contain a 'PolicyType' key with value 'VNet' or 'Encryption'."
    }

    $policyType = $config.PolicyType
    Write-Host "Detected Policy Type: $policyType" -ForegroundColor Green

    # Remove PolicyType from hashtable before passing to the specific script 
    # (since the scripts don't accept this parameter)
    $params = $config.Clone()
    $params.Remove("PolicyType")

    switch ($policyType) {
        "VNet" {
            & "$ScriptPath\Create-VNetPolicy.ps1" @params
        }
        "Encryption" {
            & "$ScriptPath\Create-EncryptionPolicy.ps1" @params
        }
        Default {
            Throw "Unknown PolicyType '$policyType'. Supported values: 'VNet', 'Encryption'."
        }
    }
}
catch {
    Write-Error "Deployment failed: $_"
}
