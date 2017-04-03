cls
Remove-Variable crypto_PlainTextKey,crypto_Text,crypto_Hash,scriptHashKey -ErrorAction SilentlyContinue

# This attribute is a system default and will cause the script to be much more verbose.
# $VerbosePreference = 'Continue'

# This attribute is a system default and will cause the script to not be verbose.
# $VerbosePreference = 'SilentlyContinue'

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

##### Get Encrypted Text (v2)
function Get-EncryptedText([string]$f_crypto_Hash){
### Returns: A string containing the un-encrypted input.
### Author:  Adam Theriault (adam.theriault@telus.com or adamther@gmail.com)
### Usage:   This function will take a SecureString hash generated with a key and translate it to plan text.
### Source:  https://social.technet.microsoft.com/wiki/contents/articles/4546.working-with-passwords-secure-strings-and-credentials-in-windows-powershell.aspx
### Notes:   The source explains how to use secure strings on a host, however to make the string portable you must use the -Key paramiter with a 128,192,256 bit key. It is possible to sue the cryptographic provider "System.Security.Cryptography.SHA256CryptoServiceProvider" as the New-Object however int his method we may use the exported onbject as a secure string and use it within windows credentials as prompted.
	
	[string]$f_FunctName = 'Get-EncryptedText'
    #Request the key from user and detect errors
    function GetKeyFromUser{
        # To verify key works
        function TestKey([string]$f_TKPassToTest){
            Write-Verbose "[$f_FunctName] Testing Key Provided"
            [string]$f_TestHash = '76492d1116743f0423413b16050a5345MgB8AFgARABUAEYARwBQAHkAUQA3AGQAeABvADgAMQBBAGMAWQB4AEoAdgB4AHcAPQA9AHwAZABjADIAZABkADgAYgAyAGUANQBkADAAYQA1AGEAOQBhAGEAMQBiADEAOAAyADEAMgA1ADIANwA1AGEAYgBhADQAZQAwADcAYgAxADQAMAA5ADIAMQBmADcAYQAyADcAOQAyAGQAMgA0ADEANQA1AGYANgBjAGEAMAA2AGUAMQA='
            [string]$f_ExpectedResult = 'CryptoWorks'
            try{
                $f_SecureTestCode1 = $f_TKPassToTest | ConvertTo-SecureString -AsPlainText -Force
                $f_SecureTestCode2 = ConvertTo-SecureString -SecureKey $f_SecureTestCode1 -String $f_TestHash -ErrorAction SilentlyContinue
                [bool]$f_TKResult = (([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($f_SecureTestCode2))) -eq $f_ExpectedResult)
            }
            catch{
                [bool]$f_TKResult = $false
            }
            return $f_TKResult
        }
        if(!$scriptHashKey){
            # Check if key exists, if is true if not
            function RequestKeyWithPrompt{
                Write-Verbose "[$f_FunctName] Key not present, obtaining key from user." 
                # Prompt for key/password
                [string]$crypto_PlaintextKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host -Prompt "Input secret key (16 Carecters long only)" -AsSecureString)))
                # Check is key is 16 chars long (It must be 16) or if the cancle buttion is pressed.
                if ($crypto_PlaintextKey.length -ne 16){
                    Write-Host "Wrong key length! Key was $($crypto_PlaintextKey.length) charecters long, please try again." -fo Red
                    GetKeyFromUser
                }
                elseif(!(TestKey($crypto_PlaintextKey))){
                    Write-Host "Incorrect key, please try again." -fo Red
                    GetKeyFromUser
                }
                elseif((TestKey($crypto_PlaintextKey))){
                    Write-Verbose "[$f_FunctName] Key provided is correct and verified."
                    return $crypto_PlaintextKey
                }
                else{
                    Write-Host "KEY FAILURE! STOPPING!" -fo Red
                    break
                }
            }
            Write-Verbose "[$f_FunctName] Creating secure variable to use."
            # Set script hash key
            New-Variable -Scope 'global' -Name 'scriptHashKey' -Value ($(RequestKeyWithPrompt) | ConvertTo-SecureString -AsPlainText -Force) -Force
            # This removes the unsecured password from memory after overwriting the memory allocated
            Write-Verbose "[$f_FunctName] Removing plain text password from memory."
            $crypto_PlaintextKey = "##########################################"
            Remove-Variable crypto_PlaintextKey -ErrorAction SilentlyContinue
        }
    }
    # Call the key function to check if key is present and valid and if not, request the key.
    GetKeyFromUser

    # Decrypt the string
    Write-Verbose "[$f_FunctName] Input Hash: $f_crypto_Hash" 
    [string]$crypto_Plaintext = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
                (ConvertTo-SecureString -SecureKey $global:scriptHashKey -String $f_crypto_Hash)
            )
    )
    # Return the string of decrypted text for the fucntion
    Write-Verbose "[$f_FunctName] PlainText Output: $crypto_Plaintext"
    return $crypto_Plaintext
}

############ Testing Lines Below

# Sets the string to Test123, this will not be show in the output
$SecureText = Set-EncryptedText "Test123"

# Removed the key and all other variables from memory
Remove-Variable crypto_PlainTextKey,crypto_Text,crypto_Hash,scriptHashKey -ErrorAction SilentlyContinue

# Read the text, a key will be needed to be retyped.
Get-EncryptedText $SecureText