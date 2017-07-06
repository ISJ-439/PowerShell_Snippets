# Retrive the folder a user wishes to use (v1)
function Get-FolderDialog([string]$f_Title = "Select Folder:", [string]$f_InitialDir = 'Desktop'){
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
        ShowNewFolderButton = $true
        Description = $f_Title
    }
    [void]$FolderBrowser.ShowDialog()
    return $FolderBrowser.SelectedPath
}
