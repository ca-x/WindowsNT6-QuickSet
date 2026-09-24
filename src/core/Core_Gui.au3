;==============================================================================
; 模块：GUI 辅助库
; 说明：窗口/控件创建封装、皮肤与悬停效果、托盘、消息回调、加载动画、全选反选
; 文件：src\core\Core_Gui.au3
; 函数：共 44 个
;==============================================================================
#include-once


;关键部分函数
;移除控件视觉效果
Func _removeEffect($Contrl = -1)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($Contrl), "wstr", 0, "wstr", 0)
EndFunc   ;==>_removeEffect

;退出工具
Func QuitTool()
	If $UseNetMetr Then
		DllCallbackFree($hUpdate)
		DllClose($IPHlpApi_Dll)
	EndIf
	GUISetState(@SW_HIDE, $LoadingUI)
	GUIDelete($LoadingUI)
	_WinAPI_AnimateWindow($Form1, BitOR($AW_BLEND, $AW_SLIDE, $AW_HIDE), 500)
	DirRemove(@TempDir & '\PreOEM', 1)
	If @OSArch = "X64" Then
		Local $stOldVal = DllStructCreate("dword")
		DllCall("kernel32.dll", "int", "Wow64RevertWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
	EndIf
	Exit
EndFunc   ;==>QuitTool
Func _DisableTrayMenu()
	TrayItemSetState($ExtPlugins, $TRAY_DISABLE)
	TrayItemSetState($QuickSet, $TRAY_DISABLE)
	TrayItemSetState($TrayMenuHis, $TRAY_DISABLE)
EndFunc   ;==>_DisableTrayMenu
Func _EnableTrayMenu()
	TrayItemSetState($ExtPlugins, $TRAY_ENABLE)
	TrayItemSetState($QuickSet, $TRAY_ENABLE)
	TrayItemSetState($TrayMenuHis, $TRAY_ENABLE)
EndFunc   ;==>_EnableTrayMenu
Func EndSessionProc($hWnd, $MsgID, $WParam, $LParam)
	TrayTip('提示', '检测到当前系统用户session终' & @LF & '止消息，程序即将退出！', 3, 1)
	QuitTool()
	Return False
EndFunc   ;==>EndSessionProc
Func _PrepBmp()
	If Not FileExists(@TempDir & '\on.bmp') Then _MakeOnBmp()
	If Not FileExists(@TempDir & '\off.bmp') Then _MakeOffBmp()
	GUICtrlSetImage($OnPic, @TempDir & '\on.bmp')
	GUICtrlSetImage($OffPic, @TempDir & '\off.bmp')
	GUICtrlSetState($OnPic, $GUI_HIDE)
	GUICtrlSetState($OffPic, $GUI_HIDE)
	FileDelete(@TempDir & '\on.bmp')
	FileDelete(@TempDir & '\off.bmp')
EndFunc   ;==>_PrepBmp

Func NumLkStatus()
	Local $sg = ''
	If StringInStr($PcType, '笔记本') Then
		$sg = '[建议]当前计算机为笔记本建议关闭小键盘'
	ElseIf $PcType = '台式机' Then
		$sg = '[建议]当前计算机为台式机建议开启小键盘'
	Else
		$sg = '[建议]不能判断当前计算机类型，无法提供建议'
	EndIf
	If BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1) = 1 Then
		GUICtrlSetState($OnPic, $GUI_SHOW)
		GUICtrlSetState($OffPic, $GUI_HIDE)
		GUICtrlSetTip($OnPic, $sg & @LF & '[鼠标单击]临时切换小键盘状态' & @LF & '[ALT+N]长效切换小键盘状态' & @LF & '[小键盘当前状态]开启', '提示', 1)
	Else
		GUICtrlSetState($OnPic, $GUI_HIDE)
		GUICtrlSetState($OffPic, $GUI_SHOW)
		GUICtrlSetTip($OffPic, $sg & @LF & '[鼠标单击]临时切换小键盘状态' & @LF & '[ALT+N]长效切换小键盘状态' & @LF & '[小键盘当前状态]关闭', '提示', 1)
	EndIf
