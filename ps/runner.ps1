$Prof = $args[0]
$InstanceId = $args[1]
$storageType = $args[2]
$RdsInstancesId = $args[3]
$tunnelPort = $args[4]
$localPort = $args[5]

Write-Host "`u{2728} $args" -ForegroundColor green
""
## Connect to RDS or Redis  ###########################################
if ($storageType -eq 'rds') {
  Write-Host "`u{2705} Tunneling RDS (Relational Database Service)..." -ForegroundColor green
  Write-Host "`Environment: $Prof" -ForegroundColor green
  Write-Host "`Instance ID: $InstanceId" -ForegroundColor green
  Write-Host "`Storage Type: $storageType" -ForegroundColor green
  Write-Host "`DNS: $RdsInstancesId" -ForegroundColor green
  Write-Host "`DNS Port: $tunnelPort" -ForegroundColor green
  Write-Host "`Local Port: $localPort" -ForegroundColor green
}else {
  Write-Host "`u{2705} Tunneling ElatiCache ""Redis""..." -ForegroundColor green
  Write-Host "`Environment: $Prof" -ForegroundColor green
  Write-Host "`Instance ID: $InstanceId" -ForegroundColor green
  Write-Host "`Storage Type: $storageType" -ForegroundColor green
  Write-Host "`DNS: $RdsInstancesId" -ForegroundColor green
  Write-Host "`DNS Port: $tunnelPort" -ForegroundColor green
  Write-Host "`Local Port: $localPort" -ForegroundColor green
}
## START Session ###################################################
$param = "{""host"":[""$RdsInstancesId""], ""portNumber"":[""$tunnelPort""], ""localPortNumber"":[""$localPort""]}"
Write-Host "`u{2728} connecting..." -ForegroundColor green

aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof
