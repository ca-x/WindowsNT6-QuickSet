#Region Header

#include-once

#CS UDF Info

	Name.........:      GUICtrlOnHover.au3
	Description..:      Allows to set event function for the window control hover process.
	Forum link...:      http://www.autoitscript.com/forum/index.php?s=&showtopic=55120
	Author.......:      G.Sandler a.k.a MrCreatoR (CreatoR's Lab, www.creator-lab.ucoz.ru, www.autoit-script.ru)
	Remarks......:  	
						1)	TreeView/ListView Items can not be set :(.
						2)	When the window is not active, the hover/leave hover functions will still called, but not when the window is disabled.
						3)	The hover/leave hover functions will be called even if the script is paused by such functions as MsgBox().
						4)	The $sHover_Func/$sLeaveHover_Func functions should not introduce significant delays in the main script,
							for example by calling functions like Sleep() or MsgBox().
						5) IMPORTANT!
							A)	Do not call _GUICtrl_OnHoverRegister inside $sHover_Func/$sLeaveHover_Func functions, it's not a good idea.
							
							B)	This UDF registering WM_COMMAND and WM_LBUTTONDOWN window messages.
								Please ensure that those messages are not used after including this library,
								if they do, you will have to call __GUICtrl_SOH_WM_COMMAND and __GUICtrl_SOH_WM_LBUTTONDOWN inside those functions. Example:
								
								Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
									__GUICtrl_SOH_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
 									...
								EndFunc
	
	
	*** Version History ***
	
	[v2.1] - [05.12.2010]
	+ Added function to release all resources: _GUICtrl_OnHoverReleaseResources
	+ Added alternative UDF "GUICtrlOnHover_NoCallback.au3", it uses AdlibRegister instead of callback with timer. In some cases callback can cause a memory leak.
		The disadvantage is obvious, any blocking function or loop will "freez" the hovering events.
	
	[v2.0] - [09.06.2010]
	* Fixed potential issue with calling $sPrimaryDownFunc function (first call was performed only after recieving WM_COMMAND message, wich is the control event).
	* Fixed an issue with blocking the OnHover function - the OnLeaveHover function was not called untill the OnHover function was blocked.
	* Fixed(?) (again) issue when the UDF is not working under 64-bit OS.
	* Optimized internal "__GUICtrl_SOH_Call" function to work faster when calling parameters functions.
	
	[v1.9] - [21.05.2010]
	* UDF library now compatible with AutoIt 3.3.6.1.
	* UDF library renamed to GUICtrlOnHover.au3.
	* Changed the main function name to _GUICtrl_OnHoverRegister, For backwards compatibility reasons, other (old) function names are still supported:
		_GUICtrl_SetOnHover, GUICtrl_SetOnHover, GUICtrlSetOnHover, _GUICtrlSetOnHover
	
	* Fixed(?) issue when the UDF is not working under 64-bit OS.
	* Global variables and internal functions renaming (for "cosmetic" reasons only).
	* UDF's code is more readable now.
	
	
	[v1.8] - [28.09.2009]
	* Few Global variables now have more unique name.
	* Fixed an issue with false calling of function on PrimaryDown event.
		I.e when the user clicks on other place (not on the hovered control) and drag the cursor to the control, the PrimaryDown function was called.
	* Due to (and as a result of) previous issue, the UDF now registering WM_COMMAND and WM_LBUTTONDOWN messages at first UDF call.
	
	
	[v1.7] - [07.07.2009]
	+ Added _GUICtrl_SetHoverOnBackWindow...
		Allows to set the hovering mode:
				$iSetBackWin = 1 (default) hovering process will proceed even when GUI is not active (in background).
				$iSetBackWin <> 1 hovering process will NOT proceed when GUI is not active.
	
	
	[v1.6] - [12.06.2009]
	* Now the UDF compatible with scripts (or other udfs) that uses OnAutoItExit function.
		i.e: "OnAutoItExit" function that was *previously* set by user will be called as well.
	
	+ Added new parameter $iKeepCall_Hover_Func. If this parameter = 1, 
		then the $sHover_Func function *Will* be called constantly untill the control is no longer been hovered
		(default is 0, do not call the function constantly).
	+ Added new arguments to calling function...
		The OnPrimaryDown/Up function now can recieve one more argument:
			$iClickMode - Defines the Click mode (1 - Pressed, 2 - Released)
	
	* Changed return value - function will return 2 when $iCtrlID is redefined (ReSet, already exists in the controls list).
	* Fixed incorrect documentation parts.
	* Fixed "OnClick" handeling. When using multiple GUIs, the active gui was not recognized properly.
	* Fixed(?) bug with "dimension range exceeded" when trying to UnSet a Control.
	
	[v1.5]
	+ Added AutoIt 3.2.10.0+ support, but 3.2.8.1 or less is dropped :( (due to lack of native CallBack functions).
	+ Added Primary Down and Primary Up support. Helping to handle with the buttons pressing.
	+ Added new arguments to calling function...
		The OnHover function now can recieve two more arguments:
			$iHoverMode - Defines the hover mode (1 - Hover, 2 - Leaves Hovering)
			$hWnd_Hovered - Control Handle where the mouse is moved to (after hovering).
	
	* Almost all code of this UDF was rewritted.
	* Now the main function name is _GUICtrl_SetOnHover(),
		but for backwards compatibility reasons, other (old) function names are still supported.
	* Fixed bug with hovering controls in other apps.
	* Improvements in generaly, the UDF working more stable now.
	
	[v1.?]
	* Beta changes, see "Forum link" for more details.
	
	[v1.0]
	* First release.

#CE

#EndRegion Header

#Region Internal Global Variables

Global $a__GUICtrl_SOH_Ctrls[1][1]
Global $a__GUICtrl_SOH_LastHoveredElements[2] 		= [-1, -1]
Global $a__GUICtrl_SOH_LastHoveredElementsMark 		= -1
Global $h__GUICtrl_SOH_LastClickedElementMark 		= -1
Global $i__GUICtrl_SOH_CtrlsModified				= 0
Global $i__GUICtrl_SOH_HoverOnBackWin				= 1
Global $i__GUICtrl_SOH_LastPrimaryDownCtrlID		= 0

Global $i__GUICtrl_SOH_Adlib 						= 0

Global $s__GUICtrl_SOH_User32_Dll					= @SystemDir & "\User32.dll"
Global $s__GUICtrl_SOH_OnExitFunc 					= ""

If @AutoItVersion < "3.3.2.0" Then
	$s__GUICtrl_SOH_OnExitFunc = Execute('Opt("OnExitFunc", "__GUICtrl_SOH_Exit")')
Else
	Execute('OnAutoItExitRegister("__GUICtrl_SOH_Exit")')
EndIf

Global Const $n__GUICtrl_SOH_WM_COMMAND				= 0x0111
Global Const $n__GUICtrl_SOH_WM_LBUTTONDOWN			= 0x0201

#EndRegion Internal Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........:	_GUICtrl_OnHoverRegister
; Description....:	Registers a function to be called when GUI elements been hovered.
; Syntax.........:	_GUICtrl_OnHoverRegister($iCtrlID [, $sHover_Func="" [, $sLeaveHover_Func=-1 [, $sPrimaryDownFunc=-1 [, $sPrimaryUpFunc=-1 [, $iKeepCall_PrDn_Func=1 [, $iKeepCall_Hover_Func=0 ]]]]]])
; 
; Parameters.....:	$iCtrlID              - The Ctrl ID to set hovering for (can be a -1 as indication to the last item created).
;
;                   $sHover_Func          - [Optional] Function to call when the mouse is hovering the control.
;                                             If this parameter passed as empty string (""),
;                                             then the specified CtrlID is UnSet from Hovering Handler list.
;
;                   $sLeaveHover_Func     - [Optional] Function to call when the mouse is leaving hovering the control
;                       (-1 no function used).
;                     * For both parameters, $sHover_FuncName and $sLeaveHover_FuncName,
;                       the specified function called with maximum 3 parameters:
;                                                     $iCtrlID      - CtrlID of hovered control.
;                                                     $iHoverMode   - Defines the hover mode (1 - Hover, 2 - Leaves Hovering).
;                                                     $hWnd_Hovered - Control Handle where the mouse is moved to (after hovering).
;
;                   $sPrimaryDownFunc     - [Optional] Function to call when Primary mouse button is *clicked* on the control.
;                       (-1 -> function is not called).
;
;                   $sPrimaryUpFunc       - [Optional] Function to call when Primary mouse button is *released* the control.
;                       (-1 -> function is not called).
;
;                     * For both parameters, $sPrimaryDownFunc and $sPrimaryUpFunc,
;                       the specified function called with maximum 2 parameters:
;                                                     $iCtrlID      - CtrlID of clicked control.
;                                                     $iClickMode   - Defines the click mode (1 - Pressed, 2 - Released).
;
;                   $iKeepCall_PrDn_Func  - [Optional] If this parameter < 1,
;                                            then the $sPrimaryDownFunc function will *Not* be called constantly untill
;                                            the primary mouse button is released (default behaviour - $iKeepCall_PrDn_Func = 1).
;
;                   $iKeepCall_Hover_Func - [Optional] If this parameter = 1,
;                                            then the $sHover_Func function *Will* be called constantly untill
;                                            the control is no longer been hovered (default behaviour - $iKeepCall_Hover_Func = 0).
;					
; Return values..:	Success               - Returns 1 if the function registered succesefully.
;                                           When $iCtrlID is redefined (ReSet, already exists in the controls list), the return value is 2.
;					Failure               - Set @error to 1 and return 0 if $iCtrlID is not a GUI Control Identifier.
; 
; Author.........:	G.Sandler (a.k.a CreatoR), www.creator-lab.ucoz.ru, www.autoit-script.ru.
; Modified.......:	
; Remarks........:	1) TreeView/ListView Items can not be set :(.
;                   2) When the window is not active, the hover/leave hover functions will still called, but not when the window is disabled.
;                   3) The hover/leave hover functions will be called even if the script is paused by such functions as MsgBox().
;                   4) The $sHover_Func/$sLeaveHover_Func functions should not introduce significant delays in the main script,
;                      for example by calling functions like Sleep() or MsgBox().
;                   5) IMPORTANT!
;                      A) Do not call _GUICtrl_OnHoverRegister inside $sHover_Func/$sLeaveHover_Func functions, it's not a good idea.
; 
;                      B) This UDF registering WM_COMMAND and WM_LBUTTONDOWN window messages.
;                      Please ensure that those messages are not used after including this library,
;                      if they do, you will have to call __GUICtrl_SOH_WM_COMMAND and __GUICtrl_SOH_WM_LBUTTONDOWN inside those functions. Example:
;
;							Func MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
;								__GUICtrl_SOH_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
; 								...
;							EndFunc
; 
; Related........:	
; Link...........:	http://www.autoitscript.com/forum/index.php?s=&showtopic=55120
; Example........:	Yes.
; ===============================================================================================================
Func _GUICtrl_OnHoverRegister($iCtrlID, $sHover_Func="", $sLeaveHover_Func=-1, $sPrimaryDownFunc=-1, $sPrimaryUpFunc=-1, $iKeepCall_PrDn_Func=1, $iKeepCall_Hover_Func=0)
	Local $hCtrlID = GUICtrlGetHandle($iCtrlID)
	
	If Not $hCtrlID Then
		Return SetError(1, 0, 0)
	EndIf
	
	If $i__GUICtrl_SOH_Adlib = 0 Then
		$i__GUICtrl_SOH_Adlib = 1
		
		AdlibRegister("__GUICtrl_SOH_CALLBACK", 30)
		GUIRegisterMsg($n__GUICtrl_SOH_WM_COMMAND, "__GUICtrl_SOH_WM_COMMAND")
		GUIRegisterMsg($n__GUICtrl_SOH_WM_LBUTTONDOWN, "__GUICtrl_SOH_WM_LBUTTONDOWN")
	EndIf
	
	;UnSet Hovering for specified control (remove control id from hovering checking process)
	If $sHover_Func = "" And @NumParams <= 2 Then
		Local $a__GUICtrl_SOH_Ctrls_Tmp[1][1]
		Local $a__GUICtrl_SOH_Ctrls_Swap = $a__GUICtrl_SOH_Ctrls ;This one prevents a bug with "dimension range exceeded"
		
		For $i = 1 To $a__GUICtrl_SOH_Ctrls_Swap[0][0]
			If $hCtrlID <> $a__GUICtrl_SOH_Ctrls_Swap[$i][0] Then
				$a__GUICtrl_SOH_Ctrls_Tmp[0][0] += 1
				ReDim $a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]+1][7]
				
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][0] = $a__GUICtrl_SOH_Ctrls_Swap[$i][0]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][1] = $a__GUICtrl_SOH_Ctrls_Swap[$i][1]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][2] = $a__GUICtrl_SOH_Ctrls_Swap[$i][2]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][3] = $a__GUICtrl_SOH_Ctrls_Swap[$i][3]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][4] = $a__GUICtrl_SOH_Ctrls_Swap[$i][4]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][5] = $a__GUICtrl_SOH_Ctrls_Swap[$i][5]
				$a__GUICtrl_SOH_Ctrls_Tmp[$a__GUICtrl_SOH_Ctrls_Tmp[0][0]][6] = $a__GUICtrl_SOH_Ctrls_Swap[$i][6]
			EndIf
		Next
		
		If $a__GUICtrl_SOH_Ctrls_Tmp[0][0] < 1 Then
			__GUICtrl_SOH_ReleaseResources() ;Release the callbacks
		Else
			$i__GUICtrl_SOH_CtrlsModified = 1
			$a__GUICtrl_SOH_Ctrls = $a__GUICtrl_SOH_Ctrls_Tmp
		EndIf
		
		Return 1
	EndIf
	
	;Check if the hovering process already handle the passed CtrlID, if so, just assign new values (functions)
	For $i = 1 To $a__GUICtrl_SOH_Ctrls[0][0]
		If $hCtrlID = $a__GUICtrl_SOH_Ctrls[$i][0] Then
			$a__GUICtrl_SOH_Ctrls[$i][0] = $hCtrlID
			$a__GUICtrl_SOH_Ctrls[$i][1] = $sHover_Func
			$a__GUICtrl_SOH_Ctrls[$i][2] = $sLeaveHover_Func
			$a__GUICtrl_SOH_Ctrls[$i][3] = $sPrimaryDownFunc
			$a__GUICtrl_SOH_Ctrls[$i][4] = $sPrimaryUpFunc
			$a__GUICtrl_SOH_Ctrls[$i][5] = $iKeepCall_PrDn_Func
			$a__GUICtrl_SOH_Ctrls[$i][6] = $iKeepCall_Hover_Func
			
			Return 2
		EndIf
	Next
	
	$a__GUICtrl_SOH_Ctrls[0][0] += 1
	ReDim $a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]+1][7]
	
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][0] = $hCtrlID
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][1] = $sHover_Func
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][2] = $sLeaveHover_Func
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][3] = $sPrimaryDownFunc
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][4] = $sPrimaryUpFunc
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][5] = $iKeepCall_PrDn_Func
	$a__GUICtrl_SOH_Ctrls[$a__GUICtrl_SOH_Ctrls[0][0]][6] = $iKeepCall_Hover_Func
	
	Return 1
