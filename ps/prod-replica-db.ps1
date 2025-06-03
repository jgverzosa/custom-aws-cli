## ENVIRONMENT ######################################################
$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging '
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$dev = New-Object System.Management.Automation.Host.ChoiceDescription '&Development', 'Development'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($dev, $stg, $prd)
$title = 'AWS Environment Role'
$Prof = "default"
""
Write-Host "`u{2728} Environment: $Prof" -ForegroundColor green
### STORAGE TYPE ######################################################
$storageRds = New-Object System.Management.Automation.Host.ChoiceDescription '&RDS', 'RDS'
$storageRedis = New-Object System.Management.Automation.Host.ChoiceDescription '&ElastiCacheRedis', 'ElastiCacheRedis'
$storageOptions = [System.Management.Automation.Host.ChoiceDescription[]]($storageRds, $storageRedis)
$storageType = "rds"; $localPort = 3301
""
Write-Host "`u{2728} Storage Type: $storageType" -ForegroundColor green
""
Write-Host "`u{2728} Local Port: $localPort" -ForegroundColor green
""
## EC2 ##################################################################
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
""
## Connect static dns  #################################################
$dnsDbList = @(
  "rds.replica.local.deliverit.com.au"
)
Write-Host "DNS DB List:"
foreach ($dnsDb in $dnsDbList) {
  Write-Host $dnsDb
}
""
## Connect to RDS or Redis  ###########################################
if ($storageType -eq 'rds') {
  ## RDS connection ###################################################
  $tunnelPort = 3306
  $RdsInstancesId = "rds.replica.local.deliverit.com.au"
  Write-Host "`u{2705} Tunneling RDS (Relational Database Service)..." -ForegroundColor green
  Write-Host "`u{2728} $RdsInstancesId $tunnelPort" -ForegroundColor green
}

## START Session ###################################################
$param = "{""host"":[""$RdsInstancesId""], ""portNumber"":[""$tunnelPort""], ""localPortNumber"":[""$localPort""]}"
Write-Host "aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof" -ForegroundColor yellow
aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof
