##### Expand-XMLToString (v3)
function Expand-XMLToString ([System.Xml.XmlElement]$f_XMLSubsetInput,[xml]$f_XMLFullInput)
{
    if($f_XMLSubsetInput){
        $StringWriter = New-Object System.IO.StringWriter
        $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter
        $XmlWriter.Formatting = "indented"
        $f_XMLSubsetInput.WriteTo($XmlWriter);
        $XmlWriter.Flush()
        $StringWriter.Flush()
        return $StringWriter.ToString()
    }
    elseif($f_XMLFullInput){
        $StringWriter = New-Object System.IO.StringWriter
        $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter
        $XmlWriter.Formatting = "indented"
        $f_XMLFullInput.WriteTo($XmlWriter);
        $XmlWriter.Flush()
        $StringWriter.Flush()
        return $StringWriter.ToString()
    }
}
