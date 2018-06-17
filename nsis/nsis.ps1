param(
    [string]$scriptFile,
    [string]$arguments
)

foreach($key in $PSBoundParameters.Keys)
{
    Write-Host ($key + ' = ' + $PSBoundParameters[$key])
}

$path = split-path $MyInvocation.MyCommand.Path

$output = $path + "\nsis.zip"

$destination = $path + "\nsis"

if(!(Test-Path $destination)){

    $start_time = Get-Date

	Add-Type -assembly "system.io.compression.filesystem"

	[io.compression.zipfile]::ExtractToDirectory($output, $destination)

	$directories = Get-ChildItem -Path $destination
	$nsis3Directory = $directories[0].FullName
	
    Write-Output "Time taken (Unzip): $((Get-Date).Subtract($start_time).Seconds) second(s)"
} else {
	$directories = Get-ChildItem -Path $destination
	$nsis3Directory = $directories[0].FullName
}

$nsis3Exe = $nsis3Directory + "\makensis.exe"

$env:NSIS_EXE = $nsis3Exe
Write-Host("##vso[task.setvariable variable=NSIS_EXE;]$nsis3Exe")

$args = ''

if($arguments -notcontains "/V"){
    if($env:Debug -eq "true")
    {
        $args += "/V4 "
    }
    if($env:Debug -eq "false")
    {
        $args += "/V1 "
    }
}
$args += $arguments + ' "' + $scriptFile + '"'

Write-Host("Executing nsis $nsis3Exe with args: $args")

Invoke-Tool -Path $nsis3Exe -Arguments $args