EndFunc   ;==>NumLkStatus
Func ToogleNumLk()
	Local $sg = ''
	If StringInStr($PcType, '笔记本') Then
		$sg = '[建议]当前计算机为笔记本建议关闭小键盘'
	Else
		$sg = '[建议]当前计算机不为笔记本建议开启小键盘'
	EndIf
	If BitAND(_WinAPI_GetKeyState($VK_NUMLOCK), 1) = 1 Then
		Send('{NUMLOCK off}')
		If $sHotkey = 1 Then
			RegWrite('HKEY_USERS\.Default\Control Panel\Keyboard', 'InitialKeyboardIndicators', 'REG_SZ', '0')
			RegWrite('HKEY_CURRENT_USER\Control Panel\Keyboard', 'InitialKeyboardIndicators', 'REG_SZ', '0')
			MsgBox(0, '提示', '已经将小键盘的状态长效设置为[关]', 5, $Form1)
		EndIf
		GUICtrlSetState($OnPic, $GUI_HIDE)
		GUICtrlSetState($OffPic, $GUI_SHOW)

		GUICtrlSetTip($OffPic, $sg & @LF & '[鼠标单击]临时切换小键盘状态' & @LF & '[ALT+N]长效切换小键盘状态' & @LF & '[小键盘当前状态]关闭', '提示', 1)
	Else
		Send('{NUMLOCK on}')
		If $sHotkey = 1 Then
			RegWrite('HKEY_USERS\.Default\Control Panel\Keyboard', 'InitialKeyboardIndicators', 'REG_SZ', '2')
			RegWrite('HKEY_CURRENT_USER\Control Panel\Keyboard', 'InitialKeyboardIndicators', 'REG_SZ', '2')
			MsgBox(0, '提示', '已经将小键盘的状态长效设置为[开]', 5, $Form1)
		EndIf
		GUICtrlSetState($OnPic, $GUI_SHOW)
		GUICtrlSetState($OffPic, $GUI_HIDE)
		GUICtrlSetTip($OnPic, $sg & @LF & '[鼠标单击]临时切换小键盘状态' & @LF & '[ALT+N]长效切换小键盘状态' & @LF & '[小键盘当前状态]开启', '提示', 1)
	EndIf
EndFunc   ;==>ToogleNumLk

Func ToogleNumLkHk()
	$sHotkey = 1
	ToogleNumLk()
	$sHotkey = 0
EndFunc   ;==>ToogleNumLkHk

;=========================================================================================
; 全局功能
;=========================================================================================
; 全选和反选

Func SelectAll($aArray)
	For $i = 1 To UBound($aArray) - 1
		GUICtrlSetState($aArray[$i], $GUI_CHECKED)
	Next
;~ 	_SendMessage(@GUI_WinHandle,$WM_COMMAND)
EndFunc   ;==>SelectAll
;
; 反选
Func reverseSelect($aArray)
	For $i = 1 To UBound($aArray) - 1
		If GUICtrlGetState($aArray[$i]) <> 144 Then
			GUICtrlSetState($aArray[$i], BitAND(BitOR($GUI_CHECKED, $GUI_UNCHECKED), BitNOT(GUICtrlRead($aArray[$i]))))
		EndIf
	Next
	_SendMessage(@GUI_WinHandle, $WM_COMMAND)
EndFunc   ;==>reverseSelect

;注册表
Func regall()
	SelectAll($Checkbox)
EndFunc   ;==>regall
Func regreverse()
	reverseSelect($Checkbox)
EndFunc   ;==>regreverse

;插件
Func pluginsall()
	SelectAll($plugins)
EndFunc   ;==>pluginsall
Func pluginsreverse()
	reverseSelect($plugins)
EndFunc   ;==>pluginsreverse
;服务功能
Func svcall()
	SelectAll($svc)
