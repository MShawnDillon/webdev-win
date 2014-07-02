@ECHO OFF
REM The SystemRoot environment variable is defined and set automatically in
REM all Windows installations. This is typically something like C:\Windows
%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "%~dp0get-to-work.ps1"
