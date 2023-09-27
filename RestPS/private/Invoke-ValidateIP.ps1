function Invoke-ValidateIP
{
    <#
    .DESCRIPTION
        This function provides several way to validate or authenticate a client base on acceptable IP's.
    .PARAMETER RestPSLocalRoot
        The RestPSLocalRoot is also optional, and defaults to "C:\RestPS"
    .PARAMETER VerifyClientIP
        A VerifyClientIP is optional - Accepted values are:$false or $true
    .PARAMETER Url
        Url is optional - Checks if URL is in the ACL list gotten from Get-RestIPAuth.ACL
    .OUTPUTS
        The IPACL entry found to be valid for the validation
    .EXAMPLE
        Invoke-ValidateIP -VerifyClientIP $true -RestPSLocalRoot c:\RestPS
    .NOTES
        This will return a boolean.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter()][String]$RestPSLocalRoot = "c:\RestPS",
        [Parameter()][String]$URL = $null,
        [Parameter()][Bool]$VerifyClientIP
    )

    #$NetworkAdr, $NetworkLen = "123.123.123.123/24" -split ("/")	
    #[System.Net.IPAddress]$SubnetMask = ([UInt32]::MaxValue) -shl (32 - $NetworkLen) -shr (32 - $NetworkLen)
    #$NetworkAdr.Address -eq ($RequesterIP.Address -band $SubnetMask.Address)

    #[System.Net.IPAddress]$IPAddress = '172.20.76.5'
    #[System.Net.IPAddress]$Subnet = "172.20.76.0"
    #[System.Net.IPAddress]$SubnetMask = "255.255.254.0"
	
	
    if ($VerifyClientIP -eq $true)
    {
        . $RestPSLocalRoot\bin\Get-RestIPAuth.ps1
        $RestIPAuth = (Get-RestIPAuth).UserIP
        $RequesterIP = $script:Request.RemoteEndPoint
        if ($null -ne $RestIPAuth)
        {
            [System.Net.IPAddress]$RequesterIP, $RequesterPort = $RequesterIP -split (":")
            if (Get-NetIPAddress -IPAddress $RequesterIP -ErrorAction Ignore)
            {
                [System.Net.IPAddress]$RequesterIP = "127.0.0.1"
            }

            $script:VerifyStatus = $false
	    $script:IPACL = $null
            if ($RestIPAuth.ACL."$($RequesterIP.Address)")
            {
                :IPCheck foreach ($Path in $ACL.Path)
                {
                    if ($URL.toLower().StartsWith($Path))
                    {
                        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP"
                        $script:VerifyStatus = $true
			$script:IPACL = $ACL
                        break :IPCheck
                    }
                }
            }
            else
            {
                if ($RestIPAuth.EnableIPLists)
                {
                    :ListCheck foreach ($ACL in $RestIPAuth.ACL)
                    {
                        foreach ($IP in (($ACL.Name) -split "," ))
                        {
                            if ($RequesterIP -eq $IP)
                            {
                                foreach ($Path in $ACL.Path)
                                {
                                    if ($URL.toLower().StartsWith($Path))
                                    {
                                        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP in List $($ACL.Name)"
                                        $script:VerifyStatus = $true
					$script:IPACL = $ACL
                                        Break :ListCheck
                                    }
                                }
                            }
                        }
                    }
                }
                if (($RestIPAuth.EnableSubnetSearch) -and !($script:VerifyStatus))
                {
                    :SubnetCheck foreach ($ACL in $RestIPAuth.ACL)
                    {
                        [System.Net.IPAddress]$NetworkAdr, [integer]$NetworkLen = $ACL.Name -split ("/")
                        [System.Net.IPAddress]$SubnetMask = ([UInt32]::MaxValue) -shl (32 - $NetworkLen) -shr (32 - $NetworkLen)
                        if ($NetworkAdr.Address -eq ($RequesterIP.Address -band $SubnetMask.Address))
                        {
                            foreach ($Path in $ACL.Path)
                            {
                                if ($URL.toLower().StartsWith($Path))
                                {
                                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP in subnet $($NetworkAdr.Address)/$($NetworkLen)"
                                    $script:VerifyStatus = $true
                                    $script:IPACL = $ACL
                                    Break :SubnetCheck
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    #$script:VerifyStatus
    $script:IPACL
}
