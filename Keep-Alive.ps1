# v1
$StartTime = Get-Date
while($true){
  Start-Sleep -Seconds 600
  $x = New-Object -ComObject WScript.Shell
  $x.SendKeys('^');$CurTime = Get-Date
  $TimeSpan = New-TimeSpan -Start $StartTime -End $CurTime
  Write-Host "Still running after" $TimeSpan.Days "Days" $TimeSpan.Hours "Hours" $TimeSpan.Minutes "Minutes..."
}
