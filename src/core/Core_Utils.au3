;==============================================================================
; 模块：通用工具库
; 说明：字符串/数组/路径处理、系统与硬件信息探测、编解码等与业务无关的工具函数
; 文件：src\core\Core_Utils.au3
; 函数：共 21 个
;==============================================================================
#include-once

;获取用户SID值
Func GetUserSID()
	Local $KeyValue = _Security__LookupAccountName(@UserName)
	Return $KeyValue[0]
EndFunc   ;==>GetUserSID
;获取盘符
Func getDriveInfo()
	Local $adriveFix, $i, $result
	$adriveFix = DriveGetDrive('Fixed')
	For $i In $adriveFix
		If DriveStatus($i) = 'ready' Then
			$result &= StringUpper($i) & '|'
		EndIf
	Next
	$result &= '浏览...'
	GUICtrlSetData($TargetDrive, $result)
EndFunc   ;==>getDriveInfo
;判断当前计算机类型
Func _VMDetect()
	Local $strComputer = ".", $sMake, $sModel, $sBIOSVersion, $bIsVM, $sVMPlatform
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")
	If IsObj($colItems) Then
		For $objItem In $colItems
			$sModel = $objItem.Model
		Next
	EndIf

	$sVMPlatform = ""
	If $sModel = "Virtual Machine" Then
		; Microsoft virtualization technology detected, assign defaults
		$sVMPlatform = "Hyper-V"
		; Try to determine more specific values
		Switch $sBIOSVersion
			Case "VRTUAL - 1000831"
				$sVMPlatform = "Hyper-V 2008 Beta 或 RC0"
			Case "VRTUAL - 5000805", "BIOS Date: 05/05/08 20:35:56  Ver: 08.00.02"
				$sVMPlatform = "Hyper-V 2008 RTM"
			Case "VRTUAL - 3000919"
				$sVMPlatform = "Hyper-V 2008 R2"
			Case "A M I  - 2000622"
				$sVMPlatform = "VS2005R2SP1 或 VPC2007"
			Case "A M I  - 9000520"
				$sVMPlatform = "VS2005R2"
			Case "A M I  - 9000816", "A M I  - 6000901"
				$sVMPlatform = "Windows Virtual PC"
			Case "A M I  - 8000314"
				$bIsVM = True
				$sVMPlatform = "VS2005 或 VPC2004"
		EndSwitch
	ElseIf $sModel = "VMware Virtual Platform" Then
		; VMware detected
		$sVMPlatform = "VMware"
	ElseIf $sModel = "VirtualBox" Then
		; VirtualBox detected
		$sVMPlatform = "VirtualBox"
	Else
	EndIf
	If $sVMPlatform <> '' Then
		Return $sVMPlatform & '虚拟机'
	Else
		Return ''
	EndIf
EndFunc   ;==>_VMDetect
Func DetecPcType()
	If $HasSSD Then
		$iComputerType = @TempDir & '\SSD.bmp'
	Else
		$iComputerType = @TempDir & '\HDD.bmp'
	EndIf
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $Biosinfo = "", $FlagDetail = 0
	Local $strComputer = "localhost"
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT Vendor,Name,Version,IdentifyingNumber FROM Win32_ComputerSystemProduct", "WQL", _
			$wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			If StringInStr(_RemoveWS($objItem.Name), ' ') Then
				$Biosinfo = _CamelStr($objItem.Vendor) & ' ' & _RemoveWS($objItem.Name)
				$FlagDetail = 1
			EndIf
			If StringInStr(_RemoveWS($objItem.Version), ' ') Then
				$Biosinfo = _CamelStr($objItem.Vendor) & ' ' & _RemoveWS($objItem.Version)
				$FlagDetail = 1
			EndIf
			If $FlagDetail = 0 Then
				$Biosinfo = _CamelStr($objItem.Vendor)
			EndIf
			If $objItem.IdentifyingNumber <> '' Then $IdentifyingNumber = $objItem.IdentifyingNumber
		Next
	EndIf
	$colChassis = $objWMIService.ExecQuery('Select * from Win32_SystemEnclosure')
	For $objChassis In $colChassis
		For $strChassisType In $objChassis.ChassisTypes
			;笔记本
			If $strChassisType = 8 Or $strChassisType = 9 Or $strChassisType = 10 Then
				If $Biosinfo <> '' Then
					If StringInStr($Biosinfo, '51nb') Or $Biosinfo == 'Ibm' Then
						$Biosinfo = 'X62 Classic'
					EndIf
					$PcType &= $Biosinfo & "笔记本"
				Else
					$PcType &= "笔记本"
				EndIf
			EndIf
			;台式机
			If $strChassisType = 3 Or $strChassisType = 4 Or $strChassisType = 5 Or $strChassisType = 6 Or $strChassisType = 7 Then
				If $Biosinfo <> '' Then
					$PcType &= $Biosinfo & "台式电脑"
				Else
					$PcType &= "台式电脑"
				EndIf
			EndIf
		Next
	Next
	If $PcType = '' Then
		$PcType = _VMDetect()
		If $PcType = '' Then
			$PcType &= '不明物体'
		EndIf
	EndIf

