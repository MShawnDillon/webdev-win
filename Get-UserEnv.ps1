<#
.SYNOPSIS
    Gets a user environment variable value as it is currently stored in the
    user's persistent profile.
.DESCRIPTION
    The user's environment block is stored in the user's profile hive
    (HKEY_CURRENT_USER, on disk at %USERPROFILE%\NTUSER.dat) in the Windows
    registry (specifically, at HKEY_CURRENT_USER\Environment). This function
    reads the requested user environment variable value from here without
    performing environment variable expansion (as would be the case when you
    read the value from $env:VARIABLE or the Env:\ PowerShell drive).
.EXAMPLE
    Get-UserEnv 'PATH'
.EXAMPLE
    Get-UserEnv 'NODE_HOME'
.PARAMETER Name
    The name of the environment variable whose value will be returned from
    the user's personal persistent settings.
.PARAMETER DefaultValue
    The value to return if the variable does not exist as a persistent value
    in the user's profile.
.OUTPUTS
    System.String. The raw value of the environment variable as it is stored
    in the user's profile hive in the registry (or the default value, if it
    does not exist).
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-UserEnv
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $false)]
        [String] $DefaultValue = [String]::Empty
    )

    begin
    {
        $hive = [Microsoft.Win32.Registry]::CurrentUser
        $key = $hive.OpenSubKey('Environment')
    }

    process
    {
        return $key.GetValue( `
            $Name, `
            $DefaultValue, `
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    }

    end
    {
        $key.Close()
    }
}