EndFunc

;Set the hovering mode:
;                      $iSetBackWin = 1 (default) hovering process will proceed even when GUI is not active (in background).
;                      $iSetBackWin <> 1 hovering process will NOT proceed when GUI is not active.
Func _GUICtrl_SetHoverOnBackWindow($iSetBackWin)
	$i__GUICtrl_SOH_HoverOnBackWin = Number($iSetBackWin = 1)
EndFunc

;Releases all resources used by this UDF
Func _GUICtrl_OnHoverReleaseResources()
	__GUICtrl_SOH_ReleaseResources()
EndFunc

#EndRegion Public Functions

#Region Backwards Compatibility Functions

;Backwards compatibility function #1
Func _GUICtrl_SetOnHover($iCtrlID, $sHover_Func="", $sLeaveHover_Func=-1, $sPrimaryDownFunc=-1, $sPrimaryUpFunc=-1, $iKeepCall_PrDn_Func=1, $iKeepCall_Hover_Func=0)
	_GUICtrl_OnHoverRegister($iCtrlID, $sHover_Func, $sLeaveHover_Func, $sPrimaryDownFunc, $sPrimaryUpFunc, $iKeepCall_PrDn_Func, $iKeepCall_Hover_Func)
EndFunc

;Backwards compatibility function #2
Func GUICtrl_SetOnHover($iCtrlID, $sHover_Func="", $sLeaveHover_Func=-1, $sPrimaryDownFunc=-1, $sPrimaryUpFunc=-1, $iKeepCall_PrDn_Func=1, $iKeepCall_Hover_Func=0)
	_GUICtrl_OnHoverRegister($iCtrlID, $sHover_Func, $sLeaveHover_Func, $sPrimaryDownFunc, $sPrimaryUpFunc, $iKeepCall_PrDn_Func, $iKeepCall_Hover_Func)
