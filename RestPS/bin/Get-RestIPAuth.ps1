function Get-RestIPAuth
{
    $RestIPAuth = @{
        ACL                = @{
            "127.0.0.1"                  = @{
                Name = "Local host"
                Path = @("/")                   # Local host have access to everything
            }
            "192.168.22.18"              = @{
                Name = "Workstation 1"
                Path = @("/endpoint/shutdown", "/endpoint/status")
            }
            "192.168.22.5"               = @{
                Name = "Workstatation 2"
                Path = @("/a", "/b")
            }
            "192.168.22.5,192.168.22.18" = @{	# Define a comma list of IPs with access, needs to be enabled, see below
                Name = "Workstation 1 and 2"
                Path = @("/c", "/d")
            }
            "192.168.1.0/24"             = @{   # you are able to define a subnet with access, but subnetsearch must be enabled before it will work, see below
                Name = "Subnet 1"
                Path = @("/")
            }
            "192.168.7.0/24"             = @{   # you are able to define a subnet with access, but subnetsearch must be enabled before it will work, see below
                Name = "Subnet 7"
                Path = @("/a")
            }
        }
        EnableSubnetSearch = $false		# Enable subnet seach, this will take a performance hit, how big depends on the number of subnets in the ACL list.
        EnableIPList       = $false	    # Enable of comma list of ACL IPS, Cost a little performance. Consider this instead of subnets
    }
    $RestIPAuth
}