EndFunc   ;==>svcall
Func svcreverse()
	reverseSelect($svc)
EndFunc   ;==>svcreverse
;SSD
Func ssdall()
	SelectAll($SSDbox)
EndFunc   ;==>ssdall
Func ssdreverse()
	reverseSelect($SSDbox)
EndFunc   ;==>ssdreverse

Func W81DirCheckAll()
	SelectAll($W81Dir)
EndFunc   ;==>W81DirCheckAll

Func W81Dirreverse()
	reverseSelect($W81Dir)
EndFunc   ;==>W81Dirreverse

Func SecurityCheckAll()
	SelectAll($SecuritySet)
EndFunc   ;==>SecurityCheckAll
Func SecurityReverse()
	reverseSelect($SecuritySet)
EndFunc   ;==>SecurityReverse
;;windows7激活相关

;退出的事件响应
Func quitForm()
	Run(@ComSpec & ' /c taskkill /im "bios.exe" /f', @WindowsDir, @SW_HIDE)
	_WinAPI_AnimateWindow($ActForm, BitOR($AW_BLEND, $AW_HIDE), 500)
	GUIDelete($ActForm)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>quitForm

Func ExitFunc()
	_WinAPI_SetWindowLong($hInput[0], -4, $CallProc)
;~         _WinAPI_SetWindowLong($hInput2, -4, $CallProc)
	For $i = 1 To UBound($hInput) - 1
		_WinAPI_SetWindowLong($hInput[$i], -4, $CallProc)
	Next
EndFunc   ;==>ExitFunc


Func My_InputProc($hWnd, $Msg, $WParam, $LParam)
	Switch $Msg
		Case 0x0084 ;WM_NCHITTEST
			$hover = $hWnd
		Case 0x02A3 ;WM_MOUSELEAVE
			$hover = False
			Local $tRect = _WinAPI_GetWindowRect($hWnd)
			Local $Width = DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1)
			Local $Height = DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2)
			_WinAPI_ScreenToClient($Form1, $tRect)
			DllStructSetData($tRect, 3, $Width + DllStructGetData($tRect, 1))
			DllStructSetData($tRect, 4, $Height + DllStructGetData($tRect, 2))
			_WinAPI_InflateRect($tRect, 1, 1)
			_WinAPI_InvalidateRect($Form1, $tRect)
		Case 0x0085 ;WM_NCPAINT
			_DrawEditFrame($hWnd)
			Return 0
	EndSwitch
	Return _WinAPI_CallWindowProc($CallProc, $hWnd, $Msg, $WParam, $LParam)
EndFunc   ;==>My_InputProc

Func _DrawEditFrame($hWnd)
	Local $tRect = _WinAPI_GetWindowRect($hWnd)
	Local $Width = DllStructGetData($tRect, 3) - DllStructGetData($tRect, 1)
	Local $Height = DllStructGetData($tRect, 4) - DllStructGetData($tRect, 2)
	_WinAPI_ScreenToClient($Form1, $tRect)
	DllStructSetData($tRect, 3, $Width + DllStructGetData($tRect, 1))
	DllStructSetData($tRect, 4, $Height + DllStructGetData($tRect, 2))
	$hDC = _WinAPI_GetDC($Form1)
	$hBrush = _WinAPI_CreateSolidBrush(0xC08B33)
	_WinAPI_FrameRect($hDC, DllStructGetPtr($tRect), $hBrush)
	_WinAPI_DeleteObject($hBrush)
	If $hover = $hWnd Then
		$hBrush = _WinAPI_CreateSolidBrush(0xFDC860) ;0xC08B33深蓝，0xFDC860淡蓝
		_WinAPI_InflateRect($tRect, 1, 1)
		_WinAPI_FrameRect($hDC, DllStructGetPtr($tRect), $hBrush)
		_WinAPI_DeleteObject($hBrush)
	EndIf
	_WinAPI_ReleaseDC($Form1, $hDC)
