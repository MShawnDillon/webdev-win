<#
.SYNOPSIS
    Sets a user environment variable in the current environment and in the
    registry so that it persists across restarts.
.DESCRIPTION
    Most environment variable changes should be scoped to within the current
    process, so that those changes only affect that process. This is how the
    Env:\ drive works in PowerShell and how the SET command works in normal
    batch (*.cmd, *.bat) files. PowerShell provides no native functionality
    to create or set the value of a per-user environment variable so that it
    persists across reboots and multiple user sessions.

    The user's environment block is stored in the user's profile hive
    (HKEY_CURRENT_USER, on disk at %USERPROFILE%\NTUSER.dat) in the Windows
    registry (specifically, at HKEY_CURRENT_USER\Environment). This function
    sets user environment variables here as REG_EXPAND_SZ values as well as
    ensuring that the environment variable is available within the current
    process.
.EXAMPLE
    Set-UserEnv 'PATH' '%USERPROFILE%\Commands;%PUBLIC%\Scripts'
.EXAMPLE
    Set-UserEnv 'NODE_HOME' '%APPDATA%\.nvmw\Current'
.PARAMETER Name
    The name of the environment variable.
.PARAMETER Value
    The value to apply to the 'Name' environment variable. This value can
    include other environment variable names that will be expanded.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Set-UserEnv
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Name,
        [Parameter(Mandatory = $false)]
        [String] $Value = ""
    )

    begin
    {
        $hive = [Microsoft.Win32.Registry]::CurrentUser
        $key = $hive.OpenSubKey('Environment', $true)

        if ($global.EnvironmentRefreshRequired -ne $true)
        {
            $global:EnvironmentRefreshRequired = $false
        }
    }

    process
    {
        $ExpandedValue = [Environment]::ExpandEnvironmentVariables($Value)

        $CurrentValue = $key.GetValue( `
            $Name, `
            [String]::Empty, `
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)

        $CurrentExpandedValue = [Environment]::ExpandEnvironmentVariables( `
            $CurrentValue)

        $key.SetValue( `
            $Name, `
            $Value, `
            [Microsoft.Win32.RegistryValueKind]::ExpandString)

        ## We want to add/change the variable's value in the local environment
        ## only if it has, in fact, changed.
        $Changed = $CurrentExpandedValue -ne $ExpandedValue

        if ($Changed -eq $false)
        {
            return
        }

        if ((Test-Path "Env:\$Name") -eq $false)
        {
            ## Easy, it doesn't exist; so add it with our expanded value.
            Set-Content "Env:\$Name" $ExpandedValue
        }
        else
        {
            $LocalValue = Get-Content "Env:\$Name"

            ## Note that LocalValue may be a combination of both the system
            ## and user environments (like PATH, for example).
            if ($LocalValue -eq $CurrentExpandedValue)
            {
                ## They're equivalent, so let's change it.
                Set-Content "Env:\$Name" $ExpandedValue
            }
            else
            {
                if ($CurrentExpandedValue.Length -eq 0)
                {
                    Set-Content `
                        "Env:\$Name" `
                        ($LocalValue + ';' + $ExpandedValue)
                }
                else
                {
                    Set-Content `
                        "Env:\$Name" `
                        ($LocalValue.Replace($CurrentExpandedValue, $ExpandedValue))
                }
            }
        }

        $global:EnvironmentRefreshRequired = $true
    }

    end
    {
        $key.Close()
    }
}