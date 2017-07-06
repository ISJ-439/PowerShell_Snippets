##### Set Encrypted Text (v1)
function Set-EncryptedText([string]$crypto_Text){
### Author: Adam Theriault (adam.theriault@telus.com or adamther@gmail.com)
### Usage:  This function will take a plain text string and translate it to a SecureString hash generated with a key.
### Source: https://social.technet.microsoft.com/wiki/contents/articles/4546.working-with-passwords-secure-strings-and-credentials-in-windows-powershell.aspx
### Notes:  The source explains how to use secure strings on a host, however to make the string portable you must use the -Key paramiter with a 128,192,256 bit key. It is possible to sue the cryptographic provider "System.Security.Cryptography.SHA256CryptoServiceProvider" as the New-Object however int his method we may use the exported onbject as a secure string and use it within windows credentials as prompted.

    # Check if key exists
    if(!$global:scriptHashKey){
       Write-Verbose "[Set-EncryptedText] Key not present, obtaining key from user." 
        # Prompt for key/password
        [string]$crypto_PlaintextKey = Read-Host -Prompt "Input secret key (16 Carecters long only)"
        # Check is key is 16 chars long (It must be 16)
        if ($crypto_PlaintextKey.length -ne 16){
            # Repeat request if not 16 chars long
            While($crypto_PlaintextKey.length -ne 16){
                Write-Host "Wrong key length! Key was ["$crypto_PlaintextKey.length"] charecters long, please try again." -fo red
                [string]$crypto_PlaintextKey = Read-Host -Prompt "Input secret key (16 Carecters long only)"
            }
        }
        # Set script hash key
        $global:scriptHashKey = $crypto_PlaintextKey | ConvertTo-SecureString -AsPlainText -Force
        # This removed the unsecured password from memory
        Remove-Variable PlainTextKey -ErrorAction SilentlyContinue
    }
    # Encrypt the string with the key provided
   Write-Verbose "[Set-EncryptedText] Encrypting Text: $crypto_Text" 
    [string]$crypto_SecuredText = $crypto_Text | ConvertTo-SecureString -AsPlainText -Force | `
        ConvertFrom-SecureString -SecureKey $global:scriptHashKey
    # Return the string of encrypted text for the fucntion
   Write-Verbose "[Set-EncryptedText] Encrypted Output Finished: $crypto_SecuredText"
    return $crypto_SecuredText
}
