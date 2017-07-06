##### Current date for timestamps (v3) [Function Req: OutCLI function] ( C:\Users\t915320\Desktop\logs\PaloAlto_API_Queries\2017\Jan\02\231020 ) 
function Get-LoggingFilePath(){
    [string]$s_ExtendedLogFolder = "$s_BaseLogFolder\$(Get-Date -uf "%Y")\$(Get-Date -Format MMM)\$(Get-Date -uf '%d')"
    if(Test-Path $s_ExtendedLogFolder){
      OutCLI -f_mTxt "Logging path exists `"$s_ExtendedLogFolder`"" -f_mSubj "Get-LoggingFilePath" -f_Verbose
    }
    else{
       OutCLI -f_mTxt "Logging path does not exist, creating folder `"$s_ExtendedLogFolder`"" -f_mSubj "Get-LoggingFilePath" -f_Verbose
        New-Item -Path $s_ExtendedLogFolder -ItemType Directory
    }
    return "$s_ExtendedLogFolder\$(Get-Date -UFormat "%H%M%S")"
}
