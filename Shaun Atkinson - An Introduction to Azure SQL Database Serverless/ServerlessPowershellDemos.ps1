
# before you begin connect to your Azure account using Connect-AzAccount below
# then find and replace the string Your Resource Group Name in this script 
# with the name of your Azure SQL DB resource group.

Connect-AzAccount

return 'You pressed F5 and I saved you from giving all your demo  `
secrets away'

 # create a new serverless database

 # Enter your Resource Group Name, and if you want to you can change the 
 # Database Name, Minimum Number of vCores, Maximum Number of vCores, Database size (GB) 
 # and Auto Pause Delay in Minutes

 # Ensure the Auto Pause Delay in Minutes is at least 60 and ends with a 0 e.g. 60, 70, 80, 90 etc.

 $ResourceGroup = 'Your Resource Group Name'
 $DatabaseName = 'ServerlessPoshTestDB'
 $MinVcore = 0.5
 $MaxVcore = 1
 $MaxsizeinGB = 2
 $AutoPauseDelayMins = 60

  # Get Server Name

 $ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$ResourceGroup\b")} | `
 Select-Object -First 1 -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}

 $MaxSizeinBytes = 1024*1024*1024*$MaxsizeinGB

 New-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $serverName `
 -DatabaseName $DatabaseName -Edition GeneralPurpose -MaxSizeBytes $MaxSizeinBytes `
 -ComputeModel Serverless -ComputeGeneration Gen5 -MinVcore $MinVcore `
 -MaxVcore $MaxVcore -AutoPauseDelayInMinutes $AutoPauseDelayMins

 #------------------------------------------------------------------------------------------------------------------

 # Get information about your Serverless Database

 # If you changed the $DatabaseName in the script above then will need to change it below

 $ResourceGroup = 'Your Resource Group Name'
 $DatabaseName = 'ServerlessPoshTestDB'
 
 # Get Server Name
 
 $ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$DatabaseName\b")} | `
 Select-Object -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}
 
  # Return Serverless DB Status Results
 
 Get-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName `
 -DatabaseName $DatabaseName |  `
 Select-Object ResourceGroupName, ServerName, DatabaseName, Location, Edition, `
 CurrentServiceObjectiveName, MinimumCapacity, Capacity, `
 AutoPauseDelayInMinutes, MaxSizeBytes, Status 

#----------------------------------------------------------------------------------------------------------------------

# change AutoPauseDelay

 # Enter your Resource Group Name

 # If you changed the $DatabaseName in the script above then you will need to change it below

 # This script will fail because AutoPauseDelayMins must end with a 0

$ResourceGroup = 'Your Resource Group Name'
$DatabaseName = 'ServerlessPoshTestDB'
$MinVcore = 0.5
$MaxVcore = 1
$AutoPauseDelayMins = 75  

# Get Server Name

$ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$DatabaseName\b")} | `
Select-Object -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}


Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName `
-DatabaseName $databaseName -AutoPauseDelayInMinutes $AutoPauseDelayMins

  #--------------------------------------------------------------------------------------------------------------------------------

 # change min and max Vcores

 # Enter your Resource Group Name
 # If you changed the $DatabaseName in the script above then will need to change it below

 # This script will fail because $MaxVcore is set to an invalid value.

 # valid $MaxvCore values can be found here 
 # https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-single-databases
 # or on the Serverless maxVcore slider in the Azure Portal 

$ResourceGroup = 'Your Resource Group Name'
$DatabaseName = 'ServerlessPoshTestDB'
$MinVcore = 0.5
$MaxVcore = 3
$AutoPauseDelayMins = 60

# Get Server Name

$ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$DatabaseName\b")} | `
 Select-Object -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}


Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName `
-DatabaseName $databaseName -MinVcore $MinVcore -MaxVcore $MaxVcore 

  # ------------------------------------------------------------------------------------------------------------------------------

# change multiple settings together
   
# Enter your Resource Group Name

# this script with succeed as all parameters are now valid

$ResourceGroup = 'Your Resource Group Name'
$DatabaseName = 'ServerlessPoshTestDB'
$MinVcore = 0.5
$MaxVcore = 4
$AutoPauseDelayMins = 70

# Get Server Name

$ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$DatabaseName\b")} | `
Select-Object -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}

Set-AzSqlDatabase -ResourceGroupName $resourceGroup -ServerName $serverName `
-DatabaseName $DatabaseName -MinVcore $MinVcore -MaxVcore $MaxVcore `
-AutoPauseDelayInMinutes $AutoPauseDelayMins

 #-------------------------------------------------------------------------------------------------------------------------------------
 # Move AdventureWorksLT database to the Serverless compute tier
 
 # Ensure that the AdventureWorksLT database is on either the Provisoned Compute tier 
 # or another Azure Service Tier before running this script 

 # Instructions about how to create the AdventureWorksLT database in Azure can be found
 # here https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver15&tabs=ssms
 # under the Deploy to Azure SQL Database heading, Deploy new sample database.

 # Enter your Resource Group Name
 # Enter your own Database Name if you want to move one of your own DB's to serverless

# if you want to you can change the Minimum Number of vCores, Maximum Number of vCores, 
# Database size (GB) and Auto Pause Delay in Minutes parameters

$ResourceGroup = 'Your Resource Group Name'
$DatabaseName = 'AdventureWorksLT'
$MinVcore = 0.5
$MaxVcore = 1
$SizeinGB = 2
$AutoPauseDelayMins = 60

# Get Server Name

$ServerName=Get-AzResource | Where-Object { ($_.ResourceId -match "\b$ResourceGroup\b")} | `
Select-Object -First 1 -ExpandProperty ResourceId  | ForEach-Object {$_.Split('/')[8]}

$MaxSizeinBytes = 1024*1024*1024*$SizeinGB

 Set-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $ServerName `
 -DatabaseName $DatabaseName -Edition GeneralPurpose -MaxSizeBytes $MaxSizeinBytes `
 -ComputeModel Serverless -ComputeGeneration Gen5 -MinVcore $MinVcore  -MaxVcore $MaxVcore `
 -AutoPauseDelayInMinutes $AutoPauseDelayMins

 #-----------------------------------------------------------------------------------------------------------------------------------




