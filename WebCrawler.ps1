#####################  Autologin  ###################
$url = "mail.google.com"
$username="abc@gmail.com" 
$password="password" 
$ie = New-Object -com internetexplorer.application; 
$ie.visible = $true; 
$ie.navigate($url); 
while ($ie.Busy -eq $true) 
{ 
    Start-Sleep -Seconds 1; 
} 
$ie.Document.getElementById("login").value = $username 
$ie.Document.getElementByID("passwd").value=$password 
$ie.Document.getElementById("cred_sign_in_button").Click()



####################   Query Keywords:  ##################################
write-host -foregroundcolor yellow $price.Trim("￥")
#Internet option -> Privacy -> Change Settings bar to the lowest "accept all cookies", or the script will popup window.
$url = "http://item.yhd.com/item/1231903"
$result1 = Invoke-WebRequest $url
$elements = $result1.AllElements | Where Class -eq "ico_sina" | Select -ExpandProperty href 
$elements = $elements.split(" ")
write-host -foregroundcolor yellow $elements[-2]
$ie=new-object -com internetexplorer.application
$ie.navigate("http://item.jd.com/1295080.html")
$ie.visible=$false
$ie.Document.getElementById("jd-price").outertext

$url = "http://item.yhd.com/item/1231903"
$result = Invoke-WebRequest $url -usebasicparsing
$elements = $result.content
$elements = $elements.split(" ")

# $n = 1
# do{
# if ($elements[$n] -ne "￥332"){$n = $n + 1}
# }
# until ($elements[$n] -eq "￥332")
# $n

$price = $elements[5557] -replace "\D"
if ($price -ge 330)
{
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null

	$output = [System.Windows.Forms.MessageBox]::Show("The price is "+$price , "" , 4)

	if ($output -eq "Yes")
	{Invoke-Expression "cmd.exe /C start http://item.yhd.com/item/1231903"}
}