EndFunc   ;==>_DrawEditFrame

Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom, $iIDFrom, $iCode, $hWndEdit
	$hWndFrom = $ilParam
	$iIDFrom = _WinAPI_LoWord($iwParam)
	$iCode = _WinAPI_HiWord($iwParam)
	Switch $hWndFrom
		Case $hInput[0], $hInput[1], $hInput[2], $hInput[3], $hInput[4], $hInput[5], $hInput[6], $hInput[7], $hInput[8], $hInput[9], $hInput[10]
			Switch $iCode
				Case $EN_ALIGN_LTR_EC ; Sent when the user has changed the edit control direction to left-to-right

				Case $EN_ALIGN_RTL_EC ; Sent when the user has changed the edit control direction to right-to-left

				Case $EN_CHANGE ; Sent when the user has taken an action that may have altered text in an edit control
					GUICtrlSetColor($iIDFrom, 0x000000)
				Case $EN_ERRSPACE ; Sent when an edit control cannot allocate enough memory to meet a specific request

				Case $EN_HSCROLL ; Sent when the user clicks an edit control's horizontal scroll bar

				Case $EN_KILLFOCUS ; Sent when an edit control loses the keyboard focus
					GUICtrlSetColor($iIDFrom, 0x989898)
				Case $EN_MAXTEXT ; Sent when the current text insertion has exceeded the specified number of characters for the edit control

				Case $EN_SETFOCUS ; Sent when an edit control receives the keyboard focus
					GUICtrlSetColor($iIDFrom, 0x000000)
				Case $EN_UPDATE ; Sent when an edit control is about to redraw itself

				Case $EN_VSCROLL ; Sent when the user clicks an edit control's vertical scroll bar or when the user scrolls the mouse wheel over the edit control

			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND

Func _DEVICECHANGE($hWnd, $Msg, $WParam, $LParam)
	Switch $WParam
		Case $DBT_DEVICEARRIVAL, $DBT_DEVICEREMOVECOMPLETE
			_GetSourceDrivesToCombo()

	EndSwitch
EndFunc   ;==>_DEVICECHANGE
Func _Loader()
	;内存占用释放,转换内存到虚拟内存，读写磁盘io较大，故当系统为固态硬盘，不进行内存释放
	If Not $HasSSD Then DllCall('psapi.dll', 'bool', 'EmptyWorkingSet', 'handle', -1)
	$hHBmp_BG = _GDIPlus_MutiColorLoader($iW, $iH, $aText)
	$hB = GUICtrlSendMsg($iPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hHBmp_BG)
	If $hB Then _WinAPI_DeleteObject($hB)
	_WinAPI_DeleteObject($hHBmp_BG)
EndFunc   ;==>_Loader


