##### Read-XMLParam: Parse An XML Object (v1)
function Read-XMLParam ([int]$f_Lvl=0,[string]$f_PrefStr,$f_XMLObj,[string]$f_ExpResRgx){
    $f_XMLReturnStr = "$($f_XMLObj)"
    if($f_XMLReturnStr -match $f_ExpResRgx -and $f_XMLReturnStr -ne ""){
        Out-CLI -f_mSubj 'Loop>ReadXML' -f_mTxt "$("$SC"*$f_Lvl)$f_PrefStr$f_XMLReturnStr"
    }
    elseif ($f_ExpResRgx -eq "#EMPTY#" -and $f_XMLReturnStr -eq ""){
        Out-CLI -f_mSubj 'Loop>ReadXML' -f_mTxt "$("$SC"*$f_Lvl)$f_PrefStr$f_XMLReturnStr"
    }
    else{
        Out-CLI -f_mSubj 'Loop>ReadXML' -f_mTxt "$("$SC"*$f_Lvl)$f_PrefStr$f_XMLReturnStr !!!!! | Expected: '$f_ExpResRgx'" -f_mColor Red
    }
}
