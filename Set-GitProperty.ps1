<#
.SYNOPSIS
    Sets or adds a configuration value to the user's global Git configuration.
.DESCRIPTION
    This basically calls git config --global --replace-all with the specified
    property name and value (if the value is different than its current
    value).
.EXAMPLE
    Set-GitProperty 'user.name' 'Ordinary User'
.PARAMETER Name
    The name of the global Git configuration option to set.
.PARAMETER Value
    The value to which the global Git configuration option will be set.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Set-GitProperty
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $true)]
        [String] $Value,
        [Switch] $Force = $false
    )

    process
    {
        $currentValue = git config `-`-global `-`-get`-all $Name

        if ($currentValue -ne $Value)
        {
            $shouldSet = $true
            if (($currentValue.Length -gt 0) -and ($Force -eq $false))
            {
                $shouldSet = $false
                Write-Host ("The current Git user configuration already " + `
                    "contains a '$Name' value set to '$currentValue'. Do " + `
                    "you want to replace the current value with '$Value'?")
                if ((Read-Host "Set '$Name' to '$Value' [no]? [yes/no]") `
                    -imatch '^y.+')
                {
                    $shouldSet = $true
                }
            }

            if ($shouldSet -eq $true)
            {
                Write-Host "Setting Git '$Name' to '$Value'"
                git config `-`-global `-`-replace`-all $Name "`"$Value`""
            }
        }
    }
}
