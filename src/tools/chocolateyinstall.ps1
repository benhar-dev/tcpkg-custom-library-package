# Define custom values
$libraryFileName = "MyCustomLibraryPlcProject.library"

# ----------------------------------------------------------------------------------------------
# This script installs a TwinCAT library using RepTool.exe
# It is designed to be run in the context of a Chocolatey package.
# Everything below this line is a script that will be executed and does not need to be modified.
# ----------------------------------------------------------------------------------------------

# Get the path to the library to install
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$fileLocation = Join-Path $toolsDir $libraryFileName

# Check file exists
if (-not (Test-Path $fileLocation)) {
	Write-Error "Library file not found: $fileLocation"
	exit 1
}

# Read TwinCAT install location from registry
$tcBasePath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Beckhoff\TwinCAT3" -Name "TwinCATDir").TwinCATDir

if (-not $tcBasePath) {
	Write-Error "Could not find TwinCAT base path in registry."
	exit 1
}

# Find the latest RepTool.exe under Build_4026.*
$searchPattern = Join-Path $tcBasePath "3.1\Components\Plc\Build_4026.*\Common\RepTool.exe"
$RepToolLocations = @(Get-Item $searchPattern -ErrorAction SilentlyContinue | Sort-Object FullName)

if ($RepToolLocations.Count -eq 0) {
	Write-Error "RepTool.exe not found in expected TwinCAT directories."
	exit 1
}

$RepToolLocation = $RepToolLocations[-1].FullName

# Extract PLC profile
$index = $RepToolLocation.IndexOf("Build_4026.")
$plcProfile = $RepToolLocation.Substring($index)
$index = $plcProfile.IndexOf("\Common\RepTool.exe")
$plcProfile = $plcProfile.Substring(0, $index)

# Prepare RepTool arguments
$RepToolArgs = @(
	"--profile=`"TwinCAT PLC Control_$plcProfile`"",
	"--installLib `"$fileLocation`""
)

# Run the installer
Start-Process $RepToolLocation -ArgumentList $RepToolArgs -Wait
