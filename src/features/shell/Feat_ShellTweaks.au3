;==============================================================================
; 模块：外壳微调
; 说明：Win+X 菜单、新建文件默认名、注册表跳转
; 文件：src\features\shell\Feat_ShellTweaks.au3
; 函数：共 10 个
;==============================================================================
#include-once

Func _FormRegJump()
	Global $FormRegJump = _GUICreate("注册表一键跳转", 506, 80, 35, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("注册表键值", 8, 0, 481, 41)
	Global $RegKeyToJmp = GUICtrlCreateInput("", 16, 16, 465, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKAUTO + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("跳转到注册表项目", 8, 48, 483, 25)
	GUICtrlSetOnEvent(-1, 'JumpToKey')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitRegJump')
EndFunc   ;==>_FormRegJump
Func QuitRegJump()
	_WinAPI_AnimateWindow($FormRegJump, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormRegJump)
EndFunc   ;==>QuitRegJump
Func JumpToKey()
	$Key = GUICtrlRead($RegKeyToJmp)
	If $RegKeyToJmp <> '' Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit', 'LastKey', 'REG_SZ', $Key)
		Run('regedit -m')
	EndIf
EndFunc   ;==>JumpToKey

Func FormWinX()
	Global $Formwinx = GUICreate("Win+X一键设置", 303, 51, 170, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("Win+X默认打开cmdlet", 8, 0, 281, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $CbWinxOpt = GUICtrlCreateCombo("CMD", 16, 16, 145, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "PowerShell")
	GUICtrlCreateButton("设置", 208, 16, 75, 25)
	GUICtrlSetOnEvent(-1, '_SetWinX')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_Quitwinx')

EndFunc   ;==>FormWinX

Func _SetWinX()
	If GUICtrlRead($CbWinxOpt) = "CMD" Then
;~ 		Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontUsePowerShellOnWinX" /t REG_DWORD /d "1" /f
		RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DontUsePowerShellOnWinX', 'REG_DWORD', '1')
	Else
		RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DontUsePowerShellOnWinX', 'REG_DWORD', '0')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '应用选项成功！', 5)
EndFunc   ;==>_SetWinX


Func _Quitwinx()
	_WinAPI_AnimateWindow($Formwinx, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Formwinx)
EndFunc   ;==>_Quitwinx

Func formdefaultFileName()

	Global $FormdefaultFileName = GUICreate("修改新建默认文件名", 298, 51, 170, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("新建默认文件名", 8, 0, 281, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateButton("修改", 216, 16, 67, 25)
	GUICtrlSetOnEvent(-1, '_SetDefaultFileName')
	Global $sdefaultFileName = GUICtrlCreateInput("%s", 24, 16, 153, 21)
	GUICtrlCreateLabel("默认", 184, 24, 28, 17)
	GUICtrlSetOnEvent(-1, '_setsysdafaultFileName')
	GUICtrlSetFont(-1, 4, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x800080)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_Quitwindfn')

EndFunc   ;==>formdefaultFileName
Func _Quitwindfn()
	_WinAPI_AnimateWindow($FormdefaultFileName, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormdefaultFileName)
EndFunc   ;==>_Quitwindfn
Func _setsysdafaultFileName()
	GUICtrlSetData($sdefaultFileName, '%s')
EndFunc   ;==>_setsysdafaultFileName
Func _SetDefaultFileName()
	If GUICtrlRead($sdefaultFileName) <> "" Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates', 'RenameNameTemplate', 'REG_SZ', GUICtrlRead($sdefaultFileName))
		_ForceUpdate()
		MsgBox(0, '提示', '修改新建默认文件名成功！', 5)
	Else
		MsgBox(16, '提示', '默认文件名不能为空！', 5)
	EndIf
EndFunc   ;==>_SetDefaultFileName
