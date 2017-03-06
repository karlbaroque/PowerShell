[CmdletBinding()] 
param ($servername, $serverlist, $output, [switch] $scan, [switch] $help)

$usage = @'
###############################################################################
##  DESCRIPTION:  Return VM to Hyper-V mapping
##
##  INPUTS: 
##     -ServerName [String] Server to check.  Multiple server can be listed, 
##                          seperated by comma.
##     -ServerList [FileName] File to read list of server(s), one server per
##                            line.
##     -Output     [FileName] File to write output to.  Output is in CSV 
##                            format.
##     -Scan	   Scan Active Directory for Hyper-V servers
##     -Help       Display help.
##     -Verbose	   Verbose output
##
##  OUTPUTS:
##     Object(s) with the following properites:
##	-Host	   Host Server name
##	-Model	   Host Server model
##	-Serial	   Host Server serial #
##	-Memory    Host RAM in MB
##	-Proc	   Host # of Logical processor
##	-Error	   Error Messages
##	-vmName	   Virtual Machine name
##	-vmStatus  Virtual Machine Status
##	-vmMemory  Virtual Machine RAM in MB
##
##  USAGE:  
##     .\Get-HyperV2.ps1 -ServerName 'Server01,Server02'
##     .\Get-HyperV2.ps1 -ServerList servers.txt -Output results.csv -Verbose
##     .\Get-HyperV2.ps1 -Scan -Output results.csv
##     
##  Note: 
##     If Scan option is used, server list will be ignored.
##
'@
################################################################################
##  Revision Date: 2014/04/07
################################################################################

############# Functions ###################
function Get-HyperVServers {

    # Always get the domain name from the local computer and never from the
    # user's environment. The user may be a trusted user from another forest.
    
    $domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
    $rootDSE = [ADSI]('LDAP://{0}/RootDSE' -f $domain)
    $searchBase = [ADSI]('LDAP://{0}/{1}' -f $domain, $rootDSE.defaultNamingContext[0])

    # Look for servers that have a Microsoft Hyper-V service connection point.
    
    $searcher = New-Object System.DirectoryServices.DirectorySearcher($searchBase)
    $searcher.Filter = '(&(cn=Microsoft Hyper-V)(objectClass=serviceConnectionPoint))'
    $searcher.FindAll() |
        % { ([ADSI]$_.Path).PSBase.Parent.dNSHostName } |
        Sort-Object

}

function Ping-Server ($computer=$env:computername) {
	test-connection -computername $computer -Count 1 -Quiet -ErrorAction SilentlyContinue
}

############# Initialize ##################
Write-Verbose  $('[Initializing]')
$vms = @()
$servers = @()

if ($servername) {
    foreach ($server in $servername.split(',')) {
        Write-Verbose $('Adding {0}' -f $server.Trim())
        $servers += $server.Trim()
    }
}

if ($serverlist) {
    if (test-path $serverlist) {
        foreach ($server in (Get-Content $serverlist)) {
            Write-Verbose $('Adding {0}' -f $server.Trim())
            $servers += $server.Trim()
        }
    } else {
        write $('Server list {0} not found' -f $serverlist)
    }
}

if ($scan) {
	$servers = Get-HyperVServers
}

if (!($servers) -or ($help)) {
    write $usage
    exit
}

############# Main ##################
Write-Verbose $('Checking {0} servers...' -f $servers.count)

foreach ($server in $servers) {
    Write-Verbose $('Scanning {0}' -f $server)
        $computerSystem = $null
        $bios = $null
        $virtualMachines = $null
	$ErrMsg = $null

	if (Ping-Server $server) {
        $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server -ErrorAction SilentlyContinue -ErrorVariable err
        $bios = Get-WmiObject -Class Win32_Bios -ComputerName $server -ErrorAction SilentlyContinue -ErrorVariable err
        $virtualMachines = Get-WmiObject -ComputerName $server -Namespace root\virtualization -Class Msvm_ComputerSystem -Filter 'processId >= 0'

	if ($err) {$ErrMsg = $Err[0].ToString()}
	

        $memory = [int]($computerSystem.TotalPhysicalMemory / 1MB)
        $model = $computerSystem.Model
        $proc = $computerSystem.NumberOfLogicalProcessors
        $serial = $bios.SerialNumber

        if ($virtualMachines) {
            $virtualMachines | Sort-Object ElementName |
                % {
                    $serverObj = New-Object PSObject
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Host" -Value $server
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Model" -Value $model
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Serial" -Value $serial
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Memory" -Value $memory
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Proc" -Value $proc
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Error" -Value $ErrMsg
            
                    $settings = Get-WmiObject -Computer $server -Namespace root\virtualization -Class Msvm_VirtualSystemSettingData -Filter "SystemName='$($_.Name)' AND SettingType=3"
                    $memorySettings = Get-WmiObject -Computer $server -Namespace root\virtualization -Query "ASSOCIATORS OF {$($settings.__PATH)} Where AssocClass=Msvm_VirtualSystemSettingDataComponent Role=GroupComponent ResultClass=Msvm_MemorySettingData"

                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmName" -Value $_.ElementName
                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmStatus" -Value $_.OperationalStatus[0]
                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmMemory" -Value $memorySettings.VirtualQuantity
                    $vms += $serverObj
                }
        } else {
                    $serverObj = New-Object PSObject
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Host" -Value $server
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Model" -Value $model
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Serial" -Value $serial
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Memory" -Value $memory
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Proc" -Value $proc
                    $serverObj | Add-Member -MemberType NoteProperty -Name "Error" -Value $ErrMsg
                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmName" -Value $null
                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmStatus" -Value $null
                    $serverObj | Add-Member -MemberType NoteProperty -Name "vmMemory" -Value $null
                    $vms += $serverObj            
        }
    } else {
        $serverObj = New-Object PSObject
        $serverObj | Add-Member -MemberType NoteProperty -Name "Host" -Value $server
        $serverObj | Add-Member -MemberType NoteProperty -Name "Model" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "Serial" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "Memory" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "Proc" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "Error" -Value "Failed Ping"
        $serverObj | Add-Member -MemberType NoteProperty -Name "vmName" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "vmStatus" -Value $null
        $serverObj | Add-Member -MemberType NoteProperty -Name "vmMemory" -Value $null
        $vms += $serverObj
    }
}

if ($output) {
    $vms | export-csv $output -notype
} else {
    $vms
}
