;==============================================================================
; 模块：Vista / Win7 / 2008R2
; 说明：适用于 6000 < @OSBuild <= 8000 的分支实现
; 文件：src\os\vista7.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsVista7_AddRegTweaks_25
; 适用条件：@OSBuild > 8000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsVista7_AddRegTweaks_25()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWAR\Classes\Directory\Background\shellex\ContextMenuHandlers\Flip3D', '', 'REG_SZ', '{3080F90E-D7AD-11D9-BD98-0000947B0257}')
EndFunc   ;==>_OsVista7_AddRegTweaks_25

;-------------------------------------------------------------------------------
; _OsVista7_AddRegTweaks_35
; 适用条件：@OSBuild < 8000 And @OSBuild > 6000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsVista7_AddRegTweaks_35()
	;离开模式
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Power', 'AwayModeEnabled', 'REG_DWORD', '00000001')
	;禁用打开方式的浏览网页程序
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'NoInternetOpenWith', 'REG_DWORD', '00000001')
	;加快运行速度
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '10')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\CLSID\{00021400-0000-0000-C000-000000000046}', 'MenuShowDelay', 'REG_SZ', '10')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoRestartShell', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\WSearch', 'Start', 'REG_DWORD', '00000004')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\WSearch', 'Start', 'REG_DWORD', '00000004')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\CrashControl', 'AutoReboot', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\CrashControl', 'AutoReboot', 'REG_DWORD', '00000000')
	RegWrite('HKEY_CURRENT_USER\Control Panel\DeskDesktop', 'AutoEndTasks', 'REG_SZ', '1')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'ConfigFileAllocSize', 'REG_DWORD', '000001f4')
	;网络优化
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\NetBT\Parameters', 'NameSrvQueryTimeout', 'REG_DWORD', '0000bb8')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Rpc', 'MaxRpcSize', 'REG_DWORD', '00100000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxCmds', 'REG_DWORD', '00000064')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxThreads', 'REG_DWORD', '00000064')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxCollectionCount', 'REG_DWORD', '00000064')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\AFD\Parameters', 'BufferMultiplier', 'REG_DWORD', '00000400')
	;;关闭自动调试提高运行速度
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
	;;优化程序进程，独立进程优先级，避免死机
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer', 'DesktopProcess', 'REG_DWORD', '00000001')
	;;加快开机和关机
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'WaitToKillAppTimeout', 'REG_SZ', '2000')
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'HungAppTimeout', 'REG_SZ', '900')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control', 'WaitToKillServiceTimeout', 'REG_SZ', '2000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control', 'WaitToKillServiceTimeout', 'REG_SZ', '2000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'ReportBootOk', 'REG_SZ', '0')
	If Not $HasSSD Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
	Else
		TurnOffPrefetch()
	EndIf
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'VideoInitTime', 'REG_DWORD', '000001e4')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
	;禁用内存面调度,提升核心系统性能
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'DisablePagingExecutive', 'REG_DWORD', '00000001')
	;提高NTFS访问速度
	If Not HasSSD() Then RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisableLastAccessUpdate', 'REG_DWORD', '00000000')
	If Not HasSSD() Then RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisable8dot3NameCreation', 'REG_DWORD', '00000000')
	;在资源管理器显示菜单栏
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'AlwaysShowClassicMenu', 'REG_DWORD', '00000001')
	;跳过WMP首次运行出现的协议窗口
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer', 'GroupPrivacyAcceptance', 'REG_DWORD', '00000001')
	;提高WMP的编码能力
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'HighRate', 'REG_DWORD', '0002EE00')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'LowRate', 'REG_DWORD', '0000DAC0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'MediumHighRate', 'REG_DWORD', '0001F400')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'MediumRate', 'REG_DWORD', '0000FA00')
	;在独立的内存空间中运行16位程序
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\WOW', 'DefaultSeparateVDM', 'REG_SZ', 'Yes')
	;禁用程序兼容助手
	RegWrite('HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\AppCompat', 'DisablePCA', 'REG_DWORD', '00000001')
	;打开启动优化功能
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'Y')
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
		_OsServer_AddRegTweaks_34()
	EndIf
	;dns Tweaks
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters', 'MaxCacheTtl', 'REG_DWORD', '00003840')
	;禁用隐藏共享
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
	;杂项
	RegWrite('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows NT\Driver Signing', 'BehaviorOnFailedVerify', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'DEVMGR_SHOW_DETAILS', 'REG_SZ', '1')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout', 'EnableAutoLayout', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ForegroundLockTimeout', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager', 'AutoChkTimeOut', 'REG_DWORD', '00000005')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\ContentIndex', 'FilterFilesWithUnknownExtensions', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup', 'SourcePath', 'REG_SZ', '')
