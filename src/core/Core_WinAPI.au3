;==============================================================================
; 模块：WinAPI 底层封装
; 说明：权限提升、LSA、以 SYSTEM 身份运行、窗口消息过滤、鼠标按键等底层调用
; 文件：src\core\Core_WinAPI.au3
; 函数：共 15 个
;==============================================================================
#include-once

Func _SwapMouseButton($bFlag = True)
	$iResult = DllCall("user32.dll", "int", "SwapMouseButton", "int", $bFlag)
	Return $iResult[0]
EndFunc   ;==>_SwapMouseButton

Func _SwithMouseBtn()
	If _SwapMouseButton() Then
		_SwapMouseButton(False)
		MsgBox(0, '提示', '切换鼠标左右键为默认设置成功！！', 5)
	Else
		_SwapMouseButton()
		MsgBox(0, '提示', '切换鼠标左右键成功！！', 5)
	EndIf
EndFunc   ;==>_SwithMouseBtn

Func _SeImpersonateSystemContext($iImpersonationLevel, $iDesiredAccess)
	Local $iResult

	; get system id.
	; =========================================================================================================================

	$iResult = DllCall("Ntdll.dll", "ulong", "CsrGetProcessId")

	Local $iProcessID = $iResult[0]
	If $iProcessID == 0 Then Return SetError(1359, 1, 0) ; 1359=ERROR_INTERNAL_ERROR

	$iResult = DllCall("Ntdll.dll", "long", "NtQuerySystemInformation", "ulong", 5, "ptr", 0, "ulong", 0, "ulong*", 0)
	If $iResult[4] == 0 Then Return SetError($iResult[0], 2, 0)

	Local $tBuffer = DllStructCreate("ubyte Data[" & $iResult[4] & "]")
	Local $pBuffer = DllStructGetPtr($tBuffer)

	$iResult = DllCall("Ntdll.dll", "long", "NtQuerySystemInformation", "ulong", 5, "ptr", $pBuffer, "ulong", $iResult[4], "ulong*", 0)
	If $iResult[0] < 0 Then Return SetError($iResult[0], 3, 0)

	Local $iOffset, $tProcessInfo, $iSystemID

	Local Const $tagVM_COUNTERS = "ULONG_PTR PeakVirtualSize;ULONG_PTR VirtualSize;DWORD PageFaultCount;ULONG_PTR PeakWorkingSetSize;ULONG_PTR WorkingSetSize;ULONG_PTR QuotaPeakPagedPoolUsage;ULONG_PTR QuotaPagedPoolUsage;ULONG_PTR QuotaPeakNonPagedPoolUsage;ULONG_PTR QuotaNonPagedUsage;ULONG_PTR PagefileUsage;ULONG_PTR PeakPagefileUsage;"

	Local Const $tagIO_COUNTERS = "INT64 ReadOperationCount;INT64 WriteOperationCount;INT64 OtherOperationCount;INT64 ReadTransferCount;INT64 WriteTransferCount;INT64 OtherTransferCount;"

	If @AutoItX64 Then
		Local $tagSYSTEM_THREAD = "INT64 KernelTime;INT64 UserTime;INT64 CreateTime;ULONG WaitTime;ULONG_PTR Reserved3;PTR StartAddress;ULONG_PTR UniqueProcessId;ULONG_PTR UniqueThreadId;ULONG Priority;ULONG BasePriority;ULONG ContextSwitchCount;ULONG State;ULONG WaitReason;"
	Else
		Local $tagSYSTEM_THREAD = "INT64 KernelTime;INT64 UserTime;INT64 CreateTime;ULONG WaitTime;PTR StartAddress;ULONG_PTR UniqueProcessId;ULONG_PTR UniqueThreadId;ULONG Priority;ULONG BasePriority;ULONG ContextSwitchCount;ULONG State;ULONG WaitReason;"
	EndIf

	Local Const $tagSYSTEM_PROCESS_INFORMATION = "ULONG NextEntryOffset;ULONG NumberOfThreads;INT64 Reserved[3];INT64 CreateTime;INT64 UserTime;INT64 KernelTime;WORD Length;WORD MaximumLength;PTR ImageName;ULONG BasePriority;ULONG_PTR ProcessId;ULONG_PTR InheritedFromProcessId;ULONG HandleCount;ULONG Reserved[2];ULONG PrivatePageCount;" & $tagVM_COUNTERS & $tagIO_COUNTERS & $tagSYSTEM_THREAD

	While 1
		$tProcessInfo = DllStructCreate($tagSYSTEM_PROCESS_INFORMATION, $pBuffer)
		$iOffset = DllStructGetData($tProcessInfo, "NextEntryOffset")

		If DllStructGetData($tProcessInfo, "ProcessId") == $iProcessID Then
			$iSystemID = DllStructGetData($tProcessInfo, "UniqueThreadId")

			ExitLoop
		Else
			If $iOffset Then
				$pBuffer += $iOffset
			Else
				ExitLoop
			EndIf
		EndIf
	WEnd
	If $iSystemID = 0 Then Return SetError(1359, 4, 0)
	; =========================================================================================================================

	; enable Debug privilege.
	; =========================================================================================================================
	$iResult = DllCall("Advapi32.dll", "bool", "OpenProcessToken", "handle", -1, "dword", 0x0020, "handle*", 0)

	Local $hToken = $iResult[3]
	If $hToken = 0 Then Return SetError(s2er(0), 5, 0)

	Local $tTokenPrivileges = DllStructCreate("DWORD PrivilegeCount;DWORD LowPart;LONG HighPart;DWORD Attributes")
	Local $pTokenPrivileges = DllStructGetPtr($tTokenPrivileges)

	DllStructSetData($tTokenPrivileges, "PrivilegeCount", 1)
	DllStructSetData($tTokenPrivileges, "Attributes", 2) ; 2=SE_PRIVILEGE_ENABLED

	$iResult = DllCall("Advapi32.dll", "bool", "LookupPrivilegeValueW", "ptr", 0, "wstr", "SeDebugPrivilege", "ptr", DllStructGetPtr($tTokenPrivileges, "LowPart"))

	If Not $iResult[0] Then
		; handle error
	EndIf

	DllCall("Kernel32.dll", "none", "SetLastError", "dword", 0)
	DllCall("Advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", 0, "ptr", $pTokenPrivileges, "dword", 0, "ptr", 0, "ptr", 0)

	$iResult = DllCall("Kernel32.dll", "dword", "GetLastError")

	If $iResult[0] = 1300 Then ; 1300=ERROR_NOT_ALL_ASSIGNED
		; not all privileges are assigned.
	EndIf
	DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
	; =========================================================================================================================

	; impersonate security context.
	; =========================================================================================================================
	$iResult = DllCall("Kernel32.dll", "handle", "OpenThread", "dword", 0x0200, "bool", 0, "dword", $iSystemID)

	Local $hThread = $iResult[0]
	If $hThread = 0 Then Return SetError(s2er(0), 6, 0)

	Local $tSecurityQos = DllStructCreate("DWORD Length;DWORD ImpersonationLevel;BOOLEAN ContextTrackingMode;BOOLEAN EffectiveOnly")
	Local $pSecurityQos = DllStructGetPtr($tSecurityQos)

	DllStructSetData($tSecurityQos, "Length", DllStructGetSize($tSecurityQos))
	DllStructSetData($tSecurityQos, "ImpersonationLevel", $iImpersonationLevel)
	DllStructSetData($tSecurityQos, "ContextTrackingMode", 0)
	DllStructSetData($tSecurityQos, "EffectiveOnly", 0)

	$iResult = DllCall("Ntdll.dll", "long", "NtImpersonateThread", "handle", -2, "handle", $hThread, "ptr", $pSecurityQos)

	DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hThread)

	If $iResult[0] < 0 Then Return SetError($iResult[0], 7, 0)
	; =========================================================================================================================

	; open impersonation token.
	$iResult = DllCall("Advapi32.dll", "bool", "OpenThreadToken", "handle", -2, "dword", $iDesiredAccess, "boolean", 0, "handle*", 0)

	If $iResult[0] Then
		Return $iResult[4]
	Else
		Return SetError(s2er(0), 8, 0)
	EndIf
