function Get-Nvmw
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Url,
        [Parameter(Mandatory = $false)]
        [String] $NvmwInstallRoot = (Join-Path $env:APPDATA '.nvmw')
    )

    process
    {
        if (((Get-GitVersion) -eq $null) -or ((Get-GitVersion) -lt ([Version]'1.9.2')))
        {
            Throw ('Cannot get Node Version Manager for Windows because ' + `
                   'the minimum required of Git is not available.')
        }

        if ((Test-Path $NvmwInstallRoot -PathType Container) -eq $true)
        {
            Remove-Item $NvmwInstallRoot -Force -Recurse
        }

        git clone $Url "`"$NvmwInstallRoot`""

        ## Now that we have it, let's make sure we have our PATH set to get
        ## to it easily from any command prompt or other program.
        $nvmwInstallRootPreferred = $NvmwInstallRoot.Replace( `
            $env:APPDATA, '%APPDATA%')

        ## Add the path to the .nvmw directory to the list only if it is not
        ## already effectively present, either using environment variables
        ## that expand to something matching that path or the hard-coded path
        ## itself.
        Set-PathInclude $nvmwInstallRootPreferred

        ## We also want whatever version of Node is 'Current' to always be
        ## available from the command line without needing to invoke NVMW for
        ## each usage. This sets the PATH to include the Current junction in
        ## the NVMW install root.
        $nvmwCurrentPreferred = Join-Path $nvmwInstallRootPreferred 'Current'

        ## Add the .nvmw\Current directory to the list only if it is not
        ## already effectively present, either using environment variables
        ## that expand to something matching that path or the hard-coded path
        ## itself.
        Set-PathInclude $nvmwCurrentPreferred

        if ((Test-Nvmw) -eq $false)
        {
            Throw ('The Node Version Manager for Windows is still not ' + `
                   'available. Something went wrong.')
        }
    }
}