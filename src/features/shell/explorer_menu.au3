;==============================================================================
; 模块：资源管理器右键菜单
; 说明：Win11 新旧右键菜单切换、小盾牌、Defender 右键项、重启资源管理器
; 文件：src\features\shell\explorer_menu.au3
; 函数：共 9 个
;==============================================================================
#include-once


Func Win11RightMenuToogleUI()
	Global $Win11RightMenuForm = _GUICreate("Windows 11 右键菜单风格切换", 270, 50, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("windows11新版风格", 24, 5, 113, 33)
	GUICtrlSetOnEvent(-1, 'windows11StyleRightMenu')
	GUICtrlCreateButton("windows旧版风格", 140, 5, 97, 33)
	GUICtrlSetOnEvent(-1, 'windowsOldStyleRightMenu')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWin11RightMenuForm')
EndFunc   ;==>Win11RightMenuToogleUI

Func windows11StyleRightMenu()
	RegDelete('HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}')
	_ForceUpdate()
	RestartExplorer()
	MsgBox(0, '提示', '设置右键菜单为windows11新版风格成功！', 5, $Win11RightMenuForm)
EndFunc   ;==>windows11StyleRightMenu
Func windowsOldStyleRightMenu()
	RegWrite('HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32', '', "REG_SZ", "")
	_ForceUpdate()
	RestartExplorer()
	MsgBox(0, '提示', '设置右键菜单为windows旧版本风格成功！', 5, $Win11RightMenuForm)
EndFunc   ;==>windowsOldStyleRightMenu

Func RestartExplorer()
	Local $ifailure = 100, $zfailure = 100, $rPID = 0, $iExplorerPath = @WindowsDir & "\Explorer.exe"
	_WinAPI_ShellChangeNotify($shcne_AssocChanged, 0, 0, 0) ; Save icon positions
	Local $hSystray = _WinAPI_FindWindow("Shell_TrayWnd", "")
	_SendMessage($hSystray, 1460, 0, 0) ; Close the Explorer shell gracefully
	While ProcessExists("Explorer.exe") ; Try Close the Explorer
		Sleep(10)
		$ifailure -= ProcessClose("Explorer.exe") ? 0 : 1
		If $ifailure < 1 Then Return SetError(1, 0, 0)
	WEnd
	While (Not ProcessExists("Explorer.exe")) ; Start the Explorer
		If Not FileExists($iExplorerPath) Then Return SetError(-1, 0, 0)
		Sleep(500)
		$rPID = ShellExecute($iExplorerPath)
		$zfailure -= $rPID ? 0 : 1
		If $zfailure < 1 Then Return SetError(2, 0, 0)
	WEnd
	Return $rPID
EndFunc   ;==>RestartExplorer

Func QuitWin11RightMenuForm()
	_WinAPI_AnimateWindow($Win11RightMenuForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Win11RightMenuForm)
EndFunc   ;==>QuitWin11RightMenuForm

Func RemoveDP()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '77', 'REG_SZ', '%systemroot%\system32\imageres.dll,197')
	FileSetAttrib(@LocalAppDataDir & '\Local\iconcache.db', '-SRH')
	If ProcessExists("explorer.exe") Then ProcessClose('explorer.exe')
	FileDelete(@LocalAppDataDir & '\Local\iconcache.db')
	If Not ProcessExists("explorer.exe") Then Run(@WindowsDir & '\explorer.exe')
	_ForceUpdate()
	MsgBox(0, '提示', '已经移除小盾牌图标！', 5)
EndFunc   ;==>RemoveDP
Func RestoreDP()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '77')
	FileSetAttrib(@LocalAppDataDir & '\Local\iconcache.db', '-SRH')
	If ProcessExists("explorer.exe") Then ProcessClose('explorer.exe')
	FileDelete(@LocalAppDataDir & '\Local\iconcache.db')
	If Not ProcessExists("explorer.exe") Then Run(@WindowsDir & '\explorer.exe')
	_ForceUpdate()
	MsgBox(0, '提示', '已经还原小盾牌图标！', 5)
EndFunc   ;==>RestoreDP
Func RemoveWD()
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	_ForceUpdate()
	MsgBox(0, '提示', '移除Windows Defender右键菜单成功！', 5)
EndFunc   ;==>RemoveWD
Func RestoreWD()
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0', '', 'REG_SZ', 'Morro Shell Extension 1.0 Type Library')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0\win32', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender\shellext.dll')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\FLAGS', '', 'REG_SZ', '0')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\HELPDIR', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender\shellext.dll')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32', 'ThreadingModel', 'REG_SZ', 'Apartment')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\Version', '', 'REG_SZ', '4.0.0106.0')
	_ForceUpdate()
	MsgBox(0, '提示', '恢复Windows Defender右键菜单成功！', 5)
EndFunc   ;==>RestoreWD
