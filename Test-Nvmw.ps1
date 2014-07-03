function Test-Nvmw
{
    try
    {
        $command = Get-Command nvmw.bat -ErrorAction SilentlyContinue

        return $true
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $false
    }
}