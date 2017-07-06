##### Get-PaloAltoLogs: Get the logs from the host's API call (v2)
function Get-PaloAltoLogs([string]$f_FQDN, [string]$f_APIKey, [string]$f_LogType, $f_MaxCount, [string]$f_LogQuery){
    <#
    Types of logs avalible:
        traffic   for traffic logs
        threat    for threat logs
        config    for config logs
        system    for system logs
        hipmatch  for HIP logs
        wildfire  for WildFire logs
        url       for URL Filtering logs
        data      for Data Filtering logs
    
    The other optional parameters to this request are:
        &query='<WebUI like query>'    Specify match criteria for the logs. This is similar to the query provided in the WebUI under the Monitor tab when viewing the logs. The query must be URL encoded.
        &nlogs='<1-5000>'              Specify the number of logs to be retrieved. The default is 20 when the parameter is not specified. The maximum is 5000.
        &skip='<number>'               Specify the number of logs to skip when doing a log retrieval. The default is 0. This is useful when retrieving logs in batches where you can skip the previously retrieved logs.
    If $f_MaxCount is 'ALL' then it will recursivly download all logs avalible
    #>
    Remove-Variable "f_LogOutput", "f_JobID" -ErrorAction SilentlyContinue
    # No more than 5000 entries can be delivered
    if ($f_MaxCount -le 5000){
        # Create the query job
        [string]$f_JobID = (Invoke-WebRequest -Method Get `
            "https://$f_FQDN/api/?type=log&query=$f_LogQuery&nlogs=$f_MaxCount&log-type=$f_LogType&key=$f_APIKey") `
            -replace ".*(<job>)" -replace "(</job>.*)"

        Write-Host "Job ID: $f_JobID, retriving job status..."
        [xml]$f_LogOutput = Invoke-WebRequest -Method Get `
            "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"

        # Check over and over if the job is complete yet
        while("$(($f_LogOutput.Content -split "`n" | Select-String ".^*(<status>).*$") -replace ".*(<status>)" -replace "(</status>).*")" -notlike '*FIN*'){
                Write-Host "Logs not ready, $($f_LogOutput.response.result.log.logs.count) log entries detected,job progress is at $($f_LogOutput.response.result.log.logs.progress)%, sleeping 3 seconds..."
                Start-Sleep -Seconds 3
                Write-Host "Retriving job status..."
                [xml]$f_LogOutput = Invoke-WebRequest -Method Get "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"
                Write-Host "Jog Status: $($f_LogOutput.response.job.status)"
        }
        Write-Host "Logs ready, $($f_LogOutput.response.result.log.logs.count) log entries detected."
        return $f_LogOutput
    }
    elseif ($f_MaxCount -eq 'ALL'){
        Remove-Variable f_LogOutput,f_LogCatOutput,f_LoopLogCount,f_CurrentCount -ErrorAction SilentlyContinue
        $f_MaxCount = 5000
        $f_CurrentCount = 0
        $f_EOL = $false
        while($f_EOL -eq $false){
            # Create the query job
            Write-Host "Creating the job."
            [string]$f_JobID = (Invoke-WebRequest -Method Get `
                "https://$f_FQDN/api/?type=log&skip=$f_CurrentCount&query=$f_LogQuery&nlogs=$f_MaxCount&log-type=$f_LogType&key=$f_APIKey") `
                -replace ".*(<job>)" -replace "(</job>.*)"

            Write-Host "Job ID: $f_JobID, retriving job status..."
            [xml]$f_LogOutput = Invoke-WebRequest -Method Get `
                "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"

           # $y = $f_LogOutput

            # Check over and over if the job is complete yet
            while("$(($f_LogOutput.Content -split "`n" | Select-String ".^*(<status>).*$") -replace ".*(<status>)" -replace "(</status>).*")" -notlike '*FIN*'){
                Write-Host "Logs not ready, $($f_LogOutput.response.result.log.logs.count) log entries detected,job progress is at $($f_LogOutput.response.result.log.logs.progress)%, sleeping 3 seconds..."
                Start-Sleep -Seconds 3
                Write-Host "Retriving job status..."
                [xml]$f_LogOutput = Invoke-WebRequest -Method Get "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"
                #$x = $f_LogOutput.response
                #break
                Write-Host "Jog Status: $($f_LogOutput.response.job.status)"
                Write-Host "1"
                $f_LogOutput | gm
                Write-Host "2"
                $f_LogOutput.response
                Write-Host "3"
                $f_LogOutput.response.job
                Write-Host "4"
                $f_LogOutput.response.job.status
            }
            $f_LogCatOutput += $f_LogOutput
            Remove-Variable "f_LogOutput"  -ErrorAction SilentlyContinue
            $f_LoopLogCount = [int]($f_LogOutput.response.result.log.logs.count)
            Write-Host $f_LoopLogCount -fo Green
            if($f_LoopLogCount -lt 5000){
                $f_EOL = $true
            }
            $f_CurrentCount += $f_LoopLogCount
            Write-Host "Current Logs Downloaded: $f_CurrentCount"
        }
        Write-Host "Logs ready, $($f_CurrentCount) log entries detected."
        return $f_LogCatOutput
    }
    else{
        Write-Host "INVALID MaxCount" -fo Red
    }
}