EndFunc   ;==>DetecPcType

Func _CamelStr($sCamel)
	Local $FirstLeter = StringUpper(StringLeft($sCamel, 1))
	Return $FirstLeter & StringTrimLeft(StringLower($sCamel), 1)
EndFunc   ;==>_CamelStr
Func _RemoveWS($strToWs)
	Return StringStripWS(StringStripWS($strToWs, 2), 1)
EndFunc   ;==>_RemoveWS
Func RemoveDuplicateStr($sToRemove)
	Local $sResult = StringRegExpReplace($sToRemove, '(.*?\s+)\1+', '$1')
	Return $sResult
EndFunc   ;==>RemoveDuplicateStr

Func GetOSVersion()
	$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	$colItems = $objWMIService.ExecQuery("Select Caption,Version from Win32_OperatingSystem")
	For $os In $colItems
		If $os.Caption & " " & $os.Version <> '' Then
			If @OSArch = 'X64' Then
				$osfullversion = $os.Caption & '(64位)'
			EndIf
			If @OSArch = 'X86' Then
				$osfullversion = $os.Caption & '(32位)'
			EndIf
		Else
			$osfullversion = @OSVersion & '' & @OSBuild & '' & @OSArch
		EndIf
	Next
EndFunc   ;==>GetOSVersion
;~ $option 说明：
;~ 4       不显示进度条
;~ 8       如果目标路径存在相同源文件或目录则自动修改名称，如：复件 autoit3
;~ 16       显示任何对话框都点击"全是"
;~ 64       如果可能的话,保留撤销信息，
;~ 128      执行该操作仅当通配符指定文件名(*.*)。
;~ 256     显示进度条但不显示文件名（复制目录时不显示）
;~ 512     如果操作需要建立一个新目录，不确认建立一个新目录
;~ 1024    如果出现错误,不显示用户界面，
;~ 4096    禁用递归
;~ 8192    不复制的一组连接的文件。仅复制指定的文件
Func _FileCopy($fromFile, $ToDir, $option = 16)
	$winShell = ObjCreate("shell.application")
	If Not FileExists($ToDir) Then
		DirCreate($ToDir)
	EndIf
	$winShell.namespace($ToDir).CopyHere($fromFile, $option)
EndFunc   ;==>_FileCopy
Func _FileMove($fromFile, $ToDir, $option = 16)
	$winShell = ObjCreate("shell.application")
	If Not FileExists($ToDir) Then
		DirCreate($ToDir)
	EndIf
	$winShell.namespace($ToDir).MoveHere($fromFile, $option)
EndFunc   ;==>_FileMove
Func _GetDirNameFromStr($sdir)
	Local $smatch = StringRegExp($sdir, '[^\\]*$', 3)
	If Not @error Then
		Return $smatch[0]
	EndIf
EndFunc   ;==>_GetDirNameFromStr

#cs
	SSD优化
#ce


;关闭SSD的节能功能
Func _IsProcessorFeaturePresent($iFeature)
	#cs
		_IsProcessorFeaturePresent(7) ; PF_3DNOW_INSTRUCTIONS_AVAILABLE
		_IsProcessorFeaturePresent(6) ; PF_XMMI_INSTRUCTIONS_AVAILABLE (SSE)
		_IsProcessorFeaturePresent(10) ; PF_XMMI64_INSTRUCTIONS_AVAILABLE (SSE2)
	#ce
	; http://msdn.microsoft.com/en-us/library/ms724482%28v=VS.85%29.aspx
	$iRes = DllCall("Kernel32.dll", "int", "IsProcessorFeaturePresent", "DWORD", $iFeature)
	Return $iRes[0]
EndFunc   ;==>_IsProcessorFeaturePresent

