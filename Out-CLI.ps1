##### Out-CLI: Write Verbose/Host details and log to disk (v12)
    # Logging folder
    # Declared at top #[string]$s_BaseLogFolder = 'C:\Users\t915320\Desktop\logs\PaloAlto_API_SingleCmdQueries'
    # Name of generic log file, set logging file here for background output
    $f_LoggingFile = "Parse-PaloAltoConfigs_Rolling_Logfile.log"
function Out-CLI($f_mSubj="N/A", $f_mTxt="N/A", $f_mColor='White', [switch]$f_Verbose=$false, [switch]$f_NoLog){
    if(!(Test-Path $s_BaseLogFolder)){
        Write-Warning "Creating logging folder: $s_BaseLogFolder"
        New-Item -ItemType Directory -Path (Split-Path $s_BaseLogFolder) -Name (Split-Path $s_BaseLogFolder -Leaf)
    }
    if($f_Verbose){
        if($VerbosePreference -eq 'Continue'){
           Write-Verbose "$(Get-Date -u "%H-%M-%S") [$($f_mSubj)] $($f_mTxt)"
        }
    }
    else{
        # Write the test to the CLI
        Write-Host "$(Get-Date -uF "%r") [" -NoNewline
        Write-Host "$($f_mSubj)" -NoNewline -Fo Gray
        Write-Host "] " -NoNewline
        Write-Host "$($f_mTxt)" -Fo $f_mColor
        # Create a formatted test string to export
    }
    if(!$f_NoLog){
            "$(CurTime) [$($f_mSubj)]  $($f_mTxt)" | Out-File -FilePath "$s_BaseLogFolder\$f_LoggingFile" -Append
    }
}
