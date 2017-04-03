﻿##### Send-SYSLOG (v2) - Based on https://github.com/poshsecurity/Posh-Syslog
#requires -Version 2 #-Modules NetTCPIP
enum Syslog_Facility
{
	kern
	user
	mail
	daemon
	auth
	syslog
	lpr
	news
	uucp
	clock
	authpriv
	ftp
	ntp
	logaudit
	logalert
	cron
	local0
	local1
	local2
	local3
	local4
	local5
	local6
	local7
}

enum Syslog_Severity
{
	Emergency
	Alert
	Critical
	Error
	Warning
	Notice
	Informational
	Debug
}

function Send-SYSLOG
{
    [CMDLetBinding(DefaultParameterSetName = 'RFC5424')]
    Param
    (
        #Destination SYSLOG server that message is to be sent to.
        [Parameter(mandatory   = $true,
                   HelpMessage = 'Server to send message to')]
        [ValidateNotNullOrEmpty()]
        [String] 
        $Server,
	
        #Our message or content that we want to send to the server. This is option in RFC 5424, the CMDLet still has this as a madatory parameter, to send no message, simply specifiy '-' (as per RFC).
        [Parameter(mandatory   = $true,
                   HelpMessage = 'Message to send')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,
	
        #Severity level as defined in SYSLOG specification, must be of ENUM type Syslog_Severity
        [Parameter(mandatory   = $true,
                   HelpMessage = 'Messsage severity level')]
        [ValidateNotNullOrEmpty()]
        [Syslog_Severity]
        $Severity,
	
        #Facility of message as defined in SYSLOG specification, must be of ENUM type Syslog_Facility
        [Parameter(mandatory   = $true,
                   HelpMessage = 'Facility sending message')]
        [ValidateNotNullOrEmpty()]
        [Syslog_Facility] 
        $Facility,
	
        #Hostname of machine the mssage is about, if not specified, RFC 5425 selection rules will be followed.
        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Hostname = '',
	
        #Specify the name of the application or script that is sending the mesage. If not specified, will select the ScriptName, or if empty, powershell.exe will be sent. To send Null, specify '-' to meet RFC 5424. 
        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ApplicationName = '',
	
        #ProcessID or PID of generator of message. Will automatically use $PID global variable. If you want to override this and send null, specify '-' to meet RFC 5424 rquirements. This is only sent for RFC 5424 messages.
        [Parameter(mandatory = $false, 
                   ParameterSetName = 'RFC5424')]
        [ValidateNotNullOrEmpty()]
        [String]
        $ProcessID = $PID,
	
        #Error message or troubleshooting number associated with the message being sent. If you want to override this and send null, specify '-' to meet RFC 5424 rquirements. This is only sent for RFC 5424 messages.
        [Parameter(mandatory = $false, 
                   ParameterSetName = 'RFC5424')]
        [ValidateNotNullOrEmpty()]
        [String]
        $MessageID = '-',
	
        #Key Pairs of structured data as a string as defined in RFC5424. Default will be '-' which means null. This is only sent for RFC 5424 messages.
        [Parameter(mandatory = $false, 
                   ParameterSetName = 'RFC5424')]
        [ValidateNotNullOrEmpty()]
        [String]
        $StructuredData = '-',
	
        #Time and date of the message, must be of type DateTime. Correct format will be selected depending on RFC requested. If not specified, will call get-date to get appropriate date time.
        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [DateTime] 
        $Timestamp = (Get-Date),
	
        #SYSLOG UDP port to send message to. Defaults to 514 if not specified.
        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,65535)]
        [UInt16]
        $UDPPort = 514,
	
        #Send an RFC3164 fomatted message instead of RFC5424.
        [Parameter(mandatory = $True,
                   ParameterSetName = 'RFC3164')]
        [switch]
        $RFC3164
    )

    # Evaluate the facility and severity based on the enum types
    $Facility_Number = $Facility.value__
    $Severity_Number = $Severity.value__
    Write-Verbose -Message "Syslog Facility, $Facility_Number, Severity is $Severity_Number"

    # Calculate the priority
    $Priority = ($Facility_Number * 8) + $Severity_Number
    Write-Verbose -Message "Priority is $Priority"

    <#
            Application name or process name, simply find out if a script is calling the CMDLet, else use PowerShell
    #>
    if ($ApplicationName -eq '')
    {
        if (($null -ne $myInvocation.ScriptName) -and ($myInvocation.ScriptName -ne ''))
        {
            $ApplicationName = Split-Path -Leaf -Path $myInvocation.ScriptName
        }
        else
        {
            $ApplicationName = 'PowerShell'
        }
    }

    <#
            According to RFC 5424, we need to send our hostname as one of these 5 (in order of priority)
            1.  FQDN
            2.  Static IP address
            3.  Hostname - Windows always has one of these, so this is our last resort
            4.  Dynamic IP address - We will never get to this one
            5.  the NILVALUE - or this one

            Windows should always, in the worst case, have a result at 3, the hostname or computer name of the system this command is run from.

            Taking this into account, then our logic, if no hostname is provided should be:
            1. Are we domain joined, if so, we have a FQDN
            2. Do we have any static ip allocations and can we ping or at least try to ping the SYSLOG server from an interface with a static ip address
                The elseif statement first determines if there are any interfaces with a static address, if there are, it does the ping, otherwise it returns false immediately.
                This is due to how PowerShell processes -and/-or/etc logic.
            3. The name of the computer
    #>
    if ($Hostname -eq '')
    {
        if ($null -ne $ENV:userdnsdomain)
        {
            # Option 1, FQDN
            $Hostname = $ENV:Computername + '.' + $ENV:userdnsdomain
        }
        elseif (($null -ne (Get-NetIPAddress -PrefixOrigin Manual -SuffixOrigin Manual -ErrorAction SilentlyContinue)) -and ((Test-NetConnection -ComputerName $Server -ErrorAction SilentlyContinue).SourceAddress.PrefixOrigin -eq 'Manual'))
        {
            # Option 2, Static IP address
            # ** Changes here as suggested by Brtlvrs **
            $Hostname = (Test-NetConnection -ComputerName $Server -ErrorAction SilentlyContinue).SourceAddress.IPAddress
        }
        else
        {
            # Option 3
            $Hostname = $ENV:Computername
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'RFC3164')
    {
        Write-Verbose -Message 'Using RFC 3164 UNIX/BSD message format'
        #Get the timestamp
        $FormattedTimestamp = (Get-Culture).TextInfo.ToTitleCase($Timestamp.ToString('MMM dd HH:mm:ss'))
        # Assemble the full syslog formatted Message
        $FullSyslogMessage = '<{0}>{1} {2} {3} {4}' -f $Priority, $FormattedTimestamp, $Hostname, $ApplicationName, $Message
    }
    else
    {
        Write-Verbose -Message 'Using RFC 5424 IETF message format'
        #Get the timestamp
        $FormattedTimestamp = $Timestamp.ToString('yyyy-MM-ddTHH:mm:ss.ffffffzzz')
        # Assemble the full syslog formatted Message
        $FullSyslogMessage = '<{0}>1 {1} {2} {3} {4} {5} {6} {7}' -f $Priority, $FormattedTimestamp, $Hostname, $ApplicationName, $ProcessID, $MessageID, $StructuredData, $Message
    }

    Write-Verbose -Message "Message to send will be $FullSyslogMessage"

    # create an ASCII Encoding object
    $Encoding = [System.Text.Encoding]::ASCII

    # Convert into byte array representation
    $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage)

    # If the message is too long, shorten it
    if ($ByteSyslogMessage.Length -gt 1024)
    {
        $ByteSyslogMessage = $Encoding.GetBytes($FullSyslogMessage.SubString(0, 1024))
    }

    # Create a UDP Client Object
    $UDPCLient = New-Object -TypeName System.Net.Sockets.UdpClient
    $UDPCLient.Connect($Server, $UDPPort)

    # Send the Message
    $null = $UDPCLient.Send($ByteSyslogMessage, $ByteSyslogMessage.Length)

    #Close the connection
    $UDPCLient.Close()
}