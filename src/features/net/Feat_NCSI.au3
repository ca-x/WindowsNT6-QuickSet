;==============================================================================
; 模块：NCSI 服务器设置
; 说明：微软/火狐/Debian NCSI 探测服务器切换
; 文件：src\features\net\Feat_NCSI.au3
; 函数：共 6 个
;==============================================================================
#include-once



Func NCSIServerUI()
	Global $FormNCSIServerForm = _GUICreate("windows NCSI服务器设置", 351, 123, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择NCSI服务器", 16, 8, 273, 65)
	_removeEffect()
	Global $OptMicroSoft = GUICtrlCreateRadio("microsoft", 32, 32, 65, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $OptDebian = GUICtrlCreateRadio("debian", 120, 32, 65, 17)
	Global $OptFirefox = GUICtrlCreateRadio("firefox", 208, 32, 65, 17)
	GUICtrlCreateButton("设置NCSI服务器", 48, 80, 211, 25)
	GUICtrlSetOnEvent(-1, 'ApplyNCSISetting')
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitNCSIUI')
EndFunc   ;==>NCSIServerUI

Func ApplyNCSISetting()
	If GUICtrlRead($OptMicroSoft) = $GUI_CHECKED Then
		microsoftNCSI()
	EndIf
	If GUICtrlRead($OptDebian) = $GUI_CHECKED Then
		debianNCSI()
	EndIf
	If GUICtrlRead($OptFirefox) = $GUI_CHECKED Then
		firefoxNCSI()
	EndIf

EndFunc   ;==>ApplyNCSISetting

Func debianNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "208.67.222.222")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "2620:119:35::35")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "NetworkManager is online")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "NetworkManager is online")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "network-test.debian.org")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "network-test.debian.org")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "nm")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "nm")
	MsgBox(0, '提示', '所选Debian NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>debianNCSI

Func microsoftNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "131.107.255.255")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "fd3e:4f5a:5b81::1")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "dns.msftncsi.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "dns.msftncsi.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "Microsoft Connect Test")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "Microsoft Connect Test")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "www.msftconnecttest.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "ipv6.msftconnecttest.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "connecttest.txt")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "connecttest.txt")
	MsgBox(0, '提示', '所选Microsoft NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>microsoftNCSI

Func firefoxNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "208.67.222.222")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "2620:119:35::35")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "success")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "success")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "detectportal.firefox.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "detectportal.firefox.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "success.txt")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "success.txt")
	MsgBox(0, '提示', '所选Firefox NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>firefoxNCSI

Func QuitNCSIUI()
	_WinAPI_AnimateWindow($FormNCSIServerForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($OptMicroSoft)
	GUIDelete($OptFirefox)
	GUIDelete($OptDebian)
EndFunc   ;==>QuitNCSIUI
