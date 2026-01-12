<#
.SYNOPSIS
    Checks if the required PowerShell modules for the Power Platform Enterprise Policies scripts are installed.

.DESCRIPTION
    This script verifies that the 'Az' module (or specifically 'Az.Accounts' and 'Az.Resources') 
    is installed and available. If missing, it provides instructions on how to install them.
#>

$requiredModules = @(
    @{ Name = "Az.Accounts";  MinVersion = "2.0.0" }
    @{ Name = "Az.Resources"; MinVersion = "4.0.0" }
)

$allPassed = $true

Write-Host "Checking prerequisites..." -ForegroundColor Cyan

foreach ($mod in $requiredModules) {
    $name = $mod.Name
    $minVersion = $mod.MinVersion

    # Check if module is available (installed)
    $installed = Get-Module -ListAvailable -Name $name | Sort-Object Version -Descending | Select-Object -First 1

    if ($null -eq $installed) {
        Write-Host "Create-X: Module '$name' is missing." -ForegroundColor Red
        $allPassed = $false
    }
    else {
        if ($installed.Version -lt [version]$minVersion) {
            Write-Host "Create-X: Module '$name' version '$($installed.Version)' is older than required ($minVersion)." -ForegroundColor Yellow
            $allPassed = $false
        }
        else {
            Write-Host "Success: Module '$name' found (Version: $($installed.Version))." -ForegroundColor Green
        }
    }
}

if (-not $allPassed) {
    Write-Host "`nSome prerequisites are missing." -ForegroundColor Red
    Write-Host "Please install the Azure PowerShell module by running:" -ForegroundColor Yellow
    Write-Host "Install-Module -Name Az -AllowClobber -Scope CurrentUser" -ForegroundColor White
    exit 1
} else {
    Write-Host "`nAll prerequisites met. You are ready to run the scripts!" -ForegroundColor Green
}
