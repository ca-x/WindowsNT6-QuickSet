;==============================================================================
; 模块：网络工具
; 说明：Winsock 重置、网络配置备份还原、时间同步、远程桌面端口、雨声白噪音、宽带连接创建
; 文件：src\features\net\Feat_NetTools.au3
; 函数：共 18 个
;==============================================================================
#include-once

Func ResetWinsock()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在重置Winsock，请稍候..'
	RunWait(@ComSpec & ' /c netsh winsock reset', '', @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '重置Winsock成功，重启后生效。', 5)
EndFunc   ;==>ResetWinsock
Func _NetWorkConfigsTool()
	Global $NetWorkConfigsUI = _GUICreate("网络配置备份与恢复", 277, 66, 144, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("备份网络配置[&B]", 8, 8, 259, 20)
	GUICtrlSetOnEvent(-1, '_MakeNetworkConfigBackup')
	GUICtrlCreateButton("还原网络配置[&R]", 8, 30, 259, 27)
	GUICtrlSetOnEvent(-1, '_RestroreNetworkConfigBackup')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitConfigUI')
EndFunc   ;==>_NetWorkConfigsTool
Func _QuitConfigUI()
	_WinAPI_AnimateWindow($NetWorkConfigsUI, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($NetWorkConfigsUI)
EndFunc   ;==>_QuitConfigUI
Func _MakeNetworkConfigBackup()
	Local $File = FileSaveDialog('请设置网络配置备份要进行保存的文件名称', '', '所有文件(*.*)', 16, '', $NetWorkConfigsUI)
	If Not @error Then
		TrayTip('提示', '正在备份网络配置，请稍候..', 3, 1)
		RunWait(@ComSpec & ' /c netsh dump >"' & $File & '"', @WindowsDir, @SW_HIDE)
		TrayTip('', '', 0)
		MsgBox(0, '提示', '已经成功备份当前网络配置~', 5, $NetWorkConfigsUI)
	Else
		TrayTip('提示', '用户取消了备份操作..', 3, 1)
	EndIf
EndFunc   ;==>_MakeNetworkConfigBackup
Func _RestroreNetworkConfigBackup()
	Local $File = FileOpenDialog('请选择网络配置备份文件', '', '所有文件(*.*)', 1, '', $NetWorkConfigsUI)
	If Not @error Then
		TrayTip('提示', '正在还原网络配置，请稍候..', 3, 1)
		RunWait(@ComSpec & ' /c netsh exec "' & $File & '"', @WindowsDir, @SW_HIDE)
		TrayTip('', '', 0)
		MsgBox(0, '提示', '已经成功还原网络配置到当前系统~', 5, $NetWorkConfigsUI)
	Else
		TrayTip('提示', '用户取消了还原操作..', 3, 1)
	EndIf
EndFunc   ;==>_RestroreNetworkConfigBackup
Func SynSysTime()
	;先判定网络是否连接，0表示断开，1表示连接
	If _IsConnectedToInternet() Then
		;预先读取时间格式
		Local $Regkey = 'HKEY_CURRENT_USER\Control Panel\International'
		Local $sShortDate = RegRead($Regkey, 'sShortDate')
		Local $sLongDate = RegRead($Regkey, 'sLongDate')
		Local $sTimeFormat = RegRead($Regkey, 'sTimeFormat')
		Local $sShortTime = RegRead($Regkey, 'sShortTime')
		;如果不是标准时间格式，那么就修改为标准时间格式
		If $sShortDate <> 'yyyy/M/d' Then
			RegWrite($Regkey, 'sShortDate', 'REG_SZ', 'yyyy/M/d')
		EndIf
		If $sLongDate <> "yyyy'年'M'月'd'日'" Then
			RegWrite($Regkey, 'sLongDate', 'REG_SZ', "yyyy'年'M'月'd'日'")
		EndIf
		If $sTimeFormat <> 'H:mm:ss' Then
			RegWrite($Regkey, 'sTimeFormat', 'REG_SZ', 'H:mm:ss')
		EndIf
		If $sShortTime <> 'H:mm' Then
			RegWrite($Regkey, 'sShortTime', 'REG_SZ', 'H:mm')
		EndIf
		;开始同步时间
		$_Now_date = _GetSrv_Date()
		$_Now_Splt = StringSplit($_Now_date, " ")
		If StringInStr($_Now_Splt[1], '/') Then
			$NowData = StringSplit($_Now_Splt[1], "/")
		Else
			$NowData = StringSplit($_Now_Splt[1], "-")
		EndIf
		$NowTime = StringSplit($_Now_Splt[2], ":")
		_SetDate($NowData[3], $NowData[2], $NowData[1])
		_SetTime($NowTime[1], $NowTime[2], $NowTime[3])
		;还原时间格式设置
		RegWrite($Regkey, 'sShortDate', 'REG_SZ', $sShortDate)
		RegWrite($Regkey, 'sLongDate', 'REG_SZ', $sLongDate)
		RegWrite($Regkey, 'sTimeFormat', 'REG_SZ', $sTimeFormat)
		RegWrite($Regkey, 'sShortTime', 'REG_SZ', $sShortTime)
		MsgBox(64, "我滴小伙伴！", "当前系统的时间已经校准完成！", 5)
	Else
		MsgBox(16, '我滴小伙伴！', '貌似当前没能连接到互联网' & @LF & '哦！所以校准不了时间！', 5)
	EndIf
EndFunc   ;==>SynSysTime

Func _GetSrv_Date()
	Local $_Srvlist[15] = ["ntp.api.bz", _
			"time-nw.nist.gov", _
			"time-a.nist.gov", _
			"time-b.nist.gov", _
			"time-a.timefreq.bldrdoc.gov", _
			"time-b.timefreq.bldrdoc.gov", _
			"time-c.timefreq.bldrdoc.gov", _
			"utcnist.colorado.edu", _
			"time.nist.gov", _
			"nist1.datum.com", _
			"nist1.dc.glassey.com", _
			"nist1.ny.glassey.com", _
			"nist1.sj.glassey.com", _
			"nist1.aol-ca.truetime.com", _
			"nist1.aol-va.truetime.com"]
	UDPStartup()
	Local $_Time_Srv
	For $x = 0 To UBound($_Srvlist) - 1
		$_Time_Srv = $_Srvlist[$x]
		Local $Socket = UDPOpen(TCPNameToIP($_Time_Srv), 123)
		If @error <> 0 Then ContinueLoop
		$status = UDPSend($Socket, MakePacket())
		If $status = 0 Then ContinueLoop
		Local $data = "", $i = 0
		While $data = ""
			$i += 1
			$data = UDPRecv($Socket, 100)
			If $i = 5 Then ContinueLoop (2)
			Sleep(88)
		WEnd
		UDPCloseSocket($Socket)
		UDPShutdown()
		ExitLoop
	Next
	If $data = "" Then Return 0
	$data = UnsignedHexToDec(StringMid($data, 83, 8))
	$data = _DateTimeFormat(_DateAdd("s", $data, "1900/01/01 08:00:00"), 0)
;~ 	ConsoleWrite('第['&$x&']个OK '&$data&@lf)
	Return $data
EndFunc   ;==>_GetSrv_Date

Func MakePacket()
	Local $P, $D = "1b0e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	While $D
		$P &= Chr(Dec(StringLeft($D, 2)))
		$D = StringTrimLeft($D, 2)
	WEnd
	Return $P
EndFunc   ;==>MakePacket
Func _Rainymood()
	Global $FRainyMood = GUICreate("Rainymood", 133, 198, 192, 124, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $oWMP = ObjCreate("WMPlayer.OCX")
	GUICtrlCreateObj($oWMP, 0, 0, 133, 181)
	AdlibRegister("SetWMPStaus")
	Global $WMPStatus = GUICtrlCreateLabel('', 1, 181, 133, 17)
	$oWMP.URL = "https://czyt.tech/0.m4a"
	$oWMP.controls.play()
	$oWMP.stretchToFit = True
	$oWMP.windowlessVideo = True
	$oWMP.fullscreen = True
	$oWMP.uiMode = 'none'
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitRainymood')
EndFunc   ;==>_Rainymood
Func _getPlaystatus()
	If IsObj($oWMP) Then
		Switch $oWMP.playState()
;~ 		1=停止，2=暂停，3=播放，6=正在缓冲，9=正在连接，10=准备就绪
			Case 1
				Return "停止"
			Case 2
				Return "暂停[VOL:" & $oWMP.settings.volume & ']'
			Case 3
				Return "播放" & $oWMP.controls.currentPositionString()
			Case 6
				Return "正在缓冲[VOL:" & $oWMP.settings.volume & ']'
			Case 9
				Return "正在连接"
			Case 10
				Return "准备就绪"
		EndSwitch
	EndIf
EndFunc   ;==>_getPlaystatus

Func SetWMPStaus()
	GUICtrlSetData($WMPStatus, '播放状态：' & _getPlaystatus())
EndFunc   ;==>SetWMPStaus
Func QuitRainymood()
	AdlibUnRegister("SetWMPStaus")
	$oWMP = ''
	_WinAPI_AnimateWindow($FRainyMood, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FRainyMood)
EndFunc   ;==>QuitRainymood

Func CreateDigUp()
	$sPnebk = @AppDataCommonDir & "\Microsoft\Network\Connections\Pbk\rasphone.pbk"
	$aEntry = _RasEnumEntries($sPnebk)
	If UBound($aEntry) > 1 Then
		MsgBox(16, '', '当前系统已经存在宽带连接！请检查！', 5)
	Else
		GUISetState(@SW_MINIMIZE, $Form1)
		Local $strConnectionName = '宽带连接'
		Run('rasphone.exe -a')
		If @OSBuild < 6000 Then
			WinActivate('[Class:#32770]')
			$Hwin = WinWait('[Class:#32770]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:4]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:6]')
			WinActivate($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:13]')
			FileCreateShortcut('%SystemRoot%\System32\Rasphone.exe', @DesktopDir & '\' & $strConnectionName & '.lnk', @WindowsDir, '-d "' & $strConnectionName & '"', '宽带连接，通过这个您可以使用宽带供应商为您提供的帐号和密码进行拨号上网', '%SystemRoot%\system32\netshell.dll', '', '105')
		Else
			$Hwin = WinWait('Set up a new connection', '', 5)
			WinActive($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:4]')
			WinWait($Hwin)
			WinActive($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:9]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:1]')
			FileCreateShortcut('%SystemRoot%\System32\Rasphone.exe', @DesktopDir & '\' & $strConnectionName & '.lnk', @WindowsDir, '-d "' & $strConnectionName & '"', '宽带连接，通过这个您可以使用宽带供应商为您提供的帐号和密码进行拨号上网', '%SystemRoot%\system32\netshell.dll', '', '105')
		EndIf
		MsgBox(0, '提示', '成功创建宽带连接！', 5)
		GUISetState(@SW_RESTORE, $Form1)
	EndIf
EndFunc   ;==>CreateDigUp
Func _GetRemoteDeskPort()
	Local $port = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp', 'PortNumber')
	If Not @error Then
		Return $port
	EndIf
EndFunc   ;==>_GetRemoteDeskPort
Func _IsFirewallOpen()
	$fwMgr = ObjCreate("HNetCfg.FwMgr")
	$profile = $fwMgr.LocalPolicy.CurrentProfile
	$isOpen = $profile.FirewallEnabled
	$fwMgr = 0
	Return $isOpen
EndFunc   ;==>_IsFirewallOpen
Func ChangeTerminPort()
	Local $port = _GetRemoteDeskPort()
	Global $FChangeTerminPort = _GUICreate("远程桌面端口修改器", 430, 65, 64, 120, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("当前远程桌面端口", 9, 0, 143, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $oldport = GUICtrlCreateLabel($port, 16, 16, 124, 17, BitOR($SS_CENTER, $SS_CENTERIMAGE, $WS_BORDER))
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("修改为端口", 160, 0, 137, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $NewPort = GUICtrlCreateInput($port, 168, 16, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)
	GUICtrlSetResizing(-1, $GUI_DOCKHCENTER + $GUI_DOCKHEIGHT)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("修改", 304, 8, 115, 33)
	GUICtrlSetOnEvent(-1, 'ChangeTermPortNum')
	Global $TakeEffNow = _GUICtrlCreateCheckbox("立即生效", 8, 45, 70, 17)
	GUICtrlSetTip(-1, '勾选此项目将立即生效，但会注销所有的远程登录会话。', '提示', 1)
	If _IsFirewallOpen() Then
		Global $addRuleinfw = _GUICtrlCreateCheckbox("在系统防火墙添加开放端口的防火墙规则", 81, 45, 312, 17)
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTerminChange')
EndFunc   ;==>ChangeTerminPort
Func QuitTerminChange()
	_WinAPI_AnimateWindow($FChangeTerminPort, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FChangeTerminPort)
EndFunc   ;==>QuitTerminChange
Func ChangeTermPortNum()
	Local $oldPortNum = GUICtrlRead($oldport)
	Local $NewPortNum = GUICtrlRead($NewPort)
	If $NewPortNum <> $oldPortNum Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp', 'PortNumber', 'REG_DWORD', $NewPortNum)
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentContro1Set\Control\Terminal Server\WinStations\RDP-Tcp', 'PortNumber', 'REG_DWORD', $NewPortNum)
		If _IsFirewallOpen() Then
			RunWait(@ComSpec & ' /c netsh advfirewall firewall delete rule name="WindowsNTRDP"', @WindowsDir, @SW_HIDE)
			If GUICtrlRead($addRuleinfw) = $GUI_CHECKED Then
				RunWait(@ComSpec & ' /c netsh advfirewall firewall add rule name="WindowsNTRDP" dir=in action=allow protocol=TCP localport=' & $NewPortNum, @WindowsDir, @SW_HIDE)
			EndIf
			If GUICtrlRead($TakeEffNow) = $GUI_CHECKED Then
				Run(@ComSpec & ' /c logoff rdp-tcp ', @WindowsDir, @SW_HIDE)
			EndIf
		EndIf
		_ForceUpdate()
		GUICtrlSetData($oldport, $NewPortNum)
		MsgBox(0, '', '已经成功修改远程桌面端口！！', 5)
	Else
		MsgBox(0, '', '未对端口号进行更改！！', 5)
	EndIf
EndFunc   ;==>ChangeTermPortNum
