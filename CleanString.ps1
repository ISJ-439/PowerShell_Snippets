##### String Cleanup (v2)
function CleanString([string]$f_Input,[regex]$f_AcceptedChars="[^a-zA-Z0-9\.\;\\\/\`"\`'\n\r]"){
    return "($f_Input -replace $f_NormalChars)"
}