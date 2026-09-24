;==============================================================================
; 模块：缓存清理
; 说明：释放缓存、清理图标缓存
; 文件：src\features\system\cache.au3
; 函数：共 4 个
;==============================================================================
#include-once


Func ReleseCacheUI()
	Global $FormReleaseCache = _GUICreate("释放Windows8.1更新缓存", 380, 89, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $StartReleaseCache = GUICtrlCreateButton("一键释放更新缓存", 8, 56, 363, 25)
	GUICtrlSetOnEvent(-1, 'ReleaseCache')
	GUICtrlSetTip(-1, "该操作不可逆，释放后将无法卸载" & @LF & "安装的Windows更新", '提示', 1, 2)
	$OptResetBase[1] = _GUICtrlCreateCheckbox("重置被取代的基本组件", 16, 24, 305, 17)
	GUICtrlSetTip(-1, "该选项可进一步减小组件存储的大" & @LF & "小，但会消耗更多的时间", '提示', 1, 2)
	GUICtrlCreateGroup("释放选项", 8, 8, 361, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFormReleaseForm')
EndFunc   ;==>ReleseCacheUI
Func QuitFormReleaseForm()
	_WinAPI_AnimateWindow($FormReleaseCache, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormReleaseCache)
EndFunc   ;==>QuitFormReleaseForm
Func ReleaseCache()
	Local $sCMD = ''
	If GUICtrlRead($OptResetBase) = $GUI_CHECKED Then
		$sCMD = 'dism /online /Cleanup-Image /startComponentCleanup '
	Else
		$sCMD = 'dism /online /Cleanup-Image /startComponentCleanup /ResetBase '
	EndIf
	GUICtrlSetState($StartReleaseCache, $GUI_DISABLE)
	GUICtrlSetState($OptResetBase, $GUI_DISABLE)
	GUICtrlSetData($StartReleaseCache, '正在释放更新缓存...')
	$PidCleanCache = Run(@ComSpec & ' /c ' & $sCMD, @WindowsDir, @SW_HIDE)
	TrayTip("提示", "正在释放更新缓存，请稍后..", 10, 1)
	AdlibRegister('_NofierCacheDone')
EndFunc   ;==>ReleaseCache
Func _NofierCacheDone()
	If Not ProcessExists($PidCleanCache) Then
		GUICtrlSetState($StartReleaseCache, $GUI_ENABLE)
		GUICtrlSetState($OptResetBase, $GUI_ENABLE)
		GUICtrlSetData($StartReleaseCache, '一键释放更新缓存')
		AdlibUnRegister('_NofierCacheDone')
		MsgBox(0, '提示', '释放更新缓存操作完成！', 5, $FormReleaseCache)
	EndIf
EndFunc   ;==>_NofierCacheDone
