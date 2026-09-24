;==============================================================================
; 模块：个人资料转移
; 说明：用户资料目录的转移、还原与目标盘选择
; 文件：src\features\shell\Feat_DirTransfer.au3
; 函数：共 4 个
;==============================================================================
#include-once


;=============================================================
; 个人资料转移
;=============================================================
;文本选中

Func ToogleListviewCheck()
	Local $hLast = @GUI_CtrlId
	$TreePos = ControlGetPos($Form1, '', $TreeView)
	$x = _GUICtrlTreeView_DisplayRect($TreeView, @GUI_CtrlId, True) ;取点击项文本框的坐标
	$curX = GUIGetCursorInfo()
	If Not @error And IsArray($curX) And IsArray($TreePos) And IsArray($x) Then
		If $curX[0] - $TreePos[0] >= $x[0] Then
			GUICtrlSetState($hLast, (BitAND(GUICtrlRead($hLast), $GUI_CHECKED)) ? $GUI_UNCHECKED : $GUI_CHECKED)
		EndIf
	EndIf
	Local $HidParent = _GUICtrlTreeView_GetParentHandle($TreeView, $hLast)
	Local $bCheck = _GUICtrlTreeView_GetChecked($TreeView, $hLast)
	If $HidParent = 0 Then
		;表示点击的是父项目
		Local $iChildcount = _GUICtrlTreeView_GetChildCount($TreeView, $hLast)
		For $i = 0 To $iChildcount - 1
			_GUICtrlTreeView_SetCheckedByIndex($TreeView, $hLast, $i, $bCheck)
		Next
		_GUICtrlTreeView_Expand($TreeView, $hLast, $bCheck)
	Else
		;表示点击的是子项目
		Local $iChildcount = _GUICtrlTreeView_GetChildCount($TreeView, $HidParent)
		_GUICtrlTreeView_SetChecked($TreeView, $HidParent, $bCheck)
		For $i = 0 To $iChildcount - 1
			_GUICtrlTreeView_SetCheckedByIndex($TreeView, $HidParent, $i, $bCheck)
		Next
		_GUICtrlTreeView_Expand($TreeView, $HidParent, $bCheck)
	EndIf
EndFunc   ;==>ToogleListviewCheck
Func QuickSetDrive()
	;检测是否选择浏览
	Local $targetpath = GUICtrlRead($TargetDrive)
	If $targetpath <> '选择目标盘符或路径' Then
		If $targetpath = '浏览...' Then
			Local $dir = FileSelectFolder('请选择要用于存储转移资料的目录', '', 1 + 4, '')
			If Not @error Then
				For $i = 2 To 44 Step 3
					If _GUICtrlTreeView_GetChecked($TreeView, _GUICtrlTreeView_GetParentHandle($TreeView, $aTreeView[$i])) = True Then
						Local $sNewPath = $dir & '\' & _GetDirNameFromStr(_GUICtrlTreeView_GetText($TreeView, $aTreeView[$i]))
						_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i], $sNewPath)
					EndIf
				Next
			EndIf
		Else
			For $i = 2 To 44 Step 3
				If _GUICtrlTreeView_GetChecked($TreeView, _GUICtrlTreeView_GetParentHandle($TreeView, $aTreeView[$i])) = True Then
					Local $sNewPath = StringRegExpReplace(_GUICtrlTreeView_GetText($TreeView, $aTreeView[$i]), '\w:', $targetpath)
					_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i], $sNewPath)
				EndIf
			Next
		EndIf
	EndIf
EndFunc   ;==>QuickSetDrive
Func TransDir()
;~ 	MsgBox(0,'',$UserSid)
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	Local $DirRegkey = 'HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
	For $i = 0 To 44 Step 3
		If _GUICtrlTreeView_GetChecked($TreeView, $aTreeView[$i]) = True Then
			Local $sOPeration = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i])
			Local $sSourceDir = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i + 1])
			Local $sNewDir = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i + 2])
			Local $sRegKey = $aDataTreeView[$i / 3][2]
			$aText = '开始进行个人资料[' & $sOPeration & ']转移操作.....'
			If $sSourceDir = $sNewDir Then
				$aText = '个人资料转移操作[' & $sOPeration & ']源路径和目标路径相同，自动跳过...'
				ContinueLoop
			EndIf
			RegWrite($DirRegkey, $sRegKey, 'REG_SZ', $sNewDir)
			If GUICtrlRead($optFileCopy) = $GUI_CHECKED Then
				_FileCopy($sSourceDir, $sNewDir)
			ElseIf GUICtrlRead($optFileMove) = $GUI_CHECKED Then
				_FileMove($sSourceDir, $sNewDir)
			Else
;~ 				;不做任何事情
			EndIf
		EndIf
	Next
	$aText = '正在处理，请稍后..'
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	_ForceUpdate()
EndFunc   ;==>TransDir
Func RestoreDefaultOpt()
	For $i = 0 To 44 Step 3
		If _GUICtrlTreeView_GetChecked($TreeView, $aTreeView[$i]) = True Then
			Local $sDefaultPath = $aDataTreeView[$i / 3][3]
			_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i + 2], _WinAPI_PathSearchAndQualify(_WinAPI_ExpandEnvironmentStrings($sDefaultPath)))
		EndIf
	Next
	MsgBox(0, '提示', '已经设置为默认值，请点击[执行操作]进行应用！', 5, $Form1)
EndFunc   ;==>RestoreDefaultOpt
