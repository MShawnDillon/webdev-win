<#
.SYNOPSIS
    Gets the Git version that is available in the current environment.
.DESCRIPTION
    This calls the git --version command if the command is available and
    returns a System.Version representing the currently available git version.
.EXAMPLE
    Get-GitVersion
.OUTPUT
    System.Nullable[System.Version] Either the version returned from Git (with
    the msysgit specification removed), or $null if git is not available.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-GitVersion
{
    try
    {
        $gitVersion = git.exe `-`-version

        $match = [Regex]::Match( `
            $gitVersion, `
            '^git version (?<Version>\d+\.\d+\.\d+)\.msysgit\.(?<Revision>\d+)$')

        if ($match.Success -eq $false)
        {
            return $null
        }

        $version = [Version]($match.Groups[1].Value + '.' + $match.Groups[2].Value)

        return $version
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $null
    }
}