;==============================================================================
; 模块：OEM 信息与登录背景
; 说明：计算机所有者信息、品牌预设、OEM Logo、登录界面背景、工作组/环境变量
; 文件：src\features\personalize\Feat_OemInfo.au3
; 函数：共 20 个
;==============================================================================
#include-once


Func _SetWorkGroupName($sGroupName)
	Local $aRet = DllCall("Netapi32.dll", "long", "NetJoinDomain", "int", 0, "wstr", $sGroupName, "int", 0, "int", 0, "int", 0, "dword", 0x00000040)
	Return $aRet[0]
EndFunc   ;==>_SetWorkGroupName

Func _GetWorkgroupName()
	Local $NERR, $pBuffer, $sName
	Local Const $NetSetupUnknownStatus = 0
	Local Const $NetSetupUnjoined = 1
	Local Const $NetSetupWorkgroupName = 2
	Local Const $NetSetupDomainName = 3

	$NERR = DllCall("Netapi32.dll", "int", "NetGetJoinInformation", "wstr", @ComputerName, "ptr*", 0, "int*", 0)

	If @error Then Return SetError(@error, @extended, "")
	If $NERR[0] = 0 Then
		$pBuffer = $NERR[2]
		$sName = DllStructGetData(DllStructCreate("wchar[" & __NetApi_BufferSize($pBuffer) & "]", $pBuffer), 1)
		__NetApi_BufferFree($pBuffer)
	EndIf
	If @error Then Return SetError(@error, @extended, "")

	Return $sName
EndFunc   ;==>_GetWorkgroupName

