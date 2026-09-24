;==============================================================================
; 模块：进程黑名单
; 说明：禁止运行指定进程的黑名单管理
; 文件：src\features\system\Feat_ProcessBL.au3
; 函数：共 10 个
;==============================================================================
#include-once

Func ProcessBL()
	Global $FPBL = _GUICreate("进程黑名单设置工具", 404, 254, 103, 30, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $LV_Processes = GUICtrlCreateListView("进程名称|进程说明", 8, 96, 362, 150, BitOR($GUI_SS_DEFAULT_LISTVIEW, $WS_VSCROLL), BitOR($WS_EX_CLIENTEDGE, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 100)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 255)
	_GUICtrlListView_JustifyColumn(GUICtrlGetHandle($LV_Processes), 1, 2)
	GUICtrlCreateGroup("编辑名单", 8, 8, 361, 81)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("进程名称", 16, 32, 52, 17)
	Global $ProcessName = GUICtrlCreateInput("", 72, 24, 289, 21)
	GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	Global $CoboProcesses = GUICtrlCreateCombo("", 72, 24, 289, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE, $CBS_SORT))
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlSetOnEvent(-1, 'LoadProcessNameToEdit')
	GUICtrlCreateLabel("进程说明", 16, 56, 52, 17)
	Global $ProcessDesc = GUICtrlCreateInput("", 72, 56, 289, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("选", 375, 15, 27, 25)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, 0x800000)
	GUICtrlSetTip(-1, '通过该按钮从当前系统进程列表中选' & @LF & '择要加入黑名单的进程名称', '说明', 1)
	GUICtrlSetOnEvent(-1, 'SelectCurrentProcess')
	GUICtrlCreateButton("增", 375, 40, 27, 25)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, 0x808000)
	GUICtrlSetTip(-1, '通过该按钮添加指定进程名称到黑名单', '说明', 1)
	GUICtrlSetOnEvent(-1, 'AddRecord')
	GUICtrlCreateButton("更", 375, 65, 27, 25)
	GUICtrlSetTip(-1, '通过该按钮更新指定进程黑名单记录', '说明', 1)
	GUICtrlSetColor(-1, 0xC0C0C0)
	GUICtrlSetBkColor(-1, 0x008000)
	GUICtrlSetOnEvent(-1, 'UpdateRecord')
	GUICtrlCreateButton("删", 375, 127, 27, 25, $WS_CLIPSIBLINGS)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, 0x800080)
	GUICtrlSetTip(-1, '通过该按钮删除指定进程黑名单记录', '说明', 1)
	GUICtrlSetOnEvent(-1, 'DelRecord')
	LoadBlackList()
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFormPBL')
	GUISetOnEvent($GUI_EVENT_DROPPED, 'SetProcessNameToEdit')
EndFunc   ;==>ProcessBL
Func LoadBlackList()
	Local $aReg[0][2], $i = 1
	Do
		Local $sSubItem = RegEnumVal($BLRegkey, $i)
		If $sSubItem <> '' Then
			ReDim $aReg[$i][2]
			$aReg[$i - 1][0] = $sSubItem
			$aReg[$i - 1][1] = RegRead($BLRegkey, $sSubItem)
			$i += 1
		EndIf
	Until @error <> 0
	If UBound($aReg) = 0 Then
		RegDelete($PBLRegkey, 'DisallowRun')
		_ForceUpdate()
	Else
		For $x = 0 To UBound($aReg) - 1
			GUICtrlCreateListViewItem($aReg[$x][1] & '|' & $aReg[$x][0], $LV_Processes)
			GUICtrlSetOnEvent(-1, 'LoadToEdit')
		Next
	EndIf
EndFunc   ;==>LoadBlackList
Func QuitFormPBL()
	_WinAPI_AnimateWindow($FPBL, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FPBL)
