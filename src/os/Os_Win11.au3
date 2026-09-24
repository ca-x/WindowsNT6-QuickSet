;==============================================================================
; 模块：Windows 11
; 说明：适用于 @OSBuild > 19040 / 21900 / 21990 的分支实现
; 文件：src\os\Os_Win11.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsWin11_AddRegTweaks_03
; 适用条件：@OSBuild > 19040
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin11_AddRegTweaks_03()
	;恢复经典系统属性界面
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\0\2093230218', 'EnabledState', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin11_AddRegTweaks_03

;-------------------------------------------------------------------------------
; _OsWin11_AddRegTweaks_19
; 适用条件：@OSBuild > 21900
; 来源：AddRegTweaks / 12	任务栏使用小图标
;-------------------------------------------------------------------------------
Func _OsWin11_AddRegTweaks_19()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '0')
EndFunc   ;==>_OsWin11_AddRegTweaks_19

;-------------------------------------------------------------------------------
; _OsWin11_AddRegTweaks_22
; 适用条件：@OSBuild > 21990
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin11_AddRegTweaks_22()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig', 'BypassTPMCheck', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig', 'BypassSecureBootCheck', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin11_AddRegTweaks_22

;-------------------------------------------------------------------------------
; _OsWin11_AddRegTweaks_55
; 适用条件：@OSBuild > 21900
; 来源：AddRegTweaks / 20IE综合优化选项
;-------------------------------------------------------------------------------
Func _OsWin11_AddRegTweaks_55()
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_ShowClassicMode", "REG_DWORD", "00000001")
EndFunc   ;==>_OsWin11_AddRegTweaks_55