Func _GDIPlus_MutiColorLoader($iW, $iH, $sText = "Loading", $sFont = "微软雅黑", $iFontSize = 12, $bHBitmap = True)
	Local Const $hFormat = _GDIPlus_StringFormatCreate()
	Local Const $hFamily = _GDIPlus_FontFamilyCreate($sFont)
	Local Const $hFont = _GDIPlus_FontCreate($hFamily, $iFontSize)
	_GDIPlus_StringFormatSetAlign($hFormat, 1)
	_GDIPlus_StringFormatSetLineAlign($hFormat, 1)
	Local $tLayout = _GDIPlus_RectFCreate()
	Local Const $hBitmap = _GDIPlus_BitmapCreateFromScan0($iW, $iH)
	Local Const $hGfx = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsSetSmoothingMode($hGfx, 4 + (@OSBuild > 5999))
	_GDIPlus_GraphicsSetTextRenderingHint($hGfx, 4)
	_GDIPlus_GraphicsSetPixelOffsetMode($hGfx, $GDIP_PIXELOFFSETMODE_HIGHQUALITY)

	Local Const $hBitmap_Bg = _GDIPlus_BitmapCreateFromMemory(_Background_Image())
	Local Const $hTexture = _GDIPlus_TextureCreate($hBitmap_Bg)
	_GDIPlus_GraphicsFillRect($hGfx, 0, 0, $iW, $iH, $hTexture)

	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGfx, $sText, $hFont, $tLayout, $hFormat)
	Local Const $hBrush_Text = _GDIPlus_BrushCreateSolid(0x20F0F0F0)

	$tLayout.Width = $iW + 2.5
	$tLayout.Height = $iH / 2 + 2.5
	_GDIPlus_GraphicsDrawStringEx($hGfx, $sText, $hFont, $tLayout, $hFormat, $hBrush_Text)
	_GDIPlus_BrushSetSolidColor($hBrush_Text, 0xFF232323)
	$tLayout.Width = $iW
	$tLayout.Height = $iH / 2
	_GDIPlus_GraphicsDrawStringEx($hGfx, $sText, $hFont, $tLayout, $hFormat, $hBrush_Text)

	Local Const $iColors = 7
	Local Const $aColors[$iColors] = [0xFF2ECC71, 0xFF3498DB, 0xFF9B59B6, 0xFFE67E22, 0xFFC0392B, 0xFFE74C3C, 0xFFE74C8C]
	Local Const $hBrush = _GDIPlus_BrushCreateSolid()
	Local Const $iWidth = 10, $iSpace = 4, $iX = ($iW - $iColors * ($iWidth + $iSpace)) / 2, $iHeight = $iH / 5
	Local $i, $fDH
	Local Static $s, $t
	For $i = 0 To UBound($aColors) - 1
		_GDIPlus_BrushSetSolidColor($hBrush, $aColors[$i])
		$fDH = Sin($s + Cos($i + $t)) * $iHeight * 0.66666
		_GDIPlus_GraphicsFillRect($hGfx, $iX + $i * ($iWidth + $iSpace), (-$iHeight + $iH - $fDH) / 2, $iWidth, $iHeight + $fDH, $hBrush)
		$s += 0.05
	Next
	$t += 0.1
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_GraphicsDispose($hGfx)

	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
	_GDIPlus_StringFormatDispose($hFormat)
	_GDIPlus_BrushDispose($hBrush_Text)
	_GDIPlus_BrushDispose($hTexture)
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_BitmapDispose($hBitmap_Bg)

	If $bHBitmap Then
		Local $hHBITMAP = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
		_GDIPlus_BitmapDispose($hBitmap)
		Return $hHBITMAP
	EndIf
	Return $hBitmap
EndFunc   ;==>_GDIPlus_MutiColorLoader


Func _ScrollingCredits($sText, $iLeft, $iTop, $iWidth, $iHeight, $iSpeed = 100, $sTipText = '', $sFontFamily = '微软雅黑', $iDirection = 1, $fCenter = False, $iFontSize = 12)
	Local $sCenterEnd = '', $sCenterStart = '', $sDirection = 'up'

	If $fCenter = Default Then
		$fCenter = 0
	EndIf
	If $iDirection = Default Then
		$iDirection = 1
	EndIf
	If $iFontSize = Default Then
		$iFontSize = 10
	EndIf
	If $sFontFamily = Default Then
		$sFontFamily = '微软雅黑'
	EndIf
	If $fCenter Then
		$sCenterStart = '<center>'
		$sCenterEnd = '</center>'
	EndIf
	If $iDirection > 1 Then
		$sDirection = 'down'
	EndIf

	$sText = StringRegExpReplace($sText, '\r\n|\r|\n', '<br>') ; Replace @CRLF, @CR & @LF with <br>.
	Local $oShellObject = ObjCreate('Shell.Explorer.2')
	If IsObj($oShellObject) = 0 Then
		Return SetError(1, 0, -1)
	EndIf

	Local $iControlObject = GUICtrlCreateObj($oShellObject, $iLeft, $iTop, $iWidth, $iHeight)
	$oShellObject.navigate('about:blank')
	While $oShellObject.busy
		Sleep(100)
	WEnd

	With $oShellObject.document
		.write('<style>marquee{cursor: default;color:grey}></style>')
		.write('<body onselectstart="return false" oncontextmenu="return false" ondragstart="return false"  onmouseover="return false">')
		.writeln('<marquee width=100% height=100% onmouseover="this.stop()" onmouseout="this.start()"')
		.writeln('loop="0"')
		.writeln('behavior="scroll"')
		.writeln('direction="' & $sDirection & '"')
		.writeln('scrollamount="2"')
		.writeln('scrolldelay="' & $iSpeed & '"')
		.write('>')
		.writeln($sCenterStart)
		.write($sText)
		.writeln($sCenterEnd)
		.writeln('</marquee>')
		.body.title = $sTipText
		.body.topmargin = 0
		.body.leftmargin = 0
		.body.scroll = 'no'
		.body.style.backgroundColor = Hex(_WinAPI_GetSysColor($COLOR_MENU), 6)
		.body.style.color = Hex(_WinAPI_GetSysColor($COLOR_WINDOWTEXT), 6)
		.body.style.borderWidth = 0
		.body.style.fontFamily = $sFontFamily
		.body.style.fontSize = $iFontSize
	EndWith
	Return $iControlObject
