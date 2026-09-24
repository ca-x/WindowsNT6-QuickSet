;==============================================================================
; 模块：SYSTEM 权限运行
; 说明：以 SYSTEM 身份运行命令/程序
; 文件：src\features\account\sys_run.au3
; 函数：共 4 个
;==============================================================================
#include-once

Func GuiSYSCMD()
	Global $FormSysRun = _GUICreate("SYSTEM用户执行操作模拟", 448, 80, 85, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $HCommand = GUICtrlCreateInput("", 12, 16, 369, 21)
	GUICtrlSetState(-1, 8)
	GUICtrlCreateGroup("输入要执行的程序或系统命令", 8, 0, 433, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("...", 392, 16, 43, 21)
	GUICtrlSetOnEvent(-1, '_LocateFile')
	GUICtrlCreateButton("以SYSTEM用户身份执行[&R]", 8, 48, 433, 25)
	GUICtrlSetOnEvent(-1, '_RunCommandOrExe')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFormSysRun')
EndFunc   ;==>GuiSYSCMD
Func QuitFormSysRun()
	_WinAPI_AnimateWindow($FormSysRun, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormSysRun)
EndFunc   ;==>QuitFormSysRun

Func _LocateFile()
	Local $CommandExe = FileOpenDialog('选择要以SYSTEM用户执行的可执行程序', '', '可执行程序(*.exe;*.msi)', 1)
	If $CommandExe <> '' Then
		GUICtrlSetData($HCommand, $CommandExe)
	EndIf
EndFunc   ;==>_LocateFile

Func _RunCommandOrExe()
	Local $CommandToRun = GUICtrlRead($HCommand)
	If $CommandToRun <> '' Then
		If @OSBuild < 8000 Then
			Local $tProcessInfo = _SeCreateSystemProcess($CommandToRun, @WorkingDir)
			Local $iError = @error
			Local $iExtended = @extended
			If IsDllStruct($tProcessInfo) Then
				TrayTip('提示', '已经成功模拟SYSTEM用户执行操作~', 3, 1)
				Local $hProcess = DllStructGetData($tProcessInfo, "hProcess") ; 进程句柄。
				Local $hThread = DllStructGetData($tProcessInfo, "hThread") ; 主线程句柄。
				Local $iProcessID = DllStructGetData($tProcessInfo, "ProcessID") ; 进程ID。
				Local $iThreadID = DllStructGetData($tProcessInfo, "ThreadID") ; 主线程ID。
				DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
				DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hThread)
			Else
				TrayTip('提示', '模拟SYSTEM用户执行操作失败~' & @LF & StringFormat("error=%d, extended=%d\n", $iError, $iExtended), 3, 3)
			EndIf
		Else
			RunAsSYSTEMWindows81($CommandToRun)
			If Not @error Then
				TrayTip('提示', '已经成功模拟SYSTEM用户执行操作~', 3, 1)
			Else
				TrayTip('提示', '模拟SYSTEM用户执行操作失败~', 3, 3)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_RunCommandOrExe
