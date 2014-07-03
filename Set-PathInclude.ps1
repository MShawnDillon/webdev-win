<#
.SYNOPSIS
    Ensures that the user's PATH includes a specific value, adding it if
    necessary to the existing list of paths.
.DESCRIPTION
    This will determine whether the path already exists in the user's PATH
    list, and if it doesn't, it will add it to the user's profile so that it
    persists across reboots (and set it in the current environment, as well).
.EXAMPLE
    Set-PathInclude '%USERPROFILE%\Commands'
.PARAMETER Path
    The path to a directory that should be included in the user's PATH list.
    This path can include environment variables.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Set-PathInclude
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Path
    )

    process
    {
        $ExpandedPath = [Environment]::ExpandEnvironmentVariables($Path)

        $Combined = (Get-Content Env:\PATH).Split(';')
        $RawUserPath = (Get-UserEnv PATH "")
        if ($RawUserPath.Length -eq 0)
        {
            $UserPaths = [String[]]@()
        }
        else
        {
            $UserPaths = $RawUserPath.Split(';')
        }

        [String[]] $ExpandedUserPaths = @()
        $UserPaths | ForEach-Object {
            $ExpandedUserPaths += [Environment]::ExpandEnvironmentVariables($_)
        }

        ## The New-Object command, as it is used below, takes as its second
        ## argument an object array [Object[]] representing the list of
        ## constructor arguments to provide to the object being created.
        ##
        ## We need the following to create an object array and set its first
        ## element to an array of strings, otherwise New-Object will interpret
        ## the array of strings as separate arguments to be passed to the
        ## constructor (one string per argument). Since the constructor for a
        ## generic list doesn't have an overload that accepts a 'params'
        ## array, this workaround is necessary to call the correct
        ## constructor.
        $temp = @()
        $temp += ,$UserPaths

        $Pending = New-Object 'System.Collections.Generic.List[String]' $temp

        $exists = $Combined -contains $ExpandedPath
        $existsWithTrailing = $Combined -contains ($ExpandedPath + '\')

        if ($exists -or $existsWithTrailing)
        {
            ## It is set in the current system or user environment.
            return
        }

        $exists = $ExpandedUserPaths -contains $ExpandedPath
        $existsWithTrailing = $ExpandedUserPaths -contains ($ExpandedPath + '\')

        if (($exists -or $existsWithTrailing) -eq $false)
        {
            ## It is not set in the current system or user environment.
            $Pending.Insert(0, $Path)

            $NewValue = [String]::Join(';', $Pending.ToArray())

            ## Note that this sets the user's PATH environment variable
            ## directly in the registry so that it will be available whenever
            ## (and wherever) the user logs in. Unfortunately, this does NOT
            ## affect any programs launched from the current shell (Windows
            ## Explorer, the program that provides your task bar and desktop
            ## environment in Windows). This is because the environment block
            ## is copied from the registry to the current process at logon,
            ## and from that point, any new programs started from that program
            ## typically just copy the parent process's environment block.
            ##
            ## Long story short (too late), the user will have to restart
            ## Windows Explorer (their shell) in order for these changes to be
            ## picked up. Either Windows Explorer can be restarted, or the
            ## user could log off and back on, or restart their whole machine.
            ##
            ## Within this process, however, we can set these environment
            ## variables to get access to the tools they make available at
            ## least for the remaining activities we need to carry out. The
            ## downside is that when the program ends, our environment
            ## variable changes will be lost as well (until the shell
            ## restarts as mentioned above).
            ##
            ## This is just one of those Windows CrazyThings(tm) that makes
            ## Windows so inferior to other operating systems.
            ##
            Set-UserEnv PATH $NewValue
        }
    }
}
