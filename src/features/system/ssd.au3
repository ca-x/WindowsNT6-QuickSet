;==============================================================================
; 模块：SSD 优化
; 说明：SSD 节能、预读、休眠、系统还原、NTFS Journal 等开关
; 文件：src\features\system\ssd.au3
; 函数：共 25 个
;==============================================================================
#include-once


Func TurnOffSSD_SE()
	Local $CpuType = _CPUType()
	If StringInStr($CpuType, 'intel') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'DIPM', 'REG_DWORD', '00000000')
	EndIf
	If StringInStr($CpuType, 'amd') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableALPEDisableHotplug', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableCCC', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CCCTimeoutValue', 'REG_DWORD', '0000000a')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CCCCompletionValue', 'REG_DWORD', '00000020')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'NCQEnableDiskIDBits', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableHIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableDIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableHDDParking', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CAMTimeOutValue', 'REG_DWORD', '00000005')
	EndIf
EndFunc   ;==>TurnOffSSD_SE
;关闭预读取
Func TurnOffPrefetch()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableSuperfetch', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000000')
EndFunc   ;==>TurnOffPrefetch
;关闭启动跟踪
Func TurnOffBoottrace()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000000')
EndFunc   ;==>TurnOffBoottrace
Func TurnOnBoottrace()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000001')
	MsgBox(0, '提示', '已经开启启动跟踪功能！', 5)
EndFunc   ;==>TurnOnBoottrace
Func TurnOffJournal()
	RunWait('fsutil usn deletejournal /n ' & @HomeDrive, @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffJournal
Func TurnOffcheckdiskOnBoot()
	;启动时不整理磁盘
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'N')
EndFunc   ;==>TurnOffcheckdiskOnBoot
Func TurnOncheckdiskOnBoot()
	;启动时整理磁盘
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'Y')
	MsgBox(0, '提示', '已经设置系统启动时整理磁盘！', 5)
