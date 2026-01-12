<#
.SYNOPSIS
    Creates a Power Platform Encryption (Customer Managed Key/CMK) Enterprise Policy.
    NOTE: usage of "AKS" in requests usually refers to Azure Key Vault (AKV) keys for this policy type.

.PARAMETER SubscriptionId
    The Azure Subscription ID where the policy will be created.

.PARAMETER ResourceGroupName
    The Resource Group name.

.PARAMETER Location
    The Azure Region for the Policy.

.PARAMETER PolicyName
    The name of the new Enterprise Policy resource.

.PARAMETER KeyVaultId
    The Resource ID of the Azure Key Vault containing the CMK.

.PARAMETER KeyName
    The name of the Key in the Key Vault.

.PARAMETER KeyVersion
    The specific version of the Key to use.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [string]$PolicyName,

    [Parameter(Mandatory=$true)]
    [string]$KeyVaultId,

    [Parameter(Mandatory=$true)]
    [string]$KeyName,

    [Parameter(Mandatory=$true)]
    [string]$KeyVersion
)

$ScriptPath = $PSScriptRoot
Import-Module "$ScriptPath\Modules\PolicyUtils.psm1" -Force

try {
    # 1. Login
    Connect-PolicyAccount -SubscriptionId $SubscriptionId

    # 2. Construct ARM Template Body
    $templateBody = @{
        "`$schema"        = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        "contentVersion"  = "1.0.0.0"
        "parameters"      = @{}
        "resources"       = @(
            @{
                "type"       = "Microsoft.PowerPlatform/enterprisePolicies"
                "apiVersion" = "2020-10-30"
                "name"       = $PolicyName
                "location"   = $Location
                "kind"       = "Encryption"
                "identity"   = @{
                    "type" = "SystemAssigned"
                }
                "properties" = @{
                    "encryption" = @{
                        "state"    = "Enabled"
                        "keyVault" = @{
                            "id"  = $KeyVaultId
                            "key" = @{
                                "name"    = $KeyName
                                "version" = $KeyVersion
                            }
                        }
                    }
                }
            }
        )
    }

    # 3. Deploy
    New-PolicyDeployment `
        -ResourceGroupName $ResourceGroupName `
        -DeploymentName "Deploy-EncryptionPolicy-$PolicyName" `
        -TemplateBody $templateBody

    # 4. Output Result
    $policyId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.PowerPlatform/enterprisePolicies/$PolicyName"
    Write-Host "`nPolicy Created Successfully!" -ForegroundColor Green
    Write-Host "Policy ID: $policyId" -ForegroundColor Gray
    Write-Host "Ensure the System Assigned Managed Identity of this policy has 'Get', 'Wrap', 'Unwrap' permissions on the Key Vault." -ForegroundColor Yellow
}
catch {
    Write-Error "Script execution failed: $_"
}
