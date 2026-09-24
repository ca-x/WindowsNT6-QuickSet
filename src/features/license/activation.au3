;==============================================================================
; 模块：系统激活
; 说明：BIOS/UEFI 激活、KMS、HWIDGen、OEM 证书备份与安装
; 文件：src\features\license\activation.au3
; 函数：共 13 个
;==============================================================================
#include-once

Func _BiosTool()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	$ActForm = _GUICreate("BIOS辅助工具", 265, 71, 172, 135, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("", 8, 8, 249, 49)
	GUICtrlCreateButton("BIOS SLIC动态加载工具", 16, 24, 139, 25)
	GUICtrlSetTip(-1, '动态加载SLIC文件，模拟OEM', '提示', 1)
	GUICtrlSetOnEvent(-1, '_RunDBSLDR')
	Global $BtnBAKBIOS = GUICtrlCreateButton("备份BIOS及证书", 160, 24, 91, 25)
	GUICtrlSetTip(-1, '证书及BIOS等信息辅助工具，请右键' & @LF & '选择所需选项进行执行', '提示', 1)
	$MBiosTool = GUICtrlCreateContextMenu($BtnBAKBIOS)
	GUICtrlCreateMenuItem('备份BIOS及证书', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'BackupInfo')
	GUICtrlSetTip(-1, '备份BIOS文件、证书、密匙等信息')
	GUICtrlCreateMenuItem('安装OEM证书及密匙[如果可用]', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'InstallOEMCertKey')
	GUICtrlCreateMenuItem('手工执行BIOS.exe', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'ManualRunBiosTool')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'quitForm')
