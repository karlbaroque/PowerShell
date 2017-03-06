$Date = Get-Date -UFormat %Y%m%d
$Output = "$home\desktop\VMwareReport_$Date.csv"
$HostName = hostname

$VCenter = @( 
)


foreach ($VC in $VCenter) {
	Start-Job {
		Add-PSSnapin VMware.VimAutomation.Core
		Connect-VIServer $Using:VC | Out-Null
		
		$DataCenters = Get-Datacenter
		foreach ($DataCenter in $DataCenters) {
			$Clusters = Get-DataCenter $DataCenter | % {Get-Cluster -Location $_}
			foreach ($Cluster in $Clusters) {
				$DataStores = Get-Cluster $Cluster | Get-Datastore
				foreach ($DataStore in $DataStores){
					$ObjDS = [PSCustomObject][Ordered]@{
						VCenter = $Using:VC
						DataCenter = $DataCenter.Name
						Cluster = $Cluster.Name
						Type = "DataStore"
						Name = $DataStore.Name
						"CPU Count" = "N/A"
						"Memory(GB)" = "N/A"
						"MemoryUsage(GB)" = "N/A"
						"Capacity(GB)" = "{0:N1}" -f $DataStore.CapacityGB
						"FreeSpace(GB)" = "{0:N1}" -f $DataStore.FreeSpaceGB
						VLAN = "N/A"
						#IP = "N/A"
						OS = "N/A"
					}
					$ObjDS
				}
			
				$VMHosts = Get-Cluster $Cluster | Get-VMHost
				foreach ($VMHost in $VMHosts) {
					$VMHostCPU = ($VMHost | Get-View).Hardware.CpuInfo.NumCpuPackages
					$VMHostVLAN = ($VMHost | Get-VirtualPortGroup).Name | ? {$_ -notmatch "Management Network" -and $_ -notmatch "dvSwitch"}
					$VMHostVLAN = $VMHostVLAN -Join ","
					#$VMHostIP = ($VMHost | Get-VMHostNetworkAdapter | ? {$_.Name -eq "vmk0"}).IP
					$ObjVMHost = [PSCustomObject][Ordered]@{
						VCenter = $Using:VC
						DataCenter = $DataCenter.Name
						Cluster = $Cluster.Name
						Type = "VMHost"
						Name = $VMHost.Name.Replace(".paypalcorp.com","")
						"CPU Count" = $VMHostCPU
						"Memory(GB)" = "{0:N1}" -f $VMHost.MemoryTotalGB
						"MemoryUsage(GB)" = "{0:N1}" -f $VMHost.MemoryUsageGB
						"Capacity(GB)" = "N/A"
						"FreeSpace(GB)" = "N/A"
						VLAN = $VMHostVLAN
						#IP = $VMHostIP
						OS = ($VMHost | Get-View).Config.Product.FullName
					}
					$ObjVMHost
		
					$VMs = Get-VMHost $VMHost | Get-VM
					foreach ($VM in $VMs) {
						$VMVLAN = ($VM | Get-NetworkAdapter).NetworkName
						$VMVLAN = $VMVLAN -Join ","
						#$VMIP = $VM.Guest.IPAddress | ? {$_ -notmatch "[a-z]" -and $_ -notmatch "^169*"}
						$ObjVM = [PSCustomObject][Ordered]@{
							VCenter = $Using:VC
							DataCenter = $DataCenter.Name
							Cluster = $Cluster.Name
							Type = "VM"
							Name = $VM.Name.Replace(".paypalcorp.com","")
							"CPU Count" = $VM.NumCpu
							"Memory(GB)" = "{0:N1}" -f $VM.MemoryGB
							"MemoryUsage(GB)" = "N/A"
							"Capacity(GB)" = "N/A"
							"FreeSpace(GB)" = "N/A"
							VLAN = $VMVLAN
							#IP = $VMIP
							OS = $VM.Guest.OSFullName
						}
						$ObjVM
					}
				}
			}
		}
		Disconnect-VIServer $Using:VC -Force -Confirm:$False | Out-Null
	}
}

$Result = Get-Job | Wait-Job | Receive-Job | Select VCenter,DataCenter,Cluster,Type,Name,"CPU Count","Memory(GB)","MemoryUsage(GB)","Capacity(GB)","FreeSpace(GB)",VLAN,OS
$Result | Export-Csv $Output -NotypeInformation

