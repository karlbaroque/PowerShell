#Define const
if (!(Test-Path $PSScriptRoot\SN.txt)) {Write-Error "No SN file detected, quit"; pause; exit }
$SN = gc $PSScriptRoot\SN.txt
$URL = "http://h20564.www2.hpe.com/hpsc/wc/public/addRows"
$Date = Get-Date -UFormat "%Y%m%d"
$Time = Get-Date
$ResultHTML = "$PSScriptRoot\HPWarranty_$Date.html"
$ResultXLSX = "$PSScriptRoot\HPWarranty_$Date.xlsx"

#Group SN
$Counter = [PSCustomObject] @{ Value = 0 }
$GroupSize = 20
$Groups = $SN | Group-Object -Property { [Math]::Floor($Counter.Value++ / $GroupSize) }

Write-Host "$($SN.Count) Serial Numbers detected, HP website supports searching at most 20 Numbers per session, will be seperate to $($Groups.Count) groups." -ForegroundColor Yellow

$HTML = @()

$Header = @"
<p></p>
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 1px;padding: 3px;border-style: solid;border-color: black;}
</style>
"@

$HTML += $Header

for ($M = 0; $M -lt $Groups.Count; $M++) {
	echo "Quering Group $($M+1)"
	$IE = New-Object -ComObject InternetExplorer.Application
	$IE.Visible = $true
	$IE.Navigate($URL)
	while ($IE.Busy -eq $true) {Start-Sleep -Seconds 1}
	for ($N = 0; $N -lt 20; $N++) {
		$IE.Document.getElementByID("serialNumber$N").value = $Groups[$M].Group[$N]
	}
	($IE.Document.getElementsByName("submitButton"))[0].Click()
	while ($IE.Document.getElementById("generate_table_$($Groups[$M].Group[-1])").InnerHTML.Length -le 50) {Start-Sleep -Seconds 1}
	
	
	for ($i = 0; $i -lt 20; $i++)
	{
		$HTML += $IE.Document.getElementById("generate_table_$($Groups[$M].Group[$i])").InnerHTML
	}
	
	Get-Process iexplore | ? {$_.starttime -gt $time} | Stop-process -force
	
	echo "Done for Group $($M+1)"
	
	if (($M+1) -ne $Groups.Count) {echo "sleep 30"; Sleep 30}
}



# ConvertTo-HTML -Body $Header
$html | Out-File $ResultHTML


$xl = New-Object -ComObject Excel.Application
$wb = $xl.Workbooks.Open($ResultHTML)
$lastrow = $wb.Worksheets.item(1).cells.range("A1048576").end("-4162").row

for ($i =  $lastrow ; $i -gt 1; $i--){

   If ($xl.Cells.Item($i,1).Value2 -eq "Type") {
        $Range = $xl.Cells.Item($i,1).EntireRow
        $Range.Delete() | out-null
    }
}

$wb.saveas($ResultXLSX,51)
$xl.quit()

Get-Process excel | ? {$_.starttime -gt $time} | stop-process -force

echo "done"
pause
