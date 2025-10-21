##########################################################################

#Update-W365MachineRegion.ps1
#Author : Sujin Nelladath
#LinkedIn : https://www.linkedin.com/in/sujin-nelladath-8911968a/


##########################################################################

Connect-MgGraph -Scopes "CloudPC.ReadWrite.All", "DeviceManagementConfiguration.ReadWrite.All" -NoWelcome

# Get user inputs
$CloudPCName = Read-Host "Enter Cloud PC Name"
$RegionName = Read-Host "Enter Region Name (e.g., centralindia)"
$RegionGroup = Read-Host "Enter Region Group (e.g., India)"
$RegionName = $RegionName.ToLower()
$RegionGroup = $RegionGroup.ToLower()

Write-Host "Searching for Cloud PC: $CloudPCName"

# Step 1: Find the Cloud PC and get policy ID
$cloudPCUri = "https://graph.microsoft.com/v1.0/deviceManagement/virtualEndpoint/cloudPCs?`$filter=managedDeviceName eq '$CloudPCName'&`$select=provisioningPolicyId"

try {
    $cloudPC = Invoke-MgGraphRequest -Uri $cloudPCUri
    
    if ($cloudPC.value.Count -eq 0) 
    {
        Write-Host "Cloud PC not found!" -ForegroundColor Red
        exit
    }
    
    $policyId = $cloudPC.value[0].provisioningPolicyId
    Write-Host "Found Policy ID: $policyId"
    
} 

catch 
{
    Write-Host "Error finding Cloud PC: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Step 2: Update the provisioning policy
$updateUri = "https://graph.microsoft.com/v1.0/deviceManagement/virtualEndpoint/provisioningPolicies/$policyId"

$body = @{
    "@odata.type" = "#microsoft.graph.cloudPcProvisioningPolicy"
    "domainJoinConfigurations" = @(
        @{
            "@odata.type" = "#microsoft.graph.cloudPcDomainJoinConfiguration"
            "regionName" = $RegionName
            "regionGroup" = $RegionGroup
        }
    )
} | ConvertTo-Json -Depth 3

Write-Host "Updating region to: $RegionName ($RegionGroup)"

try 
{
    Invoke-MgGraphRequest -Uri $updateUri -Method PATCH -Body $body
    Write-Host "Region updated successfully!" -ForegroundColor Green
    
} 

catch

{
    Write-Host "Error updating region: $($_.Exception.Message)" -ForegroundColor Red
}
