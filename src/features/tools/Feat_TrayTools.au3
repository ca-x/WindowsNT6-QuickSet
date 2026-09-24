;==============================================================================
; 模块：托盘小工具
; 说明：一键集成/卸载的独立小工具（UPX、KClock、JunctionMaster、虚拟光驱、图标缓存等）
; 文件：src\features\tools\Feat_TrayTools.au3
; 函数：共 9 个
;==============================================================================
#include-once

;小众人群插件
Func Convert2bmp()
	If RegRead('HKEY_CLASSES_ROOT\*\shell\转为Alpha通道bmp\command', '') = '' Then
		If @OSArch = "X86" Then
			FileInstall('.\src\file\img2bmp32.exe', @WindowsDir & '\img2bmp.exe', 1)
		ElseIf @OSArch = "X64" Then
			FileInstall('.\src\file\img2bmp64.exe', @WindowsDir & '\img2bmp.exe', 1)
		Else
		EndIf
		RegWrite("HKEY_CLASSES_ROOT\*\shell\转为Alpha通道bmp\command", "", "REG_SZ", @WindowsDir & '\img2bmp.exe "%1"')
		MsgBox(0, '提示', '"转为Alpha通道bmp"右键菜单添加成功！')
	Else
		RegDelete('HKEY_CLASSES_ROOT\*\shell\转为Alpha通道bmp')
		MsgBox(0, '提示', '"转为Alpha通道bmp"右键菜单卸载成功！')
	EndIf
EndFunc   ;==>Convert2bmp

Func UPX()
	Local $Path = @WindowsDir
	If RegRead('HKEY_CLASSES_ROOT\dllfile\shell\UPXMenu', 'MUIVerb') = '' Then
		FileInstall('.\src\file\upx.exe', $Path & '\upx.exe', 1)
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ExPandUpx', '', 'REG_SZ', '使用UPX解压')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ExPandUpx\command', '', 'REG_SZ', $Path & '\upx.exe -d -k "%1"')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\BestUPX', '', 'REG_SZ', '使用UPX压缩[最好]')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\BestUPX\command', '', 'REG_SZ', $Path & '\upx.exe -9 -k "%1"')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\FastUPX', '', 'REG_SZ', '使用UPX压缩[最快]')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\FastUPX\command', '', 'REG_SZ', $Path & '\upx.exe -1 -k "%1"')
		RegWrite('HKEY_CLASSES_ROOT\exefile\shell\UPXMenu', 'MUIVerb', 'REG_SZ', 'UPX工具')
		RegWrite('HKEY_CLASSES_ROOT\exefile\shell\UPXMenu', 'SubCommands', 'REG_SZ', 'ExPandUpx;BestUPX;FastUPX')
		RegWrite('HKEY_CLASSES_ROOT\dllfile\shell\UPXMenu', 'MUIVerb', 'REG_SZ', 'UPX工具')
		RegWrite('HKEY_CLASSES_ROOT\dllfile\shell\UPXMenu', 'SubCommands', 'REG_SZ', 'ExPandUpx;BestUPX;FastUPX')
		RegWrite('HKEY_CLASSES_ROOT\ocxfile\shell\UPXMenu', 'MUIVerb', 'REG_SZ', 'UPX工具')
		RegWrite('HKEY_CLASSES_ROOT\ocxfile\shell\UPXMenu', 'SubCommands', 'REG_SZ', 'ExPandUpx;BestUPX;FastUPX')
		MsgBox(0, '提示', '"UPX工具"右键菜单添加成功！')
	Else
		If ProcessExists('upx.exe') Then Run(@ComSpec & ' /c ntsd -c q -pn upx.exe', '', @SW_HIDE)
		FileDelete($Path & '\upx.exe')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\ExPandUpx')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\BestUPX')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\FastUPX')
		RegDelete('HKEY_CLASSES_ROOT\exefile\shell\UPXMenu')
		RegDelete('HKEY_CLASSES_ROOT\dllfile\shell\UPXMenu')
		RegDelete('HKEY_CLASSES_ROOT\ocxfile\shell\UPXMenu')
		MsgBox(0, '提示', '"UPX工具"右键菜单卸载成功！')
	EndIf
