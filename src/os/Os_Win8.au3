;==============================================================================
; 模块：Windows 8 / 8.1 / 2012
; 说明：适用于 8000 < @OSBuild <= 10240，或 @OSVersion = WIN_8 / WIN_81 的分支实现
; 文件：src\os\Os_Win8.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_07
; 适用条件：@OSVersion = 'WIN_81'
; 来源：AddRegTweaks / 5开始菜单显示运行命令
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_07()
	RegWrite('HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\PintoStartScreen', '', 'REG_SZ', '{470C0EBD-5D73-4d58-9CED-E91E22E23282}')
	RegWrite('HKEY_CURRENT_USER\Software\Classes\AllFileSystemObjects\shellex\ContextMenuHandlers\PintoStartScreen', '', 'REG_SZ', '{470C0EBD-5D73-4d58-9CED-E91E22E23282}')
EndFunc   ;==>_OsWin8_AddRegTweaks_07

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_24
; 适用条件：@OSBuild > 8000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_24()
	If @OSBuild > 21990 Then
		_OsWin11_AddRegTweaks_22()
	Else
		_OsCommon_AddRegTweaks_23()
	EndIf
EndFunc   ;==>_OsWin8_AddRegTweaks_24

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_29
; 适用条件：@OSBuild > 9000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_29()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'HideSCAHealth', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin8_AddRegTweaks_29

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_33
; 适用条件：@OSBuild > 8000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_33()
	;等优化啥的，哈哈
	;允许未登录关机
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system', 'shutdownwithoutlogon', 'REG_DWORD', '00000001')
	;开机不显示服务管理器
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\ServerManager', 'DoNotOpenServerManagerAtLogon', 'REG_DWORD', '00000001')
	;加快菜单显示速度
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '10')
	;;取消IE禁用加载项的提示(设置延迟10秒，这样就不会提示了)
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\MAO Settings', 'AddonLoadTimeThreshold', 'REG_DWORD', '00002710')
	;格式化选项中显示Refs格式
	RegWrite('HKEY_LOCALMACHINE\SYSTEM\CurrentControlSet\Control\MiniNT', 'AllowRefsFormatOverNonmirrorVolume', 'REG_DWORD', '00000001')
	;禁用windows8帮助提示
	RegWrite('HKEY_CURRENT_USER\Software|Policies\Microsoft\Windows\EdgeUI', 'DisableHelpSticker', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin8_AddRegTweaks_33

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_39
; 适用条件：@OSBuild > 9000（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_39()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'FilterAdministratorToken', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsWin8_AddRegTweaks_39

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_40
; 适用条件：@OSBuild > 8000
; 来源：AddRegTweaks / 17 上帝模式
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_40()
	If @OSBuild > 9000 Then
		_OsWin10_AddRegTweaks_38()
	Else
		_OsWin8_AddRegTweaks_39()
	EndIf
EndFunc   ;==>_OsWin8_AddRegTweaks_40

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_46
; 适用条件：@OSVersion = 'WIN_8'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_46()
	Local $BootFile = FileOpen(@StartupCommonDir & '\BootToDesktop.scf', 1 + 8)
	FileWrite($BootFile, '')
	FileWrite($BootFile, '[Shell]' & @LF & 'Command=2' & @LF & 'IconFile=imageres.dll,105' & @LF & '[Taskbar]' & @LF & 'Command=ToggleDesktop')
	FileClose($BootFile)
EndFunc   ;==>_OsWin8_AddRegTweaks_46

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_47
; 适用条件：@OSVersion = "WIN_81" Or @OSVersion = "WIN_10"
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_47()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage', 'OpenAtLogon', 'REG_DWORD', '00000000')
EndFunc   ;==>_OsWin8_AddRegTweaks_47

;-------------------------------------------------------------------------------
; _OsWin8_AddRegTweaks_49
; 适用条件：@OSBuild > 8000
; 来源：AddRegTweaks / 18 开机直接进入桌面(win8)
;-------------------------------------------------------------------------------
Func _OsWin8_AddRegTweaks_49()
	If @OSVersion = 'WIN_8' Then
		_OsWin8_AddRegTweaks_46()
	EndIf
	If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Then
		_OsWin8_AddRegTweaks_47()
	EndIf
	If @OSBuild > 9000 Then
		_OsWin10_AddRegTweaks_48()
	EndIf
EndFunc   ;==>_OsWin8_AddRegTweaks_49

;-------------------------------------------------------------------------------
; _OsWin8_pluginsTweaks_01
; 适用条件：@OSBuild > 8000
; 来源：pluginsTweaks / 3破解系统主题
;-------------------------------------------------------------------------------
Func _OsWin8_pluginsTweaks_01()
	$i += 1
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装系统更新禁用服务)..'
	$percent += $percent
	DirCreate(@ProgramFilesDir & "\UpdaterDisabler")
	FileInstall('.\src\file\UpdaterDisabler.exe', @ProgramFilesDir & "\UpdaterDisabler\")
	RunWait(@ProgramFilesDir & "\UpdaterDisabler\UpdaterDisabler.exe -install", @ProgramFilesDir & "\UpdaterDisabler\", @SW_HIDE)
EndFunc   ;==>_OsWin8_pluginsTweaks_01

;-------------------------------------------------------------------------------
; _OsWin8_pluginsTweaks_05
; 适用条件：@OSBuild < 10240
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_pluginsTweaks_05()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows开发者证书..'
	$percent += $percent
	RunWait(@ComSpec & ' /c powershell -c Show-WindowsDeveloperLicenseRegistration', @WindowsDir, @SW_HIDE)
EndFunc   ;==>_OsWin8_pluginsTweaks_05

;-------------------------------------------------------------------------------
; _OsWin8_pluginsTweaks_07
; 适用条件：@OSBuild > 8000
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_pluginsTweaks_07()
	If @OSBuild < 10240 Then
		_OsWin8_pluginsTweaks_05()
	Else
		_OsWin10_pluginsTweaks_06()
	EndIf
EndFunc   ;==>_OsWin8_pluginsTweaks_07

;-------------------------------------------------------------------------------
; _OsWin8_pluginsTweaks_19
; 适用条件：@OSBuild < 8000（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsWin8_pluginsTweaks_19()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在添加“Windows8右键快捷菜单”..'
	;Windows8右键快捷菜单
	Local $OsString = ''
	Switch @OSArch
		Case 'X64'
			$OsString = '64'
		Case 'X86'
			$OsString = ''
	EndSwitch
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt', '', 'REG_SZ', '命令提示符')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt', 'icon', 'REG_SZ', 'cmd.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt\command', '', 'REG_SZ', 'cmd.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel', '', 'REG_SZ', '控制面板')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel', 'icon', 'REG_SZ', 'shell32.dll,21')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel\command', '', 'REG_SZ', 'rundll32.exe shell32.dll,Control_RunDLL')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer', '', 'REG_SZ', '我的电脑')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer', 'icon', 'REG_SZ', 'imageres.dll,105')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer\command', '', 'REG_SZ', 'explorer.exe /e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad', '', 'REG_SZ', '记事本')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad', 'icon', 'REG_SZ', 'notepad.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad\command', '', 'REG_SZ', 'notepad.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint', '', 'REG_SZ', '画 图')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint', 'icon', 'REG_SZ', 'mspaint.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint\command', '', 'REG_SZ', 'mspaint.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart', '', 'REG_SZ', '重 启')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart', 'icon', 'REG_SZ', 'shell32.dll,112')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart\command', '', 'REG_SZ', 'Shutdown -r -f -t 0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown', '', 'REG_SZ', '关 机')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown', 'icon', 'REG_SZ', 'shell32.dll,215')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown\command', '', 'REG_SZ', 'Shutdown -s -f -t 0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool', '', 'REG_SZ', '截 图')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool', 'icon', 'REG_SZ', 'SnippingTool.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool\command', '', 'REG_SZ', 'SnippingTool.exe')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff', '', 'REG_SZ', '注 销')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff', 'icon', 'REG_SZ', 'shell32.dll,44')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff\command', '', 'REG_SZ', 'Shutdown -l')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services', '', 'REG_SZ', '服 务')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services', 'SuppressionPolicy', 'REG_DWORD', '4000003c')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services\command', '', 'REG_EXPAND_SZ', '%windir%\system32\mmc.exe /s %SystemRoot%\system32\services.msc /s')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'Position', 'REG_SZ', 'top')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'MUIVerb', 'REG_SZ', '快捷键')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'Icon', 'REG_SZ', 'shell32.dll,319')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'Position', 'REG_SZ', 'top')
	RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
EndFunc   ;==>_OsWin8_pluginsTweaks_19