EndFunc   ;==>_SeImpersonateSystemContext

Func _SeCreateSystemProcess($sCommandLine, $sWorkingDir = @WorkingDir, $iShowCmd = @SW_SHOWNORMAL)
	Local $hImpersonationToken = _SeImpersonateSystemContext(2, 0x0F01FF)
	If $hImpersonationToken = 0 Then Return SetError(@error, @extended, 0)

	Local $iResult

	; enable privileges
	; =========================================================================================================================
	Local $tTokenPrivileges = DllStructCreate("DWORD;DWORD;LONG;DWORD;DWORD;LONG;DWORD")
	Local $pTokenPrivileges = DllStructGetPtr($tTokenPrivileges)

	DllStructSetData($tTokenPrivileges, 1, 1)
	DllStructSetData($tTokenPrivileges, 4, 2) ; 2=SE_PRIVILEGE_ENABLED
	DllStructSetData($tTokenPrivileges, 7, 2) ; 2=SE_PRIVILEGE_ENABLED

	$iResult = DllCall("Advapi32.dll", "bool", "LookupPrivilegeValueW", "ptr", 0, "wstr", "SeAssignPrimaryTokenPrivilege", "ptr", DllStructGetPtr($tTokenPrivileges, 2))
	$iResult = DllCall("Advapi32.dll", "bool", "LookupPrivilegeValueW", "ptr", 0, "wstr", "SeTcbPrivilege", "ptr", DllStructGetPtr($tTokenPrivileges, 5))

	If Not $iResult[0] Then
		; handle error
	EndIf

	DllCall("Kernel32.dll", "none", "SetLastError", "dword", 0)
	DllCall("Advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hImpersonationToken, "bool", 0, "ptr", $pTokenPrivileges, "dword", 0, "ptr", 0, "ptr", 0)

	$iResult = DllCall("Kernel32.dll", "dword", "GetLastError")

	If $iResult[0] = 1300 Then ; 1300=ERROR_NOT_ALL_ASSIGNED
		; not all privileges are assigned.
	EndIf
	; =========================================================================================================================

	; adjust session ID
	; =========================================================================================================================
	$iResult = DllCall("Kernel32.dll", "dword", "WTSGetActiveConsoleSessionId")
	$iResult = DllCall("Advapi32.dll", "bool", "SetTokenInformation", "handle", $hImpersonationToken, "ulong", 12, "dword*", $iResult[0], "dword", 4)
	If Not $iResult[0] Then
		; handle error
	EndIf
	; =========================================================================================================================

	$iResult = DllCall("Advapi32.dll", "bool", "GetTokenInformation", "handle", $hImpersonationToken, "ulong", 9, "dword*", 0, "dword", 4, "dword*", 0)
	If $iResult[3] <> 2 Then ; 2=SecurityImpersonation
		; handle error
	EndIf

	$iResult = DllCall("Advapi32.dll", "bool", "DuplicateTokenEx", "handle", $hImpersonationToken, "dword", 0x0F01FF, "ptr", 0, "dword", 0, "dword", 1, "handle*", 0)

	Local $hPrimaryToken = $iResult[6]
	If $hPrimaryToken = 0 Then Return SetError(s2er(0), 9, 0)

	If $sWorkingDir == "" Then $sWorkingDir = @WorkingDir

	Local Const $tagPROCESS_INFORMATION = "HANDLE hProcess;HANDLE hThread;DWORD ProcessID;DWORD ThreadID"
	Local Const $tagSTARTUPINFO = "DWORD Length;PTR Reserved;PTR Desktop;PTR Title;DWORD X;DWORD Y;DWORD XSize;DWORD YSize;DWORD XCountChars;DWORD YCountChars;DWORD FillAttributes;DWORD Flags;WORD ShowWindow;WORD Reserved2;PTR Reserved3;HANDLE StdInput;HANDLE StdOutput;HANDLE StdError"

	Local $tProcessInfo = DllStructCreate($tagPROCESS_INFORMATION)
	Local $pProcessInfo = DllStructGetPtr($tProcessInfo)

	Local $tStartupInfo = DllStructCreate($tagSTARTUPINFO)
	Local $pStartupInfo = DllStructGetPtr($tStartupInfo)

	DllStructSetData($tStartupInfo, "Length", DllStructGetSize($tStartupInfo))

	If @NumParams > 2 Then
		If IsKeyword($iShowCmd) Then $iShowCmd = @SW_SHOWNORMAL

		DllStructSetData($tStartupInfo, "ShowWindow", $iShowCmd)
		DllStructSetData($tStartupInfo, "Flags", 1)
	EndIf

	$iResult = DllCall("Advapi32.dll", "bool", "CreateProcessAsUserW", "handle", $hPrimaryToken, "ptr", 0, "wstr", $sCommandLine, "ptr", 0, "ptr", 0, "bool", 0, "dword", 0, "ptr", 0, "wstr", $sWorkingDir, "ptr", $pStartupInfo, "ptr", $pProcessInfo)

	Local $iError = s2er($iResult[0])

	DllCall("Advapi32.dll", "bool", "RevertToSelf")
	DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hImpersonationToken)
	DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hPrimaryToken)

	If $iResult[0] Then
		Return $tProcessInfo
	Else
		Return SetError($iError, 10, 0)
	EndIf
