$asg = New-Object System.Management.Automation.Host.ChoiceDescription '&Asg', 'Asg (OO, API, & etc.)'
$cloud = New-Object System.Management.Automation.Host.ChoiceDescription '&Cloud', 'Cloud (CR, CA, Maps & etc.)'
$webserv = New-Object System.Management.Automation.Host.ChoiceDescription '&Webserv', 'Webserv (HQ & etc.)'
$optionsServer = [System.Management.Automation.Host.ChoiceDescription[]]($asg, $cloud, $webserv)
$titleServer = 'AWS EC2 server'
$messageServer = 'Select a server:'
$resultServer = $host.ui.PromptForChoice($titleServer, $messageServer, $optionsServer, 0)
switch ($resultServer) {
  0 { $serverName = "Asg"; $server = "oov7-stack/OOV7ASG" }
  1 { $serverName = "Cloud"; $server = "delit-avmh-web" }
  2 { $serverName = "Webserv"; $server = "dsoft-avmh-webserv-01" }
}
Write-Host "`u{2728} Server: $serverName (Name: $server)" -ForegroundColor green
""
$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging'
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$dev = New-Object System.Management.Automation.Host.ChoiceDescription '&Development', 'Development'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($dev, $stg, $prd)
$title = ""
$message = "Select AWS environment:"
$result = $host.ui.PromptForChoice($title, $message, $options, 0)
switch ($result) {
  0 { $Prof = "ditdev" }
  1 { $Prof = "default" }
  2 { $Prof = "ditstg" }
}
Write-Host "`u{2728} Environment: $Prof" -ForegroundColor green
""
$Instances = aws ec2 describe-instances --profile $Prof --output text --query "Reservations[*].Instances[*].InstanceId" --filter "Name=tag:Name,Values=$server*" "Name=instance-state-name,Values=running";

if (!$Instances) {
  "`u{1F6D1} No Instance"
  return
}

$InstanceNumber = ($Instances.Trim() -Split '\n').Count
"Instance Id/s ($InstanceNumber):"
$Instances
""
$InstanceId = ($Instances -split '\n')[0]
$InputInstanceId = ""
$InputInstanceId = Read-Host -Prompt "Enter Instance Id [?] Help (default is '$InstanceId')";
if ($InputInstanceId) {
  $InstanceId = $InputInstanceId
}
Write-Host "`u{2705} Connecting to $InstanceId" -ForegroundColor green

$Host.UI.RawUI.WindowTitle = "$serverName ($InstanceId)"

aws --profile $Prof ssm start-session --target $InstanceId