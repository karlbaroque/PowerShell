<#
Syntax .\DiskUsage.ps1 [-ThresholdFreePercentage [0.0000-1.0000]] -serverslist

.\DiskUsage.ps1
.\DiskUsage.ps1 25 Server01
.\DiskUsage.ps1 -ThresholdFreePercentage 25 -serverslist .\sl.txt
.\DiskUsage.ps1 -ThresholdFreePercentage 25 -serverslist Server01,Server02
#>
param (
[string]$ThresholdFreePercentage="100",
$serverslist
) #if not defined the ThresholdFreePercentage, it will get all drives on all servers

if(!$serverslist){$serverslist=$env:COMPUTERNAME}elseif(test-path $serverslist[0]){$serverslist=get-content $serverslist}

Function GetSeversList
{ $Timestamp=(Get-Date -Format yyyyMMddhhmmss).toString()
  $FilePath=".\DiskUsageReport-$Timestamp.csv"
  $DisksData=@()
  foreach($server in $serverslist)
  {
    try{
        $Drives=Get-WmiObject -computerName $server -Class Win32_logicaldisk -filter "drivetype=3"  -ErrorAction Stop 
        #$Drives
  		foreach($Drive in $Drives)
  		{         
  		 $SizeGB=$Drive | Select-Object -ExpandProperty Size    
  		 $FreeGB=$Drive | Select-Object -ExpandProperty FreeSpace
  		 $FreePercentage=($FreeGB/$SizeGB)*100
         $FreePercentage="{0:N2}" -f $FreePercentage	 

  		 if([double]$FreePercentage -le [double]$ThresholdFreePercentage)
  		    {  
            $tempDisk=New-Object psobject
            $FreePercentage=[string]$FreePercentage+"%"
  			$SizeGB=$SizeGB/1GB
  			$FreeGB=$FreeGB/1GB
  			$UsedGB=$SizeGB-$FreeGB
  			$SizeGB="{0:N2}" -f $SizeGB    
  			$FreeGB="{0:N2}" -f $FreeGB    
  			$UsedGB="{0:N2}" -f $UsedGB  
            $tempDisk|Add-Member noteproperty "ServerName" $Drive.SystemName -force
            $tempDisk|Add-Member noteproperty "Drive" $Drive.DeviceID -force
            $tempDisk|Add-Member noteproperty "FreePercentage" $FreePercentage -force
            $tempDisk|Add-Member noteproperty "FreeGB" $FreeGB -force
            $tempDisk|Add-Member noteproperty "SizeGB" $SizeGB -force
            $tempDisk|Add-Member noteproperty "UsedGB" $UsedGB -force
            $DisksData=$DisksData+$tempDisk            
  			}
          }
  	 }
       Catch [Exception] #Catch PRC is unavailable exception
  			{
  			 Write-Host -ForegroundColor Red "$server cannot be reached" #Reminder            
             $tempDisk=New-Object psobject
  			 $tempDisk|Add-Member noteproperty "ServerName" "$server cannot be reached" -force
             $tempDisk|Add-Member noteproperty "Drive" "N#A" -force
             $tempDisk|Add-Member noteproperty "FreePercentage" "N#A" -force
             $tempDisk|Add-Member noteproperty "FreeGB" "N#A" -force
             $tempDisk|Add-Member noteproperty "SizeGB" "N#A" -force
             $tempDisk|Add-Member noteproperty "UsedGB" "N#A" -force
             $DisksData=$DisksData+$tempDisk
  			}        
   }
  $DisksData | Select-Object -Property ServerName,Drive,FreePercentage,FreeGB,SizeGB,UsedGB | FT -Wrap -AutoSize   
  try{
  $DisksData | Select-Object -Property ServerName,Drive,FreePercentage,FreeGB,SizeGB,UsedGB|Export-Csv -NoTypeInformation -Path $FilePath -ErrorAction Stop
  $ReportPath=$FilePath|Convert-Path
  Write-Host -ForegroundColor Green "Report generated at $ReportPath"
      }catch{Write-Host -ForegroundColor red "Report generated failed: $_.exception.message"} 
  
}

GetSeversList #Calling function