EndFunc

;Backwards compatibility function #3
Func GUICtrlSetOnHover($iCtrlID, $sHover_Func="", $sLeaveHover_Func=-1, $sPrimaryDownFunc=-1, $sPrimaryUpFunc=-1, $iKeepCall_PrDn_Func=1, $iKeepCall_Hover_Func=0)
	_GUICtrl_OnHoverRegister($iCtrlID, $sHover_Func, $sLeaveHover_Func, $sPrimaryDownFunc, $sPrimaryUpFunc, $iKeepCall_PrDn_Func, $iKeepCall_Hover_Func)
EndFunc

;Backwards compatibility function #4
Func _GUICtrlSetOnHover($iCtrlID, $sHover_Func="", $sLeaveHover_Func=-1, $sPrimaryDownFunc=-1, $sPrimaryUpFunc=-1, $iKeepCall_PrDn_Func=1, $iKeepCall_Hover_Func=0)
	_GUICtrl_OnHoverRegister($iCtrlID, $sHover_Func, $sLeaveHover_Func, $sPrimaryDownFunc, $sPrimaryUpFunc, $iKeepCall_PrDn_Func, $iKeepCall_Hover_Func)
EndFunc

#EndRegion Backwards Compatibility Functions

#Region Internal Functions

;CallBack function to handle the hovering process
Func __GUICtrl_SOH_CALLBACK()
	$i__GUICtrl_SOH_CtrlsModified = 0
	
	If $a__GUICtrl_SOH_Ctrls[0][0] < 1 Then
		Return
	EndIf
	
	If $i__GUICtrl_SOH_HoverOnBackWin Then
		Local $iControl_Hovered = __GUICtrl_SOH_ControlGetHovered()
	Else
		Local $iControl_Hovered = GUIGetCursorInfo()
		
		If Not IsArray($iControl_Hovered) Then
			Return
		EndIf
		
		$iControl_Hovered = GUICtrlGetHandle($iControl_Hovered[4])
	EndIf
	
	Local $sCheck_LHE = $a__GUICtrl_SOH_LastHoveredElements[1]
	Local $iCheck_LCEM = $h__GUICtrl_SOH_LastClickedElementMark
	Local $iCtrlID
	
	;Leave Hovering Process and reset variables
	If Not $iControl_Hovered Or ($sCheck_LHE <> -1 And $iControl_Hovered <> $sCheck_LHE) Then
		If $a__GUICtrl_SOH_LastHoveredElementsMark = -1 Then
			Return
		EndIf
		
		Local $a__Tmp_GUICtrl_SOH_LastHoveredElements[2] = [$a__GUICtrl_SOH_LastHoveredElements[0], $a__GUICtrl_SOH_LastHoveredElements[1]]
		
		$a__GUICtrl_SOH_LastHoveredElements[0] = -1
		$a__GUICtrl_SOH_LastHoveredElements[1] = -1
		$a__GUICtrl_SOH_LastHoveredElementsMark = -1
		$h__GUICtrl_SOH_LastClickedElementMark = -1
		
		If $a__Tmp_GUICtrl_SOH_LastHoveredElements[0] <> -1 Then
			$iCtrlID = DllCall($s__GUICtrl_SOH_User32_Dll, "int", "GetDlgCtrlID", "hwnd", $a__Tmp_GUICtrl_SOH_LastHoveredElements[1])
			
			If IsArray($iCtrlID) Then
				$iCtrlID = $iCtrlID[0]
			EndIf
			
			;2 is the indicator of OnLeavHover process
			__GUICtrl_SOH_Call($a__Tmp_GUICtrl_SOH_LastHoveredElements[0], $iCtrlID, 2, $iControl_Hovered)
		EndIf
	Else ;Hovering Process, Primary Down/Up handler, and set $a__GUICtrl_SOH_LastHoveredElements
		If $i__GUICtrl_SOH_CtrlsModified = 1 Then
			$i__GUICtrl_SOH_CtrlsModified = 0
			Return
		EndIf
		
		Local $iUbound = UBound($a__GUICtrl_SOH_Ctrls)-1
		
		For $i = 1 To $a__GUICtrl_SOH_Ctrls[0][0]
			If $i > $iUbound Then
				ExitLoop
			EndIf
			
			If $a__GUICtrl_SOH_Ctrls[$i][0] = $iControl_Hovered Then
				$iCtrlID = DllCall($s__GUICtrl_SOH_User32_Dll, "int", "GetDlgCtrlID", "hwnd", $iControl_Hovered)
				
				If IsArray($iCtrlID) Then
					$iCtrlID = $iCtrlID[0]
				EndIf
				
				;Primary Down/Up handler
				If ($a__GUICtrl_SOH_Ctrls[$i][3] <> "" Or $a__GUICtrl_SOH_Ctrls[$i][4] <> "") And ($iCheck_LCEM = -1 Or $iCheck_LCEM = $iControl_Hovered) Then
					Local $aCursorInfo = 0
					Local $hParent_Wnd = DllCall($s__GUICtrl_SOH_User32_Dll, "hwnd", "GetParent", "hwnd", $iControl_Hovered)
					
					If Not @error And IsArray($hParent_Wnd) Then
						$hParent_Wnd = $hParent_Wnd[0]
						$aCursorInfo = GUIGetCursorInfo($hParent_Wnd)
					Else
						$aCursorInfo = GUIGetCursorInfo()
					EndIf
					
					If IsArray($aCursorInfo) Then
						;Primary Down...
						;* First condition is to prevent function call when holding down m.button from other control
						;* Last condition is to Prevent/Allow multiple function call 
						;(depending on $iKeepCall_PrDn_Func param).
						If ($i__GUICtrl_SOH_LastPrimaryDownCtrlID = $iControl_Hovered Or $i__GUICtrl_SOH_LastPrimaryDownCtrlID = 0) And WinActive($hParent_Wnd) And _
							$aCursorInfo[2] = 1 And $a__GUICtrl_SOH_Ctrls[$i][3] <> -1 And _
							(($a__GUICtrl_SOH_Ctrls[$i][5] < 1 And $iCheck_LCEM <> $iControl_Hovered) Or $a__GUICtrl_SOH_Ctrls[$i][5] > 0) Then
							
							;1 is the indicator of Primary*Down* event
							__GUICtrl_SOH_Call($a__GUICtrl_SOH_Ctrls[$i][3], $iCtrlID, 1)
							
							$h__GUICtrl_SOH_LastClickedElementMark = $iControl_Hovered
						;Primary Up
						ElseIf $aCursorInfo[2] = 0 And $a__GUICtrl_SOH_Ctrls[$i][4] <> -1 And $iCheck_LCEM = $iControl_Hovered Then
							;2 is the indicator of Primary*Up* event
							__GUICtrl_SOH_Call($a__GUICtrl_SOH_Ctrls[$i][4], $iCtrlID, 2)
							
							$h__GUICtrl_SOH_LastClickedElementMark = -1
						EndIf
					EndIf
				EndIf
				
				If $i__GUICtrl_SOH_CtrlsModified = 1 Then
					ExitLoop
				EndIf
				
				If $a__GUICtrl_SOH_Ctrls[$i][6] < 1 And $a__GUICtrl_SOH_LastHoveredElementsMark = $a__GUICtrl_SOH_Ctrls[$i][0] Then
					ExitLoop
				Else
					$a__GUICtrl_SOH_LastHoveredElementsMark = $a__GUICtrl_SOH_Ctrls[$i][0]
				EndIf
				
				If $a__GUICtrl_SOH_Ctrls[$i][2] <> -1 Then
					$a__GUICtrl_SOH_LastHoveredElements[0] = $a__GUICtrl_SOH_Ctrls[$i][2]
					$a__GUICtrl_SOH_LastHoveredElements[1] = $iControl_Hovered
				EndIf
				
				__GUICtrl_SOH_Call($a__GUICtrl_SOH_Ctrls[$i][1], $iCtrlID, 1, 0) ;1 is the indicator of OnHover process
				
				If $i__GUICtrl_SOH_CtrlsModified = 1 Then
					ExitLoop
				EndIf
				
				ExitLoop
			EndIf
		Next
	EndIf
	
	$i__GUICtrl_SOH_CtrlsModified = 0
