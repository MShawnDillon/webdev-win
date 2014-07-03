<#
.SYNOPSIS
    Gets the portable version of msysgit (Git for Windows).
.DESCRIPTION
    Downloads the portable version of msysgit and configures it for use in a
    locked-down environment.
.EXAMPLE
    Get-Git 'http://somedomain.com/url/to/portable/git.7z' 'C:\Users\Some User\AppData\Roaming\Git'
.PARAMETER Url
    The url from which the portable version of msysgit will be download.
.PARAMETER NodeVersion
    The local path where portable Git will be extracted.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Get-PortableGit
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Url,
        [Parameter(Mandatory = $true)]
        [String] $GitInstallRoot
    )

    process
    {
        $portableGitUrl = $Url
        $portableGitFileName = $portableGitUrl.Substring($portableGitUrl.LastIndexOf('/') + 1)
        $portableGitSaveLocation = Join-Path $PWD.Path $portableGitFileName
        ## 7-zip is just a means to an end. We only need it to extract the
        ## portable git download. Once done, we remove it.
        $sevenZipExtractorUrl = 'http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.20/7za920.zip'
        $sevenZipExtractorFileName = $sevenZipExtractorUrl.Substring($sevenZipExtractorUrl.LastIndexOf('/') + 1)
        $sevenZipExtractorSaveLocation = Join-Path $PWD.Path $sevenZipExtractorFileName
        $sevenZipExtractToDirectory = Join-Path $PWD.Path ([IO.Path]::GetFileNameWithoutExtension($sevenZipExtractorFileName))

        Download-File $portableGitUrl $portableGitSaveLocation
        Download-File $sevenZipExtractorUrl $sevenZipExtractorSaveLocation
        Expand-Zip $sevenZipExtractorSaveLocation $sevenZipExtractToDirectory

        $process = "`"$sevenZipExtractToDirectory\7za.exe`""
        $arguments = "x -o`"$gitInstallRoot`" -y "
        $arguments += "`"$portableGitSaveLocation`""

        CMD.EXE /C "`"$process $arguments`"" | Out-Null

        Remove-Item $sevenZipExtractToDirectory -Force -Recurse
        Remove-Item $sevenZipExtractorSaveLocation -Force
        Remove-Item $portableGitSaveLocation -Force

        $gitInstallBinAlternate = (Join-Path $GitInstallRoot 'bin')
        $gitInstallBinPreferred = $gitInstallBinAlternate.Replace($env:APPDATA, '%APPDATA%')
        $gitInstallCmdAlternate = (Join-Path $GitInstallRoot 'cmd')
        $gitInstallCmdPreferred = $gitInstallCmdAlternate.Replace($env:APPDATA, '%APPDATA%')

        ## Add the path to the Git\cmd directory to the list only if it is not
        ## already effectively present, either using environment variables
        ## that expand to something matching that path or the hard-coded path
        ## itself.
        Set-PathInclude $gitInstallCmdPreferred

        ## Add the path to the Git\bin directory to the list only if it is not
        ## already effectively present, either using environment variables
        ## that expand to something matching that path or the hard-coded path
        ## itself.
        Set-PathInclude $gitInstallBinPreferred

        ## Git internally uses the following environment variables, so let's
        ## go ahead and set them both in the user's environment as well as the
        ## current process environment (if they're not already present).

        ## The HOME environment variable is not necessarily the same as
        ## the user's USERPROFILE. The user profile is a local directory
        ## where Windows stores the user's application data (like this
        ## per-user installation of Git), roaming configuration settings,
        ## and the user's personal registry hive. The HOME location, on
        ## the other hand, could be a network location where the user is
        ## intended to save their personal documents and files. The major
        ## difference between these two is that, if the workstation should
        ## become toast (or a brick), the roaming settings are safely
        ## backed up in Active Directory, and the user's documents and
        ## other files are safe in the HOME location (usually on a network
        ## share). Anything else in the user profile is subject to be lost
        ## forever.
        ##
        ## Windows automatically defines a HOMEDRIVE and a HOMEPATH, but
        ## doesn't combine them into a HOME location (which is standard
        ## on Mac/Unix and Linux systems that don't have the concept of
        ## "drives" as part of the file system).
        ##
        ## This makes sure that the HOME variable is set, and points to
        ## the correct location.
        Set-UserEnv HOME ($env:HOMEDRIVE + $env:HOMEPATH)

        Set-UserEnv PLINK_PROTOCOL 'ssh'
        Set-UserEnv TERM 'msys'

        # Back up current curl-ca-bundle.crt
        $currentCurlCaBundle = Join-Path $gitInstallBinAlternate `
            'curl-ca-bundle.crt'
        $backupCurlCaBundle = $currentCurlCaBundle + '.' + `
            [DateTime]::UtcNow.ToString('yyyyMMddHHmmss')

        Copy-Item `
            -LiteralPath $currentCurlCaBundle `
            -Destination $backupCurlCaBundle

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
        ## Git, being a cross-platform tool, does not use Windows' own
        ## mechanisms to determine which certificates (specifically, the
        ## certificate authorities that issue them) to trust. When Git is used
        ## over a corporate network that engages in SSL inspection it will
        ## normally fail to push to or pull from any external repositories,
        ## because the certificate issued by the internal proxy is not trusted
        ## and the target server's certificate (the one that may have been
        ## issued by a trusted authority) is never actually received.
        ##
        ## To work around this and tell Git to go ahead and trust the internal
        ## proxy's certificate issuer, the curl-ca-bundle.crt file must be
        ## modified to include the proxy's issuing root certificate.
        $zscalerRootCa = @"

Zscaler Root CA
===============
-----BEGIN CERTIFICATE-----
MIIE0zCCA7ugAwIBAgIJAOTYAq3C9SHKMA0GCSqGSIb3DQEBBQUAMIGhMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2Ux
FTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgw
FgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRA
enNjYWxlci5jb20wHhcNMTMwNjI0MTU0NDE5WhcNNDAxMTA5MTU0NDE5WjCBoTEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBK
b3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5j
LjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBw
b3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
uTYftUd6FCweoWdu0hiJyt7js0OYTRoMheO6t1p64UHSjixHfcRa6G+jbEzjDtSP
ZhbVZaTjQbDOvaVU8fyCazbwZBSmZy+UI4ILWLPywDL2FDDMkxqtNjL3UOHJKz8P
UKPsj284kcWYmL4KZbclJk57oNdrkU/R0b3Oiqg76O+gcusxCvUgg4j2agxF5u89
y3qFoZEUaZPGNUlFgF/61IK+BhaNuwDSnZ62K1WW5K8sd3/nUyjKvk4lbrZT1G48
t20tbT0NGG3l5SNEulZfBruexiw+i5KH3FkI1gYmY1hXRKV4AHgBvefUDBSpVYgy
TWjkRBDw3k9zXKtiTJ4x5wIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFK1BqSokdBRw
b5ob0IhuTRjBhkA2MIHWBgNVHSMEgc4wgcuAFK1BqSokdBRwb5ob0IhuTRjBhkA2
oYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8G
A1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMM
WnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG
9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDk2AKtwvUhyjAMBgNVHRMEBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4IBAQAsglrucSDQjsNe8YaDj5ufMeWnWFlb5wfi
prM4P2Gh0kjT0UqpIkFe7xE1UDvsT3XCFOc9YqF1Vz/XCea84qg6YW/uRPHNiYEw
NeG0pN4WRoMngaSwwVAFuihzVmpg+lX813M314wwxnTY68Sh0AzI8Iit5XjNy+Mm
x5AzyOOp03EvROg/jKbZlLAC5Q5kjCKXZtguCAuMemje7e+KVCJ1/Ihwg06vs4n1
udJ08w1y9bxeML888S9hSpsSz0mJ+vULI5kBR2v2wGr5Q+TNezXZF2QY1Cxo7WaD
gQmyaOJ89bZWRdtY1GjF3XCPD0ZlZ8wtCJH7pmDkX3WxRSI+6443
-----END CERTIFICATE-----


"@

        ## Replace Windows' line endings (CRLF) with normal line endings (LF)
        $zscalerRootCa = $zscalerRootCa.Replace( `
            [Environment]::NewLine, `
            ([Char]10).ToString())

        [IO.File]::AppendAllText( `
            $currentCurlCaBundle, `
            $zscalerRootCa, `
            [Text.Encoding]::UTF8)

        ## Finally, before we exit, make sure that we can, in fact, use git
        ## as a command within this script.
        if ((Get-GitVersion) -lt ([Version]'1.9.2'))
        {
            Throw 'Unable to get Git.'
        }
    }
}