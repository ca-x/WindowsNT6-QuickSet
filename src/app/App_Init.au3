;==============================================================================
; 模块：程序初始化
; 说明：全局常量/变量、运行环境检测、加载动画、托盘菜单、单实例检查
; 文件：src\app\App_Init.au3
; 函数：共 0 个
;==============================================================================
#include-once

; 本文件为顶层可执行代码，由入口文件按顺序 #include，请勿调整 include 次序。

Global Const $UerHome = "https://czyt.tech"
Global Const $EXEVerson = FileGetVersion(@ScriptFullPath)
DllCall("Kernel32", "ubyte", "SetProcessShutdownParameters", "dword", 1024, "dword", 1)
;创建系统Flag，在x86系统下，使用64进行注册表访问
Local $OSFlag = '', $interfaceName, $Checkbox[22], $plugins[15], $svc[13], $SSDbox[15], $W81Dir[7], $SecuritySet[7], $hInput[11], $aTreeView[45], $RdWOL[3], $IpSetDlg[5], $UseBdMac[2], $FlagShowPassword[3], $MklinkTool[3], $win81dirOp[5], $OptResetBase[2], $aThinkHotkey[3], $CreateFileTool[4]
If @OSArch = "X64" Then
	Local $stOldVal = DllStructCreate("dword")
	DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "ptr", DllStructGetPtr($stOldVal))
	;当脚本为x86编译时，使用x64flag
	If _WinAPI_GetBinaryType(@ScriptFullPath) Then
		If @extended = $SCS_32BIT_BINARY Then $OSFlag = "64"
	EndIf
EndIf
Global $hover = False, $sHotkey = 0, $iniFile = @ScriptDir & '\IPSetData.ini', $IpSetStr = '', $IPdataNotInit = True, $InterFaceGUID = '', $HasSSD = HasSSD(), $iW = 500, $iH = 260, $aUserInfo[0][0], $gaDropFiles[1], $iComputerType
;检测当前用户是否以管理员身份运行
If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Then
	If IsAdmin() = 0 Then
		If MsgBox(4, '提示', '貌似您当前没有"以管理员身份运行"本程序' & @LF & @LF & '，部分设置可能失效，是否继续运行？', 5) = 7 Then
			Exit
		EndIf
	EndIf
EndIf
;计数变量n
Global $n = 0, $BootMode
If _Singleton(@ScriptName, 1) = 0 Then
	MsgBox(0, "额", "程序貌似已经在运行咯哦！")
	Exit
EndIf
;解决win8.1下模拟SYSTEM用户运行的问题所用函数需用变量
Const $ERROR_INVALID_SID = 1337
If IsUEFIBoot() Then
	_UEFIbmp(True, @TempDir)
	$iBootType = @TempDir & '\UEFI.bmp'
Else

	_BIOSbmp(True, @TempDir)
	$iBootType = @TempDir & '\BIOS.bmp'
EndIf

Global Const $tagSTARTUPINFO1 = "dword cb;ptr lpReserved;ptr lpDesktop;ptr lpTitle;dword dwX;dword dwY;dword dwXSize;dword dwYSize;" & _
		"dword dwXCountChars;dword dwYCountChars;dword dwFillAttribute;dword dwFlags;ushort wShowWindow;" & _
		"ushort cbReserved2;ptr lpReserved2;ptr hStdInput;ptr hStdOutput;ptr hStdError"
