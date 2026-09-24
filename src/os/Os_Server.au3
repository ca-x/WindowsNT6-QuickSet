;==============================================================================
; 模块：Windows Server
; 说明：适用于 @OSVersion = WIN_2003 / WIN_2008 / WIN_2008R2 的服务器版实现
; 文件：src\os\Os_Server.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsServer_AddRegTweaks_34
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsServer_AddRegTweaks_34()
	;关机理由啥的
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonUI', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonOn', 'REG_DWORD', '00000000')
	;提升多媒体优先级解决爆音问题
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile', 'SystemResponsiveness', 'REG_DWORD', '00000014')
	;禁用仅加载代码签署的DLLs参考http://msdn.microsoft.com/zh-cn/library/ee461144.aspx
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows', 'RequireSignedAppInit_DLLs', 'REG_DWORD', '00000000')
EndFunc   ;==>_OsServer_AddRegTweaks_34

;-------------------------------------------------------------------------------
; _OsServer_AddRegTweaks_36
; 适用条件：@OSVersion = 'WIN_2003'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsServer_AddRegTweaks_36()
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ScreenSaverIsSecure', 'REG_SZ', '0')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Policies\system', 'disablecad', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonUI', 'REG_DWORD', '000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonOn', 'REG_DWORD', '000000')
EndFunc   ;==>_OsServer_AddRegTweaks_36

;-------------------------------------------------------------------------------
; _OsServer_AddRegTweaks_41
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsServer_AddRegTweaks_41()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoAdminLogon', 'REG_SZ', '1')
EndFunc   ;==>_OsServer_AddRegTweaks_41

;-------------------------------------------------------------------------------
; _OsServer_AddRegTweaks_50
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsServer_AddRegTweaks_50()
	Local $infData = '[version]' & @LF & _
			'signature="$CHICAGO$"' & @LF & _
			'[System Access]' & @LF & _
			'MinimumPasswordAge = 0' & @LF & _
			'MaximumPasswordAge = 0' & @LF & _
			'MinimumPasswordLength = 0' & @LF & _
			'PasswordComplexity = 0' & @LF & _
			'PasswordHistorySize = 0' & @LF & _
			'LockoutBadCount = 0' & @LF & _
			'RequireLogonToChangePassword = 0' & @LF & _
			'ForceLogoffWhenHourExpire = 0'

	Local $InfH = FileOpen(@TempDir & '\gp.inf', 1 + 8)
	FileWrite($InfH, $infData)
	FileClose($InfH)
	RunWait(@ComSpec & ' /c secedit /configure /db gp.sdb /cfg gp.inf /quiet', @TempDir, @SW_HIDE)
	;刷新组策略
	RunWait(@ComSpec & ' /c GPUpdate /force', @WindowsDir, @SW_HIDE)
	;清除inf文件
	FileDelete(@TempDir & '\gp.inf')
EndFunc   ;==>_OsServer_AddRegTweaks_50

;-------------------------------------------------------------------------------
; _OsServer_AddRegTweaks_53
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'
; 来源：AddRegTweaks / 19禁用登录需要按Ctrl+Alt+Del
;-------------------------------------------------------------------------------
Func _OsServer_AddRegTweaks_53()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'disablecad', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsServer_AddRegTweaks_53

