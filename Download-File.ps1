<# 
.SYNOPSIS
    Downloads a file (while showing the progress of the download).
.DESCRIPTION
    This will download a file locally while showing the progress of the
    download.
.EXAMPLE
    Download-File 'http://someurl.com/somefile.zip'
.EXAMPLE
    Download-File 'http://someurl.com/somefile.zip' 'C:\Temp\somefile.zip'
.PARAMETER Url
    The url of the file to be downloaded.
.PARAMETER LocalFile
    The local filename where the download should be saved.
.NOTES
    Original Author: CrazyDave
    Extended Author: M. Shawn Dillon
#Requires -Version 2.0 
#>
function Download-File
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Url,
        [Parameter(Mandatory = $false)]
        [String] $LocalFile = `
            (Join-Path $PWD.Path $Url.SubString($Url.LastIndexOf('/') + 1)),
        [Parameter(Mandatory = $false)]
        [Int32] $Id = 0
    )

    begin
    {
    	$client = New-Object System.Net.WebClient

        $global:DownloadComplete = $false

        $eventDataComplete = Register-ObjectEvent `
            -InputObject $client `
            -EventName DownloadFileCompleted `
            -SourceIdentifier WebClient.DownloadFileComplete `
            -Action { $global:DownloadComplete = $true }

        $eventDataProgress = Register-ObjectEvent `
            -InputObject $client `
            -EventName DownloadProgressChanged `
            -SourceIdentifier WebClient.DownloadProgressChanged `
            -Action { $global:DownloadProgress = $EventArgs }
    }

    process
    {
        Write-Progress `
            -Activity 'Downloading file' `
            -Status $Url

        $client.DownloadFileAsync($Url, $LocalFile)

        while ($global:DownloadComplete -eq $false)
        {
            $percentComplete = $global:DownloadProgress.ProgressPercentage

            if ($percentComplete -ne $null)
            {
                Write-Progress `
                    -Activity 'Downloading file' `
                    -Status $Url `
                    -PercentComplete $percentComplete
            }
        }

        Write-Progress `
            -Activity 'Downloading file' `
            -Status $Url `
            -Complete
    }

    end
    {
        Unregister-Event `
            -SourceIdentifier WebClient.DownloadProgressChanged

        Unregister-Event `
            -SourceIdentifier WebClient.DownloadFileComplete

        $client.Dispose()

        $global:DownloadComplete = $null
        $global:DownloadProgress = $null

        Remove-Variable client
        Remove-Variable eventDataComplete
        Remove-Variable eventDataProgress

        [GC]::Collect()
    }
}
