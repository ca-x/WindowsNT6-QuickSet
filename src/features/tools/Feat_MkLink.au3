;==============================================================================
; 模块：符号链接工具
; 说明：MkLink 图形界面封装
; 文件：src\features\tools\Feat_MkLink.au3
; 函数：共 7 个
;==============================================================================
#include-once


Func MkLinkGUI()
	Global $FMkLink = _GUICreate("MkLink GUI实用工具", 398, 128, 106, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateLabel("使用本工具可以一键创建文件及目录的符号、硬链接", 8, 104, 280, 17)
	GUICtrlCreateGroup("链接内容设定", 8, 8, 257, 89)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("源路径：", 16, 33, 52, 17)
	Global $LinkSource = GUICtrlCreateInput("", 72, 32, 145, 21)
	GUICtrlSetState(-1, 8)
	$BtnSource = GUICtrlCreateButton("浏览", 224, 33, 35, 17)
	GUICtrlSetTip(-1, '请右键选择链接源类型及位置', '提示', 1)
	$MenuSource = GUICtrlCreateContextMenu($BtnSource)
	;选择文件
	GUICtrlCreateMenuItem('选择源文件', $MenuSource)
	GUICtrlSetOnEvent(-1, 'SetSourceFile')
	;选择目录
	GUICtrlCreateMenuItem('选择源目录', $MenuSource)
	GUICtrlSetOnEvent(-1, 'SetSourceDir')
	GUICtrlCreateLabel("链接路径：", 16, 64, 64, 17)
	Global $LinkTarget = GUICtrlCreateInput("", 72, 64, 145, 21)
	GUICtrlSetState(-1, 8)
	$BtnTarget = GUICtrlCreateButton("浏览", 224, 65, 35, 17)
	GUICtrlSetTip(-1, '请右键选择链接目标类型及位置', '提示', 1)
	$MenuTarget = GUICtrlCreateContextMenu($BtnTarget)
	;选择源文件
	GUICtrlCreateMenuItem('选择目标文件[可不存在]', $MenuTarget)
	GUICtrlSetOnEvent(-1, 'SetTargetFile')
	;选择源目录
	GUICtrlCreateMenuItem('选择目标文件夹[可不存在]', $MenuTarget)
	GUICtrlSetOnEvent(-1, 'SetTargetDir')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("链接类型", 272, 8, 113, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$MklinkTool[1] = _GUICtrlCreateRadio("软链接", 280, 24, 89, 17)
	GUICtrlSetState($MklinkTool[1], $GUI_CHECKED)
	$MklinkTool[2] = _GUICtrlCreateRadio("硬链接", 280, 40, 97, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("创建链接", 272, 72, 115, 25)
	GUICtrlSetOnEvent(-1, 'MakeLink')
	GUISetState(@SW_SHOW, $FMkLink)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFMklink')
EndFunc   ;==>MkLinkGUI

Func QuitFMklink()
	_WinAPI_AnimateWindow($FMkLink, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FMkLink)
EndFunc   ;==>QuitFMklink

Func SetSourceFile()
	Local $File = FileOpenDialog('请选择要进行链接的源文件路径', '', '(*.*)所有文件类型', 1 + 8, '', $FMkLink)
	If $File <> '' And FileExists($File) Then
		GUICtrlSetData($LinkSource, $File)
	EndIf
EndFunc   ;==>SetSourceFile

Func SetSourceDir()
	Local $dir = FileSelectFolder('请选择要进行链接的源目录路径', '', 1 + 4, '', $FMkLink)
	If $dir <> '' And FileExists($dir) Then
		GUICtrlSetData($LinkSource, $dir)
	EndIf
EndFunc   ;==>SetSourceDir

Func SetTargetFile()
	Local $File = FileOpenDialog('请选择要进行链接的目标文件路径', '', '(*.*)所有文件类型', 0, '', $FMkLink)
	If $File <> '' Then
		GUICtrlSetData($LinkTarget, $File)
	EndIf
EndFunc   ;==>SetTargetFile

Func SetTargetDir()
	Local $dir = FileSelectFolder('请选择要进行链接的目标目录路径', '', 0, '', $FMkLink)
	If $dir <> '' Then
		GUICtrlSetData($LinkTarget, $dir)
	EndIf
EndFunc   ;==>SetTargetDir

Func MakeLink()
	Local $sSource = GUICtrlRead($LinkSource), $sTarget = GUICtrlRead($LinkTarget)
	If $sSource = '' Or $sTarget = '' Then
		MsgBox(16, '提示', '源路径和目标路径均不能' & @LF & '为空！请修改后再试！', 5)
		Return 0
	EndIf
	;软链接
	If GUICtrlRead($MklinkTool[1]) = $GUI_CHECKED Then
		Local $sAttr = FileGetAttrib($sSource)
		;如果源文件是目录
		If StringInStr($sAttr, 'D') Then
			$process = Run(@ComSpec & ' /c mklink /d "' & $sTarget & '" "' & $sSource & '"', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		Else
			;如果源文件是文件
			$process = Run(@ComSpec & ' /c mklink "' & $sTarget & '" "' & $sSource & '"', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		EndIf
		ProcessWaitClose($process)
		$result = StdoutRead($process)
		MsgBox(0, '提示', '选定操作执行完成，执行返回结果如下：' & @LF & @LF & $result, 5)
	EndIf
	;硬链接
	If GUICtrlRead($MklinkTool[2]) = $GUI_CHECKED Then
		Local $sAttr = FileGetAttrib($sSource)
		;如果源文件是目录
		If StringInStr($sAttr, 'D') Then
			$process = Run(@ComSpec & ' /c mklink /d /h "' & $sTarget & '" "' & $sSource & '"', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		Else
			;如果源文件是文件
			$process = Run(@ComSpec & ' /c mklink /h "' & $sTarget & '" "' & $sSource & '"', @WindowsDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		EndIf
		ProcessWaitClose($process)
		$result = StdoutRead($process)
		MsgBox(0, '提示', '选定操作执行完成，执行返回结果如下：' & @LF & @LF & $result, 5)
	EndIf
EndFunc   ;==>MakeLink
