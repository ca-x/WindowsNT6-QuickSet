;==============================================================================
; 模块：网络底层库
; 说明：IPHLPAPI 接口表、网卡信息、WMI 适配器枚举、流量统计
; 文件：src\core\net.au3
; 函数：共 16 个
;==============================================================================
#include-once


Func _loadNetInterface()
	For $i = 1 To UBound($NetInfo) - 1
		GUICtrlSetData($NetApt, $NetInfo[$i][3])
	Next
EndFunc   ;==>_loadNetInterface
Func _LoadSpecifecInterfaceInfo()
	For $i = 1 To UBound($NetInfo) - 1
		If GUICtrlRead($NetApt) == $NetInfo[$i][3] Then
			$InterFaceGUID = $NetInfo[$i][5]
			If $NetInfo[$i][6] = '' Then
				_GUICtrlIpAddress_Set($IPAddress, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($IPAddress, $NetInfo[$i][6])
			EndIf
			If $NetInfo[$i][8] = '' Then
				_GUICtrlIpAddress_Set($zmym, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($zmym, $NetInfo[$i][8])
			EndIf
			If $NetInfo[$i][7] = '' Then
				_GUICtrlIpAddress_Set($GateWay, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($GateWay, $NetInfo[$i][7])
			EndIf
			If $NetInfo[$i][9] = '' Then
				_GUICtrlIpAddress_Set($FirstDns, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($FirstDns, $NetInfo[$i][9])
			EndIf
			If $NetInfo[$i][10] = '' Then
				_GUICtrlIpAddress_Set($BakDns, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($BakDns, $NetInfo[$i][10])
			EndIf
			$InterFaceGUID = $NetInfo[$i][5]
			If $NetInfo[$i][12] = True Then
				GUICtrlSetState($IpSetDlg[1], $GUI_CHECKED)
			Else
				GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
			EndIf
			_ToogleIPControl()
			GUICtrlSetData($IpProjName, '无方案')
			_GUICtrlComboBox_SelectString($DNS, '本地DNS')
			ExitLoop
		EndIf
	Next
EndFunc   ;==>_LoadSpecifecInterfaceInfo

Func _updateArryInfo()
	Local $Ip = _GUICtrlIpAddress_Get($IPAddress)
	Local $SubMask = _GUICtrlIpAddress_Get($zmym)
	Local $DefGateWay = _GUICtrlIpAddress_Get($GateWay)
	Local $protDns = _GUICtrlIpAddress_Get($FirstDns)
	Local $SecDns = _GUICtrlIpAddress_Get($BakDns)
	Local $ConName = GUICtrlRead($NetApt)
	For $i = 1 To UBound($NetInfo) - 1
		If $ConName == $NetInfo[$i][3] Then
			If GUICtrlRead($IpSetDlg[2]) = $GUI_CHECKED Then
				If $Ip = '' Then
					$NetInfo[$i][6] = '0.0.0.0'
				EndIf
				If $SubMask = '' Then
					$NetInfo[$i][8] = '0.0.0.0'
				Else
					$NetInfo[$i][8] = $SubMask
				EndIf
				If $DefGateWay = '' Then
					$NetInfo[$i][7] = '0.0.0.0'
				Else
					$NetInfo[$i][7] = $DefGateWay
				EndIf
				If $protDns = '' Then
					$NetInfo[$i][9] = '0.0.0.0'
				Else
					$NetInfo[$i][9] = $protDns
				EndIf
				If $SecDns = '' Then
					$NetInfo[$i][10] = '0.0.0.0'
				Else
					$NetInfo[$i][10] = $SecDns
				EndIf
			EndIf

			ExitLoop
		EndIf
	Next
EndFunc   ;==>_updateArryInfo
Func _GetNetworkAdapterInfo()
	Local $colItem
	Local $objItem
	Local $colItems
	Local $objItems
	Local $objWMIService
	Local $Adapters[1][13]
	$Adapters[0][0] = 0
	$objWMIService = ObjGet("winmgmts:\\localhost\root\CIMV2")
	$colItem = $objWMIService.ExecQuery("Select * FROM Win32_NetworkAdapter Where NetConnectionStatus >0", "WQL", 0x30)
	If IsObj($colItem) Then
		For $objItem In $colItem
			If $objItem.MACAddress = "00:00:00:00:00:00" Then ContinueLoop
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][13]
			$Adapters[$Adapters[0][0]][0] += $Adapters[0][0]
			$Adapters[$Adapters[0][0]][1] = $objItem.NetConnectionStatus
			$Adapters[$Adapters[0][0]][2] = $objItem.Description
			$Adapters[$Adapters[0][0]][3] = $objItem.NetConnectionID
			$Adapters[$Adapters[0][0]][4] = $objItem.MACAddress
			;WidnowsNT6上的网卡ID
			If @OSBuild > 6000 Then
				$Adapters[$Adapters[0][0]][5] = $objItem.Guid
			Else
				$Adapters[$Adapters[0][0]][5] = ''
			EndIf
			$colItems = $objWMIService.ExecQuery('Select * FROM Win32_NetworkAdapterConfiguration Where MACAddress = "' & $Adapters[$Adapters[0][0]][4] & '" And IPEnabled = True ', "WQL", 0x30)
			If IsObj($colItems) Then
				For $objItems In $colItems
;~ 					if $objItems.IPAddress(0) = "0.0.0.0" Then ContinueLoop
					$Adapters[$Adapters[0][0]][6] = $objItems.IPAddress(0)
					$Adapters[$Adapters[0][0]][7] = $objItems.DefaultIPGateway(0)
					$Adapters[$Adapters[0][0]][8] = $objItems.IPSubnet(0)
					$sDNS = _WMIArrayToString($objItems.DNSServerSearchOrder())
					$aDns = StringSplit($sDNS, '|')
					If Not @error Then
						$Adapters[$Adapters[0][0]][9] = $aDns[1]
						$Adapters[$Adapters[0][0]][10] = $aDns[2]
					Else
						$Adapters[$Adapters[0][0]][9] = $aDns[1]
						$Adapters[$Adapters[0][0]][10] = '0.0.0.0'
					EndIf
					$Adapters[$Adapters[0][0]][11] = $objItems.SettingID
					$Adapters[$Adapters[0][0]][12] = $objItems.DHCPEnabled
				Next
			EndIf
		Next
	EndIf
	Return $Adapters
EndFunc   ;==>_GetNetworkAdapterInfo
Func _WMIArrayToString($aArray, $sDelimeter = '|')
	Local $sString = ''
	If UBound($aArray) Then
		For $i = 0 To UBound($aArray) - 1
			$sString &= $aArray[$i] & $sDelimeter
		Next
		$sString = StringTrimRight($sString, StringLen($sDelimeter))
	EndIf
	Return $sString
EndFunc   ;==>_WMIArrayToString

Func GetAdaptersList()
	Local $Adapters[1][4]
	$Adapters[0][0] = 0

	If @OSType = "WIN32_NT" Then
		;Use WMI
		Local $i
		For $i = 1 To UBound($NetInfo) - 1
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][6]
			$Adapters[$Adapters[0][0]][0] = $NetInfo[$i][2] ;adapter name
			$Adapters[$Adapters[0][0]][1] = $NetInfo[$i][4] ;adapter real mac address
			Local $AdapterReg = GetAdapterRegKey($NetInfo[$i][2])
			$Adapters[$Adapters[0][0]][2] = $AdapterReg[0] ;adapter regkey
			If @OSBuild < 6000 Then
				$NetInfo[$i][5] = RegRead($AdapterReg[0], 'NetCfgInstanceId')
			EndIf
			$Adapters[$Adapters[0][0]][3] = $AdapterReg[1] ;virtual mac
			$Adapters[$Adapters[0][0]][4] = $NetInfo[$i][6] ;IP地址
			$Adapters[$Adapters[0][0]][5] = $NetInfo[$i][3] ;连接名称
		Next
	Else
		;Use a lista do registro se for win9x
		Local $AdapterRegList = GetAdapterRegKey()
		Local $i = 0
		For $i = 1 To $AdapterRegList[0][0]
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][4]
			$Adapters[$Adapters[0][0]][0] = $AdapterRegList[$i][0] ;adapter name
			$Adapters[$Adapters[0][0]][1] = "" ;adapter real mac address
			$Adapters[$Adapters[0][0]][2] = $AdapterRegList[$i][1] ;adapter regkey
			$Adapters[$Adapters[0][0]][3] = $AdapterRegList[$i][2] ;virtual mac
		Next
	EndIf
	Return $Adapters
EndFunc   ;==>GetAdaptersList

;------------------------------------------------------------------------------------------------------------
Func GetAdapterRegKey($Adapter = "")
	Local $RetVal[2]
	Local $NetKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
	If @OSType = "WIN32_WINDOWS" Then
		$NetKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\System\CurrentControlSet\Services\Class\Net"
	EndIf
	Local $i = 0
	While 1
		$i += 1
		Local $Key = RegEnumKey($NetKey, $i)
		If @error <> 0 Then ExitLoop
		Local $AdapterKey = $NetKey & "\" & $Key
		Local $j = 0
		While 1
			$j += 1
			Local $Value = RegEnumVal($AdapterKey, $j)
			If @error <> 0 Then ExitLoop
			If $Value = "DriverDesc" Then
				If $Adapter <> "" Then
					;vai retornar somente o adaptador que pedi
					If $Adapter = RegRead($AdapterKey, $Value) Then
						$RetVal[0] = $AdapterKey
						$RetVal[1] = RegRead($AdapterKey, "networkaddress")
						ExitLoop
					EndIf
				Else
					;retorne a lista com os adaptadores
					ReDim $RetVal[$i + 1][3]
					$RetVal[0][0] = $i
					$RetVal[$i][0] = RegRead($AdapterKey, $Value)
					$RetVal[$i][1] = $AdapterKey
					$RetVal[$i][2] = RegRead($AdapterKey, "networkaddress")
				EndIf
			EndIf
		WEnd
	WEnd
	Return $RetVal
EndFunc   ;==>GetAdapterRegKey

Func _SetCmpIP($LanID, $setIP, $setZW, $setWG, $setDNS)
	;======================================================
	; 函数名称:       _SetCmpIP($AdapterID,$strComputerName,$setIP,$setZW,$setWG,$setDNS)
	; 详细信息:        修改机器IP
	; $LanID 网卡ID
	; $setIP 机器IP
	; $setZW 子网掩码
	; $setWG 默认网关 如 8.8.8.8,8.8.4.4
	;======================================================
	$SetKey1 = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\"
	$SetKey2 = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet002\"
	$CtrlKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\"
	$LanReg1 = $SetKey1 & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	$LanReg2 = $SetKey2 & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	$LanReg3 = $CtrlKey & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	;通过注册表修改网卡自动获取IP为固定IP
	RegWrite($LanReg3, "EnableDHCP", "REG_DWORD", "0")
	;通过注册表修改IP
	RegWrite($LanReg1, "IPAddress", "REG_MULTI_SZ", $setIP)
	RegWrite($LanReg2, "IPAddress", "REG_MULTI_SZ", $setIP)
	RegWrite($LanReg3, "IPAddress", "REG_MULTI_SZ", $setIP)
	;通过注册表修改子网掩码
	RegWrite($LanReg1, "SubnetMask", "REG_MULTI_SZ", $setZW)
	RegWrite($LanReg2, "SubnetMask", "REG_MULTI_SZ", $setZW)
	RegWrite($LanReg3, "SubnetMask", "REG_MULTI_SZ", $setZW)
	;通过注册表修改网关
	RegWrite($LanReg1, "DefaultGateway", "REG_MULTI_SZ", $setWG)
	RegWrite($LanReg2, "DefaultGateway", "REG_MULTI_SZ", $setWG)
	RegWrite($LanReg3, "DefaultGateway", "REG_MULTI_SZ", $setWG)

	;通过注册表修改DNS
	RegWrite($LanReg1, "NameServer", "REG_SZ", $setDNS)
	RegWrite($LanReg2, "NameServer", "REG_SZ", $setDNS)
	RegWrite($LanReg3, "NameServer", "REG_SZ", $setDNS)
	_ForceUpdate()
EndFunc   ;==>_SetCmpIP
;=========================================================================================
;校准系统时间
;=========================================================================================
Func _IsConnectedToInternet()
	If _WinAPI_GetVersion() < '6.0' Then
		Local $NetCon = DllCall("sensapi.dll", "int", "IsNetworkAlive", "str", $NETWORK_ALIVE_LAN)
		$x = $NetCon[0]
		If $x = 1 Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return _WinAPI_IsInternetConnected()
	EndIf
EndFunc   ;==>_IsConnectedToInternet

Func _RasEnumEntries($sPhonebook)
	Local $iResult, $aResult[1][3], $tBuffer, $pBuffer, $iSizeofBuffer, $tagBuffer, $iIndex

	$tBuffer = DllStructCreate("dword;char[257];dword;char[261]")
	$pBuffer = DllStructGetPtr($tBuffer)
	$iSizeofBuffer = DllStructGetSize($tBuffer)
	DllStructSetData($tBuffer, 1, $iSizeofBuffer)

	$iResult = DllCall("rasapi32.dll", "dword", "RasEnumEntries", _
			"ptr", 0, "str", $sPhonebook, _
			"ptr", $pBuffer, "int*", $iSizeofBuffer, "int*", 0)
	$tBuffer = 0
	$aResult[0][0] = $iResult[5]
	ReDim $aResult[$iResult[5] + 1][3]
	If $iResult[5] = 0 Then Return SetError($iResult[0], 0, $aResult)

	For $i = 1 To $iResult[5]
		$tagBuffer &= "dword;char[257];dword;char[261];"
	Next

	$tBuffer = DllStructCreate($tagBuffer)
	$pBuffer = DllStructGetPtr($tBuffer)
	DllStructSetData($tBuffer, 1, $iSizeofBuffer)

	$iResult = DllCall("rasapi32.dll", "dword", "RasEnumEntries", _
			"ptr", 0, "str", $sPhonebook, _
			"ptr", $pBuffer, "int*", $iResult[4], "int*", 0)
	For $i = 2 To $iResult[5] * 4 Step 4
		$iIndex += 1
		$aResult[$iIndex][0] = DllStructGetData($tBuffer, $i)
		$aResult[$iIndex][1] = DllStructGetData($tBuffer, $i + 2)
		$aResult[$iIndex][2] = DllStructGetData($tBuffer, $i + 1)
	Next
	$tBuffer = 0
	Return SetError($iResult[0], $iResult[5], $aResult)
EndFunc   ;==>_RasEnumEntries
Func _IsWirelessAdapter($sAdapter)

	Local $hDLL = DllOpen("wlanapi.dll"), $aResult, $hClientHandle, $pInterfaceList, _
			$tInterfaceList, $iInterfaceCount, $tInterface, $pInterface, $tGUID, $pGUID

	$aResult = DllCall($hDLL, "dword", "WlanOpenHandle", "dword", 2, "ptr", 0, "dword*", 0, "hwnd*", 0)
	If @error Or $aResult[0] Then Return 0

	$hClientHandle = $aResult[4]

	$aResult = DllCall($hDLL, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle, "ptr", 0, "ptr*", 0)
	If @error Or $aResult[0] Then Return 0

	$pInterfaceList = $aResult[3]

	$tInterfaceList = DllStructCreate("dword", $pInterfaceList)
	$iInterfaceCount = DllStructGetData($tInterfaceList, 1)
	If Not $iInterfaceCount Then Return 0

	Local $abGUIDs[$iInterfaceCount]

	For $i = 0 To $iInterfaceCount - 1
		$pInterface = Ptr(Number($pInterfaceList) + ($i * 532 + 8))
		$tInterface = DllStructCreate("byte GUID[16]; wchar descr[256]; int State", $pInterface)
		$abGUIDs[$i] = DllStructGetData($tInterface, "GUID")

		If DllStructGetData($tInterface, "descr") == $sAdapter Then Return 1

	Next


	DllCall($hDLL, "dword", "WlanFreeMemory", "ptr", $pInterfaceList)

	$tGUID = DllStructCreate("byte[16]")
	DllStructSetData($tGUID, 1, $abGUIDs[0])
	$pGUID = DllStructGetPtr($tGUID)


	DllCall($hDLL, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", 0)
	DllClose($hDLL)

	Return 0

EndFunc   ;==>_IsWirelessAdapter

Func _UpdateStats()

	Local $aEnd_Values, $iRecived, $iSent, $sNew_Label, $iLargest_Value

	$aEnd_Values = _GetAllTraffic()
	$iRecived = $aEnd_Values[0] - $aStart_Values[0]
	$iSent = $aEnd_Values[1] - $aStart_Values[1]

	If Not ($iRecived + $iSent) Then ; No Activity
		Local $sZero = '↓DL [0.0 kB/秒]' & @LF & '↑UL [0.0 kB/秒]'
		If $sLast_Label <> $sZero Then GUICtrlSetData($Label1, $sZero)
		$aStart_Values = $aEnd_Values
		$sLast_Label = $sZero
		Return
	EndIf
	If $iSent >= $iRecived Then
		$iLargest_Value = $iSent
	Else
		$iLargest_Value = $iRecived
	EndIf

	If $iLargest_Value >= 1048576 Then
		$sNew_Label = '↓DL [' & StringFormat('%.2f', Round($iRecived / 1048576, 2)) & ' mB/秒]' & @LF & '↑UL [' & StringFormat('%.2f', Round($iSent / 1048576, 2)) & ' mB/秒]'
		If $sNew_Label <> $sLast_Label Then GUICtrlSetData($Label1, $sNew_Label)
	Else
		$sNew_Label = '↓DL[' & StringFormat('%.1f', Round($iRecived / 1024, 1)) & ' kB/秒]' & @LF & '↑UL[' & StringFormat('%.1f', Round($iSent / 1024, 1)) & 'kB/秒]'
		If $sNew_Label <> $sLast_Label Then GUICtrlSetData($Label1, $sNew_Label)
	EndIf

	$sLast_Label = $sNew_Label
	$aStart_Values = $aEnd_Values

EndFunc   ;==>_UpdateStats

Func _GetAllTraffic()

	Local $Total_Values[2], $Adapter_Values
	Local $ifcount = _GetNumberofInterfaces()

;~ 	If $Global_IF_Count <> $ifcount Then
;~ 		TrayTip("网卡数量信息发生改变", "流量统计功能尝试重新初始化...", 10, 3)
;~ 		$Global_IF_Count = $ifcount
;~ 		$Table_Data = _WinAPI_GetIfTable()
;~ 		$aStart_Values = _GetAllTraffic()
;~ 	EndIf

	For $i = 1 To $Table_Data[0][0]
		$Adapter_Values = _WinAPI_GetIfEntry($Table_Data[$i][1])
		If IsArray($Adapter_Values) Then
			$Total_Values[0] += $Adapter_Values[0] ;Recived
			$Total_Values[1] += $Adapter_Values[1] ;Sent
;~ 		Else
;~ 			;ConsoleWrite('Error: Adaptor Count has change.' & @CRLF & 'Attepting to reinitalize...')
;~             TrayTip("网卡数量信息发生改变", "流量统计功能尝试重新初始化...", 10, 3)
;~ 			$Table_Data = _WinAPI_GetIfTable()
		EndIf
	Next

	Return $Total_Values

EndFunc   ;==>_GetAllTraffic

Func _WinAPI_GetIfEntry($iIndex)

	Local $ret, $Stats[2]
	Static $tMIB_IFROW = DllStructCreate($tagMIB_IFROW)

	DllStructSetData($tMIB_IFROW, 2, $iIndex)

	$ret = DllCall($IPHlpApi_Dll, 'dword', 'GetIfEntry', 'ptr', DllStructGetPtr($tMIB_IFROW))
	If (@error) Or ($ret[0]) Then Return SetError($ret[0], 0, 0)

	$Stats[0] = DllStructGetData($tMIB_IFROW, 'InOctets') ;Recived
	$Stats[1] = DllStructGetData($tMIB_IFROW, 'OutOctets') ;Sent

	Return $Stats

EndFunc   ;==>_WinAPI_GetIfEntry

Func _GetNumberofInterfaces()
	Local $Adaptor_Count = DllCall($IPHlpApi_Dll, 'int', 'GetNumberOfInterfaces', 'dword*', 0)
	Return $Adaptor_Count[1]
EndFunc   ;==>_GetNumberofInterfaces

Func _WinAPI_GetIfTable($iType = 0)

	Local $ret, $Row, $Type, $Tag, $Tab, $Addr, $count, $Lenght, $tMIB_IFTABLE
	Local $tMIB_IFROW = DllStructCreate($tagMIB_IFROW)

	$Row = 'byte[' & DllStructGetSize($tMIB_IFROW) & ']'
	$Tag = 'dword;'
	For $i = 1 To 32
		$Tag &= $Row & ';'
	Next
	$tMIB_IFTABLE = DllStructCreate($Tag)
	$ret = DllCall($IPHlpApi_Dll, 'dword', 'GetIfTable', 'ptr', DllStructGetPtr($tMIB_IFTABLE), 'long*', DllStructGetSize($tMIB_IFTABLE), 'int', 1)
	If (@error) Or ($ret[0]) Then Return SetError($ret[0], 0, 0)

	$count = DllStructGetData($tMIB_IFTABLE, 1)
	Dim $Tab[$count + 1][20]
	$Tab[0][0] = 0
	$Tab[0][1] = 'Index'
	$Tab[0][2] = 'Type'
	$Tab[0][3] = 'Mtu'
	$Tab[0][4] = 'Speed'
	$Tab[0][5] = 'Address'
	$Tab[0][6] = 'AdminStatus'
	$Tab[0][7] = 'OperStatus'
	$Tab[0][8] = 'InOctets'
	$Tab[0][9] = 'InUcastPkts'
	$Tab[0][10] = 'InNUcastPkts'
	$Tab[0][11] = 'InDiscards'
	$Tab[0][12] = 'InErrors'
	$Tab[0][13] = 'InUnknownProtos'
	$Tab[0][14] = 'OutOctets'
	$Tab[0][15] = 'OutUcastPkts'
	$Tab[0][16] = 'OutNUcastPkts'
	$Tab[0][17] = 'OutDiscards'
	$Tab[0][18] = 'OutErrors'

	For $i = 1 To $count
		$tMIB_IFROW = DllStructCreate($tagMIB_IFROW, DllStructGetPtr($tMIB_IFTABLE, $i + 1))
		$Type = DllStructGetData($tMIB_IFROW, 'Type')
		If $Type <> $MIB_IF_TYPE_SOFTWARE_LOOPBACK Then
			$Tab[0][0] += 1

			$Lenght = DllStructGetData($tMIB_IFROW, 'PhysAddrLen')
			$Addr = ''
			For $j = 1 To $Lenght
				$Addr &= Hex(DllStructGetData($tMIB_IFROW, 'PhysAddr', $j), 2) & '-'
			Next
			$Addr = StringTrimRight($Addr, 1)

			_ArraySearch($Tab, $Addr, 1, $Tab[0][0] - 1, 1, 0, 1, 5)
			If @error <> 6 Or $Addr = '' Or StringLen($Addr) > 17 Then
				$Tab[0][0] -= 1
				ContinueLoop
			EndIf

			$Tab[$Tab[0][0]][0] = DllStructGetData($tMIB_IFROW, 'Name')
			$Tab[$Tab[0][0]][1] = DllStructGetData($tMIB_IFROW, 'Index')
			$Tab[$Tab[0][0]][2] = $Type
			$Tab[$Tab[0][0]][3] = DllStructGetData($tMIB_IFROW, 'Mtu')
			$Tab[$Tab[0][0]][4] = DllStructGetData($tMIB_IFROW, 'Speed')
			$Tab[$Tab[0][0]][5] = $Addr
			$Tab[$Tab[0][0]][6] = DllStructGetData($tMIB_IFROW, 'AdminStatus')
			$Tab[$Tab[0][0]][7] = DllStructGetData($tMIB_IFROW, 'OperStatus')
			$Tab[$Tab[0][0]][8] = DllStructGetData($tMIB_IFROW, 'InOctets')
			$Tab[$Tab[0][0]][9] = DllStructGetData($tMIB_IFROW, 'InUcastPkts')
			$Tab[$Tab[0][0]][10] = DllStructGetData($tMIB_IFROW, 'InNUcastPkts')
			$Tab[$Tab[0][0]][11] = DllStructGetData($tMIB_IFROW, 'InDiscards')
			$Tab[$Tab[0][0]][12] = DllStructGetData($tMIB_IFROW, 'InErrors')
			$Tab[$Tab[0][0]][13] = DllStructGetData($tMIB_IFROW, 'InUnknownProtos')
			$Tab[$Tab[0][0]][14] = DllStructGetData($tMIB_IFROW, 'OutOctets')
			$Tab[$Tab[0][0]][15] = DllStructGetData($tMIB_IFROW, 'OutUcastPkts')
			$Tab[$Tab[0][0]][16] = DllStructGetData($tMIB_IFROW, 'OutNUcastPkts')
			$Tab[$Tab[0][0]][17] = DllStructGetData($tMIB_IFROW, 'OutDiscards')
			$Tab[$Tab[0][0]][18] = DllStructGetData($tMIB_IFROW, 'OutErrors')
			$Tab[$Tab[0][0]][19] = StringLeft(DllStructGetData($tMIB_IFROW, 'Descr'), DllStructGetData($tMIB_IFROW, 'DescrLen') - 1)
		EndIf
	Next

	If $Tab[0][0] < $count Then ReDim $Tab[$Tab[0][0] + 1][20]

	Return $Tab
EndFunc   ;==>_WinAPI_GetIfTable
