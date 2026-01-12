@{
    # Policy Type: 'VNet' or 'Encryption'
    PolicyType = "Encryption"

    # Common Parameters
    SubscriptionId    = ""
    ResourceGroupName = ""
    Location          = ""
    PolicyName        = "MyConfiguredCMKPolicy"

    # Encryption Specific Parameters
    KeyVaultId = "/subscriptions/<SubscriptionId>/resourceGroups/<ResourceGroupName>/providers/Microsoft.KeyVault/vaults/<MyKeyVaultName>"
    KeyName    = "MyEncryptionKey"
    KeyVersion = "d83f8646736486c48364863486"
}