EndFunc   ;==>UPX
Func RemoveUsb()
	If RegRead("HKEY_CLASSES_ROOT\Drive\shell\安全移除该设备\command", '') = '' Then
		If @OSArch = 'X64' Then
			FileInstall('.\src\file\RemoveDriveX64.exe', @WindowsDir & '\RemoveDrive.exe', 1)
		Else
			FileInstall('.\src\file\RemoveDriveX86.exe', @WindowsDir & '\RemoveDrive.exe', 1)
		EndIf
		RegWrite("HKEY_CLASSES_ROOT\Drive\shell\安全移除该设备\command", "", "REG_SZ", 'cmd.exe /c color 27 && echo ☆★开始安全移除移动设备操作★☆ && RemoveDrive.exe %1 -l -b -e &&echo 设备已经安全移除！&&ping -n 2 127.0.0.1>nul  ')
		MsgBox(0, '提示', '"安全移除该设备"右键菜单添加成功！')
	Else
		If ProcessExists('RemoveDrive.exe') Then Run(@ComSpec & ' /c ntsd -c q -pn RemoveDrive.exe', '', @SW_HIDE)
		FileDelete(@WindowsDir & '\RemoveDrive.exe')
		RegDelete("HKEY_CLASSES_ROOT\Drive\shell\安全移除该设备")
		MsgBox(0, '提示', '"安全移除该设备"右键菜单卸载成功！')
	EndIf
EndFunc   ;==>RemoveUsb
Func UWD()
	FileInstall('.\src\file\uwd.exe', @TempDir & '\uwd.exe')
	Run(@TempDir & '\uwd.exe')
EndFunc   ;==>UWD
;; KClock
Func KClock()
	If RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'KClock') = '' Then
		If @OSArch = 'X86' Then
			FileInstall('.\src\file\KClockx86.exe', @WindowsDir & '\KClock.exe', 1)
		ElseIf @OSArch = 'X64' Then
			FileInstall('.\src\file\KClockx64.exe', @WindowsDir & '\KClock.exe', 1)
		Else
			MsgBox(0, '', '本插件不支持当前系统平台', 5)
		EndIf
		Run(@WindowsDir & '\KClock.exe')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'KClock', 'REG_SZ', @WindowsDir & '\KClock.exe')
		MsgBox(0, '提示', '安装KClock任务栏时钟增强插件成功！')
	Else
		If ProcessExists('KClock.exe') Then Run(@ComSpec & ' /c ntsd -c q -pn KClock.exe', '', @SW_HIDE)
		FileDelete(@WindowsDir & '\KClock.exe')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'KClock')
		MsgBox(0, '提示', '卸载KClock任务栏时钟增强插件成功！')
	EndIf
EndFunc   ;==>KClock

