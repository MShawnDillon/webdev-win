param (
    [Parameter(Mandatory = $false)]
    [String] $DisplayName = [String]::Empty,
    [Parameter(Mandatory = $false)]
    [String] $EmailAddress = [String]::Empty
)

## Pull in the other functions we need.
.'.\Invoke-BatchFile.ps1'
.'.\Download-File.ps1'
.'.\Expand-Zip.ps1'
.'.\Get-UserInfo.ps1'
.'.\Get-UserEnv.ps1'
.'.\Set-UserEnv.ps1'
.'.\Set-PathInclude.ps1'
.'.\Get-GitVersion.ps1'
.'.\Get-NodeVersion.ps1'
.'.\Get-NpmVersion.ps1'
.'.\Get-PortableGit.ps1'
.'.\Get-GitProperty.ps1'
.'.\Set-GitProperty.ps1'
.'.\Set-NpmProperty.ps1'
.'.\Test-Nvmw.ps1'
.'.\Get-Nvmw.ps1'

$userInfo = $null

if (($DisplayName.Length -gt 0) -and ($EmailAddress.Length -gt 0))
{
    $userInfo = Get-UserInfo -NonInteractive
    $userInfo.DisplayName = $DisplayName
    $userInfo.EmailAddress = $EmailAddress
}
else
{
    if ((Get-GitVersion) -ne $null)
    {
        $DisplayName = Get-GitProperty 'user.name'
        $EmailAddress = Get-GitProperty 'user.email'

        $userInfo = Get-UserInfo -NonInteractive

        if ($userInfo.DisplayName.Length -eq 0)
        {
            $userInfo.DisplayName = $DisplayName
        }

        if ($userInfo.EmailAddress.Length -eq 0)
        {
            $userInfo.EmailAddress = $EmailAddress
        }
    }
    else
    {
        $userInfo = Get-UserInfo
    }
}

if ((Get-GitVersion) -lt ([Version]'1.9.2'))
{
    $gitInstallRoot = Join-Path $userInfo.DataDirectory 'Git'

    Get-PortableGit `
        -Url 'https://github.com/msysgit/msysgit/releases/download/Git-1.9.4-preview20140611/PortableGit-1.9.4-preview20140611.7z' `
        -GitInstallRoot $gitInstallRoot
}

Set-GitProperty 'user.name' ($userInfo.DisplayName)
Set-GitProperty 'user.email' ($userInfo.EmailAddress)
Set-GitProperty 'push.default' 'simple'
Set-GitProperty 'alias.serve' '!git daemon --reuseaddr --informative-errors --verbose --base-path=. --export-all ./.git'
Set-GitProperty 'alias.hub' '!git daemon --reuseaddr --informative-errors --verbose --base-path=. --enable=receive-pack --export-all ./.git'

if ((Test-Nvmw) -eq $false)
{
    $nvmwInstallRoot = Join-Path $userInfo.DataDirectory '.nvmw'

    Get-Nvmw `
        -Url 'https://github.com/MShawnDillon/nvmw.git' `
        -NvmwInstallRoot $nvmwInstallRoot
}

if (((Get-NodeVersion) -eq $null) -or ((Get-NpmVersion) -eq $null))
{
    Invoke-BatchFile -Path ((Get-Command nvmw.bat).Path) -Arguments "install v0.10.29"
}

## *Name Withdrawn* engages in the dubious practice of "SSL
## Inspection", meaning that they intercept all SSL communication
## requests and replace the certificate issued by the target server
## with a certificate created on-the-fly in response to a user request
## whose Common Name (CN) matches the requested target identity. These
## 'on-the-fly' certificates chain up to a certificate that is trusted
## only internally on company-owned equipment. In short, *Name
## Withdrawn* performs a 'man-in-the-middle' attack on all secure
## channels going over standard ports (443) so that it can log and
## inspect all of the traffic flowing over its network. To be clear,
## they have every right to do this; after all, they own the network
## and have every right to inspect all of the information that flows
## through it. Unfortunately, many people don't realize this and still
## trust the "lock" symbol in their browser to mean that their
## communication with the host is secure and safe from prying eyes. It
## is not. There should be no expectation of privacy on a corporate
## network... ever.
##
## NPM, being a cross-platform tool, does not use Windows' own
## mechanisms to determine which certificates (specifically, the
## certificate authorities that issue them) to trust. When NPM is used
## over a corporate network that engages in SSL inspection it will
## normally fail to retrieve packages from the standard repositories,
## because the certificate issued by the internal proxy is not trusted
## and the target server's certificate (the one that may have been
## issued by a trusted authority) is never actually received.
##
## To work around this and tell NPM that it should not enforce SSL
## certificate validation, the 'strict-ssl' configuration setting must
## be set to 'false'.
Set-NpmProperty 'strict-ssl' 'false' -Global -Force
Set-NpmProperty 'init.author.name' ($userInfo.DisplayName)
Set-NpmProperty 'init.author.email' ($userInfo.EmailAddress)

## Pause for 5 seconds so the user can take in what all just happened and read
## what is remaining on the screen.
Start-Sleep -s 5

Write-Host @"


Done! Several user environment variables were changed and/or added; in order
for those changes and the new commands they make available to be reflected in
your environment, you must either restart Windows Explorer or log out and log
back in.

To restart Windows Explorer without logging out, click on the 'Start Menu'
button, and then hold down the CTRL+SHIFT keys while right-clicking on the
arrow next to the 'Shut Down' (or 'Disconnect') button to the lower right of
the start menu display. A context menu will open with two options:
'Properties' and 'Exit Explorer'.

WARNING: When you 'Exit Explorer', your whole task bar will disappear. You
must press CTRL+ALT+DELETE and then 'Start Task Manager'. From there, you can
use its 'File'->'New Task (Run...)' menu command to start the 'explorer.exe'
program. When 'explorer.exe' is restarted, your taskbar will return along with
your system notification area and any programs that you had running.

Enjoy!
"@
