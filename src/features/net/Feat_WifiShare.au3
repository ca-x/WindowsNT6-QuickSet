;==============================================================================
; 模块：Wifi 热点共享
; 说明：创建 Wifi 热点、ICS 共享设置
; 文件：src\features\net\Feat_WifiShare.au3
; 函数：共 11 个
;==============================================================================
#include-once

Func CreateWifiDlg()
	HotKeySet('^{1}', 'CleanWifi')
	HotKeySet('^{2}', 'ReloadWifi')
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $Wifi = _GUICreate("创建Wifi热点", 259, 157, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $WifiName = GUICtrlCreateInput("", 16, 16, 225, 21)
	GUICtrlSetTip(-1, "您要共享出来的Wifi显示名称，最好是英文！")
	Global $WifiPwd = GUICtrlCreateInput("", 16, 75, 225, 21, $ES_PASSWORD)
	_GUICtrlEdit_SetPasswordChar(-1, '#')
	GUICtrlSetTip(-1, "密码至少8位以上，否则可能创建失败！")
	Global $ICSFrom = GUICtrlCreateCombo("", 16, 16, 225, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $ICSTo = GUICtrlCreateCombo("", 17, 73, 225, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $PreStep = GUICtrlCreateButton("<", 8, 128, 35, 25)
	GUICtrlSetTip(-1, "返回上一步操作")
	GUICtrlSetOnEvent(-1, '_PreStep')
	GUICtrlSetState(-1, $GUI_DISABLE)
	Global $BtnCreateWifi = GUICtrlCreateButton("创建Wifi热点[&C]", 48, 128, 163, 25)
	GUICtrlSetTip(-1, '按CTRL+1可以清除已经创建的wifi热点' & @LF & '按CTRL+2可以激活已经创建的Wifi热点', '说明', 1, 2)
	GUICtrlSetOnEvent(-1, 'CreateWifi')
	Global $BtnSetICS = GUICtrlCreateButton("应用ICS设置[&A]", 48, 128, 163, 25)
	GUICtrlSetOnEvent(-1, 'ApplyICS')
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $NextStep = GUICtrlCreateButton(">", 216, 128, 35, 25)
	GUICtrlSetTip(-1, "进行下一步操作")
	GUICtrlSetOnEvent(-1, '_NextStep')
	Global $GwifiName = GUICtrlCreateGroup("Wifi热点名称", 8, 0, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $GICSFrom = GUICtrlCreateGroup("要使用的网络连接", 8, 0, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $GwifiPwd = GUICtrlCreateGroup("Wifi热点密码", 10, 58, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $GICSTo = GUICtrlCreateGroup("用于创建wifi热点的连接", 10, 58, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$FlagShowPassword[2] = _GUICtrlCreateCheckbox("显示密码", 16, 104, 97, 17)
	GUICtrlSetOnEvent($FlagShowPassword[2], '_ShowPassword')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWifiDlg')
EndFunc   ;==>CreateWifiDlg
Func QuitWifiDlg()
	ToolTip("")
	_WinAPI_AnimateWindow($Wifi, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Wifi)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	HotKeySet('^{1}')
	HotKeySet('^{2}')
EndFunc   ;==>QuitWifiDlg
Func _ShowPassword()
	If GUICtrlRead($FlagShowPassword[2]) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($WifiPwd)
	Else
		_GUICtrlEdit_SetPasswordChar($WifiPwd, '#')
	EndIf
	GUICtrlSetState($WifiPwd, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($WifiPwd, -1, -1)
EndFunc   ;==>_ShowPassword
Func CreateWifi()
	If GUICtrlRead($WifiName) <> '' And GUICtrlRead($WifiPwd) <> '' Then
		GUISetState(@SW_HIDE, $Wifi)
		$cmd = Run(@ComSpec & ' /c netsh wlan show drivers', @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		ProcessWaitClose($cmd)
		$result = StdoutRead($cmd)
		If StringInStr($result, '支持的承载网络  : 是') Then
			;MsgBox(0,'','支持')
			ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '开始设置服务模式和SSID，PASS' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			RunWait(@ComSpec & ' /c netsh wlan set hostednetwork mode=allow ssid="' & GUICtrlRead($WifiName) & '" key="' & GUICtrlRead($WifiPwd) & '"', @SystemDir & '\', @SW_HIDE)
			ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在启动服务' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			RunWait(@ComSpec & ' /c netsh wlan start hostednetwork', @SystemDir & '\', @SW_HIDE)
			GUISetState(@SW_SHOW, $Wifi)
			$sHalfDone = _
					'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆' & @CRLF & _
					'Wifi热点创建完毕，请点击[>]按钮进入下一步操作，或' & @CRLF & _
					'通过手工方式进行操作，手工操作方式如下：' & @CRLF & _
					'打开网络共享中心--更改适配器设置,右击您当前使用的' & @CRLF & _
					'网络，选择属性,点击共享，勾选“允许其他网络用户通' & @CRLF & _
					'过连接来连接”选项,在下拉菜单中选择您刚才创建的Wi' & @CRLF & _
					'fi名称。' & @CRLF & _
					'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆'
			ToolTip($sHalfDone, @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			Sleep(5000)
		Else
			MsgBox(0, '', '您当前系统不支持！')
		EndIf
		GUISetState(@SW_SHOW, $Wifi)
	Else
		MsgBox(16, '', 'Wifi热点名称和Wifi热点密码都不能为空！请填写后再试！', 5)
	EndIf
EndFunc   ;==>CreateWifi
Func ApplyICS()
	Local $sourceNet = GUICtrlRead($ICSFrom), $destinNet = GUICtrlRead($ICSTo)
	If $sourceNet <> '' And $destinNet <> '' Then
		_SetICSbyName("on", $destinNet, $sourceNet)
		$sFinished = _
				'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆' & @CRLF & _
				'创建wifi成功，请尽情享受wifi带来的畅快与便捷吧！' & @CRLF & _
				'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆'
	Else
		MsgBox(16, '错误', '请选择要进行设置的连接', 5)
	EndIf
	ToolTip($sFinished, @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	Sleep(4000)
EndFunc   ;==>ApplyICS
Func sApName()
	$NetInfo = _GetNetworkAdapterInfo()
	Local $NewAdapterList = GetAdaptersList()
	Local $sName = ''
	For $i = 0 To UBound($NewAdapterList) - 1
		$sName &= $NewAdapterList[$i][5] & '|'
	Next
	Return $sName
EndFunc   ;==>sApName
Func _SetICSbyName($switch, $con1 = "", $con2 = "")
	Const $ICSSC_DEFAULT = 0
	Const $CONNECTION_PUBLIC = 0
	Const $CONNECTION_PRIVATE = 1
	Const $CONNECTION_ALL = 2
	$NetSharingManager = ObjCreate("HNetCfg.HNetShare.1")
	If (IsObj($NetSharingManager)) = False Then
		ConsoleWrite("Unable to get the HNetCfg.HnetShare.1 object" & @CRLF)
		Return
	EndIf
	;如果已经开启连接共享，先关闭
	$Connections = $NetSharingManager.EnumPublicConnections($ICSSC_DEFAULT)
	If $Connections.Count > 0 Then
		For $Item In $Connections
			$PublicConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
			$PublicConnection.DisableSharing
		Next
	EndIf
	$Connections = $NetSharingManager.EnumPrivateConnections($ICSSC_DEFAULT)
	If $Connections.Count > 0 Then
		For $Item In $Connections
			$PrivateConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
			$PrivateConnection.DisableSharing
		Next
	EndIf
	If $switch = "off" Then Return
	;如果是关闭共享，到止为止，下面不执行
	$EveryConnectionCollection = $NetSharingManager.EnumEveryConnection
	For $Item In $EveryConnectionCollection
		$EveryConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
		$objNCProps = $NetSharingManager.NetConnectionProps($Item)

		If $objNCProps.Name = $con1 Then
			$EveryConnection.EnableSharing($CONNECTION_PRIVATE)
		EndIf

		If $objNCProps.Name = $con2 Then
			$EveryConnection.EnableSharing($CONNECTION_PUBLIC)
		EndIf
	Next

EndFunc   ;==>_SetICSbyName
Func _NextStep()
	GUICtrlSetState($WifiName, $GUI_HIDE)
	GUICtrlSetState($WifiPwd, $GUI_HIDE)
	GUICtrlSetState($PreStep, $GUI_ENABLE)
	GUICtrlSetState($BtnCreateWifi, $GUI_HIDE)
	GUICtrlSetState($NextStep, $GUI_DISABLE)
	GUICtrlSetState($FlagShowPassword[2], $GUI_DISABLE)
	GUICtrlSetState($GwifiName, $GUI_HIDE)
	GUICtrlSetState($GwifiPwd, $GUI_HIDE)
	GUICtrlSetState($BtnCreateWifi, $GUI_HIDE)
	;显示之前创建的控件
	GUICtrlSetState($ICSFrom, $GUI_SHOW)
	GUICtrlSetState($ICSTo, $GUI_SHOW)
	GUICtrlSetState($BtnSetICS, $GUI_SHOW)
	GUICtrlSetState($GICSFrom, $GUI_SHOW)
	GUICtrlSetState($GICSTo, $GUI_SHOW)
	GUICtrlSetState($BtnSetICS, $GUI_SHOW)

	Local $sComData = sApName()
	GUICtrlSetData($ICSFrom, '')
	GUICtrlSetData($ICSTo, '')
	GUICtrlSetData($ICSFrom, $sComData)
	GUICtrlSetData($ICSTo, $sComData)
EndFunc   ;==>_NextStep
Func _PreStep()
	;隐藏之前创建的控件
	GUICtrlSetState($ICSFrom, $GUI_HIDE)
	GUICtrlSetState($ICSTo, $GUI_HIDE)
	GUICtrlSetState($BtnSetICS, $GUI_HIDE)
	GUICtrlSetState($GICSFrom, $GUI_HIDE)
	GUICtrlSetState($GICSTo, $GUI_HIDE)
	GUICtrlSetState($BtnSetICS, $GUI_HIDE)

	GUICtrlSetState($WifiName, $GUI_SHOW)
	GUICtrlSetState($WifiPwd, $GUI_SHOW)
	GUICtrlSetState($PreStep, $GUI_DISABLE)
	GUICtrlSetState($BtnCreateWifi, $GUI_SHOW)
	GUICtrlSetState($NextStep, $GUI_ENABLE)
	GUICtrlSetState($FlagShowPassword[2], $GUI_ENABLE)
	GUICtrlSetState($GwifiName, $GUI_SHOW)
	GUICtrlSetState($GwifiPwd, $GUI_SHOW)
	GUICtrlSetState($BtnCreateWifi, $GUI_SHOW)
EndFunc   ;==>_PreStep
Func CleanWifi()
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在停止服务..' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan stop hostednetwork', @SystemDir & '\', @SW_HIDE)
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在清理...' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan set hostednetwork mode=disallow', @SystemDir & '\', @SW_HIDE)
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '清理完成，(*^__^*) 嘻嘻' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
EndFunc   ;==>CleanWifi
Func ReloadWifi()
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在启动服务..' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan start hostednetwork', @SystemDir & '\', @SW_HIDE)
EndFunc   ;==>ReloadWifi