EndFunc   ;==>_ScrollingCredits

Func _ShowMain()
	If IsHWnd($Form1) Then
		If Not WinActive($Form1) Then
			WinActivate($Form1)
		EndIf
	EndIf
EndFunc   ;==>_ShowMain
Func _WinHide($hWnd)
	$Wp = WinGetPos($hWnd)
	$Mp = MouseGetPos()
	Select
		Case $Wp[1] <= 3 ;靠在上边
			If $Mp[0] >= $Wp[0] And $Mp[0] <= $Wp[0] + $Wp[2] And $Mp[1] >= $Wp[1] And $Mp[1] <= $Wp[1] + $Wp[3] Then ;如果鼠标的位置在界面窗口内
				WinSetOnTop($Form1, "", 0) ;显示时撤消置顶属性
				WinMove($hWnd, "", $Wp[0], 0, $Wp[2], $Wp[3], 1) ;上边显示
			Else
				WinSetOnTop($Form1, "", 1) ;隐藏时设置置顶属性
				WinMove($hWnd, "", $Wp[0], 3 - $Wp[3], $Wp[2], $Wp[3], 1) ;上边隐藏
			EndIf
		Case $Wp[1] >= @DesktopHeight - $Wp[3] - 3 ;靠在下边
			If $Mp[0] >= $Wp[0] And $Mp[0] <= $Wp[0] + $Wp[2] And $Mp[1] >= $Wp[1] And $Mp[1] <= $Wp[1] + $Wp[3] Then
				WinSetOnTop($Form1, "", 0)
				WinMove($hWnd, "", $Wp[0], @DesktopHeight - $Wp[3], $Wp[2], $Wp[3], 1) ;下边显示
			Else
				WinSetOnTop($Form1, "", 1)
				WinMove($hWnd, "", $Wp[0], @DesktopHeight - 3, $Wp[2], $Wp[3], 1) ;下边隐藏
			EndIf
		Case $Wp[0] <= 0 ;靠在左边
			If $Mp[0] >= $Wp[0] And $Mp[0] <= $Wp[0] + $Wp[2] And $Mp[1] >= $Wp[1] And $Mp[1] <= $Wp[1] + $Wp[3] Then
				WinSetOnTop($Form1, "", 0)
				WinMove($hWnd, "", 0, $Wp[1], $Wp[2], $Wp[3], 1) ;左边显示
			Else
				WinSetOnTop($Form1, "", 1)
				WinMove($hWnd, "", -$Wp[2] + 3, $Wp[1], $Wp[2], $Wp[3], 1) ;左边隐藏
			EndIf
		Case $Wp[0] >= (@DesktopWidth - $Wp[2] + 3) ;靠在右边
			If $Mp[0] >= $Wp[0] And $Mp[0] <= $Wp[0] + $Wp[2] And $Mp[1] >= $Wp[1] And $Mp[1] <= $Wp[1] + $Wp[3] Then
				WinSetOnTop($Form1, "", 0)
				WinMove($hWnd, "", @DesktopWidth - $Wp[2] + 3, $Wp[1], $Wp[2], $Wp[3], 1) ;右边显示
			Else
				WinSetOnTop($Form1, "", 1)
				WinMove($hWnd, "", @DesktopWidth - 3, $Wp[1], $Wp[2], $Wp[3], 1) ;右边隐藏
			EndIf
	EndSelect
