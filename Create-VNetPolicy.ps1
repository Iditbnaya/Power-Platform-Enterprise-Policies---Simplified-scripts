<#
.SYNOPSIS
    Creates a Power Platform Network Injection (VNet) Enterprise Policy.
    Supports both Single Region (1 VNet) and Paired Region (2 VNets) configurations.

.PARAMETER SubscriptionId
    The Azure Subscription ID where the policy will be created.

.PARAMETER ResourceGroupName
    The Resource Group name.

.PARAMETER Location
    The Azure Region for the Policy (e.g., "westeurope" or "europe").

.PARAMETER PolicyName
    The name of the new Enterprise Policy resource.

.PARAMETER PrimaryVnetId
    The Resource ID of the Primary VNet.

.PARAMETER PrimarySubnetName
    The name of the subnet in the Primary VNet.

.PARAMETER SecondaryVnetId
    (Optional) The Resource ID of the Secondary VNet. Required for Paired Regions (e.g. North Europe).

.PARAMETER SecondarySubnetName
    (Optional) The name of the subnet in the Secondary VNet. Required if SecondaryVnetId is provided.
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
    [string]$PrimaryVnetId,

    [Parameter(Mandatory=$true)]
    [string]$PrimarySubnetName,

    [Parameter(Mandatory=$false)]
    [string]$SecondaryVnetId,

    [Parameter(Mandatory=$false)]
    [string]$SecondarySubnetName
)

$ScriptPath = $PSScriptRoot
Import-Module "$ScriptPath\Modules\PolicyUtils.psm1" -Force

try {
    # 1. Login
    Connect-PolicyAccount -SubscriptionId $SubscriptionId

    # 2. Build Virtual Networks Array
    $virtualNetworks = @(
        @{
            "id" = $PrimaryVnetId
            "subnet" = @{
                "name" = $PrimarySubnetName
            }
        }
    )

    if (-not [string]::IsNullOrWhiteSpace($SecondaryVnetId)) {
        if ([string]::IsNullOrWhiteSpace($SecondarySubnetName)) {
            Throw "SecondarySubnetName must be provided if SecondaryVnetId is specified."
        }

        Write-Host "Configuring Paired Region Policy (Primary + Secondary VNet)..." -ForegroundColor Yellow
        $virtualNetworks += @{
            "id" = $SecondaryVnetId
            "subnet" = @{
                "name" = $SecondarySubnetName
            }
        }
    }
    else {
        Write-Host "Configuring Single Region Policy (Primary VNet only)..." -ForegroundColor Yellow
    }

    # 3. Construct ARM Template Body
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
                "kind"       = "NetworkInjection"
                "properties" = @{
                    "networkInjection" = @{
                        "virtualNetworks" = $virtualNetworks
                    }
                }
            }
        )
    }

    # 4. Deploy
    New-PolicyDeployment `
        -ResourceGroupName $ResourceGroupName `
        -DeploymentName "Deploy-VNetPolicy-$PolicyName" `
        -TemplateBody $templateBody

    # 5. Output Result
    $policyId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.PowerPlatform/enterprisePolicies/$PolicyName"
    Write-Host "`nPolicy Created Successfully!" -ForegroundColor Green
    Write-Host "Policy ID: $policyId" -ForegroundColor Gray
}
catch {
    Write-Error "Script execution failed: $_"
}