Global Const $tagPROCESSINFO1 = "ptr hProcess;ptr hThread;dword dwProcessId;dword dwThreadId"
Global $ghADVAPI32 = DllOpen("advapi32.dll")
Global $EvaApp = ''
If @OSBuild > 8000 Then
	FileInstall('.\src\file\ele.exe', @WindowsDir & '\', 1)
	$EvaApp = 'ele.exe '
EndIf
Local $ScreenSaverIsSecure = RegRead('HKEY_CURRENT_USER\Control Panel\Desktop', 'ScreenSaverIsSecure'), $UserSid = GetUserSID(), $PBLRegkey = 'HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', $BLRegkey = $PBLRegkey & '\DisallowRun', $DeletedProcessName = '', $IdentifyingNumber = '', $aGUID = ['{A6D9E920-8B6C-4C1A-8E72-993F7A86B115}', '{38BBFE26-4F51-45E7-A091-C7BB249C1086}', '{10CE8806-0501-44D5-A64E-476650A5C2F8}', '{432EF6CE-512A-4118-80F6-C98F49E0B62E}', '{90A10CAB-F4C9-41F9-9308-81F9D7C6C660}', '{A98EA9D1-C050-467D-ACBD-174495A51B45}', '{287A9098-318D-4703-8DE7-A15F7E807F51}', '{061667D2-F474-4E84-9E38-987CCD6EE05F}', '{BD604B7B-36AF-4E41-B05C-07D4054EA64D}', '{010B5AD7-1B8B-4035-81B6-84746EA7C61A}'], $aKey[12] = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '0A', '0B', '0C'], $aGroupBkcolor = ['0x6614a5', '0xf4546b', '0x615d62', '0x535353', '0x3399FF', '0xba0c19', '0x11a9d4'], $ibkcolor = Random(0, UBound($aGroupBkcolor) - 1, 1), $OEMInfo[6], $PidInstallNet35, $PidCleanCache, $aCtrlIDCheckBox[0][0], $aCtrlIDR[0][0]
HotKeySet('!n', 'ToogleNumLkHk')
;~ AdlibRegister('_UpdateIcoInfo','1200')
Global Const $MIB_IF_TYPE_OTHER = 1
Global Const $MIB_IF_TYPE_ETHERNET_CSMACD = 6
Global Const $MIB_IF_TYPE_ISO88025_TOKENRING = 9
Global Const $MIB_IF_TYPE_PPP = 23
Global Const $MIB_IF_TYPE_SOFTWARE_LOOPBACK = 24
Global Const $MIB_IF_TYPE_ATM = 37
Global Const $MIB_IF_TYPE_IEEE80211 = 71
Global Const $MIB_IF_TYPE_TUNNEL = 131
Global Const $MIB_IF_TYPE_IEEE1394 = 144
Global Const $tagMIB_IFROW = 'wchar Name[256];dword Index;dword Type;dword Mtu;dword Speed;dword PhysAddrLen;byte PhysAddr[8];dword AdminStatus;dword OperStatus;' & _
		'dword LastChange;dword InOctets;dword InUcastPkts;dword InNUcastPkts;dword InDiscards;dword InErrors;dword InUnknownProtos;dword OutOctets;dword OutUcastPkts;' & _
		'dword OutNUcastPkts;dword OutDiscards;dword OutErrors;dword OutQLen;dword DescrLen;char Descr[256]'

Global $IPHlpApi_Dll = DllOpen('IPHlpApi.dll')
Global $sLast_Label, $iShowHide = 1
Global $Global_IF_Count = _GetNumberofInterfaces()
Global $Table_Data = _WinAPI_GetIfTable()
Global $UseNetMetr = True
If @error Then
	$UseNetMetr = False
EndIf
OnAutoItExitRegister("ExitFunc")
FileDelete(@TempDir & '\logo.bmp')
_MakeLogo(True, @TempDir)
_HDDbmp(True, @TempDir)
_SSDbmp(True, @TempDir)
_Setico(True, @TempDir)
_Toico(True, @TempDir)
_Fromico(True, @TempDir)
_GDIPlus_Startup()
;~ Global Const $STM_SETIMAGE = 0x0172, $DBT_DEVICEARRIVAL = 0x8000, $DBT_DEVICEREMOVECOMPLETE = 0x8004
Global Const $DBT_DEVICEARRIVAL = 0x8000, $DBT_DEVICEREMOVECOMPLETE = 0x8004
If @OSBuild > 6000 Then
	Global $iW = 500, $iH = 100
Else
	Global $iW = 500, $iH = 80
