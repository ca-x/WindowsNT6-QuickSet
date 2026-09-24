;==============================================================================
; 模块：网络唤醒
; 说明：WOL 界面、魔术包生成与发送、计划任务
; 文件：src\features\net\wol.au3
; 函数：共 7 个
;==============================================================================
#include-once

;=========================================================================================
; 网络唤醒
;=========================================================================================
Func WOLUI()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $WOL = _GUICreate("网络唤醒", 349, 114, 130, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("任务设定", 16, 8, 89, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$RdWOL[1] = _GUICtrlCreateRadio("单个唤醒", 24, 24, 72, 17)
	GUICtrlSetState($RdWOL[1], $GUI_CHECKED)
	GUICtrlSetOnEvent($RdWOL[1], 'ToogleWOLTaskType')
	$RdWOL[2] = _GUICtrlCreateRadio("批量唤醒", 24, 40, 72, 17)
	GUICtrlSetOnEvent($RdWOL[2], 'ToogleWOLTaskType')
	Global $MacToWOL = GUICtrlCreateInput("", 112, 40, 177, 21)
	Global $WOLLabel = GUICtrlCreateLabel("请输入要唤醒的计算机MAC地址", 112, 16, 220, 17)
	Global $WOLStatusLabel = GUICtrlCreateLabel("", 8, 100, 220, 18)
	Global $LocateMacFile = GUICtrlCreateButton("...", 296, 40, 43, 21)
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlSetTip(-1, '请选择包含要网络唤醒的计算机' & @LF & '的MAC地址的文件，每行一个MAC' & @LF & '地址,MAC地址可以是使用:或-进' & @LF & '行分割，也可以是无分割的', '提示', 1)
	GUICtrlSetOnEvent(-1, 'SelectMACFile')
	Global $startWOL = GUICtrlCreateButton("开始唤醒操作[&W]", 16, 72, 131, 25)
	GUICtrlSetOnEvent(-1, 'WOLMain')
	GUICtrlCreateButton("关闭[&Q]", 177, 73, 131, 25)
	GUICtrlSetOnEvent(-1, 'QuitWOL')
	GUISetState(@SW_SHOW, $WOL)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWOL', $WOL)
EndFunc   ;==>WOLUI

Func QuitWOL()
	_WinAPI_AnimateWindow($WOL, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($WOL)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitWOL

;切换单个任务和多个任务状态
Func ToogleWOLTaskType()
	Switch GUICtrlRead($RdWOL[1])
		Case $GUI_CHECKED
			GUICtrlSetData($MacToWOL, '')
			GUICtrlSetData($WOLLabel, '请输入要唤醒的计算机MAC地址')
			GUICtrlSetState($LocateMacFile, $GUI_HIDE)
			GUICtrlSetState($MacToWOL, $GUI_NODROPACCEPTED)
		Case $GUI_UNCHECKED
			GUICtrlSetData($MacToWOL, '')
			GUICtrlSetData($WOLLabel, '请选择包含要唤醒计算机MAC地址的文件')
			GUICtrlSetState($LocateMacFile, $GUI_SHOW)
			GUICtrlSetState($MacToWOL, $GUI_DROPACCEPTED)
	EndSwitch
EndFunc   ;==>ToogleWOLTaskType
;选择包含MAC地址的文本文件
Func SelectMACFile()
	Local $File = FileOpenDialog('请选择包含计算机MAC地址的文件', '', '所有支持的文件(*.*)')
	If FileExists($File) Then GUICtrlSetData($MacToWOL, $File)
EndFunc   ;==>SelectMACFile
; 网络唤醒
Func WOLMain()
	Local $macSome = GUICtrlRead($MacToWOL)
	If $macSome <> '' Then
		GUICtrlSetState($LocateMacFile, $GUI_DISABLE)
		GUICtrlSetState($RdWOL[1], $GUI_DISABLE)
		GUICtrlSetState($RdWOL[2], $GUI_DISABLE)
		GUICtrlSetState($MacToWOL, $GUI_DISABLE)
		GUICtrlSetState($startWOL, $GUI_DISABLE)
		Switch GUICtrlRead($RdWOL[1])
			Case $GUI_CHECKED
				_WOL($macSome)
			Case $GUI_UNCHECKED
				If FileExists($macSome) Then
					Local $macArry
					_FileReadToArray($macSome, $macArry)
					If Not @error Then
						_ArrayDelete($macArry, 0)
						If UBound($macArry) > 0 Then
							_WOL($macArry)
						EndIf
					EndIf
				EndIf
		EndSwitch
		GUICtrlSetState($LocateMacFile, $GUI_ENABLE)
		GUICtrlSetState($RdWOL[1], $GUI_ENABLE)
		GUICtrlSetState($RdWOL[2], $GUI_ENABLE)
		GUICtrlSetState($MacToWOL, $GUI_ENABLE)
		GUICtrlSetState($startWOL, $GUI_ENABLE)
		GUICtrlSetData($WOLStatusLabel, '')
		MsgBox(0, '嘻嘻', '成功执行网络唤醒操作!', 5, $WOL)
	Else
		MsgBox(16, '提示', GUICtrlRead($WOLLabel), 5, $WOL)
	EndIf
EndFunc   ;==>WOLMain

;核心函数
; ===================================================================
; 函数 *=== 此功能返回生成 "数据包" ===*
; ===================================================================
Func GenerateMagicPacket($strMACAddress)
	$MagicPacket = Binary("0xFFFFFFFFFFFF")
	For $P = 1 To 16 ;
		$MagicPacket &= $strMACAddress
	Next
	$MagicPacket &= ("000000000000") ;最后6个字节是密码，没有密码的话可以0x00填充
;~ 	ConsoleWrite($MagicPacket & @CRLF)
	Return $MagicPacket
EndFunc   ;==>GenerateMagicPacket

; ===================================================================
; 网络唤醒
;功能说明 数组形式传递MAC，可以一次唤醒多机 直接唤醒一台机的MAC
; MAC格式支持:跟-分隔符的，或是不带分隔符的
;参数 $mac MAC格式的字符串或是数组都可以，程序自动识别 $port，程序运行端口，
;错误返回 0为网络错误
; -1参数不对
; -2MAC格式不对
; ===================================================================
Func _WOL($Mac, $port = 7)
	$IPAddress = "255.255.255.255" ; 这是广播地址 !
	UDPStartup() ;开始 UDP 服务.
	$connexion = UDPOpen($IPAddress, $port, 1) ;连接到服务器进行会话,port为7赋给变量"$connexion"
	If $connexion[0] == 0 Then Return ;如果出错则返回 @error: windows API WSAGetError 返回值

	If IsArray($Mac) Then
		$dims = UBound($Mac, 0)
		If $dims > 1 Then Return -1 ;参数不对

		For $element In $Mac
			ConsoleWrite($element & @CRLF)
			$element = StringReplace($element, ":", "")
			$element = StringReplace($element, "-", "")
			$strLen = StringLen($element)
			If StringIsXDigit($element) And $strLen < 13 Then
				GUICtrlSetData($WOLStatusLabel, '正在网络唤醒MAC地址为[' & $element & ']的计算机..')
				$res = UDPSend($connexion, GenerateMagicPacket($element)) ;打开的套接字(socket)上面发送数据,GenerateMagicPacket($MACAddress)调用函数
			Else
				GUICtrlSetData($WOLStatusLabel, 'MAC地址[' & $element & ']错误，无法执行唤醒操作..')
				Return -2 ;MAC格式不对
			EndIf
		Next
	Else
		$Mac = StringReplace($Mac, ":", "")
		$Mac = StringReplace($Mac, "-", "")
		$strLen = StringLen($Mac)
		ConsoleWrite($Mac & @CRLF)
		If StringIsXDigit($Mac) And $strLen < 13 Then
			GUICtrlSetData($WOLStatusLabel, '正在网络唤醒MAC地址为[' & $Mac & ']的计算机..')
			$res = UDPSend($connexion, GenerateMagicPacket($Mac)) ;打开的套接字(socket)上面发送数据,GenerateMagicPacket($MACAddress)调用函数
		Else
			GUICtrlSetData($WOLStatusLabel, 'MAC地址[' & $Mac & ']错误，无法执行唤醒操作..')
			Return -2 ;MAC格式不对
		EndIf
	EndIf

EndFunc   ;==>_WOL
