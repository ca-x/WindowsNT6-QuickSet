;==============================================================================
; 模块：ThinkPad 热键
; 说明：ThinkPad 热键定义、X62 Intel 无线指示灯设置
; 文件：src\features\tools\tp_hotkey.au3
; 函数：共 12 个
;==============================================================================
#include-once


Func TPHotKeySet()
	Global $FormTPset = _GUICreate("Thinkpad 热键定义程序", 281, 149, 164, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("按键设定", 8, 8, 145, 81)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$aThinkHotkey[1] = _GUICtrlCreateRadio("ThinkVantage", 24, 32, 113, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetOnEvent($aThinkHotkey[1], '_LoadradioSet')
	$aThinkHotkey[2] = _GUICtrlCreateRadio("FN+", 24, 56, 35, 17)
	GUICtrlSetOnEvent($aThinkHotkey[2], '_LoadradioSet')
	Global $CmbKey = GUICtrlCreateCombo("F1", 64, 56, 49, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, '_LoadradioSet')
	Local $sKey = ''
	For $i = 2 To 12
		$sKey &= 'F' & $i & '|'
	Next
	GUICtrlSetData(-1, $sKey)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateLabel("执行程序", 8, 98, 52, 17)
	Global $TPFilePath = GUICtrlCreateInput("", 64, 96, 177, 21)
	GUICtrlCreateButton("..", 248, 96, 19, 21)
	GUICtrlSetOnEvent(-1, 'locateExecutor')
	GUICtrlCreateLabel("程序执行参数", 8, 127, 88, 17)
	Global $TParam = GUICtrlCreateInput("", 85, 125, 180, 21)
	GUICtrlCreateButton("设定[&S]", 168, 16, 99, 25)
	GUICtrlSetOnEvent(-1, 'TpSetKey')
	GUICtrlCreateButton("清除[&C]", 167, 53, 99, 25)
	GUICtrlSetOnEvent(-1, 'TPClearkey')
	_LoadradioSet()
	GUISetState(@SW_SHOW, $FormTPset)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTP')
EndFunc   ;==>TPHotKeySet

Func QuitTP()
	_WinAPI_AnimateWindow($FormTPset, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormTPset)
EndFunc   ;==>QuitTP
Func X62intelWlanLed()
	Global $x62intelWlan = GUICreate("X62 intel 无线状态灯设置程序", 337, 165, 155, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("连接名称", 16, 0, 313, 65)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $ConnNameWlan = GUICtrlCreateCombo("", 24, 16, 297, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetOnEvent(-1, 'showNCNameInGUI')
	GUICtrlCreateLabel("网卡名称:", 24, 40, 80, 17)
	Global $NcName = GUICtrlCreateLabel("", 104, 40, 296, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("状态选择", 16, 64, 313, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $LedStatus = GUICtrlCreateCombo("[0]总是关闭状态灯", 24, 80, 297, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "[1]状态灯随无线网络状态闪烁|[2]状态灯常亮|[3]状态灯随无线网络状态闪烁")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("设定选项", 16, 128, 315, 25)
	GUICtrlSetOnEvent(-1, '_ApplyIntelWlansetting')
	Global $ReStartInterface = GUICtrlCreateCheckbox("重新启用指定连接以使选项生效", 16, 112, 233, 17)
	loadConnNameToCombo()
	GUISetState(@SW_SHOW, $x62intelWlan)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'Quit62wlan')
EndFunc   ;==>X62intelWlanLed
Func Quit62wlan()
	_WinAPI_AnimateWindow($x62intelWlan, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($x62intelWlan)
EndFunc   ;==>Quit62wlan
Func loadConnNameToCombo()
	;加载连接到列表
	Local $s = ''
	For $i = 0 To $AdapterList[0][0]
		If _IsWirelessAdapter($AdapterList[$i][0]) Then
			$s &= $AdapterList[$i][5] & '|'
		EndIf
	Next
	GUICtrlSetData($ConnNameWlan, $s)
EndFunc   ;==>loadConnNameToCombo
Func showNCNameInGUI()
	For $i = 0 To $AdapterList[0][0]
		If GUICtrlRead($ConnNameWlan) = $AdapterList[$i][5] Then
			GUICtrlSetData($NcName, $AdapterList[$i][0])
		EndIf
	Next
EndFunc   ;==>showNCNameInGUI
Func _ApplyIntelWlansetting()
	For $i = 0 To $AdapterList[0][0]
		If GUICtrlRead($NcName) = $AdapterList[$i][0] Then
			Local $aSRE = StringRegExp(GUICtrlRead($LedStatus), '\d', 3)
			If Not @error Then
				RegWrite($AdapterList[$i][2], 'LedMode', 'REG_DWORD', $aSRE[0])
				If GUICtrlRead($ReStartInterface) = $GUI_CHECKED Then
					RunWait(@ComSpec & ' /c PowerShell Restart-NetAdapter -Name ' & GUICtrlRead($ConnNameWlan), @WindowsDir, @SW_HIDE)
				EndIf
				MsgBox(0, '提示', '已经将配置应用到指定连接！', 5)
			EndIf
		EndIf
	Next
EndFunc   ;==>_ApplyIntelWlansetting
Func locateExecutor()
	Local $File = FileOpenDialog('请选择可执行程序的路径', '', '可执行程序(*.exe;*.bat;*.cmd;*.ps1)', 1 + 8, '')
	If FileExists($File) Then GUICtrlSetData($TPFilePath, $File)
EndFunc   ;==>locateExecutor
Func TPHokey($parmeter = 0)
	Local $sRegKey = ''
	If GUICtrlRead($aThinkHotkey[1]) = $GUI_CHECKED Then
		$sRegKey = 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\IBM\TPHOTKEY\8001'
	EndIf
	If GUICtrlRead($aThinkHotkey[2]) = $GUI_CHECKED Then
		Local $stemp = StringRegExp(GUICtrlRead($CmbKey), '\d+', 3)
		$sRegKey = 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\IBM\TPHOTKEY\Class\01\' & $aKey[$stemp[0] - 1]
	EndIf
	;模式值=0 读取
	;模式值=1 写入
	If $parmeter = 0 Then
		Local $executor = RegRead($sRegKey, 'File')
		GUICtrlSetData($TPFilePath, $executor)
		Local $exeparam = RegRead($sRegKey, 'Parameters')
		GUICtrlSetData($TParam, $exeparam)
	EndIf
	If $parmeter = 1 Then
		Local $executor = GUICtrlRead($TPFilePath)
		If FileExists($executor) Then
			RegWrite($sRegKey, 'File', 'REG_SZ', $executor)
			RegWrite($sRegKey, 'Parameters', 'REG_SZ', GUICtrlRead($TParam))
		EndIf
		If $executor = '' Then
			RegWrite($sRegKey, 'File', 'REG_SZ', '')
			RegWrite($sRegKey, 'Parameters', 'REG_SZ', '')
		EndIf
	EndIf
EndFunc   ;==>TPHokey
Func _LoadradioSet()
	;状态设定
	If GUICtrlRead($aThinkHotkey[1]) = $GUI_CHECKED Then
		GUICtrlSetState($CmbKey, $GUI_DISABLE)
	EndIf
	If GUICtrlRead($aThinkHotkey[2]) = $GUI_CHECKED Then
		GUICtrlSetState($CmbKey, $GUI_ENABLE)
	EndIf
	;加载已经定义热键相关内容
	TPHokey(0)
EndFunc   ;==>_LoadradioSet
Func TpSetKey()
	TPHokey(1)
	MsgBox(0, '提示', '设定对应热键功能完成！', 5)
EndFunc   ;==>TpSetKey
Func TPClearkey()
	GUICtrlSetData($TPFilePath, '')
	GUICtrlSetData($TParam, '')
	TPHokey(1)
	MsgBox(0, '提示', '清除对应热键功能完成！', 5)
EndFunc   ;==>TPClearkey

