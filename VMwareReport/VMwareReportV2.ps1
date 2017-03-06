#Variable declaration
$OutputPath="C:\vm_automation\Reports\" #Location where you want to place generated report
add-pssnapin VMware.VimAutomation.Core
$Datefile = ( get-date ).ToString('yyyy-MM-dd-hhmmss')
Start-transcript -Path C:\Transcript\CorpDaily_$Datefile.txt -force 
$servers = @();
Connect-VIServer -Server $servers
#This is the CSS used to add the style to the report
$Css="<style>
body {
    font-family: Verdana, sans-serif;
    font-size: 9px;
	color: #666666;
	background: #FEFEFE;
}
#title{
	color:#90B800;
	font-size: 20px;
	font-weight: bold;
	padding-top:25px;
	margin-left:35px;
	height: 50px;
}
#subtitle{
	font-size: 11px;
	margin-left:35px;
}
#main{
	position:relative;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#box1{
	position:absolute;
	background: #F8F8F8;
	border: 1px solid #DCDCDC;
	margin-left:10px;
	padding-top:10px;
	padding-left:10px;
	padding-bottom:10px;
	padding-right:10px;
}
#boxheader{
	font-family: Arial, sans-serif;
	padding: 5px 20px;
	position: relative;
	z-index: 20;
	display: block;
	height: 30px;
	color: #777;
	text-shadow: 1px 1px 1px rgba(255,255,255,0.8);
	line-height: 12px;
	font-size: 9px;
	background: #fff;
	background: -moz-linear-gradient(top, #ffffff 1%, #eaeaea 100%);
	background: -webkit-gradient(linear, left top, left bottom, color-stop(1%,#ffffff), color-stop(100%,#eaeaea));
	background: -webkit-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -o-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: -ms-linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	background: linear-gradient(top, #ffffff 1%,#eaeaea 100%);
	filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#ffffff', endColorstr='#eaeaea',GradientType=0 );
	box-shadow: 
		0px 0px 0px 1px rgba(155,155,155,0.3), 
		1px 0px 0px 0px rgba(255,255,255,0.9) inset, 
		0px 2px 2px rgba(0,0,0,0.1);
}

table{
	width:100%;
	border-collapse:collapse;
}
table td, table th {
	border:1px solid #2198BF;
	padding:3px 7px 2px 7px;
}
table th {
	text-align:left;
	padding-top:5px;
	padding-bottom:4px;
	background-color:#2198BF;
color:#fff;
}
table tr.alt td {
	color:#000;
	background-color:#D3EAF2;
}
</style>"
#These are divs declarations used to properly style HTML using previously defined CSS
$PageBoxOpener="<div id='box1'>"
$VmDisconnectedHostsHeader="<div id='boxheader'>Disconnected and Non Responding Hosts </div>"
#$ReportVmHost="<div id='boxheader'>Get-VMHost $LocationName</div>"
$BoxContentOpener="<div id='boxcontent'>"
$PageBoxCloser="</div>"
$br="<br>" #This should have been defined in CSS but if you need new line you could also use it this way
$VMsCreatedByHeader="<div id='boxheader'>VMs created in the last 7 days.</div>"
#$VMsCreated7DaysHeader="<div id='boxheader'>Created Hardware, in the last 7 days</div>"
$VMsRemoved7DaysHeader="<div id='boxheader'>VMs removed in the last 7 days.</div>"
#$ReportGetCluster="<div id='boxheader'>Get-Cluster $ClusterName</div>"
$VMSnapshotsLastMonthHeader="<div id='boxheader'>Snapshots Created in the last 30 days.</div>"
#$ReportGetVmCluster="<div id='boxheader'>Get-VM $ClusterName</div>"
$VMSnapshotsOlderHeader="<div id='boxheader'>Snapshots older than 30 days.</div>"
#Get VMHost infos
$VmDisconnectedHosts = Get-VMHost | Where-Object {$_.ConnectionState -ne "Connected" -and $_.ConnectionState -ne "Maintenance"} | Select Name,ConnectionState,@{N="Cluster";E={Get-Cluster -VMHost $_}},@{Name="vCenter";E={$_.ExtensionData.CLient.ServiceUrl.Split('/')[2]}} | ConvertTo-HTML -Fragment
# $VmHost=Get-VMHost -Location $LocationName | Select-Object @{Name = 'Host'; Expression = {$_.Name}},State,ConnectionState,PowerState,Model,Version,Build,NumCpu,@{Name = 'CpuTotalGhz'; Expression = {"{0:N2}" -f ($_.CpuTotalMhz/1000)}},@{Name = 'CpuUsageGhz'; Expression = {"{0:N2}" -f ($_.CpuUsageMhz/1000)}},@{Name = 'MemoryTotalGB'; Expression = {"{0:N2}" -f $_.MemoryTotalGB}}, @{Name = 'MemoryUsageGB'; Expression = {"{0:N2}" -f $_.MemoryUsageGB}} | ConvertTo-HTML -Fragment
#Get VM Events
$vms = get-vm
	$vmevts = @()
	$vmevt = new-object PSObject
   foreach ($vm in $vms) {
      # Progress bar:
      $foundString = "Found: "+$vmevt.name+"   "+$vmevt.createdTime+"   "+$vmevt.IPAddress+"   "+$vmevt.createdBy
      $searchString = "Searching: "+$vm.name
      $percentComplete = $vmevts.count / $vms.count * 100
      write-progress -activity $foundString -status $searchString -percentcomplete $percentComplete
      $evt = get-vievent $vm | where {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"}
      $vmevt = new-object PSObject
      $vmevt | add-member -type NoteProperty -Name createdTime -Value $evt.createdTime
      $vmevt | add-member -type NoteProperty -Name name -Value $vm.name
      $vmevt | add-member -type NoteProperty -Name IPAddress -Value $vm.Guest.IPAddress[0]
      $vmevt | add-member -type NoteProperty -Name createdBy -Value $evt.UserName
      $vmevt | add-member -type NoteProperty -Name NICType -Value (Get-NetworkAdapter -vm $vm | select -Property Type)
      $vmevt | add-member -type NoteProperty -Name VLAN -Value (Get-NetworkAdapter -vm $vm | select -Property NetworkName)
      $vmevt | add-member -type NoteProperty -Name PowerState -Value $vm.PowerState
      $vmevt | add-member -type NoteProperty -Name ResourcePool -Value $vm.ResourcePool
      $vmevt | add-member -type NoteProperty -Name HardwareVersion -Value $vm.Version
      $vmevt | add-member -type NoteProperty -Name MemoryGB -Value $vm.MemoryGB
      $vmevt | add-member -type NoteProperty -Name CPU -Value $vm.NumCPU
      $vmevt | add-member -type NoteProperty -Name OperatingSystem -Value $vm.ExtensionData.Summary.Guest.GuestFullName
      $vmevts += $vmevt
	}
$vmevts | sort createdTime
$vmsname7days = $vmevts | where {$_.createdTime -gt ((Get-Date).AddDays(-7))}
$VMsCreatedBy = $vmsname7days | select * | ConvertTo-HTML -Fragment
#$VMsCreated7Days = foreach(vmcreated in (Get-VM -Name $vmsname7days.Name){Select Name,MemoryGB,@{N="Network Adapter";E={$_.NetworkAdapters| foreach-object {$_.Type}}}, @{N="MacAddress";E={$_.NetworkAdapters| ForEach-Object {$_.MacAddress}}}, @{N="PortGroup";E={Get-VirtualPortGroup -VM $_}},ResourcePool,Version,PowerState} | ConvertTo-HTML -Fragment
$VMsRemoved7Days = Get-VIEvent -maxsamples 10000 -Start (Get-Date).AddDays(-7) | where {$_.Gettype().Name-eq "VmRemovedEvent"} | Sort CreatedTime -Descending | Select CreatedTime, UserName,FullformattedMessage | ConvertTo-HTML -Fragment
# $GetCluster=Get-Cluster -Name $ClusterName | Select-Object Name, HAEnabled, HAIsolationResponse,@{Name = 'DRS Enabled'; Expression = {$_.DrsEnabled}},@{Name = 'DRS'; Expression = {$_.DrsAutomationLevel}},VsanEnabled,VsanDiskClaimMode | ConvertTo-HTML -Fragment
#Get VM infos
$VMSnapshotsLastMonth = Get-VM | Get-Snapshot | Where {$_.Created -gt ((Get-Date).AddDays(-30))} | Sort Created | Select @{N="VMHOST";E={Get-VMHost -VM $_.vm}},VM,Name,Description,Created,SizeGBParent,ParentSnapshotID,ParentSnapshot,Children | ConvertTo-HTML -Fragment
$VMSnapshotsOlder = Get-VM | Get-Snapshot | Where {$_.Created -lt ((Get-Date).AddDays(-30))} | Sort Created | Select @{N="VMHOST";E={Get-VMHost -VM $_.vm}},VM,Name,Description,Created,SizeGBParent,ParentSnapshotID,ParentSnapshot,Children | ConvertTo-HTML -Fragment
#Send A HTML Report
$smtp = ""
$to = ""
$from = ""
$subject = "Morning report on the Last 7 Days"
$body = ConvertTo-Html -Title "Daily Morning Report" -Head "<div id='title'>VMware Report</div>$br<div id='subtitle'>Report generated: $(Get-Date)</div>
" -Body " $Css $PageBoxOpener $VmDisconnectedHostsHeader $BoxContentOpener $VmDisconnectedHosts $br $VMsCreatedByHeader $BoxContentOpener $VMsCreatedBy $PageBoxCloser $br $VMsRemoved7DaysHeader $BoxContentOpener $VMsRemoved7Days $PageBoxCloser $br $VMSnapshotsLastMonthHeader $BoxContentOpener $VMSnapshotsLastMonth $PageBoxCloser $br $VMSnapshotsOlderHeader $BoxContentOpener $VMSnapshotsOlder $PageBoxCloser $br $PageBoxCloser $br"| Out-String 
ConvertTo-Html -Title "Daily Morning Report" -Head "<div id='title'>VMware Report</div>$br<div id='subtitle'>Report generated: $(Get-Date)</div>
" -Body " $Css $PageBoxOpener $VmDisconnectedHostsHeader $BoxContentOpener $VmDisconnectedHosts $br $VMsCreatedByHeader $BoxContentOpener $VMsCreatedBy $PageBoxCloser $br $VMsRemoved7DaysHeader $BoxContentOpener $VMsRemoved7Days $PageBoxCloser $br $VMSnapshotsLastMonthHeader $BoxContentOpener $VMSnapshotsLastMonth $PageBoxCloser $br $VMSnapshotsOlderHeader $BoxContentOpener $VMSnapshotsOlder $PageBoxCloser $br $PageBoxCloser $br"| Out-file -FilePath $OutputPath\Last7Report_$Datefile.html
### Now send the email using \> Send-MailMessage  
send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Priority high 
Stop-transcript
Disconnect-VIServer "*" -confirm:$false