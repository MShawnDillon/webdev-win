<# 
.SYNOPSIS
    Downloads text content and returns it as a string or as JSON (depending on
    the "Content-Type" of the response).
.DESCRIPTION
    This will retrieve web content while showing the progress of the
    operation. If the "Content-Type" header of the response is
    'application/json', the content is returned as JSON (rather than as a
    string).
.EXAMPLE
    $json = Download-Content 'https://api.github.com/repos/msysgit/msysgit/tags'
.EXAMPLE
    $page = Download-Content 'http://nodejs.org/dist/latest/'
.PARAMETER Url
    The url of the content to retrieve.
.NOTES
    Extended Author: M. Shawn Dillon
#Requires -Version 2.0 
#>
function Download-Content
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Url
    )

    process
    {
        $global:DownloadResult = [String]::Empty
    	$client = New-Object System.Net.WebClient

        $global:DownloadError = $null
        $global:DownloadComplete = $false

        $eventDataComplete = Register-ObjectEvent `
            -InputObject $client `
            -EventName DownloadStringCompleted `
            -SourceIdentifier WebClient.DownloadStringComplete `
            -Action { `
                $global:DownloadComplete = $true; `
                $global:DownloadError = $EventArgs.Error; `
                if ($EventArgs.Error -eq $null) { `
                    $global:DownloadResult = $EventArgs.Result; `
                } `
            }

        $eventDataProgress = Register-ObjectEvent `
            -InputObject $client `
            -EventName DownloadProgressChanged `
            -SourceIdentifier WebClient.DownloadProgressChanged `
            -Action { $global:DownloadProgress = $EventArgs }

        Write-Progress `
            -Activity 'Downloading content' `
            -Status $Url

        try
        {
            $client.DownloadStringAsync($Url)

            while ($global:DownloadComplete -eq $false)
            {
                $percentComplete = $global:DownloadProgress.ProgressPercentage

                if ($percentComplete -ne $null)
                {
                    Write-Progress `
                        -Activity 'Downloading content' `
                        -Status $Url `
                        -PercentComplete $percentComplete
                }
            }

            Write-Progress `
                -Activity 'Downloading content' `
                -Status $Url `
                -Completed

            if ($global:DownloadError -ne $null)
            {
                Throw $global:DownloadError
            }

            return $global:DownloadResult
        }
        finally
        {
            Unregister-Event `
                -SourceIdentifier WebClient.DownloadProgressChanged

            Unregister-Event `
                -SourceIdentifier WebClient.DownloadStringComplete

            $client.Dispose()

            $global:DownloadResult = $null
            $global:DownloadComplete = $null
            $global:DownloadProgress = $null
            $global:DownloadError = $null

            Remove-Variable client
            Remove-Variable eventDataComplete
            Remove-Variable eventDataProgress
            Remove-Variable DownloadResult -Scope Global
            Remove-Variable DownloadComplete -Scope Global
            Remove-Variable DownloadProgress -Scope Global
            Remove-Variable DownloadError -Scope Global
        }
    }
}

