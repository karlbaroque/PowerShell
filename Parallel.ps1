workflow WF-parallel
{
	param($sl)
	$b = gc $sl
	foreach -parallel ($a in $b)
	{
		InlineScript
			{
				Invoke-Command –ComputerName $using:a –ScriptBlock {get-service | select Name,@{Label = "ServerName"; Expression = {hostname}} | format-table  | out-string } 
			}
	}
}

function WF
{
	param($sl1)
	$c = gc $sl1
	foreach ($d in $c)
	{
		Invoke-Command –ComputerName $d –ScriptBlock {get-service | select Name,@{Label = "ServerName"; Expression = {hostname}} | format-table  | out-string } 
	}
}

(measure-command -expression {WF-parallel -sl $home\desktop\sl.txt}).totalseconds
(measure-command -expression {WF -sl1 $home\desktop\sl.txt}).totalseconds
