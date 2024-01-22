## ✨ ENVIRONMENT ######################################################
$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging '
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$dev = New-Object System.Management.Automation.Host.ChoiceDescription '&Development', 'Development'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($dev, $stg, $prd)
$title = 'AWS Environment Role'
$message = 'Select AWS environment:'
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0 { $Prof = "ditdev" }
  1 { $Prof = "ditstg" }
  2 { $Prof = "default" }
}

Write-Host "`u{2728} Environment: $Prof" -ForegroundColor green
""

$Instances = "test"

$InstanceId = ($Instances -split '\n')[0]
Write-Host "`u{2728} $InstanceId" -ForegroundColor green
""


## ✨ TUNNEL ALL ###############################################################
# - OO DB 3320
$cloudLocalPort = 3320
$cloudLocalPortReplica = 3321
$ooLocalPort = 3330
$ooLocalPortReplica = 3331
$redisLocalPort = 6380

$cloudDbWriterDns = "cloud.local.deliverit.com.au"
$cloudDbReplicaDns = "cloud-read.local.deliverit.com.au"
$ooDbWriterDns = "rds.local.deliverit.com.au"
$ooDbReplicaDns = "rds.replica.local.deliverit.com.au"
$redisDns = "redis.local.deliverit.com.au"

$localHost = "127.0.0.1"
$delim = ":"
Write-Host "`u{2705} Tunneling" -ForegroundColor green
Write-Host "`OO DB ----------- $ooDbWriterDns ---------- $localHost$delim$ooLocalPort " -ForegroundColor green
Write-Host "`OO DB (read) ---- $ooDbReplicaDns -- $localHost$delim$ooLocalPortReplica" -ForegroundColor green
Write-Host "`Cloud DB -------- $cloudDbWriterDns -------- $localHost$delim$cloudLocalPort" -ForegroundColor green
Write-Host "`Cloud DB (read) - $cloudDbReplicaDns --- $localHost$delim$cloudLocalPortReplica" -ForegroundColor green
Write-Host "`OO Redis -------- $redisDns -------- $localHost$delim$redisLocalPort" -ForegroundColor green

## ✨ START Session #############################################################
# $prof $InstanceId $storageType $RdsInstancesId $tunnelPort $localPort
wt --window 0 --title "$ooDbWriterDns$delim$ooLocalPort" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "rds" $ooDbWriterDns $tunnelPort 3306