EndFunc   ;==>_SeCreateSystemProcess
Func RunAsSYSTEMWindows81($sCommand)
	If $sCommand <> '' Then
		$sCmdLine = $sCommand
		$Privs = "SeDebugPrivilege,SeAssignPrimaryTokenPrivilege,SeIncreaseQuotaPrivilege"
		$PrivsArray = StringSplit($Privs, ",")
		For $i = 1 To $PrivsArray[0]
			ConsoleWrite("Now setting privilege: " & $PrivsArray[$i] & @CRLF)
			_SetPrivilege($PrivsArray[$i])
		Next
		$sProcessAsUser = "winlogon.exe"

		$dwSessionId = DllCall("kernel32.dll", "dword", "WTSGetActiveConsoleSessionId")
		If @error Or $dwSessionId[0] = 0xFFFFFFFF Then
			ConsoleWrite("WTSGetActiveConsoleSessionId: " & _WinAPI_GetLastErrorMessage() & @CRLF)
			Return @error
		EndIf
		$dwSessionId = $dwSessionId[0]
		ConsoleWrite("Running in session: " & $dwSessionId & @CRLF)
		Dim $aProcs = ProcessList($sProcessAsUser), $processPID = -1, $ret
		For $i = 1 To $aProcs[0][0]
			$ret = DllCall("kernel32.dll", "int", "ProcessIdToSessionId", "dword", $aProcs[$i][1], "dword*", 0)
			If Not @error And $ret[0] And($ret[2] = $dwSessionId) Then
				$processPID = $aProcs[$i][1]
				ExitLoop
			EndIf
		Next
		ConsoleWrite("Host PID: " & $processPID & @CRLF)
		If $processPID = -1 Then
			ConsoleWrite("Return 0 ; failed to get winlogon PID in current sessio")
			Return @error
		EndIf
		Local $hProc = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", 0x001F0FFF, "int", 0, "dword", $processPID)
		If @error Or Not $hProc[0] Then
			ConsoleWrite("OpenProcess: " & _WinAPI_GetLastErrorMessage() & @CRLF)
			Return @error
		EndIf
		$hProc = $hProc[0]
		$hToken = DllCall($ghADVAPI32, "int", "OpenProcessToken", "ptr", $hProc, "dword", 0x2, "ptr*", 0)
		If @error Or Not $hToken[0] Then
			ConsoleWrite("OpenProcessToken: " & _WinAPI_GetLastErrorMessage() & @CRLF)
			DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hProc)
			Return @error
		EndIf
		$hToken = $hToken[3]
		$hDupToken = DllCall($ghADVAPI32, "int", "DuplicateTokenEx", "ptr", $hToken, "dword", 0x1F0FFF, "ptr", 0, "int", 1, "int", 1, "ptr*", 0)
		If @error Or Not $hDupToken[0] Then
			ConsoleWrite("DuplicateTokenEx: " & _WinAPI_GetLastErrorMessage() & @CRLF)
			DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hToken)
			DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hProc)
			Return @error
		EndIf
		$hDupToken = $hDupToken[6]
		$pEnvBlock = _GetEnvironmentBlock($sProcessAsUser, $dwSessionId) ; target process
		$dwCreationFlags = BitOR($NORMAL_PRIORITY_CLASS, $CREATE_NEW_CONSOLE)
		If $pEnvBlock Then $dwCreationFlags = BitOR($dwCreationFlags, $CREATE_UNICODE_ENVIRONMENT)
		$SI = DllStructCreate($tagSTARTUPINFO1)
		DllStructSetData($SI, "cb", DllStructGetSize($SI))
		$PI = DllStructCreate($tagPROCESSINFO1)
		$sDesktop = "winsta0\default"
		$lpDesktop = DllStructCreate("wchar[" & StringLen($sDesktop) + 1 & "]")
		DllStructSetData($lpDesktop, 1, $sDesktop)
		DllStructSetData($SI, "lpDesktop", DllStructGetPtr($lpDesktop))
		$ret = DllCall($ghADVAPI32, "bool", "CreateProcessWithTokenW", "handle", $hDupToken, "dword", 1, "ptr", 0, "wstr", $sCmdLine, "dword", $dwCreationFlags, "ptr", $pEnvBlock, "wstr", @WindowsDir, "ptr", DllStructGetPtr($SI), "ptr", DllStructGetPtr($PI))
		If @error Or Not $ret[0] Then
			$ret = DllCall($ghADVAPI32, "int", "CreateProcessAsUserW", "handle", $hDupToken, "ptr", 0, "wstr", $sCmdLine, "ptr", 0, "ptr", 0, "int", 0, "dword", $dwCreationFlags, "ptr", $pEnvBlock, "ptr", 0, "ptr", DllStructGetPtr($SI), "ptr", DllStructGetPtr($PI))
			If Not @error And $ret[0] Then
				ConsoleWrite("New process created successfully: " & DllStructGetData($PI, "dwProcessId") & @CRLF)
				DllCall("kernel32.dll", "int", "CloseHandle", "ptr", DllStructGetData($PI, "hThread"))
				DllCall("kernel32.dll", "int", "CloseHandle", "ptr", DllStructGetData($PI, "hProcess"))
			Else
				ConsoleWrite("CreateProcessAsUserW / CreateProcessWithTokenW: " & _WinAPI_GetLastErrorMessage() & @CRLF)
			EndIf
		EndIf

		If $pEnvBlock Then DllCall("userenv.dll", "int", "DestroyEnvironmentBlock", "ptr", $pEnvBlock)
		DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hDupToken)
		DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hToken)
		DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hProc)
	EndIf
