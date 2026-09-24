;==============================================================================
; 模块：系统插件补丁
; 说明：Notepad2/HashTab/Everything/CCleaner 等插件的安装与移除
; 文件：src\features\system\Feat_Plugins.au3
; 函数：共 15 个
;==============================================================================
#include-once

;=========================================================================================
; 系统插件补丁
;=========================================================================================
Func pluginsTweaks()
	;获取选择项数量
	Local $SeletedCount
	$SeletedCount = 0
	For $i = 1 To 14
		If GUICtrlRead($plugins[$i]) = $GUI_CHECKED Then
			$SeletedCount += 1
		EndIf
	Next
	If $SeletedCount > 0 Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		;重置进度条进度
		Local $i = 0
		GUISetState(@SW_SHOW, $LoadingUI)
		Local $percent = 100 / $SeletedCount
		;1使用Notepad2替换系统自带的记事本
		If GUICtrlRead($plugins[1]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在使用Notepad2替换系统自带的记事本..'
			$percent += $percent
			If @OSArch = "X86" Then FileInstall('.\src\file\Notepad2_X86.exe', @WindowsDir & '\Notepad2.exe', 1)
			If @OSArch = "X64" Then FileInstall('.\src\file\Notepad2_X64.exe', @WindowsDir & '\Notepad2.exe', 1)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe', 'Debugger', 'REG_SZ', '"' & @WindowsDir & '\Notepad2.exe"' & ' /z')
			If RegRead('HKEY_CLASSES_ROOT\*\shell\Notepad', '') <> "" Then
				RegWrite("HKEY_CLASSES_ROOT\*\shell\Notepad", "icon", "REG_SZ", '"' & @WindowsDir & '\Notepad2.exe"')
			EndIf
			If Not FileExists(@WindowsDir & '\Notepad2.ini') Then
				Local $sNotepad2 = _
						'[Notepad2]' & @CRLF & _
						'[Settings]' & @CRLF & _
						'SaveSettings=1' & @CRLF & _
						'SaveRecentFiles=0' & @CRLF & _
						'SaveFindReplace=0' & @CRLF & _
						'CloseFind=0' & @CRLF & _
						'CloseReplace=0' & @CRLF & _
						'NoFindWrap=0' & @CRLF & _
						'OpenWithDir=%USERPROFILE%\Desktop' & @CRLF & _
						'Favorites=%CSIDL:MYDOCUMENTS%' & @CRLF & _
						'PathNameFormat=1' & @CRLF & _
						'WordWrap=1' & @CRLF & _
						'WordWrapMode=0' & @CRLF & _
						'WordWrapIndent=0' & @CRLF & _
						'WordWrapSymbols=22' & @CRLF & _
						'ShowWordWrapSymbols=0' & @CRLF & _
						'MatchBraces=1' & @CRLF & _
						'AutoCloseTags=0' & @CRLF & _
						'HighlightCurrentLine=0' & @CRLF & _
						'AutoIndent=1' & @CRLF & _
						'AutoCompleteWords=0' & @CRLF & _
						'ShowIndentGuides=1' & @CRLF & _
						'TabsAsSpaces=0' & @CRLF & _
						'TabIndents=1' & @CRLF & _
						'BackspaceUnindents=0' & @CRLF & _
						'TabWidth=4' & @CRLF & _
						'IndentWidth=0' & @CRLF & _
						'MarkLongLines=1' & @CRLF & _
						'LongLinesLimit=100' & @CRLF & _
						'LongLineMode=1' & @CRLF & _
						'ShowSelectionMargin=0' & @CRLF & _
						'ShowLineNumbers=1' & @CRLF & _
						'ShowCodeFolding=1' & @CRLF & _
						'MarkOccurrences=3' & @CRLF & _
						'MarkOccurrencesMatchCase=0' & @CRLF & _
						'MarkOccurrencesMatchWholeWords=1' & @CRLF & _
						'ViewWhiteSpace=0' & @CRLF & _
						'ViewEOLs=0' & @CRLF & _
						'DefaultEncoding=0' & @CRLF & _
						'SkipUnicodeDetection=0' & @CRLF & _
						'LoadASCIIasUTF8=0' & @CRLF & _
						'LoadNFOasOEM=1' & @CRLF & _
						'NoEncodingTags=0' & @CRLF & _
						'DefaultEOLMode=0' & @CRLF & _
						'FixLineEndings=0' & @CRLF & _
						'FixTrailingBlanks=0' & @CRLF & _
						'PrintHeader=1' & @CRLF & _
						'PrintFooter=0' & @CRLF & _
						'PrintColorMode=3' & @CRLF & _
						'PrintZoom=10' & @CRLF & _
						'PrintMarginLeft=2000' & @CRLF & _
						'PrintMarginTop=2000' & @CRLF & _
						'PrintMarginRight=2000' & @CRLF & _
						'PrintMarginBottom=2000' & @CRLF & _
						'SaveBeforeRunningTools=0' & @CRLF & _
						'FileWatchingMode=0' & @CRLF & _
						'ResetFileWatching=1' & @CRLF & _
						'EscFunction=0' & @CRLF & _
						'AlwaysOnTop=0' & @CRLF & _
						'MinimizeToTray=0' & @CRLF & _
						'TransparentMode=0' & @CRLF & _
						'ToolbarButtons=1 2 4 0 5 6 0 7 8 9 0 10 11 0 12 0 24 0 13 14 0 15 0 17' & @CRLF & _
						'ShowToolbar=1' & @CRLF & _
						'ShowStatusbar=1' & @CRLF & _
						'EncodingDlgSizeX=256' & @CRLF & _
						'EncodingDlgSizeY=262' & @CRLF & _
						'RecodeDlgSizeX=256' & @CRLF & _
						'RecodeDlgSizeY=262' & @CRLF & _
						'FileMRUDlgSizeX=412' & @CRLF & _
						'FileMRUDlgSizeY=376' & @CRLF & _
						'OpenWithDlgSizeX=384' & @CRLF & _
						'OpenWithDlgSizeY=386' & @CRLF & _
						'FavoritesDlgSizeX=334' & @CRLF & _
						'FavoritesDlgSizeY=316' & @CRLF & _
						'FindReplaceDlgPosX=0' & @CRLF & _
						'FindReplaceDlgPosY=0' & @CRLF & _
						'[Settings2]' & @CRLF & _
						'SingleFileInstance=1' & @CRLF & _
						'ShellAppUserModelID=Notepad2' & @CRLF & _
						'ShellUseSystemMRU=1' & @CRLF & _
						'[Recent Files]' & @CRLF & _
						'[Recent Find]' & @CRLF & _
						'[Recent Replace]' & @CRLF & _
						'[Window]' & @CRLF & _
						'1400x1050 PosX=396' & @CRLF & _
						'1400x1050 PosY=16' & @CRLF & _
						'1400x1050 SizeX=988' & @CRLF & _
						'1400x1050 SizeY=988' & @CRLF & _
						'1400x1050 Maximized=0' & @CRLF & _
						'[Custom Colors]' & @CRLF & _
						'01=#000000' & @CRLF & _
						'02=#0A246A' & @CRLF & _
						'03=#3A6EA5' & @CRLF & _
						'04=#003CE6' & @CRLF & _
						'05=#006633' & @CRLF & _
						'06=#608020' & @CRLF & _
						'07=#648000' & @CRLF & _
						'08=#A46000' & @CRLF & _
						'09=#FFFFFF' & @CRLF & _
						'10=#FFFFE2' & @CRLF & _
						'11=#FFF1A8' & @CRLF & _
						'12=#FFC000' & @CRLF & _
						'13=#FF4000' & @CRLF & _
						'14=#C80000' & @CRLF & _
						'15=#B000B0' & @CRLF & _
						'16=#B28B40' & @CRLF & _
						'[Styles]' & @CRLF & _
						'Use2ndDefaultStyle=0' & @CRLF & _
						'DefaultScheme=0' & @CRLF & _
						'AutoSelect=1' & @CRLF & _
						'SelectDlgSizeX=304' & @CRLF & _
						'SelectDlgSizeY=324' & @CRLF & _
						''
				$Fh = FileOpen(@WindowsDir & '\Notepad2.ini', 1 + 8)
				FileWrite($sNotepad2, $Fh)
				FileClose($Fh)
			EndIf
		EndIf
		;2在资源管理器中使用HashTab
		If GUICtrlRead($plugins[2]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在在资源管理器中安装HashTab插件..'
			$percent += $percent
			Local $bResult
			;清除之前的版本（若存在）
			If @OSArch = "X86" Then
				DllUnInstall(@WindowsDir & '\system32\HashTab32.dll')
				FileDelete(@WindowsDir & '\system32\HashTab32.dll')
			ElseIf @OSArch = "X64" Then
				DllUnInstall(@WindowsDir & '\SysWOW64\HashTab64.dll')
				FileDelete(@WindowsDir & '\SysWOW64\HashTab64.dll')
			Else
			EndIf
			;开始安装
			If @OSArch = "X86" Then
				FileInstall('.\src\file\HashTab32.dll', @WindowsDir & '\system32\', 1)
				$bResult = DllInstall(@WindowsDir & '\system32\HashTab32.dll')
			ElseIf @OSArch = "X64" Then
				FileInstall('.\src\file\HashTab64.dll', @WindowsDir & '\SysWOW64\', 1)
				$bResult = DllInstall(@WindowsDir & '\SysWOW64\HashTab64.dll')
			Else
			EndIf
			If $bResult Then
				;写入注册表配置项
				RegWrite('HKEY_CURRENT_USER\Software\HashTab\Algorithms\CRC32', 'Enabled', 'REG_DWORD', '00000001')
				RegWrite('HKEY_CURRENT_USER\Software\HashTab\Algorithms\MD5', 'Enabled', 'REG_DWORD', '00000001')
				RegWrite('HKEY_CURRENT_USER\Software\HashTab\Algorithms\SHA-1', 'Enabled', 'REG_DWORD', '00000001')
				RegWrite('HKEY_CURRENT_USER\Software\HashTab\Settings', 'UseLowercase', 'REG_DWORD', '00000000')
			EndIf
		EndIf
		;3破解系统主题
		If GUICtrlRead($plugins[3]) = $GUI_CHECKED Then
			If @OSBuild > 8000 Then
				_OsWin8_pluginsTweaks_01()
			Else
				_OsVista7_pluginsTweaks_02()
			EndIf
		EndIf
		;4安装摄像头工具
		;4 破解系统链接数
		If GUICtrlRead($plugins[4]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild < 6000 Then
				_OsXp_pluginsTweaks_03()
			Else
				_OsCommon_pluginsTweaks_04()
			EndIf
		EndIf
		;5Windows2008游戏补丁
		If GUICtrlRead($plugins[5]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild > 8000 Then
				_OsWin8_pluginsTweaks_07()
			Else
				_OsVista7_pluginsTweaks_12()
			EndIf
		EndIf
		;6DirectMusic补丁
		If GUICtrlRead($plugins[6]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild < 6000 Then
				_OsXp_pluginsTweaks_13()
			Else
				_OsCommon_pluginsTweaks_16()
			EndIf
		EndIf
		;7everything
		If GUICtrlRead($plugins[7]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Everything搜索工具..'
			$percent += $percent
			FileInstall('.\src\file\everything.exe', @TempDir & '\', 1)
			RunWait(@TempDir & '\everything.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			FileMove(@HomeDrive & '\Program Files\Everything\Everything' & @OSArch & '.exe', @HomeDrive & '\Program Files\Everything\Everything.exe', 1)
			RegWrite('HKEY_CLASSES_ROOT\Folder\shell\搜索Everything...\command', '', 'REG_SZ', '"' & @HomeDrive & '\Program Files\Everything\Everything.exe" -admin -path "%1"')
			RegWrite('HKEY_CLASSES_ROOT\Folder\shell\搜索Everything...', 'icon', 'REG_SZ', '"' & @HomeDrive & '\Program Files\Everything\Everything.exe"')
			Switch @OSArch
				Case 'X86'
					FileDelete(@HomeDrive & '\Program Files\Everything\EverythingX64.exe')
				Case 'X64'
					FileDelete(@HomeDrive & '\Program Files\Everything\EverythingX86.exe')
			EndSwitch
			FileDelete(@TempDir & '\everything.exe')
		EndIf
		;8CBX Shell压缩包缩略图插件
		If GUICtrlRead($plugins[8]) = $GUI_CHECKED Then
			$i += 1
			Local $t, $Guid
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装CBX Shell压缩包缩略图插件..'
			$percent += $percent
			FileInstall('.\src\file\CBXShell.exe', @TempDir & '\', 1)
			RunWait(@TempDir & '\CBXShell.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			RunWait('regsvr32.exe /s  "' & @HomeDrive & '\Program Files\CBXShell\CBXShell.dll"', '', @SW_HIDE)
			RunWait('regsvr32.exe /s  "' & @HomeDrive & '\Program Files\CBXShell\unrar64.dll"', '', @SW_HIDE)
			For $t = 1 To 100
				$Guid = RegEnumKey('HKEY_USERS', $t)
				If StringLen($Guid) = 45 Then
					ExitLoop
				EndIf
			Next
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbr\shellex')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbr\shellex\{00021500-0000-0000-C000-000000000046}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbr\shellex\{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbz\shellex')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbz\shellex\{00021500-0000-0000-C000-000000000046}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.cbz\shellex\{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.RAR\shellex\{00021500-0000-0000-C000-000000000046}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.RAR\shellex\{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.ZIP\shellex\{00021500-0000-0000-C000-000000000046}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\Classes\.ZIP\shellex\{BB2E617C-0920-11d1-9A0B-00C04FC2D6C1}', '', 'REG_SZ', '{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}')
			RegWrite('HKEY_USERS\' & $Guid & '\Software\T800 Productions\{9E6ECB90-5A61-42BD-B851-D3297D9C7F39}', 'NoSort', 'REG_DWORD', '00000000')
			FileDelete(@TempDir & '\CBXShell.exe')
		EndIf
		;9去除桌面水印通用补丁
		If GUICtrlRead($plugins[9]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild < 6000 Then
				_OsXp_pluginsTweaks_17()
			Else
				_OsCommon_pluginsTweaks_20()
			EndIf
			$percent += $percent
		EndIf
		;10reg2inf右键菜单
		If GUICtrlRead($plugins[10]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Reg2Inf右键菜单..'
			$percent += $percent
			If Not FileExists(@WindowsDir & '\reg2inf.exe') Then FileInstall('.\src\file\reg2inf.exe', @WindowsDir & '\', 1)
			RegWrite('HKEY_CLASSES_ROOT\regfile\shell\convert', '', 'REG_SZ', '转换为inf文件')
			RegWrite('HKEY_CLASSES_ROOT\regfile\shell\convert\command', '', 'REG_SZ', 'reg2inf.exe -w -t "%1"')
		EndIf
		;11ccleaner
		If GUICtrlRead($plugins[11]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装ccleaner..'
			$percent += $percent
			FileInstall('.\src\file\CCleaner.exe', @TempDir & '\', 1)
			RunWait(@TempDir & '\CCleaner.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			Switch @OSArch
				Case 'X86'
					FileDelete(@HomeDrive & '\Program Files\CCleaner\CCleaner64.exe')
					RegWrite('HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\打开 CCleaner...\command', '', 'REG_SZ', '"' & @HomeDrive & '\Program Files\CCleaner\CCleaner.exe"')
					RegWrite('HKEY_CLASSES_ROOT\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\打开 CCleaner...', 'icon', 'REG_SZ', '"' & @HomeDrive & '\Program Files\CCleaner\CCleaner.exe"')
				Case 'X64'
					FileDelete(@HomeDrive & '\Program Files\CCleaner\CCleaner.exe')
					RegWrite('HKEY_CLASSES_ROOT64\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\打开 CCleaner...\command', '', 'REG_SZ', '"' & @HomeDrive & '\Program Files\CCleaner\CCleaner64.exe"')
					RegWrite('HKEY_CLASSES_ROOT64\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\打开 CCleaner...', 'icon', 'REG_SZ', '"' & @HomeDrive & '\Program Files\CCleaner\CCleaner64.exe"')
			EndSwitch
			FileDelete(@TempDir & '\CCleaner.exe')
		EndIf
		;12VHD右键菜单
		If GUICtrlRead($plugins[12]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在VHD右键菜单..'
			$percent += $percent
			Local $sVbs = _
					'			Dim Args' & @CRLF & _
					'Set Args = WScript.Arguments' & @CRLF & _
					'TranArgs = " "' & @CRLF & _
					'For i = 0 To Args.Count - 1' & @CRLF & _
					'	TranArgs = TranArgs & """" & Args(i) & """" & " " ' & @CRLF & _
					'Next' & @CRLF & _
					'If Args(0) <> "-hFlag" Then ' & @CRLF & _
					'	If Args(0) <> "-hWind" Then ' & @CRLF & _
					'		CreateObject("Shell.Application").ShellExecute "wscript.exe", _' & @CRLF & _
					'			"""" & WScript.ScriptFullName & """" & " -hWind" & TranArgs, "", "runas", 1' & @CRLF & _
					'		WScript.Quit(5)' & @CRLF & _
					'	Else' & @CRLF & _
					'		CreateObject("Wscript.Shell").Run "cscript.exe " & _' & @CRLF & _
					'			"""" & Wscript.ScriptFullName & """" & Replace(TranArgs, "-hWind", "-hFlag"), 0, TRUE' & @CRLF & _
					'		WScript.Quit(1)' & @CRLF & _
					'	End If' & @CRLF & _
					'Else' & @CRLF & _
					'	''Add Your Codes' & @CRLF & _
					'	Dim objShell, objExec' & @CRLF & _
					'	Set objShell = WScript.CreateObject("Wscript.Shell")' & @CRLF & _
					'	Set objExec = objShell.Exec("c:\windows\system32\diskpart.exe")' & @CRLF & _
					'		' & @CRLF & _
					'	objExec.StdIn.WriteLine "select vdisk file=""" & WScript.Arguments(2) & """"' & @CRLF & _
					'	Select Case Args(1)' & @CRLF & _
					'		Case "/M"' & @CRLF & _
					'			objExec.StdIn.WriteLine "attach vdisk"' & @CRLF & _
					'			objExec.StdIn.WriteLine "exit"' & @CRLF & _
					'			WScript.Quit(0)' & @CRLF & _
					'			' & @CRLF & _
					'		Case "/D"' & @CRLF & _
					'			objExec.StdIn.WriteLine "detach vdisk"' & @CRLF & _
					'			objExec.StdIn.WriteLine "exit"' & @CRLF & _
					'			WScript.Quit(0)' & @CRLF & _
					'			' & @CRLF & _
					'		Case Else' & @CRLF & _
					'			''other' & @CRLF & _
					'			WScript.Quit(0)' & @CRLF & _
					'	End Select' & @CRLF & _
					'	' & @CRLF & _
					'	WScript.Quit(0)' & @CRLF & _
					'End If'
			Local $Fh = FileOpen(@WindowsDir & '\System32\vdm.vbs', 2 + 8)
			FileWrite($Fh, $sVbs)
			FileClose($Fh)
			RegWrite('HKEY_CLASSES_ROOT\.vhd', '', 'REG_SZ', 'Virtual.Machine.HD')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Virtual.Machine.HD\Shell\Dismount', '', 'REG_SZ', '分离 VHD(&D)')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Virtual.Machine.HD\Shell\Dismount\command', '', 'REG_SZ', '"C:\windows\system32\wscript.exe" C:\Windows\System32\vdm.vbs /D "%1"')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Virtual.Machine.HD\Shell\Mount', '', 'REG_SZ', '挂载 VHD(&M)')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Virtual.Machine.HD\Shell\Mount\command', '', 'REG_SZ', '"C:\windows\system32\wscript.exe" C:\Windows\System32\vdm.vbs /M "%1"')
		EndIf
		;13 Unlocker
		If GUICtrlRead($plugins[13]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Unlocker文件强制删除工具..'
			$percent += $percent
			If @OSArch = "X86" Then
				FileInstall('.\src\file\UnlockerX86.exe', @TempDir & '\', 1)
				RunWait(@TempDir & '\UnlockerX86.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			ElseIf @OSArch = "X64" Then
				FileInstall('.\src\file\UnlockerX64.exe', @TempDir & '\', 1)
				RunWait(@TempDir & '\UnlockerX64.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			Else
			EndIf
			RunWait('"' & @HomeDrive & '\Program Files\Unlocker\Ins.cmd"', @WindowsDir, @SW_HIDE)
			FileDelete(@TempDir & '\Unlocker*.exe')
		EndIf
		;14 xbox及显示/隐藏系统文件+扩展名
		If GUICtrlRead($plugins[14]) = $GUI_CHECKED Then
			$i += 1
			If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
				_OsServer_pluginsTweaks_21()
			Else
				_OsCommon_pluginsTweaks_22()
			EndIf
			$percent += $percent
		EndIf
		_GUIDisable($Form1, 0)
		_EnableTrayMenu()
		GUISetState(@SW_HIDE, $LoadingUI)
		$aText = '正在处理，请稍后'
		MsgBox(0, '提示', '您选择的补丁或插件已经安装完毕!', 5)
	Else
		MsgBox(16, '提示', '请选择要进行安装的补丁或插件!', 5)
	EndIf
EndFunc   ;==>pluginsTweaks
;移除插件部分
Func RemoveNotePad2()
	FileDelete(@WindowsDir & '\Notepad2.exe')
	FileDelete(@WindowsDir & '\Notepad2.ini')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe')
	RegDelete("HKEY_CLASSES_ROOT\*\shell\Notepad", "icon")
	MsgBox(0, '提示', '已经移除Notepad2！', 5)
EndFunc   ;==>RemoveNotePad2

Func RemoveHashTab()
	Local $bResult
	If @OSArch = "X86" Then
		$bResult = DllUnInstall(@WindowsDir & '\system32\HashTab32.dll')
		FileDelete(@WindowsDir & '\system32\HashTab32.dll')
	ElseIf @OSArch = "X64" Then
		$bResult = DllUnInstall(@WindowsDir & '\SysWOW64\HashTab64.dll')
		FileDelete(@WindowsDir & '\SysWOW64\HashTab64.dll')
	Else
	EndIf
	If $bResult Then
		RegDelete('HKEY_CURRENT_USER\Software\HashTab')
		MsgBox(0, '提示', '已经移除HashTab！', 5)
	Else
		MsgBox(16, '提示', '移除HashTab时发生错误：' & @error, 5)
	EndIf
EndFunc   ;==>RemoveHashTab
Func Removeupdatedisabler()
	;先禁用移除服务，再删除目录
	RunWait(@ProgramFilesDir & '\UpdaterDisabler\UpdaterDisabler.exe -remove', @ProgramFilesDir & '\UpdaterDisabler\', @SW_HIDE)
	FileDelete(@ProgramFilesDir & '\UpdaterDisabler\UpdaterDisabler.exe')
	DirRemove(@ProgramFilesDir & '\UpdaterDisabler', 1)
	MsgBox(0, '提示', '已经移除系统更新禁用插件)！', 5)
EndFunc   ;==>Removeupdatedisabler
Func RemoveCamera()
	FileDelete(@WindowsDir & '\Ecap.exe')
	FileDelete(@UserProfileDir & '\Appdata\Roaming\Microsoft\Windows\Network shortcuts\视频设备')
	MsgBox(0, '提示', '已经移除摄像头工具！', 5)
EndFunc   ;==>RemoveCamera

Func RemoveEverything()
	If ProcessExists("Everything.exe") Then Run(@ComSpec & ' /c taskkill /im "Everything.exe" /f', @WindowsDir, @SW_HIDE)
	DirRemove(@HomeDrive & '\Program Files\Everything', 1)
	RegDelete('HKEY_CLASSES_ROOT\Folder\shell\搜索Everything...')
	MsgBox(0, '提示', '已经移除Everything！', 5)
EndFunc   ;==>RemoveEverything

Func RemoveCBX()
	RunWait('regsvr32.exe /u  "' & @HomeDrive & '\Program Files\CBXShell\CBXShell.dll"', '', @SW_HIDE)
	RunWait('regsvr32.exe /u  "' & @HomeDrive & '\Program Files\CBXShell\unrar64.dll"', '', @SW_HIDE)
	DirRemove(@HomeDrive & '\Program Files\CBXShell', 1)
	MsgBox(0, '提示', '已经移除CBX Shell插件！', 5)
EndFunc   ;==>RemoveCBX

Func RemoveReg2inf()
	FileDelete(@WindowsDir & '\reg2inf.exe')
	RegDelete('HKEY_CLASSES_ROOT\regfile\shell\convert')
	MsgBox(0, '提示', '已经移除reg2inf右键工具！', 5)
EndFunc   ;==>RemoveReg2inf

Func RemoveCC()
	DirRemove(@HomeDrive & '\Program Files\CCleaner', 1)
	RegDelete('HKEY_CLASSES_ROOT64\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\打开 CCleaner...')
	MsgBox(0, '提示', '已经移除CCleaner！', 5)
EndFunc   ;==>RemoveCC
Func RemoveUnlocker()
	If ProcessExists('Unlocker.exe') Then Run(@ComSpec & ' /c taskkill /im "Unlocker.exe" /f', @WindowsDir, @SW_HIDE)
	RunWait('"' & @HomeDrive & '\Program Files\Unlocker\UnIns.cmd"', @WindowsDir, @SW_HIDE)
	Local $iRemove = DirRemove(@HomeDrive & '\Program Files\Unlocker', 1)
	If Not $iRemove = 1 Then
		If ProcessExists('explorer.exe') Then Run(@ComSpec & ' /c taskkill /im "explorer.exe" /f', @WindowsDir, @SW_HIDE)
		DirRemove(@HomeDrive & '\Program Files\Unlocker', 1)
		If Not ProcessExists('explorer.exe') Then ShellExecute(@WindowsDir & '\explorer.exe')
	EndIf
	MsgBox(0, '提示', '已经移除Unlocker！', 5)
EndFunc   ;==>RemoveUnlocker
Func RemoveSuperHide()
	RegDelete('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\SuperHidden')
	RegDelete('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\InProcServer32', '')
	RegDelete('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\InProcServer32', 'ThreadingModel')
	RegDelete('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance')
	RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced')
	FileDelete(@WindowsDir & '\UninstallSuperHidden.reg')
	FileDelete(@WindowsDir & '\SuperHidden.vbs')
	MsgBox(0, '提示', '已经移除显示\隐藏系统文件+扩展名右键菜单！！', 5)
EndFunc   ;==>RemoveSuperHide

Func RemoveVHD()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Virtual.Machine.HD')
	FileDelete(@WindowsDir & '\System32\vdm.vbs')
	MsgBox(0, '提示', '已经移除VHD相关菜单项目！！', 5)
EndFunc   ;==>RemoveVHD
Func RemoveW8Quick()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services')
	RegDelete('HKEY_CLASSES_ROOT\*\shell\OtaQuickMenu')
	RegDelete('HKEY_CLASSES_ROOT\LibraryFolder\background\shell\OtaQuickMenu')
	RegDelete('KEY_CLASSES_ROOT\Directory\shell\OtaQuickMenu')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\background\shell\OtaQuickMenu')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\OtaQuickMenu')
	MsgBox(0, '提示', '已经移除Windows8右键快捷菜单', 5)
EndFunc   ;==>RemoveW8Quick
Func _ClearAllScope()
	Local $Regkey = 'HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchScopes'
	RegDelete($Regkey)
	MsgBox(0, '', '已经移除所有浏览器搜索引擎！', 5)
EndFunc   ;==>_ClearAllScope
Func RemoveIESearch()
	If @OSBuild > 8000 Then
	Else
		If @OSVersion = 'WIN_XP' Then
		Else
			If @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008" Then
			Else
				Local $Regkey = 'HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchScopes'
				For $sGUID In $aGUID
					RegDelete($Regkey & '\' & $sGUID)
				Next
				MsgBox(0, '', '已经移除搜索引擎增强包！', 5)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>RemoveIESearch
