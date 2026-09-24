;==============================================================================
; 模块：Vista 及以后通用实现
; 说明：适用于 @OSBuild > 6000 的通用分支，以及无法再细分的兜底分支
; 文件：src\os\Os_Common.au3
;==============================================================================
#include-once

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_02
; 适用条件：@OSBuild < 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 1右键添加管理员取得所有权
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_02()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}\Count', '', 'REG_SZ', '')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F')
EndFunc   ;==>_OsCommon_AddRegTweaks_02

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_04
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 2右键添加CAB相关命令
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_04()
	Local $Icostr = _WinAPI_AssocQueryString('.cab', $ASSOCSTR_DEFAULTICON)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress', '', 'REG_SZ', 'CAB最大压缩')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress\command', '', 'REG_SZ', 'makecab /v3 /D CompressionType=LZX /D CompressionMemory=21 "%1"')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand', '', 'REG_SZ', '解压缩 CAB 文件')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand\command', '', 'REG_SZ', 'expand -r "%1"')
	RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'MUIVerb', 'REG_SZ', 'CAB文件工具')
	RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'icon', 'REG_SZ', $Icostr)
	RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'SubCommands', 'REG_SZ', 'CABCmpress;CABExpand')

EndFunc   ;==>_OsCommon_AddRegTweaks_04

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_08
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_08()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000001')
	RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_08

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_10
; 适用条件：@OSVersion = 'WIN_81'（不满足时走另一分支）
; 来源：AddRegTweaks / 5开始菜单显示运行命令
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_10()
	If @OSBuild > 6000 Then
		_OsCommon_AddRegTweaks_08()
	Else
		_OsXp_AddRegTweaks_09()
	EndIf
EndFunc   ;==>_OsCommon_AddRegTweaks_10

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_11
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 6资源管理器启用复选框
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_11()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'AutoCheckSelect', 'REG_DWORD', '1')
EndFunc   ;==>_OsCommon_AddRegTweaks_11

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_13
; 适用条件：@OSVersion = 'WIN_XP'（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_13()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_13

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_15
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 7禁用UAC
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_15()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorUser', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableInstallerDetection', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'PromptOnSecureDesktop', 'REG_DWORD', '00000000')
EndFunc   ;==>_OsCommon_AddRegTweaks_15

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_18
; 适用条件：@OSBuild < 6000（不满足时走另一分支）
; 来源：AddRegTweaks / 11移除快捷方式字样和图标
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_18()
	FileInstall('.\src\file\Empty.ico', @WindowsDir & '\', 1)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '29', 'REG_SZ', '%SystemRoot%\Empty.ico,0')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer', 'link', 'REG_BINARY', '00,00,00,00')
	RegWrite('HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer', 'link', 'REG_BINARY', '00,00,00,00')
EndFunc   ;==>_OsCommon_AddRegTweaks_18

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_20
; 适用条件：@OSBuild > 21900（不满足时走另一分支）
; 来源：AddRegTweaks / 12	任务栏使用小图标
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_20()
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSmallIcons', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_20

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_23
; 适用条件：@OSBuild > 21990（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_23()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'NoPreviousVersionsPage', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_23

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_26
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 14打开所在目录
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_26()
	If @OSBuild > 8000 Then
		_OsWin8_AddRegTweaks_24()
	Else
		_OsVista7_AddRegTweaks_25()
	EndIf
EndFunc   ;==>_OsCommon_AddRegTweaks_26

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_30
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 15隐藏操作中心图标
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_30()
	If @OSBuild > 9000 Then
		_OsWin10_AddRegTweaks_28()
	Else
		_OsWin8_AddRegTweaks_29()
	EndIf
EndFunc   ;==>_OsCommon_AddRegTweaks_30

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_32
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_32()
	;已登录用户计算机自动更新安装不执行自动重启
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU', 'NoAutoRebootWithLoggedOnUsers', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_32

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_42
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_42()
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式', '', 'REG_SZ', '上帝模式')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式\command', '', 'REG_EXPAND_SZ', 'explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C}')
EndFunc   ;==>_OsCommon_AddRegTweaks_42

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_44
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_44()
	If @OSBuild > 6000 Then
		_OsCommon_AddRegTweaks_42()
	Else
		_OsXp_AddRegTweaks_43()
	EndIf