;-------------------------------------------------------------------------------
; _OsServer_pluginsTweaks_09
; 适用条件：@OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008"
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsServer_pluginsTweaks_09()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows2008游戏补丁..'
	FileInstall('.\src\file\GameFixForws2008.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\GameFixForws2008.exe', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\GameFixForws2008.exe')
EndFunc   ;==>_OsServer_pluginsTweaks_09

;-------------------------------------------------------------------------------
; _OsServer_pluginsTweaks_14
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008'
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsServer_pluginsTweaks_14()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在在资源管理器中安装windows2008DirectMusic补丁..'
	$percent += $percent
	If FileExists(@TempDir & '\DirectMusic.exe') = 0 Then FileInstall('.\src\file\DirectMusic.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\DirectMusic.exe', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\DirectMusic.exe')
EndFunc   ;==>_OsServer_pluginsTweaks_14

;-------------------------------------------------------------------------------
; _OsServer_pluginsTweaks_21
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008'
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsServer_pluginsTweaks_21()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows2008xbox支持补丁..'
	FileInstall('.\src\file\xbox.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\xbox.exe', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\xbox.exe')
EndFunc   ;==>_OsServer_pluginsTweaks_21

;-------------------------------------------------------------------------------
; Win08ServiceTweaks  （整函数搬移，来源：src/features/system/Feat_Services.au3）
;-------------------------------------------------------------------------------
;=========================================================================================
; 系统服务及功能
;=========================================================================================
;08
Func Win08ServiceTweaks()
	Local $n = 0, $SeletedCount = 0
	For $i = 1 To 12
		If GUICtrlRead($svc[$i]) = $GUI_CHECKED Then
			$SeletedCount += 1
		EndIf
	Next
	If $SeletedCount > 0 Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Local $i = 0
		GUISetState(@SW_SHOW, $LoadingUI)
		Local $percent = 100 / $SeletedCount
		;1开启音频服务
		If GUICtrlRead($svc[1]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启音频服务..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\AudioEndpointBuilder', 'Start', 'REG_DWORD', '00000002')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Audiosrv', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;2开启主题服务
		If GUICtrlRead($svc[2]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启主题服务..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Themes', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;3启用搜索服务
		If GUICtrlRead($svc[3]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用搜索功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:FS-Search-Service', @WindowsDir, @SW_HIDE)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\WSearch', 'Start', 'REG_DWORD', '00000002')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\WSearch', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;4启用缩略图
		If GUICtrlRead($svc[4]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用缩略图功能..'
			$percent += $percent
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'IconsOnly', 'REG_DWORD', '00000000')
		EndIf
		;5开启SuperFetch
		If GUICtrlRead($svc[5]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启超级预读取..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableSuperfetch', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Prefetcher')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NvCache')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\SysMain', 'DisplayName', 'REG_SZ', 'Superfetch')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\SysMain', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;6 安装桌面体验
		If GUICtrlRead($svc[6]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用桌面体验功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:InkSupport', @WindowsDir, @SW_HIDE)
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:DesktopExperience', @WindowsDir, @SW_HIDE)
		EndIf
		;7提高windows2008兼容性
		If GUICtrlRead($svc[7]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在应用兼容性优化设置项目..'
			$percent += $percent
			;关闭数据执行保护
			RunWait(@ComSpec & ' /c BCDEDIT /set {current} nx AlwaysOff', @WindowsDir, @SW_HIDE)
			;设置处理器计划为程序,设置为00000018为后台程序
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PriorityControl', 'REG_DWORD', '00000026')
		EndIf
		;8开启Aero透明效果
		If GUICtrlRead($svc[8]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启Aero透明效果..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'UseAlternateButtons', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Animations', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Glass', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Blur', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'EnableMachineCheck', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'MagnificationPercent', 'REG_DWORD', '00000064')
		EndIf
		;9启用网络打印机支持
		If GUICtrlRead($svc[9]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用网络打印支持..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:Printing-InternetPrinting-Client', @WindowsDir, @SW_HIDE)
		EndIf
		;10启用无线功能
		If GUICtrlRead($svc[10]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用无线功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:WirelessNetworking', @WindowsDir, @SW_HIDE)
		EndIf
		;11启用Telnet客户端
		If GUICtrlRead($svc[11]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用Telnet客户端功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:TelnetClient', @WindowsDir, @SW_HIDE)
		EndIf
		;12启用NetFramework3.5
		If GUICtrlRead($svc[12]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用NetFramework3.5功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:NetFx3', @WindowsDir, @SW_HIDE)
		EndIf
		GUISetState(@SW_HIDE, $LoadingUI)
		_GUIDisable($Form1, 0)
		_EnableTrayMenu()
		$aText = '正在处理，请稍后'
		_ForceUpdate()
		MsgBox(0, '提示', '您选择的项目已经应用到当前系统!', 5)
	Else
		MsgBox(16, '错误', '请选择您要进行优化的项目！', 5)
	EndIf
EndFunc   ;==>Win08ServiceTweaks
