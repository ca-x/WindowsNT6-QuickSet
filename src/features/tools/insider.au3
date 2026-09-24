;==============================================================================
; 模块：Windows 预览体验计划
; 说明：预览体验计划通道切换与注册表配置
; 文件：src\features\tools\insider.au3
; 函数：共 12 个
;==============================================================================
#include-once


Func InsiderSwitchUI()

	Global $InsiderSwicth = _GUICreate("Windows预览版计划切换器", 327, 176, 106, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择要切换的通道", 24, 8, 169, 145)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $dev = GUICtrlCreateRadio("Dev通道", 40, 32, 113, 17)
	Global $beta = GUICtrlCreateRadio("Beta通道", 40, 56, 97, 17)
	Global $rp = GUICtrlCreateRadio("Release Preview通道", 40, 77, 129, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $quitInsider = GUICtrlCreateRadio("停止接收预览版", 40, 102, 113, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("应用选项", 200, 40, 105, 65)
	GUICtrlSetOnEvent(-1, "ApplyInsiderSwitchSetting")
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitInsiderUI')
EndFunc   ;==>InsiderSwitchUI


Func _QuitInsiderUI()
	_WinAPI_AnimateWindow($InsiderSwicth, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($InsiderSwicth)
EndFunc   ;==>_QuitInsiderUI
Func ApplyInsiderSwitchSetting()
	ResetInsiderConfig()
	$isFlightSigningEnabled = checkFlightSigningEnabled()
	If GUICtrlRead($dev) = $GUI_CHECKED Then
		SwitchToDevChannel()
		toogleNormalInsiderChannel($isFlightSigningEnabled, "Dev")
	EndIf
	If GUICtrlRead($beta) = $GUI_CHECKED Then
		SwitchToBetaChannel()
		toogleNormalInsiderChannel($isFlightSigningEnabled, "Beta")
	EndIf
	If GUICtrlRead($rp) = $GUI_CHECKED Then
		SwitchToReleasePreviewChannel()
		toogleNormalInsiderChannel($isFlightSigningEnabled, "Release Preview")
	EndIf
	If GUICtrlRead($quitInsider) = $GUI_CHECKED Then
		If $isFlightSigningEnabled Then
			SetFlightSigningOff()
		EndIf
		MsgBox(0, '提示', "退出内部预览版通道成功！", 5)
	EndIf
EndFunc   ;==>ApplyInsiderSwitchSetting

Func toogleNormalInsiderChannel($isFlightSigningEnabled, $channel)
	If $isFlightSigningEnabled Then
		MsgBox(0, '提示', '切换内部通道为：' & $channel & "成功！", 5)
	Else
		$resp = SetFlightSigningOn()
		MsgBox(0, '提示', '切换内部通道为：' & $channel & "成功,系统返回信息:" & $resp & "，请重启以生效！", 5)
	EndIf
EndFunc   ;==>toogleNormalInsiderChannel



Func SwitchToDevChannel()
	_EnRoll("Dev", "Dev Channel", 2, "Mainline", "External", 11)
EndFunc   ;==>SwitchToDevChannel

Func SwitchToBetaChannel()
	_EnRoll("Beta", "Beta Channel", 4, "Mainline", "External", 11)
EndFunc   ;==>SwitchToBetaChannel

Func SwitchToReleasePreviewChannel()
	_EnRoll("ReleasePreview", "Release Preview Channel", 8, "Mainline", "External", 11)
EndFunc   ;==>SwitchToReleasePreviewChannel

Func ResetInsiderConfig()
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Account")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Cache")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Restricted")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ToastNotification")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring%Ring%")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry")
	RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate", "BranchReadinessLevel")
	_ForceUpdate()
EndFunc   ;==>ResetInsiderConfig

Func _EnRoll($channel, $fancy, $Brl, $content, $Ring, $RId)
	If @OSBuild < 21990 Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings", "StickyXaml", "REG_SZ", '<StackPanel xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"><TextBlock Style="{StaticResource BodyTextBlockStyle }">此设备已通过“Windows预览体验计划通道切换器”注册到预览体验计划。若你想要修改预览体验计划设置或退出预览体验计划，请重新运行此脚本。</TextBlock><TextBlock Text="应用的设置" Margin="0,20,0,10" Style="{StaticResource SubtitleTextBlockStyle}" /><TextBlock Style="{StaticResource BodyTextBlockStyle }" Margin="0,0,0,5"><Run FontFamily="Segoe MDL2 Assets">&#xECA7;</Run> <Span FontWeight="SemiBold">' & $channel & '</Span><TextBlock Text="诊断反馈设置" Margin="0,20,0,10" Style="{StaticResource SubtitleTextBlockStyle}" /><TextBlock Style="{StaticResource BodyTextBlockStyle }">Windows预览体验计划需要使用此设备的必需及可选诊断数据。你可通过以下链接检查此选项是否正常开启。</TextBlock><Button Command="{StaticResource ActivateUriCommand}" CommandParameter="ms-settings:privacy-feedback" Margin="0,10,0,0"><TextBlock Margin="5,0,5,0">打开诊断和反馈</TextBlock></Button></StackPanel>')
	Else
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings", "StickyMessage", "REG_SZ", '{"Message":"此设置由“Windows预览体验计划通道切换器”来管理","LinkTitle":"","LinkUrl":"","DynamicXaml":"<StackPanel xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\"><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">此设备已通过“Windows预览体验计划通道切换器”注册到预览体验计划。若你想要修改预览体验计划设置或退出预览体验计划，请重新运行此脚本。</TextBlock><TextBlock Text=\"应用的设置\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\" Margin=\"0,0,0,5\"><Run FontFamily=\"Segoe MDL2 Assets\">&#xECA7;</Run> <Span FontWeight=\"SemiBold\">' & $channel & '</Span></TextBlock><TextBlock Text=\"诊断反馈设置\" Margin=\"0,20,0,10\" Style=\"{StaticResource SubtitleTextBlockStyle}\" /><TextBlock Style=\"{StaticResource BodyTextBlockStyle }\">Windows预览体验计划需要使用此设备的必需及可选诊断数据。你可通过以下链接检查此选项是否正常开启。</TextBlock><Button Command=\"{StaticResource ActivateUriCommand}\" CommandParameter=\"ms-settings:privacy-feedback\" Margin=\"0,10,0,0\"><TextBlock Margin=\"5,0,5,0\">打开诊断和反馈</TextBlock></Button></StackPanel>","Severity":0}')

	EndIf
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator", "EnableUUPScan", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\Ring" & $Ring, "Enabled", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat", "WUMUDCATEnabled", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "EnablePreviewBuilds", "REG_DWORD", "2")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "IsBuildFlightingEnabled", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "IsConfigSettingsFlightingEnabled", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "IsConfigExpFlightingEnabled", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "TestFlags", "REG_DWORD", "32")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "RingId", "REG_DWORD", $RId)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "Ring", "REG_SZ", $Ring)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "ContentType", "REG_SZ", $content)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "BranchName", "REG_SZ", $channel)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIHiddenElements", "REG_DWORD", "65535")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIDisabledElements", "REG_DWORD", "65535")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIServiceDrivenElementVisibility", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIErrorMessageVisibility", "REG_DWORD", "192")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry", "REG_DWORD", "3")
	If $Brl <> "" Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate", "BranchReadinessLevel", "REG_DWORD", $Brl)
	EndIf
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIHiddenElements_Rejuv", "REG_DWORD", "65534")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility", "UIDisabledElements_Rejuv", "REG_DWORD", "65535")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIRing", "REG_SZ", $Ring)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIContentType", "REG_SZ", $content)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIBranch", "REG_SZ", $channel)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIOptin", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "RingBackup", "REG_SZ", $Ring)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "RingBackupV2", "REG_SZ", $Ring)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "BranchBackup", "REG_SZ", $channel)
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Cache", "PropertyIgnoreList", "REG_SZ", "AccountsBlob;;CTACBlob;FlightIDBlob;ServiceDrivenActionResults")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Cache", "RequestedCTACAppIds", "REG_SZ", "WU;FSS")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Account", "SupportedTypes", "REG_DWORD", "3")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Account", "Status", "REG_DWORD", "8")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\Applicability", "UseSettingsExperience", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "AllowFSSCommunications", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "UICapabilities", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "IgnoreConsolidation", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "MsaUserTicketHr", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "MsaDeviceTicketHr", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "ValidateOnlineHr", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "LastHR", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "ErrorState", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "PilotInfoRing", "REG_DWORD", "3")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "RegistryAllowlistVersion", "REG_DWORD", "4")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\ClientState", "FileAllowlistVersion", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI", "UIControllableState", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIDialogConsent", "REG_DWORD", "0")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "UIUsage", "REG_DWORD", "26")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "OptOutState", "REG_DWORD", "25")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\WindowsSelfHost\UI\Selection", "AdvancedToggleState", "REG_DWORD", "24")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\WindowsUpdate", "AllowWindowsUpdate", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\MoSetup", "AllowUpgradesWithUnsupportedTPMOrCPU", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\LabConfig", "BypassRAMCheck", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\LabConfig", "BypassSecureBootCheck", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\LabConfig", "BypassStorageCheck", "REG_DWORD", "1")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\Setup\LabConfig", "BypassTPMCheck", "REG_DWORD", "1")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\PCHC", "UpgradeEligibility", "REG_DWORD", "1")
	_ForceUpdate()

EndFunc   ;==>_EnRoll

Func checkFlightSigningEnabled()
	$check = Run('bcdedit -enum {current}', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($check)
	$text = StdoutRead($check)
	Return StringRegExp($text, '\bflightsigning.+Yes\b', 0, 1) == 1
EndFunc   ;==>checkFlightSigningEnabled

Func SetFlightSigningOn()
	$check = Run('bcdedit -set {current} flightsigning yes', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($check)
	Return StdoutRead($check)
EndFunc   ;==>SetFlightSigningOn

Func SetFlightSigningOff()
	$check = Run('bcdedit -deletevalue {current} flightsigning', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	ProcessWaitClose($check)
	Return StdoutRead($check)
EndFunc   ;==>SetFlightSigningOff
