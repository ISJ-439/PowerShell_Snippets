##### CurTime: Returns a timestamp (v3)
function CurTime(){
    <# Get Date UFormats
    foreach($fe_Letter in $($( 65..90 | % {"$([char]$_)"} ) + $( 97..122 | % {"$([char]$_)"} ))){if($(Get-Date -UFormat "%$fe_Letter") -ne $fe_Letter){Write-Host -fo yellow "[ $fe_Letter ] " -NoNewline;Get-Date -UFormat "%$fe_Letter"}}
    foreach($fe_Letter in $($( 65..90 | % {"$([char]$_)"} ) + $( 97..122 | % {"$([char]$_)"} ))){if($(Get-Date -Format "%$fe_Letter") -ne $fe_Letter){Write-Host -fo yellow "[ $fe_Letter ] " -NoNewline;Get-Date -Format "%$fe_Letter"}}
    #>
    [string]$f_TimeSTR = $(Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
    return $f_TimeSTR
}
