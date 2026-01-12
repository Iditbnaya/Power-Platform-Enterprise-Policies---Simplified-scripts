@{
    # Policy Type: 'VNet' or 'Encryption'
    PolicyType = "VNet"

    # Common Parameters
    SubscriptionId    = "SubscriptionID"
    ResourceGroupName = "ResourceGroupName"
    Location          = "europe" #The location of your Power Platform
    PolicyName        = "MyConfiguredVnetPolicy1"

    # VNet Specific Parameters
    PrimaryVnetId     = "/subscriptions/<SubscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.Network/virtualNetworks/<VNetname>"
    PrimarySubnetName = ""
    
    # Optional Pair (Comment out if Single Region)
    SecondaryVnetId     = "/subscriptions/<SubscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.Network/virtualNetworks/<VNetname>"
    SecondarySubnetName = ""
}
