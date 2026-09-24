;==============================================================================
; 模块：Windows XP / 2003
; 说明：适用于 @OSBuild < 6000 或 @OSVersion = WIN_XP / WIN_2003 的分支实现
; 文件：src\os\Os_Xp.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_01
; 适用条件：@OSBuild < 6000
; 来源：AddRegTweaks / 1右键添加管理员取得所有权
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_01()
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ScreenSaverIsSecure', 'REG_DWORD', ($ScreenSaverIsSecure = 0) ? ("1") : ("0"))
	GUICtrlSetData($Checkbox[1], ($ScreenSaverIsSecure = 0) ? ("从屏保恢复时不显示登录屏幕") : ("从屏保恢复时显示登录屏幕"))
EndFunc   ;==>_OsXp_AddRegTweaks_01

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_05
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 2右键添加CAB相关命令
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_05()
	RegWrite('HKEY_CLASSES_ROOT\*\shell\CAB最大压缩\command', '', 'REG_SZ', 'makecab /v3 /D CompressionType=LZX /D CompressionMemory=21 \"%1\"')
	RegWrite('HKEY_CLASSES_ROOT\*\shell\解压缩 CAB 文件\command', '', 'REG_SZ', 'expand -r \"%1\"')
EndFunc   ;==>_OsXp_AddRegTweaks_05

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_09
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_09()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\cdrom', 'Autorun', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\cdrom', 'Autorun', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\USBSTOR', 'Autorun', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\USBSTOR', 'Autorun', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsXp_AddRegTweaks_09

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_12
; 适用条件：@OSVersion = 'WIN_XP'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_12()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\WPA\PosReady', 'Installed', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsXp_AddRegTweaks_12

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_14
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 6资源管理器启用复选框
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_14()
	If @OSVersion = 'WIN_XP' Then
		_OsXp_AddRegTweaks_12()
	Else
		_OsCommon_AddRegTweaks_13()
	EndIf
EndFunc   ;==>_OsXp_AddRegTweaks_14

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_16
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 7禁用UAC
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_16()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg', 'RemoteRegAccess', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsXp_AddRegTweaks_16

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_17
; 适用条件：@OSBuild < 6000
; 来源：AddRegTweaks / 11移除快捷方式字样和图标
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_17()
	RegDelete('HKEY_CLASSES_ROOT\lnkfile', 'IsShortcut')
EndFunc   ;==>_OsXp_AddRegTweaks_17

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_21
; 适用条件：@OSBuild < 6000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_21()
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultValue", "REG_DWORD", "00000001")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultByFontTest", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultApplied", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultValue", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothingOrientation", "REG_DWORD", "00000001")
	RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "FontSmoothing", "REG_SZ", "2")
	RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "FontSmoothingType", "REG_DWORD", "00000002")
	RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "ForegroundFlashCount", "REG_DWORD", "00000003")
	RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "ForegroundLockTimeout", "REG_DWORD", "00000000")
	RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "SmoothScroll", "REG_DWORD", "00000000")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultValue", "REG_DWORD", "00000000")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultByAlphaTest", "REG_DWORD", "00000000")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultApplied", "REG_DWORD", "00000000")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultValue", "REG_DWORD", "00000000")
	;不缓存缩略图
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DisableThumbnailCache', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsXp_AddRegTweaks_21

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_27
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 14打开所在目录
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_27()
	Local $strVbs = 'set args = WScript.Arguments' & @CRLF & _
			'linkname = args(0)' & @CRLF & _
			'set wshshell = CreateObject("WScript.Shell")' & @CRLF & _
			'set scut = wshshell.CreateShortcut(linkname)' & @CRLF & _
			'set fs = CreateObject("Scripting.FileSystemObject")' & @CRLF & _
			'folder = """" & fs.GetParentFolderName(scut.TargetPath) & """"' & @CRLF & _
			'wshshell.Run(folder)'
	Local $Fh = FileOpen(@WindowsDir & '\system32\OpenShortcutDir.vbs', 2 + 8)
	FileWrite($Fh, $strVbs)
	FileClose($Fh)
	RegWrite('HKEY_CLASSES_ROOT\lnkfile\shell\打开所在目录\command', '', 'REG_SZ', 'WScript.exe //nologo ' & @WindowsDir & '\system32\OpenShortcutDir.vbs "%L"')