EndFunc   ;==>_WinHide
Func _WinHideMain()
	_WinHide($Form1)
EndFunc   ;==>_WinHideMain
Func _GDIPlus_GraphicsGetDPIRatio($iDPIDef = 96)
	Local $aResults[2] = [1, 1]
	_GDIPlus_Startup()

	Local $hGfx = _GDIPlus_GraphicsCreateFromHWND(0)
	If @error Then Return SetError(1, @extended, $aResults)

	Local $aResult
	#forcedef $__g_hGDIPDll, $ghGDIPDll
	$aResult = DllCall($__g_hGDIPDll, "int", "GdipGetDpiX", "handle", $hGfx, "float*", 0)
	If @error Then Return SetError(2, @error, $aResults)

	Local $iDPI = $aResult[2]
	Local $aResults[2] = [$iDPIDef / $iDPI, $iDPI / $iDPIDef]
	_GDIPlus_GraphicsDispose($hGfx)
	_GDIPlus_Shutdown()
	Return $aResults

EndFunc   ;==>_GDIPlus_GraphicsGetDPIRatio
Func _GUICtrlCreateCheckbox($cText, $Left, $Top, $Width, $Height, $Style = Default, $ExStyle = Default)
	Local $HCtrl = GUICtrlCreateCheckbox($cText, $Left, $Top, $Width, $Height, $Style = -1, $ExStyle = -1)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", 0, "wstr", 0)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	Return $HCtrl
EndFunc   ;==>_GUICtrlCreateCheckbox
Func _GUICtrlCreateRadio($cText, $Left, $Top, $Width, $Height, $Style = Default, $ExStyle = Default)
	$HCtrl = GUICtrlCreateRadio($cText, $Left, $Top, $Width, $Height, $Style = -1, $ExStyle = -1)
	DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle(-1), "wstr", 0, "wstr", 0)
	GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
	Return $HCtrl
EndFunc   ;==>_GUICtrlCreateRadio
Func _GUICreate($sTitle, $iWidth, $iHeight, $iLeft = -1, $iTop = -1, $Style = Default, $ExStyle = Default, $winP = 0)
	Local $Hwin = GUICreate($sTitle, $iWidth, $iHeight, $iLeft, $iTop, $Style, $ExStyle, $winP)
	_ChangeWindowMessageFilterEx($Hwin, 0x233, 1)
	_ChangeWindowMessageFilterEx($Hwin, $WM_COPYDATA, 1)
	_ChangeWindowMessageFilterEx($Hwin, 0x0049, 1)
	Return $Hwin
EndFunc   ;==>_GUICreate
Func _Monitor_OFF()
	Local $Progman_hwnd = WinGetHandle('[CLASS:Progman]')
	DllCall('user32.dll', 'int', 'SendMessage', _
			'hwnd', $Progman_hwnd, _
			'int', 274, _
			'int', 61808, _
			'int', 2)
EndFunc   ;==>_Monitor_OFF
Func _MoveGUI()
	_SendMessage($Form1, $WM_SYSCOMMAND, ($SC_MOVE + $HTCAPTION), 0)
EndFunc   ;==>_MoveGUI
Func _MinisizeGUI()
	GUISetState(@SW_MINIMIZE, $Form1)
