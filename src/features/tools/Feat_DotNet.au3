;==============================================================================
; 模块：.NET Framework 3.5
; 说明：从安装介质安装 .NET 3.5
; 文件：src\features\tools\Feat_DotNet.au3
; 函数：共 6 个
;==============================================================================
#include-once


Func InstallNetFrame35UI()
	Global $FormInsdotNet = _GUICreate("Windows8.1+.NET Framework3.5安装工具", 368, 109, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择Windows8.1+源安装盘", 8, 8, 353, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $InsSourceDriveList = GUICtrlCreateCombo("", 16, 24, 337, 25, BitOR($CBS_DROPDOWNLIST, $WS_HSCROLL))
	GUICtrlSetData(-1, "")
	$MSetCustomDir = GUICtrlCreateContextMenu($InsSourceDriveList)
	GUICtrlCreateMenuItem('添加自定义目录进行安装', $MSetCustomDir)
	GUICtrlSetOnEvent(-1, 'AddCustomSourceDir')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Btn_installdotnet35 = GUICtrlCreateButton("从源安装盘安装.NET Framework3.5", 8, 74, 355, 25, BitOR($BS_DEFPUSHBUTTON, $BS_PUSHLIKE))
	GUICtrlSetOnEvent(-1, '_InstallNF35Frommedia')
	Global $ShowCMD = GUICtrlCreateCheckbox("显示命令行界面", 8, 56, 113, 17)
	GUICtrlSetTip(-1, '勾选此选项将显示命令提示符界面以便查看进度', '说明', 1)
	Global $LimitAccess = GUICtrlCreateCheckbox("安装时不检查更新服务器", 128, 56, 169, 17)
	GUICtrlSetTip(-1, '勾选此选项将部分提高安装的速度', '说明', 1)
	GUISetState(@SW_SHOW)
	_GetSourceDrivesToCombo()
	GUIRegisterMsg($WM_DEVICECHANGE, '_DEVICECHANGE')
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitDotNetForm')
EndFunc   ;==>InstallNetFrame35UI
Func QuitDotNetForm()
	GUIRegisterMsg($WM_DEVICECHANGE, '')
	_WinAPI_AnimateWindow($FormInsdotNet, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormInsdotNet)
EndFunc   ;==>QuitDotNetForm
Func _GetSourceDrivesToCombo()
	Local $aDrive = DriveGetDrive('ALL'), $str = ''
	For $i = 1 To $aDrive[0]
		If FileExists($aDrive[$i] & '\sources\sxs') Then
			Local $DriveLabel = DriveGetLabel($aDrive[$i])
			If $DriveLabel = '' Then
				$str &= StringUpper($aDrive[$i]) & '|'
			Else
				$str &= StringUpper($aDrive[$i]) & '[' & $DriveLabel & ']|'
			EndIf
		EndIf
		GUICtrlSetData($InsSourceDriveList, '')
		GUICtrlSetData($InsSourceDriveList, $str)
	Next
EndFunc   ;==>_GetSourceDrivesToCombo
Func AddCustomSourceDir()
	Local $dir = FileSelectFolder('请选择Windows8.1系统安装文件所在目录[包含Sources的文件目录]', '')
	If Not @error And $dir <> '' Then
		GUICtrlSetData($InsSourceDriveList, $dir)
		_GUICtrlComboBox_SetCurSel($InsSourceDriveList, _GUICtrlComboBox_SelectString($InsSourceDriveList, $dir))
	EndIf
EndFunc   ;==>AddCustomSourceDir
Func _InstallNF35Frommedia()
	Local $sourceData = GUICtrlRead($InsSourceDriveList), $sSourceDrive = ''
	If $sourceData <> '' Then
		If StringInStr($sourceData, ':\') Then
			$sSourceDrive = $sourceData
		Else
			$sSourceDrive = StringLeft($sourceData, 2)
		EndIf
	EndIf
	If FileExists($sSourceDrive & '\sources\sxs') Then
		Local $sParam = ''
		Local $ShowFlag = @SW_HIDE
		If GUICtrlRead($ShowCMD) = $GUI_CHECKED Then
			$ShowFlag = @SW_SHOW
		EndIf
		If GUICtrlRead($LimitAccess) = $GUI_CHECKED Then
			$sParam = '/LimitAccess'
		EndIf
		GUICtrlSetData($Btn_installdotnet35, '正在安装安装.NET Framework3.5，请稍后..')
		GUICtrlSetState($Btn_installdotnet35, $GUI_DISABLE)
		GUICtrlSetState($InsSourceDriveList, $GUI_DISABLE)
		TrayTip("提示", "正在安装安装.NET Framework3.5，请稍后..", 10, 1)
		$PidInstallNet35 = Run(@ComSpec & ' /c dism.exe /online /enable-feature /featurename:NetFX3 /Source:' & $sSourceDrive & '\sources\sxs ' & $sParam, @WindowsDir, $ShowFlag)
		AdlibRegister('_NofierNetComplete')
	Else
		MsgBox(16, '提示', '请插入可用的Windows安装介质！', 5)
	EndIf
EndFunc   ;==>_InstallNF35Frommedia
Func _NofierNetComplete()
	If Not ProcessExists($PidInstallNet35) Then
		TrayTip('', '', 0)
		GUICtrlSetData($Btn_installdotnet35, '从源安装盘安装.NET Framework3.5')
		GUICtrlSetState($Btn_installdotnet35, $GUI_ENABLE)
		GUICtrlSetState($InsSourceDriveList, $GUI_ENABLE)
		AdlibUnRegister('_NofierNetComplete')
		MsgBox(0, '提示', '已经成功安装.NET Framework3.5', 5)
	EndIf
EndFunc   ;==>_NofierNetComplete
