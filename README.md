# Power Platform Enterprise Policies - Simplified scripts

Welcome to the simplified PowerShell toolkit for managing **Power Platform Enterprise Policies**. 

git init **Network Injection (VNet)** or **Customer Managed Key (CMK/Encryption)** policies without the overhead of complex, monolithic frameworks.

## 🚀 Features

*   **VNet Injection Policies**: Easily create policies for both Single and Paired regions.
*   **Encryption Policies**: Simple setup for Customer Managed Keys (CMK) using Azure Key Vault.
*   **Configuration Driven**: Support for .psd1 configuration files to manage environments as code.
*   **Modular Design**: Reusable helper functions for consistency.

## 📋 Prerequisites

Before relying on these scripts, ensure you have the following:

1.  **PowerShell 7+** (Recommended) or Windows PowerShell 5.1.
2.  **Azure PowerShell Module** (Az):
    `powershell
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    `
3.  **Permissions**: You must have Owner or Contributor rights on the Azure Subscription and Resource Group where policies will be created.
> 💡 **Tip**: Run `.\Check-Prerequisites.ps1` to verify your environment setup automatically.
## 📂 Repository Structure

`	ext
.
├── Configs/                    # Configuration templates
│   ├── Encryption-Config.psd1  # Template for Encryption policies
│   └── VNet-Config.psd1        # Template for VNet policies
├── Modules/
│   └── PolicyUtils.psm1        # Shared helper functions (Login, ARM deployment)
├── Check-Prerequisites.ps1     # Script to check for installed modules
├── Create-EncryptionPolicy.ps1 # Script to create Encryption policies
├── Create-VNetPolicy.ps1       # Script to create VNet policies
├── Deploy-PolicyFromConfig.ps1 # Master script to deploy using config files
└── README.md                   # Documentation
`

## 🛠️ Getting Started

### Method 1: Using Configuration Files (Recommended)

This method ensures you have a record of your deployment settings and makes reruns easier.

1.  **Clone the repository**:
    `\bash
    git clone https://github.com/yourusername/PowerPlatformEnterprisePolicies-SimpleScripts.git
    cd PowerPlatformEnterprisePolicies-SimpleScripts
    `

2.  **Prepare your configuration**:
    *   Navigate to the Configs folder.
    *   Copy VNet-Config.psd1 or Encryption-Config.psd1 to a new file (e.g., MyProductionVNet.psd1).
    *   Edit the file with your specific Azure Subscription ID, Resource Group, and VNet details.

3.  **Run the deployment**:
    `powershell
    .\Deploy-PolicyFromConfig.ps1 -ConfigFilePath ".\Configs\MyProductionVNet.psd1"
    `

### Method 2: Command Line (Ad-hoc)

You can also run the scripts directly with parameters for quick, one-off tasks.

#### Creating a VNet Policy (Paired Regions)

Suitable for environments ensuring Business Continuity (BCDR).

`powershell
.\Create-VNetPolicy.ps1 
    -SubscriptionId "00000000-0000-0000-0000-000000000000" 
    -ResourceGroupName "MyResourceGroup" 
    -Location "northeurope" 
    -PolicyName "ProdVNetPolicy" 
    -PrimaryVnetId "/subscriptions/.../virtualNetworks/VnetNorth" 
    -PrimarySubnetName "subnet-north" 
    -SecondaryVnetId "/subscriptions/.../virtualNetworks/VnetWest" 
    -SecondarySubnetName "subnet-west"
`

#### Creating an Encryption (CMK) Policy

`powershell
.\Create-EncryptionPolicy.ps1 
    -SubscriptionId "00000000-0000-0000-0000-000000000000" 
    -ResourceGroupName "MyResourceGroup" 
    -Location "eastus" 
    -PolicyName "ProdEncryptionPolicy" 
    -KeyVaultId "/subscriptions/.../vaults/MyKeyVault" 
    -KeyName "MyKey" 
    -KeyVersion "optional-version-guid"
`

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements or bug fixes:

1.  Fork the repository.
2.  Create a feature branch (git checkout -b feature/NewFeature).
3.  Commit your changes.
4.  Push to the branch.
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Based on the original [PowerPlatform-EnterprisePolicies](https://github.com/microsoft/PowerPlatform-EnterprisePolicies/) repository.*