Func JunctionMaster()
	If RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\JunctionMaster\Command', '') = '' Then
		If @OSArch = 'X86' Then
			FileInstall('.\src\file\JunctionMasterX86.exe', @WindowsDir & '\JunctionMaster.exe', 1)
		ElseIf @OSArch = 'X64' Then
			FileInstall('.\src\file\JunctionMasterX64.exe', @WindowsDir & '\JunctionMaster.exe', 1)
		Else
			MsgBox(0, '', '本插件不支持当前系统平台', 5)
		EndIf
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\JunctionMaster', '', 'REG_SZ', '移动并链接文件夹到...')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\JunctionMaster\Command', '', 'REG_SZ', @WindowsDir & '\JunctionMaster.exe "%1" /create')
		RegWrite('HKEY_CURRENT_USER\Software\MoveAndLink\JunctionMaster.exe\XMessageBox', 'jqAqrHCPR13b7vh22273687', 'REG_DWORD', '0x00000004')
		RegWrite('HKEY_USERS\' & $UserSid & '\Software\MoveAndLink\JunctionMaster.exe\XMessageBox', 'jqAqrHCPR13b7vh22273687', 'REG_DWORD', '0x01000006')
		MsgBox(0, '提示', '安装JunctionMaster右键增强插件成功！')
	Else
		If ProcessExists('JunctionMaster.exe') Then Run(@ComSpec & ' /c ntsd -c q -pn JunctionMaster.exe', '', @SW_HIDE)
		FileDelete(@WindowsDir & '\JunctionMaster.exe')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\JunctionMaster')
		RegDelete('HKEY_CURRENT_USER\Software\MoveAndLink')
		RegDelete('HKEY_USERS\' & $UserSid & '\Software\MoveAndLink')
		MsgBox(0, '提示', '卸载JunctionMaster右键增强插件成功！')
	EndIf

EndFunc   ;==>JunctionMaster

Func VirtualDrive()
	FileInstall('src\file\virtualdrivemaster.sfx.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\virtualdrivemaster.sfx.exe', @TempDir, @SW_HIDE)
	Local $File = ''
	If @OSArch = 'x64' Then
		$File = @ProgramFilesDir & ' (x86)\虚拟光驱\virtualdrivemaster.exe'
	Else
		$File = @ProgramFilesDir & '\虚拟光驱\virtualdrivemaster.exe'
	EndIf
	If FileExists($File) Then
		If ProcessExists('virtualdrivemaster.exe') Then Run(@ComSpec & ' /c taskkill /im virtualdrivemaster.exe /f', @WindowsDir, @SW_HIDE)
		Run($File)
		Sleep(500)
		WinWait('[CLASS:_TweakCube_VD]', '')
		WinActivate('[CLASS:_TweakCube_VD]', '')
		WinWaitActive('[CLASS:_TweakCube_VD]', '')
		ControlClick('[CLASS:_TweakCube_VD]', '', '[CLASS:Button; INSTANCE:5]')
		ControlClick('[CLASS:_TweakCube_VD]', '', '[CLASS:Button; INSTANCE:14]')
		ControlClick('[CLASS:_TweakCube_VD]', '', '[CLASS:Button; INSTANCE:6]')
		WinClose('[CLASS:_TweakCube_VD]')
		MsgBox(0, '提示', '已经成功执行了安装/卸载操作！', 5)
	Else
		MsgBox(16, '错误', '在执行安装时出现未知错误！', 10)
	EndIf

EndFunc   ;==>VirtualDrive
Func ClipExt()
	If FileExists(@WindowsDir & '\system32\FileGetPath.vbs') Then
		RegDelete('HKEY_CLASSES_ROOT\*\shell\复制文件路径(&B)')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\复制文件夹路径(&B)')
		RegDelete('HKEY_CLASSES_ROOT\Folder\shell\复制文件夹路径(&B)')
		FileDelete(@WindowsDir & '\system32\FileGetPath.vbs')
		MsgBox(0, '提示', '卸载复制文件路径右键菜单成功！', 5)
	Else
		Local $Vbsdata = 'Dim WshShell' & @CRLF & _
				'set WshShell = CreateObject("wscript.Shell")' & @CRLF & _
				'WshShell.Run "cmd.exe /c echo " & WScript.Arguments(0) & " | clip",0,False' & @CRLF & _
				'WSHShell.Popup "已经将路径复制到剪切板~~", 5, "基于Clip.exe的右键菜单程序提示", vbInformation' & @CRLF & _
				'set WshShell=Nothing' & @CRLF & _
				'WScript.Quit(0)'
		Local $Fh = FileOpen(@WindowsDir & '\system32\FileGetPath.vbs', 2 + 8)
		FileWrite($Fh, $Vbsdata)
		FileClose($Fh)
		RegWrite('HKEY_CLASSES_ROOT\*\shell\复制文件路径(&B)\command', '', 'REG_SZ', 'WScript.exe //nologo ' & @WindowsDir & '\system32\FileGetPath.vbs "%1"')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\复制文件夹路径(&B)\Command', '', 'REG_SZ', 'WScript.exe //nologo ' & @WindowsDir & '\system32\FileGetPath.vbs "%1"')
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\复制文件夹路径(&B)\command', '', 'REG_SZ', 'WScript.exe //nologo ' & @WindowsDir & '\system32\FileGetPath.vbs "%1"')
		MsgBox(0, '提示', '安装复制文件路径右键菜单成功！', 5)
	EndIf
EndFunc   ;==>ClipExt
Func ReBuildIconache()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在清理系统图标缓存，请稍后..'
	If @OSBuild < 8000 Then
		Run(@ComSpec & ' /c taskkill /im explorer.exe /f', "", @SW_HIDE)
		FileDelete(@UserProfileDir & "\appdata\local\iconcache.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_32.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_96.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_256.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_1024.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_idx.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\thumbcache_sr.db")
		FileDelete(@UserProfileDir & "\AppData\Local\Microsoft\Windows\Explorer\*.db")
		RunWait("mcbuilder.exe", @WindowsDir, @SW_HIDE)
		Run(@WindowsDir & "\explorer.exe")
	EndIf
	RunWait('ie4uinit.exe -ClearIconCache', @WindowsDir, @SW_HIDE)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	GUISetState(@SW_HIDE, $LoadingUI)
	$aText = '正在处理，请稍后..'
	MsgBox(0, '提示', '已经成功重建当前系统图标缓存！', 5)
EndFunc   ;==>ReBuildIconache
