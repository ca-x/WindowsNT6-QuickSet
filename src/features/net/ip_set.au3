;==============================================================================
; 模块：IP 地址设置
; 说明：IP/DNS 静态与自动获取设置、方案管理、DNS 列表
; 文件：src\features\net\ip_set.au3
; 函数：共 18 个
;==============================================================================
#include-once



;========================================================================================
; Ip设置什么的
;========================================================================================
;Dlg
Func IpSetDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $ShareandIp = _GUICreate("IP地址设置", 370, 219, 120, 50, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("网络设置", 8, 0, 353, 209)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("IP地址：", 24, 24, 50, 17)
	GUICtrlCreateLabel("子网掩码：", 24, 48, 64, 17)
	GUICtrlCreateLabel("默认网关：", 24, 72, 64, 17)
	Global $zDNs = GUICtrlCreateLabel("主DNS：", 24, 128, 72, 17)
	Global $IPAddress = _GUICtrlIpAddress_Create($ShareandIp, 96, 24, 130, 21)
	Global $zmym = _GUICtrlIpAddress_Create($ShareandIp, 96, 48, 130, 21)
	Global $GateWay = _GUICtrlIpAddress_Create($ShareandIp, 96, 72, 130, 21)
	Global $FirstDns = _GUICtrlIpAddress_Create($ShareandIp, 96, 128, 130, 21)
	_GUICtrlIpAddress_Set($FirstDns, "0.0.0.0")
	Global $BakDns = _GUICtrlIpAddress_Create($ShareandIp, 96, 152, 130, 21)
	_GUICtrlIpAddress_Set($BakDns, "0.0.0.0")
	Global $DNS = GUICtrlCreateCombo("", 96, 96, 129, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetOnEvent(-1, 'LoadDNS')
	Global $DIDNS = _GUICtrlCreateCheckbox("自定DNS", 16, 169, 81, 17)
	GUICtrlSetOnEvent(-1, '_DIUseSpecifyDNS')
	$IpSetDlg[1] = _GUICtrlCreateRadio("使用DHCP", 16, 184, 81, 17)
	GUICtrlSetTip($IpSetDlg[1], "勾选此选项将使计算机使用DHCP" & @LF & "来自动获取IP地址以及DNS地址", '说明', 1)
	GUICtrlSetOnEvent($IpSetDlg[1], '_ToogleIPControl')
	$IpSetDlg[2] = _GUICtrlCreateRadio("设置静态IP", 104, 184, 97, 17)
	GUICtrlSetTip($IpSetDlg[2], "勾选此选项将设置计" & @LF & "算机为静态IP地址！", '说明', 1)
	GUICtrlSetOnEvent($IpSetDlg[2], '_ToogleIPControl')
	GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
	GUICtrlCreateGroup("DNS线路", 242, 25, 85, 60)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$IpSetDlg[3] = _GUICtrlCreateRadio("电信线路", 248, 40, 73, 17)
	GUICtrlSetState($IpSetDlg[3], $GUI_CHECKED)
	GUICtrlSetOnEvent($IpSetDlg[3], 'ChooseLine')
	$IpSetDlg[4] = _GUICtrlCreateRadio("网通线路", 248, 64, 73, 17)
	GUICtrlSetOnEvent($IpSetDlg[4], 'ChooseLine')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateLabel("设置DNS", 40, 96, 51, 17)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $fDNs = GUICtrlCreateLabel("辅DNS：", 24, 152, 72, 17)
	Global $NetApt = GUICtrlCreateCombo("", 232, 143, 121, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetTip(-1, "请选择正在使用的网络！" & @LF & "否则可能不生效！", '提示', 2)
	GUICtrlSetData(-1, $AdapterList[1][5])
	GUICtrlSetOnEvent(-1, '_LoadSpecifecInterfaceInfo')
	GUICtrlCreateLabel("请选择目标网络名称", 235, 128, 112, 15)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("IP地址方案", 240, 88, 89, 38)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $IpProjName = GUICtrlCreateLabel("无方案", 248, 104, 68, 17)
	GUICtrlSetColor(-1, 0x3399FF)
	GUICtrlSetTip(-1, "请点击此处以新建、编辑或" & @LF & "删除IP切换方案！", '提示', 1)
	GUICtrlSetOnEvent(-1, '_ManageIPPrjUI')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("设置", 230, 168, 67, 33)
	GUICtrlSetOnEvent(-1, 'SetIPS')
	GUICtrlCreateButton("关闭", 305, 168, 50, 33)
	GUICtrlSetOnEvent(-1, 'QuitIpSetTool')
	PrepDNS()
	LoadDNS()
	_loadNetInterface()
	_LoadSpecifecInterfaceInfo()
	_GUICtrlIpAddress_Disable($IPAddress, 0xf)
	_GUICtrlIpAddress_Disable($zmym, 0xf)
	_GUICtrlIpAddress_Disable($GateWay, 0xf)
	_GUICtrlIpAddress_Disable($FirstDns, 0xf)
	_GUICtrlIpAddress_Disable($BakDns, 0xf)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitIpSetTool')
EndFunc   ;==>IpSetDlg
Func _ToogleIPControl()
	If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
		;dhcp
		_GUICtrlIpAddress_Disable($IPAddress, 0xf)
		_GUICtrlIpAddress_Disable($zmym, 0xf)
		_GUICtrlIpAddress_Disable($GateWay, 0xf)
		_GUICtrlIpAddress_Disable($FirstDns, 0xf)
		_GUICtrlIpAddress_Disable($BakDns, 0xf)
		GUICtrlSetState($DNS, $GUI_DISABLE)
		GUICtrlSetState($DIDNS, $GUI_UNCHECKED)
		GUICtrlSetState($DIDNS, $GUI_ENABLE)
	Else
		_GUICtrlIpAddress_Disable($IPAddress)
		_GUICtrlIpAddress_Disable($zmym)
		_GUICtrlIpAddress_Disable($GateWay)
		_GUICtrlIpAddress_Disable($FirstDns)
		_GUICtrlIpAddress_Disable($BakDns)
		GUICtrlSetState($DNS, $GUI_ENABLE)
		GUICtrlSetState($DIDNS, $GUI_CHECKED)
		GUICtrlSetState($DIDNS, $GUI_DISABLE)
		;static
	EndIf
EndFunc   ;==>_ToogleIPControl
Func _DIUseSpecifyDNS()
	;设置DHCP 勾选进行切换
	;设置静态IP 无任何操作，切自动勾选DNS
	If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
		If GUICtrlRead($DIDNS) = $GUI_CHECKED Then
			_GUICtrlIpAddress_Disable($FirstDns)
			_GUICtrlIpAddress_Disable($BakDns)
			GUICtrlSetState($DNS, $GUI_ENABLE)
		Else
			_GUICtrlIpAddress_Disable($FirstDns, 0xf)
			_GUICtrlIpAddress_Disable($BakDns, 0xf)
			GUICtrlSetState($DNS, $GUI_DISABLE)
		EndIf
	EndIf
EndFunc   ;==>_DIUseSpecifyDNS
Func QuitIpSetTool()
	_WinAPI_AnimateWindow($ShareandIp, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($ShareandIp)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitIpSetTool
Func _ManageIPPrjUI()
	GUISetState(@SW_HIDE, $ShareandIp)
	Global $GManageIP = _GUICreate("IP地址方案维护", 248, 326, 180, 10, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择IP地址方案", 8, 8, 225, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $LName = GUICtrlCreateCombo("", 16, 24, 145, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetOnEvent(-1, '_LoadIpSet')
	GUICtrlCreateButton("+", 168, 24, 27, 25)
	GUICtrlSetTip(-1, '点击此按钮来新增一个IP地址方案', '提示', 1)
	GUICtrlSetOnEvent(-1, '_AddIpSet')
	GUICtrlCreateButton("-", 196, 24, 27, 25)
	GUICtrlSetTip(-1, '点击此按钮来删除一个IP地址方案', '提示', 1)
	GUICtrlSetOnEvent(-1, '_DelIPSet')
	GUICtrlCreateGroup("方案详情", 8, 64, 225, 225)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("方案名称", 16, 88, 52, 17)
	Global $GProjName = GUICtrlCreateInput("", 88, 88, 129, 21)
	GUICtrlCreateLabel("IP地址", 16, 120, 38, 17)
	Global $GIPAdress = _GUICtrlIpAddress_Create($GManageIP, 88, 120, 130, 21)
	_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
	GUICtrlCreateLabel("子网掩码", 16, 152, 52, 17)
	Global $GSubMask = _GUICtrlIpAddress_Create($GManageIP, 88, 152, 130, 21)
	_GUICtrlIpAddress_Set($GSubMask, "0.0.0.0")
	GUICtrlCreateLabel("默认网关", 16, 184, 52, 17)
	Global $GDefaultGateway = _GUICtrlIpAddress_Create($GManageIP, 88, 184, 130, 21)
	_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
	GUICtrlCreateLabel("首选DNS", 16, 216, 51, 17)
	Global $GDNS1 = _GUICtrlIpAddress_Create($GManageIP, 88, 216, 130, 21)
	_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
	GUICtrlCreateLabel("备用DNS", 16, 248, 51, 17)
	Global $GDNS2 = _GUICtrlIpAddress_Create($GManageIP, 88, 248, 130, 21)
	_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
	GUICtrlCreateButton("保存方案", 8, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_SaveIPSet')
	GUICtrlCreateButton("选定方案", 83, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_SelectIPSet')
	GUICtrlCreateButton("取消", 156, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_QuitManageIPUI')
	GUISetState(@SW_SHOW)
	_InitIpSetData()
	_loadIpsetNameToCombo()
	_LoadIpSet()
	_CleanZeroSizeFile()
	If $IPdataNotInit = True Then MsgBox(0, '提示', '未能正确加载IP设置方案，请检查' & @LF & 'IPSetData.ini文件内容！', 5)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitManageIPUI')
EndFunc   ;==>_ManageIPPrjUI
Func _QuitManageIPUI()
	GUISetState(@SW_SHOW, $ShareandIp)
	_WinAPI_AnimateWindow($GManageIP, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($GManageIP)
EndFunc   ;==>_QuitManageIPUI
Func _CleanZeroSizeFile()
	If FileExists($iniFile) And FileGetSize($iniFile) = 0 Then
		FileDelete($iniFile)
	EndIf
EndFunc   ;==>_CleanZeroSizeFile
Func _InitIpSetData()
	$IpSetStr = ''
	;0-方案名称;1-IP地址;2-子网掩码;3-默认网关;4-主DNS;5-辅DNS;6-序列
	$aSectionNames = IniReadSectionNames($iniFile)
	If Not @error Then
		Global $aIpSetData[$aSectionNames[0]][7]
		For $i = 0 To $aSectionNames[0] - 1
			$aIpSetData[$i][0] = $aSectionNames[$i + 1]
			$IpSetStr &= $aSectionNames[$i + 1] & '|'
			;IP地址
			$aIpSetData[$i][1] = IniRead($iniFile, $aSectionNames[$i + 1], 'IP', '0.0.0.0')
			;SubMask
			$aIpSetData[$i][2] = IniRead($iniFile, $aSectionNames[$i + 1], 'SubMask', '0.0.0.0')
			;DefaultGateWay
			$aIpSetData[$i][3] = IniRead($iniFile, $aSectionNames[$i + 1], 'DefaultGateWay', '0.0.0.0')
			;DNS1
			$aIpSetData[$i][4] = IniRead($iniFile, $aSectionNames[$i + 1], 'DNS1', '0.0.0.0')
			;DNS2
			$aIpSetData[$i][5] = IniRead($iniFile, $aSectionNames[$i + 1], 'DNS2', '0.0.0.0')
			;序列
			$aIpSetData[$i][6] = $i
		Next
		$IPdataNotInit = False
	Else
		$IPdataNotInit = True
	EndIf
EndFunc   ;==>_InitIpSetData
;加载所有方案到选框
Func _loadIpsetNameToCombo()
	If $IpSetStr <> '' Then
		Local $z = ''
		If StringInStr($IpSetStr, '|') Then
			Local $aTemp = StringSplit($IpSetStr, '|')
			If IsArray($aTemp) And Not @error Then
				$z = $aTemp[1]
			EndIf
			GUICtrlSetData($LName, $IpSetStr, $z)
		Else
			GUICtrlSetData($LName, $IpSetStr)
		EndIf
	EndIf
EndFunc   ;==>_loadIpsetNameToCombo
;加载指定的方案到界面显示
Func _LoadIpSet()
	If $IPdataNotInit = False Then
		Local $Index
		For $i = 0 To UBound($aIpSetData) - 1
			If GUICtrlRead($LName) = $aIpSetData[$i][0] Then
				$Index = $i
				ExitLoop
			EndIf
		Next
		GUICtrlSetData($GProjName, $aIpSetData[$Index][0])
		_GUICtrlIpAddress_Set($GIPAdress, $aIpSetData[$Index][1])
		_GUICtrlIpAddress_Set($GSubMask, $aIpSetData[$Index][2])
		_GUICtrlIpAddress_Set($GDefaultGateway, $aIpSetData[$Index][3])
		_GUICtrlIpAddress_Set($GDNS1, $aIpSetData[$Index][4])
		_GUICtrlIpAddress_Set($GDNS2, $aIpSetData[$Index][5])
	EndIf
EndFunc   ;==>_LoadIpSet
;新建IP设置方案
Func _AddIpSet()
	GUICtrlSetData($GProjName, '新建IP设置方案[' & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ']')
	;清理先前加载配置
	_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
	_GUICtrlIpAddress_Set($GSubMask, "255.255.255.0")
	_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
	_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
	_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
EndFunc   ;==>_AddIpSet
;删除IP设置方案
Func _DelIPSet()
	If GUICtrlRead($LName) <> '' Then
		If MsgBox(4, '提示', '是否删除IP设置方案[' & GUICtrlRead($LName) & ']?', 8) = 6 Then
			GUICtrlSetData($GProjName, '')
			_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
			_GUICtrlIpAddress_Set($GSubMask, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
			IniDelete($iniFile, GUICtrlRead($LName))
			MsgBox(0, '提示', 'IP设置方案[' & GUICtrlRead($LName) & ']删除成功！', 5)
			GUICtrlSetData($LName, '')
			_InitIpSetData()
			_loadIpsetNameToCombo()
			_LoadIpSet()
		EndIf
	Else
		MsgBox(0, '提示', '没有可供删除的IP设置方案！', 5)
	EndIf
	_CleanZeroSizeFile()
EndFunc   ;==>_DelIPSet
;保存IP地址方案，对ini文件进行相应的更新
Func _SaveIPSet()
	If MsgBox(4, '提示', '是否将当前正在编辑的IP设置方案保存为[' & GUICtrlRead($GProjName) & ']?', 8) = 6 Then
		Local $SectionName = GUICtrlRead($GProjName)
		Local $IsNameExist = False
		If FileExists($iniFile) And $IPdataNotInit = False Then
			_InitIpSetData()
			For $i = 0 To UBound($aIpSetData) - 1
				If $aIpSetData[$i][0] = $SectionName Then
					$IsNameExist = True
					MsgBox(16, '错误', '已经存在同名的IP设置方案！', 5)
					ExitLoop
				EndIf
			Next
		EndIf
		If $IsNameExist = False Then
			IniWrite($iniFile, $SectionName, 'IP', _GUICtrlIpAddress_Get($GIPAdress))
			IniWrite($iniFile, $SectionName, 'SubMask', _GUICtrlIpAddress_Get($GSubMask))
			IniWrite($iniFile, $SectionName, 'DefaultGateWay', _GUICtrlIpAddress_Get($GDefaultGateway))
			IniWrite($iniFile, $SectionName, 'DNS1', _GUICtrlIpAddress_Get($GDNS1))
			IniWrite($iniFile, $SectionName, 'DNS2', _GUICtrlIpAddress_Get($GDNS2))
			GUICtrlSetData($LName, '')
			_InitIpSetData()
			_loadIpsetNameToCombo()
			_LoadIpSet()
		EndIf
	EndIf
	_CleanZeroSizeFile()
EndFunc   ;==>_SaveIPSet

Func _SelectIPSet()
	_LoadIpSet()
	_GUICtrlIpAddress_Set($IPAddress, _GUICtrlIpAddress_Get($GIPAdress))
	_GUICtrlIpAddress_Set($zmym, _GUICtrlIpAddress_Get($GSubMask))
	_GUICtrlIpAddress_Set($GateWay, _GUICtrlIpAddress_Get($GDefaultGateway))
	_GUICtrlIpAddress_Set($FirstDns, _GUICtrlIpAddress_Get($GDNS1))
	_GUICtrlIpAddress_Set($BakDns, _GUICtrlIpAddress_Get($GDNS2))
	GUICtrlSetData($IpProjName, GUICtrlRead($GProjName))
	GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
	If $IPdataNotInit = True Then
		GUICtrlSetData($IpProjName, '无方案')
		_LoadSpecifecInterfaceInfo()
	EndIf
	_QuitManageIPUI()
	_CleanZeroSizeFile()
EndFunc   ;==>_SelectIPSet
Func PrepDNS()
	Global $aDns[2][47][3]
	;电信DNS
	$aDns[0][0][0] = '本地DNS'
	$aDns[0][0][1] = '0.0.0.0'
	$aDns[0][0][2] = '0.0.0.0'
	$aDns[0][1][0] = "北京DNS"
	$aDns[0][1][1] = "202.96.199.133"
	$aDns[0][1][2] = "202.96.0.133"
	$aDns[0][10][0] = "湖南DNS"
	$aDns[0][10][1] = "202.103.0.68"
	$aDns[0][10][2] = "202.103.96.68"
	$aDns[0][11][0] = "江苏DNS"
	$aDns[0][11][1] = "202.102.15.162"
	$aDns[0][11][2] = "202.102.29.3"
	$aDns[0][12][0] = "陕西DNS"
	$aDns[0][12][1] = "202.100.13.11"
	$aDns[0][12][2] = "202.100.4.16"
	$aDns[0][13][0] = "西安DNS"
	$aDns[0][13][1] = "202.100.4.15"
	$aDns[0][13][2] = "202.100.0.68"
	$aDns[0][14][0] = "湖北DNS"
	$aDns[0][14][1] = "202.103.0.68"
	$aDns[0][14][2] = "202.103.0.117"
	$aDns[0][15][0] = "山东DNS"
	$aDns[0][15][1] = "202.102.154.3"
	$aDns[0][15][2] = "202.102.152.3"
	$aDns[0][16][0] = "浙江DNS"
	$aDns[0][16][1] = "202.96.102.3"
	$aDns[0][16][2] = "202.96.104.18"
	$aDns[0][17][0] = "辽宁DNS"
	$aDns[0][17][1] = "219.149.6.99"
	$aDns[0][17][2] = "219.148.204.66"
	$aDns[0][18][0] = "安徽DNS"
	$aDns[0][18][1] = "202.102.192.68"
	$aDns[0][18][2] = "202.102.199.68"
	$aDns[0][19][0] = "重庆DNS"
	$aDns[0][19][1] = "61.128.128.68"
	$aDns[0][19][2] = "10.150.0.1"
	$aDns[0][2][0] = "上海DNS"
	$aDns[0][2][1] = "202.96.199.132"
	$aDns[0][2][2] = "202.96.199.133"
	$aDns[0][20][0] = "黑龙江DNS"
	$aDns[0][20][1] = "202.97.229.133"
	$aDns[0][20][2] = "202.97.224.68"
	$aDns[0][21][0] = "河北DNS"
	$aDns[0][21][1] = "222.222.202.202"
	$aDns[0][21][2] = "222.222.222.222"
	$aDns[0][22][0] = "保定DNS"
	$aDns[0][22][1] = "202.99.160.68"
	$aDns[0][22][2] = "202.99.166.4"
	$aDns[0][23][0] = "吉林DNS"
	$aDns[0][23][1] = "202.98.14.18"
	$aDns[0][23][2] = "202.98.14.19"
	$aDns[0][24][0] = "江西DNS"
	$aDns[0][24][1] = "202.101.224.68"
	$aDns[0][24][2] = "202.101.240.36"
	$aDns[0][25][0] = "山西DNS"
	$aDns[0][25][1] = "202.99.192.68"
	$aDns[0][25][2] = "202.99.198.6"
	$aDns[0][26][0] = "新疆DNS"
	$aDns[0][26][1] = "61.128.99.133"
	$aDns[0][26][2] = "61.128.99.134"
	$aDns[0][27][0] = "贵州DNS"
	$aDns[0][27][1] = "202.98.192.68"
	$aDns[0][27][2] = "10.157.2.15"
	$aDns[0][28][0] = "云南DNS"
	$aDns[0][28][1] = "202.98.96.68"
	$aDns[0][28][2] = "202.98.160.68"
	$aDns[0][29][0] = "四川DNS"
	$aDns[0][29][1] = "202.98.96.68"
	$aDns[0][29][2] = "61.139.2.69"
	$aDns[0][3][0] = "天津DNS"
	$aDns[0][3][1] = "202.99.96.68"
	$aDns[0][3][2] = "10.10.64.68"
	$aDns[0][30][0] = "重庆DNS"
	$aDns[0][30][1] = "61.128.128.68"
	$aDns[0][30][2] = "61.128.192.4"
	$aDns[0][31][0] = "成都DNS"
	$aDns[0][31][1] = "202.98.96.68"
	$aDns[0][31][2] = "202.98.96.69"
	$aDns[0][32][0] = "内蒙古DNS"
	$aDns[0][32][1] = "222.74.1.200"
	$aDns[0][32][2] = "10.29.0.2"
	$aDns[0][33][0] = "青海DNS"
	$aDns[0][33][1] = "202.100.128.68"
	$aDns[0][33][2] = "10.184.0.1"
	$aDns[0][34][0] = "海南DNS"
	$aDns[0][34][1] = "202.100.192.68"
	$aDns[0][34][2] = "202.100.199.8"
	$aDns[0][35][0] = "宁夏DNS"
	$aDns[0][35][1] = "202.100.0.68"
	$aDns[0][35][2] = "202.100.96.68"
	$aDns[0][36][0] = "甘肃DNS"
	$aDns[0][36][1] = "202.100.72.13"
	$aDns[0][36][2] = "10.179.64.1"
	$aDns[0][37][0] = "香港DNS"
	$aDns[0][37][1] = "205.252.144.126"
	$aDns[0][37][2] = "218.102.62.71"
	$aDns[0][38][0] = "澳门DNS"
	$aDns[0][38][1] = "202.175.3.8"
	$aDns[0][38][2] = "202.175.3.3"
	$aDns[0][39][0] = "谷歌DNS"
	$aDns[0][39][1] = "8.8.8.8"
	$aDns[0][39][2] = "8.8.4.4"
	$aDns[0][4][0] = "广东DNS"
	$aDns[0][4][1] = "202.96.128.143"
	$aDns[0][4][2] = "202.96.128.68"
	$aDns[0][40][0] = "阿里公共DNS"
	$aDns[0][40][1] = "223.5.5.5"
	$aDns[0][40][2] = "223.6.6.6"
	$aDns[0][41][0] = "百度公共DNS"
	$aDns[0][41][1] = "180.76.76.76"
	$aDns[0][41][2] = "114.114.114.114"
	$aDns[0][42][0] = "OpenDNS"
	$aDns[0][42][1] = "208.67.222.222"
	$aDns[0][42][2] = "208.67.220.220Norton DNS"
	$aDns[0][43][0] = "OpenDNS Family"
	$aDns[0][43][1] = "208.67.222.123"
	$aDns[0][43][2] = "208.67.220.123"
	$aDns[0][44][0] = "Comodo Secure DNS"
	$aDns[0][44][1] = "156.154.70.22"
	$aDns[0][44][2] = "156.154.71.22"
	$aDns[0][45][0] = "ScrubIt DNS"
	$aDns[0][45][1] = "67.138.54.100"
	$aDns[0][45][2] = "207.225.209.66"
	$aDns[0][46][0] = "DNS Advantage"
	$aDns[0][46][1] = "156.154.70.1"
	$aDns[0][46][2] = "156.154.71.1"
	$aDns[0][5][0] = "深圳DNS"
	$aDns[0][5][1] = "202.96.134.133"
	$aDns[0][5][2] = "202.96.154.8"
	$aDns[0][6][0] = "河南DNS"
	$aDns[0][6][1] = "202.102.227.68"
	$aDns[0][6][2] = "202.102.224.68"
	$aDns[0][7][0] = "广西DNS"
	$aDns[0][7][1] = "202.103.224.68"
	$aDns[0][7][2] = "202.103.225.68"
	$aDns[0][8][0] = "福建DNS"
	$aDns[0][8][1] = "218.85.157.99"
	$aDns[0][8][2] = "202.101.115.55"
	$aDns[0][9][0] = "厦门DNS"
	$aDns[0][9][1] = "202.101.103.55"
	$aDns[0][9][2] = "202.101.103.54"
	;网通DNS
	$aDns[1][1][0] = "北京DNS"
	$aDns[1][1][1] = "ns.bta.net.cn"
	$aDns[1][1][2] = "202.96.0.133"
	$aDns[1][10][0] = "天津DNS"
	$aDns[1][10][1] = "202.99.96.68"
	$aDns[1][10][2] = "10.10.64.68"
	$aDns[1][11][0] = "辽宁DNS"
	$aDns[1][11][1] = "202.96.75.68"
	$aDns[1][11][2] = "202.96.75.64"
	$aDns[1][12][0] = "江苏DNS"
	$aDns[1][12][1] = "202.102.29.3"
	$aDns[1][12][2] = "202.102.13.141"
	$aDns[1][13][0] = "安徽DNS"
	$aDns[1][13][1] = "202.102.192.68"
	$aDns[1][13][2] = "202.102.199.68"
	$aDns[1][14][0] = "四川DNS"
	$aDns[1][14][1] = "119.6.6.6"
	$aDns[1][14][2] = "221.10.251.197"
	$aDns[1][15][0] = "重庆DNS"
	$aDns[1][15][1] = "61.128.128.68"
	$aDns[1][15][2] = "61.128.192.4"
	$aDns[1][16][0] = "成都DNS"
	$aDns[1][16][1] = "202.98.96.68"
	$aDns[1][16][2] = "202.98.96.69"
	$aDns[1][17][0] = "河北DNS"
	$aDns[1][17][1] = "202.99.160.68"
	$aDns[1][17][2] = "10.17.128.90"
	$aDns[1][18][0] = "保定DNS"
	$aDns[1][18][1] = "202.99.160.68"
	$aDns[1][18][2] = "202.99.166.4"
	$aDns[1][19][0] = "山西DNS"
	$aDns[1][19][1] = "202.99.198.6"
	$aDns[1][19][2] = "202.99.192.68"
	$aDns[1][2][0] = "香港DNS"
	$aDns[1][2][1] = "205.252.144.228"
	$aDns[1][2][2] = "0.0.0.0"
	$aDns[1][20][0] = "吉林DNS"
	$aDns[1][20][1] = "202.98.5.68"
	$aDns[1][20][2] = "202.98.14.19"
	$aDns[1][21][0] = "山东DNS"
	$aDns[1][21][1] = "202.102.152.3"
	$aDns[1][21][2] = "202.102.128.68"
	$aDns[1][22][0] = "福建DNS"
	$aDns[1][22][1] = "202.101.98.55"
	$aDns[1][22][2] = "202.101.115.55"
	$aDns[1][23][0] = "湖南DNS"
	$aDns[1][23][1] = "202.103.100.206"
	$aDns[1][23][2] = "202.103.96.68"
	$aDns[1][24][0] = "广西DNS"
	$aDns[1][24][1] = "202.103.224.68"
	$aDns[1][24][2] = "202.103.225.68"
	$aDns[1][25][0] = "江西DNS"
	$aDns[1][25][1] = "202.109.129.2"
	$aDns[1][25][2] = "202.101.224.68"
	$aDns[1][26][0] = "云南DNS"
	$aDns[1][26][1] = "202.98.160.68"
	$aDns[1][26][2] = "202.98.96.68"
	$aDns[1][27][0] = "河南DNS"
	$aDns[1][27][1] = "202.102.227.68"
	$aDns[1][27][2] = "202.102.224.68"
	$aDns[1][28][0] = "新疆DNS"
	$aDns[1][28][1] = "61.128.97.73"
	$aDns[1][28][2] = "61.128.97.74"
	$aDns[1][29][0] = "乌鲁木齐DNS"
	$aDns[1][29][1] = "61.128.97.73"
	$aDns[1][29][2] = "61.128.97.74"
	$aDns[1][3][0] = "澳门DNS"
	$aDns[1][3][1] = "202.175.3.8"
	$aDns[1][3][2] = "0.0.0.0"
	$aDns[1][30][0] = "武汉DNS"
	$aDns[1][30][1] = "202.103.24.68"
	$aDns[1][30][2] = "202.103.0.117"
	$aDns[1][31][0] = "厦门DNS"
	$aDns[1][31][1] = "202.101.103.55"
	$aDns[1][31][2] = "202.101.103.54"
	$aDns[1][32][0] = "山东DNS"
	$aDns[1][32][1] = "202.102.134.68"
	$aDns[1][32][2] = "202.102.152.3"
	$aDns[1][33][0] = "长沙DNS"
	$aDns[1][33][1] = "202.103.96.68"
	$aDns[1][33][2] = "202.103.96.112"
	$aDns[1][34][0] = "谷歌DNS"
	$aDns[1][34][1] = "8.8.8.8"
	$aDns[1][34][2] = "8.8.4.4"
	$aDns[1][35][0] = "阿里公共DNS"
	$aDns[1][35][1] = "223.5.5.5"
	$aDns[1][35][2] = "223.6.6.6"
	$aDns[1][36][0] = "百度公共DNS"
	$aDns[1][36][1] = "180.76.76.76"
	$aDns[1][36][2] = "114.114.114.114"
	$aDns[1][37][0] = "OpenDNS"
	$aDns[1][37][1] = "208.67.222.222"
	$aDns[1][37][2] = "208.67.220.220"
	$aDns[1][38][0] = "OpenDNS Family"
	$aDns[1][38][1] = "208.67.222.123"
	$aDns[1][38][2] = "208.67.220.123"
	$aDns[1][39][0] = "Comodo Secure DNS"
	$aDns[1][39][1] = "156.154.70.22"
	$aDns[1][39][2] = "156.154.71.22"
	$aDns[1][4][0] = "深圳DNS"
	$aDns[1][4][1] = "220.250.64.26"
	$aDns[1][4][2] = "202.96.134.133"
	$aDns[1][40][0] = "ScrubIt DNS"
	$aDns[1][40][1] = "67.138.54.100"
	$aDns[1][40][2] = "207.225.209.66"
	$aDns[1][41][0] = "DNS Advantage"
	$aDns[1][41][1] = "156.154.70.1"
	$aDns[1][41][2] = "156.154.71.1"
	$aDns[1][5][0] = "广东DNS"
	$aDns[1][5][1] = "202.96.128.143"
	$aDns[1][5][2] = "202.96.128.68"
	$aDns[1][6][0] = "上海DNS"
	$aDns[1][6][1] = "202.96.199.132"
	$aDns[1][6][2] = "202.96.199.133"
	$aDns[1][7][0] = "浙江DNS"
	$aDns[1][7][1] = "202.96.102.3"
	$aDns[1][7][2] = "202.96.96.68"
	$aDns[1][8][0] = "陕西DNS"
	$aDns[1][8][1] = "202.100.13.11"
	$aDns[1][8][2] = "202.100.4.16"
	$aDns[1][9][0] = "西安DNS"
	$aDns[1][9][1] = "202.100.4.15"
	$aDns[1][9][2] = "202.100.0.68"
	GUICtrlSetData($DNS, '')
	If GUICtrlRead($IpSetDlg[3]) = $GUI_CHECKED Then
		For $i = 0 To UBound($aDns, 2) - 1
			Local $CityName = $aDns[0][$i][0]
			If $CityName <> '' Then
				GUICtrlSetData($DNS, $aDns[0][$i][0])
			EndIf
		Next
	Else
		For $i = 0 To UBound($aDns, 2) - 1
			Local $CityName = $aDns[1][$i][0]
			If $CityName <> '' Then
				GUICtrlSetData($DNS, $aDns[1][$i][0])
			EndIf
		Next
	EndIf
EndFunc   ;==>PrepDNS
;设置Dns函数
Func LoadDNS()
	If GUICtrlRead($IpSetDlg[3]) = $GUI_CHECKED Then
		For $i = 0 To UBound($aDns, 2) - 1
			If GUICtrlRead($DNS) = $aDns[0][$i][0] Then
				_GUICtrlIpAddress_Set($FirstDns, $aDns[0][$i][1])
				_GUICtrlIpAddress_Set($BakDns, $aDns[0][$i][2])
			EndIf
		Next
	Else
		For $i = 0 To UBound($aDns, 2) - 1
			If GUICtrlRead($DNS) = $aDns[1][$i][0] Then
				_GUICtrlIpAddress_Set($FirstDns, $aDns[1][$i][1])
				_GUICtrlIpAddress_Set($BakDns, $aDns[1][$i][2])
			EndIf
		Next
	EndIf
EndFunc   ;==>LoadDNS
;线路选择触发事件函数
Func ChooseLine()
;~ 	PrepDNS()
	LoadDNS()
EndFunc   ;==>ChooseLine

;设置DNS
Func SetIPS()
	If GUICtrlRead($NetApt) <> '' Then
		Local $Ip = _GUICtrlIpAddress_Get($IPAddress)
		Local $SubMask = _GUICtrlIpAddress_Get($zmym)
		Local $DefGateWay = _GUICtrlIpAddress_Get($GateWay)
		Local $protDns = _GUICtrlIpAddress_Get($FirstDns)
		Local $SecDns = _GUICtrlIpAddress_Get($BakDns)
		Local $ConName = GUICtrlRead($NetApt)
		If GUICtrlRead($IpSetDlg[2]) = $GUI_CHECKED Then
			;设置IP地址及子网掩码、网关
			RunWait(@ComSpec & ' /c netsh interface ip set address name="' & $ConName & '" static ' & $Ip & ' ' & $SubMask & ' ' & $DefGateWay, @WindowsDir, @SW_HIDE)
			_SetCmpIP($InterFaceGUID, $Ip, $SubMask, $DefGateWay, $protDns & ',' & $SecDns)
			;刷新DNS缓存
			DllCall('Dnsapi.dll', 'BOOL', 'DnsFlushResolverCache')
			_updateArryInfo()
			MsgBox(0, '提示', '设置静态IP成功！', 5)
		EndIf
		If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\" & $InterFaceGUID, "EnableDHCP", "REG_DWORD", "1")
			RunWait(@ComSpec & ' /c netsh interface ip set address name="' & $ConName & '" source=dhcp ', @ScriptDir & '\', @SW_HIDE)
			If GUICtrlRead($DIDNS) = $GUI_CHECKED Then
				RunWait('netsh interface ipv4 set dnsservers "' & $ConName & '" static ' & $protDns & ' primary validate=no', @ScriptDir & '\', @SW_HIDE)
				RunWait('netsh interface ipv4 set dnsservers "' & $ConName & '" static ' & $SecDns & ' index=2 validate=no', @ScriptDir & '\', @SW_HIDE)
			Else
				RunWait(@ComSpec & ' /c netsh interface ip set dns name="' & $ConName & '" source=dhcp ', @ScriptDir & '\', @SW_HIDE)
			EndIf
			_ForceUpdate()
			DllCall('Dnsapi.dll', 'BOOL', 'DnsFlushResolverCache')
			MsgBox(0, '提示', '设置计算机IP为自动获取成功！', 5)
		EndIf
	ElseIf GUICtrlRead($NetApt) = '' Then
		MsgBox(0, '', '请选择您要进行设置的网络！', 3)
	Else
	EndIf
EndFunc   ;==>SetIPS
