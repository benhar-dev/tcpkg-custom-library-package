# ----------------------------------------------------------------------------------------------
# This script is executed before the installation of a package.
# It is designed to clear the cache of TwinCAT libraries.
# It is designed to be run in the context of a Chocolatey package.
# Everything below this line is a script that will be executed and does not need to be modified.
# ----------------------------------------------------------------------------------------------

$manLibPath = Join-Path $env:ALLUSERSPROFILE 'Beckhoff\TwinCAT\PlcEngineering\Managed Libraries'

if (Test-Path -Path $manLibPath) {
    Get-ChildItem -Path $manLibPath -Filter 'cache*' -Recurse -File | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
    }
}
