;==============================================================================
; 模块：MAC 修改与绑定
; 说明：网卡 MAC 地址修改、绑定、还原
; 文件：src\features\net\mac_change.au3
; 函数：共 11 个
;==============================================================================
#include-once

Func MacChangeDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $frmMacChanger = _GUICreate("Mac修改及绑定", 334, 114, 138, 120, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $cboAdapters = GUICtrlCreateCombo("", 8, 8, 313, 21, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetTip(-1, '请选择您要修改Mac物理地址的网卡', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiShowMac")
	GUICtrlSetData(-1, $AdapterList[1][0])
	Global $txtMac0 = GUICtrlCreateInput("", 8, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac1 = GUICtrlCreateInput("", 33, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac2 = GUICtrlCreateInput("", 58, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac3 = GUICtrlCreateInput("", 83, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac4 = GUICtrlCreateInput("", 108, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac5 = GUICtrlCreateInput("", 133, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $gphModified = GUICtrlCreateGraphic(158, 42, 17, 17)
	GUICtrlSetBkColor(-1, 0xFF0000)
	$win81dirOp[2] = GUICtrlCreateButton("还原Mac", 195, 38, 60, 25)
	GUICtrlSetTip(-1, '如果您的计算机在修改后存在' & @LF & '不能联网等情况，请点击此按钮！', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiRestoreMac")
	$Change = GUICtrlCreateButton("修改Mac", 260, 38, 60, 25)
	GUICtrlSetTip(-1, '修改完成以后，可能需要重启计算机以使修改生效！', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiChangeMac")
	Global $Bd = GUICtrlCreateButton("解除MAC绑定", 256, 78, 72, 25)
	GUICtrlSetOnEvent(-1, 'MacTIP')
	Global $MacIp = _GUICtrlIpAddress_Create($frmMacChanger, 112, 80, 138, 21)
	$UseBdMac[1] = _GUICtrlCreateCheckbox("启用MAC绑定", 16, 80, 97, 17)
	GUICtrlSetTip($UseBdMac[1], '不勾选，将删除现在选择网卡MAC地址的绑定！', '说明', 1)
	GUICtrlSetOnEvent($UseBdMac[1], 'toogleStatus')
	For $i = 1 To $AdapterList[0][0]
		GUICtrlSetData($cboAdapters, $AdapterList[$i][0])
	Next
	For $i = 0 To 5
		GUICtrlSetOnEvent(Eval('txtMac' & $i), 'GuiCheckHex')
		GUICtrlSetTip(Eval('txtMac' & $i), '按下[CTRL+1]可以一键复制MAC地址', '提示', 1)
	Next
	GUISetOnEvent($GUI_EVENT_CLOSE, "QuitMacChangeDlg")
	GuiShowMac()
	GUISetState(@SW_SHOW)
	If IsHWnd($frmMacChanger) Then
		HotKeySet('^{1}', '_PutMacToClip')
	EndIf
	_GUICtrlIpAddress_Disable($MacIp, 0xf)
EndFunc   ;==>MacChangeDlg

Func QuitMacChangeDlg()
	_WinAPI_AnimateWindow($frmMacChanger, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($frmMacChanger)
	HotKeySet('^{1}')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitMacChangeDlg

;------------------------------------------------------------------------------------------------------------
Func GuiClearMac()
	For $i = 0 To 5
		GUICtrlSetData(Eval('txtMac' & $i), '')
	Next
EndFunc   ;==>GuiClearMac

;------------------------------------------------------------------------------------------------------------
Func GuiCheckHex()
	Local $data = GUICtrlRead(@GUI_CtrlId)
	Dec($data)
	If @error Then
		GUICtrlSetData(@GUI_CtrlId, "")
	Else
		GUICtrlSetData(@GUI_CtrlId, StringUpper($data))
	EndIf
EndFunc   ;==>GuiCheckHex

;------------------------------------------------------------------------------------------------------------
Func GuiRestoreMac()
	GuiClearMac()
	GuiChangeMac()
EndFunc   ;==>GuiRestoreMac

;------------------------------------------------------------------------------------------------------------
Func GuiChangeMac()
	Local $NewMac = GUICtrlRead($txtMac0) & GUICtrlRead($txtMac1) & GUICtrlRead($txtMac2) & GUICtrlRead($txtMac3) & GUICtrlRead($txtMac4) & GUICtrlRead($txtMac5)
	Local $MacLen = StringLen($NewMac)
	If $MacLen = 12 Or $MacLen = 0 Then
		If WriteNewMac($AdapterList, GUICtrlRead($cboAdapters), $NewMac) Then
			$AdapterList = GetAdaptersList()
			GuiShowMac()
			MsgBox(0, '提示', '修改Mac地址成功，可能需要重启才可生效！', 5)
		EndIf
	Else
		MsgBox(16, "错误", "新的MAC地址必须包含12个16进制字符或者设置为空以供删除！", 5)
	EndIf
EndFunc   ;==>GuiChangeMac

;------------------------------------------------------------------------------------------------------------
Func GuiShowMac()
	$Adapter = GUICtrlRead($cboAdapters)
	GUICtrlSetBkColor($gphModified, $GUI_BKCOLOR_TRANSPARENT)
	GuiClearMac()
	If StringLen($Adapter) Then
		Local $i = 0
		For $i = 1 To $AdapterList[0][0]
			If $AdapterList[$i][0] = $Adapter Then
				If $AdapterList[$i][4] = '' Then
					_GUICtrlIpAddress_Set($MacIp, '0.0.0.0')
				Else
					_GUICtrlIpAddress_Set($MacIp, $AdapterList[$i][4])
				EndIf
				GUICtrlSetTip($cboAdapters, '修改连接[' & $AdapterList[$i][5] & ']的MAC地址信息', '说明', 1)
				Local $Mac = $AdapterList[$i][3]
				If StringLen($Mac) = 0 Then
					$Mac = $AdapterList[$i][1]
				Else
					GUICtrlSetBkColor($gphModified, 0xFF0000)
				EndIf
				$Mac = StringReplace($Mac, ":", "")
				GUICtrlSetData($txtMac0, StringMid($Mac, 1, 2))
				GUICtrlSetData($txtMac1, StringMid($Mac, 3, 2))
				GUICtrlSetData($txtMac2, StringMid($Mac, 5, 2))
				GUICtrlSetData($txtMac3, StringMid($Mac, 7, 2))
				GUICtrlSetData($txtMac4, StringMid($Mac, 9, 2))
				GUICtrlSetData($txtMac5, StringMid($Mac, 11, 2))
				ExitLoop
			EndIf
		Next
	EndIf
EndFunc   ;==>GuiShowMac

;------------------------------------------------------------------------------------------------------------
Func WriteNewMac($AdapterList, $AdapterName, $NewMac = "")
	If UBound($AdapterList) Then
		Local $i
		Local $AdapterKey = ""
		For $i = 1 To $AdapterList[0][0]
			If $AdapterList[$i][0] = $AdapterName Then
				$AdapterKey = $AdapterList[$i][2]
			EndIf
		Next
		If StringLen($AdapterKey) Then
			If StringLen($NewMac) Then
				RegWrite($AdapterKey, "networkaddress", "REG_SZ", $NewMac)
			Else
				RegDelete($AdapterKey, "networkaddress")
			EndIf
			_ForceUpdate()
			Return 1
		EndIf
	EndIf
	Return 0
EndFunc   ;==>WriteNewMac
Func _PutMacToClip()
	Local $MacStr = ''
	For $i = 0 To 5
		$MacStr &= GUICtrlRead(Eval('txtMac' & $i)) & ':'
	Next
	ClipPut(StringTrimRight($MacStr, 1))
	TrayTip('提示', 'MAC地址已经复制到剪切板上！', 3)
EndFunc   ;==>_PutMacToClip
Func MacTIp()
	If GUICtrlRead($UseBdMac[1]) = $GUI_CHECKED Then
		If Not _GUICtrlIpAddress_IsBlank($MacIp) Then
			$macadress = ''
			For $i = 0 To 5
				If $i <> 5 Then
					$macadress &= GUICtrlRead(Eval('txtMac' & $i)) & '-'
				Else
					$macadress &= GUICtrlRead(Eval('txtMac' & $i))
				EndIf
			Next
			ProcessWaitClose(Run(@ComSpec & ' /c arp -s ' & _GUICtrlIpAddress_Get($MacIp) & ' ' & $macadress, '', @SW_HIDE))
			MsgBox(0, '', 'MAC地址绑定操作执行完成！', 5)
		Else
			MsgBox(0, '', '请手工填写网卡的MAC地址后再行尝试！')
		EndIf
	Else
		If Not _GUICtrlIpAddress_IsBlank($MacIp) Then
			ProcessWaitClose(Run(@ComSpec & ' /c arp -d ' & _GUICtrlIpAddress_Get($MacIp), '', @SW_HIDE))
			MsgBox(0, '', 'MAC地址解除绑定操作执行完成！', 5)
		Else
			MsgBox(0, '', '请手工填写网卡的MAC地址后再行尝试！')
		EndIf
	EndIf
EndFunc   ;==>MacTIp
;设置控件状态
Func toogleStatus()
	If GUICtrlRead($UseBdMac[1]) = $GUI_CHECKED Then
		GUICtrlSetData($Bd, '进行MAC绑定')
		_GUICtrlIpAddress_Disable($MacIp)
	Else
		GUICtrlSetData($Bd, '解除MAC绑定')
		_GUICtrlIpAddress_Disable($MacIp, 0xf)
	EndIf
EndFunc   ;==>toogleStatus
