##### Write to CLI in color function (v1)
Function Write-Color{
	<#
	.SYNOPSIS
		Enables support to write multiple color text on a single line
	.DESCRIPTION
		Users color codes to enable support to write multiple color text on a single line
	.PARAMETER text
		Mandatory. Line of text to write
	.INPUTS
		[string]$text
	.OUTPUTS
		None
	.NOTES
		Version:        1.0
		Author:         Brian Clark
		Creation Date:  01/21/2017
		Purpose/Change: Initial function development
	.EXAMPLE
		Write-Color "Hey look ^crThis is red ^cgAnd this is green!"

	^cn = Normal Output Color
	^ck = Black
	^cb = Blue
	^cc = Cyan
	^ce = Grey
	^cg = Green
	^cm = Magenta
	^cr = Red
	^cw = White
	^cy = Yellow
	^cB = DarkBlue
	^cC = DarkCyan
	^cE = DarkGrey
	^cG = DarkGreen
	^cM = DarkMagenta
	^cR = DarkRed
	^cY = DarkYellow [Unsupported in Powershell]
    #>    
 
	[CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)][string]$text
    )
    $blnstrStartsWithColor = $false
    $count = 1
    if (-not $text.Contains("^c")){Write-Host "$($text)";return}
    if ($text.Substring(0,2) -eq "^c") { $blnstrStartsWithColor = $true }
    $strArray = $text -split "\^c" 
    $strArray | % {
        if ($count -eq 1 -and $blnstrStartsWithColor -eq $false){Write-Host "$($_)" -NoNewline;$count++}
        elseif ($_.ToString().Length -eq 0){$count++}
        else{
            $char = $_.ToString().Substring(0,1)
            if ($char -clike "k"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Black}
            elseif ($char -clike "b"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Blue}
            elseif ($char -clike "c"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Cyan}
            elseif ($char -clike "B"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkBlue}
            elseif ($char -clike "C"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkCyan}
            elseif ($char -clike "E"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkGray}
            elseif ($char -clike "G"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkGreen}
            elseif ($char -clike "M"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkMagenta}
            elseif ($char -clike "R"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkRed}
            elseif ($char -clike "Y"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor DarkYellow}
            elseif ($char -clike "e"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Grey}
            elseif ($char -clike "g"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Green}
            elseif ($char -clike "m"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Magenta}
            elseif ($char -clike "r"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Red}
            elseif ($char -clike "w"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor White}
            elseif ($char -clike "y"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline -ForegroundColor Yellow}
            elseif ($char -clike "n"){Write-Host "$($_.ToString().Substring(1,$_.Length -1))" -NoNewline}
            else{Write-Host "$($_)" -NoNewline}
            if ($count -eq $strArray.Count){Write-Host "`r`n" -NoNewline}
            $count++
        }
    }
}