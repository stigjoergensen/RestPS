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
        This will return $null if not validated, can be used as a boolen.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [Parameter()][String]$RestPSLocalRoot = "c:\RestPS",
        [Parameter()][String]$URL = $null,
        [Parameter()][Bool]$VerifyClientIP
    )
	
    $script:IPACL = $null
    if ($VerifyClientIP -eq $true)
    {
        . $RestPSLocalRoot\bin\Get-RestIPAuth.ps1
        $RestIPAuth = (Get-RestIPAuth)
        $RequesterIP = $script:Request.RemoteEndPoint
        if ($null -ne $RestIPAuth)
        {
            # make sure local request is 127.0.0.1
            :LocalIP foreach ($IP in Get-NetIpAddress)
            {
                if ($IP.IPAddress -eq $RequesterIP.Address)
                {
                    $RequesterIP.Address = 16777343
                    break :LocalIP
                }
            }

            if ($RestIPAuth.EnableACL)
            {
                $ipAcl = Get-CachedJson -FilePath ([IO.Path]::Combine($RestPSLocalRoot, "endpoints\ipACL.json"))
                if ($ACL = $ipACL."$($RequesterIP.Address.IPAddressToString)")
                {
                    :IPCheck foreach ($Path in $ACL.Path)
                    {
                        if ($URL.toLower().StartsWith($Path))
                        {
                            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP"
                            $script:IPACL = $ACL
                            break :IPCheck
                        }
                    }
                }
                else
                {
                    if ($RestIPAuth.EnableIPLists)
                    {
                        :ListCheck foreach ($ACL in $ipACL)
                        {
                            foreach ($IP in (($ACL.Name) -split "," ))
                            {
                                if ($RequesterIP.Address.IPAddressToString -eq $IP)
                                {
                                    foreach ($Path in $ACL.Path)
                                    {
                                        if ($URL.toLower().StartsWith($Path))
                                        {
                                            Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP in List $($ACL.Name)"
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
                        :SubnetCheck foreach ($ACL in $ipACL)
                        {
                            [System.Net.IPAddress]$NetworkAdr, [integer]$NetworkLen = $ACL.Name -split ("/")
                            [System.Net.IPAddress]$SubnetMask = ([UInt32]::MaxValue) -shl (32 - $NetworkLen) -shr (32 - $NetworkLen)
                            if ($NetworkAdr.Address -eq ($RequesterIP.Address -band $SubnetMask.Address))
                            {
                                foreach ($Path in $ACL.Path)
                                {
                                    if ($URL.toLower().StartsWith($Path))
                                    {
                                        Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP in subnet $($ACL.Name)"
                                        $script:IPACL = $ACL
                                        Break :SubnetCheck
                                    }
                                }
                            }
                        }
                    }
                }
                $script:VerifyStatus = ($null -ne $script:IPACL)
                $script:IPACL
            }
            else # not $RestIPAuth.EnableACL
            {
                $RequesterIP, $RequesterPort = $RequesterIP -split (":")
                $RequesterStatus = $RestIPAuth | Where-Object { ($_.IP -eq "$RequesterIP") }
                if (($RequesterStatus | Measure-Object).Count -eq 1)
                {
                    Write-Log -LogFile $Logfile -LogLevel $logLevel -MsgType INFO -Message "Invoke-ValidateIP: Valid Client IP"
                    $script:VerifyStatus = $true
                }
                else
                {
                    $script:VerifyStatus = $false
                }
            }

        }
    }
}
