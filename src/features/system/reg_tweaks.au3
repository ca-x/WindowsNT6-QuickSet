;==============================================================================
; 模块：注册表优化项
; 说明：常规优化选项卡中的各项注册表优化及其移除/还原；各版本实现见 src\os
; 文件：src\features\system\reg_tweaks.au3
; 函数：共 26 个
;==============================================================================
#include-once

Func DllInstall($sDll)
	$aCall = DllCall($sDll, "long", "DllRegisterServer")
	If @error Or $aCall[0] Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>DllInstall
Func DllUnInstall($sDll)
	$aCall = DllCall($sDll, "long", "DllUnregisterServer")
	If @error Or $aCall[0] Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>DllUnInstall


Func _ForceUpdate()
	DllCall("user32.dll", "int", "SendMessageTimeout", "hwnd", 65535, "int", 26, "int", 0, "int", 0, "int", 0, "int", 1000, "str", "dwResult")
	$binWave = Wave()
	$tWave = DllStructCreate('byte[' & BinaryLen($binWave) & ']')
	$pWave = DllStructGetPtr($tWave)
	DllStructSetData($tWave, 1, $binWave)
	_WinAPI_PlaySound($pWave, BitOR($SND_ASYNC, $SND_MEMORY, $SND_NOWAIT))
	$tWave = 0