EndFunc   ;==>_OsVista7_AddRegTweaks_35

;-------------------------------------------------------------------------------
; _OsVista7_AddRegTweaks_45
; 适用条件：@OSBuild > 8000（不满足时走另一分支）
; 来源：AddRegTweaks / 17 上帝模式
;-------------------------------------------------------------------------------
Func _OsVista7_AddRegTweaks_45()
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
		_OsServer_AddRegTweaks_41()
	Else
		_OsCommon_AddRegTweaks_44()
	EndIf
EndFunc   ;==>_OsVista7_AddRegTweaks_45

;-------------------------------------------------------------------------------
; _OsVista7_AddRegTweaks_52
; 适用条件：@OSBuild > 8000（不满足时走另一分支）
; 来源：AddRegTweaks / 18 开机直接进入桌面(win8)
;-------------------------------------------------------------------------------
Func _OsVista7_AddRegTweaks_52()
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
		_OsServer_AddRegTweaks_50()
	Else
		_OsCommon_AddRegTweaks_51()
	EndIf
EndFunc   ;==>_OsVista7_AddRegTweaks_52

;-------------------------------------------------------------------------------
; _OsVista7_pluginsTweaks_02
; 适用条件：@OSBuild > 8000（不满足时走另一分支）
; 来源：pluginsTweaks / 3破解系统主题
;-------------------------------------------------------------------------------
Func _OsVista7_pluginsTweaks_02()
	$i += 1
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在对系统主题进行破解..'
	$percent += $percent
	If @OSArch = "X86" Then
		FileInstall('.\src\file\ThemePatcherx86.exe', @TempDir & '\', 1)
		RunWait(@TempDir & '\ThemePatcherx86.exe  -silent', '', @SW_HIDE)
	ElseIf @OSArch = "X64" Then
		FileInstall('.\src\file\ThemePatcherx64.exe', @TempDir & '\', 1)
		RunWait(@TempDir & '\ThemePatcherx64.exe  -silent', '', @SW_HIDE)
	Else
	EndIf
EndFunc   ;==>_OsVista7_pluginsTweaks_02

;-------------------------------------------------------------------------------
; _OsVista7_pluginsTweaks_12
; 适用条件：@OSBuild > 8000（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsVista7_pluginsTweaks_12()
	$percent += $percent
	If @OSVersion = 'WIN_XP' Then
		_OsXp_pluginsTweaks_08()
	Else
		_OsCommon_pluginsTweaks_11()
	EndIf
EndFunc   ;==>_OsVista7_pluginsTweaks_12

;-------------------------------------------------------------------------------
; _OsVista7_pluginsTweaks_18
; 适用条件：@OSBuild < 8000
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsVista7_pluginsTweaks_18()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装去除桌面水印补丁..'
	If @OSArch = "X86" Then
		FileInstall('.\src\file\RemoveWatermarkX86.exe', @TempDir & '\', 1)
		RunWait(@TempDir & '\RemoveWatermarkX86.exe  -silent', '', @SW_HIDE)
	ElseIf @OSArch = "X64" Then
		FileInstall('.\src\file\RemoveWatermarkX64.exe', @TempDir & '\', 1)
		RunWait(@TempDir & '\RemoveWatermarkX64.exe  -silent', '', @SW_HIDE)
	Else
	EndIf
EndFunc   ;==>_OsVista7_pluginsTweaks_18