EndIf
Global Const $LoadingUI = _GUICreate("Loading", $iW, $iH, -1, -1, $WS_POPUP, $WS_EX_TOPMOST + $WS_EX_TOOLWINDOW)
Global Const $iPic = GUICtrlCreatePic("", 0, 0, $iW, $iH)
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState()
Global $hHBmp_BG, $hB, $iPerc = 0, $iSleep = 20, $s = 0, $aText = "正在处理，请稍后.."
GUIRegisterMsg($WM_TIMER, "_Loader")
DllCall("user32.dll", "int", "SetTimer", "hwnd", $LoadingUI, "int", 0, "int", $iSleep, "int", 0)
;预解压补丁文件
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)
Opt("GUIOnEventMode", 1)
Const $tagMPRINTERFACE0 = "wchar Name[257];ptr Interface;int Enabled;int IfType;int State;dword UnreachabilityReasons;dword LastError"
Global $PcType, $osfullversion, $ActForm, $NetInfo = _GetNetworkAdapterInfo(), $AdapterList = GetAdaptersList(), $orgGroupName = _GetWorkgroupName(), $PasswordChangeMode = 0
Dim $varstr, $num
$aText = '正在检测系统版本信息..'
DetecPcType()
GetOSVersion()
$aText = '正在创建程序菜单..'
$ExtPlugins = TrayCreateMenu("系统附加插件")
TrayCreateItem('右键集成/卸载"转为Alpha通道bmp"', $ExtPlugins)
TrayItemSetOnEvent(-1, 'Convert2bmp')
TrayCreateItem('右键集成/卸载"UPX工具"', $ExtPlugins)
TrayItemSetOnEvent(-1, 'UPX')
TrayCreateItem('右键集成/卸载"JunctionMaster右键增强插件"', $ExtPlugins)
TrayItemSetOnEvent(-1, 'JunctionMaster')
TrayCreateItem('右键集成/卸载"安全移除该设备"', $ExtPlugins)
TrayItemSetOnEvent(-1, 'RemoveUsb')
If @OSBuild > 8000 Then
	TrayCreateItem('Universal Watermark Disabler', $ExtPlugins)
	TrayItemSetOnEvent(-1, 'UWD')
EndIf
TrayCreateItem('安装/卸载KClock任务栏时钟增强插件', $ExtPlugins)
TrayItemSetOnEvent(-1, 'KClock')
TrayCreateItem('安装/卸载魔方虚拟光驱', $ExtPlugins)
TrayItemSetOnEvent(-1, 'VirtualDrive')
If @OSBuild > 6000 Then
	TrayCreateItem('安装/卸载复制文件路径快捷菜单', $ExtPlugins)
	TrayItemSetOnEvent(-1, 'ClipExt')
EndIf
$QuickSet = TrayCreateMenu("系统功能快速设置")
$NetWorkTool = TrayCreateMenu('网络功能设置', $QuickSet)
$SysUseTool = TrayCreateMenu('系统实用工具', $QuickSet)
$UerAccTool = TrayCreateMenu('用户账户辅助', $QuickSet)
If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
	TrayCreateItem('IE SEC配置', $SysUseTool)
	TrayItemSetOnEvent(-1, 'IESEC')