EndFunc   ;==>_OsXp_AddRegTweaks_27

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_31
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 15隐藏操作中心图标
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_31()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Security Center', 'AntiVirusOverride', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsXp_AddRegTweaks_31

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_37
; 适用条件：@OSBuild < 8000 And @OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_37()
	;winxp及2003的优化
	;禁用搜索助手并使用高级搜索
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'Actor', 'REG_SZ', '')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'SocialUI', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'UsageCount', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'UseAdvancedSearchAlways', 'REG_DWORD', '00000001')
	;禁止启动时候弹出错误信息
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Windows', 'NoPopUpsOnBoot', 'REG_SZ', '1')
	;加快局域网显示速度
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{D6277990-4C6A-11CF-8D87-00AA0060F5BF}')
	;在所有资源管理器窗口显示状态栏
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main', 'StatusBarOther', 'REG_DWORD', '00000001')
	;—>  启动系统时为桌面和资源管理器创建独立的进程(其中一个崩溃也不影响另一个)
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'SeparateProcess', 'REG_DWORD', '00000001')
	;为每种文件夹类型使用一种背景图片
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultApplied', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultValue', 'REG_DWORD', '00000001')
	;显示半透明的选择长方形
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultByAlphaTest', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultApplied', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ListviewAlphaSelect', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultValue', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultApplied', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultValue', 'REG_DWORD', '00000000')
	;在菜单下显示阴影 - 关闭
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultValue', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultApplied', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultValue', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultValue', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultApplied', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultValue', 'REG_DWORD', '00000000')
	;;在鼠标指针下显示阴影
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow', 'DefaultApplied', 'REG_DWORD', '00000001')
	;在桌面上为图标标签使用阴影
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultByAlphaTest', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultApplied', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ListviewShadow', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax', 'DefaultValue', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax', 'DefaultApplied', 'REG_DWORD', '00000000')
	;拖拉时显示窗体内容
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows', 'DefaultValue', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows', 'DefaultApplied', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'DragFullWindows', 'REG_SZ', '1')
	;;关闭窗口的动画效果
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics', 'MinAnimate', 'REG_SZ', '0')
	;桌面图标 - 标题换行
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics', 'IconTitleWrap', 'REG_SZ', '1')
	;安装驱动时不搜索 Windows Update
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\DriverSearching', 'DontSearchWindowsUpdate', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\DriverSearching', 'DontPromptForWindowsUpdate', 'REG_DWORD', '00000001')
	; ;禁止系统通过全面搜索目标驱动器来解析快捷方式
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoResolveSearch', 'REG_DWORD', '00000001')
	;启动 XP 的路由功能和 IP 的过滤功能
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'IPEnableRouter', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'EnableSecurityFilters', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control', 'WaitToKillAppTimeout', 'REG_SZ', '2000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'MasterDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'SlaveDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'MasterDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'SlaveDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Security Center', 'AntiVirusOverride', 'REG_DWORD', '00000001')
	;关闭桌面清理向导
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\CleanupWiz', 'NoRun', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Messenger', 'Start', 'REG_DWORD', '00000004')
	;加速打开资源管理器
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'ConfigFileAllocSize', 'REG_DWORD', '000001f4')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisableLastAccessUpdate', 'REG_DWORD', '00000000')
	;;不自动搜索网络文件夹和打印机
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'NoNetCrawling', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoRemoteRecursiveEvents', 'REG_DWORD', '00000001')
	;禁止 Windows 漫游气球提醒
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Tour', 'RunCount', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Applets\Tour', 'RunCount', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'CPUPriority', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'PCIConcur', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'FastDRAM', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'AGPConcur', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000001')
	;加快菜单显示速度
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Re moteComputer\NameSpace\{2227A280-3AEA-1069-A2DE-08002B30309D}', '', 'REG_SZ', 'Printers')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\Security', 'BlockXBM', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\stisvc', 'Start', 'REG_DWORD', '00000002')
	;语言栏隐藏到任务栏并隐藏语言栏上的帮助按钮
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\MSUTB', 'ShowDeskBand', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar', 'ShowStatus', 'REG_DWORD', '00000004')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar', 'ExtraIconsOnMinimized', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar\ItemState\{ED9D5450-EBE6-4255-8289-F8A31E687228}', 'DemoteLevel', 'REG_DWORD', '00000003')
	;在任务栏显示音量图标
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\SysTray', 'Services', 'REG_DWORD', '0000001f')
	;平滑屏幕字体边缘

	;关机理由啥的
	If @OSVersion = 'WIN_2003' Then
		_OsServer_AddRegTweaks_36()
	EndIf
