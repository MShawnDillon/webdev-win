<#
.SYNOPSIS
   Invokes the specified batch file (*.bat or *.cmd file) and retains any
   environment variable changes it makes.
.DESCRIPTION
   Invoke the specified batch file (with parameters), but also propagate any
   environment variable changes back to the PowerShell environment that
   called it.
.PARAMETER Path
   Path to a *.bat or *.cmd file.
.PARAMETER Arguments
   Command line arguments to pass to the batch file. Multiple arguments are
   separated by spaces, and you must escape any quoted strings (quoted
   strings are interpreted by cmd.exe as a single argument, allowing
   individual arguments, such as file system paths, to contain spaces).
.EXAMPLE
   C:\PS> Invoke-BatchFile "$env:VS90COMNTOOLS..\..\vc\vcvarsall.bat"
   Invokes the vcvarsall.bat file to set up a 32-bit development environment
   using the Visual Studio 2008 Command Prompt tools. All environment
   variable changes it makes will be propagated to the current PowerShell
   session.
.EXAMPLE
   C:\PS> Invoke-BatchFile "$env:VS90COMNTOOLS..\..\vc\vcvarsall.bat" amd64
   Invokes the vcvarsall.bat file to set up a 64-bit development environment
   using the Visual Studio 2008 Command Prompt tools. All environment
   variable changes it makes will be propagated to the current PowerShell
   session.
.EXAMPLE
   Given the following batch file named 'Hello World.bat':

   @ECHO Hello, world! The first argument is %1, and the second is %2.

   C:\PS> Invoke-BatchFile '.\Hello World.bat' "`"Arg #1`" `"Arg #2`""
   Hello, world! The first argument is "Arg #1", the second is "Arg #2".

   Notice the escaped quotes in the Arguments parameter.
.NOTES
   Original Author: Lee Holmes
   Extended Author: M. Shawn Dillon
#>
function Invoke-BatchFile
{
    param (
        [Parameter(Mandatory = $true)]
        [String] $Path,
        [Parameter(Mandatory = $false)]
        [String] $Arguments
    )

    begin
    {
        $tempFile = [IO.Path]::GetTempFileName()
    }

    process
    {
        ## Store the output of cmd.exe. We also ask cmd.exe to output the
        ## environment table after the batch file completes.
        CMD.EXE /C "`"`"$Path`" $Arguments && SET > `"$tempFile`"`""

        ## Go through the environment variables in the temp file. For each of
        ## them, set the variable in our local environment.
        Get-Content $tempFile | Foreach-Object {
            if ($_ -match "^(.*?)=(.*)$")
            {
                Set-Content "Env:\$($matches[1])" $matches[2]
            }
        }
    }

    end
    {
        Remove-Item $tempFile
    }
}
