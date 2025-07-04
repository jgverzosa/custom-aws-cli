## ENVIRONMENT ######################################################
$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging '
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($stg, $prd)
$title = 'AWS Environment Role'
$message = 'Select AWS environment:'
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0 { $Prof = "ditstg" }
  1 { $Prof = "default" }
}
""
Write-Host "`u{2728} Environment: $Prof" -ForegroundColor green
### STORAGE TYPE ####################################################
$storageRds = New-Object System.Management.Automation.Host.ChoiceDescription '&RDS', 'RDS'
$storageRedis = New-Object System.Management.Automation.Host.ChoiceDescription '&ElastiCacheRedis', 'ElastiCacheRedis'
$storageOptions = [System.Management.Automation.Host.ChoiceDescription[]]($storageRds, $storageRedis)
$title = 'Storage Type'
$storageResult = $host.ui.PromptForChoice($title, "", $storageOptions, 0)
switch ($storageResult) {
  0 { $storageType = "rds"; $localPort = 3330 }
  1 { $storageType = "redis"; $localPort = 6380 }
}
""
Write-Host "`u{2728} Storage Type: $storageType" -ForegroundColor green
""
## LOCAL PORT #######################################################
$InputlocalPort = Read-Host -Prompt "Enter Local Port [?] Help (default is '$localPort')";
if ($InputlocalPort) {
  $localPort = $InputlocalPort
}
Write-Host "`u{2728} Local Port: $localPort" -ForegroundColor green
""

function Ec2 {
  ## EC2 ###############################################################
  Write-Host " Retrieving Instance Id" -ForegroundColor white
  # $Instances = aws ssm --profile $Prof describe-instance-information --output text --query "InstanceInformationList[*].[InstanceId]" --filters "Key=tag:Name,Values=oov7-stack/OOV7ASG";
  $Instances = aws ssm --profile $Prof describe-instance-information --output text --query "InstanceInformationList[*].[InstanceId]" --filters "Key=tag:Name,Values=delit-avmh-web-01";
  $server = "oov7-stack/OOV7ASG"
  $Instances = aws ec2 describe-instances --profile $Prof --output text --query "Reservations[*].Instances[*].InstanceId" --filter "Name=tag:Name,Values=$server*" "Name=instance-state-name,Values=running";
  if (!$Instances) {
    "`u{1F6D1} No Instance"
    return
  }
  $InstanceId = ($Instances -split '\n')[0]
  Write-Host "`u{2728} $InstanceId" -ForegroundColor green
  return $InstanceId
}

## Connect static dns  ###########################################
if ($storageType -eq 'rds') {
  $dnsDbList = @(
    "rds.local.deliverit.com.au", 
    "rds.replica.local.deliverit.com.au", 
    "cloud.local.deliverit.com.au", 
    "cloud-read.local.deliverit.com.au"
  )
} if ($storageType -eq 'redis') {
  $dnsDbList = @(
    "redis.local.deliverit.com.au", 
    "redis.replica.local.deliverit.com.au"
  )
}

Write-Host "Storage Host List:"
foreach ($dnsDb in $dnsDbList) {
  Write-Host $dnsDb
}
""
## Connect to RDS or Redis  ###########################################
if ($storageType -eq 'rds') {
  ## RDS connection ###################################################
  $tunnelPort = 3306
  $RdsInstances = $dnsDbList -join "`n";
  # $RdsInstances = aws rds --profile $Prof describe-db-instances --query 'DBInstances[*].[Endpoint.[Address]]' --output text;
  # if (!$RdsInstances) {
  #   "`u{1F6D1} No RDS Instance"
  #   return
  # }
  # "RDS Instance List:"
  # $RdsInstances
  # ""
  $RdsInstancesId = ($RdsInstances -split '\n')[0]
  $RdsInputInstanceId = ""
  $RdsInputInstanceId = Read-Host -Prompt "Enter RDS Instance [?] Help (default is '$RdsInstancesId')";
  if ($RdsInputInstanceId) {
    $RdsInstancesId = $RdsInputInstanceId
  }
  Write-Host "`u{2705} Tunneling RDS (Relational Database Service)..." -ForegroundColor green
  Write-Host "`u{2728} $RdsInstancesId $tunnelPort" -ForegroundColor green
  ""
  $InstanceId = Ec2;
  ""
}else {
  ## Redis connection ###################################################
  $tunnelPort = 6379
  $RedisInstances = $dnsDbList -join "`n";
  # $RedisInstances = aws elasticache --profile $Prof describe-cache-clusters --show-cache-node-info --query 'CacheClusters[*].[CacheNodes[*].Endpoint.Address]' --output text;
  # if (!$RedisInstances) {
  #   "`u{1F6D1} No Redis Instance"
  #   return
  # }
  # "Redis Instance List:"
  # $RedisInstances
  # ""
  $RdsInstancesId = ($RedisInstances -split '\n')[0]
  $RdsInputInstanceId = ""
  $RdsInputInstanceId = Read-Host -Prompt "Enter RDS Instance [?] Help (default is '$RdsInstancesId')";
  if ($RdsInputInstanceId) {
    $RdsInstancesId = $RdsInputInstanceId
  }
  Write-Host "`u{2705} Tunneling ElatiCache ""Redis""..." -ForegroundColor green
  Write-Host "`u{2728} $RdsInstancesId $tunnelPort" -ForegroundColor green
  ""
  $InstanceId = Ec2;
  ""
}

## START Session ###################################################
$param = "{""host"":[""$RdsInstancesId""], ""portNumber"":[""$tunnelPort""], ""localPortNumber"":[""$localPort""]}"
Write-Host "aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof" -ForegroundColor yellow
aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof


