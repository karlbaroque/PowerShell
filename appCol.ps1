#=============================================================================# 
#                                                                             # 
# Powershell Script to collect app installation infomation on remote          # 
# Date: 30.10.2014                                                            #
# Usage:  .\appCol.ps1 -serverlist ServerName                     			  #
#                                                                             # 
#=============================================================================# 

Param
(
    $serverlist,
    $Publisher,
    $Appname,
    $Installdate,
    $outfile
)

$arr = @()

if($serverlist)
{

foreach ($server in Get-Content $serverlist)
{ 

	$arr2 = @()
$arr2= invoke-command -ComputerName $server -ScriptBlock {param($Publisher,$Appname)
    

    $appinfo = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |Where {$_.displayname -ne $null}|Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

	
	$output = new-object psobject
    foreach($app in $appinfo)

	{
		$appname  = $app.DisplayName
		$appversion = $app.DisplayVersion
		$apppublisher = $app.Publisher
		$installdate = $app.installdate
        $sn=Hostname
		$output | Add-Member noteproperty "ServerName" $sn -Force
		$output | Add-Member noteproperty "AppName" $appname -Force
		$output | Add-Member noteproperty "Version" $appversion -Force
		$output | Add-Member noteproperty "Publisher" $apppublisher -Force
		$output | Add-Member noteproperty "InstallDate" $installdate -Force
		$output
	}

}-ArgumentList($Publisher,$Appname)

$arr1 += $arr2
}

If($Publisher){ $arr3 =$arr1|Where {$_.publisher -eq $Publisher}|Select-Object -Property ServerName,AppName,Version,Publisher,InstallDate
}
elseif($Appname) { $arr3 =$arr1|Where {$_.AppName -eq $Appname}|Select-Object -Property ServerName,AppName,Version,Publisher,InstallDate}
else{$arr3 =$arr1|Select-Object -Property ServerName,AppName,Version,Publisher,InstallDate} 

If($outfile)
{
$arr3 | export-csv -notypeinformation -path $outfile
}
Else{$arr3}
}

Else
{write-host "Please arrage a serverlist" -foregroundcolor red}
