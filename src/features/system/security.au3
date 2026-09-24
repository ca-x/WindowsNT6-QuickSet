;==============================================================================
; 模块：系统安全设置
; 说明：Windows 安全选项一键设置与还原
; 文件：src\features\system\security.au3
; 函数：共 9 个
;==============================================================================
#include-once

Func SystemSecuritySet()
	Global $SecuritySetForm = _GUICreate("Windows安全选项设置", 429, 90, 100, 105, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	$SecuritySet[1] = _GUICtrlCreateCheckbox("禁止导入注册表文件", 8, 8, 145, 17)
	$MSecurity1 = GUICtrlCreateContextMenu($SecuritySet[1])
	GUICtrlCreateMenuItem('允许导入注册表文件', $MSecurity1)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet1')
	$SecuritySet[2] = _GUICtrlCreateCheckbox("禁用控制面板", 8, 32, 97, 17)
	$MSecurity2 = GUICtrlCreateContextMenu($SecuritySet[2])
	GUICtrlCreateMenuItem('启用控制面板', $MSecurity2)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet2')
	$SecuritySet[3] = _GUICtrlCreateCheckbox("禁用文件夹选项菜单", 8, 56, 137, 17)
	$MSecurity3 = GUICtrlCreateContextMenu($SecuritySet[3])
	GUICtrlCreateMenuItem('启用文件夹选项菜单', $MSecurity3)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet3')
	$SecuritySet[4] = _GUICtrlCreateCheckbox("禁用注册表编辑器", 160, 8, 121, 17)
	$MSecurity4 = GUICtrlCreateContextMenu($SecuritySet[4])
	GUICtrlCreateMenuItem('启用注册表编辑器', $MSecurity4)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet4')
	$SecuritySet[5] = _GUICtrlCreateCheckbox("禁用任务管理器", 160, 32, 113, 17)
	$MSecurity5 = GUICtrlCreateContextMenu($SecuritySet[5])
	GUICtrlCreateMenuItem('启用任务管理器', $MSecurity5)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet5')
	$SecuritySet[6] = _GUICtrlCreateCheckbox("禁用命令提示符", 160, 56, 113, 17)
	$MSecurity6 = GUICtrlCreateContextMenu($SecuritySet[6])
	GUICtrlCreateMenuItem('启用命令提示符', $MSecurity6)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet6')
	GUICtrlCreateGroup("便捷选择", 288, 8, 129, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$SecurityAllselectAll = _GUICtrlCreateRadio("全选", 296, 24, 49, 17)
	GUICtrlSetOnEvent($SecurityAllselectAll, 'SecurityCheckAll')
	$SecurityReverseselect = _GUICtrlCreateRadio("反选", 352, 24, 57, 17)
	GUICtrlSetOnEvent($SecurityReverseselect, 'SecurityReverse')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("应用设置[&A]", 288, 58, 131, 25)
	GUICtrlSetOnEvent(-1, 'ApplySecuritySet')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitSecurityForm')
EndFunc   ;==>SystemSecuritySet

Func QuitSecurityForm()
	_WinAPI_AnimateWindow($SecuritySetForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($SecuritySetForm)
EndFunc   ;==>QuitSecurityForm
Func ApplySecuritySet()
	Local $n = 0
	For $i = 1 To UBound($SecuritySet) - 1
		If GUICtrlRead($SecuritySet[$i]) = $GUI_CHECKED Then
			$n += 1
		EndIf
	Next
	If $n > 0 Then
		If MsgBox(4, '提示', '是否应用当前勾选的' & $n & '个安全设置项？', 5) = 6 Then
			If GUICtrlRead($SecuritySet[1]) = $GUI_CHECKED Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\.reg', '', 'REG_SZ', 'txtfile')
			EndIf
			If GUICtrlRead($SecuritySet[2]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoControlPanel', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[3]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoFolderOptions', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[4]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableRegistryTools', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[5]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableTaskMgr', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[6]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows\System', 'DisableCMD', 'REG_DWORD', '00000002')
			EndIf
			_ForceUpdate()
			MsgBox(0, '提示', '已经将所选' & $n & '个安全选项应用到当前系统！', 5)
		EndIf
	Else
		MsgBox(16, '提示', '请勾选要进行设置的项目！！', 5)
	EndIf
EndFunc   ;==>ApplySecuritySet

Func RemoveSecuritySet1()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\.reg', '', 'REG_SZ', 'regfile')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用系统注册表文件导入功能！', 5)
EndFunc   ;==>RemoveSecuritySet1
Func RemoveSecuritySet2()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoControlPanel')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用系统控制面板！', 5)
EndFunc   ;==>RemoveSecuritySet2
Func RemoveSecuritySet3()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoFolderOptions')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用文件夹选项菜单！', 5)
EndFunc   ;==>RemoveSecuritySet3
Func RemoveSecuritySet4()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableRegistryTools')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用注册表编辑器！', 5)
EndFunc   ;==>RemoveSecuritySet4
Func RemoveSecuritySet5()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableTaskMgr')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用任务管理器！', 5)
EndFunc   ;==>RemoveSecuritySet5
Func RemoveSecuritySet6()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows\System', 'DisableCMD')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用命令提示符！', 5)
EndFunc   ;==>RemoveSecuritySet6