EndFunc   ;==>_ForceUpdate
;=========================================================================================
; 注册表优化项目
;=========================================================================================
Func AddRegTweaks()
	$n = 0
	;1右键添加管理员取得所有权
	If GUICtrlRead($Checkbox[1]) = $GUI_CHECKED Then
		If @OSBuild < 6000 Then
			_OsXp_AddRegTweaks_01()
		Else
			_OsCommon_AddRegTweaks_02()
		EndIf
		$n += 1
	EndIf
	;
	If GUICtrlRead($Checkbox[2]) = $GUI_CHECKED Then
		If @OSBuild > 19040 Then
			_OsWin11_AddRegTweaks_03()
		Else
			_OsWin10_AddRegTweaks_06()
		EndIf
		$n += 1
	EndIf
	;3右键快速打开CMD
	If GUICtrlRead($Checkbox[3]) = $GUI_CHECKED Then
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符', 'icon', 'REG_SZ', 'C:\WINDOWS\system32\cmd.exe')
		RegWrite('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Command Processor', 'CompletionChar', 'REG_DWORD', '9')
		RegWrite("HKEY_CLASSES_ROOT\.cmd\ShellNew", "NullFile", "REG_SZ", "")
		$n += 1
	EndIf
	;4右键快速打开PowerShell
	If GUICtrlRead($Checkbox[4]) = $GUI_CHECKED Then
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell\command', '', 'REG_SZ', "C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -noexit set-location -Path '%1'")
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell', 'icon', 'REG_SZ', 'C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe')
		$n += 1
	EndIf
	;5开始菜单显示运行命令
	If GUICtrlRead($Checkbox[5]) = $GUI_CHECKED Then
		If @OSVersion = 'WIN_81' Then
			_OsWin8_AddRegTweaks_07()
		Else
			_OsCommon_AddRegTweaks_10()
		EndIf
		$n += 1
	EndIf
	;6资源管理器启用复选框
	;启用停止更新的Windowsupdate
	If GUICtrlRead($Checkbox[6]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_11()
		Else
			_OsXp_AddRegTweaks_14()
		EndIf
		$n += 1
	EndIf
	;7禁用UAC
	If GUICtrlRead($Checkbox[7]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_15()
		Else
			_OsXp_AddRegTweaks_16()
		EndIf
		$n += 1
	EndIf
	;8右键添加记事本打开项
	If GUICtrlRead($Checkbox[8]) = $GUI_CHECKED Then
		RegWrite("HKEY_CLASSES_ROOT\*\shell\Notepad", "", "REG_SZ", "用记事本打开")
		RegWrite("HKEY_CLASSES_ROOT\*\shell\Notepad\command", "", "REG_SZ", "notepad.exe %1")
		$n += 1
	EndIf
	;9右键添加DLL\OCX注册与反注册
	If GUICtrlRead($Checkbox[9]) = $GUI_CHECKED Then
		RegWrite("HKEY_CLASSES_ROOT\.ocx", "", "REG_SZ", "ocxfile")
		RegWrite("HKEY_CLASSES_ROOT\ocxfile", "", "REG_SZ", "OCX")
		RegWrite("HKEY_CLASSES_ROOT\ocxfile\Shell\注册\command", "", "REG_SZ", 'regsvr32.exe \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\ocxfile\Shell\反注册\command", "", "REG_SZ", 'regsvr32.exe /u \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\.dll", "Content Type", "REG_SZ", "application/x-msdownload")
		RegWrite("HKEY_CLASSES_ROOT\.dll", "", "REG_SZ", "Application Extension")
		RegWrite("HKEY_CLASSES_ROOT\dllfile\Shell\注册\command", "", "REG_SZ", 'regsvr32.exe \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\dllfile\Shell\反注册\command", "", "REG_SZ", 'regsvr32.exe /u \"%1"')
		$n += 1
	EndIf
	;10右键添加在新窗口打开命令
	If GUICtrlRead($Checkbox[10]) = $GUI_CHECKED Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开', '', 'REG_SZ', '在新窗口中打开')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开\Command', '', 'REG_SZ', 'explorer %1')
		$n += 1
	EndIf
	;11移除快捷方式字样和图标
	If GUICtrlRead($Checkbox[11]) = $GUI_CHECKED Then
		If @OSBuild < 6000 Then
			_OsXp_AddRegTweaks_17()
		Else
			_OsCommon_AddRegTweaks_18()
		EndIf
		$n += 1
	EndIf
	;12	任务栏使用小图标
	If GUICtrlRead($Checkbox[12]) = $GUI_CHECKED Then
		If @OSBuild > 21900 Then
			_OsWin11_AddRegTweaks_19()
		Else
			_OsCommon_AddRegTweaks_20()
		EndIf
		$n += 1
	EndIf
	;13优化系统显示设置
	If GUICtrlRead($Checkbox[13]) = $GUI_CHECKED Then
		RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothing", "REG_SZ", "2")
		RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothingType", "REG_DWORD", "00000002")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "Max Cached Icons", "REG_SZ", "7500")
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Animations', 'REG_DWORD', '00000000')
		;Xp的显示优化啥的
		If @OSBuild < 6000 Then
			_OsXp_AddRegTweaks_21()
		EndIf
		$n += 1
	EndIf
	;14打开所在目录
	If GUICtrlRead($Checkbox[14]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_26()
		Else
			_OsXp_AddRegTweaks_27()
		EndIf
		$n += 1
	EndIf
	;15隐藏操作中心图标
	If GUICtrlRead($Checkbox[15]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_30()
		Else
			_OsXp_AddRegTweaks_31()
		EndIf
		$n += 1
	EndIf
	;16系统性能综合优化
	;16Windows8优化
	If GUICtrlRead($Checkbox[16]) = $GUI_CHECKED Then
		;调节内存性能配置
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'Size', 'REG_DWORD', '00000002')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'IoPageLockLimit', 'REG_DWORD', '00000000')
		;关闭磁盘自动播放
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
		;关闭磁盘空间不足警告
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoLowDiskSpaceChecks', 'REG_DWORD', '00000001')
		;Explorer崩溃时，自动重启
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoRestartShell', 'REG_DWORD', '00000001')
		;显示文件扩展名
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'HideFileExt', 'REG_DWORD', '00000000')
		;删除无用的新建项目
		RegDelete('HKEY_CLASSES_ROOT\Briefcase\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.contact\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.bmp\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.rtf\ShellNew')
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_32()
		EndIf
		;最小化时显示完整路径
		RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState', 'FullPath', 'REG_DWORD', '00000001')
		;禁用.NET Runtime Optimization Service
		;http://baike.baidu.com/view/713328.htm
		Local $i = 1
		Do
			$keys = RegEnumKey('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services', $i)
			If StringInStr($keys, 'clr_Optimization') Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\' & $keys, 'Start', 'REG_DWORD', '0x00000004')
			EndIf
			$i += 1
		Until $keys = ''
		;;增加 Internet 时间校准网站
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '', 'REG_SZ', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '2', 'REG_SZ', 'time-a.nist.gov')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '3', 'REG_SZ', 'time-b.nist.gov')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '4', 'REG_SZ', 'time-nw.nist.gov')
		;驱动签名
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Driver Signing', 'Policy', 'REG_BINARY', '01')
		;关闭错误报告
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\PCHealth\ErrorReporting', 'DoReport', 'REG_DWORD', '00000000')
		;禁用IPV6
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters', 'DisabledComponents', 'REG_DWORD', '000000ff')
		;启用性能for程序
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
		;网络优化for all
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'DefaultTTL', 'REG_DWORD', '64')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'EnablePMTUBHDetect', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'EnablePMTUDiscovery', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'MTU', 'REG_DWORD', '1500')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'SackOpts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'TCPWindowSize', 'REG_DWORD', '25000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'DefaultTTL', 'REG_DWORD', '64')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'EnablePMTUBHDetect', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'EnablePMTUDiscovery', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'MTU', 'REG_DWORD', '1500')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'SackOpts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '3')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'TCPWindowSize', 'REG_DWORD', '25000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'DisableTaskOffload', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer', 'AlwaysUnloadDll', 'REG_SZ', '1')
		;禁止使用绝对路径来解释出错的快捷方式
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'LinkResolveIgnoreLinkInfo', 'REG_DWORD', '00000001')
		If @OSBuild > 8000 Then
			_OsWin8_AddRegTweaks_33()
		Else
			If @OSBuild < 8000 And @OSBuild > 6000 Then
				_OsVista7_AddRegTweaks_35()
			Else
				_OsXp_AddRegTweaks_37()
			EndIf
		EndIf
		$n += 1
	EndIf
	;17自动登录(Windows2008)
	;17使管理员可以使用Metro应用
	;17 上帝模式
	If GUICtrlRead($Checkbox[17]) = $GUI_CHECKED Then
		If @OSBuild > 8000 Then
			_OsWin8_AddRegTweaks_40()
		Else
			_OsVista7_AddRegTweaks_45()
		EndIf
		$n += 1
	EndIf
	;18去除组策略密码验证限制
	;18 开机直接进入桌面(win8)
	;去除显卡右键菜单
	If GUICtrlRead($Checkbox[18]) = $GUI_CHECKED Then
		If @OSBuild > 8000 Then
			_OsWin8_AddRegTweaks_49()
		Else
			_OsVista7_AddRegTweaks_52()
		EndIf
		$n += 1
	EndIf
	;19禁用登录需要按Ctrl+Alt+Del
	;USB供电开关
	If GUICtrlRead($Checkbox[19]) = $GUI_CHECKED Then
		If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
			_OsServer_AddRegTweaks_53()
		Else
			_OsCommon_AddRegTweaks_54()
		EndIf
		$n += 1
	EndIf
	;20IE综合优化选项
	If GUICtrlRead($Checkbox[20]) = $GUI_CHECKED Then
		If @OSBuild > 21900 Then
			_OsWin11_AddRegTweaks_55()
		Else
			_OsCommon_AddRegTweaks_56()
		EndIf
		$n += 1
	EndIf
	;21关闭系统开机声音#关闭分组相似任务栏按钮
	If GUICtrlRead($Checkbox[21]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			_OsCommon_AddRegTweaks_57()
		Else
			_OsXp_AddRegTweaks_58()
		EndIf
		$n += 1
	EndIf
EndFunc   ;==>AddRegTweaks
Func RemoveRegTweak1()
	;删除管理员取得权限
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键"管理员取得所有权"菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak1
Func RemoveRegTweak2()
	If @OSBuild > 19040 Then
		;恢复新版系统属性界面
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\0\2093230218', 'EnabledState', 'REG_DWORD', '00000002')
		_ForceUpdate()
		MsgBox(0, '提示', '恢复默认系统属性界面成功', 5)
	Else
		;删除cab最大压缩
		If @OSBuild > 6000 Then
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress')
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand')
			RegDelete('HKEY_CLASSES_ROOT\*\shell\CABMenu')
		Else
			RegDelete('HKEY_CLASSES_ROOT\*\shell\CAB最大压缩')
			RegDelete('HKEY_CLASSES_ROOT\*\shell\解压缩 CAB 文件')
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '移除CAB相关菜单成功', 5)
	EndIf

