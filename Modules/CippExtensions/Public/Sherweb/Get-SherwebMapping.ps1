function Get-SherwebMapping {
    [CmdletBinding()]
    param (
        $CIPPMapping
    )

    $ExtensionMappings = Get-ExtensionMapping -Extension 'Sherweb'

    $Tenants = Get-Tenants -IncludeErrors

    $Mappings = foreach ($Mapping in $ExtensionMappings) {
        $Tenant = $Tenants | Where-Object { $_.defaultDomainName -eq $Mapping.RowKey }
        if ($Tenant) {
            [PSCustomObject]@{
                TenantId        = $Tenant.customerId
                Tenant          = $Tenant.displayName
                TenantDomain    = $Tenant.defaultDomainName
                IntegrationId   = $Mapping.IntegrationId
                IntegrationName = $Mapping.IntegrationName
            }
        }
    }
    $Tenants = Get-Tenants -IncludeErrors
    try {
        $SherwebCustomers = Get-SherwebCustomers

    } catch {
        $Message = if ($_.ErrorDetails.Message) {
            Get-NormalizedError -Message $_.ErrorDetails.Message
        } else {
            $_.Exception.message
        }

        Write-LogMessage -Message "Could not get Sherweb Companies, error: $Message " -Level Error -tenant 'CIPP' -API 'SherwebMapping'
        $SherwebCustomers = @(@{name = "Could not get Sherweb Companies, error: $Message"; value = '-1' })
    }
    $SherwebCustomers = $SherwebCustomers | ForEach-Object {
        [PSCustomObject]@{
            name  = $_.displayName
            value = "$($_.id)"
        }
    }
    $MappingObj = [PSCustomObject]@{
        Companies = @($SherwebCustomers)
        Mappings  = @($Mappings)
    }

    return $MappingObj

}