EndFunc

Func __GUICtrl_SOH_WM_COMMAND($hWndGUI, $MsgID, $WParam, $LParam)
	$i__GUICtrl_SOH_LastPrimaryDownCtrlID = $LParam
EndFunc

Func __GUICtrl_SOH_WM_LBUTTONDOWN($hWndGUI, $MsgID, $WParam, $LParam)
	$i__GUICtrl_SOH_LastPrimaryDownCtrlID = 0
EndFunc

;Thanks to amel27 for that one!!!
Func __GUICtrl_SOH_ControlGetHovered()
	Local $iOld_Opt_MCM = Opt("MouseCoordMode", 1)
	Local $tPoint = DllStructCreate("int X;int Y")
	Local $aMPos = MouseGetPos()
	
	DllStructSetData($tPoint, "x", $aMPos[0])
	DllStructSetData($tPoint, "y", $aMPos[1])
	
	Local $tPointCast = DllStructCreate("int64", DllStructGetPtr($tPoint))
	Local $aRet = DllCall($s__GUICtrl_SOH_User32_Dll, "hwnd", "WindowFromPoint", "int64", DllStructGetData($tPointCast, 1))
	
	Opt("MouseCoordMode", $iOld_Opt_MCM)
	
	If @error Then
		Return SetError(@error, @extended, 0)
	EndIf
	
	Return $aRet[0]