EndFunc   ;==>RunAsSYSTEMWindows81

Func _GetEnvironmentBlock($sProcess, $dwSession)
	Local Const $MAXIMUM_ALLOWED1 = 0x02000000
	Local Const $dwAccess = BitOR(0x2, 0x8) ; TOKEN_DUPLICATE | TOKEN_QUERY

	; get PID of process in current session
	Local $aProcs = ProcessList($sProcess), $processPID = -1, $ret = 0
	For $i = 1 To $aProcs[0][0]
		$ret = DllCall("kernel32.dll", "int", "ProcessIdToSessionId", "dword", $aProcs[$i][1], "dword*", 0)
		If Not @error And $ret[0] And($ret[2] = $dwSession) Then
			$processPID = $aProcs[$i][1]
			ExitLoop
		EndIf
	Next
	If $processPID = -1 Then Return 0 ; failed to get PID
	; open process
	Local $hProc = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", 0x02000000, "int", 0, "dword", $processPID)
	If @error Or Not $hProc[0] Then Return 0
	$hProc = $hProc[0]
	; open process token
	$hToken = DllCall($ghADVAPI32, "int", "OpenProcessToken", "ptr", $hProc, "dword", $dwAccess, "ptr*", 0)
	If @error Or Not $hToken[0] Then
		ConsoleWrite("OpenProcessToken: " & _WinAPI_GetLastErrorMessage() & @CRLF)
		DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hProc)
		Return 0
	EndIf
	$hToken = $hToken[3]
	; create a new environment block
	Local $pEnvBlock = DllCall("userenv.dll", "int", "CreateEnvironmentBlock", "ptr*", 0, "ptr", $hToken, "int", 1)
	If Not @error And $pEnvBlock[0] Then $ret = $pEnvBlock[1]
	; close handles
	DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hToken)
	DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hProc)
	Return $ret