EndFunc   ;==>_OsXp_AddRegTweaks_37

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_43
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_43()
	RegWrite('KEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
EndFunc   ;==>_OsXp_AddRegTweaks_43

;-------------------------------------------------------------------------------
; _OsXp_AddRegTweaks_58
; 适用条件：@OSBuild > 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 21关闭系统开机声音#关闭分组相似任务栏按钮
;-------------------------------------------------------------------------------
Func _OsXp_AddRegTweaks_58()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000000')
EndFunc   ;==>_OsXp_AddRegTweaks_58

;-------------------------------------------------------------------------------
; _OsXp_pluginsTweaks_03
; 适用条件：@OSBuild < 6000
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsXp_pluginsTweaks_03()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 开始破解系统连接数..'
	FileInstall('.\src\file\tcpPatch.exe', @TempDir & '\', 1)
	FileChangeDir(@TempDir)
	Run("tcpPatch.exe")
	WinWaitActive("比特精灵提供", "操作系统")
	ControlSetText("比特精灵提供", "操作系统", "Edit2", "2000")
	Send("!a")
	If WinExists("比特精灵", "您希望现在就重启") Then
		Send("!n")
	EndIf
	WinWaitActive("比特精灵提供", "成功的应用了补丁")
	WinClose("比特精灵提供", "成功的应用了补丁")
	If WinExists("比特精灵", "您希望现在就重启") Then
		Send("!n")
	EndIf
	Run(@ComSpec & ' /c tsakkill /im "tcpPatch.exe" /f', @WindowsDir, @SW_HIDE)
	FileDelete(@TempDir & '\tcpPatch.exe')
EndFunc   ;==>_OsXp_pluginsTweaks_03

;-------------------------------------------------------------------------------
; _OsXp_pluginsTweaks_08
; 适用条件：@OSVersion = 'WIN_XP'
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsXp_pluginsTweaks_08()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装WindowsXP内存4GB限制破解补丁..'
	FileInstall('.\src\file\XP64G.exe', @TempDir & '\', 1)
	Run(@TempDir & '\XP64G.exe')
	WinActivate('[CLASS:#32770]')
	WinWaitActive('[CLASS:#32770]')
	ControlClick('XP64G 2.0（修正USB蓝屏问题）', '', "[CLASS:Button; INSTANCE:1]")
	Sleep(2500)
	If ProcessExists('XP64G.exe') Then Run(@ComSpec & ' /c taskkill /im XP64G.exe /f', @WindowsDir, @SW_HIDE)
	FileDelete(@TempDir & '\XP64G.exe')
EndFunc   ;==>_OsXp_pluginsTweaks_08

;-------------------------------------------------------------------------------
; _OsXp_pluginsTweaks_13
; 适用条件：@OSBuild < 6000
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsXp_pluginsTweaks_13()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装豆沙绿护眼配色方案..'
	$percent += $percent
	RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors', 'Background', 'REG_SZ', '204 232 207')
	RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors', 'Window', 'REG_SZ', '204 232 207')
	RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings', 'Always Use My Colors ', 'REG_DWORD', '00000000')
	RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings', 'Background Color', 'REG_SZ', '204 232 207')
	RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings\Software\Microsoft\Internet Explorer\Main', 'Use_DlgBox_Colors', 'REG_SZ', 'yes')
EndFunc   ;==>_OsXp_pluginsTweaks_13

;-------------------------------------------------------------------------------
; _OsXp_pluginsTweaks_17
; 适用条件：@OSBuild < 6000
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsXp_pluginsTweaks_17()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装关闭光驱插件..'
	FileInstall('.\src\file\srcd.dll', @WindowsDir & '\System32\', 1)
	Run(@ComSpec & ' /c Regsvr32 /s %windir%\System32\srcd.dll', @WindowsDir & '\System32', @SW_HIDE)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Wenson CDROM Eject', '', 'REG_SZ', '{F0479943-AA1D-49DD-86F4-6035E068260C}')
EndFunc   ;==>_OsXp_pluginsTweaks_17
