##### Test-TCPPortConnection: Test a TCP Port (v1)
function Test-TCPPortConnection {
<#
.SYNOPSIS
Test the response of a computer to a specific TCP port

.DESCRIPTION
Test the response of a computer to a specific TCP port

.PARAMETER  ComputerName
Name of the computer to test the response for

.PARAMETER  Port
TCP Port number(s) to test

.INPUTS
System.String.
System.Int.

.OUTPUTS
None

.EXAMPLE
PS C:\> Test-TCPPortConnection -ComputerName Server01

.EXAMPLE
PS C:\> Get-Content Servers.txt | Test-TCPPortConnection -Port 22,443
#>

    [CmdletBinding()][OutputType('System.Management.Automation.PSObject')]

    param(
    [Parameter(Position=0,Mandatory=$true,HelpMessage="Name of the computer to test",
    	ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
    	[Alias('CN','__SERVER','IPAddress','Server')]
    	[String[]]$ComputerName,
    
    	[Parameter(Position=1)]
    	[ValidateRange(1,65535)]
    	[Int[]]$Port = 3389
    )
    
    begin {
    	$TCPObject = @()
    }

    process {
    	foreach ($Computer in $ComputerName){
            foreach ($TCPPort in $Port){
    	        $Connection = New-Object Net.Sockets.TcpClient
    	        try{
    	            $Connection.Connect($Computer,$TCPPort)
    	            if ($Connection.Connected){
                        $Response = “Open”
    	                $Connection.Close()
    	            }
    	        }
    	        catch [System.Management.Automation.MethodInvocationException]{
    	            $Response = “Closed / Filtered”
    	        }
    	        $Connection = $null
    	        $hash = @{
    	            ComputerName = $Computer
    	            Port = $TCPPort
    	            Response = $Response
    	        }
    	        $Object = New-Object PSObject -Property $hash
    	        $TCPObject += $Object
    	    }
    	}
    }

    end {
        Write-Output $TCPObject
    }
}
