$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging '
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$dev = New-Object System.Management.Automation.Host.ChoiceDescription '&Development', 'Development'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($stg, $prd, $dev)
$title = 'AWS Environment Role'
$message = 'Select AWS environment:'
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0 { $Prof = "ditstg" }
  1 { $Prof = "default" }
  2 { $Prof = "ditdev" }
}
""
Write-Host "`u{2728} Environment: $Prof" -ForegroundColor green
""
#####################################################
$localPort = 3330
$InputlocalPort = Read-Host -Prompt "Enter Local Port [?] Help (default is '$localPort')";
if ($InputlocalPort) {
  $localPort = $InputlocalPort
}
Write-Host "`u{2728} Local Port: $localPort" -ForegroundColor green
""
#####################################################
Write-Host " Retrieving Instance Id" -ForegroundColor white
$Instances = aws ssm --profile $Prof describe-instance-information --output text --query "InstanceInformationList[*].[InstanceId]" --filters "Key=tag:Name,Values=oov7-stack/OOV7ASG";
if (!$Instances) {
  "`u{1F6D1} No Instance"
  return
}
$InstanceId = ($Instances -split '\n')[0]
Write-Host "`u{2728} $InstanceId" -ForegroundColor green
""
#####################################################
$RdsInstances = aws rds --profile $Prof describe-db-instances --query 'DBInstances[*].[Endpoint.[Address]]' --output text;
if (!$RdsInstances) {
  "`u{1F6D1} No RDS Instance"
  return
}
"RDS Instance List:"
$RdsInstances
""
$RdsInstancesId = ($RdsInstances -split '\n')[0]
$RdsInputInstanceId = ""
$RdsInputInstanceId = Read-Host -Prompt "Enter RDS Instance [?] Help (default is '$RdsInstancesId')";
if ($RdsInputInstanceId) {
  $RdsInstancesId = $RdsInputInstanceId
}
Write-Host "`u{2705} Tunneling..." -ForegroundColor green
Write-Host "`u{2728} $RdsInstancesId 3306" -ForegroundColor green
#####################################################
$param = "{""host"":[""$RdsInstancesId""], ""portNumber"":[""3306""], ""localPortNumber"":[""$localPort""]}"
aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters $param --profile $Prof

# aws ssm start-session --target $InstanceId --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"host":[".$RdsInstancesId."], "portNumber":["3306"], "localPortNumber":["3331"]}' --profile $Prof