Func _EnvUpdate($sEnvVar = "", $vValue = "", $fCurrentUser = True, $fMachine = False)
	Local $sREG_TYPE = "REG_SZ", $iRet1, $iRet2

	If $sEnvVar <> "" Then
		If StringInStr($sEnvVar, "\") Then $sREG_TYPE = "REG_EXPAND_SZ"
		If $vValue <> "" Then
			If $fCurrentUser Then RegWrite("HKCU\Environment", $sEnvVar, $sREG_TYPE, $vValue)
			If $fMachine Then RegWrite("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar, $sREG_TYPE, $vValue)
		Else
			If $fCurrentUser Then RegDelete("HKCU\Environment", $sEnvVar)
			If $fMachine Then RegDelete("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar)
		EndIf
		; http://msdn.microsoft.com/en-us/library/ms686206%28VS.85%29.aspx
		$iRet1 = DllCall("Kernel32.dll", "BOOL", "SetEnvironmentVariable", "str", $sEnvVar, "str", $vValue)
		If $iRet1[0] = 0 Then Return SetError(1)
	EndIf
	; http://msdn.microsoft.com/en-us/library/ms644952%28VS.85%29.aspx
	$iRet2 = DllCall("user32.dll", "lresult", "SendMessageTimeoutW", _
			"hwnd", 0xffff, _
			"dword", 0x001A, _
			"ptr", 0, _
			"wstr", "Environment", _
			"dword", 0x0002, _
			"dword", 5000, _
			"dword_ptr*", 0)

	If $iRet2[0] = 0 Then Return SetError(1)
EndFunc   ;==>_EnvUpdate
;  Authenticity
Func __NetApi_BufferSize($pBuffer)
	Local $aResult = DllCall("Netapi32.dll", "int", "NetApiBufferSize", "ptr", $pBuffer, "uint*", 0)

	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] <> 0 Then Return SetError(-1, $aResult[0], 0)
	Return $aResult[2]
EndFunc   ;==>__NetApi_BufferSize

;  Authenticity
Func __NetApi_BufferFree($pBuffer)
	Local $aResult = DllCall("Netapi32.dll", "int", "NetApiBufferFree", "ptr", $pBuffer)

	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] <> 0 Then Return SetError(-1, $aResult[0], False)
	Return SetError(0, 0, True)
EndFunc   ;==>__NetApi_BufferFree
;=========================================================================================
; 系统个性化定制
;=========================================================================================
;预加载OEM信息
Func preLoadOemInfo($Flag = 1)
	Local $sProdutor, $sPcXh, $sTechHour, $sTechPhone, $sSptSite, $sOemLogo
	If @OSBuild > 6000 Then
		$sProdutor = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer')
		$sPcXh = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model')
		$sTechHour = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours')
		$sTechPhone = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone')
		$sSptSite = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL')
		$sOemLogo = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo')
	Else
		Local $oemIni = @WindowsDir & '\system32\OemInfo.ini'
		If FileExists($oemIni) Then
			Local $Stroem = FileRead($oemIni)
			Local $aTechour = StringRegExp($Stroem, '(\d{1,2}:\d{2}[\d|-]+\d{2}:\d{1,2})', 3)
			If Not @error Then
				$sTechHour = $aTechour[0]
			EndIf
			Local $aTechPhone = StringRegExp($Stroem, '(\d{3}[\d|-]+\d{3})"', 3)
			If Not @error Then
				$sTechPhone = $aTechPhone[0]
			EndIf
			Local $aTechsite = StringRegExp($Stroem, 'http://(.*?)"', 3)
			If Not @error Then
				$sSptSite = $aTechsite[0]
			EndIf
			If FileExists(@WindowsDir & '\system32\oemlogo.bmp') Then $sOemLogo = @WindowsDir & '\system32\oemlogo.bmp'
			$sProdutor = IniRead($oemIni, 'General', 'Manufacturer', '')
			$sPcXh = IniRead($oemIni, 'General', 'Model', '')
		EndIf
	EndIf
	$OEMInfo[0] = $sProdutor
	$OEMInfo[1] = $sPcXh
	$OEMInfo[2] = $sTechPhone
	$OEMInfo[3] = $sTechHour
	$OEMInfo[4] = $sSptSite
	$OEMInfo[5] = $sOemLogo
	If $Flag = 1 Then
		GUICtrlSetData($PcProdutor, $sProdutor)
		GUICtrlSetData($PcXh, $sPcXh)
		GUICtrlSetData($TechHour, $sTechHour)
		GUICtrlSetData($TechPhone, $sTechPhone)
		GUICtrlSetData($SptSite, $sSptSite)
		GUICtrlSetData($OemLogo, $sOemLogo)
		GUICtrlSetData($RegOrg, RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization'))
		GUICtrlSetData($RegUser, RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner'))
	EndIf
EndFunc   ;==>preLoadOemInfo
Func previewOemlogo()
	Local $oembmp = _WinAPI_PathSearchAndQualify(_WinAPI_ExpandEnvironmentStrings(GUICtrlRead($OemLogo)))
	If FileExists($oembmp) = 1 Then
		Global $PreviewDlg = _GUICreate("OEM图片预览", 128, 128, 241, 136, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		GUICtrlCreatePic($oembmp, 0, 0, 127, 127)
		GUICtrlSetOnEvent(-1, 'QuitPreviewDlg')
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitPreviewDlg', $PreviewDlg)
	Else
		MsgBox(0, '提示', '您的OEM图片不存在，请检查！', 3)
	EndIf
EndFunc   ;==>previewOemlogo

Func QuitPreviewDlg()
	GUISetState(@SW_HIDE, $PreviewDlg)
	GUIDelete($PreviewDlg)
EndFunc   ;==>QuitPreviewDlg
Func Selectoemlogo()
	$OemlogoFile = FileOpenDialog('请选择您要设置为oem图标的bmp图像', '', '(*.bmp)位图文件', 1 + 2)
	If FileExists($OemlogoFile) Then
		GUICtrlSetData($OemLogo, $OemlogoFile)
	EndIf
EndFunc   ;==>Selectoemlogo
Func setpcinfo()
	If @OSBuild > 6000 Then
		;计算机制造商名称
		If GUICtrlRead($PcProdutor) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer', 'REG_SZ', GUICtrlRead($PcProdutor))
		EndIf
		;计算机型号
		If GUICtrlRead($PcXh) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model', 'REG_SZ', GUICtrlRead($PcXh))
		EndIf
		;技术支持时间
		If GUICtrlRead($TechHour) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours', 'REG_SZ', GUICtrlRead($TechHour))
		EndIf
		;技术支持电话
		If GUICtrlRead($TechPhone) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone', 'REG_SZ', GUICtrlRead($TechPhone))
		EndIf
		; 技术支持网址
		If GUICtrlRead($SptSite) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL', 'REG_SZ', GUICtrlRead($SptSite))
		EndIf
		;OEMLOGO
		If GUICtrlRead($OemLogo) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo') Then
			Local $WinsatBmp = @TempDir & '\PreOEM\' & _WinAPI_PathFindFileName(StringReplace(GUICtrlRead($OemLogo), '.bmp', '_WINSAT.bmp'))
			FileCopy(GUICtrlRead($OemLogo), @WindowsDir & '\system32\OEM\logo.bmp', 1 + 8)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo', 'REG_SZ', @WindowsDir & '\system32\OEM\logo.bmp')
			;windows体验指数OEM信息
			If FileExists($WinsatBmp) Then
				RunWait(@ComSpec & ' /c del/s/f/q %windir%\system32\OEM\WINSAT.bmp', @WindowsDir, @SW_HIDE)
				FileCopy($WinsatBmp, @WindowsDir & '\system32\OEM\WINSAT.bmp', 1 + 8)
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winsat\WindowsExperienceIndexOemInfo', 'Logo', 'REG_SZ', @WindowsDir & '\system32\OEM\WINSAT.bmp')
			EndIf
		EndIf
		;使windows8及后续版本 显示 技术支持信息
		If @OSBuild > 8000 Then
			Local $sDword = '00000001'
			If @OSBuild > 9000 Then
				$sDword = '00000000'
			EndIf
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'HelpCustomized', 'REG_DWORD', $sDword)
		EndIf
	Else
		Local $OemInfostr = _
				'[General]' & @CRLF & _
				'Manufacturer=' & GUICtrlRead($PcProdutor) & @CRLF & _
				'Model=' & GUICtrlRead($PcXh) & @CRLF & _
				'[Support Information]' & @CRLF & _
				'Line1=" "' & @CRLF & _
				'Line2="为保护您的每一分投资，我公司向您提供"' & @CRLF & _
				'Line3="一系列的服务与支持，当您遇到硬件故障"' & @CRLF & _
				'Line4="和不能解决的软件故障时，请访问我们的"' & @CRLF & _
				'Line5="客户支持网页或者与我公司技术支持热线"' & @CRLF & _
				'Line6="联系，请注意目前仅对中国大陆地区的客"' & @CRLF & _
				'Line7="户提供支持。"' & @CRLF & _
				'Line8="" ' & @CRLF & _
				'Line9="链接：' & GUICtrlRead($SptSite) & '"' & @CRLF & _
				'Line10="电话：' & GUICtrlRead($TechPhone) & '"' & @CRLF & _
				'Line11="      周一至周六 ' & GUICtrlRead($TechHour) & '"' & @CRLF & _
				'Line12="      (服务时间如有改变，恕不另行通知。)"'
		Local $Fh = FileOpen(@WindowsDir & '\System32\oeminfo.ini', 2 + 8)
		FileWrite($Fh, $OemInfostr)
		FileClose($Fh)
		FileCopy(GUICtrlRead($OemLogo), @WindowsDir & '\system32\oemlogo.bmp', 1 + 8)
	EndIf
	;注册组织
	If GUICtrlRead($RegOrg) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization', 'REG_SZ', GUICtrlRead($RegOrg))
	EndIf
	;注册人
	If GUICtrlRead($RegUser) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner', 'REG_SZ', GUICtrlRead($RegUser))
	EndIf
	;修改用户名
	If GUICtrlRead($NewUserName) <> '' And GUICtrlRead($NewUserName) <> GUICtrlRead($ComboUserList) Then
		If GUICtrlRead($ChangeUserFullNameOnly) = $GUI_CHECKED Then
			_SetUserFullName(GUICtrlRead($ComboUserList), GUICtrlRead($NewUserName))
		Else
			_NetUserChangeName(GUICtrlRead($ComboUserList), GUICtrlRead($NewUserName))
		EndIf
		_LoadUserNameToArray()
	EndIf
	;修改计算机名
	If GUICtrlRead($NewPcName) <> '' And GUICtrlRead($NewPcName) <> @ComputerName Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Control\ComputerName\ComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Control\ComputerName\ActiveComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Services\Tcpip\Parameters", "NV Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Services\Tcpip\Parameters", "Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Control\ComputerName\ComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Services\Tcpip\Parameters", "NV Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Services\Tcpip\Parameters", "Hostname", "REG_SZ", GUICtrlRead($NewPcName))
	EndIf
	If GUICtrlRead($NewGroupName) <> $orgGroupName Then
		_SetWorkGroupName(GUICtrlRead($NewGroupName))
	EndIf
	_EnvUpdate()
	preLoadOemInfo(0)
	_ForceUpdate()
	DllCall('WININET.DLL', 'long', 'InternetSetOption', 'int', 0, 'long', 39, 'str', 0, 'long', 0)
	_GUICtrlComboBox_SetCurSel($PreOEMList, 0)
	MsgBox(0, '提示', '您的计算机个性化信息设置完成!', 5)
EndFunc   ;==>setpcinfo
Func _DropHandler()
	If @GUI_DropId = $OemLogo Then
		GUICtrlSetData($OemLogo, '')
		If StringRight(@GUI_DragFile, 4) <> '.bmp' Then
			MsgBox(16, '错误', '您拖放的图片文件不是BMP格式！', 5, $Form1)
		Else
			GUICtrlSetData($OemLogo, @GUI_DragFile)
		EndIf
	EndIf
EndFunc   ;==>_DropHandler
Func LoadPreOEM()
	If Not FileExists(@TempDir & '\OEM.exe') Then FileInstall('.\src\file\OEM.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\OEM.exe', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\OEM.exe')
	If GUICtrlRead($PreOEMList) = "当前品牌" Then
		GUICtrlSetData($PcProdutor, $OEMInfo[0])
		GUICtrlSetData($PcXh, $OEMInfo[1])
		GUICtrlSetData($TechPhone, $OEMInfo[2])
		GUICtrlSetData($TechHour, $OEMInfo[3])
		GUICtrlSetData($SptSite, $OEMInfo[4])
		GUICtrlSetData($OemLogo, $OEMInfo[5])
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Lenovo.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想（新）" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LENOVO_NEW.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想（新1）" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LENOVO_NEW_1.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "宏 碁" Then
		GUICtrlSetData($PcProdutor, "宏碁中国有限公司")
		GUICtrlSetData($PcXh, "宏碁电脑")
		GUICtrlSetData($TechPhone, "400-700-1000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.acer.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Acer.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "三 星" Then
		GUICtrlSetData($PcProdutor, "三星中国有限公司")
		GUICtrlSetData($PcXh, "三星电脑")
		GUICtrlSetData($TechPhone, "400-810-5858")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\SAMSUNG.bmp')
	EndIf

	If GUICtrlRead($PreOEMList) = "惠 普" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "惠普电脑")
		GUICtrlSetData($TechPhone, "800-810-3888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\HP.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "惠 普（新）" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "惠普电脑")
		GUICtrlSetData($TechPhone, "800-810-3888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NewHP.bmp')
	EndIf

	If GUICtrlRead($PreOEMList) = "海 尔" Then
		GUICtrlSetData($PcProdutor, "海尔中国有限公司")
		GUICtrlSetData($PcXh, "海尔电脑")
		GUICtrlSetData($TechPhone, "4006-999-999")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ithaier.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\HAIER.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "戴 尔" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "戴尔电脑")
		GUICtrlSetData($TechPhone, "800-858-2969")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Dell.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "戴 尔（新）" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "戴尔电脑")
		GUICtrlSetData($TechPhone, "800-858-2969")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NewDell.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "华 硕" Then
		GUICtrlSetData($PcProdutor, "华硕中国有限公司")
		GUICtrlSetData($PcXh, "华硕电脑")
		GUICtrlSetData($TechPhone, "400-600-6655")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.asus.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Asus.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "明 基" Then
		GUICtrlSetData($PcProdutor, "明基中国有限公司")
		GUICtrlSetData($PcXh, "明基电脑")
		GUICtrlSetData($TechPhone, "400-888-0666")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.benq.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\BenQ.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "方 正" Then
		GUICtrlSetData($PcProdutor, "方正中国有限公司")
		GUICtrlSetData($PcXh, "方正电脑")
		GUICtrlSetData($TechPhone, "010-82529966")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.founderpc.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Founder.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "同 方" Then
		GUICtrlSetData($PcProdutor, "同方中国有限公司")
		GUICtrlSetData($PcXh, "同方电脑")
		GUICtrlSetData($TechPhone, "800-810-5546")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.tongfangpc.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\TONGFAN.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "东 芝" Then
		GUICtrlSetData($PcProdutor, "东芝中国有限公司")
		GUICtrlSetData($PcXh, "东芝电脑")
		GUICtrlSetData($TechPhone, "400-818-0280")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.Toshiba.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Toshiba.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "康 柏" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "康柏电脑")
		GUICtrlSetData($TechPhone, "800-888-0220")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\ComPaq.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "富士通" Then
		GUICtrlSetData($PcProdutor, "富士通中国有限公司")
		GUICtrlSetData($PcXh, "富士通电脑")
		GUICtrlSetData($TechPhone, "400-820-8387")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.fujtsu.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\FUJITSU.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "LG电子" Then
		GUICtrlSetData($PcProdutor, "LG电子中国有限公司")
		GUICtrlSetData($PcXh, "LG电脑")
		GUICtrlSetData($TechPhone, "400-819-9999")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lg.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LG.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "SONY" Then
		GUICtrlSetData($PcProdutor, "SONY中国有限公司")
		GUICtrlSetData($PcXh, "Sony Computer")
		GUICtrlSetData($TechPhone, "400-810-9000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.sony.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\SONY.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "NEC" Then
		GUICtrlSetData($PcProdutor, "日电(中国)有限公司 NEC (China) Co., Ltd.")
		GUICtrlSetData($PcXh, "NEC Computer")
		GUICtrlSetData($TechPhone, "800-828-7579")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://cn.nec.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NEC.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "IBM（三色标）" Then
		GUICtrlSetData($PcProdutor, "IBM中国有限公司")
		GUICtrlSetData($PcXh, "IBM Computer")
		GUICtrlSetData($TechPhone, "400-810-1818")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ibm.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\IBM_ThreeColor.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "IBM（灰色）" Then
		GUICtrlSetData($PcProdutor, "IBM中国有限公司")
		GUICtrlSetData($PcXh, "IBM Computer")
		GUICtrlSetData($TechPhone, "400-810-1818")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ibm.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\IBM.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "ALIENWARE" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "Alienware Computer")
		GUICtrlSetData($TechPhone, "800-858-2060")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\ALIENWARE.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "ThinkPad" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "ThinkPad Computer")
		GUICtrlSetData($TechPhone, "400-100-6000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com.cn/think")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\THINKPAD.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "微 星" Then
		GUICtrlSetData($PcProdutor, "微星中国有限公司")
		GUICtrlSetData($PcXh, "微星电脑")
		GUICtrlSetData($TechPhone, "400-828-8588")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://cn.msi.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\MSI.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "Gateway" Then
		GUICtrlSetData($PcProdutor, "Gateway.Inc")
		GUICtrlSetData($PcXh, "Gateway电脑")
		GUICtrlSetData($TechPhone, "400-700-9888")
		GUICtrlSetData($TechHour, "9:00－18:00")
		GUICtrlSetData($SptSite, "http://cn.gateway.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\GATEWAY.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "Terrans Force" Then
		GUICtrlSetData($PcProdutor, "Terrans Force.Inc")
		GUICtrlSetData($PcXh, "未来人类(Terrans Force)系列电脑")
		GUICtrlSetData($TechPhone, "400-887-8912")
		GUICtrlSetData($TechHour, "工作日:9:00－17:00")
		GUICtrlSetData($SptSite, "http://www.terransforce.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\terransforce.bmp')
	EndIf
;~ 	Surface|VMWARE|VirtualBox
	If GUICtrlRead($PreOEMList) = "Surface" Then
		GUICtrlSetData($PcProdutor, "Microsoft Corporation")
		GUICtrlSetData($PcXh, "Microsoft Surface")
		GUICtrlSetData($TechPhone, "U.S./Canada: 1-800-Microsoft (642-7676); Mexico: 01 800 123 3353")
		GUICtrlSetData($TechHour, "工作日:9:00－17:00")
		GUICtrlSetData($SptSite, "http://www.microsoft.com/surface")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\surface.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "VMWARE" Then
		GUICtrlSetData($PcProdutor, "VMware.Inc")
		GUICtrlSetData($PcXh, "VMWARE Machine")
		GUICtrlSetData($TechPhone, "")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "http://www.vmware.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\VMWARE.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "VirtualBox" Then
		GUICtrlSetData($PcProdutor, "VirtualBox")
		GUICtrlSetData($PcXh, "VirtualBox Machine")
		GUICtrlSetData($TechPhone, "1-800-633-1058")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "https://www.virtualbox.org")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\VBOX.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "X62" Then
		GUICtrlSetData($PcProdutor, "51nb.com")
		GUICtrlSetData($PcXh, "X62 Classic")
		GUICtrlSetData($TechPhone, "")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "http://forum.51nb.com/forum.php")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\X62.bmp')
	EndIf
EndFunc   ;==>LoadPreOEM

Func _SetBckDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $Is_Moved = False
	Global $SetBkgForm = _GUICreate("登录界面设置", 405, 80, 100, 80, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("图片文件路径设置", 8, 8, 313, 65)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlCreateLabel("图片路径", 16, 32, 52, 17)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Global $Bkg_Path = GUICtrlCreateInput("", 72, 32, 209, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	GUICtrlCreateButton("...", 281, 30, 35, 25)
	GUICtrlSetOnEvent(-1, '_SelectBkgPic')
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("应用", 328, 16, 67, 25)
	GUICtrlSetTip(-1, '将预览图片设置为登录背景，按下' & @LF & 'shift键可以删除登录背景', '提示', 1)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, '_SetBG')
	GUICtrlCreateButton("预览", 328, 48, 67, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, '_Preview')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitSetBkgForm')
	GUISetOnEvent($GUI_EVENT_DROPPED, '_PicDropEvent', $SetBkgForm)
EndFunc   ;==>_SetBckDlg

Func QuitSetBkgForm()
	GUISetState(@SW_HIDE, $SetBkgForm)
	GUIDelete($SetBkgForm)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitSetBkgForm

Func _VFile()
	If Not FileExists(GUICtrlRead($Bkg_Path)) Then
		MsgBox(16, '错误', '登录界面背景图片不存在！', 5, $SetBkgForm)
		Return False
	Else
		Return True
	EndIf
	If StringRight(GUICtrlRead($Bkg_Path), 4) <> '.jpg' Then
		MsgBox(16, '错误', '登录界面背景图片只能为JPG格式！', 5, $SetBkgForm)
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_VFile

Func _SelectBkgPic()
	Local $bkgjpg = FileOpenDialog('请选择要设置为登录背景的图片文件', '', 'JPG图片文件(*.jpg)', 1, '', $SetBkgForm)
	If FileExists($bkgjpg) Then
		GUICtrlSetData($Bkg_Path, $bkgjpg)
	EndIf
EndFunc   ;==>_SelectBkgPic
Func _Preview()
	Local $bkgjpg = GUICtrlRead($Bkg_Path)
	Local $b = _VFile()
	If $b = False Then
		Return 0
	EndIf
	If $Is_Moved = False Then
		Local $pos = WinGetPos('登录界面设置')
		WinMove('登录界面设置', '', $pos[0], $pos[1] - 120, $pos[2], 372)
		Global $PreviewUI = GUICtrlCreatePic("", 8, 80, 388, 260)
		GUICtrlSetTip(-1, '点击预览图可以关闭预览界面滴哦！', '提示', 1)
		GUICtrlSetResizing(-1, $GUI_DOCKALL)
		GUICtrlSetState(-1, $GUI_DROPACCEPTED)
		GUICtrlSetOnEvent(-1, '_RestoreOldSize')
		$Is_Moved = True
	EndIf
	If FileExists($bkgjpg) Then
		GUICtrlSetImage($PreviewUI, $bkgjpg)
	EndIf
EndFunc   ;==>_Preview
Func _PicDropEvent()
	If FileExists(@GUI_DragFile) Then
		GUICtrlSetData($Bkg_Path, '')
		If StringRight(@GUI_DragFile, 4) <> '.jpg' Then
			MsgBox(16, '错误', '登录界面背景图片只能为JPG格式！', 5, $SetBkgForm)
		Else
			GUICtrlSetData($Bkg_Path, @GUI_DragFile)
			If IsDeclared('PreviewUI') Then
				GUICtrlSetImage($PreviewUI, @GUI_DragFile)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_PicDropEvent
Func _RestoreOldSize()
	If $Is_Moved = True Then
		GUICtrlSetState($PreviewUI, $GUI_HIDE)
		GUICtrlDelete($PreviewUI)
		Local $pos = WinGetPos('登录界面设置')
		WinMove('登录界面设置', '', $pos[0], $pos[1] + 120, $pos[2], 110)
		$Is_Moved = False
	EndIf
EndFunc   ;==>_RestoreOldSize

Func _SetBG()
	If _IsPressed("10") Then
		DirRemove(@SystemDir & "\oobe\info\Backgrounds", 1)
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background", "OEMBackground", "REG_DWORD", "00000000")
		MsgBox(0, '提示', '删除登录背景成功！', 5, $SetBkgForm)
	Else
		Local $LOGOOEM = GUICtrlRead($Bkg_Path)
		Local $b = _VFile()
		If $b = False Then
			Return 0
		EndIf
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background", "OEMBackground", "REG_DWORD", "00000001")
		DirCreate(@SystemDir & "\oobe\info\Backgrounds")
		FileCopy($LOGOOEM, @SystemDir & "\oobe\info\Backgrounds\BACKGROUNDDEFAULT.jpg", 1)
		MsgBox(0, '提示', '将选定图片设置为登录背景成功！', 5, $SetBkgForm)
	EndIf
EndFunc   ;==>_SetBG