EndFunc   ;==>_GetEnvironmentBlock

Func _SetPrivilege($Privilege)
	Local $tagLUIDANDATTRIB = "int64 Luid;dword Attributes"
	Local $count = 1
	Local $tagTOKENPRIVILEGES = "dword PrivilegeCount;byte LUIDandATTRIB[" & $count * 12 & "]" ; count of LUID structs * sizeof LUID struct
	Local $TOKEN_ADJUST_PRIVILEGES = 0x20
	Local $SE_PRIVILEGE_ENABLED = 0x2

	Local $curProc = DllCall("kernel32.dll", "ptr", "GetCurrentProcess")
	Local $call = DllCall("advapi32.dll", "int", "OpenProcessToken", "ptr", $curProc[0], "dword", $TOKEN_ALL_ACCESS, "ptr*", "")
	If Not $call[0] Then Return False
	Local $hToken = $call[3]

	$call = DllCall("advapi32.dll", "int", "LookupPrivilegeValue", "str", "", "str", $Privilege, "int64*", "")
	Local $iLuid = $call[3]

	Local $TP = DllStructCreate($tagTOKENPRIVILEGES)
	Local $TPout = DllStructCreate($tagTOKENPRIVILEGES)
	Local $LUID = DllStructCreate($tagLUIDANDATTRIB, DllStructGetPtr($TP, "LUIDandATTRIB"))

	DllStructSetData($TP, "PrivilegeCount", $count)
	DllStructSetData($LUID, "Luid", $iLuid)
	DllStructSetData($LUID, "Attributes", $SE_PRIVILEGE_ENABLED)

	$call = DllCall("advapi32.dll", "int", "AdjustTokenPrivileges", "ptr", $hToken, "int", 0, "ptr", DllStructGetPtr($TP), "dword", DllStructGetSize($TPout), "ptr", DllStructGetPtr($TPout), "dword*", 0)
	$lasterror = _WinAPI_GetLastError()
	If $lasterror <> 0 Then
		ConsoleWrite("AdjustTokenPrivileges (" & $Privilege & "): " & _WinAPI_GetLastErrorMessage() & @CRLF)
		If $lasterror = 1300 Then
			$RightsAdder = _LsaAddAccountRights(@UserName, $Privilege)
			If Not @error Then
				ConsoleWrite("Reboot required for changes to take effect" & @CRLF)
			Else
				ConsoleWrite("Error: The right was probably not added correctly to your account" & @CRLF)
				Return SetError(1, 0, 0)
			EndIf
		EndIf
	EndIf
	DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hToken)
	Return ($call[0] <> 0) ; $call[0] <> 0 is success
