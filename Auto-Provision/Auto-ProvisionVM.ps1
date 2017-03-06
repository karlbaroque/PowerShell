# == Global Preference == #
$ErrorActionPreference = "SilentlyContinue"

# == Prerequisite Check == #
$InstalledModule = (Get-Module -ListAvailable).Name


#DNS Server Module
if (($InstalledModule -like "DnsServer").Length -lt 1)
{
	Write-Host "DNS Server Module is not detected, please remote and copy this script to a server where DNS Server Module is installed then rerun." -ForegroundColor Magenta
	Pause
	break
}

#VMware Module
if ((($InstalledModule -like "VMware.VimAutomation*").Length -lt 1) -and ((Get-PSSnapin -Registered) -like "VMware.VimAutomation*").Length -lt 1)
{
	Write-Host "VMware Automation Snapin is not detected, please remote and copy this script to a vSphere installed server then rerun." -ForegroundColor Magenta
	Pause
	break
}

#SQL Module 
if (($InstalledModule -like "SQLPS").Length -lt 1)
{
	Write-Host "SQL Snapin is not detected, please remote and copy this script to a SSMS installed server then rerun." -ForegroundColor Magenta
	Pause
	break
}

#VMRC
if (!(Test-Path "C:\Program Files (x86)\VMware\VMware Remote Console\vmrc.exe"))
{
	Write-Host "VMRC is not detected, script can't open VMware Remote Console, please check manually." -ForegroundColor Magenta
	Pause
	break
}

#bfi
if (!(Test-Path "$PSScriptRoot\bfi.exe"))
{
	Write-Host "BFI file is not detected, script can't create a floppy drive for VM, please check manually." -ForegroundColor Magenta
	Pause
	break
}



# == Form Part Start == #

Add-Type -Assembly "System.Windows.Forms"
Add-Type -Assembly "System.Drawing"

$Screen = [System.Windows.Forms.Screen]::PrimaryScreen
$Width = $Screen.WorkingArea.Width
$Height = $Screen.WorkingArea.Height

#Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "VM Auto Provision"
$Form.Location = '0,0'
$Form.Size = New-Object System.Drawing.Size($Width,$Height)
$Form.WindowState = 'Maximized'
$Form.AutoScroll = $True
$Form.AutoScaleMode = 'Font'
$Form.AutoScaleDimensions = New-Object System.Drawing.SizeF('6F','13F')
$Form.KeyPreview = $True
	
	#Tab Control
	#$TabControl = New-object System.Windows.Forms.TabControl
	#$TabControl.TabIndex = 4
	#$TabControl.SelectedIndex = 0
	#$TabControl.AutoSize = $true
	#$TabControl.Location = '20,20'
	#$TabControl.Size = New-Object System.Drawing.Size(($Width-40),($Height-140))
	


		#GBOTTab
		#$GBOTTab = New-Object System.Windows.Forms.TabPage
		#$GBOTTab.Text = "GBOT"
		#$GBOTTab.AutoSize = $true

			#GBOT Tab GBOT GroupBox
			$GBOTGroupBox = New-Object System.Windows.Forms.GroupBox
			$GBOTGroupBox.Text = "GBOT Info"
			$GBOTGroupBox.Location = New-Object System.Drawing.Size(($Form.Left + 20),($Form.Top + 20))
			$GBOTGroupBox.Size = New-Object System.Drawing.Size((($Form.Width - 60)/2),($Form.Height - 80))
			$GBOTGroupBox.AutoSize = $True
			#$GBOTGroupBox.Font = "Calibri, 24, style=Bold"
			$GBOTGroupBox.ForeColor = '255,128,0'
			
				$GBOTLeftLabelAlign = 10
				$GBOTHeightAlign = 40
				$GBOTLineSpace = 50
				#$GBOTLabelFont = "Calibri, 18"
				#$GBOTTextBoxFont = "Calibri, 12"
				$GBOTForeColor = '0,0,0'
				
			
				#L1.1 GBOT Group GBOT ID Label
				$GBOTIDLabel = New-Object System.Windows.Forms.Label
				$GBOTIDLabel.Text = "GBOT ID"
				$GBOTIDLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,$GBOTHeightAlign)
				#$GBOTIDLabel.AutoSize = $true
				#$GBOTIDLabel.Font = $GBOTLabelFont
				$GBOTIDLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTIDLabel)

				#L2.1 GBOT Group Server Number Label
				$GBOTServerNumberLabel = New-Object System.Windows.Forms.Label
				$GBOTServerNumberLabel.Text = "Server Number"
				$GBOTServerNumberLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTIDLabel.Location.Y + $GBOTLineSpace))
				#$GBOTServerNumberLabel.AutoSize = $true
				#$GBOTServerNumberLabel.Font = $GBOTLabelFont
				$GBOTServerNumberLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTServerNumberLabel)
				
				#L3.1 GBOT Group OS Label
				$GBOTOSLabel = New-Object System.Windows.Forms.Label
				$GBOTOSLabel.Text = "OS"
				$GBOTOSLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTServerNumberLabel.Location.Y + $GBOTLineSpace))
				#$GBOTOSLabel.AutoSize = $true
				#$GBOTOSLabel.Font = $GBOTLabelFont
				$GBOTOSLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTOSLabel)
				
				#L4.1 GBOT Group VLAN Label
				$GBOTVLANLabel = New-Object System.Windows.Forms.Label
				$GBOTVLANLabel.Text = "VLAN"
				$GBOTVLANLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTOSLabel.Location.Y + $GBOTLineSpace))
				#$GBOTVLANLabel.AutoSize = $true
				#$GBOTVLANLabel.Font = $GBOTLabelFont
				$GBOTVLANLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTVLANLabel)
				
				#L5.1 GBOT Group Security Zone Label
				$GBOTZoneLabel = New-Object System.Windows.Forms.Label
				$GBOTZoneLabel.Text = "Security Zone"
				$GBOTZoneLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTVLANLabel.Location.Y + $GBOTLineSpace))
				#$GBOTZoneLabel.AutoSize = $true
				#$GBOTZoneLabel.Font = $GBOTLabelFont
				$GBOTZoneLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTZoneLabel)
				
				#L6.1 GBOT Group BO Label
				$GBOTBOLabel = New-Object System.Windows.Forms.Label
				$GBOTBOLabel.Text = "BO Requester"
				$GBOTBOLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTZoneLabel.Location.Y + $GBOTLineSpace))
				#$GBOTBOLabel.AutoSize = $true
				#$GBOTBOLabel.Font = $GBOTLabelFont
				$GBOTBOLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTBOLabel)

				
				$GBOTLeftTextBoxAlign = $GBOTServerNumberLabel.Right + 20
				$GBOTTextBoxSize = New-Object System.Drawing.Size(($GBOTGroupBox.Right/2 - $GBOTLeftTextBoxAlign - 20),36)
				
				
				#L1.2 GBOT Group GBOT ID TextBox
				$GBOTIDTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTIDTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTIDLabel.Location.Y)
				$GBOTIDTextBox.Size = New-Object System.Drawing.Size($GBOTTextBoxSize.Width/2,$GBOTTextBoxSize.Height)
				#$GBOTIDTextBox.Font = "Calibri,14"
				$GBOTIDTextBox.ForeColor = $GBOTForeColor
				$GBOTIDTextBox.MaxLength = 5
				$GBOTIDTextBox.Add_TextChanged({ $this.Text = $this.Text -replace '\D' })
				$GBOTGroupBox.Controls.Add($GBOTIDTextBox)
				
				#L1.3 GBOT Group GBOT ID Button
				$GBOTIDButton = New-Object System.Windows.Forms.Button
				$GBOTIDButton.Location = New-Object System.Drawing.Size(($GBOTIDTextBox.Right + 5),$GBOTIDLabel.Location.Y)
				$GBOTIDButton.Size = New-Object System.Drawing.Size(64,$GBOTIDTextBox.Height)
				$GBOTIDButton.Text = "GO!"
				#$GBOTIDButton.Font = "Calibri,14"
				$GBOTIDButton.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTIDButton)
			
				#L2.2 GBOT Group Server Number TextBox
				$GBOTServerNumberTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTServerNumberTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTServerNumberLabel.Location.Y)
				$GBOTServerNumberTextBox.Size = $GBOTTextBoxSize
				#$GBOTServerNumberTextBox.Font = "Calibri,14"
				$GBOTServerNumberTextBox.ForeColor = $GBOTForeColor
				$GBOTServerNumberTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTServerNumberTextBox)
				
				#L3.2 GBOT Group OS TextBox
				$GBOTOSTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTOSTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTOSLabel.Location.Y)
				$GBOTOSTextBox.Size = $GBOTTextBoxSize #New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$OS.Length)
				$GBOTOSTextBox.AutoSize = $true
				#$GBOTOSTextBox.Font = "Calibri,11"
				$GBOTOSTextBox.ForeColor = $GBOTForeColor
				$GBOTOSTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTOSTextBox)
				
				#L4.2 GBOT Group VLAN TextBox
				$GBOTVLANTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTVLANTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTVLANLabel.Location.Y)
				$GBOTVLANTextBox.Size = $GBOTTextBoxSize
				#$GBOTVLANTextBox.Font = $GBOTTextBoxFont
				$GBOTVLANTextBox.ForeColor = $GBOTForeColor
				$GBOTVLANTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTVLANTextBox)
				
				#L5.2 GBOT Group Security Zone TextBox
				$GBOTZoneTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTZoneTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTZoneLabel.Location.Y)
				$GBOTZoneTextBox.Size = $GBOTTextBoxSize
				#$GBOTZoneTextBox.Font = $GBOTTextBoxFont
				$GBOTZoneTextBox.ForeColor = $GBOTForeColor
				$GBOTZoneTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTZoneTextBox)
			
				#L6.2 GBOT Group BO TextBox
				$GBOTBOTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTBOTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTBOLabel.Location.Y)
				$GBOTBOTextBox.Size = $GBOTTextBoxSize
				#$GBOTBOTextBox.Font = $GBOTTextBoxFont
				$GBOTBOTextBox.ForeColor = $GBOTForeColor
				$GBOTBOTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTBOTextBox)
				
							
				$GBOTRightLabelAlign = ($GBOTGroupBox.Width/2 + 10)
				
				
				#R1.1 GBOT Group Info Message TextBox
				$GBOTMessageTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTMessageTextBox.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,$GBOTHeightAlign)
				$GBOTMessageTextBox.Size = '227,36'
				#$GBOTMessageTextBox.Font = $GBOTTextBoxFont
				$GBOTMessageTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTMessageTextBox)

				
				#R2.1 GBOT Group VC Label
				$GBOTVCLabel = New-Object System.Windows.Forms.Label
				$GBOTVCLabel.Text = "VC"
				$GBOTVCLabel.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,($GBOTMessageTextBox.Location.Y + $GBOTLineSpace))
				#$GBOTVCLabel.AutoSize = $true
				#$GBOTVCLabel.Font = $GBOTLabelFont
				$GBOTVCLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTVCLabel)
				
				#R3.1 GBOT Group CPU Label
				$GBOTCPULabel = New-Object System.Windows.Forms.Label
				$GBOTCPULabel.Text = "CPU"
				$GBOTCPULabel.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,($GBOTVCLabel.Location.Y + $GBOTLineSpace))
				#$GBOTCPULabel.AutoSize = $true
				#$GBOTCPULabel.Font = $GBOTLabelFont
				$GBOTCPULabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTCPULabel)
				
				#R4.1 GBOT Group Memory Label
				$GBOTMemoryLabel = New-Object System.Windows.Forms.Label
				$GBOTMemoryLabel.Text = "Memory(GB)"
				$GBOTMemoryLabel.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,($GBOTCPULabel.Location.Y + $GBOTLineSpace))
				#$GBOTMemoryLabel.AutoSize = $true
				#$GBOTMemoryLabel.Font = $GBOTLabelFont
				$GBOTMemoryLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTMemoryLabel)
				
				#R5.1 GBOT Group HDD Label
				$GBOTHDDLabel = New-Object System.Windows.Forms.Label
				$GBOTHDDLabel.Text = "HDD(GB)"
				$GBOTHDDLabel.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,($GBOTMemoryLabel.Location.Y + $GBOTLineSpace))
				#$GBOTHDDLabel.AutoSize = $true
				#$GBOTHDDLabel.Font = $GBOTLabelFont
				$GBOTHDDLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTHDDLabel)				
				
				#R6.1 GBOT Group Tier Label
				$GBOTTierLabel = New-Object System.Windows.Forms.Label
				$GBOTTierLabel.Text = "Tier"
				$GBOTTierLabel.Location = New-Object System.Drawing.Size($GBOTRightLabelAlign,($GBOTHDDLabel.Location.Y + $GBOTLineSpace))
				#$GBOTTierLabel.AutoSize = $true
				#$GBOTTierLabel.Font = $GBOTLabelFont
				$GBOTTierLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTTierLabel)
				
				
				$GBOTRightTextBoxAlign = $GBOTMemoryLabel.Right + 20
				
				
				#R2.2 GBOT Group VC TextBox
				$GBOTVCTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTVCTextBox.Location = New-Object System.Drawing.Size($GBOTRightTextBoxAlign,$GBOTVCLabel.Location.Y)
				$GBOTVCTextBox.Size = $GBOTTextBoxSize
				#$GBOTVCTextBox.Font = $GBOTTextBoxFont
				$GBOTVCTextBox.ForeColor = $GBOTForeColor
				$GBOTVCTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTVCTextBox)
				
				#R3.2 GBOT Group CPU TextBox
				$GBOTCPUTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTCPUTextBox.Location = New-Object System.Drawing.Size($GBOTRightTextBoxAlign,$GBOTCPULabel.Location.Y)
				$GBOTCPUTextBox.Size = $GBOTTextBoxSize
				#$GBOTCPUTextBox.Font = $GBOTTextBoxFont
				$GBOTCPUTextBox.ForeColor = $GBOTForeColor
				$GBOTCPUTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTCPUTextBox)
				
				#R4.2 GBOT Group Memory TextBox
				$GBOTMemoryTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTMemoryTextBox.Location = New-Object System.Drawing.Size($GBOTRightTextBoxAlign,$GBOTMemoryLabel.Location.Y)
				$GBOTMemoryTextBox.Size = $GBOTTextBoxSize
				#$GBOTMemoryTextBox.Font = $GBOTTextBoxFont
				$GBOTMemoryTextBox.ForeColor = $GBOTForeColor
				$GBOTMemoryTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTMemoryTextBox)
				
				#R5.2 GBOT Group HDD TextBox
				$GBOTHDDTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTHDDTextBox.Location = New-Object System.Drawing.Size($GBOTRightTextBoxAlign,$GBOTHDDLabel.Location.Y)
				$GBOTHDDTextBox.Size = $GBOTTextBoxSize
				#$GBOTHDDTextBox.Font = $GBOTTextBoxFont
				$GBOTHDDTextBox.ForeColor = $GBOTForeColor
				$GBOTHDDTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTHDDTextBox)
				
				#R6.2 GBOT Group Tier TextBox
				$GBOTTierTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTTierTextBox.Location = New-Object System.Drawing.Size($GBOTRightTextBoxAlign,$GBOTTierLabel.Location.Y)
				$GBOTTierTextBox.Size = $GBOTTextBoxSize
				#$GBOTTierTextBox.Font = $GBOTTextBoxFont
				$GBOTTierTextBox.ForeColor = $GBOTForeColor
				$GBOTTierTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTTierTextBox)
				
				
				#L7.1 GBOT Group Server Name Label
				$GBOTServerLabel = New-Object System.Windows.Forms.Label
				$GBOTServerLabel.Text = "Server Name"
				$GBOTServerLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTBOLabel.Location.Y + $GBOTLineSpace))
				#$GBOTServerLabel.AutoSize = $true
				#$GBOTServerLabel.Font = $GBOTLabelFont
				$GBOTServerLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTServerLabel)
				
				#L7.2 GBOT Group Server Name TextBox
				$GBOTServerTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTServerTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTServerLabel.Location.Y)
				$GBOTServerTextBox.Size = New-Object System.Drawing.Size(($GBOTVCTextBox.Right - $GBOTLeftTextBoxAlign),$GBOTTextBoxSize.Height)
				#$GBOTServerTextBox.Font = $GBOTTextBoxFont
				$GBOTServerTextBox.ForeColor = $GBOTForeColor
				$GBOTServerTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTServerTextBox)
				
				
				#L8.1 GBOT Group IP Label
				$GBOTIPLabel = New-Object System.Windows.Forms.Label
				$GBOTIPLabel.Text = "IP"
				$GBOTIPLabel.Location = New-Object System.Drawing.Size($GBOTLeftLabelAlign,($GBOTServerLabel.Location.Y + $GBOTLineSpace))
				#$GBOTIPLabel.AutoSize = $true
				#$GBOTIPLabel.Font = $GBOTLabelFont
				$GBOTIPLabel.ForeColor = $GBOTForeColor
				$GBOTGroupBox.Controls.Add($GBOTIPLabel)
				
				#$L8.2 GBOT Group IP TextBox
				$GBOTIPTextBox = New-Object System.Windows.Forms.TextBox
				$GBOTIPTextBox.Location = New-Object System.Drawing.Size($GBOTLeftTextBoxAlign,$GBOTIPLabel.Location.Y)
				$GBOTIPTextBox.Size = New-Object System.Drawing.Size(($GBOTVCTextBox.Right - $GBOTLeftTextBoxAlign),$GBOTTextBoxSize.Height)
				#$GBOTIPTextBox.Font = $GBOTTextBoxFont
				$GBOTIPTextBox.ForeColor = $GBOTForeColor
				$GBOTIPTextBox.ReadOnly =  $true
				$GBOTGroupBox.Controls.Add($GBOTIPTextBox)
				
				$GBOTGroupBox.Size = New-Object System.Drawing.Size($GBOTGroupBox.Width,($GBOTIPTextBox.Bottom + 20))

			$form.Controls.Add($GBOTGroupBox)
			
			#GBOT Tab Work Space GroupBox
			$WorkSpaceGroupBox = New-Object System.Windows.Forms.GroupBox
			$WorkSpaceGroupBox.Text = "Work Space"
			$WorkSpaceGroupBox.Location = New-Object System.Drawing.Size(($GBOTGroupBox.Right + 20), 20)
			$WorkSpaceGroupBox.Size = New-Object System.Drawing.Size(($form.Width - $GBOTGroupBox.Right - 40),($form.Height-80))
			$WorkSpaceGroupBox.AutoSize = $True
			#$WorkSpaceGroupBox.Font = "Calibri, 24, style=Bold"
			$WorkSpaceGroupBox.ForeColor = '255,128,0'
				
				$WorkSpaceLeftLabelAlign = 10
				$WorkSpaceHeightAlign = 40
				$WorkSpaceLineSpace = 50
				#$WorkSpaceLabelFont = "Calibri, 18"
				#$WorkSpaceTextBoxFont = "Calibri, 12"
				$WorkSpaceForeColor = '0,0,0'
				
				
				#L1.1 Work Space Group VC Label
				$WorkSpaceVCLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceVCLabel.Text = "VC"
				$WorkSpaceVCLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,$WorkSpaceHeightAlign)
				#$WorkSpaceVCLabel.AutoSize = $true
				#$WorkSpaceVCLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceVCLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceVCLabel)
				
				#L2.1 Work Space VM Version Label
				$WorkSpaceVMVersionLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceVMVersionLabel.Text = "VM Version"
				$WorkSpaceVMVersionLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceVCLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceVMVersionLabel.AutoSize = $true
				#$WorkSpaceVMVersionLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceVMVersionLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceVMVersionLabel)
				
				#L3.1 Work Space SCSI Controller Label
				$WorkSpaceSCSILabel = New-Object System.Windows.Forms.Label
				$WorkSpaceSCSILabel.Text = "SCSI Controller"
				$WorkSpaceSCSILabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceVMVersionLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceSCSILabel.AutoSize = $true
				#$WorkSpaceSCSILabel.Font = $WorkSpaceLabelFont
				$WorkSpaceSCSILabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceSCSILabel)

				#L4.1 Work Space Cores Label
				$WorkSpaceCoresLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceCoresLabel.Text = "Cores"
				$WorkSpaceCoresLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceSCSILabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceCoresLabel.AutoSize = $true
				#$WorkSpaceCoresLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceCoresLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceCoresLabel)
				
				
				$WorkSpaceLeftTextBoxAlign = $WorkSpaceSCSILabel.Right + 20
				$WorkSpaceTextBoxSize = New-Object System.Drawing.Size(($WorkSpaceGroupBox.Width/2 - $WorkSpaceLeftTextBoxAlign - 20),36)
				
				
				#L1.2 Work Space VC TextBox
				$WorkSpaceVCTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceVCTextBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$GBOTHeightAlign)
				$WorkSpaceVCTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceVCTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceVCTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceVCTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceVCTextBox)
				
				#L2.2 Work Space VM Version TextBox
				$WorkSpaceVMVersionTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceVMVersionTextBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$WorkSpaceVMVersionLabel.Location.Y)
				$WorkSpaceVMVersionTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceVMVersionTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceVMVersionTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceVMVersionTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceVMVersionTextBox)

				#L3.2 Work Space SCSI TextBox
				$WorkSpaceSCSITextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceSCSITextBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$WorkSpaceSCSILabel.Location.Y)
				$WorkSpaceSCSITextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceSCSITextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceSCSITextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceSCSITextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceSCSITextBox)

				#L4.2 Work Space Cores TextBox
				$WorkSpaceCoresTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceCoresTextBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$WorkSpaceCoresLabel.Location.Y)
				$WorkSpaceCoresTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceCoresTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceCoresTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceCoresTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceCoresTextBox)

				
				$WorkSpaceRightLabelAlign = $WorkSpaceGroupBox.Width/2 + 10
				
				
				#R1.1 Work Space Network Label
				$WorkSpaceNetworkLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceNetworkLabel.Text = "Network"
				$WorkSpaceNetworkLabel.Location = New-Object System.Drawing.Size($WorkSpaceRightLabelAlign,$WorkSpaceHeightAlign)
				#$WorkSpaceNetworkLabel.AutoSize = $true
				#$WorkSpaceNetworkLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceNetworkLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceNetworkLabel)
				
				#R2.1 Work Space Adapter Label
				$WorkSpaceAdapterLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceAdapterLabel.Text = "Adapter"
				$WorkSpaceAdapterLabel.Location = New-Object System.Drawing.Size($WorkSpaceRightLabelAlign,($WorkSpaceNetworkLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceAdapterLabel.AutoSize = $true
				#$WorkSpaceAdapterLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceAdapterLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceAdapterLabel)
				
				#R3.1 Work Space Disk Provision Label
				$WorkSpaceDiskLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceDiskLabel.Text = "Disk Provision"
				$WorkSpaceDiskLabel.Location = New-Object System.Drawing.Size($WorkSpaceRightLabelAlign,($WorkSpaceAdapterLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceDiskLabel.AutoSize = $true
				#$WorkSpaceDiskLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceDiskLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDiskLabel)
				
				#R4.1 Work Space Sockets Label
				$WorkSpaceSocketsLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceSocketsLabel.Text = "Sockets"
				$WorkSpaceSocketsLabel.Location = New-Object System.Drawing.Size($WorkSpaceRightLabelAlign,($WorkSpaceDiskLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceSocketsLabel.AutoSize = $true
				#$WorkSpaceSocketsLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceSocketsLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceSocketsLabel)				
				
				
				$WorkSpaceRightTextBoxAlign = $WorkSpaceDiskLabel.Right + 20
				#$WorkSpaceRightTextBoxSize = New-Object System.Drawing.Size(($WorkSpaceGroupBox.Right - $WorkSpaceGroupBox.Left - $WorkSpaceNetworkLabel.Right - 70),36)
				
	
				
				# $WorkSpaceNetworkTextBox = New-Object System.Windows.Forms.TextBox
				# $WorkSpaceNetworkTextBox.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceNetworkLabel.Location.Y)
				# $WorkSpaceNetworkTextBox.Size = $WorkSpaceRightTextBoxSize
				# $WorkSpaceNetworkTextBox.Font = $WorkSpaceTextBoxFont
				# $WorkSpaceNetworkTextBox.ForeColor = $WorkSpaceForeColor
				# $WorkSpaceNetworkTextBox.ReadOnly =  $true
				# $WorkSpaceGroupBox.Controls.Add($WorkSpaceNetworkTextBox)

				#R1.2 Work Space Network ComboBox
				$WorkSpaceNetworkCombo = New-Object System.Windows.Forms.ComboBox
				$WorkSpaceNetworkCombo.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceNetworkLabel.Location.Y)
				$WorkSpaceNetworkCombo.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceNetworkCombo.Font = $WorkSpaceTextBoxFont
				$WorkSpaceNetworkCombo.Sorted = $true
				$WorkSpaceNetworkCombo.Enabled = $false
				$WorkSpaceNetworkCombo.DropDownStyle = 'DropDownList'
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceNetworkCombo)	

				#R2.2 Work Space Adapter TextBox
				$WorkSpaceAdapterTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceAdapterTextBox.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceAdapterLabel.Location.Y)
				$WorkSpaceAdapterTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceAdapterTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceAdapterTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceAdapterTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceAdapterTextBox)

				#R3.2 Work Space Disk TextBox
				$WorkSpaceDiskTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceDiskTextBox.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceDiskLabel.Location.Y)
				$WorkSpaceDiskTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceDiskTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceDiskTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceDiskTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDiskTextBox)

				#R4.2 Work Space Sockets TextBox
				$WorkSpaceSocketsTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceSocketsTextBox.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceSocketsLabel.Location.Y)
				$WorkSpaceSocketsTextBox.Size = $WorkSpaceTextBoxSize
				#$WorkSpaceSocketsTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceSocketsTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceSocketsTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceSocketsTextBox)

				
				
				#CB1.1 Work Space Data Center Label
				$WorkSpaceDataCenterLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceDataCenterLabel.Text = "Data Center"
				$WorkSpaceDataCenterLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceCoresLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceDataCenterLabel.AutoSize = $true
				#$WorkSpaceDataCenterLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceDataCenterLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataCenterLabel)
				
				#CB2.1 Work Space Cluster Label
				$WorkSpaceClusterLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceClusterLabel.Text = "Cluster"
				$WorkSpaceClusterLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceDataCenterLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceClusterLabel.AutoSize = $true
				#$WorkSpaceClusterLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceClusterLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceClusterLabel)
				
				#CB3.1 Work Space Resource Pool Label
				$WorkSpaceRSPLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceRSPLabel.Text = "Resource Pool"
				$WorkSpaceRSPLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceClusterLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceRSPLabel.AutoSize = $true
				#$WorkSpaceRSPLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceRSPLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceRSPLabel)
				
				#CB3.3 Work Space Resource Pool New CheckBox
				$WorkSpaceRSPCheckBox = New-Object System.Windows.Forms.CheckBox
				$WorkSpaceRSPCheckBox.Text = "New Pool?"
				$WorkSpaceRSPCheckBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceRSPLabel.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceRSPCheckBox.AutoSize = $true
				#$WorkSpaceRSPCheckBox.Font = $WorkSpaceLabelFont
				$WorkSpaceRSPCheckBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceRSPCheckBox.Enabled = $false
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceRSPCheckBox)
				
				#CB4.1 Work Space Data Store Label
				$WorkSpaceDataStoreLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceDataStoreLabel.Text = "Data Store"
				$WorkSpaceDataStoreLabel.Location = New-Object System.Drawing.Size($WorkSpaceLeftLabelAlign,($WorkSpaceRSPCheckBox.Location.Y + $WorkSpaceLineSpace))
				#$WorkSpaceDataStoreLabel.AutoSize = $true
				#$WorkSpaceDataStoreLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceDataStoreLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataStoreLabel)


				$WorkSpaceComboSize = New-Object System.Drawing.Size(($WorkSpaceGroupBox.Right - $WorkSpaceGroupBox.Left - $WorkSpaceLeftTextBoxAlign -10 ),36)

				
				#CB1.2 Work Space Data Center ComboBox
				$WorkSpaceDataCenterCombo = New-Object System.Windows.Forms.ComboBox
				$WorkSpaceDataCenterCombo.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$WorkSpaceDataCenterLabel.Location.Y)
				$WorkSpaceDataCenterCombo.Size = $WorkSpaceComboSize
				#$WorkSpaceDataCenterCombo.Font = $WorkSpaceTextBoxFont
				$WorkSpaceDataCenterCombo.Sorted = $true
				$WorkSpaceDataCenterCombo.Enabled = $false
				$WorkSpaceDataCenterCombo.DropDownStyle = 'DropDownList'
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataCenterCombo)

				#CB2.2 Work Space Cluster ComboBox
				$WorkSpaceClusterCombo = New-Object System.Windows.Forms.ComboBox
				$WorkSpaceClusterCombo.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign, $WorkSpaceClusterLabel.Location.Y)
				$WorkSpaceClusterCombo.Size = $WorkSpaceComboSize
				#$WorkSpaceClusterCombo.Font = $WorkSpaceTextBoxFont
				$WorkSpaceClusterCombo.Sorted = $true
				$WorkSpaceClusterCombo.DropDownStyle = 'DropDownList'
				$WorkSpaceClusterCombo.Enabled = $false
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceClusterCombo)

				#CB3.2 Work Space Resource Pool ComboBox
				$WorkSpaceRSPCombo = New-Object System.Windows.Forms.ComboBox
				$WorkSpaceRSPCombo.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign, $WorkSpaceRSPLabel.Location.Y)
				$WorkSpaceRSPCombo.Size = $WorkSpaceComboSize
				#$WorkSpaceRSPCombo.Font = $WorkSpaceTextBoxFont
				$WorkSpaceRSPCombo.Sorted = $true
				$WorkSpaceRSPCombo.DropDownStyle = 'DropDownList'
				$WorkSpaceRSPCombo.Enabled = $false
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceRSPCombo)

				#CB3.4 Work Space Resource Pool New TextBox
				$WorkSpaceRSPTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceRSPTextBox.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign,$WorkSpaceRSPCheckBox.Location.Y)
				$WorkSpaceRSPTextBox.Size = $WorkSpaceComboSize
				#$WorkSpaceRSPTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceRSPTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceRSPTextBox.Enabled = $false
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceRSPTextBox)
				
				#CB4.2 Work Space Data Store ComboBox
				$WorkSpaceDataStoreCombo = New-Object System.Windows.Forms.ComboBox
				$WorkSpaceDataStoreCombo.Location = New-Object System.Drawing.Size($WorkSpaceLeftTextBoxAlign, $WorkSpaceDataStoreLabel.Location.Y)
				$WorkSpaceDataStoreCombo.Size = $WorkSpaceComboSize
				#$WorkSpaceDataStoreCombo.Font = $WorkSpaceTextBoxFont
				$WorkSpaceDataStoreCombo.DropDownStyle = 'DropDownList'
				$WorkSpaceDataStoreCombo.Enabled = $false
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataStoreCombo)
				
				#CB4.3 Work Space Data Store FreeGB TextBox
				$WorkSpaceDataStoreTextBox = New-Object System.Windows.Forms.TextBox
				$WorkSpaceDataStoreTextBox.Location = New-Object System.Drawing.Size($WorkSpaceRightLabelAlign,($WorkSpaceDataStoreLabel.Location.Y + $WorkSpaceHeightAlign))
				#$WorkSpaceDataStoreTextBox.AutoSize = $true
				#$WorkSpaceDataStoreTextBox.Font = $WorkSpaceTextBoxFont
				$WorkSpaceDataStoreTextBox.ForeColor = $WorkSpaceForeColor
				$WorkSpaceDataStoreTextBox.ReadOnly =  $true
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataStoreTextBox)

				#CB4.4 Work Space Data Store FreeGB Label
				$WorkSpaceDataStoreFreeLabel = New-Object System.Windows.Forms.Label
				$WorkSpaceDataStoreFreeLabel.Text = "GB Free"
				$WorkSpaceDataStoreFreeLabel.Location = New-Object System.Drawing.Size($WorkSpaceRightTextBoxAlign,$WorkSpaceDataStoreTextBox.Location.Y)
				#$WorkSpaceDataStoreFreeLabel.AutoSize = $true
				#$WorkSpaceDataStoreFreeLabel.Font = $WorkSpaceLabelFont
				$WorkSpaceDataStoreFreeLabel.ForeColor = $WorkSpaceForeColor
				$WorkSpaceGroupBox.Controls.Add($WorkSpaceDataStoreFreeLabel)
				
				$WorkSpaceGroupBox.Size = New-Object System.Drawing.Size($WorkSpaceGroupBox.Width,($WorkSpaceDataStoreFreeLabel.Bottom + 20))

				
				#Event Handle
				$GBOTIDButton.Add_Click({
					if ($GBOTIDTextBox.Text.Length -gt 0)
					{ 	
						#Clear TextBox
						$GBOTMessageTextBox.Clear()
						$GBOTMessageTextBox.BackColor = '240,240,240'
						$GBOTMessageTextBox.Text = "Processing..."
						$GBOTServerNumberTextBox.Clear()
						$GBOTOSTextBox.Clear()
						$GBOTVLANTextBox.Clear()
						$GBOTZoneTextBox.Clear()
						$GBOTBOTextBox.Clear()
						$GBOTVCTextBox.Clear()
						$GBOTCPUTextBox.Clear()
						$GBOTMemoryTextBox.Clear()
						$GBOTHDDTextBox.Clear()
						$GBOTTierTextBox.Clear()
						$GBOTServerTextBox.Clear()
						$GBOTIPTextBox.Clear()
						
						$WorkSpaceVCTextBox.Clear()
						$WorkSpaceVMVersionTextBox.Clear()
						$WorkSpaceSCSITextBox.Clear()
						$WorkSpaceCoresTextBox.Clear()
						$WorkSpaceAdapterTextBox.Clear()
						$WorkSpaceDiskTextBox.Clear()
						$WorkSpaceSocketsTextBox.Clear()
						
						$WorkSpaceNetworkCombo.Enabled = $false
						$WorkSpaceNetworkCombo.Items.Clear()
						$WorkSpaceDataCenterCombo.Enabled = $false
						$WorkSpaceDataCenterCombo.Items.Clear()
						$WorkSpaceClusterCombo.Enabled = $false
						$WorkSpaceClusterCombo.Items.Clear()
						$WorkSpaceRSPCombo.Enabled = $false
						$WorkSpaceRSPCombo.Items.Clear()
						$WorkSpaceRSPCheckBox.Enabled = $false
						$WorkSpaceRSPTextBox.Enabled = $false
						$WorkSpaceRSPTextBox.Items.Clear()
						$WorkSpaceDataStoreCombo.Enabled = $false
						$WorkSpaceDataStoreCombo.Items.Clear()
						$WorkSpaceDataStoreTextBox.Enabled = $false
						$WorkSpaceDataStoreTextBox.Items.Clear()
						
						# == GBOT Query Start == #
						[string]$GBOTID = @("GBOTID=" + $GBOTIDTextBox.Text)
						$TFSServer = ""
						$SQLCMD = 
@'
		SELECT [System_Id],
		[System_RevisedDate],
		[System_ChangedDate],
		[System_State],
		[System_Rev],
		[sc_servertype],
		[sc_AppTier],
		[sc_LocalAdminAccount],
		[sc_cpu],
		[sc_memory],
		[sc_HDD],
		[sc_ServerName],
		[sc_os],
		[sc_ServerNumber],
		[sc_DriveConfiguration],
		[sc_DriveType],
		[sc_VLANZone],
		[sc_mode],
		[sc_BuddycheckBy],
		[sc_SecurityZone],
		[sc_IP],
		[sc_ILO],
		[sc_vc],
		[sc_BORequester]
		FROM [Tfs_Warehouse].[dbo].[DimWorkItem] where System_Id = '$(GBOTID)'
'@
						$QueryGBOT = Invoke-Sqlcmd -ServerInstance "$TFSServer" -Username "sa" -Password "" -Query $SQLCMD -Variable $GBOTID
						$QueryResult = $QueryGBOT | Where {$_.System_State -eq "Assigned To Build Queue"} | Sort-Object -Property System_Rev -Descending | Select -First 1
						Set-Location $PSScriptRoot
						# == GBOT Query End	== #
						
						# == Parse result Start ==#
						$GBOTServerNumberTextBox.Text = $QueryResult.sc_ServerNumber
						#$GBOTServerNumberTextBox.Text = 2
						
						$GBOTOSTextBox.Text = $QueryResult.sc_os
						#$GBOTOSTextBox.Text = "Windows 2012 R2 Standard"
						
						$GBOTVCTextBox.Text = $QueryResult.sc_vc.Trim().ToUpper()
						
						$GBOTServerTextBox.Text = $QueryResult.sc_ServerName.Trim().ToUpper()
						#[array]$Servers = $QueryResult.sc_ServerName.Split(",").Split(";").Split("/").Trim().ToUpper()
						#$Servers = $Servers.Split(",").ToUpper()
						
						$GBOTIPTextBox.Text = $QueryResult.sc_IP.Trim()
						#[array]$IP = $QueryResult.sc_IP.Split(",").Split(";").Split("/").Trim()
						#[array]$IP = "192.168.0.100","192.168.0.101"
						#$IP = $IP.Split(",")
						
						$GBOTCPUTextBox.Text = $QueryResult.sc_cpu -split '\D' | Where {$_ -match '\d'}
						#$GBOTCPUTextBox.Text = 4
	
						$GBOTMemoryTextBox.Text = $QueryResult.sc_memory -split '\D' | Where {$_ -match '\d'}
						#$GBOTMemoryTextBox.Text = 8
						
						$Partition = $QueryResult.sc_DriveConfiguration -split '\D' | Where {$_ -match '\d'}
						if ($Partition -eq $Null -or $Partition -eq 0)
						{
							$DiskGB = $QueryResult.sc_HDD -split '\D' | Where {$_ -match '\d'}
						}
						else
						{
							$DiskGB = $Partition
						}
						$GBOTHDDTextBox.Text = $DiskGB
						#$GBOTHDDTextBox.Text = 80,120
											
						$GBOTVLANTextBox.Text = $QueryResult.sc_VLANZone
						
						$GBOTZoneTextBox.Text = $QueryResult.sc_SecurityZone.Trim()
						#GBOTZoneTextBox.Text = "COLO"
						
						$GBOTTierTextBox.Text = $QueryResult.sc_AppTier.Trim()
						#$GBOTTierTextBox.Text = "Tier 4"
						
						$GBOTBOTextBox.Text = $QueryResult.sc_BORequester.Trim()
						
						$LocalAdmin = $QueryResult.sc_LocalAdminAccount.Trim()
						
						#Blank TextBox Detection
						elseif (($QueryResult.sc_ServerNumber.Length -eq 0) -or `
								($QueryResult.sc_vc.Length -lt 10) -or `
								($QueryResult.sc_os.Length -eq 0) -or `
								($QueryResult.sc_cpu.Length -eq 0) -or `
								($QueryResult.sc_memory.Length -eq 0) -or `
								($QueryResult.sc_HDD.Length -eq 0) -or `
								($QueryResult.sc_ServerName.Length -eq 0) -or `
								($QueryResult.sc_IP.Length -eq 0))
						{
							$GBOTMessageTextBox.Text = "Missing info, please update TFS"
							$GBOTMessageTextBox.BackColor = '255,192,192'
						}
						
						#Check IP conflicted
						elseif (($QueryResult.sc_Ip.split(",").trim() | % {Test-Connection $_ -Count 1 -Quiet}) -eq  $true)
						{
							$GBOTMessageTextBox.Text = "IP conflicted, please check"
							$GBOTMessageTextBox.BackColor = '255,192,192'
						}
						
						# == Parse result End ==#
						
						# == User Interactive Start == #					
						else 
						{
							$WorkSpaceVCTextBox.Text = $QueryResult.sc_vc.Trim().ToUpper()
							
							$WorkSpaceVMVersionTextBox.Text = "v8"
							#$WorkSpaceVMVersionTextBox.Text = "v8"
							
							$WorkSpaceSCSITextBox.Text = "ParaVirtual"
							#$WorkSpaceSCSITextBox.Text = "ParaVirtual"
						
							if ($GBOTCPUTextBox.Text -eq 2)
							{
								$WorkSpaceCoresTextBox.Text = 1
							}
							elseif ($GBOTCPUTextBox.Text -eq 4 -or $GBOTCPUTextBox.Text -eq 6 -or $GBOTCPUTextBox.Text -eq 8 -or $GBOTCPUTextBox.Text -eq 10)
							{
								$WorkSpaceCoresTextBox.Text = 2
							}
							elseif ($GBOTCPUTextBox.Text -eq 12)
							{
								$WorkSpaceCoresTextBox.Text = 3
							}
							elseif ($GBOTCPUTextBox.Text -eq 16)
							{
								$WorkSpaceCoresTextBox.Text = 4
							}
							#WorkSpaceCoresTextBox.Text = 2

							$WorkSpaceAdapterTextBox.Text = "VMXNET3"
							#$WorkSpaceAdapterTextBox.Text = "VMXNET3"
							
							$WorkSpaceDiskTextBox.Text = "Thick, Lazy"
							#$WorkSpaceDiskTextBox.Text = "Thick, Lazy"
							
							$WorkSpaceSocketsTextBox.Text = $GBOTCPUTextBox.Text/$WorkSpaceCoresTextBox.Text
							#WorkSpaceSocketsTextBox.Text = 2
							
							$GBOTMessageTextBox.Text = "Connecting VC..."
							
							Add-PSSnapin VMware.V*
							Connect-VIServer $WorkSpaceVCTextBox.Text -Force | Out-Null
							Set-PowerCLIConfiguration -DisplayDeprecationWarnings $false -Confirm:$false | Out-Null
							
							$DataCenters = Get-Datacenter
							ForEach ($DataCenter in $DataCenters)
							{
								[void] $WorkSpaceDataCenterCombo.Items.Add($DataCenter)
							}
							$WorkSpaceDataCenterCombo.Enabled = $true

							$GBOTMessageTextBox.Text = "Ready to Deploy!"
							$GBOTMessageTextBox.BackColor = '192,255,192'

							
							$WorkSpaceDataCenterCombo_SelectionChangeCommitted = {
								If ($WorkSpaceDataCenterCombo.Text.Length -gt 0) 
								{
									$WorkSpaceClusterCombo.Enabled = $true
									$WorkSpaceClusterCombo.Items.Clear()
									$WorkSpaceRSPCheckBox.Enabled = $false
									$WorkSpaceRSPCheckBox.Checked = $false
									$WorkSpaceRSPTextBox.Clear()	
									$WorkSpaceRSPCombo.Enabled = $false
									$WorkSpaceRSPCombo.Items.Clear()
									$WorkSpaceDataStoreCombo.Enabled = $false
									$WorkSpaceDataStoreCombo.Items.Clear()
									$WorkSpaceDataStoreTextBox.Clear()
									$WorkSpaceNetworkCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$Clusters = Get-Datacenter $WorkSpaceDataCenterCombo.Text | Get-Cluster
									ForEach ($Cluster in $Clusters) 
										{
											[void] $WorkSpaceClusterCombo.Items.Add($Cluster)
										}
								}
							}
							$WorkSpaceDataCenterCombo.Add_SelectionChangeCommitted($WorkSpaceDataCenterCombo_SelectionChangeCommitted)
							
							
							$WorkSpaceClusterCombo_SelectionChangeCommitted = {
								If ($WorkSpaceClusterCombo.Text.Length -gt 0)
								{
									$WorkSpaceRSPCombo.Enabled = $true
									$WorkSpaceRSPCombo.Items.Clear()
									$WorkSpaceRSPCheckBox.Enabled = $true
									$WorkSpaceRSPCheckBox.Checked = $false
									$WorkSpaceRSPTextBox.Clear()						
									$WorkSpaceDataStoreCombo.Enabled = $false
									$WorkSpaceDataStoreCombo.Items.Clear()
									$WorkSpaceDataStoreTextBox.Clear()
									$WorkSpaceNetworkCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$RSPS = Get-Cluster $WorkSpaceClusterCombo.Text | Get-ResourcePool
									ForEach ($RSP in $RSPS) 
									{
										[void] $WorkSpaceRSPCombo.Items.Add($RSP)
									}
									
									$DataStores = (Get-Cluster $WorkSpaceClusterCombo.Text | Get-Datastore | Sort -Descending FreeSpaceGB).Name
									ForEach ($DataStore in $DataStores) 
									{
										[void] $WorkSpaceDataStoreCombo.Items.Add($DataStore)
									}
								}
								else {$WorkSpaceRSPCombo.Enabled = $false }
							}
							$WorkSpaceClusterCombo.Add_SelectionChangeCommitted($WorkSpaceClusterCombo_SelectionChangeCommitted)
							
							$WorkSpaceRSPCombo_SelectionChangeCommitted = {
								If ($WorkSpaceRSPCombo.Text.Length -gt 0)
								{				
									$WorkSpaceDataStoreCombo.Enabled = $true
									$WorkSpaceDataStoreCombo.Items.Clear()
									$WorkSpaceDataStoreTextBox.Clear()
									$WorkSpaceNetworkCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$WorkSpaceDataStoreCombo.SelectedIndex = -1
									$WorkSpaceNetworkCombo.SelectedIndex = -1
									
									$DataStores = (Get-Cluster $WorkSpaceClusterCombo.Text | Get-Datastore | Sort -Descending FreeSpaceGB).Name
									ForEach ($DataStore in $DataStores) 
									{
										[void] $WorkSpaceDataStoreCombo.Items.Add($DataStore)
									}
								}
							}
							$WorkSpaceRSPCombo.Add_SelectionChangeCommitted($WorkSpaceRSPCombo_SelectionChangeCommitted)
							#$Datastore = (Get-Cluster $Cluster | Get-Datastore | Sort -Descending FreeSpaceMB)[0].Name
							
							
							$WorkSpaceRSPCheckBox_Checked = {
								If ($WorkSpaceRSPCheckBox.Checked) 
								{
									$WorkSpaceRSPCombo.Enabled = $false
									$WorkSpaceRSPTextBox.Enabled = $true
									$WorkSpaceDataStoreCombo.Enabled = $false
									$WorkSpaceDataStoreCombo.Items.Clear()
									$WorkSpaceDataStoreTextBox.Clear()
									$WorkSpaceNetworkCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$WorkSpaceRSPCombo.SelectedIndex = -1
									$WorkSpaceDataStoreCombo.SelectedIndex = -1
									$WorkSpaceNetworkCombo.SelectedIndex = -1
									
									$DataStores = (Get-Cluster $WorkSpaceClusterCombo.Text | Get-Datastore | Sort -Descending FreeSpaceGB).Name
									ForEach ($DataStore in $DataStores) 
									{
										[void] $WorkSpaceDataStoreCombo.Items.Add($DataStore)
									}
								}
								else
								{
									$WorkSpaceRSPTextBox.Clear()
									$WorkSpaceRSPCombo.Enabled = $true
									$WorkSpaceRSPTextBox.Enabled = $false
									$WorkSpaceDataStoreCombo.Enabled = $false
									$WorkSpaceDataStoreCombo.Items.Clear()
									$WorkSpaceDataStoreTextBox.Clear()
									$WorkSpaceNetworkCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$WorkSpaceRSPCombo.SelectedIndex = -1
									$WorkSpaceDataStoreCombo.SelectedIndex = -1
									$WorkSpaceNetworkCombo.SelectedIndex = -1
								}
							}
							$WorkSpaceRSPCheckBox.Add_CheckedChanged($WorkSpaceRSPCheckBox_Checked)
							
							
							$WorkSpaceRSPTextBox_TextChanged = {
								if ($WorkSpaceRSPTextBox.Text.Length -gt 0)
								{
									$WorkSpaceDataStoreCombo.Enabled = $true
								}
								else
								{
									$WorkSpaceDataStoreCombo.Enabled = $false
									$WorkSpaceNetworkCombo.Enabled = $false
								}
							}
							$WorkSpaceRSPTextBox.Add_TextChanged($WorkSpaceRSPTextBox_TextChanged)

							
							$WorkSpaceDataStoreCombo_SelectionChangeCommitted = {
								If ($WorkSpaceDataStoreCombo.Text.Length -gt 0)
								{
									$WorkSpaceNetworkCombo.Enabled = $true
									$WorkSpaceNetworkCombo.Items.Clear()
									$OKButton.Enabled = $false
									
									$FreeSpace = (Get-Datastore $WorkSpaceDataStoreCombo.Text).FreeSpaceGB
									$WorkSpaceDataStoreTextBox.Text = "{0:N0}" -f $FreeSpace 
									
									$NetworkNames = ((Get-Cluster $WorkSpaceClusterCombo.Text | Get-VMHost)[0] | Get-VirtualPortGroup).Name
									ForEach ($NetworkName in $NetworkNames)
									{
										[void] $WorkSpaceNetworkCombo.Items.Add($NetworkName)
									}
								}
							}
							$WorkSpaceDataStoreCombo.Add_SelectionChangeCommitted($WorkSpaceDataStoreCombo_SelectionChangeCommitted)
							#$NetworkName = "VLAN405"
							
							$WorkSpaceNetworkCombo_SelectionChangeCommitted = {
								If ($WorkSpaceNetworkCombo.Text.Length -gt 0)
								{
									$OKButton.Enabled = $true
								}	
							}
							$WorkSpaceNetworkCombo.Add_SelectionChangeCommitted($WorkSpaceNetworkCombo_SelectionChangeCommitted)
							# == User Interactive End == #
						}	
					}
			})
			
			$form.Controls.Add($WorkSpaceGroupBox)
		
		#$form.Controls.Add($GBOTTab)

		
		#New VM Tab
		# $NewVMTab = New-Object System.Windows.Forms.TabPage
		# $NewVMTab.Text = "New VM"
		# $NewVMTab.AutoSize = $true
		# $TabControl.Controls.Add($NewVMTab)
	
	#$Form.Controls.Add($TabControl)
	
	
$FormButtonSize = '100,40'
	
	#OK Button
	$OKButton = New-Object 'System.Windows.Forms.Button'
	$OKButton.Text = "OK"
	$OKButton.Location = New-Object System.Drawing.Size(($Width/3),($Height-90))
	$OKButton.Size = $FormButtonSize
	$OKButton.Enabled =  $false
	$OKButton.Add_Click({
		$Form.DialogResult = 'OK'
		$Form.Close()
	})
	$Form.Controls.Add($OKButton)
	
	
	#Cancel Button
	$CancelButton = New-Object 'System.Windows.Forms.Button'
	$CancelButton.Text = "Cancel"
	$CancelButton.Location = New-Object System.Drawing.Size(($Width/3*2),($Height-90))
	$CancelButton.Size = $FormButtonSize
	$CancelButton.Add_Click({$Form.Close()})
	$Form.Controls.Add($CancelButton)
	
	#Shortcut Key
	$Form.Add_KeyDown( { if ($_.KeyCode -eq "Escape") {$Form.Close()} } ) 
	
$Form.Add_Shown({$Form.Activate()})
$Result = $Form.ShowDialog()
# == Form Part End == #


if ($Result -eq 'Cancel') 
{ Write-Host "Cancelled by user" -ForegroundColor Yellow ; exit}
elseif ($Result -eq 'OK')
{	
	# == Build VM Part Start == #
	if ($WorkSpaceRSPCheckBox.Checked)
	{
		New-ResourcePool -Location $WorkSpaceClusterCombo.Text -Name $WorkSpaceRSPTextBox.Text -Confirm:$false
		$RSP = $WorkSpaceRSPTextBox.Text
	}
	else
	{
		$RSP = Get-Cluster $WorkSpaceClusterCombo.Text | Get-ResourcePool $WorkSpaceRSPCombo.Text
	}
	
	[array]$Server = $GBOTServerTextBox.Text.Split(",").Split(";").Split("/").Trim()
	[int32]$CPU = $GBOTCPUTextBox.Text
	[int32]$MemoryGB = $GBOTMemoryTextBox.Text
	[int32]$Sockets = $WorkSpaceSocketsTextBox.Text
	[array]$DiskGB = $GBOTHDDTextBox.Text.Split(" ").Trim()
	[array]$IP = $GBOTIPTextBox.Text.Split(",").Split(";").Split("/").Trim()
	$Sep = $IP[0].LastIndexOf(".") 
	$GW = $IP[0].Substring(0,$Sep) + ".1"
	if ($GBOTOSTextBox.Text -match "2012")
	{
		$GuestID = "Windows8Server64Guest"
	}
	else
	{
		$GuestID = "Windows7Server64Guest"
	}
	#$GuestID = "Windows8Server64Guest"
	

	# Copy OSD and bfi file
	$DIR = "[$($WorkSpaceDataStoreCombo.Text)]"
	$ISO = ""
	$ISOPath = $DIR + " ISO/" + $ISO
	$DNS = ""
	$DNSServer = ""
	$SCCMPath = "" + $ISO

	
	$Dest = $DIR.Trim("[]")
	$DataStorePath = "vmstores:\$($WorkSpaceVCTextBox.Text)@443\$($WorkSpaceDataCenterCombo.Text)\$Dest\ISO\$ISO"
	if ((dir $SCCMPath).Length -ne (dir $DataStorePath).Length)
	{
		$VMwithISO = Get-Datastore $Dest | Get-VM
		$VMwithISO | % { 
			if ((Get-CDDrive $_).IsoPath -eq $ISOPath) {
				Get-CDDrive $_ | Set-CDDrive -NoMedia  -Confirm:$false
			}
		}
		Copy-DatastoreItem $SCCMPath $DataStorePath -Force
	}
	
		
	for ($N = 0; $N -lt $Server.Count; $N++) {
		# Add Static DNS Resource Record
		Add-DnsServerResourceRecordA -ZoneName "paypalcorp.com" -Name $Server[$N] -IPv4Address $IP[$N] -CreatePtr -ComputerName $DnsServer -Confirm:$false | Out-Null
		
		$RSP | New-VM -Name $Server[$N] -Datastore $WorkSpaceDataStoreCombo.Text -GuestID $GuestID -NumCPU $CPU -MemoryGB $MemoryGB -Networkname $WorkSpaceNetworkCombo.Text -DiskGB $DiskGB -DiskStorageFormat Thick -Version $WorkSpaceVMVersionTextBox.Text -CD:$True -Confirm:$False -Floppy:$True

		$Spec = New-Object -Type VMware.Vim.VirtualMachineConfigSpec
		#$Spec.NumCPUs = 4
		$Spec.NumCoresPerSocket = $Sockets
		$Spec.CpuHotAddEnabled = $False
		$Spec.MemoryHotAddEnabled = $True
		$BootCD = New-Object -Type VMware.Vim.VirtualMachineBootOptionsBootableCdromDevice
		$Spec.BootOptions = New-Object VMware.Vim.VirtualMachineBootOptions -Property @{BootOrder = $BootCD}
		$Spec.Tools = New-Object VMware.Vim.ToolsConfigInfo -property @{ToolsUpgradePolicy = 'upgradeAtPowerCycle'}
		(Get-VM $Server[$N]).ExtensionData.ReconfigVM_Task($Spec)
		Get-VM $Server[$N] | Get-NetworkAdapter | Set-NetworkAdapter -Type vmxnet3 -Confirm:$False
		Get-VM $Server[$N] | Get-ScsiController | Set-ScsiController -Type ParaVirtual -Confirm:$False
		Get-CDDrive -VM $Server[$N] | Set-CDDrive -ISOPath $ISOPath -StartConnected:$True -Confirm:$False
		
		$SetIPStatic = "netsh interface ipv4 set address name=""Ethernet"" static $($IP[$N]) 255.255.252.0 $GW`r`nnetsh interface ipv4 set dnsservers name=""Ethernet"" source=static address=$($DNS) validate=no"
		
		
		Remove-Item C:\Temp\AutoVM\* -Force
		New-Item -Type file -Path "C:\Temp\AutoVM\SetStaticIP.bat" -Value "$SetIPStatic" -Force | Out-Null
		.\bfi.exe -f=C:\Temp\AutoVM\Scripts.img C:\Temp\AutoVM\
		Move-Item C:\Temp\AutoVM\Scripts.img C:\Temp\AutoVM\Scripts.flp 
		Copy-DatastoreItem C:\Temp\AutoVM\Scripts.flp "vmstores:\$($WorkSpaceVCTextBox.Text)@443\$($WorkSpaceDataCenterCombo.Text)\$Dest\ISO\Scripts.flp" -Force
		$FloppyImagePath = $DIR + " ISO/" + "Scripts.flp"
		Get-FloppyDrive -VM $Server[$N] | Set-FloppyDrive -FloppyImagePath $FloppyImagePath -StartConnected:$True -Confirm:$False
		
		Start-VM $Server[$N]
		Remove-Item C:\Temp\AutoVM\* -Force
		# == Build VM Part End == #
		
		#Invoke VMRC
		$VM =  Get-VM $Server[$N]
		$ServerInstance = Get-View ServiceInstance
		$SessionManager = Get-View $ServerInstance.Content.SessionManager
		$Ticket = $SessionManager.AcquireCloneTicket()
		$VMID = ($VM | Get-View).Moref.Value
		#$vc=$vm.uid.substring($vm.uid.indexof("@")+1,$vm.uid.indexof(":")-$vm.uid.indexof("@")-1)
		& 'C:\Program Files (x86)\VMware\VMware Remote Console\vmrc.exe' "vmrc://clone:$($Ticket)@$($WorkSpaceVCTextBox.Text)/?moid=$($VMID)"
	}
}

Write-Host "VM Build Completed. Please proceed deployment by opening vSphere console and install OS by OSD.
VMware Tools Upgrade at Power Cycle remains unchecked according to process
Please turn it on manually after OSD completed" -ForegroundColor Green
Pause
