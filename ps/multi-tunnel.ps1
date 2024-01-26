## ENVIRONMENT ######################################################
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

$InstanceId = ($Instances -split '\n')[0]
Write-Host "`u{2728} $InstanceId" -ForegroundColor green
""

## TUNNEL ALL ###############################################################
# Cloud DB 
# Writer
$cloudDbWriterDns = "cloud.local.deliverit.com.au"
$cloudLocalPort = 3320
# Read
$cloudDbReplicaDns = "cloud-read.local.deliverit.com.au"
$cloudLocalPortReplica = 3321

# OO DB
# Writer
$ooDbWriterDns = "rds.local.deliverit.com.au"
$ooLocalPort = 3330
# Read
$ooDbReplicaDns = "rds.replica.local.deliverit.com.au"
$ooLocalPortReplica = 3331

# REDIS
$redisDns = "redis.local.deliverit.com.au"
$redisLocalPort = 6380


$localHost = "127.0.0.1"
$delim = ":"
Write-Host "`u{2705} Tunneling" -ForegroundColor green
Write-Host "`OO DB ----------- $ooDbWriterDns ---------- $localHost$delim$ooLocalPort " -ForegroundColor green
Write-Host "`OO DB (read) ---- $ooDbReplicaDns -- $localHost$delim$ooLocalPortReplica" -ForegroundColor green
Write-Host "`Cloud DB -------- $cloudDbWriterDns -------- $localHost$delim$cloudLocalPort" -ForegroundColor green
Write-Host "`Cloud DB (read) - $cloudDbReplicaDns --- $localHost$delim$cloudLocalPortReplica" -ForegroundColor green
Write-Host "`OO Redis -------- $redisDns -------- $localHost$delim$redisLocalPort" -ForegroundColor green

## GET Instance ##############################################################
$server = "delit-avmh-web"
$Instances = aws ec2 describe-instances --profile $Prof --output text --query "Reservations[*].Instances[*].InstanceId" --filter "Name=tag:Name,Values=$server*" "Name=instance-state-name,Values=running";
$InstanceId = ($Instances -split '\n')[0]



## START Session #############################################################
# $prof $InstanceId $storageType $RdsInstancesId $tunnelPort $localPort

# OO db writer
wt --window 0 --title "$ooDbWriterDns$delim$ooLocalPort" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "rds" $ooDbWriterDns "3306" "$ooLocalPort"
# OO db read
wt --window 0 --title "$ooDbReplicaDns$delim$ooLocalPortReplica" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "rds" $ooDbWriterDns "3306" "$ooLocalPortReplica"

# Cloud db writer
wt --window 0 --title "$cloudDbWriterDns$delim$cloudLocalPort" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "rds" $cloudDbWriterDns "3306" "$cloudLocalPort"
# Cloud db read
wt --window 0 --title "$cloudDbReplicaDns$delim$cloudLocalPortReplica" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "rds" $cloudDbReplicaDns "3306" "$cloudLocalPortReplica"

# REDIS
wt --window 0 --title "$redisDns$delim$redisLocalPort" -d "$pwd" pwsh -noExit -File "runner.ps1" $Prof $InstanceId "redis" $redisDns "3378" "$redisLocalPort"

# Write-Host "$Prof $InstanceId rds $ooDbWriterDns $tunnelPort 3306" -ForegroundColor green