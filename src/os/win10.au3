;==============================================================================
; 模块：Windows 10
; 说明：适用于 @OSBuild > 9000，或 @OSVersion = WIN_10 的分支实现
; 文件：src\os\win10.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsWin10_AddRegTweaks_06
; 适用条件：@OSBuild > 19040（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin10_AddRegTweaks_06()
	;2右键添加CAB相关命令
	If @OSBuild > 6000 Then
		_OsCommon_AddRegTweaks_04()
	Else
		_OsXp_AddRegTweaks_05()
	EndIf
EndFunc   ;==>_OsWin10_AddRegTweaks_06

;-------------------------------------------------------------------------------
; _OsWin10_AddRegTweaks_28
; 适用条件：@OSBuild > 9000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin10_AddRegTweaks_28()
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer', 'DisableNotificationCenter', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin10_AddRegTweaks_28

;-------------------------------------------------------------------------------
; _OsWin10_AddRegTweaks_38
; 适用条件：@OSBuild > 9000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin10_AddRegTweaks_38()
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'LaunchTo', 'REG_DWORD', '00000002')
EndFunc   ;==>_OsWin10_AddRegTweaks_38

;-------------------------------------------------------------------------------
; _OsWin10_AddRegTweaks_48
; 适用条件：@OSBuild > 9000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin10_AddRegTweaks_48()
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowFrequent', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowRecent', 'REG_DWORD', '00000000')
EndFunc   ;==>_OsWin10_AddRegTweaks_48

;-------------------------------------------------------------------------------
; _OsWin10_pluginsTweaks_06
; 适用条件：@OSBuild < 10240（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsWin10_pluginsTweaks_06()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装屏保扩展包..'
	_Fliqlo(True, @WindowsDir)
	_Aerial(True, @WindowsDir)
	_ScreenSaverSet(@WindowsDir & '\Fliqlo.scr', True)
EndFunc   ;==>_OsWin10_pluginsTweaks_06
