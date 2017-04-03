### Setting the ACL of a registery key. IE. -RegKey "HKLM:\TEST" (v1)
function Set-AdministratorsGroupAccessToRegisteryKey([string]$KeyRoot,[string]$KeyName){
    # Compose Key:
    $KeyPath = "$KeyRoot\$KeyName"

    # Common user identies and groups
    $objUser_System         = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::LocalSystemSid, $null)
    $objUser_NetworkService = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::NetworkServiceSid, $null)
    $objUser_Administrators = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid, $null)
    $objUser_Users          = New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinUsersSid, $null)
    
    # Test if key exists
    if(Test-Path $KeyPath)
    {
        Write-Host "Key exists, changing ACL..." -fo Green
        $objACL = Get-Acl $KeyPath

        $objACL.SetOwner($objUser_Administrators)
        Set-Acl $KeyPath $objACL

        $objACL.AddAccessRule(
            $(New-Object System.Security.AccessControl.RegistryAccessRule `
                'Builtin\Administrators',`
                'FullControl',`
                'Allow'
            )
        )
        Set-Acl $KeyPath $objACL
    }
    
    # Key does not exist
    else{
        Write-Host "$KeyPath does not exist. Creating..." -fo Red
        New-Item -Path $KeyRoot -Name $KeyName –Force
        if(Test-Path $KeyPath)
        {
            Write-Host "Key exists, changing ACL..." -fo Green
            $objACL = Get-Acl $KeyPath

            $objACL.SetOwner($objUser_Administrators)
            Set-Acl $KeyPath $objACL

            $objACL.AddAccessRule(
                $(New-Object System.Security.AccessControl.RegistryAccessRule `
                    'Builtin\Administrators',`
                    'FullControl',`
                    'Allow'
                )
            )
            Set-Acl $KeyPath $objACL
        }
        else{
            Write-Host "Unable to create key $KeyPath. Exiting..." -fo Red
        }
    }
}

Set-AdministratorsGroupAccessToRegisteryKey -KeyRoot "HKLM:\SOFTWARE" -KeyName "TEST2"