EndFunc   ;==>TurnOncheckdiskOnBoot
Func removefeedbacktool()
	;去除feedbacktool
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'FeedbackToolEnabled', 'REG_DWORD', '00000000')
EndFunc   ;==>removefeedbacktool
Func turnOffsysRestore()
	;关闭系统还原功能
	RunWait(@ComSpec & ' /c net stop WindowsBackup ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WindowsBackup start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>turnOffsysRestore
Func turnOnsysRestore()
	;开启系统还原功能
	RunWait(@ComSpec & ' /c net start WindowsBackup ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WindowsBackup start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启系统还原功能！', 5)
EndFunc   ;==>turnOnsysRestore
Func TurnOffSysHy()
	;关闭休眠功能
	RunWait(@ComSpec & ' /c powercfg -h off', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffSysHy
Func TurnOnSysHy()
	;开启休眠功能
	RunWait(@ComSpec & ' /c powercfg -h on', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启系统休眠功能！', 5)
EndFunc   ;==>TurnOnSysHy
Func TurnOffLastAccess()
	;关闭最后时间访问
	RunWait('fsutil behavior set disablelastaccess 1', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffLastAccess
Func TurnOnLastAccess()
	;开启最后时间访问
	RunWait('fsutil behavior set disablelastaccess 0', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启文件最后访问时间！', 5)
EndFunc   ;==>TurnOnLastAccess
Func TurnOffDos83()
	RunWait('fsutil behavior set disable8dot3 1', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffDos83
Func TurnOnDos83()
	RunWait('fsutil behavior set disable8dot3 0', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启DOS 8.3文件名支持！', 5)
EndFunc   ;==>TurnOnDos83
Func TurnOffWinsearch()
	RunWait(@ComSpec & ' /c net stop WSearch ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WSearch start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffWinsearch
Func TurnOnWinsearch()
	RunWait(@ComSpec & ' /c net start WSearch ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WSearch start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启WindowsSearch服务！', 5)
EndFunc   ;==>TurnOnWinsearch
;关机时不清除页面文件
Func NotClearPFileOnOff()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'clearPageFilesAtShutdown', 'REG_DWORD', '0')
EndFunc   ;==>NotClearPFileOnOff
Func ClearPFileOnOff()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'clearPageFilesAtShutdown', 'REG_DWORD', '1')
	MsgBox(0, '提示', '已经设置关机时清空页面文件！', 5)
EndFunc   ;==>ClearPFileOnOff
Func DisGUIBoot()
	RunWait(@ComSpec & ' /c bcdedit /set {current} quietboot Yes', @WindowsDir, @SW_HIDE)
EndFunc   ;==>DisGUIBoot
Func EnGUIBoot()
	RunWait(@ComSpec & ' /c bcdedit /deletevalue {current} quietboot', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经还原系统设置为GUI引导方式！', 5)
EndFunc   ;==>EnGUIBoot
;关闭磁盘整理服务
Func TurnOffdefrag()
	RunWait(@ComSpec & ' /c net stop defragsvc ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config defragsvc start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffdefrag
Func TurnOndefrag()
	RunWait(@ComSpec & ' /c net start defragsvc ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config defragsvc start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经设置磁盘整理服务为自动启动！', 5)
EndFunc   ;==>TurnOndefrag
Func SSDTweaksApply()
	If $HasSSD Then
		Local $SeletedCount = 0
		For $i = 1 To 14
			If GUICtrlRead($SSDbox[$i]) = $GUI_CHECKED Then
				$SeletedCount += 1
			EndIf
		Next
		If $SeletedCount > 0 Then
			Local $percent = 100 / $SeletedCount
			_GUIDisable($Form1, 1, 45, 0x51D0F7)
			_DisableTrayMenu()
			GUISetState(@SW_SHOW, $LoadingUI)
			Local $i = 0
			If GUICtrlRead($SSDbox[1]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭SSD节能功能..'
				$percent += $percent
				TurnOffSSD_SE()
			EndIf
			If GUICtrlRead($SSDbox[2]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭预读取..'
				$percent += $percent
				TurnOffPrefetch()
			EndIf
			If GUICtrlRead($SSDbox[3]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭SSD启动跟踪功能..'
				$percent += $percent
				TurnOffBoottrace()
			EndIf
			If GUICtrlRead($SSDbox[4]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭NTFS Journal功能..'
				$percent += $percent
				TurnOffJournal()
			EndIf
			If GUICtrlRead($SSDbox[5]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置启动时不整理磁盘..'
				$percent += $percent
				TurnOffcheckdiskOnBoot()
			EndIf
			If GUICtrlRead($SSDbox[6]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在移除Feedbacktool..'
				$percent += $percent
				removefeedbacktool()
			EndIf
			If GUICtrlRead($SSDbox[7]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭系统还原功能..'
				$percent += $percent
				turnOffsysRestore()
			EndIf
			If GUICtrlRead($SSDbox[8]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭系统休眠功能..'
				$percent += $percent
				TurnOffSysHy()
			EndIf
			If GUICtrlRead($SSDbox[9]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭文件最后访问时间功能..'
				$percent += $percent
				TurnOffLastAccess()
			EndIf
			If GUICtrlRead($SSDbox[10]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在移除系统DOS8.3文件格式支持功能..'
				$percent += $percent
				TurnOffDos83()
			EndIf
			If GUICtrlRead($SSDbox[11]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭Windows Search功能..'
				$percent += $percent
				TurnOffWinsearch()
			EndIf
			If GUICtrlRead($SSDbox[12]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置关机时不清空页面文件..'
				$percent += $percent
				NotClearPFileOnOff()
			EndIf
			If GUICtrlRead($SSDbox[13]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置当前系统无GUI引导..'
				$percent += $percent
				DisGUIBoot()
			EndIf
			If GUICtrlRead($SSDbox[14]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭磁盘碎片整理功能..'
				$percent += $percent
				TurnOffdefrag()
			EndIf
			GUISetState(@SW_HIDE, $LoadingUI)
			_GUIDisable($Form1, 0)
			_EnableTrayMenu()
			$aText = '正在处理，请稍后'
			_ForceUpdate()
			MsgBox(0, '提示', '已经将' & $i & '个优化项成功应用于当前系统！', 6)
		Else
			MsgBox(16, '错误', '未选择优化项目！', 5)
		EndIf
	EndIf
EndFunc   ;==>SSDTweaksApply
