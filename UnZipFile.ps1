# Unzip a file to a folder (v2)
function UnZipFile([string]$InFile, [string]$OutPath){
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    try{[System.IO.Compression.ZipFile]::ExtractToDirectory($InFile, $OutPath)}
    catch{Write-Host "WARNING: Unzip Failure!"}
}