EndFunc   ;==>_MinisizeGUI
Func _Hover_Func($iCtrlID, $iParam)
	Local $NameOfbmp = ''
	If Not FileExists(@TempDir & '\IMG_CLOSE_H.bmp') Then _IMG_CLOSE_Hbmp(True, @TempDir)
	If Not FileExists(@TempDir & '\IMG_CLOSE_N.bmp') Then _IMG_CLOSE_Nbmp(True, @TempDir)
	If Not FileExists(@TempDir & '\IMG_MAX_H.bmp') Then _IMG_MAX_Hbmp(True, @TempDir)
	If Not FileExists(@TempDir & '\IMG_MAX_N.bmp') Then _IMG_MAX_Nbmp(True, @TempDir)
	If Not FileExists(@TempDir & '\IMG_MIN_H.bmp') Then _IMG_MIN_Hbmp(True, @TempDir)
	If Not FileExists(@TempDir & '\IMG_MIN_N.bmp') Then _IMG_MIN_Nbmp(True, @TempDir)
	$NameOfClosebmp = @TempDir & '\IMG_CLOSE_H.bmp'
	$NameOfMaxbmp = @TempDir & '\IMG_MAX_H.bmp'
	$NameOfMinbmp = @TempDir & '\IMG_MIN_H.bmp'
	;Hover事件结束
	If $iParam = 2 Then
		$NameOfClosebmp = @TempDir & '\IMG_CLOSE_N.bmp'
		$NameOfMaxbmp = @TempDir & '\IMG_MAX_N.bmp'
		$NameOfMinbmp = @TempDir & '\IMG_MIN_N.bmp'
	EndIf
	Switch $iCtrlID
		Case $IMGClose
			GUICtrlSetImage($IMGClose, $NameOfClosebmp)
		Case $IMGMax
			GUICtrlSetImage($IMGMax, $NameOfMaxbmp)
		Case $IMGMin
			GUICtrlSetImage($IMGMin, $NameOfMinbmp)
	EndSwitch
EndFunc   ;==>_Hover_Func

Func _GUICtrlIpAddress_Disable($hWnd, $iFields = 0)
	Local $aFields[4], $n = 0, $hEdit

	If Not IsInt($iFields) Or $iFields < 0 Or $iFields > 15 Then Return SetError(3, 0, 0)

	Local $hWindow = _WinAPI_GetAncestor($hWnd)
	If @error Then Return SetError(1, 0, 0)
	If Not $hWindow Or Not WinExists($hWnd) Then Return SetError(2, 0, 0)

	StringRegExpReplace(WinGetClassList($hWindow), "(?im)^Edit$", "")
	For $i = 1 To @extended
		$hEdit = ControlGetHandle($hWindow, "", "[CLASSNN:Edit" & $i & "]")
		If _WinAPI_GetParent($hEdit) = $hWnd Then
			If $n > 3 Then Return SetError(1, 0, 0)
			$aFields[$n] = $hEdit
			$n += 1
		EndIf
	Next
	If $n <> 4 Then Return SetError(1, 0, 0)

	If $iFields = 0xf Then Return ControlDisable($hWindow, "", $hWnd)
	Local $iRet = ControlEnable($hWindow, "", $hWnd)
	$iRet *= (BitAND($iFields, 1) ? ControlDisable($hWindow, "", $aFields[3]) : ControlEnable($hWindow, "", $aFields[3]))
	$iRet *= (BitAND($iFields, 2) ? ControlDisable($hWindow, "", $aFields[2]) : ControlEnable($hWindow, "", $aFields[2]))
	$iRet *= (BitAND($iFields, 4) ? ControlDisable($hWindow, "", $aFields[1]) : ControlEnable($hWindow, "", $aFields[1]))
	$iRet *= (BitAND($iFields, 8) ? ControlDisable($hWindow, "", $aFields[0]) : ControlEnable($hWindow, "", $aFields[0]))

	Return $iRet
EndFunc   ;==>_GUICtrlIpAddress_Disable
