# Retrive the name of files selected (v1)
function GetFileDialog( [string]$f_Title = "Select File:", [string]$f_InitialDir = 'Desktop', `
                        [bool]$f_Multiselect = $true,[string]$f_Filter = 'All (*.*)|*.*', `
                        [string]$f_ExpectedName = ''){
    # All multi-values are semi-colan seperated
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath($f_InitialDir)
        Multiselect = $f_Multiselect
        Title = $f_Title
        Filter = $f_Filter
        FileName = $f_ExpectedName
    }
    [void]$FileBrowser.ShowDialog()
    return $FileBrowser.FileNames
}