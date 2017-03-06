$Date =  Get-Date -UFormat "%Y%m%d"
$BackupFolder = "G:\BackupFolder"
if ( (gci $BackupFolder).length -ge 2)
{ 
	write-host "Too much backup folders" -foregroundcolor yellow
	$Old = gci $BackupFolder | where name -like "Backup" | select CreationTime
	write-host $Old
	del $Old -confirm
}

new-item -path $BackupFolder -name "Backup$Date" -itemtype directory


workflow Backup 
{
	parallel
	{
		robocopy $source $dest /e /mt:100
	}
}

Backup

