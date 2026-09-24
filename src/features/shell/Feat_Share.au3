;==============================================================================
; 模块：共享与资源管理器
; 说明：一键共享开关、资源管理器目录管理、Win8.1 目录微调
; 文件：src\features\shell\Feat_Share.au3
; 函数：共 8 个
;==============================================================================
#include-once

Func OneKeySetShareUI()
	Global $FSetShare = _GUICreate("一键共享开关", 237, 45, 186, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("开启网络共享", 16, 8, 100, 25)
	GUICtrlSetOnEvent(-1, '_OpenShare')
	GUICtrlCreateButton("关闭网络共享", 129, 8, 100, 25)
	GUICtrlSetOnEvent(-1, '_CloseShare')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitFsetShare')
EndFunc   ;==>OneKeySetShareUI

Func _QuitFsetShare()
	_WinAPI_AnimateWindow($FSetShare, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FSetShare)
EndFunc   ;==>_QuitFsetShare

Func _OpenShare()
	Switch @OSVersion
		Case "WIN_2008R2" Or "WIN_7" Or "WIN_2008" Or "WIN_VISTA"
			Run(@ComSpec & ' /c  sc config nsi start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start nsi ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config DcomLaunch start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start DcomLaunch ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RpcEptMapper start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcEptMapper ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RpcSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SamSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SamSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lanmanworkstation start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lanmanworkstation ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dnscache start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dnscache ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dhcp start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dhcp ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config NlaSvc start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start NlaSvc ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config netprofm start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start netprofm ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config fdPHost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start fdPHost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config FDResPub start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start FDResPub ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config HomeGroupProvider start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start HomeGroupProvider ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config HomeGroupListener start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start HomeGroupListener ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Netman start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Netman ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lmhosts start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lmhosts ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Spooler start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Spooler ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SSDPSRV start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SSDPSRV ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config upnphost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start upnphost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh advfirewall set allprofiles state off ', @WindowsDir & '\', @SW_HIDE)
			ShareComm()
		Case "WIN_2003" Or "WIN_XP"
			Run(@ComSpec & ' /c  sc config RpcSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lanmanworkstation start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lanmanworkstation ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config PlugPlay start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start PlugPlay ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config TapiSrv start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start TapiSrv ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RasMan start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RasMan ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Netman start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Netman ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dnscache start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dnscache ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dhcp start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dhcp ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lmhosts start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lmhosts ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Nla start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Nla ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Spooler start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Spooler ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SSDPSRV start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SSDPSRV ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config upnphost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start upnphost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh firewall set opmode mode=disable ', @WindowsDir & '\', @SW_HIDE)
			ShareComm()
	EndSwitch
	MsgBox(0, '提示', '执行开启共享操作完成！！', 5)
EndFunc   ;==>_OpenShare
Func _CloseShare()
	Local $drive = DriveGetDrive("FIXED")
	Run(@ComSpec & ' /c net share admin$ /del', '', @SW_HIDE)
	Run(@ComSpec & ' /c net share IPC$ /del', '', @SW_HIDE)
	For $i In $drive
		If StringInStr($i, ':') Then
			Run(@ComSpec & ' /c net share ' & StringReplace($i, ':', '$') & ' /del', '', @SW_HIDE)
		EndIf
	Next
	Switch @OSVersion
		Case "WIN_2008R2" Or "WIN_7" Or "WIN_2008" Or "WIN_VISTA"
			Run(@ComSpec & ' /c  sc config HomeGroupListener start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop HomeGroupListener ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh advfirewall set allprofiles state on ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'restrictnullsessaccess', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server', 'fDenyTSConnections', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
		Case "WIN_2003" Or "WIN_XP"
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
			Run(@ComSpec & ' /c  sc config dfs start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop dfs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh firewall set opmode mode=enable ', @WindowsDir & '\', @SW_HIDE)
	EndSwitch
	MsgBox(0, '提示', '执行关闭共享操作完成！！', 5)
EndFunc   ;==>_CloseShare
;通用代码
Func ShareComm()
	FileInstall('src\file\ntrights.exe', @WindowsDir & '\', 1)
	Run(@ComSpec & ' /c  sc config ALG start= disabled ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net stop ALG ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net start w32time ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  w32tm /resync ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net user guest /active ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  Ntrights.exe -u Guest +r SeNetworkLogonRight ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  Ntrights.exe -u Guest -r SeDenyNetworkLogonRight ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net config server /hidden:no ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  regsvr32 /s atl.dll ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  regsvr32 /s netshell.dll ', @WindowsDir & '\', @SW_HIDE)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'forceguest', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'everyoneincludesanonymous', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'NoLmHash', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymoussam', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\System\CurrentControlSet\Services\LanManServer\Parameters', 'restrictnullsessaccess', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Browser\Parameters', 'MaintainServerList', 'REG_SZ', 'Auto')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Browser\Parameters', 'IsDomainMaster', 'REG_SZ', 'FALSE')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0', 'NtlmMinClientSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0', 'NtlmMinServerSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa\MSV1_0', 'NtlmMinClientSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa\MSV1_0', 'NtlmMinServerSec', 'REG_DWORD', '00000000')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{2227A280-3AEA-1069-A2DE-08002B30309D}')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{D6277990-4C6A-11CF-8D87-00AA0060F5BF}')
	If ProcessExists('ntrights.exe') Then Run(@ComSpec & ' /c tsakkill /f/im "ntrights.exe"', @WindowsDir, @SW_HIDE)
	FileDelete(@WindowsDir & '\ntrights.exe')
EndFunc   ;==>ShareComm

Func ExplorerDirManager()
	Global $FW81DirSet = _GUICreate('Windows X"这台电脑"文件夹一键设置', 349, 127, 130, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("操作类型", 8, 8, 121, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$win81dirOp[1] = _GUICtrlCreateRadio("移除", 16, 32, 47, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$win81dirOp[2] = _GUICtrlCreateRadio("恢复", 64, 32, 49, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("效果范围", 8, 64, 121, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$win81dirOp[3] = _GUICtrlCreateCheckbox("这台电脑", 13, 80, 105, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$win81dirOp[4] = _GUICtrlCreateCheckbox("导航窗口", 13, 99, 105, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("操作内容", 136, 8, 161, 81)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$W81Dir[1] = _GUICtrlCreateCheckbox("视频", 144, 24, 49, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[2] = _GUICtrlCreateCheckbox("图片", 200, 24, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[3] = _GUICtrlCreateCheckbox("文档", 144, 48, 49, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[4] = _GUICtrlCreateCheckbox("下载", 200, 48, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[5] = _GUICtrlCreateCheckbox("音乐", 248, 24, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[6] = _GUICtrlCreateCheckbox("桌面", 248, 48, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	If @OSBuild >= 16226 Then
		ReDim $W81Dir[UBound($W81Dir) + 1]
		$W81Dir[7] = _GUICtrlCreateCheckbox("3D对象", 144, 72, 57, 17)
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$selectW81ALL = _GUICtrlCreateRadio("全选", 304, 16, 41, 17)
	GUICtrlSetOnEvent($selectW81ALL, 'W81DirCheckAll')
	GUICtrlSetState(-1, $GUI_CHECKED)
	$ReverseSelcetW81 = _GUICtrlCreateRadio("反选", 304, 40, 41, 17)
	GUICtrlSetOnEvent($ReverseSelcetW81, 'W81Dirreverse')
	GUICtrlCreateButton("应用设置[&A]", 136, 96, 203, 26)
	GUICtrlSetOnEvent(-1, 'W81DirTweak')
;~ 	GUICtrlCreateButton("退出", 264, 64, 75, 25)
;~ 	GUICtrlSetOnEvent(-1, 'QuitDirForm')
	GUISetState(@SW_SHOW, $FW81DirSet)
	W81DirCheckAll()
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitDirForm', $FW81DirSet)
EndFunc   ;==>ExplorerDirManager

Func QuitDirForm()
	_WinAPI_AnimateWindow($FW81DirSet, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FW81DirSet)
EndFunc   ;==>QuitDirForm

Func W81DirTweak()
	If MsgBox(4, '提示', '是否应用当前勾选设置项？', 5) = 6 Then
		Local $aReg[2] = ["HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace", "HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"]
		Local $aRegWin10[2] = ['HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions', 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions']
		Local $aNameSpaceStr[6] = ["{A0953C92-50DC-43bf-BE83-3742FED03C9C}", "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}", "{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}", "{374DE290-123F-4565-9164-39C4925E467B}", "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}", "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"]
		Local $aNamespaceWin10Str[7] = ['{35286a68-3c57-41a1-bbb1-0eae73d76c95}', '{0ddd015d-b06c-45d5-8c4c-f59713854639}', '{f42ee2d3-909f-4907-8871-4c22fc0bf756}', '{7d83ee9b-2244-4e70-b1f5-5393042af1e4}', '{a0c69a99-21c8-4671-8703-7934162fcf1d}', '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}', '{31C0DD25-9439-4F12-BF41-7FF4EDA38722}']
		;隐藏
		If GUICtrlRead($win81dirOp[1]) = $GUI_CHECKED Then
			For $j = 1 To @OSBuild >= 16226 ? 7 : 6
				If GUICtrlRead($W81Dir[$j]) = $GUI_CHECKED Then
					If @OSVersion = 'WIN_81' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegDelete($aReg[0] & '\' & $aNameSpaceStr[$j - 1])
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegDelete($aReg[1] & '\' & $aNameSpaceStr[$j - 1])
					EndIf
					If @OSVersion = 'WIN_10' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aRegWin10[0] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Hide')
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aRegWin10[1] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Hide')

					EndIf
				EndIf
			Next
		EndIf
		;显示
		If GUICtrlRead($win81dirOp[2]) = $GUI_CHECKED Then
			For $j = 1 To @OSBuild >= 16232 ? 7 : 6
				If GUICtrlRead($W81Dir[$j]) = $GUI_CHECKED Then
					If @OSVersion = 'WIN_81' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aReg[0] & '\' & $aNameSpaceStr[$j - 1])
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aReg[1] & '\' & $aNameSpaceStr[$j - 1])
					EndIf
					If @OSVersion = 'WIN_10' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aRegWin10[0] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Show')
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aRegWin10[1] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Show')
					EndIf
				EndIf
			Next
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '所选设定已经成功应用到当前系统', 5)
	EndIf
EndFunc   ;==>W81DirTweak