EndFunc   ;==>RemoveRegTweak2
Func RemoveRegTweak3()
	;删除在此处打开命令提示符
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\在此处打开命令提示符')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\在此处打开命令提示符\Command')
	RegDelete('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符\command')
	RegDelete('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符\command')
	RegDelete('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符\command')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键命令行菜单成功', 5)
EndFunc   ;==>RemoveRegTweak3
Func RemoveRegTweak4()
	;POERRSHELL
	RegDelete("HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell")
	RegDelete("HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell\command")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键Powershell菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak4
Func RemoveRegTweak5()
	;RUN
	If @OSVersion = 'WIN_81' Then
		RegDelete('HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\PintoStartScreen')
		RegDelete('HKEY_CURRENT_USER\Software\Classes\AllFileSystemObjects\shellex\ContextMenuHandlers\PintoStartScreen')
		MsgBox(0, '提示', '取消所有文件都可固定到开始菜单成功！', 5)
	Else
		If @OSBuild > 6000 Then
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000000')
			RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000000')
			MsgBox(0, '提示', '取消开始菜单运行命令显示成功！', 5)
		Else
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '00000095')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '00000095')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\cdrom', 'Autorun', 'REG_DWORD', '00000001')
			RegWrite('KEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\cdrom', 'Autorun', 'REG_DWORD', '00000001')
			MsgBox(0, '提示', '开启光盘及磁盘自动播放功能成功！', 5)
		EndIf
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak5
Func RemoveRegTweak6()
	;禁用复选框
	If @OSBuild > 6000 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'AutoCheckSelect', 'REG_DWORD', '0')
		MsgBox(0, '提示', '在资源管理器中禁用复选框选择成功！', 5)
	Else
		If @OSVersion <> 'WIN_XP' Then
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareWks')
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
			MsgBox(0, '提示', '启用系统默认共享成功！！', 5)
		EndIf
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak6
Func RemoveRegTweak7()
	;UAC
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000002')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorUser', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableInstallerDetection', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'PromptOnSecureDesktop', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '启用UAC成功！', 5)
EndFunc   ;==>RemoveRegTweak7
Func RemoveRegTweak8()
	;NOTEPAD
	RegDelete("HKEY_CLASSES_ROOT\*\shell\Notepad\command")
	RegDelete("HKEY_CLASSES_ROOT\*\shell\Notepad")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键记事本菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak8