Func _CPUType()
	Local $s_CPU_Detected = "Unknown CPU"
	If _IsProcessorFeaturePresent(7) Then
		$s_CPU_Detected = "AMD"
	ElseIf _IsProcessorFeaturePresent(10) Then
		$s_CPU_Detected = "Intel"
	ElseIf _IsProcessorFeaturePresent(6) Then
		$s_CPU_Detected = "Intel"
	EndIf
	Return $s_CPU_Detected
EndFunc   ;==>_CPUType
Func UnsignedHexToDec($_Data)
	Return Dec(StringTrimRight($_Data, 1)) * 16 + Dec(StringRight($_Data, 1))
EndFunc   ;==>UnsignedHexToDec

Func _WinAPI_Base64Decode($sB64String)
	Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
	Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
	$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($bBuffer, 1)
EndFunc   ;==>_WinAPI_Base64Decode
Func _WinAPI_LZNTDecompress(ByRef $tInput, ByRef $tOutput, $iBufferSize)
	$tOutput = DllStructCreate("byte[" & $iBufferSize & "]")
	If @error Then Return SetError(1, 0, 0)
	Local $aRet = DllCall("ntdll.dll", "uint", "RtlDecompressBuffer", "ushort", 0x0002, "struct*", $tOutput, "ulong", $iBufferSize, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "ulong*", 0)
	If @error Then Return SetError(2, 0, 0)
	If $aRet[0] Then Return SetError(3, $aRet[0], 0)
	Return $aRet[6]
EndFunc   ;==>_WinAPI_LZNTDecompress
;检测是否有ssd硬盘
Func HasSSD()
	;经过测试，NT5使用ssd检测会蓝屏，故屏蔽
	If @OSBuild > 6000 Then
		Local $aDrive = DriveGetDrive('ALL')
		For $i In $aDrive
			If DriveGetType($i, 2) = 'SSD' Then
				Return True
				ExitLoop
			EndIf
		Next
	EndIf
	Return False
EndFunc   ;==>HasSSD

Func GetTotalKSize($size)
	Local $aTest = StringRegExp($size, '\d+', 3)
	Local $num = $aTest[0]
	Local $TotalK = 0
	If StringInStr($size, 'KB') Then $TotalK = $num * 1024
	If StringInStr($size, 'MB') Then $TotalK = $num * 1024 * 1024
	If StringInStr($size, 'GB') Then $TotalK = $num * 1024 * 1024 * 1024
	Return $TotalK
EndFunc   ;==>GetTotalKSize

Func s2er($iResult)
	If $iResult Then
		Return 0
	Else
		$iResult = DllCall("Kernel32.dll", "long", "GetLastError")

		Return $iResult[0]
	EndIf
EndFunc   ;==>s2er
Func _XML_GetElementsByTag($sSource, $sTag = "", $fIsCDATA = Default)
	Local $aMatches
	$sTag = ($sTag ? '\Q' & $sTag & '\E.*?' : '\w+?')

	$aMatches = StringRegExp($sSource, '(?s)' & _
			'<' & $sTag & '>' & ($fIsCDATA ? '<!\[CDATA\[' : '') & _ ; beginning
			'(.*?)' & _ ; body
			($fIsCDATA ? ']]>' : '') & '</' & $sTag & '>', 3) ;         ending
	If @error Then Return SetError(1, 0, "")

	If Not $fIsCDATA Then
		For $i = 0 To UBound($aMatches) - 1
			$aMatches[$i] = (StringLeft($aMatches[$i], 9) = '<![CDATA[' ? StringMid($aMatches[$i], 10, StringLen($aMatches[$i]) - 12) : $aMatches[$i])
		Next
	EndIf

	Return $aMatches
EndFunc   ;==>_XML_GetElementsByTag

Func IsUEFIBoot()
	Local Const $ERROR_INVALID_FUNCTION = 0x1
	Local $hDLL = DllOpen("Kernel32.dll")
	If @OSBuild > 8000 Then
		Local $aCall = DllCall($hDLL, "int", "GetFirmwareType", "int*", 0)
		DllClose($hDLL)
		If Not @error And $aCall[0] Then
			Switch $aCall[1]
				; 1 - bios 2- uefi 3-unknown
				Case 2
					Return True
				Case Else
					Return False
			EndSwitch
		EndIf
		Return False


	Else
		DllCall($hDLL, "dword", "GetFirmwareEnvironmentVariableW", "wstr", "", "wstr", '{00000000-0000-0000-0000-000000000000}', "wstr", Null, "dword", 0)
		DllClose($hDLL)
		If _WinAPI_GetLastError() = $ERROR_INVALID_FUNCTION Then
			Return False
		Else
			Return True
		EndIf
	EndIf
EndFunc   ;==>IsUEFIBoot
