;==============================================================================
; 模块：版本记录与检查更新
; 说明：版本更新记录、在线检查新版本
; 文件：src\features\tools\history.au3
; 函数：共 3 个
;==============================================================================
#include-once

;=========================================================================================
; 关于程序
;=========================================================================================
Func _History()
	If Not FileExists(@TempDir & '\更新记录.txt') Then FileInstall('readMe.txt', @TempDir & '\更新记录.txt', 1)
	Local $Fh = FileOpen(@TempDir & '\更新记录.txt')
	Local $data = FileRead($Fh)
	FileClose($Fh)
	FileDelete(@TempDir & '\更新记录.txt')
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $FormHistory = _GUICreate("程序版本更新记录", 437, 400, 86, -20, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_POPUP), BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateLabel('Windows NT6+快速设置工具版本更新记录', 3, 1, 400, 20, $SS_CENTER)
	GUICtrlSetFont(-1, 12, 800, 0, "微软雅黑")
	GUICtrlSetColor(-1, 0x3399FF)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	_ScrollingCredits($data, 3, 25, 431, 350, 5, '更多信息请访问' & $UerHome, '黑体')
	GUICtrlCreateButton("我已阅读，谢谢！", 8, 380, 419, 20)
	GUICtrlSetOnEvent(-1, 'QuitHisForm')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitHisForm')
EndFunc   ;==>_History

Func QuitHisForm()
	_WinAPI_AnimateWindow($FormHistory, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormHistory)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitHisForm
Func CheckUpdate()
	Local $version = ""
	Local $b = InetRead("https://api.github.com/repos/czyt/WindowsNT6-QuickSet/releases/latest", 3)
	Local $payload = BinaryToString($b, 4)
	Local $aVersion = StringRegExp($payload, '"tag_name":"v([^"]+)"', 1)
	Local $downloadUrl = StringRegExp($payload, '"browser_download_url":"([^"]+)"', 1)
	If UBound($aVersion) > 0 Then
		$version = $aVersion[0]
	EndIf
	If $version = $EXEVerson Then
		MsgBox(0, '提示', '当前版本已经是最新！' & @LF & "官网:" & $version & "<->当前:" & $EXEVerson, 5)
	ElseIf $version = "" Then
		If MsgBox(4, '提示', '获取版本信息失败,是否立即前往官网？', 5) = 6 Then
			ShellExecute("https://github.com/czyt/WindowsNT6-QuickSet")
		EndIf
	ElseIf $version > $EXEVerson Then
		If UBound($downloadUrl) > 0 Then
			If MsgBox(4, '提示', '发现官网新版本' & $version & ',是否下载到桌面？', 5) = 6 Then
				Local $hDownload = InetGet("http://fastgit.czyt.tech/" & $downloadUrl[0], @DesktopDir & "\WindowsNT6+快速设置工具" & $version & ".7z", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
				Do
					Sleep(250)
				Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
				InetClose($hDownload)
				MsgBox(0, '提示', "最新版的程序已经放在您的桌面，请查收！")
			EndIf
		Else
			If MsgBox(4, '提示', '发现官网新版本' & $version & ',是否立即前往官网？', 5) = 6 Then
				ShellExecute("https://github.com/czyt/WindowsNT6-QuickSet")
			EndIf
		EndIf
	Else
		MsgBox(0, '提示', '您属于高级VIP用户，正在使用内部版本，请勿对外传播当前版本！！' & @LF & "官网:" & $version & "<->当前:" & $EXEVerson, 5)
	EndIf
EndFunc   ;==>CheckUpdate
