$script:ModuleName = 'RestPS'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-StopListener function for $script:ModuleName" -Tags Build {
    $listener = [System.Net.HttpListener]::new()
    $listener = $listener
    function Write-Output {}
    Mock -CommandName 'Write-Output' -MockWith {}
    It "Should return null." {
        Invoke-StopListener | Should be $null
        Assert-MockCalled -CommandName 'Write-Output' -Times 1 -Exactly
    }
}