Func RemoveRegTweak9()
	;DLL\OCX
	RegDelete("HKEY_CLASSES_ROOT\ocxfile\Shell")
	RegDelete("HKEY_CLASSES_ROOT\dllfile\Shell")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键ocx及dll相关菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak9
Func RemoveRegTweak10()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键菜单"在新窗口中打开"成功！', 5)
EndFunc   ;==>RemoveRegTweak10
Func RemoveRegTweak11()
	Local $icoEmpty = @WindowsDir & '\Empty.ico'
	If FileExists($icoEmpty) Then FileDelete($icoEmpty)
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '29')
	_ForceUpdate()
	MsgBox(0, '提示', '还原快捷方式图标成功！', 5)
EndFunc   ;==>RemoveRegTweak11
Func RemoveRegTweak12()
	If @OSBuild > 21900 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '00000002')
	Else
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSmallIcons', 'REG_DWORD', '00000000')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '设置任务栏使用大图标成功！', 5)
EndFunc   ;==>RemoveRegTweak12

Func RemoveRegTweak12_1()
	If @OSBuild > 21900 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '00000001')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '设置任务栏使用中等图标成功！', 5)
EndFunc   ;==>RemoveRegTweak12_1

Func RemoveRegTweak14()
	If @OSBuild > 6000 Then
		If @OSBuild > 8000 Then
			If @OSBuild > 21990 Then
				RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig')
				MsgBox(0, '提示', '恢复系统默认设置成功！', 5)
			Else
				RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'NoPreviousVersionsPage')
				MsgBox(0, '提示', '恢复属性界面"以前的版本"标签页成功！', 5)
			EndIf
		Else
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\Flip3D')
			MsgBox(0, '提示', '移除右键菜单成功！', 5)
		EndIf
	Else
		RegDelete('HKEY_CLASSES_ROOT\lnkfile\shell\打开所在目录')
		FileDelete(@WindowsDir & '\system32\OpenShortcutDir.vbs')
		MsgBox(0, '提示', '移除右键菜单成功！', 5)
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak14
Func RemoveRegTweak15()
	If @OSBuild > 6000 Then
		If @OSBuild > 9000 Then
			RegDelete('HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer')
		Else
			RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'HideSCAHealth')
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '恢复操作中心托盘图标成功！', 5)
	Else
	EndIf
