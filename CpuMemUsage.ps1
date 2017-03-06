<#
Detailed Description:
This scirpt is used to collect CPU, total memory, free memory and memory usage infomation on the server name input or server list provided, and output as a CSV file on your desktop by default, you can also input the result path.


Examples:
.\CpuMemUsage.ps1 .\serverlist.txt
.\CpuMemUsage.ps1 ServerName1,ServerName2
.\CpuMemUsage.ps1 ServerName
.\CpuMemUsage.ps1 ServerName d:\resultfolder
#>

param
(
	[Parameter(Position = 0)]
	[array] $paramServersM,
	[Parameter(Position = 1)]
	[string] $resultpath
	#[switch] $desktop

)

$arrayServersM = @()
if (($paramServersM -ne $null) -and (Test-Path -LiteralPath $paramServersM[0]))
{
    #If the input is serverlist file.
    $arrayServersM1 = type $paramServersM[0]
    $arrayServersM += $arrayServersM1
}
elseif ($paramServersM -eq $null)
{
	$arrayServersM1 = $env:computername
	$arrayServersM += $arrayServersM1
}
else
{
    #If the input is the delimited servers or server name wildcard.
    $arrayServersM += $paramServersM
}


$output1 = @()
$output1 = foreach ($server in $arrayServersM)
{
	try
	{
		$Date =  Get-Date -UFormat "%Y-%m-%d_%H-%M-%S"
		$CPU = get-counter -computername $server -Counter "\Processor(_Total)\% Processor Time" -erroraction silentlycontinue
		[int]$CPUUsage1 = ($cpu.readings -split ":")[-1]
		$CPUUsage =  "{0:0.0} %" -f $CPUUsage1
		
		$Memory = gwmi -ComputerName $server win32_OperatingSystem -erroraction silentlycontinue
		$TotalMemory = "{0:0.0} GB" -f ($Memory.TotalVisibleMemorySize  / 1MB)
		$FreeMemory = "{0:0.0} GB" -f ($Memory.FreePhysicalMemory  / 1MB)
		$MemoryUsage = "{0:0.0} %" -f ((($Memory.TotalVisibleMemorySize- `
		$Memory.FreePhysicalMemory)/$Memory.TotalVisibleMemorySize)*100)
	}
	catch
	{
		write-host "Can't connect to [$server], please manually check" -foregroundcolor yellow
	}
	$output = new-object psobject
	$output | Add-Member noteproperty DateTime $Date
	$output | Add-Member noteproperty Server $server
	$output | Add-Member noteproperty "CPU Usage" $CPUUsage
	$output | Add-Member noteproperty "Total Memory GB" $TotalMemory
	$output | Add-Member noteproperty "Free Memory GB" $FreeMemory
	$output | Add-Member noteproperty "Memory Usage" $MemoryUsage
	$output
}

$output2 += $output1

$finally = $output2 | select-object -property "DateTime",Server,"CPU Usage","Total Memory GB","Free Memory GB","Memory Usage"

$finally

if (#($desktop) -or 
($resultpath -eq $null) -or (!$resultpath))
{
	$finally | export-csv -notypeinformation -append -path "$home\Desktop\result.csv"
	write-host "The Result CSV has been successfully exported to $home\Desktop\result.csv" -foregroundcolor green
}
elseif (($resultpath) -and (test-path $resultpath))
{
	$finally | export-csv -notypeinformation -append -path "$resultpath\result.csv"
	write-host "The Result CSV has been successfully exported to $resultpath\result.csv" -foregroundcolor green
}
else
{
	New-Item -Path $resultpath -ItemType directory  -Force | out-null
	$finally | export-csv -notypeinformation -append -path "$resultpath\result.csv"
	write-host "The Result CSV has been successfully exported to $resultpath\result.csv" -foregroundcolor green
}


