function Get-RestIPAuth
{
    $RestIPAuth = @{
        UserIP             = @(
            @{
                IP = '192.168.22.18'
            },
            @{
                IP = "192.168.22.5"
            }
        )
        EnableACL          = $true      # Enable the use of ipACL.json instead of using UserIP property
        EnableSubnetSearch = $false		# Enable subnet seach, this will take a performance hit, how big depends on the number of subnets in the ACL list.
        EnableIPList       = $false	    # Enable of comma list of ACL IPS, Cost a little performance. Consider this instead of subnets
    }
    $RestIPAuth
}
