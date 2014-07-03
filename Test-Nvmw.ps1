function Test-Nvmw
{
    try
    {
        ## Calling it without arguments produces help text.
        $quickTest = nvmw.bat

        return $true
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        return $false
    }
}