EndFunc   ;==>_OsCommon_AddRegTweaks_44

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_51
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'（不满足时走另一分支）
; 来源：AddRegTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_51()
	;清理显卡右键菜单
	Run('regsvr32 /s /u igfxpph.dll nvcpl.dll atiacmxx.dll igfxsrvc.dll', @WindowsDir, @SW_HIDE)
	RegDelete('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers')
	RegWrite('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New', '', 'REG_SZ', '{D969A300-E7FF-11d0-A93B-00A0C90F2719}')
EndFunc   ;==>_OsCommon_AddRegTweaks_51

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_54
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003'（不满足时走另一分支）
; 来源：AddRegTweaks / 19禁用登录需要按Ctrl+Alt+Del
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_54()
	;设置USB弹出后不再进行供电
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'EnableDiagnosticMode', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'DisableOnSoftRemove', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_54

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_56
; 适用条件：@OSBuild > 21900（不满足时走另一分支）
; 来源：AddRegTweaks / 20IE综合优化选项
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_56()
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Friendly http errors", "REG_SZ", "yes")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "DisableScriptDebuggerIE", "REG_SZ", "yes")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "UseThemes", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Download", "CheckExeSignatures", "REG_SZ", "no")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Download", "RunInvalidSignatures", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "NotifyDownloadComplete", "REG_SZ", "no")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "SmoothScroll", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Enable AutoImageResize", "REG_SZ", "yes")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Show image placeholders", "REG_DWORD", "00000001")
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main", "Show_FullURL", "REG_SZ", "yes")
	RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults", "about", "REG_DWORD", "00000004")
	;使IE可以进行10个下载任务
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings', 'MaxConnectionsPer1_0Server', 'REG_DWORD', '00000064')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings', 'MaxConnectionsPerServer', 'REG_DWORD', '00000064')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER', 'iexplore.exe', 'REG_DWORD', '0000000a')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER', 'iexplore.exe', 'REG_DWORD', '0000000A')
	;使得IE可以像在资源管理器中一样打开Ftp站点
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_INTERNET_SHELL_FOLDERS', 'iexplore.exe', 'REG_DWORD', '00000001')
	;在前端浏览器打开
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'OpenInForeground', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'OpenInForeground', 'REG_DWORD', '00000000')
	;Group?啥玩意
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'Groups', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'Groups', 'REG_DWORD', '00000001')
	;缩略图？？
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'ThumbnailBehavior', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'ThumbnailBehavior', 'REG_DWORD', '00000001')
	;关闭多标签的时候发出提示警告
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'WarnOnClose', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'WarnOnClose', 'REG_DWORD', '00000001')
	;始终在新选项卡中打开连接
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'PopupsUseNewWindow', 'REG_DWORD', '00000002')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'PopupsUseNewWindow', 'REG_DWORD', '00000002')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'NewTabPageShow', 'REG_DWORD', '00000002')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'NewTabPageShow', 'REG_DWORD', '00000002')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'NewTabNextToCurrent', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'NewTabNextToCurrent', 'REG_DWORD', '00000001')
	;其他的
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\Main', 'DEPOff', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'QuickTabsThreshold', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'QuickTabsThreshold', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'ShortcutBehavior', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'ShortcutBehavior', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'Enabled', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Internet Explorer\TabbedBrowsing', 'Enabled', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_56

