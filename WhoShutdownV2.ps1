<#
Syntax:
.\WhoShutdownV2.ps1 server [int]lastNdays [string]outfilePath
.\WhoShutdownV2.ps1 -servers -lastNdays -outfile
.\WhoShutdownV2.ps1 <default is localhost with last 30 days log, no csv output>
#>


param 
([array]$servers,[int]$lastNdays=30,[string]$outfile)

$localhost=hostname
if($servers -eq $null){$servers=$localhost}
$lastNdays=0-$lastNdays
Write-Host ----------------------------

$arrayR=@()
foreach($server in $servers)
 { 
  try {
        $log=Get-EventLog -ComputerName $server -LogName system -After (get-date).AddDays($lastNdays) -ErrorAction Stop #get last month logs
        $log=$log | where {$_.EventID -eq 1074} #shutdown event
        foreach($_ in $log)
         {
          $Report= New-Object psobject
          $eventtime=$_.TimeGenerated
          $detail=$_.Message
          #------------------------
          $username=$detail -match "of user (?<user>.*) for the following reason"
          if($username){$username=$Matches['user']}
          $shutdowntype=$detail -match "Shutdown Type: (?<type>.*)`n"
          if($shutdowntype){$shutdowntype=($Matches['type']).ToUpper()}
          $reason=$detail -match "reason: (?<reason>.*)`n"
          if($reason){$reason=$Matches['reason']}
          $comment=$detail -match "Comment:(?<comment>.*)"
          if($comment){$comment=$Matches['comment']}
          #<#
          $Report | Add-Member noteproperty "Time" $eventtime -Force
          $Report | Add-Member noteproperty "Who" $username -Force
          $Report | Add-Member noteproperty "Action" $shutdowntype -Force
          $Report | Add-Member noteproperty "Reason" $reason -Force
          $Report | Add-Member noteproperty "Comment" $comment -Force
          $arrayR+=$Report                                
          ##>
          #$frag="$eventtime $username $shutdowntype Reason:$reason Comment:$comment"
          #$frag

          <#if($shutdowntype.tostring() -match 'RESTART'){write-host -ForegroundColor White $frag}
            elseif($shutdowntype.tostring() -match 'SHUTDOWN'){ write-host -ForegroundColor $frag}
             elseif($shutdowntype.tostring() -match 'POWER OFF'){write-host -ForegroundColor Red $frag}
         #>
         
         }         
       }catch{Write-Host -ForegroundColor red $server.ToUpper() $_.exception.message}
       
 }

 $arrayR | Select-Object -Property Who,Time,Action,Reason,Comment | Format-Table -Wrap -AutoSize
 if($outfile){try{$arrayR | Export-Csv -notypeinformation -path $outfile}catch{Write-Host -ForegroundColor Red Generate Report failed: $_.exception.message}}
