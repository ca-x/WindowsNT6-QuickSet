;==============================================================================
; 模块：批量创建文件
; 说明：创建指定大小的文件
; 文件：src\features\tools\Feat_FileCreate.au3
; 函数：共 5 个
;==============================================================================
#include-once

Func MutiCrateFiles()
	Global $FormCreateFile = _GUICreate("批量创建指定大小文件 ", 502, 239, 54, 30, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("文件创建选项", 16, 8, 465, 185)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("创建大小为", 24, 72, 64, 17)
	Global $FileSize = GUICtrlCreateInput("1024", 104, 64, 73, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER))
	Global $ComboDW = GUICtrlCreateCombo("KB", 192, 64, 65, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "MB|GB")
	GUICtrlCreateLabel("在 ", 24, 33, 19, 17)
	Global $FileTargetDir = GUICtrlCreateInput("", 48, 32, 241, 21)
	GUICtrlCreateButton("浏览", 296, 32, 59, 25)
	GUICtrlSetOnEvent(-1, '_selectTargetDir')
	GUICtrlCreateLabel("的文件", 272, 72, 40, 17)
	GUICtrlCreateLabel("创建数量为 ", 24, 104, 67, 17)
	Global $FileNum = GUICtrlCreateInput("1", 104, 96, 73, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_NUMBER))
	GUICtrlCreateLabel("个", 192, 104, 16, 17)
	GUICtrlCreateLabel("文件名选项", 24, 136, 64, 17)
	$CreateFileTool[1] = _GUICtrlCreateRadio("文件名中使用时间戳", 96, 136, 145, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$CreateFileTool[2] = _GUICtrlCreateRadio("序列填充", 248, 136, 113, 17)
	GUICtrlCreateLabel("扩展名设定", 256, 161, 64, 17)
	Global $FileExt = GUICtrlCreateInput("", 328, 160, 137, 21)
	$CreateFileTool[3] = _GUICtrlCreateCheckbox("大小使用随机值", 336, 72, 129, 17)
	GUICtrlCreateLabel("文件编号前缀", 24, 161, 76, 17)
	Global $FilePre = GUICtrlCreateInput("NULL", 104, 160, 137, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("创建文件", 16, 200, 467, 33)
	GUICtrlSetOnEvent(-1, '_StartCreateFile')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitMutiCreateTool')
EndFunc   ;==>MutiCrateFiles

Func QuitMutiCreateTool()
	_WinAPI_AnimateWindow($FormCreateFile, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormCreateFile)
EndFunc   ;==>QuitMutiCreateTool

Func _selectTargetDir()
	Local $dir = FileSelectFolder('请选择要用于存放生成文件的磁盘或目录', '', 1 + 4)
	If FileExists($dir) Then
		GUICtrlSetData($FileTargetDir, $dir)
		GUICtrlSetBkColor($FileTargetDir, '0xffffff')
	Else
		GUICtrlSetData($FileTargetDir, $dir)
		GUICtrlSetBkColor($FileTargetDir, '0xff0000')
		MsgBox(16, '提示', '请选择一个文件夹哦，亲', 5)
	EndIf
EndFunc   ;==>_selectTargetDir

Func _CreateMyFile($sFilePath, $iFileSize, $fFailIfExists = 1)
	Local $iFlags = ($fFailIfExists = 0) + 1

	Local $hFile = DllCall("Kernel32.dll", "handle", "CreateFileW", "wstr", $sFilePath, "dword", 0xC0000000, "dword", 3, "ptr", 0, "dword", $iFlags, "dword", 0, "handle", 0)
	$hFile = $hFile[0]

	If ($hFile = -1) Then Return SetError(1, 0, 0)

	Local $tIOStatus = DllStructCreate("ubyte IOStatus[64]")
	Local $pIOStatus = DllStructGetPtr($tIOStatus)

	DllCall("Ntdll.dll", "long", "NtSetInformationFile", "handle", $hFile, "ptr", $pIOStatus, "int64*", $iFileSize, "long", 8, "long", 20)
	DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hFile)

	Return 1
EndFunc   ;==>_CreateMyFile

Func _StartCreateFile()
	Local $TFileDir, $Fnum = GUICtrlRead($FileNum), $FHeader = GUICtrlRead($FilePre), $FExt = GUICtrlRead($FileExt)
	Local $TFileDir = GUICtrlRead($FileTargetDir)
	If Not FileExists($TFileDir) Then
		MsgBox(16, '', '目标目录不能为空~~')
		Return 0
	EndIf
	;先检测文件创建的大小是否有可用磁盘~
	If DriveSpaceFree($TFileDir) * 1024 * 1024 < GetTotalKSize(GUICtrlRead($FileSize) & GUICtrlRead($ComboDW)) * GUICtrlRead($FileNum) Then
		MsgBox(16, '', '按照当前文件创建选项，磁盘空间可能不足~~请修改选项!', 9)
		Return 1
	EndIf
	For $i = 1 To $Fnum
		Local $FileFinalName, $FileFinalSize
		If GUICtrlRead($CreateFileTool[1]) = $GUI_CHECKED Then
			$FileFinalName = $FHeader & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & @MSEC & $FExt
		Else
			$FileFinalName = $FHeader & $i & $FExt
		EndIf
		If GUICtrlRead($CreateFileTool[3]) = $GUI_CHECKED Then
			$FileFinalSize = GetTotalKSize(Random(1, GUICtrlRead($FileSize), 1) & GUICtrlRead($ComboDW))
		Else
			$FileFinalSize = GetTotalKSize(GUICtrlRead($FileSize) & GUICtrlRead($ComboDW))
		EndIf
		_CreateMyFile($TFileDir & '\' & $FileFinalName, $FileFinalSize, 1)
	Next
	MsgBox(0, '', '已经成功创建' & $Fnum & '个文件~~', 5)
EndFunc   ;==>_StartCreateFile
