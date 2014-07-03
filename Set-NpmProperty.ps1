<#
.SYNOPSIS
    Sets or adds a configuration value to the user's NPM configuration.
.DESCRIPTION
    This basically calls 'npm config set' with the specified property name
    and value (if the value is different than its current value).
.EXAMPLE
    Set-NpmProperty 'strict-ssl' 'false' -Global -Force
.EXAMPLE
    Set-NpmProperty 'init.author.name' 'Ordinary User'
.PARAMETER Name
    The name of the NPM configuration option to set.
.PARAMETER Value
    The value to which the NPM configuration option will be set.
.PARAMETER Global
    When set, this indicates that the global NPM configuration (stored in the
    npm directory's .npmrc file should be affected; otherwise, configuration
    settings are stored in the user's .npmrc file in the user's profile.
.PARAMETER Force
    When set, this indicates that the user should not be prompted to confirm
    changes to an existing setting; otherwise, if the current value is set to
    something different than the requested value, the user will be prompted
    to confirm the change.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Set-NpmProperty
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $true)]
        [String] $Value,
        [Switch] $Global,
        [Switch] $Force
    )

    process
    {
        $globalSwitch = [String]::Empty
        if ($Global -eq $true)
        {
            $globalSwitch = '-g'
        }

        $currentValue = npm config get $globalSwitch $Name

        if ($currentValue -ne $Value)
        {
            $shouldSet = $true
            if (($currentValue.Length -gt 0) -and ($Force -eq $false))
            {
                $shouldSet = $false
                Write-Host ("The current NPM configuration contains a " + `
                    "'$Name' value set to '$currentValue'. Do you want " + `
                    "to replace the current value with '$Value'?")
                if ((Read-Host "Set '$Name' to '$Value' [no]? [yes/no]") `
                    -imatch '^y.+')
                {
                    $shouldSet = $true
                }
            }

            if ($shouldSet -eq $true)
            {
                Write-Host ("Setting NPM configuration setting '$Name' " + `
                            "to '$Value'")
                npm config set $globalSwitch $Name "`"$Value`""
            }
        }
    }
}
