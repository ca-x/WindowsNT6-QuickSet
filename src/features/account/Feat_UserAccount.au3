;==============================================================================
; 模块：用户账户
; 说明：用户改名、描述、密码修改、自动登录设置
; 文件：src\features\account\Feat_UserAccount.au3
; 函数：共 20 个
;==============================================================================
#include-once

Func ChangeSingleUserPassword()
	$PasswordChangeMode = 0
	ChangeUserPasswordDlg()
EndFunc   ;==>ChangeSingleUserPassword
Func ChangeListUserPassword()
	$PasswordChangeMode = 1
	ChangeUserPasswordDlg()
EndFunc   ;==>ChangeListUserPassword
Func ChangeUserDescDlg()
	Local $UserNameToSet = GUICtrlRead($ComboUserList)
	Local $UserDescinfo = GUICtrlRead($UserDesc)
	If $UserNameToSet <> '' Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Global $FormUserChangeDesc = _GUICreate("更改用户描述", 259, 140, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		Global $UserNameToSetDesc = GUICtrlCreateInput($UserNameToSet, 16, 16, 225, 21)
		GUICtrlSetState(-1, $GUI_DISABLE)
		Global $UserDescToChange = GUICtrlCreateInput($UserDescinfo, 16, 75, 225, 21)
		GUICtrlCreateButton("更改用户描述信息[&C]", 8, 110, 243, 25)
		GUICtrlSetOnEvent(-1, '_ChangeSelectedUserDesc')
		GUICtrlCreateGroup("要更改描述的用户名称", 8, 0, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("用户描述信息", 10, 58, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitChangeUserDescDlg')
	Else
		MsgBox(0, '提示', '请先选择要进行描述设置的用户名~~', 5)
	EndIf
EndFunc   ;==>ChangeUserDescDlg
Func QuitChangeUserDescDlg()
	_WinAPI_AnimateWindow($FormUserChangeDesc, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormUserChangeDesc)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitChangeUserDescDlg
Func ChangeUserPasswordDlg()
	Local $UserNameToSet = GUICtrlRead($ComboUserList)
	If $UserNameToSet <> '' Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Global $FormUserChangePWD = _GUICreate("更改用户密码", 259, 157, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		Global $UserNameToSetPWD = GUICtrlCreateInput($UserNameToSet, 16, 16, 225, 21)
		If $PasswordChangeMode = 1 Then GUICtrlSetData($UserNameToSetPWD, '用户列表全部用户')
		GUICtrlSetState(-1, $GUI_DISABLE)
		Global $UserPwdToChange = GUICtrlCreateInput("", 16, 75, 225, 21, $ES_PASSWORD)
		_GUICtrlEdit_SetPasswordChar(-1, '#')
		GUICtrlCreateButton("更改用户密码[&C]", 8, 125, 243, 25)
		GUICtrlSetOnEvent(-1, '_ChangeUserPassword')
		GUICtrlCreateGroup("要更改密码的用户名称", 8, 0, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("新的用户密码", 10, 58, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		$FlagShowPassword[1] = _GUICtrlCreateCheckbox("显示密码", 16, 104, 97, 17)
		GUICtrlSetOnEvent($FlagShowPassword[1], '_ShowUserPassword')
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitChangeUserPasswordDlg')
	Else
		MsgBox(0, '提示', '请先选择要进行密码设置的用户名~~', 5)
	EndIf
EndFunc   ;==>ChangeUserPasswordDlg
Func QuitChangeUserPasswordDlg()
	_WinAPI_AnimateWindow($FormUserChangePWD, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormUserChangePWD)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitChangeUserPasswordDlg
Func _ShowUserPassword()
	If GUICtrlRead($FlagShowPassword[1]) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($UserPwdToChange)
	Else
		_GUICtrlEdit_SetPasswordChar($UserPwdToChange, '#')
	EndIf
	GUICtrlSetState($UserPwdToChange, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($UserPwdToChange, -1, -1)
EndFunc   ;==>_ShowUserPassword
Func _ChangeUserPassword()
	Local $UserPassword = GUICtrlRead($UserPwdToChange)
	If $PasswordChangeMode = 0 Then
		Local $UserName = GUICtrlRead($UserNameToSetPWD)
		Local $iResult = _NetUserSetPassword($UserName, $UserPassword)
		If $iResult Then
			MsgBox(0, "提示", "用户密码更改成功~", 6)
		Else
			MsgBox(0, '错误', @error & "用户密码更改失败！", 6)
		EndIf
	Else
		Local $iResult
		For $iUser = 0 To UBound($aUserInfo) - 1
			$iResult = _NetUserSetPassword($aUserInfo[$iUser][0], $UserPassword)
		Next
		If $iResult Then
			MsgBox(0, "提示", "统一设置列表用户密码成功~", 6)
		Else
			MsgBox(0, '错误', @error & "统一设置列表用户密码失败！", 6)
		EndIf
	EndIf
EndFunc   ;==>_ChangeUserPassword
Func _ChangeSelectedUserDesc()
	Local $iResult = _SetUserDesc(GUICtrlRead($UserNameToSetDesc), GUICtrlRead($UserDescToChange))
	If $iResult Then
		MsgBox(0, '提示', '修改用户描述成功！', 5)
		_LoadUserNameToArray()
	Else
		MsgBox(16, '提示', '修改用户描述失败！', 5)
	EndIf
EndFunc   ;==>_ChangeSelectedUserDesc
Func _NetUserChangeName($sUserName, $sNewName, $sSystem = "")
	Local $iResult, $tName, $pName, $tUserName, $pUserName
	$tName = DllStructCreate("wchar[256]")
	$pName = DllStructGetPtr($tName)
	DllStructSetData($tName, 1, $sNewName)
	$tUserName = DllStructCreate("ptr")
	$pUserName = DllStructGetPtr($tUserName)
	DllStructSetData($tUserName, 1, $pName)
	$iResult = DllCall("netapi32.dll", "dword", "NetUserSetInfo", _
			"wstr", $sSystem, "wstr", $sUserName, _
			"dword", 0, "ptr", $pUserName, "int*", 0)
	$tName = 0
	$tUserName = 0
	Return SetError($iResult[0], 0, $iResult[0] = 0)
EndFunc   ;==>_NetUserChangeName
Func _SetUserFullName($UserName, $FullName)
	If $FullName <> '' Then
		$objuser = ObjGet("WinNT://" & @ComputerName & "/" & $UserName & ",User")
		$objuser.FullName = $FullName
		$objuser.SetInfo
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_SetUserFullName
Func _SetUserDesc($UserName, $Desc)
	If $Desc <> '' Then
		$objuser = ObjGet("WinNT://" & @ComputerName & "/" & $UserName & ",User")
		$objuser.Description = $Desc
		$objuser.SetInfo
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_SetUserDesc
Func _NetUserSetPassword($sUserName, $sPassword, $sSystem = "")
	Local $iResult, $tName, $pName, $tUserName, $pUserName
	$tName = DllStructCreate("wchar[256]")
	$pName = DllStructGetPtr($tName)
	DllStructSetData($tName, 1, $sPassword)
	$tUserName = DllStructCreate("ptr")
	$pUserName = DllStructGetPtr($tUserName)
	DllStructSetData($tUserName, 1, $pName)
	$iResult = DllCall("netapi32.dll", "dword", "NetUserSetInfo", _
			"wstr", $sSystem, "wstr", $sUserName, _
			"dword", 1003, "ptr", $pUserName, "int*", 0)
	$tName = 0
	$tUserName = 0
	Return SetError($iResult[0], 0, $iResult[0] = 0)
EndFunc   ;==>_NetUserSetPassword
Func _LoadUserNameToArray()
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $sUserList = ''
	Local $strComputer = "localhost"
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_UserAccount", "WQL", _
			$wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		Local $i = 0
		For $objItem In $colItems
			ReDim $aUserInfo[$i + 1][4]
			$aUserInfo[$i][0] = $objItem.Name
			$aUserInfo[$i][1] = $objItem.Disabled
			$aUserInfo[$i][2] = $objItem.FullName
			$aUserInfo[$i][3] = $objItem.Description
			$i += 1
		Next
	EndIf

	For $i = 0 To UBound($aUserInfo) - 1
		$sUserList &= $aUserInfo[$i][0] & '|'
	Next
	GUICtrlSetData($ComboUserList, '')
	GUICtrlSetData($ComboUserList, $sUserList)
	_GUICtrlComboBox_SetCurSel($ComboUserList, 0)
	_loadUserNameToEdit()
EndFunc   ;==>_LoadUserNameToArray
Func _loadUserNameToEdit()
	Local $sUserName = GUICtrlRead($ComboUserList)
	GUICtrlSetData($NewUserName, $sUserName)
	For $i = 0 To UBound($aUserInfo) - 1
		If $aUserInfo[$i][0] = $sUserName Then
			If $aUserInfo[$i][1] = True Then
				GUICtrlSetTip($ComboUserList, '该用户帐号在当前系统被禁用，修改后请' & @LF & '在系统中启用该用户帐号~', '警告', 2, 2)
				GUICtrlSetColor($NewUserName, 0xFFFFFF)
				GUICtrlSetBkColor($NewUserName, 0xFF0000)
				If $aUserInfo[$i][2] <> '' Then
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为[' & $aUserInfo[$i][2] & ']！', '说明', 1)
				Else
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为空！', '说明', 1)
				EndIf
				GUICtrlSetData($UserDesc, StringStripWS($aUserInfo[$i][3], 1 + 2))
			Else
				GUICtrlSetTip($ComboUserList, '修改将立即生效至当前选择用户帐号~', '提示', 1, 2)
				GUICtrlSetColor($NewUserName, 0x000000)
				GUICtrlSetBkColor($NewUserName, 0xFFFFFF)
				If $aUserInfo[$i][2] <> '' Then
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为[' & $aUserInfo[$i][2] & ']！', '说明', 1)
				Else
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为空！', '说明', 1)
				EndIf
				GUICtrlSetData($UserDesc, StringStripWS($aUserInfo[$i][3], 1 + 2))
			EndIf
		EndIf
	Next
EndFunc   ;==>_loadUserNameToEdit

Func AutoLoginTool()
	Local $UserPwd = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'DefaultPassword')
	If @error Then
		$UserPwd = ''
	EndIf
	Global $FSetAuto = _GUICreate("自动登录设置器", 353, 141, 128, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("用户登录信息", 16, 8, 217, 97)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("用户名", 24, 34, 40, 17)
	Global $AutoUsername = GUICtrlCreateInput(@UserName, 82, 32, 137, 21)
	GUICtrlCreateLabel("用户密码", 24, 60, 52, 17)
	Global $UserAccPwd = GUICtrlCreateInput("", 82, 60, 137, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	_GUICtrlEdit_SetPasswordChar(-1, '#')
	GUICtrlSetData(-1, $UserPwd)
	Global $ShowUserLoginPassword = _GUICtrlCreateCheckbox("显示为明文密码", 24, 85, 105, 17)
	GUICtrlSetTip(-1, '勾选此选项，将在用户密码框中' & @LF & '明文显示用户输入的密码', '说明', 1)
	GUICtrlSetOnEvent(-1, '_ShowUserLoginPassword')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $SetAuto = _GUICtrlCreateRadio("设置自动登录", 16, 112, 97, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $CancelAuto = _GUICtrlCreateRadio("取消自动登录", 120, 112, 97, 17)
	Global $LogoutAutoLogin = _GUICtrlCreateCheckbox("注销后自动登录", 240, 88, 105, 17)
	GUICtrlSetTip(-1, '勾选此选项，用户选择注销后将自' & @LF & '动重新登录，不需要再次输入密码', '说明', 1)
	$BtnSet = GUICtrlCreateButton("设置", 240, 24, 75, 25)
	GUICtrlSetOnEvent(-1, 'SetAutoLogin')
	$MSys = GUICtrlCreateContextMenu($BtnSet)
	GUICtrlCreateMenuItem('使用系统自带功能进行设置', $MSys)
	GUICtrlSetOnEvent(-1, 'UseBuildInAuto')
	GUICtrlCreateButton("退出程序", 240, 56, 75, 25)
	GUICtrlSetOnEvent(-1, 'QuitFSetAuto')
	GUICtrlCreateLabel(@ComputerName, 224, 112, 82, 17)
	GUICtrlSetColor(-1, 0x0066CC)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFSetAuto')
EndFunc   ;==>AutoLoginTool

Func QuitFSetAuto()
	_WinAPI_AnimateWindow($FSetAuto, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FSetAuto)
EndFunc   ;==>QuitFSetAuto

Func SetAutoLogin()
	If GUICtrlRead($SetAuto) = $GUI_CHECKED Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Control\Lsa", "LmCompatabilityLevel", "REG_DWORD", "2")
		If GUICtrlRead($LogoutAutoLogin) = $GUI_CHECKED Then
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "ForceAutoLogon", "REG_SZ", "1")
		EndIf
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "REG_SZ", "1")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName", "REG_SZ", GUICtrlRead($AutoUsername))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword", "REG_SZ", GUICtrlRead($UserAccPwd))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName", "REG_SZ", @ComputerName)
		MsgBox(0, '提示', '设置用户' & GUICtrlRead($AutoUsername) & '自动登录成功！' & @LF & '请重启以进行验证！', 5)
	EndIf
	If GUICtrlRead($CancelAuto) = $GUI_CHECKED Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "REG_SZ", "0")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "ForceAutoLogon", "REG_SZ", "0")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName")
		MsgBox(0, '提示', '取消自动登录完成！', 5)
	EndIf
EndFunc   ;==>SetAutoLogin
Func _ShowUserLoginPassword()
	If GUICtrlRead($ShowUserLoginPassword) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($UserAccPwd)
	Else
		_GUICtrlEdit_SetPasswordChar($UserAccPwd, '#')
	EndIf
	GUICtrlSetState($UserAccPwd, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($UserAccPwd, -1, -1)
EndFunc   ;==>_ShowUserLoginPassword
Func UseBuildInAuto()
	Run('control.exe userpasswords2', @WindowsDir)
	If GUICtrlRead($SetAuto) = $GUI_CHECKED Then
		WinActivate('[CLASS:#32770]')
		WinWaitActive('[CLASS:#32770]')
		If ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "IsChecked", "") = 0 Then
			MsgBox(0, '提示', '系统貌似已经设置了用户' & GUICtrlRead($AutoUsername) & '自动登录~~', 5)
		Else
			ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "UnCheck", "")
			ControlClick('', '', '[CLASS:Button; INSTANCE:9]')
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:1]', GUICtrlRead($AutoUsername))
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:2]', GUICtrlRead($UserAccPwd))
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:3]', GUICtrlRead($UserAccPwd))
			ControlClick('', '', '[CLASS:Button; INSTANCE:1]')
			MsgBox(0, '提示', '调用系统内建功能设置用户' & GUICtrlRead($AutoUsername) & '自动登录成功！', 5)
		EndIf
	ElseIf GUICtrlRead($CancelAuto) = $GUI_CHECKED Then
		WinActivate('[CLASS:#32770]')
		WinWaitActive('[CLASS:#32770]')
		If ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "IsChecked", "") = 1 Then
			MsgBox(0, '提示', '系统貌似未设置用户' & GUICtrlRead($AutoUsername) & '自动登录~~', 5)
		Else
			ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "Check", "")
			ControlClick('', '', '[CLASS:Button; INSTANCE:9]')
			MsgBox(0, '提示', '调用系统内建功能取消用户' & GUICtrlRead($AutoUsername) & '自动登录成功！', 5)
		EndIf
	Else
	EndIf
EndFunc   ;==>UseBuildInAuto