EndFunc   ;==>RemoveRegTweak15
Func RemoveRegTweak17()
	If @OSBuild > 6000 Then
		If @OSBuild > 9000 Then
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'LaunchTo', 'REG_DWORD', '00000002')
			MsgBox(0, '提示', '设置打开文件资源管理器时打开快速访问成功', 5)
		Else
			RegDelete('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式')
			MsgBox(0, '提示', '移除"上帝模式"右键菜单成功！', 5)
		EndIf
		_ForceUpdate()
	EndIf
EndFunc   ;==>RemoveRegTweak17
Func RemoveRegTweak18_2()
	;快速访问显示常用文件夹
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowFrequent', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '设置快速访问显示常用文件夹成功！', 5)
EndFunc   ;==>RemoveRegTweak18_2
Func RemoveRegTweak18_3()
	;快速访问显示最近文件
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowRecent', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '设置快速访问显示最近文件成功！', 5)
EndFunc   ;==>RemoveRegTweak18_3
Func RemoveRegTweak19()
	If @OSVersion <> 'WIN_2008R2' And @OSVersion <> 'WIN_2008' And @OSVersion <> 'WIN_2003' Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'EnableDiagnosticMode', 'REG_DWORD', '00000000')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'DisableOnSoftRemove')
		_ForceUpdate()
		MsgBox(0, '提示', '已经设置为弹出的USB设备继续供电！', 5)
	Else
	EndIf
EndFunc   ;==>RemoveRegTweak19

Func RestoreWin11NewStartMenu()
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_ShowClassicMode")
	_ForceUpdate()
	MsgBox(0, '提示', '已经恢复开始菜单为新版本样式！', 5)
EndFunc   ;==>RestoreWin11NewStartMenu
Func RemoveRegTweak21()
	If @OSBuild > 6000 Then
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation', 'DisableStartupSound')
		_ForceUpdate()
		MsgBox(0, '提示', '已经开启系统开机声音！', 5)
	Else
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000001')
		_ForceUpdate()
		MsgBox(0, '提示', '已经开启任务栏分组相似按钮！', 5)
	EndIf
EndFunc   ;==>RemoveRegTweak21
Func StartRegTweak()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	AddRegTweaks()
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	If $n > 0 Then
		_ForceUpdate()
		MsgBox(0, '友情提示', '您选择的' & $n & '个优化选项已经成功应用于当前系统,' & @LF & '部分优化需要重启后才能生效!', 5)
		$n = 0
	Else
		MsgBox(16, '错误', '请选择您要进行优化的项目！', 5)
		$n = 0
	EndIf
EndFunc   ;==>StartRegTweak
