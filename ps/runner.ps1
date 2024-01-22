aws configure list
$prof = $args[0]
$InstanceId = $args[1]
$storageType = $args[2]
$RdsInstancesId = $args[3]
$tunnelPort = $args[5]
$localPort = $args[6]

Write-Host "`u{2728} $InstanceId" -ForegroundColor green
""
## Connect to RDS or Redis  ###########################################
if ($storageType -eq 'rds') {
  Write-Host "`u{2705} Tunneling RDS (Relational Database Service)..." -ForegroundColor green
  Write-Host "`u{2728} $RdsInstancesId $tunnelPort" -ForegroundColor green
}else {
  Write-Host "`u{2705} Tunneling ElatiCache ""Redis""..." -ForegroundColor green
  Write-Host "`u{2728} $RdsInstancesId $tunnelPort" -ForegroundColor green
}
## START Session ###################################################
$param = "{""host"":[""$RdsInstancesId""], ""portNumber"":[""$tunnelPort""], ""localPortNumber"":[""$localPort""]}"
aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof
