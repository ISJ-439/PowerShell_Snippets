##### Get-PaloAltoAPICall: Run a customizable API Call (v2)
function Get-PaloAltoAPICall([string]$f_FQDN, [string]$f_APIKey, [string]$f_APIQuery){
    <#
    If $f_MaxCount is 'ALL' then it will recursivly download all logs avalible
    #>
    Remove-Variable "f_CallOutput", "f_JobID" -ErrorAction SilentlyContinue
    # No more than 5000 entries can be delivered
    if ($f_MaxCount -le 5000){
        # Create the query job
       Write-Verbose "Starting Job on Device: $f_FQDN"
        [string]$f_JobID = (Invoke-WebRequest -Method Get "https://$f_FQDN/api/?$f_APIQuery&key=$f_APIKey") -replace ".*(<job>)" -replace "(</job>.*)"
        Write-Host "Done, waiting 3 seconds" -No; Start-Sleep -sec 1; Write-Host "." -No; Start-Sleep -sec 1; Write-Host "." -No; Start-Sleep -sec 1; Write-Host "."
        # Initial check if job is ready after a moment pause.
        Write-Host "Job ID: $f_JobID, retriving job status..."
        [xml]$f_CallOutput = Invoke-WebRequest -Method Get "https://$f_FQDN/api/?action=get&job-id=$f_JobID&key=$f_APIKey"

        # Check over and over if the job is complete yet
        while("$(($f_LogOutput.Content -split "`n" | Select-String ".^*(<status>).*$") -replace ".*(<status>)" -replace "(</status>).*")" -notlike '*ACT*'){
            Write-Host "Logs not ready, $($f_CallOutput.response.result.log.logs.count) log entries detected, progress is at $($f_CallOutput.response.result.log.logs.progress)%, sleeping 3 seconds" -No
            Start-Sleep -sec 1; Write-Host "." -No; Start-Sleep -sec 1; Write-Host "." -No; Start-Sleep -sec 1; Write-Host "."
            Write-Host "Retriving job status..."
            [xml]$f_CallOutput = Invoke-WebRequest -Method Get "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"
            Write-Host "Job status: $(($f_LogOutput.Content -split "`n" | Select-String ".^*(<status>).*$") -replace ".*(<status>)" -replace "(</status>).*")"
        }
        Write-Host "Logs ready, $($f_CallOutput.response.result.log.logs.count) log entries detected."
        return $f_CallOutput
    }
    elseif ($f_MaxCount -eq 'ALL'){
        Remove-Variable "f_CallOutput","f_LogCatOutput","f_LoopLogCount","f_CurrentCount" -ErrorAction SilentlyContinue
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
            [xml]$f_CallOutput = Invoke-WebRequest -Method Get `
                "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"

           # $y = $f_LogOutput

            # Check over and over if the job is complete yet
            while("$(($f_LogOutput.Content -split "`n" | Select-String ".^*(<status>).*$") -replace ".*(<status>)" -replace "(</status>).*")" -notlike '*FIN*'){
                Write-Host "Logs not ready, $($f_CallOutput.response.result.log.logs.count) log entries detected,job progress is at $($f_CallOutput.response.result.log.logs.progress)%, sleeping 3 seconds..."
                Start-Sleep -Seconds 3
                Write-Host "Retriving job status..."
                [xml]$f_CallOutput = Invoke-WebRequest -Method Get "https://$f_FQDN/api/?type=log&action=get&job-id=$f_JobID&key=$f_APIKey"
                #$x = $f_LogOutput.response
                #break
                Write-Host "Jog Status: $($f_CallOutput.response.job.status)"
                $f_CallOutput.response.job
            }
            $f_LogCatOutput += $f_CallOutput
            Remove-Variable "f_CallOutput" -ErrorAction SilentlyContinue
            $f_LoopLogCount = [int]($f_CallOutput.response.result.log.logs.count)
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