EndIf
TrayCreateItem('自动登录设置器', $UerAccTool)
TrayItemSetOnEvent(-1, 'AutoLoginTool')
TrayCreateItem('重置Winsock', $NetWorkTool)
TrayItemSetOnEvent(-1, 'ResetWinsock')
TrayCreateItem('网络配置一键备份及恢复', $NetWorkTool)
TrayItemSetOnEvent(-1, '_NetWorkConfigsTool')
If _IsConnectedToInternet() Then TrayCreateItem('校准Windows时间', $SysUseTool)
TrayItemSetOnEvent(-1, 'SynSysTime')
If _IsConnectedToInternet() Then TrayCreateItem('Rainymood雨声白噪音', $SysUseTool)
TrayItemSetOnEvent(-1, '_Rainymood')
TrayCreateItem('创建宽带连接', $NetWorkTool)
TrayItemSetOnEvent(-1, 'CreateDigUp')
TrayCreateItem('修改远程桌面端口', $NetWorkTool)
TrayItemSetOnEvent(-1, 'ChangeTerminPort')
TrayCreateItem('重建图标缓存', $SysUseTool)
TrayItemSetOnEvent(-1, 'ReBuildIconache')
TrayCreateItem('注册表跳转', $SysUseTool)
TrayItemSetOnEvent(-1, '_FormRegJump')
TrayCreateItem('一键共享开关', $NetWorkTool)
TrayItemSetOnEvent(-1, 'OneKeySetShareUI')
TrayCreateItem('批量创建指定大小文件', $SysUseTool)
TrayItemSetOnEvent(-1, 'MutiCrateFiles')
TrayCreateItem('关闭显示器', $SysUseTool)
TrayItemSetOnEvent(-1, '_Monitor_OFF')
TrayCreateItem('文件免权限强制删除工具', $SysUseTool)
TrayItemSetOnEvent(-1, 'ForceDelToolUI')
TrayCreateItem('进程黑名单设置器', $SysUseTool)
TrayItemSetOnEvent(-1, 'ProcessBL')
TrayCreateItem('Windows安全选项设置', $SysUseTool)
TrayItemSetOnEvent(-1, 'SystemSecuritySet')
TrayCreateItem('鼠标左右键切换', $SysUseTool)
TrayItemSetOnEvent(-1, '_SwithMouseBtn')
If _IsConnectedToInternet() Then TrayCreateItem('Bing 18天壁纸下载器', $SysUseTool)
TrayItemSetOnEvent(-1, '_GuiDownloadBingWallPaper')
If @OSBuild > 6000 Then
	TrayCreateItem('MkLink GUI实用工具', $SysUseTool)
	TrayItemSetOnEvent(-1, 'MkLinkGUI')
EndIf
If @OSBuild >= 2200 Then
	TrayCreateItem('Windows 11 右键菜单切换', $SysUseTool)
	TrayItemSetOnEvent(-1, 'Win11RightMenuToogleUI')
EndIf
If @OSBuild > 17763 Then
	TrayCreateItem('Windows预览版计划切换器', $SysUseTool)
	TrayItemSetOnEvent(-1, 'InsiderSwitchUI')
EndIf
TrayCreateItem('SYSTEM用户执行操作模拟', $UerAccTool)
TrayItemSetOnEvent(-1, 'GuiSYSCMD')
TrayCreateItem('修改新建默认文件名', $SysUseTool)
TrayItemSetOnEvent(-1, 'formdefaultFileName')
If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Or @OSVersion = "WIN_2012" Or @OSVersion = "WIN_2016" Then
	TrayCreateItem('Windows X "这台电脑"文件夹一键设置', $SysUseTool)
	TrayItemSetOnEvent(-1, 'ExplorerDirManager')
	TrayCreateItem('Win+X 选项设置', $SysUseTool)
	TrayItemSetOnEvent(-1, 'FormWinX')
	TrayCreateItem('Windows NCSI服务器设置', $SysUseTool)
	TrayItemSetOnEvent(-1, 'NCSIServerUI')
	TrayCreateItem('Windows8.1+.NET Framework3.5安装工具', $SysUseTool)
	TrayItemSetOnEvent(-1, 'InstallNetFrame35UI')
	TrayCreateItem('释放Windows8.1更新缓存', $SysUseTool)
	TrayItemSetOnEvent(-1, 'ReleseCacheUI')
EndIf
If RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\IBM\TPHOTKEY', '') Then
	TrayCreateItem('Thinkpad热键自定义程序', $SysUseTool)
	TrayItemSetOnEvent(-1, 'TPHotKeySet')
EndIf
If StringInStr($PcType, 'X62') Then
	TrayCreateItem('X62 intel 无线状态灯设置程序', $SysUseTool)
	TrayItemSetOnEvent(-1, 'X62intelWlanLed')
EndIf
$TrayMenuHis = TrayCreateItem("版本更新记录")
TrayItemSetOnEvent(-1, '_History')
$TrayMenucheck = TrayCreateItem("检查新版本")
TrayItemSetOnEvent(-1, 'CheckUpdate')

TrayCreateItem("退出工具")
TrayItemSetOnEvent(-1, 'QuitTool')
TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "_ShowMain")
$aText = '程序加载完成..'
GUISetState(@SW_HIDE, $LoadingUI)
$aText = '正在处理，请稍后..'
