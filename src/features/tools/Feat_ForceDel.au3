;==============================================================================
; 模块：文件强制删除
; 说明：无权限文件强制删除工具
; 文件：src\features\tools\Feat_ForceDel.au3
; 函数：共 4 个
;==============================================================================
#include-once

Func ForceDelToolUI()
	Global $ForceDelTool = _GUICreate("文件免权限强制删除工具", 353, 147, 120, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("", 8, 8, 337, 129)
	GUICtrlSetState(-1, $GUI_ACCEPTFILES)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $DelProcess = GUICtrlCreateLabel("拖动您要强制删除的文件或者文件夹到这里来..", 30, 40, 300, 33)
	GUICtrlSetColor(-1, 0x808080)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitForceDelTool')
	GUISetOnEvent($GUI_EVENT_DROPPED, 'ForceDelFiles')
	GUIRegisterMsg($WM_DROPFILES, "WM_DropFiles")
EndFunc   ;==>ForceDelToolUI

Func QuitForceDelTool()
	_WinAPI_AnimateWindow($ForceDelTool, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($ForceDelTool)
	GUIRegisterMsg($WM_DROPFILES, "")
EndFunc   ;==>QuitForceDelTool
Func WM_DropFiles($hWnd, $MsgID, $WParam, $LParam)
	Local $nSize, $pFileName
	Local $nAmt = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", 0xFFFFFFFF, "ptr", 0, "int", 255)
	For $i = 0 To $nAmt[0] - 1
		$nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", $i, "ptr", 0, "int", 0)
		$nSize = $nSize[0] + 1
		$pFileName = DllStructCreate("char[" & $nSize & "]")
		DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", $i, "ptr", DllStructGetPtr($pFileName), "int", $nSize)
		ReDim $gaDropFiles[$i + 1]
		$gaDropFiles[$i] = DllStructGetData($pFileName, 1)
		$pFileName = 0
	Next
EndFunc   ;==>WM_DropFiles
Func ForceDelFiles()
	If @OSArch = 'x86' Then _xdelexe()
	If @OSArch = 'x64' Then _xdel64exe()
	GUICtrlSetData($DelProcess, '正在进行文件强制删除操作,请稍后...')
	For $i = 0 To UBound($gaDropFiles) - 1
		RunWait(@ComSpec & ' /c del/s/f/q "' & $gaDropFiles[$i] & '" |' & @TempDir & '\xdel.exe "' & $gaDropFiles[$i] & '"', @TempDir, @SW_HIDE)
		GUICtrlSetData($DelProcess, '正在删除文件：' & $gaDropFiles[$i] & '..')
	Next
	GUICtrlSetData($DelProcess, '文件删除完成..(*^__^*) 嘻嘻')
	Sleep(500)
	GUICtrlSetData($DelProcess, '拖动您要强制删除的文件或者文件夹到这里来..')
EndFunc   ;==>ForceDelFiles
