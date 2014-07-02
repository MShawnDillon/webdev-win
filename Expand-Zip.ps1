<#
.SYNOPSIS
    Expands a compressed archive (*.zip file) using the native facilities
    shipped with Windows and available out of the box.
.DESCRIPTION
    This will expand a compressed archive using the Windows shell, optionally
    showing either PowerShell or Windows (native UI) progress.
.EXAMPLE
    Expand-Zip 'C:\Users\Some User\somefile.zip'
.EXAMPLE
    Expand-Zip 'C:\Users\Some User\somefile.zip' 'C:\Users\Some User\Expanded\'
.PARAMETER ZipPath
    The path to the compressed archive to expand.
.PARAMETER Destination
    The path to the directory where the compressed files are expanded.
.PARAMETER StandardUI
    Use Windows' native UI for progress information and error dialogs.
.PARAMETER Force
    Answer "Yes to All" for any prompts that might have been displayed.
.NOTES
    Original Author: M. Shawn Dillon
#Requires -Version 2.0
#>
function Expand-Zip
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $ZipPath,
        [Parameter(Mandatory = $false)]
        [String] $Destination = (Join-Path `
            ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($ZipPath))) `
            ([IO.Path]::GetFileNameWithoutExtension($ZipPath))),
        [Switch] $StandardUI,
        [Switch] $Force
    )

    begin
    {
        # Make sure we're using a full path rather than a relative path.
        $Path = [IO.Path]::GetFullPath($ZipPath)

        # Create the destination if it does not exist.
        if ((Test-Path $Destination -PathType Container) -eq $false)
        {
            New-Item $Destination -ItemType Directory | Out-Null
        }

        $shellApplication = New-Object -COM Shell.Application
        $sourceFolder = $shellApplication.NameSpace($Path)
        $destinationFolder = $shellApplication.NameSpace($Destination)

        $FolderOptions = 0

        if ($Force -eq $true)
        {
            ## Respond with "Yes to All" for any dialog box that is displayed.
            $FolderOptions = $FolderOptions + 16
        }

        if ($StandardUI -eq $false)
        {
            ## Suppress the native UI and any error dialogs.
            $FolderOptions = $FolderOptions + 1028
        }
    }

    process
    {
        if ($StandardUI -eq $true)
        {
            ## Let Windows manage the operation.
            $destinationFolder.CopyHere($sourceFolder.Items(), $FolderOptions)
        }
        else
        {
            $itemCount = $sourceFolder.Items().Count
            $currentItem = 1

            Write-Progress `
                -Activity 'Expanding compressed archive' `
                -Status $Path

            foreach ($item in $sourceFolder.Items())
            {
                $percentComplete = ($currentItem / $itemCount) * 100

                Write-Progress `
                    -Activity 'Expanding compressed archive' `
                    -Status $Path `
                    -PercentComplete $percentComplete

                $destinationFolder.CopyHere($item, $FolderOptions)

                $currentItem = $currentItem + 1
            }

            Write-Progress `
                -Activity 'Expanding compressed archive' `
                -Status $Path `
                -Complete
        }
    }

    end
    {
        $destinationFolder = $null
        $sourceFolder = $null
        $shellApplication = $null
    }
}