EndFunc   ;==>QuitFormPBL
Func AddRecord()
	Local $Name = GUICtrlRead($ProcessName), $Desc = GUICtrlRead($ProcessDesc)
	If $Name <> '' And $Desc <> '' Then
		GUICtrlCreateListViewItem($Name & '|' & $Desc, $LV_Processes)
		RegWrite($PBLRegkey, 'DisallowRun', 'REG_DWORD', '00000001')
		RegWrite($BLRegkey, $Desc, 'REG_SZ', $Name)
		GUICtrlSetOnEvent(-1, 'LoadToEdit')
		GUICtrlSetData($ProcessName, '')
		GUICtrlSetData($ProcessDesc, '')
		_ForceUpdate()
		MsgBox(0, '', '已经将进程' & $Name & '成功加入进程黑名单~~', 5, $FPBL)
	Else
		MsgBox(16, '提示', '黑名单进程名称和描述均不能为空，请检查！', 5, $FPBL)
	EndIf
EndFunc   ;==>AddRecord
Func DelRecord()
	Local $Desc = GUICtrlRead($ProcessDesc), $Name = GUICtrlRead($ProcessName)
	If $Desc <> '' And $Name <> '' Then
		RegDelete($BLRegkey, $Desc)
		_GUICtrlListView_DeleteItemsSelected($LV_Processes)
		GUICtrlSetData($ProcessName, '')
		GUICtrlSetData($ProcessDesc, '')
		_ForceUpdate()
		MsgBox(0, '提示', '已经将进程' & $Name & '从进程黑名单中删除~', 5)
	Else
		MsgBox(16, '', '没有选择要进行删除的记录，请检查~', 5, $FPBL)
	EndIf
EndFunc   ;==>DelRecord

Func LoadToEdit()
	Local $aStr = _GUICtrlListView_GetItemTextArray($LV_Processes)
	GUICtrlSetData($ProcessName, $aStr[1])
	GUICtrlSetData($ProcessDesc, $aStr[2])
	$DeletedProcessName = $aStr[2]
EndFunc   ;==>LoadToEdit

Func UpdateRecord()
	$iNumber = _GUICtrlListView_GetItemCount($LV_Processes)
	Local $Name = GUICtrlRead($ProcessName), $Desc = GUICtrlRead($ProcessDesc)
	If $Name <> '' And $Desc <> '' Then
		For $i = 0 To $iNumber - 1
			If _GUICtrlListView_GetItemSelected($LV_Processes, $i) Then
				_GUICtrlListView_SetItemText($LV_Processes, $i, $Name, 0)
				_GUICtrlListView_SetItemText($LV_Processes, $i, $Desc, 1)
				RegDelete($BLRegkey, $DeletedProcessName)
				RegWrite($PBLRegkey, 'DisallowRun', 'REG_DWORD', '00000001')
				RegWrite($BLRegkey, $Desc, 'REG_SZ', $Name)
				_ForceUpdate()
				MsgBox(0, '提示', '更新选择项目成功~', 5, $FPBL)
			Else
				MsgBox(16, '', '发生不可预料错误~~', 5, $FPBL)
			EndIf
		Next
	Else
		MsgBox(16, '提示', '黑名单进程名称和描述均不能为空，请检查！', 5)
	EndIf
EndFunc   ;==>UpdateRecord
Func SetProcessNameToEdit()
	If _WinAPI_PathIsExe(@GUI_DragFile) Then
		GUICtrlSetData($ProcessName, _WinAPI_PathFindFileName(@GUI_DragFile))
	EndIf
EndFunc   ;==>SetProcessNameToEdit

Func SelectCurrentProcess()
	If GUICtrlGetState($CoboProcesses) = 80 Then
		GUICtrlSetState($ProcessName, $GUI_SHOW)
		GUICtrlSetState($CoboProcesses, $GUI_HIDE)
	Else
		Local $aProcess = ProcessList(), $sdata = ''
		For $i = 1 To UBound($aProcess) - 1
			$sdata &= $aProcess[$i][0] & '|'
		Next
		GUICtrlSetData($CoboProcesses, '')
		GUICtrlSetData($CoboProcesses, $sdata)
		GUICtrlSetState($ProcessName, $GUI_HIDE)
		GUICtrlSetState($CoboProcesses, $GUI_SHOW)
	EndIf
EndFunc   ;==>SelectCurrentProcess

Func LoadProcessNameToEdit()
	GUICtrlSetState($CoboProcesses, $GUI_HIDE)
	GUICtrlSetState($ProcessName, $GUI_SHOW)
	GUICtrlSetData($ProcessName, GUICtrlRead($CoboProcesses))
EndFunc   ;==>LoadProcessNameToEdit
