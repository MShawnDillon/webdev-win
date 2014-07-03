<#
.SYNOPSIS
    Gets the Node Package Manager (NPM) version that is available in the
    current environment.
.DESCRIPTION
    This calls the npm --version command if the command is available and
    returns a System.Version representing the currently available NPM version.
.EXAMPLE
    Get-NpmVersion
.OUTPUT
    System.Nullable[System.Version] Either the version returned from NPM, or
    $null if NPM is not available.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-NpmVersion
{
    try
    {
        $command = Get-Command npm.cmd -ErrorAction SilentlyContinue

        $npmVersion = npm.cmd `-`-version

        $match = [Regex]::Match( `
            $npmVersion, `
            '^(?<Version>\d+\.\d+\.\d+)$')

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