EndFunc   ;==>_BiosTool
Func BackupInfo()
	GUICtrlSetState($BtnBAKBIOS, $GUI_DISABLE)
	FileInstall('.\src\file\bios.exe', @TempDir & '\', 1)
	Local $dir = FileSelectFolder("请选择您要备份的证书和BIOS文件夹位置", "", 1 + 4)
	If FileExists($dir) = 1 And StringInStr(FileGetAttrib($dir), 'D') = 1 Then
		FileCopy(@TempDir & '\bios.exe', $dir, 1)
		TrayTip('提示', '正在进行备份，请稍后..', 5, 1)
		Local $cmd = Run($dir & '\bios.exe  /DUMP', $dir, @SW_HIDE, $STDOUT_CHILD)
		ProcessWaitClose($cmd)
		Local $result = StdoutRead($cmd)
		If $result <> '' Then
			MsgBox(0, '提示', '恭喜您！您的计算机为品牌为' & $result & @LF & '已经成功备份系统的激活信息到文件夹' & $dir & '!')
		EndIf
		FileDelete($dir & '\bios.exe')
	Else
		MsgBox(0, '', '请选择正确的文件夹')
	EndIf
	GUICtrlSetState($BtnBAKBIOS, $GUI_ENABLE)
EndFunc   ;==>BackupInfo
Func InstallOEMCertKey()
	GUICtrlSetState($BtnBAKBIOS, $GUI_DISABLE)
	FileInstall('.\src\file\bios.exe', @TempDir & '\', 1)
	TrayTip('提示', '正在安装证书及密匙，请稍后..', 5, 1)
	RunWait(@TempDir & '\bios.exe /CERT/KEY', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\bios.exe')
	TrayTip('', '', 1)
	GUICtrlSetState($BtnBAKBIOS, $GUI_ENABLE)
	MsgBox(0, '提示', '已经成功安装OEM证书及密匙~', 5)
EndFunc   ;==>InstallOEMCertKey
Func ManualRunBiosTool()
	FileInstall('.\src\file\bios.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\bios.exe')
	FileDelete(@TempDir & '\bios.exe')
EndFunc   ;==>ManualRunBiosTool
Func _RunDBSLDR()
	FileInstall('.\src\file\DBSLDR.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\DBSLDR.exe')
	FileDelete(@TempDir & '\DBSLDR.exe')
EndFunc   ;==>_RunDBSLDR
Func KMSVLALL()
	GUICtrlSetState($kmsvlbtn, $GUI_DISABLE)
	PreFiles()
	FileDelete(@TempDir & '\HWIDGen.exe')
	GUICtrlSetState($kmsvlbtn, $GUI_ENABLE)
EndFunc   ;==>KMSVLALL

Func PreFiles()
	FileInstall('.\src\file\HWIDGen.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\HWIDGen.exe', @TempDir, @SW_HIDE)
EndFunc   ;==>PreFiles

Func _UEFIActor()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $UEFIForm = _GUICreate("UEFI激活辅助工具", 361, 47, 124, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("安装UEFI激活", 4, 10, 91, 25)
	GUICtrlSetOnEvent(-1, '_InstallUEFI')
	GUICtrlCreateButton("卸载UEFI激活", 96, 10, 251, 25)
	GUICtrlSetOnEvent(-1, '_UnInstallUEFI')
	GUICtrlCreateGroup("", 2, 2, 353, 37)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitUEFIForm')
EndFunc   ;==>_UEFIActor
Func QuitUEFIForm()
	_WinAPI_AnimateWindow($UEFIForm, BitOR($AW_BLEND, $AW_HIDE), 500)
	GUIDelete($UEFIForm)
	FileDelete(@TempDir & '\KMS_VL_ALL.exe')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitUEFIForm
Func _InstallUEFI()
	_Installer_EFI_cli()
	_AcerLicFile()
	Local $sCMD = '@ECHO OFF' & @CRLF & _
			'SET SLMGR=cscript //NOLOGO "%SYSTEMROOT%\System32\slmgr.vbs"' & @CRLF & _
			'SET BCDEDIT=%SYSTEMROOT%\System32\bcdedit.exe' & @CRLF & _
			'SET /a COUNT=0' & @CRLF & _
			'ECHO removing boot entry.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'%BCDEDIT% /set {bootmgr} path "\EFI\Microsoft\Boot\bootmgfw.efi" >nul' & @CRLF & _
			'FOR /F "tokens=2" %%A IN (''%BCDEDIT% /enum BOOTMGR ^| FINDSTR /I /R /C:"{........-.*}"'') DO (' & @CRLF & _
			'	%BCDEDIT% /enum %%A | FIND /I "\EFI\WindSLIC\BOOTX64.EFI" >nul' & @CRLF & _
			'	IF NOT !ERRORLEVEL!==1 (' & @CRLF & _
			'		SET /A COUNT=%COUNT%+1' & @CRLF & _
			'		ECHO found WindSLIC boot entry.' & @CRLF & _
			'		ECHO deleting %%A' & @CRLF & _
			'		%BCDEDIT% /delete %%A >nul' & @CRLF & _
			'		ECHO setting boot order.' & @CRLF & _
			'		%BCDEDIT% /set {fwbootmgr} displayorder {bootmgr} /addfirst >nul' & @CRLF & _
			'	)' & @CRLF & _
			')' & @CRLF & _
			'IF %COUNT%==0 ECHO WindSLIC boot entry not found.' & @CRLF & _
			'"%~dp0Installer_EFI_cli.exe"' & @CRLF & _
			'ECHO installing certificate...' & @CRLF & _
			'%SLMGR% -ilc "%~dp0ACER.XRM-MS" >nul' & @CRLF & _
			'ECHO installing key.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'CALL :PRODUCT_VER_CHECK' & @CRLF & _
			'%SLMGR% -ipk %PID_KEY% >nul' & @CRLF & _
			'ECHO restart computer to finish activation.' & @CRLF & _
			'timeout 5' & @CRLF & _
			'EXIT' & @CRLF & _
			':PRODUCT_VER_CHECK' & @CRLF & _
			'   REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName" | FINDSTR /C:"Windows 7" >nul' & @CRLF & _
			'   IF ERRORLEVEL 1 ECHO ERROR: not Windows 7 & PAUSE & EXIT' & @CRLF & _
			'   FOR /F "tokens=3" %%A IN (''REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID"'') DO SET EditionID=%%A' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Starter" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :STARTER_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "HomeBasic" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :HOMEBASIC_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "HomePremium" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :HOMEPREMIUM_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Professional" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :PROFESSIONAL_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Ultimate" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :ULTIMATE_KEY & GOTO :EOF' & @CRLF & _
			'   IF ERRORLEVEL 1 ECHO ERROR: OS is unsupported & PAUSE & EXIT' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':STARTER_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=RDJXR-3M32B-FJT32-QMPGB-GCFF6' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=6K6WB-X73TD-KG794-FJYHG-YCJVG' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=36Q3Y-BBT84-MGJ3H-FT7VD-FG72J' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=RH98C-M9PW4-6DHR7-X99PJ-3FGDB' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=273P4-GQ8V6-97YYM-9YTHF-DC2VP' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':HOMEBASIC_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=MB4HF-2Q8V3-W88WR-K7287-2H4CP' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=89G97-VYHYT-Y6G8H-PJXV6-77GQM' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=36T88-RT7C6-R38TQ-RV8M9-WWTCY' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=DX8R9-BVCGB-PPKRR-8J7T4-TJHTH' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=22MFQ-HDH7V-RBV79-QMVK9-PTMXQ' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':HOMEPREMIUM_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=VQB3X-Q3KP8-WJ2H8-R6B6D-7QJB7' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=38JTJ-VBPFW-XFQDR-PJ794-8447M' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=2QDBX-9T8HR-2QWT6-HCQXJ-9YQTR' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=7JQWQ-K6KWQ-BJD6C-K3YVH-DVQJG' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=6RBBT-F8VPQ-QCPVQ-KHRB8-RMV82' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':PROFESSIONAL_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=YKHFT-KW986-GK4PY-FDWYH-7TP9F' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=2WCJK-R8B4Y-CWRF2-TRJKB-PV9HW' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=32KD2-K9CTF-M3DJT-4J3WC-733WD' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=PT9YK-BC2J9-WWYF9-R9DCR-QB9CK' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=862R9-99CD6-DD6WM-GHDG2-Y8M37' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':ULTIMATE_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=FJGCP-4DFJD-GJY49-VJBQ7-HYRR2' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=VQ3PY-VRX6D-CBG4J-8C6R2-TCVBD' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=2Y4WT-DHTBF-Q6MMK-KYK6X-VKM6G' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=342DG-6YJR8-X92GV-V7DCV-P4K27' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=78FPJ-C8Q77-QV7B8-9MH3V-XXBTK' & @CRLF & _
			'GOTO :EOF'
	Local $FhcmdFile = FileOpen(@TempDir & '\UEFIInstall.bat', 2 + 8)
	FileWrite($FhcmdFile, $sCMD)
	FileClose($FhcmdFile)
	Run(@TempDir & '\UEFIInstall.bat')
EndFunc   ;==>_InstallUEFI
Func _UnInstallUEFI()
	_Installer_EFI_cli()
	_AcerLicFile
	Local $sCMD = '@ECHO OFF' & @CRLF & _
			'SETLOCAL ENABLEDELAYEDEXPANSION' & @CRLF & _
			'SET BCDEDIT=%SYSTEMROOT%\System32\bcdedit.exe' & @CRLF & _
			'SET FREEDRIVELETTER=0' & @CRLF & _
			'SET /a COUNT=0' & @CRLF & _
			'::' & @CRLF & _
			'ECHO removing boot entry.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'%BCDEDIT% /set {bootmgr} path "\EFI\Microsoft\Boot\bootmgfw.efi" >nul' & @CRLF & _
			'FOR /F "tokens=2" %%A IN (''%BCDEDIT% /enum BOOTMGR ^| FINDSTR /I /R /C:"{........-.*}"'') DO (' & @CRLF & _
			'	%BCDEDIT% /enum %%A | FIND /I "\EFI\WindSLIC\BOOTX64.EFI" >nul' & @CRLF & _
			'	IF NOT !ERRORLEVEL!==1 (' & @CRLF & _
			'		SET /A COUNT=%COUNT%+1' & @CRLF & _
			'		ECHO found WindSLIC boot entry.' & @CRLF & _
			'		ECHO deleting %%A' & @CRLF & _
			'		%BCDEDIT% /delete %%A >nul' & @CRLF & _
			'		ECHO setting boot order.' & @CRLF & _
			'		%BCDEDIT% /set {fwbootmgr} displayorder {bootmgr} /addfirst >nul' & @CRLF & _
			'	)' & @CRLF & _
			')' & @CRLF & _
			'IF %COUNT%==0 ECHO WindSLIC boot entry not found.' & @CRLF & _
			'"%~dp0Installer_EFI_cli.exe" /u' & @CRLF & _
			'timeout 5'
	Local $FhcmdFile = FileOpen(@TempDir & '\UEFIUnInstall.bat', 2 + 8)
	FileWrite($FhcmdFile, $sCMD)
	FileClose($FhcmdFile)
	Run(@TempDir & '\UEFIUnInstall.bat')
EndFunc   ;==>_UnInstallUEFI

Func KMS10()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	FileInstall('.\src\file\KMS10.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\KMS10.exe')
	FileDelete(@TempDir & '\KMS10.exe')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>KMS10

Func ReadOEMKEY()
	Local $sKey[29], $Value = 0, $hi = 0, $n = 0, $i = 0, $dlen = 29, $slen = 15, $result, $bKey, $iKeyOffset = 52, $Regkey
	$bKey = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "DigitalProductId")
	If Not BinaryLen($bKey) Then Return ""
	Local $aKeys[BinaryLen($bKey)]
	For $i = 0 To UBound($aKeys) - 1
		$aKeys[$i] = Int(BinaryMid($bKey, $i + 1, 1))
	Next
	Local Const $isWin8 = BitAND(BitShift($aKeys[$iKeyOffset + 14], 3), 1)
	$aKeys[$iKeyOffset + 14] = BitOR(BitAND($aKeys[$iKeyOffset + 14], 0xF7), BitShift(BitAND($isWin8, 2), -2))
	$i = 24
	Local $sChars = "BCDFGHJKMPQRTVWXY2346789", $iCur, $iX, $sKeyOutput, $iLast
	While $i > -1
		$iCur = 0
		$iX = 14
		While $iX > -1
			$iCur = BitShift($iCur, -8)
			$iCur = $aKeys[$iX + $iKeyOffset] + $iCur
			$aKeys[$iX + $iKeyOffset] = Int($iCur / 24)
			$iCur = Mod($iCur, 24)
			$iX -= 1
		WEnd
		$i -= 1
		$sKeyOutput = StringMid($sChars, $iCur + 1, 1) & $sKeyOutput
		$iLast = $iCur
	WEnd
	If $isWin8 Then
		$sKeyOutput = StringMid($sKeyOutput, 2, $iLast) & "N" & StringTrimLeft($sKeyOutput, $iLast + 1)
	EndIf
	Local $Key = StringRegExpReplace($sKeyOutput, '(\w{5})(\w{5})(\w{5})(\w{5})(\w{5})', '\1-\2-\3-\4-\5')
	If $Key = '' Then
		MsgBox(16, '错误', '未能读取到系统密匙信息！', 5)
	Else
		If MsgBox(4, '提示', '已经成功读取系统密匙信息为' & @LF & $Key & @LF & '是否复制到剪切板？', 5) = 6 Then
			ClipPut($Key)
			MsgBox(0, '提示', '已经复制系统密匙到剪切板，请妥善保存！', 5)
		EndIf
	EndIf
EndFunc   ;==>ReadOEMKEY