EndFunc   ;==>_SetPrivilege

Func _LsaAddAccountRights($sName, $sRight)
	Local $hPolicy, $tSid, $pSid, $iLength, $iSysError
	Local $tUnicode, $pUnicode, $iResult, $tRight, $pRight
	$tSid = _LookupAccountName($sName)
	$pSid = DllStructGetPtr($tSid)
	If Not _IsValidSid($pSid) Then Return SetError(@error, 0, 0)
	$hPolicy = _LsaOpenPolicy(0x811)
	$iLength = StringLen($sRight) * 2
	$tRight = DllStructCreate("wchar[" & $iLength & "]")
	$pRight = DllStructGetPtr($tRight)
	DllStructSetData($tRight, 1, $sRight)
	$tUnicode = DllStructCreate("ushort Length;ushort MemSize;ptr wBuffer")
	$pUnicode = DllStructGetPtr($tUnicode)
	DllStructSetData($tUnicode, "Length", $iLength)
	DllStructSetData($tUnicode, "MemSize", $iLength + 2)
	DllStructSetData($tUnicode, "wBuffer", $pRight)
	$iResult = DllCall("advapi32.dll", "dword", "LsaAddAccountRights", _
			"hWnd", $hPolicy, "ptr", $pSid, _
			"ptr", $pUnicode, "ulong", 1)
	;	ConsoleWrite("LsaAddAccountRights Dec " & _LsaNtStatusToWinError($iResult[0]) & @CRLF)
	ConsoleWrite("LsaAddAccountRights 0x" & Hex(_LsaNtStatusToWinError($iResult[0]), 8) & @CRLF)
	$tSid = 0
	_LsaClose($hPolicy)
	$iSysError = _LsaNtStatusToWinError($iResult[0])
	Return SetError($iSysError, 0, $iSysError = 0)
