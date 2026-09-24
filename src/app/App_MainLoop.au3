;==============================================================================
; 模块：主循环
; 说明：窗口显示、输入框回调注册、定时器、消息循环
; 文件：src\app\App_MainLoop.au3
; 函数：共 0 个
;==============================================================================
#include-once

; 本文件为顶层可执行代码，由入口文件按顺序 #include，请勿调整 include 次序。

;复选框样式
;注册表优化
_WinAPI_AnimateWindow($Form1, $AW_CENTER, 300)
GUISetState(@SW_SHOW)
FileDelete(@TempDir & '\logo.bmp')
Global $hCallback = DllCallbackRegister("My_InputProc", "int", "hWnd;uint;wparam;lparam")
Global $tCallback = DllCallbackGetPtr($hCallback)
Global $CallProc = _WinAPI_SetWindowLong($hInput[0], -4, $tCallback)
;输入框回调函数
For $i = 1 To UBound($hInput) - 1
	_WinAPI_SetWindowLong($hInput[$i], -4, $tCallback)
Next
GUIRegisterMsg(0x0111, "WM_COMMAND")
GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTool')
GUISetOnEvent($GUI_EVENT_DROPPED, '_DropHandler')
GUIRegisterMsg(0x0011, "EndSessionProc")
GUIRegisterMsg(0x0016, "EndSessionProc")
If $UseNetMetr Then
	Global $hUpdate = DllCallbackRegister('_UpdateStats', 'none', '')
	DllCall('user32.dll', 'int', 'SetTimer', 'hwnd', 0, 'int', 0, 'int', 1000, 'ptr', DllCallbackGetPtr($hUpdate))
	Global $aStart_Values = _GetAllTraffic()
EndIf
While 1
	_WinHideMain()
	Sleep(100)
WEnd