EndFunc

;Call() function wrapper
Func __GUICtrl_SOH_Call($sFunction, $sParam1="", $sParam2="", $sParam3="", $sParam4="", $sParam5="")
	Local $iRet = Call($sFunction)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	$iRet = Call($sFunction, $sParam1)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	$iRet = Call($sFunction, $sParam1, $sParam2)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	$iRet = Call($sFunction, $sParam1, $sParam2, $sParam3)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	$iRet = Call($sFunction, $sParam1, $sParam2, $sParam3, $sParam4)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	$iRet = Call($sFunction, $sParam1, $sParam2, $sParam3, $sParam4, $sParam5)
	
	If @error <> 0xDEAD Then
		Return $iRet
	EndIf
	
	Return SetError(1, 0, 0)
EndFunc

;Release resources function
Func __GUICtrl_SOH_ReleaseResources()
	$i__GUICtrl_SOH_Adlib = 0
	
	AdlibUnRegister("__GUICtrl_SOH_CALLBACK")
	GUIRegisterMsg($n__GUICtrl_SOH_WM_COMMAND, "")
	GUIRegisterMsg($n__GUICtrl_SOH_WM_LBUTTONDOWN, "")
EndFunc

;Release the CallBack resources when exit
Func __GUICtrl_SOH_Exit()
	If $s__GUICtrl_SOH_OnExitFunc <> "" Then
		Call($s__GUICtrl_SOH_OnExitFunc)
	EndIf
	
	__GUICtrl_SOH_ReleaseResources()
EndFunc

#EndRegion Internal Functions
