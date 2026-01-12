# Module: PolicyUtils
# Description: Helper functions for Power Platform Enterprise Policy operations

function Connect-PolicyAccount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionId
    )

    try {
        $context = Get-AzContext
        if ($null -eq $context -or $context.Subscription.Id -ne $SubscriptionId) {
            Write-Host "Connecting to Azure Subscription: $SubscriptionId" -ForegroundColor Cyan
            Connect-AzAccount -Subscription $SubscriptionId -ErrorAction Stop
        }
        else {
            Write-Host "Already connected to subscription: $SubscriptionId" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Failed to connect to Azure: $_"
        throw
    }
}

function New-PolicyDeployment {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        
        [Parameter(Mandatory=$true)]
        [string]$DeploymentName,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$TemplateBody
    )

    $tmpFile = New-TemporaryFile
    try {
        $TemplateBody | ConvertTo-Json -Depth 10 | Out-File $tmpFile.FullName -Force
        
        Write-Host "Starting deployment '$DeploymentName' to resource group '$ResourceGroupName'..." -ForegroundColor Cyan
        
        $deployment = New-AzResourceGroupDeployment `
            -Name $DeploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $tmpFile.FullName `
            -ErrorAction Stop

        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Host "Deployment Succeeded!" -ForegroundColor Green
            return $deployment
        }
        else {
            Write-Error "Deployment failed with state: $($deployment.ProvisioningState)"
        }
    }
    catch {
        Write-Error "Deployment failed: $_"
        throw
    }
    finally {
        if (Test-Path $tmpFile.FullName) {
            Remove-Item $tmpFile.FullName -Force
        }
    }
}
Export-ModuleMember -Function Connect-PolicyAccount, New-PolicyDeployment