EndFunc   ;==>_LsaAddAccountRights

Func _LsaOpenPolicy($iAccess)
	Local $hPolicy, $tLsaAttr, $pLsaAttr
	$tLsaAttr = DllStructCreate("ulong;hWnd;ptr;ulong;ptr[2]")
	$pLsaAttr = DllStructGetPtr($tLsaAttr)
	$hPolicy = DllCall("advapi32.dll", "ulong", "LsaOpenPolicy", _
			"ptr", 0, "ptr", $pLsaAttr, "int", $iAccess, "hWnd*", 0)
	Return SetError(_LsaNtStatusToWinError($hPolicy[0]), 0, $hPolicy[4])
EndFunc   ;==>_LsaOpenPolicy

Func _LsaClose($hPolicy)
	Local $iResult
	$iResult = DllCall("advapi32.dll", "ulong", "LsaClose", "hWnd", $hPolicy)
	Return SetError(_LsaNtStatusToWinError($iResult[0]), 0, $iResult[0] = 0)
EndFunc   ;==>_LsaClose

Func _LookupAccountName($sName, $sSystem = "")
	Local $iResult, $tSid, $pSid, $tDomain, $pDomain
	$iResult = DllCall("advapi32.dll", "int", "LookupAccountName", _
			"str", $sSystem, "str", $sName, _
			"ptr", 0, "int*", 0, "ptr", 0, "int*", 0, "int*", 0)
	If $iResult[4] = 0 Then Return SetError($ERROR_INVALID_SID, 0, 0)
	$tSid = DllStructCreate("ubyte[" & $iResult[4] & "]")
	$tDomain = DllStructCreate("ubyte[" & $iResult[6] & "]")
	$pSid = DllStructGetPtr($tSid)
	$pDomain = DllStructGetPtr($tDomain)
	$iResult = DllCall("advapi32.dll", "int", "LookupAccountName", _
			"str", $sSystem, "str", $sName, _
			"ptr", $pSid, "int*", $iResult[4], _
			"ptr", $pDomain, "int*", $iResult[6], "int*", 0)
	Return SetError(Not $iResult[0], $iResult[7], $tSid)
EndFunc   ;==>_LookupAccountName

Func _IsValidSid($pSid)
	Local $iResult
	$iResult = DllCall("advapi32.dll", "int", "IsValidSid", "ptr", $pSid)
	If $iResult[0] Then Return SetError(0, 0, True)
	Return SetError($ERROR_INVALID_SID, 0, 0)
EndFunc   ;==>_IsValidSid

Func _LsaNtStatusToWinError($iNtStatus)
	Local $iSysError
	$iSysError = DllCall("Advapi32.dll", "ulong", "LsaNtStatusToWinError", "dword", $iNtStatus)
	Return $iSysError[0]
EndFunc   ;==>_LsaNtStatusToWinError

Func NT_SUCCESS($status)
	If 0 <= $status And $status <= 0x7FFFFFFF Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>NT_SUCCESS
Func _ChangeWindowMessageFilterEx($hWnd, $iMsg, $iAction)
	Local $aCall = DllCall("user32.dll", "bool", "ChangeWindowMessageFilterEx", _
			"hwnd", $hWnd, _
			"dword", $iMsg, _
			"dword", $iAction, _
			"ptr", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_ChangeWindowMessageFilterEx
