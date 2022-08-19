$stg = New-Object System.Management.Automation.Host.ChoiceDescription '&Staging', 'Staging '
$prd = New-Object System.Management.Automation.Host.ChoiceDescription '&Production', 'Production'
$dev = New-Object System.Management.Automation.Host.ChoiceDescription '&Development', 'Development'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($stg, $prd, $dev)
$title = 'Connect to server'
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
$OoInstanceId = Read-Host -Prompt 'Enter Instance Id';
$Port = Read-Host -Prompt 'Enter Port';
""
Write-Host "`u{2705} Tunneling ${OoInstanceId}:${Port}" -ForegroundColor green
$Host.UI.RawUI.WindowTitle = "${OoInstanceId}:${Port}"
$INSTANCE=$OoInstanceId;$INST_PORT=$Port;$LOCAL_PORT=$Port
aws ssm start-session --profile $Prof --target "${INSTANCE}" --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=${LOCAL_PORT},portNumber=${INST_PORT}"

