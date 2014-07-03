<#
.SYNOPSIS
    Gets an object that contains basic information about the current user.
.DESCRIPTION
    Much of this information is also available as environment variables and
    set automatically by the system when you log in. However, there are a few
    things that aren't that easy to get to, such as the user's e-mail address
    and their full name.

    This populates a PowerShell object with the current user's username (the
    identifier they use to log in), their domain name (if the user is on an
    Active Directory domain, or the local computer name if they're not), their
    workstation NetBIOS (short) name, their e-mail address and display name
    (asking for it, if it cannot be determined automatically), and a few other
    tidbits of information that might be needed to set up per-user tool
    configuration options.
.EXAMPLE
    Get-UserInfo
.PARAMETER NonInteractive
    A switch indicating that no prompts should be shown, under any
    circumstances. If some user information cannot be determined
    automatically, it is left empty or defaulted.
.OUTPUTS
    PSObject. An object containing the collected information about the current
    user.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-UserInfo
{
    param (
        [Switch] $NonInteractive
    )

    begin
    {
        $searcher = New-Object System.DirectoryServices.DirectorySearcher( `
            "(&(objectCategory=Person)(objectClass=User)(sAMAccountName=$env:USERNAME))", `
            ([String[]]@("sAMAccountName","displayName","mail")))
    }

    process
    {
        $displayName = [String]::Empty
        $emailAddress = [String]::Empty

        try
        {
            $result = $searcher.FindOne()

            if ($result.Properties["displayName"] -ne $null)
            {
                $displayName = $result.Properties["displayName"][0]
            }

            if ($result.Properties["mail"] -ne $null)
            {
                $emailAddress = $result.Properties["mail"][0]
            }
        }
        catch [Runtime.InteropServices.COMException]
        {
            ## This exception will occur if the workstation is not a member of
            ## an Active Directory domain, or has no network connection to the
            ## domain. In that case, try to find the user in the local user
            ## store. Note that the local user store does not contain e-mail
            ## addresses; the only thing we will find here is the user's full
            ## name (display name).
            $entry = New-Object System.DirectoryServices.DirectoryEntry( `
                "WinNT://$env:COMPUTERNAME/$env:USERNAME,user")
            try
            {
                $displayName = $entry.Properties["FullName"][0]
            }
            catch [Runtime.InteropServices.COMException]
            {
                ## Do nothing, leave it empty.
            }
            finally
            {
                $entry.Dispose()
            }
        }

        ## See if we can ask about any missing information.
        if ($NonInteractive -eq $false)
        {
            while ($displayName.Length -eq 0)
            {
                Write-Host ('Your display name could not be determined ' + `
                    'automatically.')

                $displayName = Read-Host ("Enter your display name " + `
                    "(typically your full or first and last name)" + `
                    "`nDisplay Name")
            }

            while ($emailAddress.Length -eq 0)
            {
                Write-Host ('Your email address could not be determined ' + `
                    'automatically and is currently empty.')

                $emailAddress = Read-Host ("Enter your email address " + `
                    "(the email address to associate with your work) " + `
                    "`nEmail Address")
            }
        }

        $user = New-Object -TypeName PSObject
        $user | Add-Member -MemberType NoteProperty -Name 'Workstation' `
            -Value ($env:COMPUTERNAME).ToUpperInvariant()
        $user | Add-Member -MemberType NoteProperty -Name 'UserName' `
            -Value ($env:USERNAME)
        $user | Add-Member -MemberType NoteProperty -Name 'DomainName' `
            -Value ($env:USERDOMAIN).ToUpperInvariant()
        $user | Add-Member -MemberType NoteProperty -Name 'DisplayName' `
            -Value $displayName
        $user | Add-Member -MemberType NoteProperty -Name 'EmailAddress' `
            -Value $emailAddress
        $user | Add-Member -MemberType NoteProperty -Name 'TempDirectory' `
            -Value ([IO.Path]::GetFullPath($env:TEMP))
        $user | Add-Member -MemberType NoteProperty -Name 'DataDirectory' `
            -Value ([IO.Path]::GetFullPath($env:APPDATA))
        $user | Add-Member -MemberType NoteProperty -Name 'UserDirectory' `
            -Value ([IO.Path]::GetFullPath($env:USERPROFILE))
        $user | Add-Member -MemberType NoteProperty -Name 'HomeDirectory' `
            -Value ([IO.Path]::GetFullPath($env:HOMEDRIVE + $env:HOMEPATH))

        return $user
    }

    end
    {
        $searcher.Dispose()
    }
}