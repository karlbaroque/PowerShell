#-------------------------------------------------------------------------------------------#
#The purpose of this script is to gain the current websites status on particular server(s). #
#-------------------------------------------------------------------------------------------#
# Examples:
# IISInfo.ps1 Server
# IISInfo.ps1 Server1, Server2, Server3...
# IISInfo.ps1 .\Servers.txt
#-------------------------------------------------------------------------------------------#


#***Define Parameters***
param (
	[Parameter(Position = 0)]
	[array] $paramServers
)

$ServerListPath = @()

if (($paramServers -ne $null) -and ($paramServers[0] -like "*.txt"))
{
    #***If the input is an server list with a TXT file***
    $ServerListPath = @(type $paramServers[0] | ?{$_.trim() -ne ''} | %{$_.trim()})
}
elseif ($paramServers -eq $NULL)
{
	#***If no parameter followed***
	$paramServers = $env:ComputerName
	$ServerListPath += $paramServers
}
else
{
    #***If the input is the delimited servers or a single server name***
    $ServerListPath += $paramServers
}

#***Export the result to a CSV file***
Function ExCSV
{
	$AsDate=(get-date).ToString("yyyyMMddhhmmss")
	$CSVResultAll = foreach($servername in $ServerListPath)
	{ 
		Invoke-Command -ComputerName $servername -ScriptBlock {
			param($servername) 
			Import-Module WebAdministration
			[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
			$CSVIIS = New-Object Microsoft.Web.Administration.ServerManager
			$CSVItems = $CSVIIS.sites
			$CSVSiteName = Get-Website | Select-Object @{Name="Name";Expression={$_.name}}
			$CSVSiteID = Get-Website | Select-Object @{Name="ID";Expression={$_.id}}
			$CSVSiteStatus = Get-Website | Select-Object @{Name="Status";Expression={$_.state}}
			$CSVSitePath =Get-Website | Select-Object @{Name="PhysicalPath";Expression={$_.physicalpath}}
			$CSVSiteBinding =Get-Website | Select-Object @{Name="Bindings";Expression={$_ | Select-Object -ExpandProperty bindings | Select-Object -ExpandProperty collection | Select-Object -ExpandProperty bindinginformation}}
			$CSVSiteAppPool =$CSVItems | Select-Object @{Name="AppPool";Expression={$_ | Select-Object -ExpandProperty Applications | Select-Object -ExpandProperty ApplicationPoolName}}
			
			#***Output as an object***
			$n=0
			$CSVResult1=@()
			do
			{
				$CSVResult = new-object psobject
				$CSVResult | Add-Member noteproperty "Computer" $servername
				$CSVResult | Add-Member noteproperty "Name" $CSVSiteName[$n].name
				$CSVResult | Add-Member noteproperty "ID" $CSVSiteID[$n].id
				$CSVResult | Add-Member noteproperty "Status" $CSVSiteStatus[$n].status
				$CSVResult | Add-Member noteproperty "PhysicalPath" $CSVSitePath[$n].PhysicalPath
				$CSVResult | Add-Member noteproperty "Bindings" $CSVSiteBinding[$n].bindings
				if ($CSVSiteAppPool[$n].AppPool.count -eq 1)
				{
					#***If $CSVSiteAppPool.AppPool is an object***
					$CSVResult | Add-Member noteproperty "AppPool" $CSVSiteAppPool[$n].AppPool
				}
				else
				{
					#***If $CSVSiteAppPool.AppPool is an array***
					$CSVResult | Add-Member noteproperty "AppPool" $CSVSiteAppPool[$n].AppPool[0]
				}
				$n++
				$CSVResult1+=$CSVResult
			}While ($CSVSiteName[$n] -ne $NULL)
			$CSVResult1
		} -ArgumentList $servername;
	}
	$CSVResultAll | Select-Object -Property Computer, Name, ID, Status, PhysicalPath, Bindings, AppPool | Export-CSV -notypeinformation -Delimiter "," -path .\$AsDate.csv
}

#***Print the result in current PowerShell window***
Function PrintResult
{
	$PrintResultAll=Foreach($servername in $ServerListPath)
	{ 
		Invoke-Command -ComputerName $servername -ScriptBlock {
			param($servername) 
			Import-Module WebAdministration
			[void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
			$PrintIIS = New-Object Microsoft.Web.Administration.ServerManager
			$PrintItems = $PrintIIS.sites
			$PrintSiteName = Get-Website | Select-Object @{Name="Name";Expression={$_.name}}
			$PrintSiteID = Get-Website | Select-Object @{Name="ID";Expression={$_.id}}
			$PrintSiteStatus = Get-Website | Select-Object @{Name="Status";Expression={$_.state}}
			$PrintSitePath =Get-Website | Select-Object @{Name="PhysicalPath";Expression={$_.physicalpath}}
			$PrintSiteBinding =Get-Website | Select-Object @{Name="Bindings";Expression={$_ | Select-Object -ExpandProperty bindings | Select-Object -ExpandProperty collection | Select-Object -ExpandProperty bindinginformation}}
			$PrintSiteAppPool =$PrintItems | Select-Object @{Name="AppPool";Expression={$_ | Select-Object -ExpandProperty Applications | Select-Object -ExpandProperty ApplicationPoolName}}
			
			#***Output as an object***
			$n=0
			$PrintResult1=@()
			do
			{
				$PrintResult = new-object psobject
				$PrintResult | Add-Member noteproperty "Computer" $servername
				$PrintResult | Add-Member noteproperty "Name" $PrintSiteName[$n].name
				$PrintResult | Add-Member noteproperty "ID" $PrintSiteID[$n].id
				$PrintResult | Add-Member noteproperty "Status" $PrintSiteStatus[$n].status
				$PrintResult | Add-Member noteproperty "PhysicalPath" $PrintSitePath[$n].PhysicalPath
				$PrintResult | Add-Member noteproperty "Bindings" $PrintSiteBinding[$n].bindings
				if ($PrintSiteAppPool[$n].AppPool.count -eq 1)
				{
					#***If $PrintSiteAppPool.AppPool is an object***
					$PrintResult | Add-Member noteproperty "AppPool" $PrintSiteAppPool[$n].AppPool
				}
				else
				{
					#***If $PrintSiteAppPool.AppPool is an array***
					$PrintResult | Add-Member noteproperty "AppPool" $PrintSiteAppPool[$n].AppPool[0]
				}
				$n++
				$PrintResult1+=$PrintResult
			}While ($PrintSiteName[$n] -ne $NULL)
			Write-Host "--------------------------------------------------------------------------------" -foregroundcolor Green
			Write-Host "$servername" -foregroundcolor Green
			Write-Host "--------------------------------------------------------------------------------" -foregroundcolor Green			
			$PrintResult1
		} -ArgumentList $servername;
	}
	$PrintResultAll
}

ExCSV
PrintResult