;-------------------------------------------------------------------------------
; _OsCommon_AddRegTweaks_57
; 适用条件：@OSBuild > 6000
; 来源：AddRegTweaks / 21关闭系统开机声音#关闭分组相似任务栏按钮
;-------------------------------------------------------------------------------
Func _OsCommon_AddRegTweaks_57()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation', 'DisableStartupSound', 'REG_DWORD', '00000001')
EndFunc   ;==>_OsCommon_AddRegTweaks_57

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_04
; 适用条件：@OSBuild < 6000（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_04()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装摄像头工具..'
	$percent += $percent
	FileInstall('.\src\file\Ecap.exe', @WindowsDir & '\', 1)
	FileCreateShortcut(@WindowsDir & '\Ecap.exe', @UserProfileDir & '\Appdata\Roaming\Microsoft\Windows\Network shortcuts\视频设备', @WindowsDir)
EndFunc   ;==>_OsCommon_pluginsTweaks_04

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_10
; 适用条件：@OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008"（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_10()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装浏览器搜素引擎增强包..'
	FileInstall('.\src\file\ico.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\ico.exe', @TempDir, @SW_HIDE)
	Local $Regkey = 'HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\SearchScopes', $IndexGUID = 9, $TempGUID = ''
	;设置默认搜索引擎
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey, 'DefaultScope', 'REG_SZ', $TempGUID)

	;百度
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '百度')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://www.baidu.com/baidu?wd={searchTerms}&tn=bdss2010_dg&ie=utf-8')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.iegallery.com/zh-CN/AddOns/DownloadAddOn?resourceId=857')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\baidu.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.baidu.com/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '0000fde9')
	RegWrite($Regkey & '\' & $TempGUID, 'ShowSearchSuggestions', 'REG_DWORD', 'dword:00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL_JSON', 'REG_SZ', 'http://suggestion.baidu.com/su?wd={searchTerms}&action=opensearch&ie=utf-8')

	;谷歌
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', 'Google')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://www.google.com.hk/search?q={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\google.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.google.com.hk/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000002')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '0000fde9')

	;淘宝
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '淘宝购物搜索')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://search8.taobao.com/browse/search_auction.htm?q={searchTerms}&cat=0&pid=mm_16665530_0_0&viewIndex=7')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\taobao.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.taobao.com/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000003')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '0000d698')

	;凡客
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '凡客诚品')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://s.vancl.com/search?k={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\fk.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://i.vanclimg.com/common/favicon/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000004')

	;维基百科
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '维基百科中文搜索')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://zh.wikipedia.org/w/index.php?title=Special:%E6%90%9C%E7%B4%A2&search={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\weiji.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://zh.wikipedia.org/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000005')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://zh.wikipedia.org/w/opensearch_desc.php')
	RegWrite($Regkey & '\' & $TempGUID, 'ShowSearchSuggestions', 'REG_DWORD', '00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL_JSON', 'REG_SZ', 'http://zh.wikipedia.org/w/api.php?action=opensearch&search={searchTerms}&namespace=0')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL', 'REG_SZ', 'http://zh.wikipedia.org/w/api.php?action=opensearch&format=xml&search={searchTerms}&namespace=0')
	;新浪天气
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '新浪天气查询')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://php.weather.sina.com.cn/search.php?city={searchTerms}&f=1&dpc=1')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\sina.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.sinaimg.cn/IT/sina_icon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000006')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '000003a8')
	RegWrite($Regkey & '\' & $TempGUID, 'ShowSearchSuggestions', 'REG_DWORD', '00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL', 'REG_SZ', 'http://php.weather.sina.com.cn/iframe/open_search_weather.php?city={searchTerms}&dpc=1')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.ieaddons.com/cn/DownloadHandler.ashx?ResourceId=2033')
	;有道词典
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '有道海量词典')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://dict.youdao.com/search?q={searchTerms}&keyfrom=ie8.suggest')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\youdao.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://shared.youdao.com/plugins/DictSearchIcon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000007')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.ieaddons.com/cn/DownloadHandler.ashx?ResourceId=830')
	RegWrite($Regkey & '\' & $TempGUID, 'ShowSearchSuggestions', 'REG_DWORD', '00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL', 'REG_SZ', 'http://dict.youdao.com/suggest/ie8.s?query={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL_JSON', 'REG_SZ', 'http://dict.youdao.com/suggest/js.s?query={searchTerms}')
	;亚马逊
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '卓越亚马逊搜索')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://www.amazon.cn/search/search.asp?source=amozonprofile&searchWord={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\zy.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.amazon.cn/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000008')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '0000fde9')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.ieaddons.com/cn/DownloadHandler.ashx?ResourceId=4748')

	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '京东商城')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://search.jd.com/Search?keyword={searchTerms}&enc=utf-8&suggest=2')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\jd.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.jd.com/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'SortIndex', 'REG_DWORD', '00000009')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '000003a8')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.iegallery.com/zh-CN/AddOns/DownloadAddOn?resourceId=12673')

	;当当网
	$TempGUID = $aGUID[$IndexGUID]
	$IndexGUID -= 1
	RegWrite($Regkey & '\' & $TempGUID, 'DisplayName', 'REG_SZ', '当当网')
	RegWrite($Regkey & '\' & $TempGUID, 'URL', 'REG_SZ', 'http://search.dangdang.com/?key={searchTerms}')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconPath', 'REG_SZ', '%systemdrive%\\WINDOWS\\Web\\ico\\dd.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'FaviconURL', 'REG_SZ', 'http://www.dangdang.com/favicon.ico')
	RegWrite($Regkey & '\' & $TempGUID, 'Codepage', 'REG_DWORD', '000003a8')
	RegWrite($Regkey & '\' & $TempGUID, 'OSDFileURL', 'REG_SZ', 'http://www.iegallery.com/zh-CN/AddOns/DownloadAddOn?resourceId=6414')
	RegWrite($Regkey & '\' & $TempGUID, 'ShowSearchSuggestions', 'REG_DWORD', '00000001')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL', 'REG_SZ', 'http://api.wudso.com/suggest/?q={searchTerms}&id=dangdang&format=xml&lang={Language}')
	RegWrite($Regkey & '\' & $TempGUID, 'SuggestionsURL_JSON', 'REG_SZ', 'http://api.wudso.com/suggest/?q={searchTerms}&id=dangdang&format=json&lang={Language}')
	FileDelete(@TempDir & '\ico.exe')
EndFunc   ;==>_OsCommon_pluginsTweaks_10

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_11
; 适用条件：@OSVersion = 'WIN_XP'（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_11()
	If @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008" Then
		_OsServer_pluginsTweaks_09()
	Else
		_OsCommon_pluginsTweaks_10()
	EndIf
EndFunc   ;==>_OsCommon_pluginsTweaks_11

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_15
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008'（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_15()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Flash P2P上传屏蔽补丁..'
	If FileExists(@HomeDrive & "\Windows\System32\FlashPlayerApp.exe") Then
		Local $batStr = _
				'@cd \' & @CRLF & _
				'@copy /y "%windir%\system32\Macromed\Flash\mms.cfg" "%windir%\system32\Macromed\Flash\mms.tmp"' & @CRLF & _
				'@del /f /q "%windir%\system32\Macromed\Flash\mms.cfg"' & @CRLF & _
				'@findstr /v "RTMFPP2PDisable" "%windir%\system32\Macromed\Flash\mms.tmp">>%windir%\system32\Macromed\Flash\mms.cfg' & @CRLF & _
				'@echo RTMFPP2PDisable=1 >> %windir%\system32\Macromed\Flash\mms.cfg' & @CRLF & _
				'@copy /y "%windir%\syswow64\Macromed\Flash\mms.cfg" "%windir%\syswow64\Macromed\Flash\mms.tmp"' & @CRLF & _
				'@del /f /q "%windir%\syswow64\Macromed\Flash\mms.cfg"' & @CRLF & _
				'@findstr /v "RTMFPP2PDisable" "%windir%\syswow64\Macromed\Flash\mms.tmp">>%windir%\syswow64\Macromed\Flash\mms.cfg' & @CRLF & _
				'@echo RTMFPP2PDisable=1 >> %windir%\syswow64\Macromed\Flash\mms.cfg' & @CRLF & _
				'@copy /y "%windir%\system32\mms.cfg" "%windir%\system32\mms.tmp"' & @CRLF & _
				'@del /f /q "%windir%\system32\mms.cfg"' & @CRLF & _
				'@findstr /v "RTMFPP2PDisable" "%windir%\system32\mms.tmp">>%windir%\syswow64\Macromed\Flash\mms.cfg' & @CRLF & _
				'@echo RTMFPP2PDisable=1 >> %windir%\system32\mms.cfg' & @CRLF & _
				'cls' & @CRLF & _
				'@echo off' & @CRLF & _
				'del/f/s/q %0'
		$Fh = FileOpen(@TempDir & '\banFlashP2P.bat', 2 + 8)
		FileWrite($Fh, $batStr)
		FileClose($Fh)
		Run(@HomeDrive & "/Windows\System32\FlashPlayerApp.exe")
		WinWait("[CLASS:#32770]", "")
		WinActive("[CLASS:#32770]", "")
		Send("{right}{right}")
		WinWait("[CLASS:#32770]", "对等协助网络")
		WinActive("[CLASS:#32770]", "对等协助网络")
		ControlClick("[CLASS:#32770]", "对等协助网络", "Button2")
		WinClose("[CLASS:#32770]", "对等协助网络")
		RunWait(@TempDir & '\banFlashP2P.bat', @TempDir, @SW_HIDE)
		FileDelete(@TempDir & '\banFlashP2P.bat')
	EndIf
EndFunc   ;==>_OsCommon_pluginsTweaks_15

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_16
; 适用条件：@OSBuild < 6000（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_16()
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
		_OsServer_pluginsTweaks_14()
	Else
		_OsCommon_pluginsTweaks_15()
	EndIf
EndFunc   ;==>_OsCommon_pluginsTweaks_16

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_20
; 适用条件：@OSBuild < 6000（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_20()
	If @OSBuild < 8000 Then
		_OsVista7_pluginsTweaks_18()
	Else
		_OsWin8_pluginsTweaks_19()
	EndIf
EndFunc   ;==>_OsCommon_pluginsTweaks_20

;-------------------------------------------------------------------------------
; _OsCommon_pluginsTweaks_22
; 适用条件：@OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008'（不满足时走另一分支）
; 来源：pluginsTweaks
;-------------------------------------------------------------------------------
Func _OsCommon_pluginsTweaks_22()
	$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在添加“显示/隐藏系统文件+扩展名”右键菜单..'
	_SuperHidden(True, @WindowsDir & '\')
	;创建菜单
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\InProcServer32', '', 'REG_EXPAND_SZ', '%SystemRoot%\system32\shdocvw.dll')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\InProcServer32', 'ThreadingModel', 'REG_SZ', 'Apartment')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance', 'CLSID', 'REG_SZ', '{3f454f0e-42ae-4d7c-8ea3-328250d6e272}')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance\InitPropertyBag', 'Param1', 'REG_SZ', 'SuperHidden.vbs')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance\InitPropertyBag', 'method', 'REG_SZ', 'ShellExecute')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance\InitPropertyBag', 'command', 'REG_SZ', '显示/隐藏系统文件+扩展名')
	RegWrite('HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance\InitPropertyBag', 'CLSID', 'REG_SZ', '{13709620-C279-11CE-A49E-444553540000}')
	RegWrite('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\SuperHidden', '', 'REG_SZ', '{00000000-0000-0000-0000-000000000012}')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ShowSuperHidden', 'REG_DWORD', '00000001')
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Hidden', 'REG_DWORD', '00000002')
	;创建一个卸载的注册表，以便用户使用
	Local $uninsReg = 'REGEDIT4' & @CRLF & _
			'[-HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\SuperHidden]' & @CRLF & _
			'@="{00000000-0000-0000-0000-000000000012}"' & @CRLF & _
			'[-HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\InProcServer32]' & @CRLF & _
			'@=hex(2):25,53,79,73,74,65,6d,52,6f,6f,74,25,5c,73,79,73,74,65,6d,33,32,5c,73,\' & @CRLF & _
			'  68,64,6f,63,76,77,2e,64,6c,6c,00' & @CRLF & _
			'"ThreadingModel"="Apartment"' & @CRLF & _
			'[-HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance]' & @CRLF & _
			'"CLSID"="{3f454f0e-42ae-4d7c-8ea3-328250d6e272}"' & @CRLF & _
			'[-HKEY_CLASSES_ROOT\CLSID\{00000000-0000-0000-0000-000000000012}\Instance\InitPropertyBag]' & @CRLF & _
			'"method"="ShellExecute"' & @CRLF & _
			'"Param1"="SuperHidden.vbs"' & @CRLF & _
			'"command"="显示/隐藏系统文件+扩展名"' & @CRLF & _
			'"CLSID"="{13709620-C279-11CE-A49E-444553540000}"' & @CRLF & _
			'[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]' & @CRLF & _
			'"ShowSuperHidden"=dword:00000000' & @CRLF & _
			'"Hidden"=dword:00000002'
	Local $regFile = FileOpen(@WindowsDir & '\UninstallSuperHidden.reg', 2 + 8)
	FileWrite($regFile, $uninsReg)
	FileClose($regFile)
EndFunc   ;==>_OsCommon_pluginsTweaks_22
