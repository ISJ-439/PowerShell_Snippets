# Retrive the name of file from user (v1)
function SaveFileDialog([string]$f_Title = "Enter File Name:", [string]$f_InitialDir = 'Desktop', `
                        [string]$f_ExpectedName = ''){
    # All multi-values are semi-colan seperated
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath($f_InitialDir)
        Title = $f_Title
        FileName = $f_ExpectedName
    }
    [void]$SaveFileDialog.ShowDialog()
    return $SaveFileDialog.FileName
}