<#
.SYNOPSIS
    Gets the Node version that is available in the current environment.
.DESCRIPTION
    This calls the node --version command if the command is available and
    returns a System.Version representing the currently available Node
    version.
.EXAMPLE
    Get-NodeVersion
.OUTPUT
    System.Nullable[System.Version] Either the version returned from Node,
    or $null if Node is not available.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-NodeVersion
{
    try
    {
        $nodeVersion = node.exe `-`-version

        $match = [Regex]::Match( `
            $nodeVersion, `
            '^v(?<Version>\d+\.\d+\.\d+)$')

        if ($match.Success -eq $false)
        {
            return $null
        }

        $version = [Version]($match.Groups[1].Value)

        return $version
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $null
    }
}