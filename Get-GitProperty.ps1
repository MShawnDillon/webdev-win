<#
.SYNOPSIS
    Gets the value of a configuration setting from the user's global Git
    configuration.
.DESCRIPTION
    This basically calls git config --global --get-all with the specified
    property name.
.EXAMPLE
    Get-GitProperty 'user.name'
.PARAMETER Name
    The name of the global Git configuration setting value to query.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-GitProperty
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name
    )

    process
    {
        return git config `-`-global `-`-get`-all $Name
    }
}
