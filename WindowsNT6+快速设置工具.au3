#Region ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#PRE_Icon=ToolIco.ico
#PRE_Outfile=WindowsNT6+快速设置工具.exe
#PRE_Outfile_x64=WindowsNT6+快速设置工具_x64.exe
#PRE_UseUpx=y
#PRE_Compile_Both=y
#PRE_Res_Comment=Windows NT6+ 快速设置工具 By 虫子樱桃
#PRE_Res_Description=Windows NT6+ 快速设置工具By 虫子樱桃
#PRE_Res_Fileversion=1.8.0.64
#PRE_Res_Fileversion_AutoIncrement=y
#PRE_Res_LegalCopyright=虫子樱桃
#PRE_Res_Language=2052
#PRE_Res_requestedExecutionLevel=highestAvailable
#PRE_Res_Field=技术支持论坛|http://bbs.ota.com.cn
#PRE_Res_Field=作者博客|https://czyt.tech
#PRE_Antidecompile=y
#EndRegion ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#Region ;**** 参数创建于 ACNWrapper_GUI ****
#EndRegion ;**** 参数创建于 ACNWrapper_GUI ****
#include 'file\_GUIDisable.au3'
#include 'file\GUICtrlOnHover.au3'
#include <Array.au3>
#include <APIConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <GuiEdit.au3>
#include <GuiTreeView.au3>
#include <GuiListView.au3>
#include <GuiIPAddress.au3>
#include <GuiTab.au3>
#include <GDIPlus.au3>
#include <ListViewConstants.au3>
#include <TreeViewConstants.au3>
#include <StaticConstants.au3>
#include <ProgressConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIEx.au3>
#include <File.au3>
#include <Constants.au3>
#include <Misc.au3>
#include <WinAPIDiag.au3>
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
	FileInstall('.\file\ele.exe', @WindowsDir & '\', 1)
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
$Form1 = _GUICreate("Windows NT6+ 快速设置工具 V" & FileGetVersion(@ScriptFullPath), 610, 400, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_POPUP, $WS_GROUP), BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE))
GUISetBkColor(0xedeef1)
If StringInStr($PcType, 'X62') Then
	_x62_Img_app(True, @TempDir)
Else
	_IMGAPPbmp(True, @TempDir)
EndIf

_IMG_CLOSE_Hbmp(True, @TempDir)
_IMG_CLOSE_Nbmp(True, @TempDir)
_IMG_MAX_Hbmp(True, @TempDir)
_IMG_MAX_Nbmp(True, @TempDir)
_IMG_MIN_Hbmp(True, @TempDir)
_IMG_MIN_Nbmp(True, @TempDir)
If @Compiled Then
	GUICtrlCreateIcon(@ScriptFullPath, -1, 5, 5, 20, 20)
Else
	GUICtrlCreateIcon('ToolIco.ico', -1, 5, 5, 20, 20)
EndIf
GUICtrlSetOnEvent(-1, '_MoveGUI')
GUICtrlCreatePic(@TempDir & '\IMG_APP.bmp', 32, 0, 495, 30)
GUICtrlSetOnEvent(-1, '_MoveGUI')
$IMGClose = GUICtrlCreatePic(@TempDir & '\IMG_CLOSE_N.bmp', 570, 0, 30, 28)
_GUICtrl_OnHoverRegister(-1, '_Hover_Func', '_Hover_Func')
GUICtrlSetOnEvent(-1, 'QuitTool')
$IMGMax = GUICtrlCreatePic(@TempDir & '\IMG_MAX_N.bmp', 540, 0, 30, 28)
_GUICtrl_OnHoverRegister(-1, '_Hover_Func', '_Hover_Func')
If @OSBuild > 9000 Then
	$MbtnMax = GUICtrlCreateContextMenu($IMGMax)
	GUICtrlCreateMenuItem('删除Windows Defender右键', $MbtnMax)
	GUICtrlSetOnEvent(-1, 'RemoveWD')
	GUICtrlCreateMenuItem('恢复Windows Defender右键', $MbtnMax)
	GUICtrlSetOnEvent(-1, 'RestoreWD')
EndIf
$IMGMin = GUICtrlCreatePic(@TempDir & '\IMG_MIN_N.bmp', 510, 0, 30, 28)
_GUICtrl_OnHoverRegister(-1, '_Hover_Func', '_Hover_Func')
GUICtrlSetOnEvent(-1, '_MinisizeGUI')
GUISetFont(9 * _GDIPlus_GraphicsGetDPIRatio()[0])
$Pic1 = GUICtrlCreatePic(@TempDir & "\logo.bmp", 0, 30, 612, 70)
$OnPic = GUICtrlCreatePic("", 560, 367, 32, 32)
GUICtrlSetOnEvent(-1, 'ToogleNumLk')
$OffPic = GUICtrlCreatePic("", 560, 367, 32, 32)
GUICtrlSetOnEvent(-1, 'ToogleNumLk')
_PrepBmp()
NumLkStatus()
$Tab1 = GUICtrlCreateTab(0, 104, 609, 257)
$TabSheet1 = GUICtrlCreateTabItem("常规优化选项")
If @OSBuild < 6000 Then
	$Checkbox[1] = _GUICtrlCreateCheckbox(($ScreenSaverIsSecure = 0) ? ("从屏保恢复时显示登录屏幕") : ("从屏保恢复时不显示登录屏幕"), 8, 136, 177, 17)
	GUICtrlSetTip(-1, '设置在从屏保恢复时是否显示登录屏幕')
Else
	$Checkbox[1] = _GUICtrlCreateCheckbox("右键添加管理员取得所有权", 8, 136, 177, 17)
	GUICtrlSetTip(-1, '在右键添加"管理员取得所有权"，一般系' & @LF & '统安装以后没有这个的，推荐选中。')
	$MCheckBox1 = GUICtrlCreateContextMenu($Checkbox[1])
	GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox1)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak1')
EndIf
If @OSBuild > 19040 Then
	$Checkbox[2] = _GUICtrlCreateCheckbox("恢复经典系统属性", 8, 160, 145, 17)
	GUICtrlSetTip(-1, 'windows 10 20h1及后续版本恢复经典系统属性')
Else
	$Checkbox[2] = _GUICtrlCreateCheckbox("右键添加CAB相关命令", 8, 160, 145, 17)
	GUICtrlSetTip(-1, '在右键添加包含"Cab最大压缩"和"Cab解压缩"子菜单的"CAB文件' & @LF & '工具"菜单,如果你有操作类似svcpack.in_文件的需要，请选中。')
EndIf
$MCheckBox2 = GUICtrlCreateContextMenu($Checkbox[2])
GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox2)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak2')

$Checkbox[3] = _GUICtrlCreateCheckbox("右键快速打开CMD", 8, 184, 129, 17)
GUICtrlSetTip(-1, '在右键快速打开命令提示符，懒得cd来cd去了！推荐选择。')
$MCheckBox3 = GUICtrlCreateContextMenu($Checkbox[3])
GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox3)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak3')
$Checkbox[4] = _GUICtrlCreateCheckbox("右键快速打开PowerShell", 8, 208, 153, 17)
GUICtrlSetTip(-1, '快速打开Powershell')
$MCheckBox4 = GUICtrlCreateContextMenu($Checkbox[4])
GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox4)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak4')
If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Then
	$Checkbox[5] = _GUICtrlCreateCheckbox("使所有文件都可固定到开始屏幕", 8, 232, 185, 17)
	GUICtrlSetTip(-1, '勾选此选项可以使得所有' & @LF & '文件都可固定到开始屏幕。')
Else
	If @OSBuild > 6000 Then
		$Checkbox[5] = _GUICtrlCreateCheckbox("开始菜单显示运行命令", 8, 232, 153, 17)
		GUICtrlSetTip(-1, 'Windows7默认隐藏开始菜单的运行命令。选中该项将在' & @LF & '开始菜单显示运行命令。推荐选择。')
	Else
		$Checkbox[5] = _GUICtrlCreateCheckbox("禁止光盘及磁盘自动运行", 8, 232, 153, 17)
		GUICtrlSetTip(-1, '勾选此选项可加强系统对病毒的防御能力。')
	EndIf
EndIf
$MCheckBox5 = GUICtrlCreateContextMenu($Checkbox[5])
If @OSBuild > 6000 Then
	GUICtrlCreateMenuItem('移除该项优化', $MCheckBox5)
Else
	GUICtrlCreateMenuItem('启用光盘及磁盘的自动播放', $MCheckBox5)
EndIf
GUICtrlSetOnEvent(-1, 'RemoveRegTweak5')
If @OSBuild > 6000 Then
	$Checkbox[6] = _GUICtrlCreateCheckbox("资源管理器启用复选框", 8, 256, 153, 17)
	GUICtrlSetTip(-1, '选中该选项以后，会在所有的文件上出现一个复选框，选中文' & @LF & '件只需选中复选框即可，再也不用按住ctrl或shift来选择了。')
Else
	If @OSVersion = 'WIN_XP' Then
		$Checkbox[6] = _GUICtrlCreateCheckbox("重获WindowsUpdate更新", 8, 256, 172, 17)
		GUICtrlSetTip(-1, '选中该选项以后，将模拟系统为Windows Embedded ' & @LF & 'POSReady 2009以获取WindowsUpdate更新支持。')
	Else
		$Checkbox[6] = _GUICtrlCreateCheckbox("关闭系统默认共享", 8, 256, 172, 17)
		GUICtrlSetTip(-1, '关闭系统中类似$IPC之类的共享')
	EndIf
EndIf
$MCheckBox6 = GUICtrlCreateContextMenu($Checkbox[6])
If @OSBuild > 6000 Then
	GUICtrlCreateMenuItem('资源管理器取消复选框', $MCheckBox6)
Else
	If @OSVersion <> 'WIN_XP' Then
		GUICtrlCreateMenuItem('恢复系统默认共享', $MCheckBox6)
	EndIf
EndIf
GUICtrlSetOnEvent(-1, 'RemoveRegTweak6')
If @OSBuild > 6000 Then
	$Checkbox[7] = _GUICtrlCreateCheckbox("禁用UAC", 8, 280, 97, 17)
	GUICtrlSetTip(-1, '禁用用户帐户控制弹出框，这个一般是要禁用的。推荐选中。')
Else
	$Checkbox[7] = _GUICtrlCreateCheckbox("禁止远程修改注册表", 8, 280, 127, 17)
	GUICtrlSetTip(-1, '禁止通过远程会话等方式对注册表进行修改。')
EndIf
$MCheckBox7 = GUICtrlCreateContextMenu($Checkbox[7])
GUICtrlCreateMenuItem('启用UAC', $MCheckBox7)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak7')
$Checkbox[8] = _GUICtrlCreateCheckbox("右键添加记事本打开项", 8, 304, 145, 17)
GUICtrlSetTip(-1, '在右键添加使用记事本打开的选项。推荐选择。')
$MCheckBox8 = GUICtrlCreateContextMenu($Checkbox[8])
GUICtrlCreateMenuItem('移除记事本右键菜单', $MCheckBox8)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak8')
$Checkbox[9] = _GUICtrlCreateCheckbox("右键添加DLL\OCX注册与反注册", 216, 136, 193, 17)
GUICtrlSetTip(-1, '对于如dll或者ocx的文件进行便捷的注册与反注册。推荐选择。')
$MCheckBox9 = GUICtrlCreateContextMenu($Checkbox[9])
GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox9)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak9')
$Checkbox[10] = _GUICtrlCreateCheckbox("右键添加在新窗口打开命令", 216, 160, 185, 17)
GUICtrlSetTip(-1, '新开一个窗口，在新窗口中打开文件夹。')
$MCheckBox10 = GUICtrlCreateContextMenu($Checkbox[10])
GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox10)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak10')
$Checkbox[11] = _GUICtrlCreateCheckbox("移除快捷方式字样和图标", 216, 184, 161, 17)
GUICtrlSetTip(-1, '移除快捷方式上的小箭头图标和快捷方式字样。')
If @OSBuild > 6000 Then
	$MCheckBox11 = GUICtrlCreateContextMenu($Checkbox[11])
	GUICtrlCreateMenuItem('恢复快捷方式图标', $MCheckBox11)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak11')
	If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Or @OSVersion = "WIN_2012R2" Or @OSVersion = "WIN_2012" Then
		GUICtrlCreateMenuItem('移除小盾牌', $MCheckBox11)
		GUICtrlSetOnEvent(-1, 'RemoveDP')
		GUICtrlCreateMenuItem('还原小盾牌', $MCheckBox11)
		GUICtrlSetOnEvent(-1, 'RestoreDP')
	EndIf
EndIf
$Checkbox[12] = _GUICtrlCreateCheckbox("任务栏使用小图标", 216, 208, 193, 17)
GUICtrlSetTip(-1, '使用小图标的任务栏。', '提示', 1)
$MCheckBox12 = GUICtrlCreateContextMenu($Checkbox[12])
If @OSBuild > 21900 Then
	GUICtrlCreateMenuItem('任务栏使用中等图标', $MCheckBox12)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak12_1')
EndIf
GUICtrlCreateMenuItem('任务栏使用大图标', $MCheckBox12)
GUICtrlSetOnEvent(-1, 'RemoveRegTweak12')
$Checkbox[13] = _GUICtrlCreateCheckbox("优化系统显示设置", 216, 232, 145, 17)
GUICtrlSetTip(-1, '优化显示效果。')
If @OSBuild > 6000 Then
	If @OSBuild > 8000 Then
		If @OSBuild > 21990 Then
			$Checkbox[14] = _GUICtrlCreateCheckbox('跳过TPM和安全启动检查', 216, 256, 185, 17)
			GUICtrlSetTip(-1, '勾选此选项，跳过TPM和安全启动检查，使老系统也可以安装或更新windows11', '提示', 1)
			$MCheckBox14 = GUICtrlCreateContextMenu($Checkbox[14])
			GUICtrlCreateMenuItem('还原还原系统默认设置', $MCheckBox14)
			GUICtrlSetOnEvent(-1, 'RemoveRegTweak14')
		Else
			$Checkbox[14] = _GUICtrlCreateCheckbox('去除属性界面"以前的版本"标签页', 216, 256, 185, 17)
			GUICtrlSetTip(-1, '勾选此选项，可去除属性界面"以前的版本"标签页', '提示', 1)
			$MCheckBox14 = GUICtrlCreateContextMenu($Checkbox[14])
			GUICtrlCreateMenuItem('还原属性界面"以前的版本"标签页', $MCheckBox14)
			GUICtrlSetOnEvent(-1, 'RemoveRegTweak14')
		EndIf
	Else
		$Checkbox[14] = _GUICtrlCreateCheckbox('右键添加"窗口转换程序"', 216, 256, 185, 17)
		GUICtrlSetTip(-1, '勾选此选项，可以在右键添加' & @LF & '"窗口转换程序"菜单', '提示', 1)
		$MCheckBox14 = GUICtrlCreateContextMenu($Checkbox[14])
		GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox14)
		GUICtrlSetOnEvent(-1, 'RemoveRegTweak14')
	EndIf
Else
	$Checkbox[14] = _GUICtrlCreateCheckbox('快捷方式右键添加"打开所在目录"', 216, 256, 185, 17)
	GUICtrlSetTip(-1, '勾选此选项，可以在快捷方式的右键添加' & @LF & '"打开所在目录"菜单', '提示', 1)
	$MCheckBox14 = GUICtrlCreateContextMenu($Checkbox[14])
	GUICtrlCreateMenuItem('移除该右键菜单', $MCheckBox14)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak14')
EndIf
If @OSBuild > 6000 Then
	$Checkbox[15] = _GUICtrlCreateCheckbox("隐藏操作中心托盘图标", 216, 280, 137, 17)
	GUICtrlSetTip(-1, '操作中心图标，一般我们都要手动关闭的，推荐选中。')
	$MCheckBox15 = GUICtrlCreateContextMenu($Checkbox[15])
	GUICtrlCreateMenuItem('恢复操作中心托盘图标', $MCheckBox15)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak15')
Else
	$Checkbox[15] = _GUICtrlCreateCheckbox("屏蔽安全中心对病毒软件的监控", 216, 280, 187, 17)
	GUICtrlSetTip(-1, '没什么用的功能，推荐选中。')
EndIf
$Checkbox[16] = _GUICtrlCreateCheckbox("系统性能综合优化", 216, 304, 129, 17)
GUICtrlSetTip(-1, '对于系统性能、兼容性的一些综合优化项目。' & @LF & '优化项目比较全面，建议选中！')
If @OSBuild > 8000 Then
	;Windows8等系统
	If @OSBuild > 9000 Then
		$Checkbox[17] = _GUICtrlCreateCheckbox("打开资源管理器时打开此电脑", 432, 136, 180, 17)
		GUICtrlSetTip(-1, '默认情况下，打开资源管理器时打开的是快速访问', '说明', 1)
		$MCheckBox17 = GUICtrlCreateContextMenu($Checkbox[17])
		GUICtrlCreateMenuItem('打开资源管理器时打开快速访问', $MCheckBox17)
		GUICtrlSetOnEvent(-1, 'RemoveRegTweak17')
		$Checkbox[18] = _GUICtrlCreateCheckbox("精简快速访问选项", 432, 160, 165, 17)
		GUICtrlSetTip(-1, '设定快速访问不显示常用文件夹及最近文件', '说明', 1)
		$MCheckBox18 = GUICtrlCreateContextMenu($Checkbox[18])
		GUICtrlCreateMenuItem('快速访问显示常用文件夹', $MCheckBox18)
		GUICtrlSetOnEvent(-1, 'RemoveRegTweak18_2')
		GUICtrlCreateMenuItem('快速访问显示最近文件', $MCheckBox18)
		GUICtrlSetOnEvent(-1, 'RemoveRegTweak18_3')
	Else
		$Checkbox[17] = _GUICtrlCreateCheckbox("允许管理员使用Metro应用", 432, 136, 169, 17)
		GUICtrlSetTip(-1, '默认情况下，管理员账户Administrator不能使用Metro应用', '说明', 1)
		$Checkbox[18] = _GUICtrlCreateCheckbox("开机直接进入桌面", 432, 160, 169, 17)
	EndIf
Else
	;Windows8之前系列系统
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
		$Checkbox[17] = _GUICtrlCreateCheckbox("自动登录(Windows2008)", 432, 136, 169, 17)
		GUICtrlSetTip(-1, '仅对windows2008以及windows2008R2系统系统' & @LF & '可用！如果您不是这个系列的系统，请勿选中！', '警告', 2)
	Else
		If @OSBuild > 6000 Then
			$Checkbox[17] = _GUICtrlCreateCheckbox("右键集成上帝模式菜单", 432, 136, 169, 17)
			GUICtrlSetTip(-1, '在计算机右键菜单上显示上帝模式！', '提示', 1)
			$MCheckBox17 = GUICtrlCreateContextMenu($Checkbox[17])
			GUICtrlCreateMenuItem('移除"上帝模式"右键菜单', $MCheckBox17)
			GUICtrlSetOnEvent(-1, 'RemoveRegTweak17')
		Else
			$Checkbox[17] = _GUICtrlCreateCheckbox("彻底关闭Dr Watson", 432, 136, 169, 17)
			GUICtrlSetTip(-1, '鸡肋的功能，作用不大，推荐勾选进行关闭。', '提示', 1)
		EndIf
	EndIf
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
		$Checkbox[18] = _GUICtrlCreateCheckbox("去除系统密码策略限制", 432, 160, 169, 17)
		GUICtrlSetTip(-1, '去除原有服务器版本系统的密码策略限制，包括' & @LF & '#密码复杂度和长度' & @LF & '#密码过期时间' & @LF & '#登录后必须更改密码', '提示', 1)
	Else
		$Checkbox[18] = _GUICtrlCreateCheckbox("清理显卡右键菜单", 432, 160, 169, 17)
		GUICtrlSetTip(-1, '清理显卡右键菜单', '提示', 1)
	EndIf
EndIf
If @OSVersion <> 'WIN_2008R2' And @OSVersion <> 'WIN_2008' And @OSVersion <> 'WIN_2003' Then
	$Checkbox[19] = _GUICtrlCreateCheckbox("不为弹出的USB设备供电", 432, 184, 169, 17)
	GUICtrlSetTip(-1, 'USB设备从系统中弹出后,系统' & @LF & '将不再为设备进行供电！', '提示', 1)
	$MCheckBox19 = GUICtrlCreateContextMenu($Checkbox[19])
	GUICtrlCreateMenuItem('为弹出的USB设备继续供电', $MCheckBox19)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak19')
Else
	$Checkbox[19] = _GUICtrlCreateCheckbox("禁用登录需要按Ctrl+Alt+Del", 432, 184, 169, 17)
	GUICtrlSetTip(-1, '无需按Ctrl+Alt+Del再进行登录，非服务器版' & @LF & '本系统请慎用该选项！', '警告', 2)
EndIf
If @OSBuild > 21900 Then
	$Checkbox[20] = _GUICtrlCreateCheckbox("开始菜单使用磁贴", 432, 208, 169, 17)
	$MCheckBox20 = GUICtrlCreateContextMenu($Checkbox[20])
	GUICtrlCreateMenuItem('使用新版本开始菜单', $MCheckBox20)
	GUICtrlSetOnEvent(-1, 'RestoreWin11NewStartMenu')
Else
	$Checkbox[20] = _GUICtrlCreateCheckbox("IE综合优化选项", 432, 208, 169, 17)
EndIf
GUICtrlSetTip(-1, '对IE进行性能及使用习惯上的综合优化', '说明', 1)
If @OSBuild > 6000 Then
	$Checkbox[21] = _GUICtrlCreateCheckbox("关闭系统开机声音", 432, 232, 169, 17)
	GUICtrlSetTip(-1, '关闭开机进入系统时的声音', '说明', 1)
	$MCheckBox21 = GUICtrlCreateContextMenu($Checkbox[21])
	GUICtrlCreateMenuItem('开启系统开机声音', $MCheckBox21)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak21')
Else
	$Checkbox[21] = _GUICtrlCreateCheckbox("关闭分组相似任务栏按钮", 432, 232, 169, 17)
	GUICtrlSetTip(-1, '关闭分组相似任务栏按钮', '说明', 1)
	$MCheckBox21 = GUICtrlCreateContextMenu($Checkbox[21])
	GUICtrlCreateMenuItem('开启分组相似任务栏按钮', $MCheckBox21)
	GUICtrlSetOnEvent(-1, 'RemoveRegTweak21')
EndIf
GUICtrlCreateGroup("便捷选择", 432, 255, 153, 57)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$SelectAllReg = _GUICtrlCreateRadio("全选", 448, 279, 49, 17)
GUICtrlSetOnEvent($SelectAllReg, 'regall')
$ReverseSelectReg = _GUICtrlCreateRadio("反选", 520, 279, 57, 17)
GUICtrlSetOnEvent($ReverseSelectReg, 'regreverse')
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ApplyRegTweaks = GUICtrlCreateButton("应用设置[&A]", 432, 320, 155, 33)
GUICtrlSetOnEvent($ApplyRegTweaks, 'StartRegTweak')
$TabSheet2 = GUICtrlCreateTabItem("系统常规插件补丁")
$plugins[1] = _GUICtrlCreateCheckbox("使用Notepad2替换系统自带的记事本", 8, 136, 217, 17)
GUICtrlSetTip(-1, 'Notepad2是一款支持多中代码高亮的文本编辑工具，' & @LF & '使用映像劫持技术替换，不删除系统原有记事本。')
$Mnotepad = GUICtrlCreateContextMenu($plugins[1])
GUICtrlCreateMenuItem('移除Notepad2', $Mnotepad)
GUICtrlSetOnEvent(-1, 'RemoveNotePad2')
$plugins[2] = _GUICtrlCreateCheckbox("在资源管理器中使用HashTab", 8, 160, 209, 17)
GUICtrlSetTip(-1, 'HashTab是一款便捷查看文件MD5等文件校验的插件。')
$MHashtab = GUICtrlCreateContextMenu($plugins[2])
GUICtrlCreateMenuItem('移除HashTab插件', $MHashtab)
GUICtrlSetOnEvent(-1, 'RemoveHashTab')
If @OSBuild > 8000 Then
	$plugins[3] = _GUICtrlCreateCheckbox("安装禁用系统更新插件", 8, 184, 157, 17)
	GUICtrlSetTip(-1, '通过Windows Update Disabler Service对系统更新服务进行禁用。')
	$Mupdatedisabler = GUICtrlCreateContextMenu($plugins[3])
	GUICtrlCreateMenuItem('移除禁用系统更新服务插件)', $Mupdatedisabler)
	GUICtrlSetOnEvent(-1, 'Removeupdatedisabler')
Else
	$plugins[3] = _GUICtrlCreateCheckbox("破解系统主题", 8, 184, 97, 17)
	GUICtrlSetTip(-1, '破解系统主题可以使您的计算机支持第三方主题。')
EndIf
If @OSBuild < 6000 Then
	$plugins[4] = _GUICtrlCreateCheckbox("破解系统TCP\IP连接数", 8, 208, 130, 17)
	GUICtrlSetTip(-1, '选中本项，可破解系统TCP\IP连接数为2000的限制。')
Else
	$plugins[4] = _GUICtrlCreateCheckbox("安装摄像头工具", 8, 208, 121, 17)
	GUICtrlSetTip(-1, '选中本项，将在资源管理器创建一个xp风格的摄像头，嘻嘻。')
	$MCamera = GUICtrlCreateContextMenu($plugins[4])
	GUICtrlCreateMenuItem('移除摄像头工具', $MCamera)
	GUICtrlSetOnEvent(-1, 'RemoveCamera')
EndIf
If @OSBuild > 8000 Then
	$plugins[5] = _GUICtrlCreateCheckbox("安装开发者证书", 8, 232, 169, 17)
	GUICtrlSetTip(-1, '安装开发者证书以后，可以允许您使用第三方Metro App应用程序！', '提示', 1)
Else
	If @OSVersion = 'WIN_XP' Then
		$plugins[5] = _GUICtrlCreateCheckbox("WindowsXp4GB内存限制破解补丁", 8, 232, 200, 17)
		GUICtrlSetTip(-1, '通过该补丁，可以使WindowsXp识别4G及以上内存', '提示', 1)
	Else
		If @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008" Then
			$plugins[5] = _GUICtrlCreateCheckbox("Windows2008游戏补丁", 8, 232, 169, 17)
			GUICtrlSetTip(-1, 'windows2008游戏补丁，额，其他的系统不要选中哦', '警告', 2)
		Else
			$plugins[5] = _GUICtrlCreateCheckbox("浏览器搜索引擎增强包", 8, 232, 169, 17)
			GUICtrlSetTip(-1, '常见的IE浏览器搜索引擎集成', '说明', 1)
			$MIESearch = GUICtrlCreateContextMenu($plugins[5])
			GUICtrlCreateMenuItem('移除该插件项目内容', $MIESearch)
			GUICtrlSetOnEvent(-1, 'RemoveIESearch')
			GUICtrlCreateMenuItem('移除所有IE搜索引擎', $MIESearch)
			GUICtrlSetOnEvent(-1, '_ClearAllScope')
		EndIf
	EndIf
EndIf
If @OSBuild < 6000 Then
	$plugins[6] = _GUICtrlCreateCheckbox("绿豆沙护眼配色方案", 8, 256, 123, 17)
	GUICtrlSetTip(-1, '使用该方案，可以有效的保护眼睛，减轻视觉疲劳！', '提示', 1)
Else
	If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
		$plugins[6] = _GUICtrlCreateCheckbox("DirectMusic补丁", 8, 256, 122, 17)
		GUICtrlSetTip(-1, 'windows2008DirectMusic补丁，额，其他的系统不要选中哦', '警告', 2)
	Else
		$plugins[6] = _GUICtrlCreateCheckbox("Flash P2P上传屏蔽补丁", 8, 256, 142, 17)
		GUICtrlSetTip(-1, '选择此补丁可以屏蔽Flash P2P上传！', '提示', 1)
	EndIf
EndIf
$plugins[7] = _GUICtrlCreateCheckbox("Everything搜索工具", 8, 280, 161, 17)
GUICtrlSetTip(-1, 'Everything是一款在windows下可以便捷进行搜索的小工具。推荐安装。')
$MEverything = GUICtrlCreateContextMenu($plugins[7])
GUICtrlCreateMenuItem('移除Everything', $MEverything)
GUICtrlSetOnEvent(-1, 'RemoveEverything')
$plugins[8] = _GUICtrlCreateCheckbox("CBX Shell压缩包缩略图插件", 8, 304, 257, 17)
GUICtrlSetTip(-1, 'CBX Shell可以实现在资源管理器中对压缩文件中的' & @LF & '图片进行预览！安装完成以后记得清理图标缓存哦！')
$MCBX = GUICtrlCreateContextMenu($plugins[8])
GUICtrlCreateMenuItem('移除CBX Shell插件', $MCBX)
GUICtrlSetOnEvent(-1, 'RemoveCBX')
If @OSBuild < 6000 Then
	$plugins[9] = _GUICtrlCreateCheckbox("光驱关闭插件", 8, 328, 169, 17)
	GUICtrlSetTip(-1, '为右键添加"关闭光驱"的菜单')
Else
	If @OSBuild < 8000 Then
		$plugins[9] = _GUICtrlCreateCheckbox("去除桌面水印通用补丁", 8, 328, 169, 17)
		GUICtrlSetTip(-1, '当您的桌面出现水印文字如“内部版本”等，使用本补丁可以移除这些水印文字。')
	Else
		$plugins[9] = _GUICtrlCreateCheckbox("Windows8右键快捷菜单", 8, 328, 169, 17)
		GUICtrlSetTip(-1, '为你系统的右键添上一些常用的快捷键功能。', ' ', 1)
		$Mw8Quick = GUICtrlCreateContextMenu($plugins[9])
		GUICtrlCreateMenuItem('移除Windows8右键快捷菜单', $Mw8Quick)
		GUICtrlSetOnEvent(-1, 'RemoveW8Quick')
	EndIf
EndIf
$plugins[10] = _GUICtrlCreateCheckbox("Reg2inf右键菜单", 272, 136, 195, 17)
GUICtrlSetTip(-1, '为注册表文件添加"转换为inf文件"右键菜单')
$Mreg2inf = GUICtrlCreateContextMenu($plugins[10])
GUICtrlCreateMenuItem('移除Reg2inf右键菜单', $Mreg2inf)
GUICtrlSetOnEvent(-1, 'RemoveReg2inf')
$plugins[11] = _GUICtrlCreateCheckbox("CCleaner系统清理工具", 272, 160, 169, 17)
GUICtrlSetTip(-1, '一款不错的集系统垃圾、注册表清理和软件卸载的小软件。')
$MCC = GUICtrlCreateContextMenu($plugins[11])
GUICtrlCreateMenuItem('移除CCleaner系统清理工具', $MCC)
GUICtrlSetOnEvent(-1, 'RemoveCC')
$plugins[12] = _GUICtrlCreateCheckbox("右键添加VHD文件相关操作菜单", 272, 184, 207, 17)
GUICtrlSetTip(-1, '添加.VHD后缀文件的"分离"、"挂载"操作' & @LF & '菜单到右键')
$MVHD = GUICtrlCreateContextMenu($plugins[12])
GUICtrlCreateMenuItem('移除VHD菜单项目', $MVHD)
GUICtrlSetOnEvent(-1, 'RemoveVHD')
$plugins[13] = _GUICtrlCreateCheckbox("安装Unlocker文件删除工具", 272, 208, 175, 17)
GUICtrlSetTip(-1, '文件强制删除工具，删除你无权删除的文件，文件解锁，' & @LF & '嘻嘻，强大的unlocker！')
$Munlocker = GUICtrlCreateContextMenu($plugins[13])
GUICtrlCreateMenuItem('移除Unlocker', $Munlocker)
GUICtrlSetOnEvent(-1, 'RemoveUnlocker')
If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
	$plugins[14] = _GUICtrlCreateCheckbox("WindowsServerXbox支持补丁", 272, 232, 185, 17)
	GUICtrlSetTip(-1, '为服务器版系统添加Xbox的支持!')
Else
	$plugins[14] = _GUICtrlCreateCheckbox("显示/隐藏系统文件+扩展名", 272, 232, 185, 17)
	GUICtrlSetTip(-1, '为你系统的右键添上“显示/隐藏系统文件+扩展名”菜单。', ' ', 1)
	$MSuperHide = GUICtrlCreateContextMenu($plugins[14])
	GUICtrlCreateMenuItem('移除“显示/隐藏系统文件+扩展名”', $MSuperHide)
	GUICtrlSetOnEvent(-1, 'RemoveSuperHide')
EndIf
GUICtrlCreateGroup("便捷选择", 434, 247, 153, 57)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$SelectAllPlugins = _GUICtrlCreateRadio("全选", 450, 271, 49, 17)
GUICtrlSetOnEvent($SelectAllPlugins, 'Pluginsall')
$PluginsReverseSelect = _GUICtrlCreateRadio("反选", 522, 271, 57, 17)
GUICtrlSetOnEvent($PluginsReverseSelect, 'Pluginsreverse')
GUICtrlCreateGroup("", -99, -99, 1, 1)
$InsSlectedPlugins = GUICtrlCreateButton("安装已选中插件[&I]", 432, 312, 155, 33)
GUICtrlSetOnEvent($InsSlectedPlugins, 'pluginsTweaks')
$TabSheet3 = GUICtrlCreateTabItem("系统个性定制")
GUICtrlCreateGroup("更改用户名和计算机名", 8, 256, 473, 100)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
GUICtrlCreateLabel("计算机用户名：", 32, 275, 90, 17)
$ComboUserList = GUICtrlCreateCombo('', 122, 272, 156, 17, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetOnEvent(-1, '_loadUserNameToEdit')
$Mcpwd = GUICtrlCreateContextMenu($ComboUserList)
GUICtrlCreateMenuItem('更改此用户密码', $Mcpwd)
GUICtrlSetOnEvent(-1, 'ChangeSingleUserPassword')
GUICtrlCreateMenuItem('更改此用户描述', $Mcpwd)
GUICtrlSetOnEvent(-1, 'ChangeUserDescDlg')
GUICtrlCreateMenuItem('统一设置列表用户密码', $Mcpwd)
GUICtrlSetOnEvent(-1, 'ChangeListUserPassword')
GUICtrlCreateLabel("用户描述:", 32, 295, 75, 17)
$UserDesc = GUICtrlCreateLabel("", 110, 295, 188, 17)
GUICtrlSetFont(-1, 8, -1, 0, "微软雅黑")
$ChangeUserFullNameOnly = GUICtrlCreateCheckbox("用户名仅修改全名", 288, 290, 130, 17)
GUICtrlCreateLabel("当前计算机名:" & @ComputerName, 32, 314, 234, 17)
GUICtrlCreateLabel("当前工作组:" & $orgGroupName, 32, 338, 234, 17)
GUICtrlCreateLabel("修改为：", 288, 272, 52, 17)
GUICtrlCreateLabel("修改为：", 288, 314, 52, 17)
GUICtrlCreateLabel("修改为：", 288, 338, 52, 17)
$NewUserName = GUICtrlCreateInput('', 344, 272, 121, 18)
$hInput[0] = GUICtrlGetHandle($NewUserName)
$NewPcName = GUICtrlCreateInput(@ComputerName, 344, 310, 121, 18)
$hInput[1] = GUICtrlGetHandle($NewPcName)
$NewGroupName = GUICtrlCreateInput($orgGroupName, 344, 332, 121, 18)
$hInput[2] = GUICtrlGetHandle($NewGroupName)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("计算机所有者信息", 8, 128, 565, 121)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
GUICtrlCreateLabel("计算机制造商：", 24, 148, 88, 17)
$PcProdutor = GUICtrlCreateInput("", 112, 144, 121, 21)
$hInput[3] = GUICtrlGetHandle($PcProdutor)
GUICtrlCreateLabel("计算机型号：", 24, 168, 76, 17)
$PcXh = GUICtrlCreateInput("", 112, 168, 121, 21)
$hInput[4] = GUICtrlGetHandle($PcXh)
GUICtrlCreateLabel("技术支持时间：", 24, 192, 88, 17)
$TechHour = GUICtrlCreateInput("", 112, 192, 121, 21)
$hInput[5] = GUICtrlGetHandle($TechHour)
GUICtrlCreateLabel("技术支持电话：", 24, 216, 88, 17)
$TechPhone = GUICtrlCreateInput("", 112, 216, 121, 21)
$hInput[6] = GUICtrlGetHandle($TechPhone)
GUICtrlCreateLabel("技术支持网址：", 248, 144, 88, 17)
$SptSite = GUICtrlCreateInput("", 344, 141, 121, 21)
$hInput[7] = GUICtrlGetHandle($SptSite)
GUICtrlCreateLabel("OEM图片：", 248, 168, 64, 17)
$OemLogo = GUICtrlCreateInput("", 344, 168, 121, 21)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$hInput[8] = GUICtrlGetHandle($OemLogo)
GUICtrlCreateLabel("注册组织：", 248, 192, 64, 17)
$RegOrg = GUICtrlCreateInput("", 344, 192, 121, 21)
$hInput[9] = GUICtrlGetHandle($RegOrg)
GUICtrlCreateLabel("注册人：", 253, 216, 52, 17)
$RegUser = GUICtrlCreateInput("", 344, 216, 121, 21)
$hInput[10] = GUICtrlGetHandle($RegUser)
GUICtrlCreateButton("浏览", 472, 169, 35, 20)
GUICtrlSetOnEvent(-1, 'Selectoemlogo')
GUICtrlCreateButton("预览", 512, 169, 53, 20)
GUICtrlSetOnEvent(-1, 'previewOemlogo')
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("预设品牌", 471, 135, 95, 27)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$PreOEMList = GUICtrlCreateCombo("当前品牌", 473, 147, 91, 23, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_HSCROLL))
Local $oemstring = '联 想|联 想（新）|联 想（新1）|微 星|海 尔|宏 碁|三 星|惠 普|惠 普（新）|戴 尔|戴 尔（新）|华 硕|明 基|方 正|同 方|东 芝|康 柏|富士通|LG电子|SONY|NEC|ThinkPad|IBM（三色标）|IBM（灰色）|ALIENWARE|Gateway|Terrans Force|Surface|VMWARE|VirtualBox'
If StringInStr($PcType, 'X62') Then
	$oemstring = 'X62|' & $oemstring
EndIf
GUICtrlSetData(-1, $oemstring, "")
GUICtrlSetOnEvent(-1, 'LoadPreOEM')
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateButton("登录界面设置", 473, 190, 91, 24)
If @OSBuild < 6000 Then GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlSetOnEvent(-1, '_SetBckDlg')
$ApplyPersonlize = GUICtrlCreateButton("应用设置[&A]", 488, 264, 95, 35)
GUICtrlSetOnEvent(-1, 'setpcinfo')
preLoadOemInfo()
$TabSheet4 = GUICtrlCreateTabItem("系统服务及功能设置")
GUICtrlCreateGroup("WindowsServer2008&&R2设置选项", 8, 136, 593, 129)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$svc[1] = _GUICtrlCreateCheckbox("开启音频服务", 16, 160, 97, 17)
$svc[2] = _GUICtrlCreateCheckbox("开启主题服务", 16, 184, 97, 17)
$svc[3] = _GUICtrlCreateCheckbox("启用搜索服务", 16, 208, 97, 17)
$svc[4] = _GUICtrlCreateCheckbox("启用缩略图", 16, 232, 97, 17)
$svc[5] = _GUICtrlCreateCheckbox("开启SuperFetch", 136, 160, 102, 17)
GUICtrlCreateGroup("便捷选择", 436, 156, 153, 57)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$SelectAllSvc = _GUICtrlCreateRadio("全选", 452, 180, 49, 17)
GUICtrlSetOnEvent($SelectAllSvc, 'svcall')
$ReverseSlectSvc = _GUICtrlCreateRadio("反选", 524, 180, 57, 17)
GUICtrlSetOnEvent($ReverseSlectSvc, 'svcreverse')
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Apply2k8SvcTweaks = GUICtrlCreateButton("应用设置[&A]", 440, 216, 155, 33)
If @OSBuild < 6000 Then GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent($Apply2k8SvcTweaks, 'Win08ServiceTweaks')
$svc[6] = _GUICtrlCreateCheckbox("启用系统桌面体验服务", 136, 184, 150, 17)
$Msvc6 = GUICtrlCreateContextMenu($svc[6])
GUICtrlCreateMenuItem('禁用桌面体验服务', $Msvc6)
GUICtrlSetOnEvent(-1, 'DisableDesktopExp')
$svc[7] = _GUICtrlCreateCheckbox("提高windows2008兼容性", 136, 208, 160, 17)
$svc[8] = _GUICtrlCreateCheckbox("开启Aero透明效果", 136, 232, 153, 17)
$svc[9] = _GUICtrlCreateCheckbox("启用网络打印机支持", 295, 160, 140, 17)
$Msvc9 = GUICtrlCreateContextMenu($svc[9])
GUICtrlCreateMenuItem('禁用网络打印机支持', $Msvc9)
GUICtrlSetOnEvent(-1, 'DisableNetPrinterSpt')
$svc[10] = _GUICtrlCreateCheckbox("启用无线功能", 295, 184, 120, 17)
$Msvc10 = GUICtrlCreateContextMenu($svc[10])
GUICtrlCreateMenuItem('禁用无线功能', $Msvc10)
GUICtrlSetOnEvent(-1, 'DisableWireless')
$svc[11] = _GUICtrlCreateCheckbox("启用Telnet客户端", 295, 208, 120, 17)
$Msvc11 = GUICtrlCreateContextMenu($svc[11])
GUICtrlCreateMenuItem('禁用Telnet客户端', $Msvc11)
GUICtrlSetOnEvent(-1, 'DisableTelnetCilent')
$svc[12] = _GUICtrlCreateCheckbox("启用NetFramework3.5", 295, 232, 145, 17)
$Msvc12 = GUICtrlCreateContextMenu($svc[12])
GUICtrlCreateMenuItem('禁用NetFramework3.5', $Msvc12)
GUICtrlSetOnEvent(-1, 'DisableNetframe35')
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Windows服务优化选项", 7, 271, 249, 50)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$w7ServiceList = GUICtrlCreateCombo("系统默认服务方案", 23, 290, 153, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "家用服务优化方案|极速服务优化方案|个人&网吧服务优化方案")
$ApplyServiceTweak = GUICtrlCreateButton("应用设置", 183, 289, 59, 25)
GUICtrlSetOnEvent(-1, 'windowsServiceTweaks')
GUICtrlSetTip(-1, '应用所选服务优化方案，在此按钮' & @LF & '上点击右键菜单可以对当前系统服' & @LF & '务状态进行备份~~', '提示', 1)
$MService = GUICtrlCreateContextMenu($ApplyServiceTweak)
GUICtrlCreateMenuItem('备份当前系统服务为批处理', $MService)
GUICtrlSetOnEvent(-1, '_BackUPServiceToBat')
GUICtrlCreateLabel(" 设置主页为", 9, 331, 70, 17)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$HomePage = GUICtrlCreateCombo("about:blank", 80, 330, 121, 17, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "http://www.baidu.com|http://www.google.com|http://www.so.com")
GUICtrlCreateButton("确定", 203, 330, 56, 20)
GUICtrlSetOnEvent(-1, '_SetHomePage')
GUICtrlCreateGroup("Windows激活", 280, 272, 121, 73)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
GUICtrlCreateButton("BIOS", 285, 315, 55, 25)
GUICtrlSetTip(-1, 'OEM计算机证书、bios等的备份！', '说明', 1)
GUICtrlSetOnEvent(-1, '_BiosTool')
GUICtrlCreateButton("UEFI", 341, 315, 55, 25)
GUICtrlSetTip(-1, 'UEFI激活支持！', '说明', 1)
GUICtrlSetOnEvent(-1, '_UEFIActor')
$kmsvlbtn = GUICtrlCreateButton("HWIDGen", 285, 286, 55, 25)
GUICtrlSetTip(-1, '传说中的HWIDGen全能' & @LF & '激活工具..', '说明', 1)
GUICtrlSetOnEvent(-1, 'KMSVLALL')
$KMS8 = GUICtrlCreateButton("KMS10", 340, 286, 55, 25)
GUICtrlSetTip(-1, '小马最新的激活工具。超强版本的系统支持' & @LF & '更加稳定、兼容性更好！' & @LF & '', '说明', 1)
GUICtrlSetOnEvent(-1, 'KMS10')
If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Or @OSVersion = "WIN_8" Then
	$MreadOEMKEY = GUICtrlCreateContextMenu($KMS8)
	GUICtrlCreateMenuItem('读取系统密匙信息', $MreadOEMKEY)
	GUICtrlSetOnEvent(-1, 'ReadOEMKEY')
EndIf
GUICtrlCreateGroup("网络设置及功能", 420, 272, 180, 73)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
GUICtrlCreateButton("&IP地址设置", 425, 286, 80, 25)
GUICtrlSetTip(-1, '设置计算机IP及DNS' & @LF & '信息！！', '说明', 1)
GUICtrlSetOnEvent(-1, 'IpSetDlg')
GUICtrlCreateButton("&MAC修改及绑定", 510, 286, 86, 25)
GUICtrlSetTip(-1, '修改计算机网卡MAC' & @LF & '地址及地址绑定！', '说明', 1)
GUICtrlSetOnEvent(-1, 'MacChangeDlg')
GUICtrlCreateButton("创建&Wifi热点", 425, 316, 80, 25)
GUICtrlSetTip(-1, '共享本机Wifi供' & @LF & '其他设备使用！', '说明', 1)
If @OSBuild < 6000 Then GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, 'CreateWifiDlg')
GUICtrlCreateButton("网络唤醒", 510, 316, 86, 25)
GUICtrlSetTip(-1, '根据提供的MAC地址，网络' & @LF & '唤醒计算机！', '说明', 1)
GUICtrlSetOnEvent(-1, 'WOLUI')
If $HasSSD Then
	$TabSheet7 = GUICtrlCreateTabItem("SSD优化")
	$SSDbox[1] = _GUICtrlCreateCheckbox("关闭SSD节能功能", 8, 136, 140, 17)
	GUICtrlSetTip(-1, '关闭节能功能，可以提高SSD的效率，推荐选中！', '说明', 1)
	$SSDbox[2] = _GUICtrlCreateCheckbox("关闭预读取", 8, 160, 145, 17)
	GUICtrlSetTip(-1, '关闭预读可以减少SSD的读写，提高SSD的寿命', '说明', 1)
	$SSDbox[3] = _GUICtrlCreateCheckbox("关闭启动跟踪", 8, 184, 129, 17)
	GUICtrlSetTip(-1, '关闭一个叫BootTrace的玩意儿！', '说明', 1)
	$MBoottrace = GUICtrlCreateContextMenu($SSDbox[3])
	GUICtrlCreateMenuItem('开启启动跟踪', $MBoottrace)
	GUICtrlSetOnEvent(-1, 'TurnOnBoottrace')
	$SSDbox[4] = _GUICtrlCreateCheckbox("关闭系统盘NTFS Journal", 8, 208, 153, 17)
	GUICtrlSetTip(-1, '关闭系统盘NTFS Journal', '说明', 1)
	$SSDbox[5] = _GUICtrlCreateCheckbox("启动时不整理磁盘", 8, 232, 153, 17)
	GUICtrlSetTip(-1, '关闭系统启动时的磁盘整理', '说明', 1)
	$MBootchkDisk = GUICtrlCreateContextMenu($SSDbox[5])
	GUICtrlCreateMenuItem('设置启动时整理磁盘', $MBootchkDisk)
	GUICtrlSetOnEvent(-1, 'TurnOncheckdiskOnBoot')
	$SSDbox[6] = _GUICtrlCreateCheckbox("去除Feedbacktool", 8, 256, 153, 17)
	GUICtrlSetTip(-1, '移除Feedbacktool', '说明', 1)
	$SSDbox[7] = _GUICtrlCreateCheckbox("关闭系统还原功能", 168, 136, 153, 17)
	GUICtrlSetTip(-1, '关闭系统自带的系统还原功能', '说明', 1)
	$MsysRestroe = GUICtrlCreateContextMenu($SSDbox[7])
	GUICtrlCreateMenuItem('开启系统还原功能', $MsysRestroe)
	GUICtrlSetOnEvent(-1, 'turnOnsysRestore')
	$SSDbox[8] = _GUICtrlCreateCheckbox("关闭系统休眠功能", 168, 160, 153, 17)
	GUICtrlSetTip(-1, '关闭系统的休眠功能', '说明', 1)
	$MsysHy = GUICtrlCreateContextMenu($SSDbox[8])
	GUICtrlCreateMenuItem('开启系统休眠功能', $MsysHy)
	GUICtrlSetOnEvent(-1, 'TurnOnSysHy')
	$SSDbox[9] = _GUICtrlCreateCheckbox("关闭文件最后访问时间", 168, 184, 153, 17)
	$MLastacess = GUICtrlCreateContextMenu($SSDbox[9])
	GUICtrlCreateMenuItem('开启文件最后访问时间', $MLastacess)
	GUICtrlSetOnEvent(-1, 'TurnOnLastAccess')
	$SSDbox[10] = _GUICtrlCreateCheckbox("关闭DOS8.3 文件名支持 ", 168, 208, 153, 17)
	$MDOS83 = GUICtrlCreateContextMenu($SSDbox[10])
	GUICtrlCreateMenuItem('启用DOS8.3 文件名支持', $MDOS83)
	GUICtrlSetOnEvent(-1, 'TurnOnDos83')
	$SSDbox[11] = _GUICtrlCreateCheckbox("关闭WindowsSearch ", 168, 232, 153, 17)
	GUICtrlSetTip(-1, '使用outlook的用户不建议勾选', '说明', 1)
	$MWinSearch = GUICtrlCreateContextMenu($SSDbox[11])
	GUICtrlCreateMenuItem('启用WindowsSearch服务', $MWinSearch)
	GUICtrlSetOnEvent(-1, 'TurnOnWinsearch')
	$SSDbox[12] = _GUICtrlCreateCheckbox("关机时不清空页面文件 ", 168, 256, 153, 17)
	GUICtrlSetTip(-1, '此选项可以加快关机速度，推荐选中', '说明', 1)
	$MClearPF = GUICtrlCreateContextMenu($SSDbox[12])
	GUICtrlCreateMenuItem('设置关机时清空页面文件', $MClearPF)
	GUICtrlSetOnEvent(-1, 'ClearPFileOnOff')
	$SSDbox[13] = _GUICtrlCreateCheckbox("设置当前系统无GUI引导", 328, 136, 153, 17)
	GUICtrlSetTip(-1, '开启该选项后将没有系统的启动界' & @LF & '面，可以使开机时间快1~2秒', '说明', 1)
	$MBootGUI = GUICtrlCreateContextMenu($SSDbox[13])
	GUICtrlCreateMenuItem('还原系统为GUI引导', $MBootGUI)
	GUICtrlSetOnEvent(-1, 'EnGUIBoot')
	$SSDbox[14] = _GUICtrlCreateCheckbox("关闭磁盘碎片整理服务", 328, 160, 153, 17)
	GUICtrlSetTip(-1, 'Windows7系统会自动识别SSD而不自动启动该服务，如果' & @LF & '您的系统中该服务是在运行的，建议勾选该选项', '说明', 1)
	$Mdefrag = GUICtrlCreateContextMenu($SSDbox[14])
	GUICtrlCreateMenuItem('开启磁盘碎片整理服务', $Mdefrag)
	GUICtrlSetOnEvent(-1, 'TurnOndefrag')
	GUICtrlCreateGroup("便捷选择", 8, 280, 153, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$SelectAllSSD = _GUICtrlCreateRadio("全选", 18, 306, 49, 17)
	GUICtrlSetOnEvent($SelectAllSSD, 'ssdall')
	$ReverseSelectSSD = _GUICtrlCreateRadio("反选", 100, 306, 57, 17)
	GUICtrlSetOnEvent($ReverseSelectSSD, 'ssdreverse')
	GUICtrlCreateButton("应用设置[&A]", 440, 285, 155, 40)
	GUICtrlSetOnEvent(-1, 'SSDTweaksApply')
EndIf
;=============淫荡的分割线
$TabSheet5 = GUICtrlCreateTabItem("个人资料转移")
GUICtrlCreateGroup("个人资料转移", 8, 127, 593, 225)
$TreeView = GUICtrlCreateTreeView(10, 152, 588, 145, BitOR($GUI_SS_DEFAULT_TREEVIEW, $TVS_CHECKBOXES, $LVS_ICON, $WS_BORDER))
GUICtrlSetResizing(-1, $GUI_DOCKLEFT)
#cs
	当前用户桌面
	收藏夹
	音乐 {4BD8D571-6D19-48D3-BE97-422220080E43}
	图片 {33E28130-4E1E-4676-835A-98395C3BC3BB}
	视频 {18989B1D-99B5-455B-841C-AB7C74E4DDFC}
	文档 {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
	下载 {374DE290-123F-4565-9164-39C4925E467B}
	IE缓存 {352481E8-33BE-4251-BA85-6007CAEDCF9D}
	IE的Cookie {2B0F765D-C0E9-4171-908E-08A611B84FF6}
	历史记录 {D9DC8A3B-B784-432E-A781-5A1130A75963}
	网上邻居 {C5ABBF53-E17F-4121-8900-86626FC2C973}
	发送到 {8983036C-27C0-404B-8F08-102D10DCFD74}
	启动
	模版 {B94237E7-57AC-4347-9151-B08C6C32D1F7}
	网络打印机 {9274BD8D-CFD1-41C3-B35E-B13F55A758F4}
	$DirDownload=_WinAPI_ShellGetKnownFolderPath('{C5ABBF53-E17F-4121-8900-86626FC2C973}')
	MsgBox(0,'',$DirDownload)
#ce
;定义一个数组用于存放TreeView创建所需数据
;数组说明
;0显示名称
;1当前路径
;2注册表键值
;3默认路径字符串
Local $aDataTreeView[15][4]
$aDataTreeView[0][0] = '当前用户桌面'
$aDataTreeView[0][1] = @DesktopDir
$aDataTreeView[0][2] = 'Desktop'
$aDataTreeView[0][3] = '%USERPROFILE%\Desktop'
$aDataTreeView[1][0] = '收藏夹'
$aDataTreeView[1][1] = @FavoritesDir
$aDataTreeView[1][2] = 'Favorites'
$aDataTreeView[1][3] = '%USERPROFILE%\Favorites'
$aDataTreeView[2][0] = '音乐'
$aDataTreeView[2][1] = _WinAPI_ShellGetKnownFolderPath('{4BD8D571-6D19-48D3-BE97-422220080E43}')
$aDataTreeView[2][2] = 'My Music'
$aDataTreeView[2][3] = '%USERPROFILE%\Music'
$aDataTreeView[3][0] = '图片'
$aDataTreeView[3][1] = _WinAPI_ShellGetKnownFolderPath('{33E28130-4E1E-4676-835A-98395C3BC3BB}')
$aDataTreeView[3][2] = 'My Pictures'
$aDataTreeView[3][3] = '%USERPROFILE%\Pictures'
$aDataTreeView[4][0] = '视频'
$aDataTreeView[4][1] = _WinAPI_ShellGetKnownFolderPath('{18989B1D-99B5-455B-841C-AB7C74E4DDFC}')
$aDataTreeView[4][2] = 'My Video'
$aDataTreeView[4][3] = '%USERPROFILE%\Videos'
$aDataTreeView[5][0] = '文档'
$aDataTreeView[5][1] = _WinAPI_ShellGetKnownFolderPath('{FDD39AD0-238F-46AF-ADB4-6C85480369C7}')
$aDataTreeView[5][2] = 'Personal'
$aDataTreeView[5][3] = '%USERPROFILE%\Documents'
$aDataTreeView[6][0] = '下载'
$aDataTreeView[6][1] = _WinAPI_ShellGetKnownFolderPath('{374DE290-123F-4565-9164-39C4925E467B}')
$aDataTreeView[6][2] = '{374DE290-123F-4565-9164-39C4925E467B}'
$aDataTreeView[6][3] = '%USERPROFILE%\Downloads'
$aDataTreeView[7][0] = 'IE缓存'
$aDataTreeView[7][1] = _WinAPI_ShellGetKnownFolderPath('{352481E8-33BE-4251-BA85-6007CAEDCF9D}')
$aDataTreeView[7][2] = 'Cache'
$aDataTreeView[7][3] = '%USERPROFILE%\AppData\Local\Microsoft\Windows\Temporary Internet Files'
$aDataTreeView[8][0] = 'IE的Cookie'
$aDataTreeView[8][1] = _WinAPI_ShellGetKnownFolderPath('{2B0F765D-C0E9-4171-908E-08A611B84FF6}')
$aDataTreeView[8][2] = 'Cookies'
$aDataTreeView[8][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Cookies'
$aDataTreeView[9][0] = '历史记录'
$aDataTreeView[9][1] = _WinAPI_ShellGetKnownFolderPath('{D9DC8A3B-B784-432E-A781-5A1130A75963}')
$aDataTreeView[9][2] = 'History'
$aDataTreeView[9][3] = '%USERPROFILE%\AppData\Local\Microsoft\Windows\History'
$aDataTreeView[10][0] = '网上邻居'
$aDataTreeView[10][1] = _WinAPI_ShellGetKnownFolderPath('{C5ABBF53-E17F-4121-8900-86626FC2C973}')
$aDataTreeView[10][2] = 'NetHood'
$aDataTreeView[10][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Network Shortcuts'
$aDataTreeView[11][0] = '发送到'
$aDataTreeView[11][1] = _WinAPI_ShellGetKnownFolderPath('{8983036C-27C0-404B-8F08-102D10DCFD74}')
$aDataTreeView[11][2] = 'SendTo'
$aDataTreeView[11][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\SendTo'
$aDataTreeView[12][0] = '启动'
$aDataTreeView[12][1] = @StartupDir
$aDataTreeView[12][2] = 'Startup'
$aDataTreeView[12][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
$aDataTreeView[13][0] = '模版'
$aDataTreeView[13][1] = _WinAPI_ShellGetKnownFolderPath('{B94237E7-57AC-4347-9151-B08C6C32D1F7}')
$aDataTreeView[13][2] = 'Templates'
$aDataTreeView[13][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Templates'
$aDataTreeView[14][0] = '网络打印机'
$aDataTreeView[14][1] = _WinAPI_ShellGetKnownFolderPath('{9274BD8D-CFD1-41C3-B35E-B13F55A758F4}')
$aDataTreeView[14][2] = 'PrintHood'
$aDataTreeView[14][3] = '%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Printer Shortcuts'
For $itv = 0 To UBound($aDataTreeView) - 1
	$aTreeView[$itv * 3] = GUICtrlCreateTreeViewItem($aDataTreeView[$itv][0], $TreeView)
	$aTreeView[$itv * 3 + 1] = GUICtrlCreateTreeViewItem($aDataTreeView[$itv][1], $aTreeView[$itv * 3])
	$aTreeView[$itv * 3 + 2] = GUICtrlCreateTreeViewItem($aDataTreeView[$itv][1], $aTreeView[$itv * 3])
Next
GUICtrlCreateGroup("快速选择目标位置", 190, 300, 132, 40)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$TargetDrive = GUICtrlCreateCombo("选择目标盘符或路径", 195, 315, 124, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetOnEvent(-1, 'QuickSetDrive')
$ExcuteTask = GUICtrlCreateButton("执行操作[&T]", 350, 310, 131, 30)
GUICtrlSetOnEvent($ExcuteTask, 'TransDir')
$MTRandata = GUICtrlCreateContextMenu($ExcuteTask)
GUICtrlCreateMenuItem('恢复选定项系统默认值', $MTRandata)
GUICtrlSetOnEvent(-1, 'RestoreDefaultOpt')
;文件夹内文件相关处理选项
GUICtrlCreateGroup("源文件夹内文件处理", 12, 300, 175, 39)
_removeEffect()
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
$optFileCopy = GUICtrlCreateRadio("复制", 24, 315, 52, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$optFileMove = GUICtrlCreateRadio("移动", 76, 315, 52, 17)
$optFileNop = GUICtrlCreateRadio("不处理", 128, 315, 52, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
For $i = 0 To 44
	If Mod($i + 1, 3) = 0 Then
		GUICtrlSetColor($aTreeView[$i], 0x2b95c7)
		_GUICtrlTreeView_SetIcon($TreeView, $aTreeView[$i], @TempDir & '\To.ico')
		;主项目
	ElseIf Mod($i, 3) = 0 Then
		_GUICtrlTreeView_SetIcon($TreeView, $aTreeView[$i], @TempDir & '\Set.ico')
	Else
		GUICtrlSetColor($aTreeView[$i], 0xff0000)
		_GUICtrlTreeView_SetIcon($TreeView, $aTreeView[$i], @TempDir & '\From.ico')
	EndIf
	GUICtrlSetOnEvent($aTreeView[$i], 'ToogleListviewCheck')
Next
$TabSheet6 = GUICtrlCreateTabItem("关于")
GUICtrlCreateLabel("Windows NT6+ 快速设置工具 ", 32, 144, 350, 24)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 12, 800, 0, "微软雅黑")
GUICtrlSetColor(-1, $aGroupBkcolor[$ibkcolor])
If StringInStr($PcType, 'X62') Then
	$x62des = "  X62是51nb专门网论坛上基于ThinkPad X60/X61(s)经典机型进行升级改造的主板项目。X62在保留原有键盘、屏幕及外观经典元素的基础上，采用英特尔酷睿5代平台进行了重大升级，最大支持32GB内存，包含一个USB3.0接口、一个最新的HDMI接口，更多的扩展，更多的便利，是小黑发烧友的最爱。" & @LF & @LF
Else
	$x62des = ""
EndIf
Local $sDes = "   Windows NT6+ 快速设置工具是一个用于快速对系统进行优化设置的小玩意儿，部分优化内容参考了秋无痕的优化程序、自由天空的系统优化方案以及experience的Tiny7优化选项,在此一并感谢！部分破解补丁对于系统可能存在一定风险性，请谨慎选择使用！" & @LF & _
		@LF & " 工具中的SSD节能优化选项自死性不改博客、工具中部分代码参考或直接调用了AutoIt中文论坛及AutoIt官网论坛的一些代码，在此一并予以感谢！" & _
		'<TABLE borderColor=#ef0000 cellSpacing=0 cellPadding=0 width="85%" border=1 ><TBODY><tr><td><font color="#ff000c" size=2><b >程序Logo设计</b></font></td><td><font color="#ff000f" size=2> milo & DTU</font></td></tr>' & @LF & _
		"<tr><td><font color='#EA0000' size=2 ><b >程序设计</b></font></td><td><font color='#EB0000' size=2 >  虫子樱桃</font></td></tr>" & @LF & _
		"<tr><td><font color='#F75000' size=2><b >程序版本</b></font></td><td><font color='#ff3365' size=2> " & $EXEVerson & "</font></td></tr>" & @LF & _
		"<tr><td><font color='#F75000' size=2><b >官方博客</b></font></td><td><font color='#F73200' size=2> " & $UerHome & " </font></td></tr>" & @LF & _
		"</TBODY></TABLE>" & @LF & _
		@LF & " <font color='#921AFF' ><b>版权所有&copy; 2013-" & @YEAR & " 虫子樱桃. 保留所有权利。</b></font>"
_ScrollingCredits($x62des & $sDes, 40, 170, 291, 170, '')
GUICtrlCreateTabItem("")
GUICtrlCreateLabel(RemoveDuplicateStr($PcType), 58, 362, 344, 20)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
If $IdentifyingNumber <> '' Then GUICtrlSetTip(-1, '主机认证编号:' & $IdentifyingNumber, '附加信息', 1, 2)
GUICtrlSetFont(-1, 10, 600, 0, "微软雅黑", 4)
GUICtrlSetColor(-1, $aGroupBkcolor[$ibkcolor])
GUICtrlCreatePic("", 8, 363, 50, 16)
GUICtrlSetImage(-1, $iComputerType)
GUICtrlCreatePic("", 8, 381, 50, 16)
GUICtrlSetImage(-1, $iBootType)
GUICtrlCreateLabel(StringReplace($osfullversion, '(R)', ''), 58, 380, 344, 20)
GUICtrlSetTip(-1, '系统内部版本号：' & RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'BuildLabEx'), '', 1, 2)
GUICtrlSetFont(-1, 10, 600, 0, "微软雅黑", 4)
GUICtrlSetColor(-1, $aGroupBkcolor[$ibkcolor])
If $UseNetMetr Then
	$Label1 = GUICtrlCreateLabel('', 418, 370, 140, 25)
	GUICtrlSetTip(-1, '系统上传下载流量显示' & @LF & 'DL：下行即时流量' & @LF & 'UL:上行即时流量', '', 1, 2)
	$NetMeterColorId = $ibkcolor + 1 > UBound($aGroupBkcolor) - 1 ? $ibkcolor - 1 : $ibkcolor + 1
	GUICtrlSetColor(-1, $aGroupBkcolor[$NetMeterColorId])
EndIf
getDriveInfo()
_LoadUserNameToArray()
;复选框样式
;注册表优化
_WinAPI_AnimateWindow($Form1, $AW_CENTER, 300)
GUISetState(@SW_SHOW)
FileDelete(@TempDir & '\logo.bmp')
Global $hCallback = DllCallbackRegister("My_InputProc", "int", "hWnd;uint;wparam;lparam")
Global $tCallback = DllCallbackGetPtr($hCallback)
Global $CallProc = _WinAPI_SetWindowLong($hInput[0], -4, $tCallback)
;输入框回调函数
For $i = 1 To UBound($hInput) - 1
	_WinAPI_SetWindowLong($hInput[$i], -4, $tCallback)
Next
GUIRegisterMsg(0x0111, "WM_COMMAND")
GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTool')
GUISetOnEvent($GUI_EVENT_DROPPED, '_DropHandler')
GUIRegisterMsg(0x0011, "EndSessionProc")
GUIRegisterMsg(0x0016, "EndSessionProc")
If $UseNetMetr Then
	Global $hUpdate = DllCallbackRegister('_UpdateStats', 'none', '')
	DllCall('user32.dll', 'int', 'SetTimer', 'hwnd', 0, 'int', 0, 'int', 1000, 'ptr', DllCallbackGetPtr($hUpdate))
	Global $aStart_Values = _GetAllTraffic()
EndIf
While 1
	_WinHideMain()
	Sleep(100)
WEnd

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
;获取用户SID值
Func GetUserSID()
	Local $KeyValue = _Security__LookupAccountName(@UserName)
	Return $KeyValue[0]
EndFunc   ;==>GetUserSID
;获取盘符
Func getDriveInfo()
	Local $adriveFix, $i, $result
	$adriveFix = DriveGetDrive('Fixed')
	For $i In $adriveFix
		If DriveStatus($i) = 'ready' Then
			$result &= StringUpper($i) & '|'
		EndIf
	Next
	$result &= '浏览...'
	GUICtrlSetData($TargetDrive, $result)
EndFunc   ;==>getDriveInfo
;判断当前计算机类型
Func _VMDetect()
	Local $strComputer = ".", $sMake, $sModel, $sBIOSVersion, $bIsVM, $sVMPlatform
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	Local $colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")
	If IsObj($colItems) Then
		For $objItem In $colItems
			$sModel = $objItem.Model
		Next
	EndIf

	$sVMPlatform = ""
	If $sModel = "Virtual Machine" Then
		; Microsoft virtualization technology detected, assign defaults
		$sVMPlatform = "Hyper-V"
		; Try to determine more specific values
		Switch $sBIOSVersion
			Case "VRTUAL - 1000831"
				$sVMPlatform = "Hyper-V 2008 Beta 或 RC0"
			Case "VRTUAL - 5000805", "BIOS Date: 05/05/08 20:35:56  Ver: 08.00.02"
				$sVMPlatform = "Hyper-V 2008 RTM"
			Case "VRTUAL - 3000919"
				$sVMPlatform = "Hyper-V 2008 R2"
			Case "A M I  - 2000622"
				$sVMPlatform = "VS2005R2SP1 或 VPC2007"
			Case "A M I  - 9000520"
				$sVMPlatform = "VS2005R2"
			Case "A M I  - 9000816", "A M I  - 6000901"
				$sVMPlatform = "Windows Virtual PC"
			Case "A M I  - 8000314"
				$bIsVM = True
				$sVMPlatform = "VS2005 或 VPC2004"
		EndSwitch
	ElseIf $sModel = "VMware Virtual Platform" Then
		; VMware detected
		$sVMPlatform = "VMware"
	ElseIf $sModel = "VirtualBox" Then
		; VirtualBox detected
		$sVMPlatform = "VirtualBox"
	Else
	EndIf
	If $sVMPlatform <> '' Then
		Return $sVMPlatform & '虚拟机'
	Else
		Return ''
	EndIf
EndFunc   ;==>_VMDetect
Func DetecPcType()
	If $HasSSD Then
		$iComputerType = @TempDir & '\SSD.bmp'
	Else
		$iComputerType = @TempDir & '\HDD.bmp'
	EndIf
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $Biosinfo = "", $FlagDetail = 0
	Local $strComputer = "localhost"
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT Vendor,Name,Version,IdentifyingNumber FROM Win32_ComputerSystemProduct", "WQL", _
			$wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		For $objItem In $colItems
			If StringInStr(_RemoveWS($objItem.Name), ' ') Then
				$Biosinfo = _CamelStr($objItem.Vendor) & ' ' & _RemoveWS($objItem.Name)
				$FlagDetail = 1
			EndIf
			If StringInStr(_RemoveWS($objItem.Version), ' ') Then
				$Biosinfo = _CamelStr($objItem.Vendor) & ' ' & _RemoveWS($objItem.Version)
				$FlagDetail = 1
			EndIf
			If $FlagDetail = 0 Then
				$Biosinfo = _CamelStr($objItem.Vendor)
			EndIf
			If $objItem.IdentifyingNumber <> '' Then $IdentifyingNumber = $objItem.IdentifyingNumber
		Next
	EndIf
	$colChassis = $objWMIService.ExecQuery('Select * from Win32_SystemEnclosure')
	For $objChassis In $colChassis
		For $strChassisType In $objChassis.ChassisTypes
			;笔记本
			If $strChassisType = 8 Or $strChassisType = 9 Or $strChassisType = 10 Then
				If $Biosinfo <> '' Then
					If StringInStr($Biosinfo, '51nb') Or $Biosinfo == 'Ibm' Then
						$Biosinfo = 'X62 Classic'
					EndIf
					$PcType &= $Biosinfo & "笔记本"
				Else
					$PcType &= "笔记本"
				EndIf
			EndIf
			;台式机
			If $strChassisType = 3 Or $strChassisType = 4 Or $strChassisType = 5 Or $strChassisType = 6 Or $strChassisType = 7 Then
				If $Biosinfo <> '' Then
					$PcType &= $Biosinfo & "台式电脑"
				Else
					$PcType &= "台式电脑"
				EndIf
			EndIf
		Next
	Next
	If $PcType = '' Then
		$PcType = _VMDetect()
		If $PcType = '' Then
			$PcType &= '不明物体'
		EndIf
	EndIf

EndFunc   ;==>DetecPcType

Func _CamelStr($sCamel)
	Local $FirstLeter = StringUpper(StringLeft($sCamel, 1))
	Return $FirstLeter & StringTrimLeft(StringLower($sCamel), 1)
EndFunc   ;==>_CamelStr
Func _RemoveWS($strToWs)
	Return StringStripWS(StringStripWS($strToWs, 2), 1)
EndFunc   ;==>_RemoveWS
Func RemoveDuplicateStr($sToRemove)
	Local $sResult = StringRegExpReplace($sToRemove, '(.*?\s+)\1+', '$1')
	Return $sResult
EndFunc   ;==>RemoveDuplicateStr
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

Func _SetWorkGroupName($sGroupName)
	Local $aRet = DllCall("Netapi32.dll", "long", "NetJoinDomain", "int", 0, "wstr", $sGroupName, "int", 0, "int", 0, "int", 0, "dword", 0x00000040)
	Return $aRet[0]
EndFunc   ;==>_SetWorkGroupName

Func _GetWorkgroupName()
	Local $NERR, $pBuffer, $sName
	Local Const $NetSetupUnknownStatus = 0
	Local Const $NetSetupUnjoined = 1
	Local Const $NetSetupWorkgroupName = 2
	Local Const $NetSetupDomainName = 3

	$NERR = DllCall("Netapi32.dll", "int", "NetGetJoinInformation", "wstr", @ComputerName, "ptr*", 0, "int*", 0)

	If @error Then Return SetError(@error, @extended, "")
	If $NERR[0] = 0 Then
		$pBuffer = $NERR[2]
		$sName = DllStructGetData(DllStructCreate("wchar[" & __NetApi_BufferSize($pBuffer) & "]", $pBuffer), 1)
		__NetApi_BufferFree($pBuffer)
	EndIf
	If @error Then Return SetError(@error, @extended, "")

	Return $sName
EndFunc   ;==>_GetWorkgroupName

Func _EnvUpdate($sEnvVar = "", $vValue = "", $fCurrentUser = True, $fMachine = False)
	Local $sREG_TYPE = "REG_SZ", $iRet1, $iRet2

	If $sEnvVar <> "" Then
		If StringInStr($sEnvVar, "\") Then $sREG_TYPE = "REG_EXPAND_SZ"
		If $vValue <> "" Then
			If $fCurrentUser Then RegWrite("HKCU\Environment", $sEnvVar, $sREG_TYPE, $vValue)
			If $fMachine Then RegWrite("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar, $sREG_TYPE, $vValue)
		Else
			If $fCurrentUser Then RegDelete("HKCU\Environment", $sEnvVar)
			If $fMachine Then RegDelete("HKLM\System\CurrentControlSet\Control\Session Manager\Environment", $sEnvVar)
		EndIf
		; http://msdn.microsoft.com/en-us/library/ms686206%28VS.85%29.aspx
		$iRet1 = DllCall("Kernel32.dll", "BOOL", "SetEnvironmentVariable", "str", $sEnvVar, "str", $vValue)
		If $iRet1[0] = 0 Then Return SetError(1)
	EndIf
	; http://msdn.microsoft.com/en-us/library/ms644952%28VS.85%29.aspx
	$iRet2 = DllCall("user32.dll", "lresult", "SendMessageTimeoutW", _
			"hwnd", 0xffff, _
			"dword", 0x001A, _
			"ptr", 0, _
			"wstr", "Environment", _
			"dword", 0x0002, _
			"dword", 5000, _
			"dword_ptr*", 0)

	If $iRet2[0] = 0 Then Return SetError(1)
EndFunc   ;==>_EnvUpdate
;  Authenticity
Func __NetApi_BufferSize($pBuffer)
	Local $aResult = DllCall("Netapi32.dll", "int", "NetApiBufferSize", "ptr", $pBuffer, "uint*", 0)

	If @error Then Return SetError(@error, @extended, 0)
	If $aResult[0] <> 0 Then Return SetError(-1, $aResult[0], 0)
	Return $aResult[2]
EndFunc   ;==>__NetApi_BufferSize

;  Authenticity
Func __NetApi_BufferFree($pBuffer)
	Local $aResult = DllCall("Netapi32.dll", "int", "NetApiBufferFree", "ptr", $pBuffer)

	If @error Then Return SetError(@error, @extended, False)
	If $aResult[0] <> 0 Then Return SetError(-1, $aResult[0], False)
	Return SetError(0, 0, True)
EndFunc   ;==>__NetApi_BufferFree

Func GetOSVersion()
	$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	$colItems = $objWMIService.ExecQuery("Select Caption,Version from Win32_OperatingSystem")
	For $os In $colItems
		If $os.Caption & " " & $os.Version <> '' Then
			If @OSArch = 'X64' Then
				$osfullversion = $os.Caption & '(64位)'
			EndIf
			If @OSArch = 'X86' Then
				$osfullversion = $os.Caption & '(32位)'
			EndIf
		Else
			$osfullversion = @OSVersion & '' & @OSBuild & '' & @OSArch
		EndIf
	Next
EndFunc   ;==>GetOSVersion

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
Func DllInstall($sDll)
	$aCall = DllCall($sDll, "long", "DllRegisterServer")
	If @error Or $aCall[0] Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>DllInstall
Func DllUnInstall($sDll)
	$aCall = DllCall($sDll, "long", "DllUnregisterServer")
	If @error Or $aCall[0] Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>DllUnInstall


Func _ForceUpdate()
	DllCall("user32.dll", "int", "SendMessageTimeout", "hwnd", 65535, "int", 26, "int", 0, "int", 0, "int", 0, "int", 1000, "str", "dwResult")
	$binWave = Wave()
	$tWave = DllStructCreate('byte[' & BinaryLen($binWave) & ']')
	$pWave = DllStructGetPtr($tWave)
	DllStructSetData($tWave, 1, $binWave)
	_WinAPI_PlaySound($pWave, BitOR($SND_ASYNC, $SND_MEMORY, $SND_NOWAIT))
	$tWave = 0
EndFunc   ;==>_ForceUpdate
;=========================================================================================
; 注册表优化项目
;=========================================================================================
Func AddRegTweaks()
	$n = 0
	;1右键添加管理员取得所有权
	If GUICtrlRead($Checkbox[1]) = $GUI_CHECKED Then
		If @OSBuild < 6000 Then
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ScreenSaverIsSecure', 'REG_DWORD', ($ScreenSaverIsSecure = 0) ? ("1") : ("0"))
			GUICtrlSetData($Checkbox[1], ($ScreenSaverIsSecure = 0) ? ("从屏保恢复时不显示登录屏幕") : ("从屏保恢复时显示登录屏幕"))
		Else
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{CEBFF5CD-ACE2-4F4F-9178-9926F41749EA}\Count', '', 'REG_SZ', '')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" /r /d y && icacls "%1" /grant administrators:F /t')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权', '', 'REG_SZ', '管理员取得所有权')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权\Command', '', 'REG_SZ', $EvaApp & 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F')
		EndIf
		$n += 1
	EndIf
	;
	If GUICtrlRead($Checkbox[2]) = $GUI_CHECKED Then
		If @OSBuild > 19040 Then
			;恢复经典系统属性界面
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\0\2093230218', 'EnabledState', 'REG_DWORD', '00000001')
		Else
			;2右键添加CAB相关命令
			If @OSBuild > 6000 Then
				Local $Icostr = _WinAPI_AssocQueryString('.cab', $ASSOCSTR_DEFAULTICON)
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress', '', 'REG_SZ', 'CAB最大压缩')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress\command', '', 'REG_SZ', 'makecab /v3 /D CompressionType=LZX /D CompressionMemory=21 "%1"')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand', '', 'REG_SZ', '解压缩 CAB 文件')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand\command', '', 'REG_SZ', 'expand -r "%1"')
				RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'MUIVerb', 'REG_SZ', 'CAB文件工具')
				RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'icon', 'REG_SZ', $Icostr)
				RegWrite('HKEY_CLASSES_ROOT\*\shell\CABMenu', 'SubCommands', 'REG_SZ', 'CABCmpress;CABExpand')

			Else
				RegWrite('HKEY_CLASSES_ROOT\*\shell\CAB最大压缩\command', '', 'REG_SZ', 'makecab /v3 /D CompressionType=LZX /D CompressionMemory=21 \"%1\"')
				RegWrite('HKEY_CLASSES_ROOT\*\shell\解压缩 CAB 文件\command', '', 'REG_SZ', 'expand -r \"%1\"')
			EndIf
		EndIf
		$n += 1
	EndIf
	;3右键快速打开CMD
	If GUICtrlRead($Checkbox[3]) = $GUI_CHECKED Then
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符', 'icon', 'REG_SZ', 'C:\WINDOWS\system32\cmd.exe')
		RegWrite('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符', '', 'REG_SZ', '在此处打开命令提示符')
		RegWrite('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符\command', '', 'REG_SZ', $EvaApp & 'cmd.exe /k pushd %L')
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Command Processor', 'CompletionChar', 'REG_DWORD', '9')
		RegWrite("HKEY_CLASSES_ROOT\.cmd\ShellNew", "NullFile", "REG_SZ", "")
		$n += 1
	EndIf
	;4右键快速打开PowerShell
	If GUICtrlRead($Checkbox[4]) = $GUI_CHECKED Then
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell\command', '', 'REG_SZ', "C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -noexit set-location -Path '%1'")
		RegWrite('HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell', 'icon', 'REG_SZ', 'C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe')
		$n += 1
	EndIf
	;5开始菜单显示运行命令
	If GUICtrlRead($Checkbox[5]) = $GUI_CHECKED Then
		If @OSVersion = 'WIN_81' Then
			RegWrite('HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\PintoStartScreen', '', 'REG_SZ', '{470C0EBD-5D73-4d58-9CED-E91E22E23282}')
			RegWrite('HKEY_CURRENT_USER\Software\Classes\AllFileSystemObjects\shellex\ContextMenuHandlers\PintoStartScreen', '', 'REG_SZ', '{470C0EBD-5D73-4d58-9CED-E91E22E23282}')
		Else
			If @OSBuild > 6000 Then
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000001')
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000001')
			Else
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\cdrom', 'Autorun', 'REG_DWORD', '00000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\cdrom', 'Autorun', 'REG_DWORD', '00000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\USBSTOR', 'Autorun', 'REG_DWORD', '00000001')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\USBSTOR', 'Autorun', 'REG_DWORD', '00000001')
			EndIf
		EndIf
		$n += 1
	EndIf
	;6资源管理器启用复选框
	;启用停止更新的Windowsupdate
	If GUICtrlRead($Checkbox[6]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'AutoCheckSelect', 'REG_DWORD', '1')
		Else
			If @OSVersion = 'WIN_XP' Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\WPA\PosReady', 'Installed', 'REG_DWORD', '00000001')
			Else
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
			EndIf
		EndIf
		$n += 1
	EndIf
	;7禁用UAC
	If GUICtrlRead($Checkbox[7]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorUser', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableInstallerDetection', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'PromptOnSecureDesktop', 'REG_DWORD', '00000000')
		Else
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg', 'RemoteRegAccess', 'REG_DWORD', '00000001')
		EndIf
		$n += 1
	EndIf
	;8右键添加记事本打开项
	If GUICtrlRead($Checkbox[8]) = $GUI_CHECKED Then
		RegWrite("HKEY_CLASSES_ROOT\*\shell\Notepad", "", "REG_SZ", "用记事本打开")
		RegWrite("HKEY_CLASSES_ROOT\*\shell\Notepad\command", "", "REG_SZ", "notepad.exe %1")
		$n += 1
	EndIf
	;9右键添加DLL\OCX注册与反注册
	If GUICtrlRead($Checkbox[9]) = $GUI_CHECKED Then
		RegWrite("HKEY_CLASSES_ROOT\.ocx", "", "REG_SZ", "ocxfile")
		RegWrite("HKEY_CLASSES_ROOT\ocxfile", "", "REG_SZ", "OCX")
		RegWrite("HKEY_CLASSES_ROOT\ocxfile\Shell\注册\command", "", "REG_SZ", 'regsvr32.exe \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\ocxfile\Shell\反注册\command", "", "REG_SZ", 'regsvr32.exe /u \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\.dll", "Content Type", "REG_SZ", "application/x-msdownload")
		RegWrite("HKEY_CLASSES_ROOT\.dll", "", "REG_SZ", "Application Extension")
		RegWrite("HKEY_CLASSES_ROOT\dllfile\Shell\注册\command", "", "REG_SZ", 'regsvr32.exe \"%1\"')
		RegWrite("HKEY_CLASSES_ROOT\dllfile\Shell\反注册\command", "", "REG_SZ", 'regsvr32.exe /u \"%1"')
		$n += 1
	EndIf
	;10右键添加在新窗口打开命令
	If GUICtrlRead($Checkbox[10]) = $GUI_CHECKED Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开', '', 'REG_SZ', '在新窗口中打开')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开\Command', '', 'REG_SZ', 'explorer %1')
		$n += 1
	EndIf
	;11移除快捷方式字样和图标
	If GUICtrlRead($Checkbox[11]) = $GUI_CHECKED Then
		If @OSBuild < 6000 Then
			RegDelete('HKEY_CLASSES_ROOT\lnkfile', 'IsShortcut')
		Else
			FileInstall('.\file\Empty.ico', @WindowsDir & '\', 1)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '29', 'REG_SZ', '%SystemRoot%\Empty.ico,0')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer', 'link', 'REG_BINARY', '00,00,00,00')
			RegWrite('HKEY_USERS\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer', 'link', 'REG_BINARY', '00,00,00,00')
		EndIf
		$n += 1
	EndIf
	;12	任务栏使用小图标
	If GUICtrlRead($Checkbox[12]) = $GUI_CHECKED Then
		If @OSBuild > 21900 Then
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '0')
		Else
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSmallIcons', 'REG_DWORD', '00000001')
		EndIf
		$n += 1
	EndIf
	;13优化系统显示设置
	If GUICtrlRead($Checkbox[13]) = $GUI_CHECKED Then
		RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothing", "REG_SZ", "2")
		RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothingType", "REG_DWORD", "00000002")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "Max Cached Icons", "REG_SZ", "7500")
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Animations', 'REG_DWORD', '00000000')
		;Xp的显示优化啥的
		If @OSBuild < 6000 Then
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultValue", "REG_DWORD", "00000001")
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultByFontTest", "REG_DWORD", "00000001")
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultApplied", "REG_DWORD", "00000001")
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing", "DefaultValue", "REG_DWORD", "00000001")
			RegWrite("HKEY_CURRENT_USER\Control Panel\Desktop", "FontSmoothingOrientation", "REG_DWORD", "00000001")
			RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "FontSmoothing", "REG_SZ", "2")
			RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "FontSmoothingType", "REG_DWORD", "00000002")
			RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "ForegroundFlashCount", "REG_DWORD", "00000003")
			RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "ForegroundLockTimeout", "REG_DWORD", "00000000")
			RegWrite("HKEY_USERS\.DEFAULT\Control Panel\Desktop", "SmoothScroll", "REG_DWORD", "00000000")
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultValue", "REG_DWORD", "00000000")
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultByAlphaTest", "REG_DWORD", "00000000")
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultApplied", "REG_DWORD", "00000000")
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation", "DefaultValue", "REG_DWORD", "00000000")
			;不缓存缩略图
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DisableThumbnailCache', 'REG_DWORD', '00000001')
		EndIf
		$n += 1
	EndIf
	;14打开所在目录
	If GUICtrlRead($Checkbox[14]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			If @OSBuild > 8000 Then
				If @OSBuild > 21990 Then
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig', 'BypassTPMCheck', 'REG_DWORD', '00000001')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig', 'BypassSecureBootCheck', 'REG_DWORD', '00000001')
				Else
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'NoPreviousVersionsPage', 'REG_DWORD', '00000001')
				EndIf
			Else
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWAR\Classes\Directory\Background\shellex\ContextMenuHandlers\Flip3D', '', 'REG_SZ', '{3080F90E-D7AD-11D9-BD98-0000947B0257}')
			EndIf
		Else
			Local $strVbs = 'set args = WScript.Arguments' & @CRLF & _
					'linkname = args(0)' & @CRLF & _
					'set wshshell = CreateObject("WScript.Shell")' & @CRLF & _
					'set scut = wshshell.CreateShortcut(linkname)' & @CRLF & _
					'set fs = CreateObject("Scripting.FileSystemObject")' & @CRLF & _
					'folder = """" & fs.GetParentFolderName(scut.TargetPath) & """"' & @CRLF & _
					'wshshell.Run(folder)'
			Local $Fh = FileOpen(@WindowsDir & '\system32\OpenShortcutDir.vbs', 2 + 8)
			FileWrite($Fh, $strVbs)
			FileClose($Fh)
			RegWrite('HKEY_CLASSES_ROOT\lnkfile\shell\打开所在目录\command', '', 'REG_SZ', 'WScript.exe //nologo ' & @WindowsDir & '\system32\OpenShortcutDir.vbs "%L"')
		EndIf
		$n += 1
	EndIf
	;15隐藏操作中心图标
	If GUICtrlRead($Checkbox[15]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			If @OSBuild > 9000 Then
				RegWrite('HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer', 'DisableNotificationCenter', 'REG_DWORD', '00000001')
			Else
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'HideSCAHealth', 'REG_DWORD', '00000001')
			EndIf
		Else
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Security Center', 'AntiVirusOverride', 'REG_DWORD', '00000001')
		EndIf
		$n += 1
	EndIf
	;16系统性能综合优化
	;16Windows8优化
	If GUICtrlRead($Checkbox[16]) = $GUI_CHECKED Then
		;调节内存性能配置
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'Size', 'REG_DWORD', '00000002')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'IoPageLockLimit', 'REG_DWORD', '00000000')
		;关闭磁盘自动播放
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '000000ff')
		;关闭磁盘空间不足警告
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoLowDiskSpaceChecks', 'REG_DWORD', '00000001')
		;Explorer崩溃时，自动重启
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoRestartShell', 'REG_DWORD', '00000001')
		;显示文件扩展名
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'HideFileExt', 'REG_DWORD', '00000000')
		;删除无用的新建项目
		RegDelete('HKEY_CLASSES_ROOT\Briefcase\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.contact\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.bmp\ShellNew')
		RegDelete('HKEY_CLASSES_ROOT\.rtf\ShellNew')
		If @OSBuild > 6000 Then
			;已登录用户计算机自动更新安装不执行自动重启
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU', 'NoAutoRebootWithLoggedOnUsers', 'REG_DWORD', '00000001')
		EndIf
		;最小化时显示完整路径
		RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState', 'FullPath', 'REG_DWORD', '00000001')
		;禁用.NET Runtime Optimization Service
		;http://baike.baidu.com/view/713328.htm
		Local $i = 1
		Do
			$keys = RegEnumKey('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services', $i)
			If StringInStr($keys, 'clr_Optimization') Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\' & $keys, 'Start', 'REG_DWORD', '0x00000004')
			EndIf
			$i += 1
		Until $keys = ''
		;;增加 Internet 时间校准网站
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '', 'REG_SZ', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '2', 'REG_SZ', 'time-a.nist.gov')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '3', 'REG_SZ', 'time-b.nist.gov')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers', '4', 'REG_SZ', 'time-nw.nist.gov')
		;驱动签名
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Driver Signing', 'Policy', 'REG_BINARY', '01')
		;关闭错误报告
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\PCHealth\ErrorReporting', 'DoReport', 'REG_DWORD', '00000000')
		;禁用IPV6
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters', 'DisabledComponents', 'REG_DWORD', '000000ff')
		;启用性能for程序
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
		;网络优化for all
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'DefaultTTL', 'REG_DWORD', '64')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'EnablePMTUBHDetect', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'EnablePMTUDiscovery', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'MTU', 'REG_DWORD', '1500')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'SackOpts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\services\Tcpip\Parameters', 'TCPWindowSize', 'REG_DWORD', '25000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'DefaultTTL', 'REG_DWORD', '64')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'EnablePMTUBHDetect', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'EnablePMTUDiscovery', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'MTU', 'REG_DWORD', '1500')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'SackOpts', 'REG_DWORD', '1')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '3')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'TCPWindowSize', 'REG_DWORD', '25000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'DisableTaskOffload', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\Tcpip\Parameters', 'Tcp1323Opts', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\explorer', 'AlwaysUnloadDll', 'REG_SZ', '1')
		;禁止使用绝对路径来解释出错的快捷方式
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'LinkResolveIgnoreLinkInfo', 'REG_DWORD', '00000001')
		If @OSBuild > 8000 Then
			;等优化啥的，哈哈
			;允许未登录关机
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system', 'shutdownwithoutlogon', 'REG_DWORD', '00000001')
			;开机不显示服务管理器
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\ServerManager', 'DoNotOpenServerManagerAtLogon', 'REG_DWORD', '00000001')
			;加快菜单显示速度
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '10')
			;;取消IE禁用加载项的提示(设置延迟10秒，这样就不会提示了)
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\MAO Settings', 'AddonLoadTimeThreshold', 'REG_DWORD', '00002710')
			;格式化选项中显示Refs格式
			RegWrite('HKEY_LOCALMACHINE\SYSTEM\CurrentControlSet\Control\MiniNT', 'AllowRefsFormatOverNonmirrorVolume', 'REG_DWORD', '00000001')
			;禁用windows8帮助提示
			RegWrite('HKEY_CURRENT_USER\Software|Policies\Microsoft\Windows\EdgeUI', 'DisableHelpSticker', 'REG_DWORD', '00000001')
		ElseIf @OSBuild < 8000 And @OSBuild > 6000 Then
			;离开模式
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Power', 'AwayModeEnabled', 'REG_DWORD', '00000001')
			;禁用打开方式的浏览网页程序
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'NoInternetOpenWith', 'REG_DWORD', '00000001')
			;加快运行速度
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '10')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\CLSID\{00021400-0000-0000-C000-000000000046}', 'MenuShowDelay', 'REG_SZ', '10')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoRestartShell', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\WSearch', 'Start', 'REG_DWORD', '00000004')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\WSearch', 'Start', 'REG_DWORD', '00000004')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\CrashControl', 'AutoReboot', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\CrashControl', 'AutoReboot', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\Control Panel\DeskDesktop', 'AutoEndTasks', 'REG_SZ', '1')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'ConfigFileAllocSize', 'REG_DWORD', '000001f4')
			;网络优化
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\NetBT\Parameters', 'NameSrvQueryTimeout', 'REG_DWORD', '0000bb8')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Rpc', 'MaxRpcSize', 'REG_DWORD', '00100000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxCmds', 'REG_DWORD', '00000064')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxThreads', 'REG_DWORD', '00000064')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\lanmanworkstation\parameters', 'MaxCollectionCount', 'REG_DWORD', '00000064')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\AFD\Parameters', 'BufferMultiplier', 'REG_DWORD', '00000400')
			;;关闭自动调试提高运行速度
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
			;;优化程序进程，独立进程优先级，避免死机
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer', 'DesktopProcess', 'REG_DWORD', '00000001')
			;;加快开机和关机
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'WaitToKillAppTimeout', 'REG_SZ', '2000')
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'HungAppTimeout', 'REG_SZ', '900')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control', 'WaitToKillServiceTimeout', 'REG_SZ', '2000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control', 'WaitToKillServiceTimeout', 'REG_SZ', '2000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'ReportBootOk', 'REG_SZ', '0')
			If Not $HasSSD Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
			Else
				TurnOffPrefetch()
			EndIf
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'VideoInitTime', 'REG_DWORD', '000001e4')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'UserMasterDeviceType', 'REG_DWORD', '00000003')
			;禁用内存面调度,提升核心系统性能
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'DisablePagingExecutive', 'REG_DWORD', '00000001')
			;提高NTFS访问速度
			If Not HasSSD() Then RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisableLastAccessUpdate', 'REG_DWORD', '00000000')
			If Not HasSSD() Then RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisable8dot3NameCreation', 'REG_DWORD', '00000000')
			;在资源管理器显示菜单栏
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'AlwaysShowClassicMenu', 'REG_DWORD', '00000001')
			;跳过WMP首次运行出现的协议窗口
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer', 'GroupPrivacyAcceptance', 'REG_DWORD', '00000001')
			;提高WMP的编码能力
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'HighRate', 'REG_DWORD', '0002EE00')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'LowRate', 'REG_DWORD', '0000DAC0')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'MediumHighRate', 'REG_DWORD', '0001F400')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\MediaPlayer\Settings\MP3Encoding', 'MediumRate', 'REG_DWORD', '0000FA00')
			;在独立的内存空间中运行16位程序
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\WOW', 'DefaultSeparateVDM', 'REG_SZ', 'Yes')
			;禁用程序兼容助手
			RegWrite('HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\AppCompat', 'DisablePCA', 'REG_DWORD', '00000001')
			;打开启动优化功能
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'Y')
			If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
				;关机理由啥的
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonUI', 'REG_DWORD', '00000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonOn', 'REG_DWORD', '00000000')
				;提升多媒体优先级解决爆音问题
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile', 'SystemResponsiveness', 'REG_DWORD', '00000014')
				;禁用仅加载代码签署的DLLs参考http://msdn.microsoft.com/zh-cn/library/ee461144.aspx
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows', 'RequireSignedAppInit_DLLs', 'REG_DWORD', '00000000')
			EndIf
			;dns Tweaks
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters', 'MaxCacheTtl', 'REG_DWORD', '00003840')
			;禁用隐藏共享
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
			;杂项
			RegWrite('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows NT\Driver Signing', 'BehaviorOnFailedVerify', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'DEVMGR_SHOW_DETAILS', 'REG_SZ', '1')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout', 'EnableAutoLayout', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ForegroundLockTimeout', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager', 'AutoChkTimeOut', 'REG_DWORD', '00000005')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\ContentIndex', 'FilterFilesWithUnknownExtensions', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup', 'SourcePath', 'REG_SZ', '')
		Else
			;winxp及2003的优化
			;禁用搜索助手并使用高级搜索
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'Actor', 'REG_SZ', '')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'SocialUI', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'UsageCount', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Search Assistant', 'UseAdvancedSearchAlways', 'REG_DWORD', '00000001')
			;禁止启动时候弹出错误信息
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Windows', 'NoPopUpsOnBoot', 'REG_SZ', '1')
			;加快局域网显示速度
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{D6277990-4C6A-11CF-8D87-00AA0060F5BF}')
			;在所有资源管理器窗口显示状态栏
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main', 'StatusBarOther', 'REG_DWORD', '00000001')
			;—>  启动系统时为桌面和资源管理器创建独立的进程(其中一个崩溃也不影响另一个)
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'SeparateProcess', 'REG_DWORD', '00000001')
			;为每种文件夹类型使用一种背景图片
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultApplied', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewWatermark', 'DefaultValue', 'REG_DWORD', '00000001')
			;显示半透明的选择长方形
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultByAlphaTest', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultApplied', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ListviewAlphaSelect', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultValue', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultApplied', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade', 'DefaultValue', 'REG_DWORD', '00000000')
			;在菜单下显示阴影 - 关闭
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultValue', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultApplied', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow', 'DefaultValue', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultValue', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultByAlphaTest', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultApplied', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation', 'DefaultValue', 'REG_DWORD', '00000000')
			;;在鼠标指针下显示阴影
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow', 'DefaultApplied', 'REG_DWORD', '00000001')
			;在桌面上为图标标签使用阴影
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultByAlphaTest', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultApplied', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'ListviewShadow', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax', 'DefaultValue', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax', 'DefaultApplied', 'REG_DWORD', '00000000')
			;拖拉时显示窗体内容
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows', 'DefaultValue', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows', 'DefaultApplied', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'DragFullWindows', 'REG_SZ', '1')
			;;关闭窗口的动画效果
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics', 'MinAnimate', 'REG_SZ', '0')
			;桌面图标 - 标题换行
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics', 'IconTitleWrap', 'REG_SZ', '1')
			;安装驱动时不搜索 Windows Update
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\DriverSearching', 'DontSearchWindowsUpdate', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Policies\Microsoft\Windows\DriverSearching', 'DontPromptForWindowsUpdate', 'REG_DWORD', '00000001')
			; ;禁止系统通过全面搜索目标驱动器来解析快捷方式
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoResolveSearch', 'REG_DWORD', '00000001')
			;启动 XP 的路由功能和 IP 的过滤功能
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'IPEnableRouter', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters', 'EnableSecurityFilters', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control', 'WaitToKillAppTimeout', 'REG_SZ', '2000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'MasterDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0001', 'SlaveDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'MasterDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Class\{4D36E96A-E325-11CE-BFC1-08002BE10318}\0002', 'SlaveDeviceTimingModeAllowed', 'REG_DWORD', 'ffffffff')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Security Center', 'AntiVirusOverride', 'REG_DWORD', '00000001')
			;关闭桌面清理向导
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\CleanupWiz', 'NoRun', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Messenger', 'Start', 'REG_DWORD', '00000004')
			;加速打开资源管理器
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'ConfigFileAllocSize', 'REG_DWORD', '000001f4')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\FileSystem', 'NtfsDisableLastAccessUpdate', 'REG_DWORD', '00000000')
			;;不自动搜索网络文件夹和打印机
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'NoNetCrawling', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoRemoteRecursiveEvents', 'REG_DWORD', '00000001')
			;禁止 Windows 漫游气球提醒
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Tour', 'RunCount', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Applets\Tour', 'RunCount', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'CPUPriority', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'PCIConcur', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'FastDRAM', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Vxd\BIOS', 'AGPConcur', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000001')
			;加快菜单显示速度
			RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'MenuShowDelay', 'REG_SZ', '0')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Re moteComputer\NameSpace\{2227A280-3AEA-1069-A2DE-08002B30309D}', '', 'REG_SZ', 'Printers')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\Security', 'BlockXBM', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\stisvc', 'Start', 'REG_DWORD', '00000002')
			;语言栏隐藏到任务栏并隐藏语言栏上的帮助按钮
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\MSUTB', 'ShowDeskBand', 'REG_DWORD', '00000001')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar', 'ShowStatus', 'REG_DWORD', '00000004')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar', 'ExtraIconsOnMinimized', 'REG_DWORD', '00000000')
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\CTF\LangBar\ItemState\{ED9D5450-EBE6-4255-8289-F8A31E687228}', 'DemoteLevel', 'REG_DWORD', '00000003')
			;在任务栏显示音量图标
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\SysTray', 'Services', 'REG_DWORD', '0000001f')
			;平滑屏幕字体边缘

			;关机理由啥的
			If @OSVersion = 'WIN_2003' Then
				RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'ScreenSaverIsSecure', 'REG_SZ', '0')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Policies\system', 'disablecad', 'REG_DWORD', '00000001')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonUI', 'REG_DWORD', '000000')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Policies\Microsoft\Windows NT\Reliability', 'ShutdownReasonOn', 'REG_DWORD', '000000')
			EndIf
		EndIf
		$n += 1
	EndIf
	;17自动登录(Windows2008)
	;17使管理员可以使用Metro应用
	;17 上帝模式
	If GUICtrlRead($Checkbox[17]) = $GUI_CHECKED Then
		If @OSBuild > 8000 Then
			If @OSBuild > 9000 Then
				RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'LaunchTo', 'REG_DWORD', '00000002')
			Else
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'FilterAdministratorToken', 'REG_DWORD', '00000001')
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000001')
			EndIf
		Else
			If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'AutoAdminLogon', 'REG_SZ', '1')
			Else
				If @OSBuild > 6000 Then
					RegWrite('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式', '', 'REG_SZ', '上帝模式')
					RegWrite('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式\command', '', 'REG_EXPAND_SZ', 'explorer shell:::{ED7BA470-8E54-465E-825C-99712043E01C}')
				Else
					RegWrite('KEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug', 'Auto', 'REG_SZ', '0')
				EndIf
			EndIf
		EndIf
		$n += 1
	EndIf
	;18去除组策略密码验证限制
	;18 开机直接进入桌面(win8)
	;去除显卡右键菜单
	If GUICtrlRead($Checkbox[18]) = $GUI_CHECKED Then
		If @OSBuild > 8000 Then
			If @OSVersion = 'WIN_8' Then
				Local $BootFile = FileOpen(@StartupCommonDir & '\BootToDesktop.scf', 1 + 8)
				FileWrite($BootFile, '')
				FileWrite($BootFile, '[Shell]' & @LF & 'Command=2' & @LF & 'IconFile=imageres.dll,105' & @LF & '[Taskbar]' & @LF & 'Command=ToggleDesktop')
				FileClose($BootFile)
			EndIf
			If @OSVersion = "WIN_81" Or @OSVersion = "WIN_10" Then
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage', 'OpenAtLogon', 'REG_DWORD', '00000000')
			EndIf
			If @OSBuild > 9000 Then
				RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowFrequent', 'REG_DWORD', '00000000')
				RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowRecent', 'REG_DWORD', '00000000')
			EndIf
		Else
			If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
				Local $infData = '[version]' & @LF & _
						'signature="$CHICAGO$"' & @LF & _
						'[System Access]' & @LF & _
						'MinimumPasswordAge = 0' & @LF & _
						'MaximumPasswordAge = 0' & @LF & _
						'MinimumPasswordLength = 0' & @LF & _
						'PasswordComplexity = 0' & @LF & _
						'PasswordHistorySize = 0' & @LF & _
						'LockoutBadCount = 0' & @LF & _
						'RequireLogonToChangePassword = 0' & @LF & _
						'ForceLogoffWhenHourExpire = 0'

				Local $InfH = FileOpen(@TempDir & '\gp.inf', 1 + 8)
				FileWrite($InfH, $infData)
				FileClose($InfH)
				RunWait(@ComSpec & ' /c secedit /configure /db gp.sdb /cfg gp.inf /quiet', @TempDir, @SW_HIDE)
				;刷新组策略
				RunWait(@ComSpec & ' /c GPUpdate /force', @WindowsDir, @SW_HIDE)
				;清除inf文件
				FileDelete(@TempDir & '\gp.inf')
			Else
				;清理显卡右键菜单
				Run('regsvr32 /s /u igfxpph.dll nvcpl.dll atiacmxx.dll igfxsrvc.dll', @WindowsDir, @SW_HIDE)
				RegDelete('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers')
				RegWrite('HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\New', '', 'REG_SZ', '{D969A300-E7FF-11d0-A93B-00A0C90F2719}')
			EndIf
		EndIf
		$n += 1
	EndIf
	;19禁用登录需要按Ctrl+Alt+Del
	;USB供电开关
	If GUICtrlRead($Checkbox[19]) = $GUI_CHECKED Then
		If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Or @OSVersion = 'WIN_2003' Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'disablecad', 'REG_DWORD', '00000001')
		Else
			;设置USB弹出后不再进行供电
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'EnableDiagnosticMode', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'DisableOnSoftRemove', 'REG_DWORD', '00000001')
		EndIf
		$n += 1
	EndIf
	;20IE综合优化选项
	If GUICtrlRead($Checkbox[20]) = $GUI_CHECKED Then
		If @OSBuild > 21900 Then
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_ShowClassicMode", "REG_DWORD", "00000001")
		Else
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
		EndIf
		$n += 1
	EndIf
	;21关闭系统开机声音#关闭分组相似任务栏按钮
	If GUICtrlRead($Checkbox[21]) = $GUI_CHECKED Then
		If @OSBuild > 6000 Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation', 'DisableStartupSound', 'REG_DWORD', '00000001')
		Else
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000000')
		EndIf
		$n += 1
	EndIf
EndFunc   ;==>AddRegTweaks
Func RemoveRegTweak1()
	;删除管理员取得权限
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\*\shell\管理员取得所有权')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\管理员取得所有权')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\exefile\shell\管理员取得所有权')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键"管理员取得所有权"菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak1
Func RemoveRegTweak2()
	If @OSBuild > 19040 Then
		;恢复新版系统属性界面
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\0\2093230218', 'EnabledState', 'REG_DWORD', '00000002')
		_ForceUpdate()
		MsgBox(0, '提示', '恢复默认系统属性界面成功', 5)
	Else
		;删除cab最大压缩
		If @OSBuild > 6000 Then
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABCmpress')
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\CABExpand')
			RegDelete('HKEY_CLASSES_ROOT\*\shell\CABMenu')
		Else
			RegDelete('HKEY_CLASSES_ROOT\*\shell\CAB最大压缩')
			RegDelete('HKEY_CLASSES_ROOT\*\shell\解压缩 CAB 文件')
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '移除CAB相关菜单成功', 5)
	EndIf

EndFunc   ;==>RemoveRegTweak2
Func RemoveRegTweak3()
	;删除在此处打开命令提示符
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\在此处打开命令提示符')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Folder\shell\在此处打开命令提示符\Command')
	RegDelete('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Drive\shell\在此处打开命令提示符\command')
	RegDelete('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Directory\shell\在此处打开命令提示符\command')
	RegDelete('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符')
	RegDelete('HKEY_CLASSES_ROOT\Folder\shell\在此处打开命令提示符\command')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键命令行菜单成功', 5)
EndFunc   ;==>RemoveRegTweak3
Func RemoveRegTweak4()
	;POERRSHELL
	RegDelete("HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell")
	RegDelete("HKEY_CLASSES_ROOT\Folder\shell\在此处打开Powershell\command")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键Powershell菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak4
Func RemoveRegTweak5()
	;RUN
	If @OSVersion = 'WIN_81' Then
		RegDelete('HKEY_CURRENT_USER\Software\Classes\*\shellex\ContextMenuHandlers\PintoStartScreen')
		RegDelete('HKEY_CURRENT_USER\Software\Classes\AllFileSystemObjects\shellex\ContextMenuHandlers\PintoStartScreen')
		MsgBox(0, '提示', '取消所有文件都可固定到开始菜单成功！', 5)
	Else
		If @OSBuild > 6000 Then
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000000')
			RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'Start_ShowRun', 'REG_DWORD', '00000000')
			MsgBox(0, '提示', '取消开始菜单运行命令显示成功！', 5)
		Else
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '00000095')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoDriveTypeAutoRun', 'REG_DWORD', '00000095')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\cdrom', 'Autorun', 'REG_DWORD', '00000001')
			RegWrite('KEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\cdrom', 'Autorun', 'REG_DWORD', '00000001')
			MsgBox(0, '提示', '开启光盘及磁盘自动播放功能成功！', 5)
		EndIf
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak5
Func RemoveRegTweak6()
	;禁用复选框
	If @OSBuild > 6000 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'AutoCheckSelect', 'REG_DWORD', '0')
		MsgBox(0, '提示', '在资源管理器中禁用复选框选择成功！', 5)
	Else
		If @OSVersion <> 'WIN_XP' Then
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareWks')
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters', 'AutoShareServer')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
			MsgBox(0, '提示', '启用系统默认共享成功！！', 5)
		EndIf
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak6
Func RemoveRegTweak7()
	;UAC
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorAdmin', 'REG_DWORD', '00000002')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'ConsentPromptBehaviorUser', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableInstallerDetection', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'PromptOnSecureDesktop', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System', 'EnableLUA', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '启用UAC成功！', 5)
EndFunc   ;==>RemoveRegTweak7
Func RemoveRegTweak8()
	;NOTEPAD
	RegDelete("HKEY_CLASSES_ROOT\*\shell\Notepad\command")
	RegDelete("HKEY_CLASSES_ROOT\*\shell\Notepad")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键记事本菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak8
Func RemoveRegTweak9()
	;DLL\OCX
	RegDelete("HKEY_CLASSES_ROOT\ocxfile\Shell")
	RegDelete("HKEY_CLASSES_ROOT\dllfile\Shell")
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键ocx及dll相关菜单成功！', 5)
EndFunc   ;==>RemoveRegTweak9
Func RemoveRegTweak10()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\shell\在新窗口中打开')
	_ForceUpdate()
	MsgBox(0, '提示', '移除右键菜单"在新窗口中打开"成功！', 5)
EndFunc   ;==>RemoveRegTweak10
Func RemoveRegTweak11()
	Local $icoEmpty = @WindowsDir & '\Empty.ico'
	If FileExists($icoEmpty) Then FileDelete($icoEmpty)
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '29')
	_ForceUpdate()
	MsgBox(0, '提示', '还原快捷方式图标成功！', 5)
EndFunc   ;==>RemoveRegTweak11
Func RemoveRegTweak12()
	If @OSBuild > 21900 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '00000002')
	Else
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSmallIcons', 'REG_DWORD', '00000000')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '设置任务栏使用大图标成功！', 5)
EndFunc   ;==>RemoveRegTweak12

Func RemoveRegTweak12_1()
	If @OSBuild > 21900 Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarSi', 'REG_DWORD', '00000001')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '设置任务栏使用中等图标成功！', 5)
EndFunc   ;==>RemoveRegTweak12_1

Func RemoveRegTweak14()
	If @OSBuild > 6000 Then
		If @OSBuild > 8000 Then
			If @OSBuild > 21990 Then
				RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\Setup\LabConfig')
				MsgBox(0, '提示', '恢复系统默认设置成功！', 5)
			Else
				RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'NoPreviousVersionsPage')
				MsgBox(0, '提示', '恢复属性界面"以前的版本"标签页成功！', 5)
			EndIf
		Else
			RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Directory\Background\shellex\ContextMenuHandlers\Flip3D')
			MsgBox(0, '提示', '移除右键菜单成功！', 5)
		EndIf
	Else
		RegDelete('HKEY_CLASSES_ROOT\lnkfile\shell\打开所在目录')
		FileDelete(@WindowsDir & '\system32\OpenShortcutDir.vbs')
		MsgBox(0, '提示', '移除右键菜单成功！', 5)
	EndIf
	_ForceUpdate()
EndFunc   ;==>RemoveRegTweak14
Func RemoveRegTweak15()
	If @OSBuild > 6000 Then
		If @OSBuild > 9000 Then
			RegDelete('HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer')
		Else
			RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'HideSCAHealth')
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '恢复操作中心托盘图标成功！', 5)
	Else
	EndIf
EndFunc   ;==>RemoveRegTweak15
Func RemoveRegTweak17()
	If @OSBuild > 6000 Then
		If @OSBuild > 9000 Then
			RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'LaunchTo', 'REG_DWORD', '00000002')
			MsgBox(0, '提示', '设置打开文件资源管理器时打开快速访问成功', 5)
		Else
			RegDelete('HKEY_CLASSES_ROOT\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\上帝模式')
			MsgBox(0, '提示', '移除"上帝模式"右键菜单成功！', 5)
		EndIf
		_ForceUpdate()
	EndIf
EndFunc   ;==>RemoveRegTweak17
Func RemoveRegTweak18_2()
	;快速访问显示常用文件夹
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowFrequent', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '设置快速访问显示常用文件夹成功！', 5)
EndFunc   ;==>RemoveRegTweak18_2
Func RemoveRegTweak18_3()
	;快速访问显示最近文件
	RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer', 'ShowRecent', 'REG_DWORD', '00000001')
	_ForceUpdate()
	MsgBox(0, '提示', '设置快速访问显示最近文件成功！', 5)
EndFunc   ;==>RemoveRegTweak18_3
Func RemoveRegTweak19()
	If @OSVersion <> 'WIN_2008R2' And @OSVersion <> 'WIN_2008' And @OSVersion <> 'WIN_2003' Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'EnableDiagnosticMode', 'REG_DWORD', '00000000')
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\usbhub\hubg', 'DisableOnSoftRemove')
		_ForceUpdate()
		MsgBox(0, '提示', '已经设置为弹出的USB设备继续供电！', 5)
	Else
	EndIf
EndFunc   ;==>RemoveRegTweak19

Func RestoreWin11NewStartMenu()
	RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_ShowClassicMode")
	_ForceUpdate()
	MsgBox(0, '提示', '已经恢复开始菜单为新版本样式！', 5)
EndFunc   ;==>RestoreWin11NewStartMenu
Func RemoveRegTweak21()
	If @OSBuild > 6000 Then
		RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation', 'DisableStartupSound')
		_ForceUpdate()
		MsgBox(0, '提示', '已经开启系统开机声音！', 5)
	Else
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'TaskbarGlomming', 'REG_DWORD', '00000001')
		_ForceUpdate()
		MsgBox(0, '提示', '已经开启任务栏分组相似按钮！', 5)
	EndIf
EndFunc   ;==>RemoveRegTweak21
Func StartRegTweak()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	AddRegTweaks()
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	If $n > 0 Then
		_ForceUpdate()
		MsgBox(0, '友情提示', '您选择的' & $n & '个优化选项已经成功应用于当前系统,' & @LF & '部分优化需要重启后才能生效!', 5)
		$n = 0
	Else
		MsgBox(16, '错误', '请选择您要进行优化的项目！', 5)
		$n = 0
	EndIf
EndFunc   ;==>StartRegTweak
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
			If @OSArch = "X86" Then FileInstall('.\file\Notepad2_X86.exe', @WindowsDir & '\Notepad2.exe', 1)
			If @OSArch = "X64" Then FileInstall('.\file\Notepad2_X64.exe', @WindowsDir & '\Notepad2.exe', 1)
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
				FileInstall('.\file\HashTab32.dll', @WindowsDir & '\system32\', 1)
				$bResult = DllInstall(@WindowsDir & '\system32\HashTab32.dll')
			ElseIf @OSArch = "X64" Then
				FileInstall('.\file\HashTab64.dll', @WindowsDir & '\SysWOW64\', 1)
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
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装系统更新禁用服务)..'
				$percent += $percent
				DirCreate(@ProgramFilesDir & "\UpdaterDisabler")
				FileInstall('.\file\UpdaterDisabler.exe', @ProgramFilesDir & "\UpdaterDisabler\")
				RunWait(@ProgramFilesDir & "\UpdaterDisabler\UpdaterDisabler.exe -install", @ProgramFilesDir & "\UpdaterDisabler\", @SW_HIDE)
			Else
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在对系统主题进行破解..'
				$percent += $percent
				If @OSArch = "X86" Then
					FileInstall('.\file\ThemePatcherx86.exe', @TempDir & '\', 1)
					RunWait(@TempDir & '\ThemePatcherx86.exe  -silent', '', @SW_HIDE)
				ElseIf @OSArch = "X64" Then
					FileInstall('.\file\ThemePatcherx64.exe', @TempDir & '\', 1)
					RunWait(@TempDir & '\ThemePatcherx64.exe  -silent', '', @SW_HIDE)
				Else
				EndIf
			EndIf
		EndIf
		;4安装摄像头工具
		;4 破解系统链接数
		If GUICtrlRead($plugins[4]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild < 6000 Then
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 开始破解系统连接数..'
				FileInstall('.\file\tcpPatch.exe', @TempDir & '\', 1)
				FileChangeDir(@TempDir)
				Run("tcpPatch.exe")
				WinWaitActive("比特精灵提供", "操作系统")
				ControlSetText("比特精灵提供", "操作系统", "Edit2", "2000")
				Send("!a")
				If WinExists("比特精灵", "您希望现在就重启") Then
					Send("!n")
				EndIf
				WinWaitActive("比特精灵提供", "成功的应用了补丁")
				WinClose("比特精灵提供", "成功的应用了补丁")
				If WinExists("比特精灵", "您希望现在就重启") Then
					Send("!n")
				EndIf
				Run(@ComSpec & ' /c tsakkill /im "tcpPatch.exe" /f', @WindowsDir, @SW_HIDE)
				FileDelete(@TempDir & '\tcpPatch.exe')
			Else
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装摄像头工具..'
				$percent += $percent
				FileInstall('.\file\Ecap.exe', @WindowsDir & '\', 1)
				FileCreateShortcut(@WindowsDir & '\Ecap.exe', @UserProfileDir & '\Appdata\Roaming\Microsoft\Windows\Network shortcuts\视频设备', @WindowsDir)
			EndIf
		EndIf
		;5Windows2008游戏补丁
		If GUICtrlRead($plugins[5]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild > 8000 Then
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows开发者证书..'
				$percent += $percent
				RunWait(@ComSpec & ' /c powershell -c Show-WindowsDeveloperLicenseRegistration', @WindowsDir, @SW_HIDE)
			Else
				$percent += $percent
				If @OSVersion = 'WIN_XP' Then
					$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装WindowsXP内存4GB限制破解补丁..'
					FileInstall('.\file\XP64G.exe', @TempDir & '\', 1)
					Run(@TempDir & '\XP64G.exe')
					WinActivate('[CLASS:#32770]')
					WinWaitActive('[CLASS:#32770]')
					ControlClick('XP64G 2.0（修正USB蓝屏问题）', '', "[CLASS:Button; INSTANCE:1]")
					Sleep(2500)
					If ProcessExists('XP64G.exe') Then Run(@ComSpec & ' /c taskkill /im XP64G.exe /f', @WindowsDir, @SW_HIDE)
					FileDelete(@TempDir & '\XP64G.exe')
				Else
					If @OSVersion = "WIN_2008R2" Or @OSVersion = "WIN_2008" Then
						$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows2008游戏补丁..'
						FileInstall('.\file\GameFixForws2008.exe', @TempDir & '\', 1)
						RunWait(@TempDir & '\GameFixForws2008.exe', @TempDir, @SW_HIDE)
						FileDelete(@TempDir & '\GameFixForws2008.exe')
					Else
						$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装浏览器搜素引擎增强包..'
						FileInstall('.\file\ico.exe', @TempDir & '\', 1)
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
					EndIf
				EndIf
			EndIf
		EndIf
		;6DirectMusic补丁
		If GUICtrlRead($plugins[6]) = $GUI_CHECKED Then
			$i += 1
			If @OSBuild < 6000 Then
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装豆沙绿护眼配色方案..'
				$percent += $percent
				RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors', 'Background', 'REG_SZ', '204 232 207')
				RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors', 'Window', 'REG_SZ', '204 232 207')
				RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings', 'Always Use My Colors ', 'REG_DWORD', '00000000')
				RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings', 'Background Color', 'REG_SZ', '204 232 207')
				RegWrite('HKEY_USERS\' & $UserSid & '\Control Panel\Colors\Software\Microsoft\Internet Explorer\Settings\Software\Microsoft\Internet Explorer\Main', 'Use_DlgBox_Colors', 'REG_SZ', 'yes')
			Else
				If @OSVersion = 'WIN_2008R2' Or @OSVersion = 'WIN_2008' Then
					$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在在资源管理器中安装windows2008DirectMusic补丁..'
					$percent += $percent
					If FileExists(@TempDir & '\DirectMusic.exe') = 0 Then FileInstall('.\file\DirectMusic.exe', @TempDir & '\', 1)
					RunWait(@TempDir & '\DirectMusic.exe', @TempDir, @SW_HIDE)
					FileDelete(@TempDir & '\DirectMusic.exe')
				Else
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
				EndIf
			EndIf
		EndIf
		;7everything
		If GUICtrlRead($plugins[7]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Everything搜索工具..'
			$percent += $percent
			FileInstall('.\file\everything.exe', @TempDir & '\', 1)
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
			FileInstall('.\file\CBXShell.exe', @TempDir & '\', 1)
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
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装关闭光驱插件..'
				FileInstall('.\file\srcd.dll', @WindowsDir & '\System32\', 1)
				Run(@ComSpec & ' /c Regsvr32 /s %windir%\System32\srcd.dll', @WindowsDir & '\System32', @SW_HIDE)
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Wenson CDROM Eject', '', 'REG_SZ', '{F0479943-AA1D-49DD-86F4-6035E068260C}')
			Else
				If @OSBuild < 8000 Then
					$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装去除桌面水印补丁..'
					If @OSArch = "X86" Then
						FileInstall('.\file\RemoveWatermarkX86.exe', @TempDir & '\', 1)
						RunWait(@TempDir & '\RemoveWatermarkX86.exe  -silent', '', @SW_HIDE)
					ElseIf @OSArch = "X64" Then
						FileInstall('.\file\RemoveWatermarkX64.exe', @TempDir & '\', 1)
						RunWait(@TempDir & '\RemoveWatermarkX64.exe  -silent', '', @SW_HIDE)
					Else
					EndIf
				Else
					$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在添加“Windows8右键快捷菜单”..'
					;Windows8右键快捷菜单
					Local $OsString = ''
					Switch @OSArch
						Case 'X64'
							$OsString = '64'
						Case 'X86'
							$OsString = ''
					EndSwitch
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt', '', 'REG_SZ', '命令提示符')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt', 'icon', 'REG_SZ', 'cmd.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Command Prompt\command', '', 'REG_SZ', 'cmd.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel', '', 'REG_SZ', '控制面板')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel', 'icon', 'REG_SZ', 'shell32.dll,21')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Control Panel\command', '', 'REG_SZ', 'rundll32.exe shell32.dll,Control_RunDLL')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer', '', 'REG_SZ', '我的电脑')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer', 'icon', 'REG_SZ', 'imageres.dll,105')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\My Computer\command', '', 'REG_SZ', 'explorer.exe /e,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad', '', 'REG_SZ', '记事本')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad', 'icon', 'REG_SZ', 'notepad.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Notepad\command', '', 'REG_SZ', 'notepad.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint', '', 'REG_SZ', '画 图')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint', 'icon', 'REG_SZ', 'mspaint.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Paint\command', '', 'REG_SZ', 'mspaint.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart', '', 'REG_SZ', '重 启')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart', 'icon', 'REG_SZ', 'shell32.dll,112')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Restart\command', '', 'REG_SZ', 'Shutdown -r -f -t 0')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown', '', 'REG_SZ', '关 机')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown', 'icon', 'REG_SZ', 'shell32.dll,215')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Shutdown\command', '', 'REG_SZ', 'Shutdown -s -f -t 0')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool', '', 'REG_SZ', '截 图')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool', 'icon', 'REG_SZ', 'SnippingTool.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\SnippingTool\command', '', 'REG_SZ', 'SnippingTool.exe')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff', '', 'REG_SZ', '注 销')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff', 'icon', 'REG_SZ', 'shell32.dll,44')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\logoff\command', '', 'REG_SZ', 'Shutdown -l')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services', '', 'REG_SZ', '服 务')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services', 'SuppressionPolicy', 'REG_DWORD', '4000003c')
					RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '' & $OsString & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\services\command', '', 'REG_EXPAND_SZ', '%windir%\system32\mmc.exe /s %SystemRoot%\system32\services.msc /s')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\*\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'Position', 'REG_SZ', 'top')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\background\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'MUIVerb', 'REG_SZ', '快捷键')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'Icon', 'REG_SZ', 'shell32.dll,319')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\Directory\shell\OtaQuickMenu', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'MUIVerb', 'REG_SZ', '快捷键')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'Icon', 'REG_SZ', 'shell32.dll,319')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'Position', 'REG_SZ', 'top')
					RegWrite('HKEY_CLASSES_ROOT' & $OsString & '\LibraryFolder\background\shell\OtaQuickMenu]', 'SubCommands', 'REG_SZ', 'My Computer;Control Panel;Notepad;Command Prompt;services;Paint;SnippingTool;logoff;Restart;Shutdown')
				EndIf
			EndIf
			$percent += $percent
		EndIf
		;10reg2inf右键菜单
		If GUICtrlRead($plugins[10]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Reg2Inf右键菜单..'
			$percent += $percent
			If Not FileExists(@WindowsDir & '\reg2inf.exe') Then FileInstall('.\file\reg2inf.exe', @WindowsDir & '\', 1)
			RegWrite('HKEY_CLASSES_ROOT\regfile\shell\convert', '', 'REG_SZ', '转换为inf文件')
			RegWrite('HKEY_CLASSES_ROOT\regfile\shell\convert\command', '', 'REG_SZ', 'reg2inf.exe -w -t "%1"')
		EndIf
		;11ccleaner
		If GUICtrlRead($plugins[11]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装ccleaner..'
			$percent += $percent
			FileInstall('.\file\CCleaner.exe', @TempDir & '\', 1)
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
				FileInstall('.\file\UnlockerX86.exe', @TempDir & '\', 1)
				RunWait(@TempDir & '\UnlockerX86.exe -o"' & @HomeDrive & '\Program Files" -r -y', @TempDir, @SW_HIDE)
			ElseIf @OSArch = "X64" Then
				FileInstall('.\file\UnlockerX64.exe', @TempDir & '\', 1)
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
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在安装Windows2008xbox支持补丁..'
				FileInstall('.\file\xbox.exe', @TempDir & '\', 1)
				RunWait(@TempDir & '\xbox.exe', @TempDir, @SW_HIDE)
				FileDelete(@TempDir & '\xbox.exe')
			Else
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
Func _SuperHidden($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $SuperHidden
	$SuperHidden &= 'PrIAT24gIEVycm8AciBSZXN1bWUAICBOZXh0DQoAc3RyID0iIg0ACkhpZGRlbiAAPSAiSEtDVVwAU29mdHdhcmWAXE1pY3JvcwA0AFxXaW5kb3dzAFxDdXJyZW50AFZlcnNpb25cAEV4cGxvcmVyAFxBZHZhbmNlTGRcA5QAplNTSKpTAGhvd1N1cGVyAQZeRmlsZUV4dA1Fs2WEJwFcZXQgQ4BvbW1hbmQxAC8AV1NjcmlwdC4AQ3JlYXRlT2JAamVjdCgihQpTQGhlbGwiKYMaYy2DGjKAGowWc4wWQ2gYZWNrAROEMy5SZcBnUmVhZCiDb4AQCElmIAUSMiBUaAxlbgAaCBZXcml0BGUggxYsIDEsIAAiUkVHX0RXT/xSRABhjxRFY+EKhEKPCgHCiyAi0tG+rckA6NbDzqrP1MoAvs+1zbPOxLwA/tL+stjAqdUIucP7QApFbHNl9RksMigsMCcsjQoOLAEpBwUsAS8HLG5kIElmQQkXdW4gKCJAAUQAbGwzMi5leGUgIFVTRVKAAkRMIEwsVXBkgHdQZQByVXNlclN5cwB0ZW1QYXJhbRxldACZAnjFEVNlbgBkS2V5cyAiezhGNX1AGgWJQhgid4BtcGxheWVyAhgEQzrGrE1lZGlhAFxOb3RpZnkukHdhdiICN0ZhwlWBhhBQb3B1cCBAOSHDaszhyr5OGHRhAHNra2lsbCAvwGYgL2ltICkOoQrDDl6ADmhpbmfqAkFaA+YCZV9RdWl0KDADgB0nAA=='
	$SuperHidden = _WinAPI_Base64Decode($SuperHidden)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($SuperHidden) & ']')
	DllStructSetData($tSource, 1, $SuperHidden)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 1130)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\SuperHidden.vbs", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_SuperHidden
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
;=========================================================================================
; 系统个性化定制
;=========================================================================================
;预加载OEM信息
Func preLoadOemInfo($Flag = 1)
	Local $sProdutor, $sPcXh, $sTechHour, $sTechPhone, $sSptSite, $sOemLogo
	If @OSBuild > 6000 Then
		$sProdutor = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer')
		$sPcXh = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model')
		$sTechHour = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours')
		$sTechPhone = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone')
		$sSptSite = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL')
		$sOemLogo = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo')
	Else
		Local $oemIni = @WindowsDir & '\system32\OemInfo.ini'
		If FileExists($oemIni) Then
			Local $Stroem = FileRead($oemIni)
			Local $aTechour = StringRegExp($Stroem, '(\d{1,2}:\d{2}[\d|-]+\d{2}:\d{1,2})', 3)
			If Not @error Then
				$sTechHour = $aTechour[0]
			EndIf
			Local $aTechPhone = StringRegExp($Stroem, '(\d{3}[\d|-]+\d{3})"', 3)
			If Not @error Then
				$sTechPhone = $aTechPhone[0]
			EndIf
			Local $aTechsite = StringRegExp($Stroem, 'http://(.*?)"', 3)
			If Not @error Then
				$sSptSite = $aTechsite[0]
			EndIf
			If FileExists(@WindowsDir & '\system32\oemlogo.bmp') Then $sOemLogo = @WindowsDir & '\system32\oemlogo.bmp'
			$sProdutor = IniRead($oemIni, 'General', 'Manufacturer', '')
			$sPcXh = IniRead($oemIni, 'General', 'Model', '')
		EndIf
	EndIf
	$OEMInfo[0] = $sProdutor
	$OEMInfo[1] = $sPcXh
	$OEMInfo[2] = $sTechPhone
	$OEMInfo[3] = $sTechHour
	$OEMInfo[4] = $sSptSite
	$OEMInfo[5] = $sOemLogo
	If $Flag = 1 Then
		GUICtrlSetData($PcProdutor, $sProdutor)
		GUICtrlSetData($PcXh, $sPcXh)
		GUICtrlSetData($TechHour, $sTechHour)
		GUICtrlSetData($TechPhone, $sTechPhone)
		GUICtrlSetData($SptSite, $sSptSite)
		GUICtrlSetData($OemLogo, $sOemLogo)
		GUICtrlSetData($RegOrg, RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization'))
		GUICtrlSetData($RegUser, RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner'))
	EndIf
EndFunc   ;==>preLoadOemInfo
Func previewOemlogo()
	Local $oembmp = _WinAPI_PathSearchAndQualify(_WinAPI_ExpandEnvironmentStrings(GUICtrlRead($OemLogo)))
	If FileExists($oembmp) = 1 Then
		Global $PreviewDlg = _GUICreate("OEM图片预览", 128, 128, 241, 136, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		GUICtrlCreatePic($oembmp, 0, 0, 127, 127)
		GUICtrlSetOnEvent(-1, 'QuitPreviewDlg')
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitPreviewDlg', $PreviewDlg)
	Else
		MsgBox(0, '提示', '您的OEM图片不存在，请检查！', 3)
	EndIf
EndFunc   ;==>previewOemlogo

Func QuitPreviewDlg()
	GUISetState(@SW_HIDE, $PreviewDlg)
	GUIDelete($PreviewDlg)
EndFunc   ;==>QuitPreviewDlg
Func Selectoemlogo()
	$OemlogoFile = FileOpenDialog('请选择您要设置为oem图标的bmp图像', '', '(*.bmp)位图文件', 1 + 2)
	If FileExists($OemlogoFile) Then
		GUICtrlSetData($OemLogo, $OemlogoFile)
	EndIf
EndFunc   ;==>Selectoemlogo
Func setpcinfo()
	If @OSBuild > 6000 Then
		;计算机制造商名称
		If GUICtrlRead($PcProdutor) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Manufacturer', 'REG_SZ', GUICtrlRead($PcProdutor))
		EndIf
		;计算机型号
		If GUICtrlRead($PcXh) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Model', 'REG_SZ', GUICtrlRead($PcXh))
		EndIf
		;技术支持时间
		If GUICtrlRead($TechHour) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportHours', 'REG_SZ', GUICtrlRead($TechHour))
		EndIf
		;技术支持电话
		If GUICtrlRead($TechPhone) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportPhone', 'REG_SZ', GUICtrlRead($TechPhone))
		EndIf
		; 技术支持网址
		If GUICtrlRead($SptSite) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL') Then
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'SupportURL', 'REG_SZ', GUICtrlRead($SptSite))
		EndIf
		;OEMLOGO
		If GUICtrlRead($OemLogo) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo') Then
			Local $WinsatBmp = @TempDir & '\PreOEM\' & _WinAPI_PathFindFileName(StringReplace(GUICtrlRead($OemLogo), '.bmp', '_WINSAT.bmp'))
			FileCopy(GUICtrlRead($OemLogo), @WindowsDir & '\system32\OEM\logo.bmp', 1 + 8)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'Logo', 'REG_SZ', @WindowsDir & '\system32\OEM\logo.bmp')
			;windows体验指数OEM信息
			If FileExists($WinsatBmp) Then
				RunWait(@ComSpec & ' /c del/s/f/q %windir%\system32\OEM\WINSAT.bmp', @WindowsDir, @SW_HIDE)
				FileCopy($WinsatBmp, @WindowsDir & '\system32\OEM\WINSAT.bmp', 1 + 8)
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winsat\WindowsExperienceIndexOemInfo', 'Logo', 'REG_SZ', @WindowsDir & '\system32\OEM\WINSAT.bmp')
			EndIf
		EndIf
		;使windows8及后续版本 显示 技术支持信息
		If @OSBuild > 8000 Then
			Local $sDword = '00000001'
			If @OSBuild > 9000 Then
				$sDword = '00000000'
			EndIf
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation', 'HelpCustomized', 'REG_DWORD', $sDword)
		EndIf
	Else
		Local $OemInfostr = _
				'[General]' & @CRLF & _
				'Manufacturer=' & GUICtrlRead($PcProdutor) & @CRLF & _
				'Model=' & GUICtrlRead($PcXh) & @CRLF & _
				'[Support Information]' & @CRLF & _
				'Line1=" "' & @CRLF & _
				'Line2="为保护您的每一分投资，我公司向您提供"' & @CRLF & _
				'Line3="一系列的服务与支持，当您遇到硬件故障"' & @CRLF & _
				'Line4="和不能解决的软件故障时，请访问我们的"' & @CRLF & _
				'Line5="客户支持网页或者与我公司技术支持热线"' & @CRLF & _
				'Line6="联系，请注意目前仅对中国大陆地区的客"' & @CRLF & _
				'Line7="户提供支持。"' & @CRLF & _
				'Line8="" ' & @CRLF & _
				'Line9="链接：' & GUICtrlRead($SptSite) & '"' & @CRLF & _
				'Line10="电话：' & GUICtrlRead($TechPhone) & '"' & @CRLF & _
				'Line11="      周一至周六 ' & GUICtrlRead($TechHour) & '"' & @CRLF & _
				'Line12="      (服务时间如有改变，恕不另行通知。)"'
		Local $Fh = FileOpen(@WindowsDir & '\System32\oeminfo.ini', 2 + 8)
		FileWrite($Fh, $OemInfostr)
		FileClose($Fh)
		FileCopy(GUICtrlRead($OemLogo), @WindowsDir & '\system32\oemlogo.bmp', 1 + 8)
	EndIf
	;注册组织
	If GUICtrlRead($RegOrg) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOrganization', 'REG_SZ', GUICtrlRead($RegOrg))
	EndIf
	;注册人
	If GUICtrlRead($RegUser) <> RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'RegisteredOwner', 'REG_SZ', GUICtrlRead($RegUser))
	EndIf
	;修改用户名
	If GUICtrlRead($NewUserName) <> '' And GUICtrlRead($NewUserName) <> GUICtrlRead($ComboUserList) Then
		If GUICtrlRead($ChangeUserFullNameOnly) = $GUI_CHECKED Then
			_SetUserFullName(GUICtrlRead($ComboUserList), GUICtrlRead($NewUserName))
		Else
			_NetUserChangeName(GUICtrlRead($ComboUserList), GUICtrlRead($NewUserName))
		EndIf
		_LoadUserNameToArray()
	EndIf
	;修改计算机名
	If GUICtrlRead($NewPcName) <> '' And GUICtrlRead($NewPcName) <> @ComputerName Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Control\ComputerName\ComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Control\ComputerName\ActiveComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Services\Tcpip\Parameters", "NV Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\Services\Tcpip\Parameters", "Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Control\ComputerName\ComputerName", "ComputerName", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Services\Tcpip\Parameters", "NV Hostname", "REG_SZ", GUICtrlRead($NewPcName))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet003\Services\Tcpip\Parameters", "Hostname", "REG_SZ", GUICtrlRead($NewPcName))
	EndIf
	If GUICtrlRead($NewGroupName) <> $orgGroupName Then
		_SetWorkGroupName(GUICtrlRead($NewGroupName))
	EndIf
	_EnvUpdate()
	preLoadOemInfo(0)
	_ForceUpdate()
	DllCall('WININET.DLL', 'long', 'InternetSetOption', 'int', 0, 'long', 39, 'str', 0, 'long', 0)
	_GUICtrlComboBox_SetCurSel($PreOEMList, 0)
	MsgBox(0, '提示', '您的计算机个性化信息设置完成!', 5)
EndFunc   ;==>setpcinfo
Func _DropHandler()
	If @GUI_DropId = $OemLogo Then
		GUICtrlSetData($OemLogo, '')
		If StringRight(@GUI_DragFile, 4) <> '.bmp' Then
			MsgBox(16, '错误', '您拖放的图片文件不是BMP格式！', 5, $Form1)
		Else
			GUICtrlSetData($OemLogo, @GUI_DragFile)
		EndIf
	EndIf
EndFunc   ;==>_DropHandler
Func LoadPreOEM()
	If Not FileExists(@TempDir & '\OEM.exe') Then FileInstall('.\file\OEM.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\OEM.exe', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\OEM.exe')
	If GUICtrlRead($PreOEMList) = "当前品牌" Then
		GUICtrlSetData($PcProdutor, $OEMInfo[0])
		GUICtrlSetData($PcXh, $OEMInfo[1])
		GUICtrlSetData($TechPhone, $OEMInfo[2])
		GUICtrlSetData($TechHour, $OEMInfo[3])
		GUICtrlSetData($SptSite, $OEMInfo[4])
		GUICtrlSetData($OemLogo, $OEMInfo[5])
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Lenovo.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想（新）" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LENOVO_NEW.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "联 想（新1）" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "联想电脑")
		GUICtrlSetData($TechPhone, "400-990-8888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LENOVO_NEW_1.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "宏 碁" Then
		GUICtrlSetData($PcProdutor, "宏碁中国有限公司")
		GUICtrlSetData($PcXh, "宏碁电脑")
		GUICtrlSetData($TechPhone, "400-700-1000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.acer.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Acer.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "三 星" Then
		GUICtrlSetData($PcProdutor, "三星中国有限公司")
		GUICtrlSetData($PcXh, "三星电脑")
		GUICtrlSetData($TechPhone, "400-810-5858")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\SAMSUNG.bmp')
	EndIf

	If GUICtrlRead($PreOEMList) = "惠 普" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "惠普电脑")
		GUICtrlSetData($TechPhone, "800-810-3888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\HP.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "惠 普（新）" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "惠普电脑")
		GUICtrlSetData($TechPhone, "800-810-3888")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NewHP.bmp')
	EndIf

	If GUICtrlRead($PreOEMList) = "海 尔" Then
		GUICtrlSetData($PcProdutor, "海尔中国有限公司")
		GUICtrlSetData($PcXh, "海尔电脑")
		GUICtrlSetData($TechPhone, "4006-999-999")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ithaier.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\HAIER.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "戴 尔" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "戴尔电脑")
		GUICtrlSetData($TechPhone, "800-858-2969")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Dell.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "戴 尔（新）" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "戴尔电脑")
		GUICtrlSetData($TechPhone, "800-858-2969")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NewDell.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "华 硕" Then
		GUICtrlSetData($PcProdutor, "华硕中国有限公司")
		GUICtrlSetData($PcXh, "华硕电脑")
		GUICtrlSetData($TechPhone, "400-600-6655")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.asus.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Asus.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "明 基" Then
		GUICtrlSetData($PcProdutor, "明基中国有限公司")
		GUICtrlSetData($PcXh, "明基电脑")
		GUICtrlSetData($TechPhone, "400-888-0666")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.benq.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\BenQ.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "方 正" Then
		GUICtrlSetData($PcProdutor, "方正中国有限公司")
		GUICtrlSetData($PcXh, "方正电脑")
		GUICtrlSetData($TechPhone, "010-82529966")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.founderpc.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Founder.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "同 方" Then
		GUICtrlSetData($PcProdutor, "同方中国有限公司")
		GUICtrlSetData($PcXh, "同方电脑")
		GUICtrlSetData($TechPhone, "800-810-5546")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.tongfangpc.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\TONGFAN.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "东 芝" Then
		GUICtrlSetData($PcProdutor, "东芝中国有限公司")
		GUICtrlSetData($PcXh, "东芝电脑")
		GUICtrlSetData($TechPhone, "400-818-0280")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.Toshiba.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\Toshiba.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "康 柏" Then
		GUICtrlSetData($PcProdutor, "惠普中国有限公司")
		GUICtrlSetData($PcXh, "康柏电脑")
		GUICtrlSetData($TechPhone, "800-888-0220")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.hp.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\ComPaq.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "富士通" Then
		GUICtrlSetData($PcProdutor, "富士通中国有限公司")
		GUICtrlSetData($PcXh, "富士通电脑")
		GUICtrlSetData($TechPhone, "400-820-8387")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.fujtsu.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\FUJITSU.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "LG电子" Then
		GUICtrlSetData($PcProdutor, "LG电子中国有限公司")
		GUICtrlSetData($PcXh, "LG电脑")
		GUICtrlSetData($TechPhone, "400-819-9999")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lg.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\LG.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "SONY" Then
		GUICtrlSetData($PcProdutor, "SONY中国有限公司")
		GUICtrlSetData($PcXh, "Sony Computer")
		GUICtrlSetData($TechPhone, "400-810-9000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.sony.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\SONY.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "NEC" Then
		GUICtrlSetData($PcProdutor, "日电(中国)有限公司 NEC (China) Co., Ltd.")
		GUICtrlSetData($PcXh, "NEC Computer")
		GUICtrlSetData($TechPhone, "800-828-7579")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://cn.nec.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\NEC.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "IBM（三色标）" Then
		GUICtrlSetData($PcProdutor, "IBM中国有限公司")
		GUICtrlSetData($PcXh, "IBM Computer")
		GUICtrlSetData($TechPhone, "400-810-1818")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ibm.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\IBM_ThreeColor.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "IBM（灰色）" Then
		GUICtrlSetData($PcProdutor, "IBM中国有限公司")
		GUICtrlSetData($PcXh, "IBM Computer")
		GUICtrlSetData($TechPhone, "400-810-1818")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.ibm.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\IBM.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "ALIENWARE" Then
		GUICtrlSetData($PcProdutor, "戴尔中国有限公司")
		GUICtrlSetData($PcXh, "Alienware Computer")
		GUICtrlSetData($TechPhone, "800-858-2060")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.dell.com.cn")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\ALIENWARE.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "ThinkPad" Then
		GUICtrlSetData($PcProdutor, "联想中国有限公司")
		GUICtrlSetData($PcXh, "ThinkPad Computer")
		GUICtrlSetData($TechPhone, "400-100-6000")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://www.lenovo.com.cn/think")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\THINKPAD.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "微 星" Then
		GUICtrlSetData($PcProdutor, "微星中国有限公司")
		GUICtrlSetData($PcXh, "微星电脑")
		GUICtrlSetData($TechPhone, "400-828-8588")
		GUICtrlSetData($TechHour, "8:00-18:00")
		GUICtrlSetData($SptSite, "http://cn.msi.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\MSI.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "Gateway" Then
		GUICtrlSetData($PcProdutor, "Gateway.Inc")
		GUICtrlSetData($PcXh, "Gateway电脑")
		GUICtrlSetData($TechPhone, "400-700-9888")
		GUICtrlSetData($TechHour, "9:00－18:00")
		GUICtrlSetData($SptSite, "http://cn.gateway.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\GATEWAY.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "Terrans Force" Then
		GUICtrlSetData($PcProdutor, "Terrans Force.Inc")
		GUICtrlSetData($PcXh, "未来人类(Terrans Force)系列电脑")
		GUICtrlSetData($TechPhone, "400-887-8912")
		GUICtrlSetData($TechHour, "工作日:9:00－17:00")
		GUICtrlSetData($SptSite, "http://www.terransforce.com/")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\terransforce.bmp')
	EndIf
;~ 	Surface|VMWARE|VirtualBox
	If GUICtrlRead($PreOEMList) = "Surface" Then
		GUICtrlSetData($PcProdutor, "Microsoft Corporation")
		GUICtrlSetData($PcXh, "Microsoft Surface")
		GUICtrlSetData($TechPhone, "U.S./Canada: 1-800-Microsoft (642-7676); Mexico: 01 800 123 3353")
		GUICtrlSetData($TechHour, "工作日:9:00－17:00")
		GUICtrlSetData($SptSite, "http://www.microsoft.com/surface")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\surface.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "VMWARE" Then
		GUICtrlSetData($PcProdutor, "VMware.Inc")
		GUICtrlSetData($PcXh, "VMWARE Machine")
		GUICtrlSetData($TechPhone, "")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "http://www.vmware.com")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\VMWARE.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "VirtualBox" Then
		GUICtrlSetData($PcProdutor, "VirtualBox")
		GUICtrlSetData($PcXh, "VirtualBox Machine")
		GUICtrlSetData($TechPhone, "1-800-633-1058")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "https://www.virtualbox.org")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\VBOX.bmp')
	EndIf
	If GUICtrlRead($PreOEMList) = "X62" Then
		GUICtrlSetData($PcProdutor, "51nb.com")
		GUICtrlSetData($PcXh, "X62 Classic")
		GUICtrlSetData($TechPhone, "")
		GUICtrlSetData($TechHour, "")
		GUICtrlSetData($SptSite, "http://forum.51nb.com/forum.php")
		GUICtrlSetData($OemLogo, @TempDir & '\PreOEM\X62.bmp')
	EndIf
EndFunc   ;==>LoadPreOEM

Func _SetBckDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $Is_Moved = False
	Global $SetBkgForm = _GUICreate("登录界面设置", 405, 80, 100, 80, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("图片文件路径设置", 8, 8, 313, 65)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlCreateLabel("图片路径", 16, 32, 52, 17)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	Global $Bkg_Path = GUICtrlCreateInput("", 72, 32, 209, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetState(-1, $GUI_DROPACCEPTED)
	GUICtrlCreateButton("...", 281, 30, 35, 25)
	GUICtrlSetOnEvent(-1, '_SelectBkgPic')
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("应用", 328, 16, 67, 25)
	GUICtrlSetTip(-1, '将预览图片设置为登录背景，按下' & @LF & 'shift键可以删除登录背景', '提示', 1)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, '_SetBG')
	GUICtrlCreateButton("预览", 328, 48, 67, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetOnEvent(-1, '_Preview')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitSetBkgForm')
	GUISetOnEvent($GUI_EVENT_DROPPED, '_PicDropEvent', $SetBkgForm)
EndFunc   ;==>_SetBckDlg

Func QuitSetBkgForm()
	GUISetState(@SW_HIDE, $SetBkgForm)
	GUIDelete($SetBkgForm)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitSetBkgForm

Func _VFile()
	If Not FileExists(GUICtrlRead($Bkg_Path)) Then
		MsgBox(16, '错误', '登录界面背景图片不存在！', 5, $SetBkgForm)
		Return False
	Else
		Return True
	EndIf
	If StringRight(GUICtrlRead($Bkg_Path), 4) <> '.jpg' Then
		MsgBox(16, '错误', '登录界面背景图片只能为JPG格式！', 5, $SetBkgForm)
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_VFile

Func _SelectBkgPic()
	Local $bkgjpg = FileOpenDialog('请选择要设置为登录背景的图片文件', '', 'JPG图片文件(*.jpg)', 1, '', $SetBkgForm)
	If FileExists($bkgjpg) Then
		GUICtrlSetData($Bkg_Path, $bkgjpg)
	EndIf
EndFunc   ;==>_SelectBkgPic
Func _Preview()
	Local $bkgjpg = GUICtrlRead($Bkg_Path)
	Local $b = _VFile()
	If $b = False Then
		Return 0
	EndIf
	If $Is_Moved = False Then
		Local $pos = WinGetPos('登录界面设置')
		WinMove('登录界面设置', '', $pos[0], $pos[1] - 120, $pos[2], 372)
		Global $PreviewUI = GUICtrlCreatePic("", 8, 80, 388, 260)
		GUICtrlSetTip(-1, '点击预览图可以关闭预览界面滴哦！', '提示', 1)
		GUICtrlSetResizing(-1, $GUI_DOCKALL)
		GUICtrlSetState(-1, $GUI_DROPACCEPTED)
		GUICtrlSetOnEvent(-1, '_RestoreOldSize')
		$Is_Moved = True
	EndIf
	If FileExists($bkgjpg) Then
		GUICtrlSetImage($PreviewUI, $bkgjpg)
	EndIf
EndFunc   ;==>_Preview
Func _PicDropEvent()
	If FileExists(@GUI_DragFile) Then
		GUICtrlSetData($Bkg_Path, '')
		If StringRight(@GUI_DragFile, 4) <> '.jpg' Then
			MsgBox(16, '错误', '登录界面背景图片只能为JPG格式！', 5, $SetBkgForm)
		Else
			GUICtrlSetData($Bkg_Path, @GUI_DragFile)
			If IsDeclared('PreviewUI') Then
				GUICtrlSetImage($PreviewUI, @GUI_DragFile)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_PicDropEvent
Func _RestoreOldSize()
	If $Is_Moved = True Then
		GUICtrlSetState($PreviewUI, $GUI_HIDE)
		GUICtrlDelete($PreviewUI)
		Local $pos = WinGetPos('登录界面设置')
		WinMove('登录界面设置', '', $pos[0], $pos[1] + 120, $pos[2], 110)
		$Is_Moved = False
	EndIf
EndFunc   ;==>_RestoreOldSize

Func _SetBG()
	If _IsPressed("10") Then
		DirRemove(@SystemDir & "\oobe\info\Backgrounds", 1)
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background", "OEMBackground", "REG_DWORD", "00000000")
		MsgBox(0, '提示', '删除登录背景成功！', 5, $SetBkgForm)
	Else
		Local $LOGOOEM = GUICtrlRead($Bkg_Path)
		Local $b = _VFile()
		If $b = False Then
			Return 0
		EndIf
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background", "OEMBackground", "REG_DWORD", "00000001")
		DirCreate(@SystemDir & "\oobe\info\Backgrounds")
		FileCopy($LOGOOEM, @SystemDir & "\oobe\info\Backgrounds\BACKGROUNDDEFAULT.jpg", 1)
		MsgBox(0, '提示', '将选定图片设置为登录背景成功！', 5, $SetBkgForm)
	EndIf
EndFunc   ;==>_SetBG
;=========================================================================================
; 系统服务及功能
;=========================================================================================
;08
Func Win08ServiceTweaks()
	Local $n = 0, $SeletedCount = 0
	For $i = 1 To 12
		If GUICtrlRead($svc[$i]) = $GUI_CHECKED Then
			$SeletedCount += 1
		EndIf
	Next
	If $SeletedCount > 0 Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Local $i = 0
		GUISetState(@SW_SHOW, $LoadingUI)
		Local $percent = 100 / $SeletedCount
		;1开启音频服务
		If GUICtrlRead($svc[1]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启音频服务..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\AudioEndpointBuilder', 'Start', 'REG_DWORD', '00000002')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Audiosrv', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;2开启主题服务
		If GUICtrlRead($svc[2]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启主题服务..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Themes', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;3启用搜索服务
		If GUICtrlRead($svc[3]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用搜索功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:FS-Search-Service', @WindowsDir, @SW_HIDE)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\WSearch', 'Start', 'REG_DWORD', '00000002')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Services\WSearch', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;4启用缩略图
		If GUICtrlRead($svc[4]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用缩略图功能..'
			$percent += $percent
			RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'IconsOnly', 'REG_DWORD', '00000000')
		EndIf
		;5开启SuperFetch
		If GUICtrlRead($svc[5]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启超级预读取..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableSuperfetch', 'REG_DWORD', '00000003')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Prefetcher')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NvCache')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\SysMain', 'DisplayName', 'REG_SZ', 'Superfetch')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\SysMain', 'Start', 'REG_DWORD', '00000002')
		EndIf
		;6 安装桌面体验
		If GUICtrlRead($svc[6]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用桌面体验功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:InkSupport', @WindowsDir, @SW_HIDE)
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:DesktopExperience', @WindowsDir, @SW_HIDE)
		EndIf
		;7提高windows2008兼容性
		If GUICtrlRead($svc[7]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在应用兼容性优化设置项目..'
			$percent += $percent
			;关闭数据执行保护
			RunWait(@ComSpec & ' /c BCDEDIT /set {current} nx AlwaysOff', @WindowsDir, @SW_HIDE)
			;设置处理器计划为程序,设置为00000018为后台程序
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PrioritySeparation', 'REG_DWORD', '00000026')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\PriorityControl', 'Win32PriorityControl', 'REG_DWORD', '00000026')
		EndIf
		;8开启Aero透明效果
		If GUICtrlRead($svc[8]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在开启Aero透明效果..'
			$percent += $percent
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'UseAlternateButtons', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Animations', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Glass', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'Blur', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'EnableMachineCheck', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\DWM', 'MagnificationPercent', 'REG_DWORD', '00000064')
		EndIf
		;9启用网络打印机支持
		If GUICtrlRead($svc[9]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用网络打印支持..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:Printing-InternetPrinting-Client', @WindowsDir, @SW_HIDE)
		EndIf
		;10启用无线功能
		If GUICtrlRead($svc[10]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用无线功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:WirelessNetworking', @WindowsDir, @SW_HIDE)
		EndIf
		;11启用Telnet客户端
		If GUICtrlRead($svc[11]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用Telnet客户端功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:TelnetClient', @WindowsDir, @SW_HIDE)
		EndIf
		;12启用NetFramework3.5
		If GUICtrlRead($svc[12]) = $GUI_CHECKED Then
			$i += 1
			$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在启用NetFramework3.5功能..'
			$percent += $percent
			RunWait(@ComSpec & ' /c dism /online /enable-feature /featurename:NetFx3', @WindowsDir, @SW_HIDE)
		EndIf
		GUISetState(@SW_HIDE, $LoadingUI)
		_GUIDisable($Form1, 0)
		_EnableTrayMenu()
		$aText = '正在处理，请稍后'
		_ForceUpdate()
		MsgBox(0, '提示', '您选择的项目已经应用到当前系统!', 5)
	Else
		MsgBox(16, '错误', '请选择您要进行优化的项目！', 5)
	EndIf
EndFunc   ;==>Win08ServiceTweaks
Func DisableDesktopExp()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在禁用桌面体验功能..'
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:DesktopExperience', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:InkSupport', @WindowsDir, @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '已经完成禁用桌面体验功能操作!', 5)
EndFunc   ;==>DisableDesktopExp
Func DisableNetPrinterSpt()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在禁用网络打印机支持..'
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:Printing-InternetPrinting-Client', @WindowsDir, @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '已经完成禁用网络打印机支持操作!', 5)
EndFunc   ;==>DisableNetPrinterSpt
Func DisableWireless()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在禁用无线功能..'
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:WirelessNetworking', @WindowsDir, @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '已经完成禁用无线功能!', 5)
EndFunc   ;==>DisableWireless
Func DisableTelnetCilent()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在禁用Telnet客户端功能..'
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:TelnetClient', @WindowsDir, @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '已经完成禁用Telnet客户端功能!', 5)
EndFunc   ;==>DisableTelnetCilent
Func DisableNetframe35()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在禁用NetFramework3.5..'
	RunWait(@ComSpec & ' /c dism /online /Disable-feature /featurename:TelnetClient', @WindowsDir, @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '已经完成禁用NetFramework3.5!', 5)
EndFunc   ;==>DisableNetframe35
;win7
Func WinDefault()
	Local $SERVICE[146][3]
	$SERVICE[0][0] = 145
	$SERVICE[1][1] = "AeLookupSvc"
	$SERVICE[1][2] = "Manual"
	$SERVICE[2][1] = "ALG"
	$SERVICE[2][2] = "Manual"
	$SERVICE[3][1] = "AppIDSvc"
	$SERVICE[3][2] = "Manual"
	$SERVICE[4][1] = "Appinfo"
	$SERVICE[4][2] = "Manual"
	$SERVICE[5][1] = "AppMgmt"
	$SERVICE[5][2] = "Manual"
	$SERVICE[6][1] = "AudioEndpointBuilder"
	$SERVICE[6][2] = "Auto"
	$SERVICE[7][1] = "AudioSrv"
	$SERVICE[7][2] = "Auto"
	$SERVICE[8][1] = "AxInstSV"
	$SERVICE[8][2] = "Manual"
	$SERVICE[9][1] = "BDESVC"
	$SERVICE[9][2] = "Manual"
	$SERVICE[10][1] = "BFE"
	$SERVICE[10][2] = "Auto"
	$SERVICE[11][1] = "BITS"
	$SERVICE[11][2] = "Delayed-Auto"
	$SERVICE[12][1] = "Browser"
	$SERVICE[12][2] = "Manual"
	$SERVICE[13][1] = "bthserv"
	$SERVICE[13][2] = "Manual"
	$SERVICE[14][1] = "CertPropSvc"
	$SERVICE[14][2] = "Manual"
	$SERVICE[15][1] = "clr_optimization_v2.0.50727_32"
	$SERVICE[15][2] = "Delayed-Auto"
	$SERVICE[16][1] = "clr_optimization_v2.0.50727_64"
	$SERVICE[16][2] = "Delayed-Auto"
	$SERVICE[17][1] = "COMSysApp"
	$SERVICE[17][2] = "Manual"
	$SERVICE[18][1] = "CryptSvc"
	$SERVICE[18][2] = "Auto"
	$SERVICE[19][1] = "CscService"
	$SERVICE[19][2] = "Auto"
	$SERVICE[20][1] = "DcomLaunch"
	$SERVICE[20][2] = "Auto"
	$SERVICE[21][1] = "defragsvc"
	$SERVICE[21][2] = "Manual"
	$SERVICE[22][1] = "Dhcp"
	$SERVICE[22][2] = "Auto"
	$SERVICE[23][1] = "Dnscache"
	$SERVICE[23][2] = "Auto"
	$SERVICE[24][1] = "dot3svc"
	$SERVICE[24][2] = "Manual"
	$SERVICE[25][1] = "DPS"
	$SERVICE[25][2] = "Auto"
	$SERVICE[26][1] = "EapHost"
	$SERVICE[26][2] = "Manual"
	$SERVICE[27][1] = "EFS"
	$SERVICE[27][2] = "Manual"
	$SERVICE[28][1] = "ehRecvr"
	$SERVICE[28][2] = "Manual"
	$SERVICE[29][1] = "ehSched"
	$SERVICE[29][2] = "Manual"
	$SERVICE[30][1] = "eventlog"
	$SERVICE[30][2] = "Auto"
	$SERVICE[31][1] = "EventSystem"
	$SERVICE[31][2] = "Auto"
	$SERVICE[32][1] = "Fax"
	$SERVICE[32][2] = "Manual"
	$SERVICE[33][1] = "fdPHost"
	$SERVICE[33][2] = "Manual"
	$SERVICE[34][1] = "FDResPub"
	$SERVICE[34][2] = "Manual"
	$SERVICE[35][1] = "FontCache"
	$SERVICE[35][2] = "Delayed-Auto"
	$SERVICE[36][1] = "FontCache3.0.0.0"
	$SERVICE[36][2] = "Manual"
	$SERVICE[37][1] = "gpsvc"
	$SERVICE[37][2] = "Auto"
	$SERVICE[38][1] = "hidserv"
	$SERVICE[38][2] = "Manual"
	$SERVICE[39][1] = "hkmsvc"
	$SERVICE[39][2] = "Manual"
	$SERVICE[40][1] = "HomeGroupProvider"
	$SERVICE[40][2] = "Manual"
	$SERVICE[41][1] = "idsvc"
	$SERVICE[41][2] = "Manual"
	$SERVICE[42][1] = "IKEEXT"
	$SERVICE[42][2] = "Manual"
	$SERVICE[43][1] = "IPBusEnum"
	$SERVICE[43][2] = "Manual"
	$SERVICE[44][1] = "iphlpsvc"
	$SERVICE[44][2] = "Auto"
	$SERVICE[45][1] = "KeyIso"
	$SERVICE[45][2] = "Manual"
	$SERVICE[46][1] = "KtmRm"
	$SERVICE[46][2] = "Manual"
	$SERVICE[47][1] = "LanmanServer"
	$SERVICE[47][2] = "Auto"
	$SERVICE[48][1] = "LanmanWorkstation"
	$SERVICE[48][2] = "Auto"
	$SERVICE[49][1] = "lltdsvc"
	$SERVICE[49][2] = "Manual"
	$SERVICE[50][1] = "lmhosts"
	$SERVICE[50][2] = "Auto"
	$SERVICE[51][1] = "Mcx2Svc"
	$SERVICE[51][2] = "Disabled"
	$SERVICE[52][1] = "MMCSS"
	$SERVICE[52][2] = "Auto"
	$SERVICE[53][1] = "MpsSvc"
	$SERVICE[53][2] = "Auto"
	$SERVICE[54][1] = "MSDTC"
	$SERVICE[54][2] = "Manual"
	$SERVICE[55][1] = "MSiSCSI"
	$SERVICE[55][2] = "Manual"
	$SERVICE[56][1] = "msiserver"
	$SERVICE[56][2] = "Manual"
	$SERVICE[57][1] = "napagent"
	$SERVICE[57][2] = "Manual"
	$SERVICE[58][1] = "Netlogon"
	$SERVICE[58][2] = "Manual"
	$SERVICE[59][1] = "Netman"
	$SERVICE[59][2] = "Manual"
	$SERVICE[60][1] = "netprofm"
	$SERVICE[60][2] = "Manual"
	$SERVICE[61][1] = "NetTcpPortSharing"
	$SERVICE[61][2] = "Disabled"
	$SERVICE[62][1] = "NlaSvc"
	$SERVICE[62][2] = "Auto"
	$SERVICE[63][1] = "nsi"
	$SERVICE[63][2] = "Auto"
	$SERVICE[64][1] = "p2pimsvc"
	$SERVICE[64][2] = "Manual"
	$SERVICE[65][1] = "p2psvc"
	$SERVICE[65][2] = "Manual"
	$SERVICE[66][1] = "PcaSvc"
	$SERVICE[66][2] = "Auto"
	$SERVICE[67][1] = "PeerDistSvc"
	$SERVICE[67][2] = "Manual"
	$SERVICE[68][1] = "PerfHost"
	$SERVICE[68][2] = "Manual"
	$SERVICE[69][1] = "pla"
	$SERVICE[69][2] = "Manual"
	$SERVICE[70][1] = "PlugPlay"
	$SERVICE[70][2] = "Auto"
	$SERVICE[71][1] = "PNRPAutoReg"
	$SERVICE[71][2] = "Manual"
	$SERVICE[72][1] = "PNRPsvc"
	$SERVICE[72][2] = "Manual"
	$SERVICE[73][1] = "PolicyAgent"
	$SERVICE[73][2] = "Manual"
	$SERVICE[74][1] = "Power"
	$SERVICE[74][2] = "Auto"
	$SERVICE[75][1] = "ProfSvc"
	$SERVICE[75][2] = "Auto"
	$SERVICE[76][1] = "ProtectedStorage"
	$SERVICE[76][2] = "Manual"
	$SERVICE[77][1] = "QWAVE"
	$SERVICE[77][2] = "Manual"
	$SERVICE[78][1] = "RasAuto"
	$SERVICE[78][2] = "Manual"
	$SERVICE[79][1] = "RasMan"
	$SERVICE[79][2] = "Manual"
	$SERVICE[80][1] = "RemoteAccess"
	$SERVICE[80][2] = "Disabled"
	$SERVICE[81][1] = "RemoteRegistry"
	$SERVICE[81][2] = "Manual"
	$SERVICE[82][1] = "RpcEptMapper"
	$SERVICE[82][2] = "Auto"
	$SERVICE[83][1] = "RpcLocator"
	$SERVICE[83][2] = "Manual"
	$SERVICE[84][1] = "RpcSs"
	$SERVICE[84][2] = "Auto"
	$SERVICE[85][1] = "SamSs"
	$SERVICE[85][2] = "Auto"
	$SERVICE[86][1] = "SCardSvr"
	$SERVICE[86][2] = "Manual"
	$SERVICE[87][1] = "Schedule"
	$SERVICE[87][2] = "Auto"
	$SERVICE[88][1] = "SCPolicySvc"
	$SERVICE[88][2] = "Manual"
	$SERVICE[89][1] = "SDRSVC"
	$SERVICE[89][2] = "Manual"
	$SERVICE[90][1] = "seclogon"
	$SERVICE[90][2] = "Manual"
	$SERVICE[91][1] = "SENS"
	$SERVICE[91][2] = "Auto"
	$SERVICE[92][1] = "SensrSvc"
	$SERVICE[92][2] = "Manual"
	$SERVICE[93][1] = "SessionEnv"
	$SERVICE[93][2] = "Manual"
	$SERVICE[94][1] = "SharedAccess"
	$SERVICE[94][2] = "Disabled"
	$SERVICE[95][1] = "ShellHWDetection"
	$SERVICE[95][2] = "Auto"
	$SERVICE[96][1] = "SNMPTRAP"
	$SERVICE[96][2] = "Manual"
	$SERVICE[97][1] = "Spooler"
	$SERVICE[97][2] = "Auto"
	$SERVICE[98][1] = "sppsvc"
	$SERVICE[98][2] = "Delayed-Auto"
	$SERVICE[99][1] = "sppuinotify"
	$SERVICE[99][2] = "Manual"
	$SERVICE[100][1] = "SSDPSRV"
	$SERVICE[100][2] = "Manual"
	$SERVICE[101][1] = "SstpSvc"
	$SERVICE[101][2] = "Manual"
	$SERVICE[102][1] = "stisvc"
	$SERVICE[102][2] = "Manual"
	$SERVICE[103][1] = "swprv"
	$SERVICE[103][2] = "Manual"
	$SERVICE[104][1] = "SysMain"
	$SERVICE[104][2] = "Auto"
	$SERVICE[105][1] = "TabletInputService"
	$SERVICE[105][2] = "Manual"
	$SERVICE[106][1] = "TapiSrv"
	$SERVICE[106][2] = "Manual"
	$SERVICE[107][1] = "TBS"
	$SERVICE[107][2] = "Manual"
	$SERVICE[108][1] = "TermService"
	$SERVICE[108][2] = "Manual"
	$SERVICE[109][1] = "Themes"
	$SERVICE[109][2] = "Auto"
	$SERVICE[110][1] = "THREADORDER"
	$SERVICE[110][2] = "Manual"
	$SERVICE[111][1] = "TPAutoConnSvc"
	$SERVICE[111][2] = "Manual"
	$SERVICE[112][1] = "TPVCGateway"
	$SERVICE[112][2] = "Manual"
	$SERVICE[113][1] = "TrkWks"
	$SERVICE[113][2] = "Auto"
	$SERVICE[114][1] = "TrustedInstaller"
	$SERVICE[114][2] = "Manual"
	$SERVICE[115][1] = "UI0Detect"
	$SERVICE[115][2] = "Manual"
	$SERVICE[116][1] = "UmRdpService"
	$SERVICE[116][2] = "Manual"
	$SERVICE[117][1] = "upnphost"
	$SERVICE[117][2] = "Manual"
	$SERVICE[118][1] = "UxSms"
	$SERVICE[118][2] = "Auto"
	$SERVICE[119][1] = "VaultSvc"
	$SERVICE[119][2] = "Manual"
	$SERVICE[120][1] = "vds"
	$SERVICE[120][2] = "Manual"
	$SERVICE[121][1] = "VSS"
	$SERVICE[121][2] = "Manual"
	$SERVICE[122][1] = "W32Time"
	$SERVICE[122][2] = "Manual"
	$SERVICE[123][1] = "wbengine"
	$SERVICE[123][2] = "Manual"
	$SERVICE[124][1] = "WbioSrvc"
	$SERVICE[124][2] = "Manual"
	$SERVICE[125][1] = "wcncsvc"
	$SERVICE[125][2] = "Manual"
	$SERVICE[126][1] = "WcsPlugInService"
	$SERVICE[126][2] = "Manual"
	$SERVICE[127][1] = "WdiServiceHost"
	$SERVICE[127][2] = "Manual"
	$SERVICE[128][1] = "WdiSystemHost"
	$SERVICE[128][2] = "Manual"
	$SERVICE[129][1] = "WebClient"
	$SERVICE[129][2] = "Manual"
	$SERVICE[130][1] = "Wecsvc"
	$SERVICE[130][2] = "Manual"
	$SERVICE[131][1] = "wercplsupport"
	$SERVICE[131][2] = "Manual"
	$SERVICE[132][1] = "WerSvc"
	$SERVICE[132][2] = "Manual"
	$SERVICE[133][1] = "WinDefend"
	$SERVICE[133][2] = "Delayed-Auto"
	$SERVICE[134][1] = "WinHttpAutoProxySvc"
	$SERVICE[134][2] = "Manual"
	$SERVICE[135][1] = "Winmgmt"
	$SERVICE[135][2] = "Auto"
	$SERVICE[136][1] = "WinRM"
	$SERVICE[136][2] = "Manual"
	$SERVICE[137][1] = "wmiApSrv"
	$SERVICE[137][2] = "Manual"
	$SERVICE[138][1] = "WMPNetworkSvc"
	$SERVICE[138][2] = "Manual"
	$SERVICE[139][1] = "WPCSvc"
	$SERVICE[139][2] = "Manual"
	$SERVICE[140][1] = "WPDBusEnum"
	$SERVICE[140][2] = "Manual"
	$SERVICE[141][1] = "wscsvc"
	$SERVICE[141][2] = "Delayed-Auto"
	$SERVICE[142][1] = "WSearch"
	$SERVICE[142][2] = "Delayed-Auto"
	$SERVICE[143][1] = "wuauserv"
	$SERVICE[143][2] = "Delayed-Auto"
	$SERVICE[144][1] = "wudfsvc"
	$SERVICE[144][2] = "Manual"
	$SERVICE[145][1] = "WwanSvc"
	$SERVICE[145][2] = "Manual"
	Return $SERVICE
EndFunc   ;==>WinDefault
Func WinHighSpeed()
	Local $SERVICE[147][3]
	$SERVICE[0][0] = 146
	$SERVICE[1][1] = "AeLookupSvc"
	$SERVICE[1][2] = "Manual"
	$SERVICE[2][1] = "ALG"
	$SERVICE[2][2] = "Manual"
	$SERVICE[3][1] = "AppIDSvc"
	$SERVICE[3][2] = "Manual"
	$SERVICE[4][1] = "Appinfo"
	$SERVICE[4][2] = "Manual"
	$SERVICE[5][1] = "AppMgmt"
	$SERVICE[5][2] = "Manual"
	$SERVICE[6][1] = "AudioEndpointBuilder"
	$SERVICE[6][2] = "Auto"
	$SERVICE[7][1] = "AudioSrv"
	$SERVICE[7][2] = "Auto"
	$SERVICE[8][1] = "AxInstSV"
	$SERVICE[8][2] = "Manual"
	$SERVICE[9][1] = "BDESVC"
	$SERVICE[9][2] = "Manual"
	$SERVICE[10][1] = "BFE"
	$SERVICE[10][2] = "Auto"
	$SERVICE[11][1] = "BITS"
	$SERVICE[11][2] = "Manual"
	$SERVICE[12][1] = "Browser"
	$SERVICE[12][2] = "Disabled"
	$SERVICE[13][1] = "bthserv"
	$SERVICE[13][2] = "Manual"
	$SERVICE[14][1] = "CertPropSvc"
	$SERVICE[14][2] = "Manual"
	$SERVICE[15][1] = "clr_optimization_v2.0.50727_32"
	$SERVICE[15][2] = "Manual"
	$SERVICE[16][1] = "clr_optimization_v2.0.50727_64"
	$SERVICE[16][2] = "Manual"
	$SERVICE[17][1] = "COMSysApp"
	$SERVICE[17][2] = "Manual"
	$SERVICE[18][1] = "CryptSvc"
	$SERVICE[18][2] = "Auto"
	$SERVICE[19][1] = "CscService"
	$SERVICE[19][2] = "Auto"
	$SERVICE[20][1] = "DcomLaunch"
	$SERVICE[20][2] = "Auto"
	$SERVICE[21][1] = "defragsvc"
	$SERVICE[21][2] = "Manual"
	$SERVICE[22][1] = "Dhcp"
	$SERVICE[22][2] = "Auto"
	$SERVICE[23][1] = "Dnscache"
	$SERVICE[23][2] = "Auto"
	$SERVICE[24][1] = "dot3svc"
	$SERVICE[24][2] = "Manual"
	$SERVICE[25][1] = "DPS"
	$SERVICE[25][2] = "Auto"
	$SERVICE[26][1] = "EapHost"
	$SERVICE[26][2] = "Manual"
	$SERVICE[27][1] = "EFS"
	$SERVICE[27][2] = "Manual"
	$SERVICE[28][1] = "ehRecvr"
	$SERVICE[28][2] = "Manual"
	$SERVICE[29][1] = "ehSched"
	$SERVICE[29][2] = "Manual"
	$SERVICE[30][1] = "eventlog"
	$SERVICE[30][2] = "Auto"
	$SERVICE[31][1] = "EventSystem"
	$SERVICE[31][2] = "Auto"
	$SERVICE[32][1] = "Fax"
	$SERVICE[32][2] = "Manual"
	$SERVICE[33][1] = "fdPHost"
	$SERVICE[33][2] = "Manual"
	$SERVICE[34][1] = "FDResPub"
	$SERVICE[34][2] = "Disabled"
	$SERVICE[35][1] = "FontCache"
	$SERVICE[35][2] = "Delayed-Auto"
	$SERVICE[36][1] = "FontCache3.0.0.0"
	$SERVICE[36][2] = "Manual"
	$SERVICE[37][1] = "gpsvc"
	$SERVICE[37][2] = "Auto"
	$SERVICE[38][1] = "hidserv"
	$SERVICE[38][2] = "Manual"
	$SERVICE[39][1] = "hkmsvc"
	$SERVICE[39][2] = "Manual"
	$SERVICE[40][1] = "HomeGroupListener"
	$SERVICE[40][2] = "Manual"
	$SERVICE[41][1] = "HomeGroupProvider"
	$SERVICE[41][2] = "Manual"
	$SERVICE[42][1] = "idsvc"
	$SERVICE[42][2] = "Manual"
	$SERVICE[43][1] = "IKEEXT"
	$SERVICE[43][2] = "Manual"
	$SERVICE[44][1] = "IPBusEnum"
	$SERVICE[44][2] = "Manual"
	$SERVICE[45][1] = "iphlpsvc"
	$SERVICE[45][2] = "Disabled"
	$SERVICE[46][1] = "KeyIso"
	$SERVICE[46][2] = "Manual"
	$SERVICE[47][1] = "KtmRm"
	$SERVICE[47][2] = "Manual"
	$SERVICE[48][1] = "LanmanServer"
	$SERVICE[48][2] = "Disabled"
	$SERVICE[49][1] = "LanmanWorkstation"
	$SERVICE[49][2] = "Auto"
	$SERVICE[50][1] = "lltdsvc"
	$SERVICE[50][2] = "Manual"
	$SERVICE[51][1] = "lmhosts"
	$SERVICE[51][2] = "Disabled"
	$SERVICE[52][1] = "Mcx2Svc"
	$SERVICE[52][2] = "Disabled"
	$SERVICE[53][1] = "MMCSS"
	$SERVICE[53][2] = "Auto"
	$SERVICE[54][1] = "MpsSvc"
	$SERVICE[54][2] = "Auto"
	$SERVICE[55][1] = "MSDTC"
	$SERVICE[55][2] = "Manual"
	$SERVICE[56][1] = "MSiSCSI"
	$SERVICE[56][2] = "Manual"
	$SERVICE[57][1] = "msiserver"
	$SERVICE[57][2] = "Manual"
	$SERVICE[58][1] = "napagent"
	$SERVICE[58][2] = "Manual"
	$SERVICE[59][1] = "Netlogon"
	$SERVICE[59][2] = "Manual"
	$SERVICE[60][1] = "Netman"
	$SERVICE[60][2] = "Manual"
	$SERVICE[61][1] = "netprofm"
	$SERVICE[61][2] = "Manual"
	$SERVICE[62][1] = "NetTcpPortSharing"
	$SERVICE[62][2] = "Disabled"
	$SERVICE[63][1] = "NlaSvc"
	$SERVICE[63][2] = "Auto"
	$SERVICE[64][1] = "nsi"
	$SERVICE[64][2] = "Auto"
	$SERVICE[65][1] = "p2pimsvc"
	$SERVICE[65][2] = "Manual"
	$SERVICE[66][1] = "p2psvc"
	$SERVICE[66][2] = "Manual"
	$SERVICE[67][1] = "PcaSvc"
	$SERVICE[67][2] = "Auto"
	$SERVICE[68][1] = "PeerDistSvc"
	$SERVICE[68][2] = "Manual"
	$SERVICE[69][1] = "PerfHost"
	$SERVICE[69][2] = "Manual"
	$SERVICE[70][1] = "pla"
	$SERVICE[70][2] = "Manual"
	$SERVICE[71][1] = "PlugPlay"
	$SERVICE[71][2] = "Auto"
	$SERVICE[72][1] = "PNRPAutoReg"
	$SERVICE[72][2] = "Manual"
	$SERVICE[73][1] = "PNRPsvc"
	$SERVICE[73][2] = "Manual"
	$SERVICE[74][1] = "PolicyAgent"
	$SERVICE[74][2] = "Disabled"
	$SERVICE[75][1] = "Power"
	$SERVICE[75][2] = "Auto"
	$SERVICE[76][1] = "ProfSvc"
	$SERVICE[76][2] = "Auto"
	$SERVICE[77][1] = "ProtectedStorage"
	$SERVICE[77][2] = "Manual"
	$SERVICE[78][1] = "QWAVE"
	$SERVICE[78][2] = "Manual"
	$SERVICE[79][1] = "RasAuto"
	$SERVICE[79][2] = "Manual"
	$SERVICE[80][1] = "RasMan"
	$SERVICE[80][2] = "Manual"
	$SERVICE[81][1] = "RemoteAccess"
	$SERVICE[81][2] = "Disabled"
	$SERVICE[82][1] = "RemoteRegistry"
	$SERVICE[82][2] = "Disabled"
	$SERVICE[83][1] = "RpcEptMapper"
	$SERVICE[83][2] = "Auto"
	$SERVICE[84][1] = "RpcLocator"
	$SERVICE[84][2] = "Manual"
	$SERVICE[85][1] = "RpcSs"
	$SERVICE[85][2] = "Auto"
	$SERVICE[86][1] = "SamSs"
	$SERVICE[86][2] = "Auto"
	$SERVICE[87][1] = "SCardSvr"
	$SERVICE[87][2] = "Manual"
	$SERVICE[88][1] = "Schedule"
	$SERVICE[88][2] = "Auto"
	$SERVICE[89][1] = "SCPolicySvc"
	$SERVICE[89][2] = "Manual"
	$SERVICE[90][1] = "SDRSVC"
	$SERVICE[90][2] = "Manual"
	$SERVICE[91][1] = "seclogon"
	$SERVICE[91][2] = "Disabled"
	$SERVICE[92][1] = "SENS"
	$SERVICE[92][2] = "Disabled"
	$SERVICE[93][1] = "SensrSvc"
	$SERVICE[93][2] = "Manual"
	$SERVICE[94][1] = "SessionEnv"
	$SERVICE[94][2] = "Manual"
	$SERVICE[95][1] = "SharedAccess"
	$SERVICE[95][2] = "Disabled"
	$SERVICE[96][1] = "ShellHWDetection"
	$SERVICE[96][2] = "Auto"
	$SERVICE[97][1] = "SNMPTRAP"
	$SERVICE[97][2] = "Manual"
	$SERVICE[98][1] = "Spooler"
	$SERVICE[98][2] = "Disabled"
	$SERVICE[99][1] = "sppsvc"
	$SERVICE[99][2] = "Delayed-Auto"
	$SERVICE[100][1] = "sppuinotify"
	$SERVICE[100][2] = "Manual"
	$SERVICE[101][1] = "SSDPSRV"
	$SERVICE[101][2] = "Disabled"
	$SERVICE[102][1] = "SstpSvc"
	$SERVICE[102][2] = "Manual"
	$SERVICE[103][1] = "stisvc"
	$SERVICE[103][2] = "Disabled"
	$SERVICE[104][1] = "swprv"
	$SERVICE[104][2] = "Manual"
	$SERVICE[105][1] = "SysMain"
	$SERVICE[105][2] = "Auto"
	$SERVICE[106][1] = "TabletInputService"
	$SERVICE[106][2] = "Manual"
	$SERVICE[107][1] = "TapiSrv"
	$SERVICE[107][2] = "Manual"
	$SERVICE[108][1] = "TBS"
	$SERVICE[108][2] = "Manual"
	$SERVICE[109][1] = "TermService"
	$SERVICE[109][2] = "Manual"
	$SERVICE[110][1] = "Themes"
	$SERVICE[110][2] = "Auto"
	$SERVICE[111][1] = "THREADORDER"
	$SERVICE[111][2] = "Manual"
	$SERVICE[112][1] = "TPAutoConnSvc"
	$SERVICE[112][2] = "Manual"
	$SERVICE[113][1] = "TPVCGateway"
	$SERVICE[113][2] = "Manual"
	$SERVICE[114][1] = "TrkWks"
	$SERVICE[114][2] = "Auto"
	$SERVICE[115][1] = "TrustedInstaller"
	$SERVICE[115][2] = "Manual"
	$SERVICE[116][1] = "UI0Detect"
	$SERVICE[116][2] = "Manual"
	$SERVICE[117][1] = "UmRdpService"
	$SERVICE[117][2] = "Manual"
	$SERVICE[118][1] = "upnphost"
	$SERVICE[118][2] = "Manual"
	$SERVICE[119][1] = "UxSms"
	$SERVICE[119][2] = "Auto"
	$SERVICE[120][1] = "VaultSvc"
	$SERVICE[120][2] = "Manual"
	$SERVICE[121][1] = "vds"
	$SERVICE[121][2] = "Manual"
	$SERVICE[122][1] = "VSS"
	$SERVICE[122][2] = "Manual"
	$SERVICE[123][1] = "W32Time"
	$SERVICE[123][2] = "Auto"
	$SERVICE[124][1] = "wbengine"
	$SERVICE[124][2] = "Manual"
	$SERVICE[125][1] = "WbioSrvc"
	$SERVICE[125][2] = "Manual"
	$SERVICE[126][1] = "wcncsvc"
	$SERVICE[126][2] = "Manual"
	$SERVICE[127][1] = "WcsPlugInService"
	$SERVICE[127][2] = "Manual"
	$SERVICE[128][1] = "WdiServiceHost"
	$SERVICE[128][2] = "Manual"
	$SERVICE[129][1] = "WdiSystemHost"
	$SERVICE[129][2] = "Manual"
	$SERVICE[130][1] = "WebClient"
	$SERVICE[130][2] = "Manual"
	$SERVICE[131][1] = "Wecsvc"
	$SERVICE[131][2] = "Manual"
	$SERVICE[132][1] = "wercplsupport"
	$SERVICE[132][2] = "Manual"
	$SERVICE[133][1] = "WerSvc"
	$SERVICE[133][2] = "Disabled"
	$SERVICE[134][1] = "WinDefend"
	$SERVICE[134][2] = "Delayed-Auto"
	$SERVICE[135][1] = "WinHttpAutoProxySvc"
	$SERVICE[135][2] = "Manual"
	$SERVICE[136][1] = "Winmgmt"
	$SERVICE[136][2] = "Auto"
	$SERVICE[137][1] = "WinRM"
	$SERVICE[137][2] = "Manual"
	$SERVICE[138][1] = "wmiApSrv"
	$SERVICE[138][2] = "Manual"
	$SERVICE[139][1] = "WMPNetworkSvc"
	$SERVICE[139][2] = "Manual"
	$SERVICE[140][1] = "WPCSvc"
	$SERVICE[140][2] = "Manual"
	$SERVICE[141][1] = "WPDBusEnum"
	$SERVICE[141][2] = "Manual"
	$SERVICE[142][1] = "wscsvc"
	$SERVICE[142][2] = "Delayed-Auto"
	$SERVICE[143][1] = "WSearch"
	$SERVICE[143][2] = "Delayed-Auto"
	$SERVICE[144][1] = "wuauserv"
	$SERVICE[144][2] = "Disabled"
	$SERVICE[145][1] = "wudfsvc"
	$SERVICE[145][2] = "Manual"
	$SERVICE[146][1] = "WwanSvc"
	$SERVICE[146][2] = "Manual"
	Return $SERVICE
EndFunc   ;==>WinHighSpeed
Func WinHome()
	Local $SERVICE[148][3]
	$SERVICE[0][0] = 147
	$SERVICE[1][1] = "AeLookupSvc"
	$SERVICE[1][2] = "Manual"
	$SERVICE[2][1] = "ALG"
	$SERVICE[2][2] = "Manual"
	$SERVICE[3][1] = "AppIDSvc"
	$SERVICE[3][2] = "Manual"
	$SERVICE[4][1] = "Appinfo"
	$SERVICE[4][2] = "Manual"
	$SERVICE[5][1] = "AppMgmt"
	$SERVICE[5][2] = "Manual"
	$SERVICE[6][1] = "AudioEndpointBuilder"
	$SERVICE[6][2] = "Auto"
	$SERVICE[7][1] = "AudioSrv"
	$SERVICE[7][2] = "Auto"
	$SERVICE[8][1] = "AxInstSV"
	$SERVICE[8][2] = "Manual"
	$SERVICE[9][1] = "BDESVC"
	$SERVICE[9][2] = "Manual"
	$SERVICE[10][1] = "BFE"
	$SERVICE[10][2] = "Auto"
	$SERVICE[11][1] = "BITS"
	$SERVICE[11][2] = "Manual"
	$SERVICE[12][1] = "Browser"
	$SERVICE[12][2] = "Manual"
	$SERVICE[13][1] = "bthserv"
	$SERVICE[13][2] = "Manual"
	$SERVICE[14][1] = "CertPropSvc"
	$SERVICE[14][2] = "Manual"
	$SERVICE[15][1] = "clr_optimization_v2.0.50727_32"
	$SERVICE[15][2] = "Delayed-Auto"
	$SERVICE[16][1] = "clr_optimization_v2.0.50727_64"
	$SERVICE[16][2] = "Delayed-Auto"
	$SERVICE[17][1] = "COMSysApp"
	$SERVICE[17][2] = "Manual"
	$SERVICE[18][1] = "CryptSvc"
	$SERVICE[18][2] = "Auto"
	$SERVICE[19][1] = "CscService"
	$SERVICE[19][2] = "Auto"
	$SERVICE[20][1] = "DcomLaunch"
	$SERVICE[20][2] = "Auto"
	$SERVICE[21][1] = "defragsvc"
	$SERVICE[21][2] = "Manual"
	$SERVICE[22][1] = "Dhcp"
	$SERVICE[22][2] = "Auto"
	$SERVICE[23][1] = "Dnscache"
	$SERVICE[23][2] = "Auto"
	$SERVICE[24][1] = "dot3svc"
	$SERVICE[24][2] = "Manual"
	$SERVICE[25][1] = "DPS"
	$SERVICE[25][2] = "Auto"
	$SERVICE[26][1] = "EapHost"
	$SERVICE[26][2] = "Manual"
	$SERVICE[27][1] = "EFS"
	$SERVICE[27][2] = "Manual"
	$SERVICE[28][1] = "ehRecvr"
	$SERVICE[28][2] = "Manual"
	$SERVICE[29][1] = "ehSched"
	$SERVICE[29][2] = "Manual"
	$SERVICE[30][1] = "eventlog"
	$SERVICE[30][2] = "Auto"
	$SERVICE[31][1] = "EventSystem"
	$SERVICE[31][2] = "Auto"
	$SERVICE[32][1] = "Fax"
	$SERVICE[32][2] = "Manual"
	$SERVICE[33][1] = "fdPHost"
	$SERVICE[33][2] = "Manual"
	$SERVICE[34][1] = "FDResPub"
	$SERVICE[34][2] = "Manual"
	$SERVICE[35][1] = "FontCache"
	$SERVICE[35][2] = "Manual"
	$SERVICE[36][1] = "FontCache3.0.0.0"
	$SERVICE[36][2] = "Manual"
	$SERVICE[37][1] = "gpsvc"
	$SERVICE[37][2] = "Auto"
	$SERVICE[38][1] = "hidserv"
	$SERVICE[38][2] = "Manual"
	$SERVICE[39][1] = "hkmsvc"
	$SERVICE[39][2] = "Manual"
	$SERVICE[40][1] = "HomeGroupListener"
	$SERVICE[40][2] = "Manual"
	$SERVICE[41][1] = "HomeGroupProvider"
	$SERVICE[41][2] = "Manual"
	$SERVICE[42][1] = "idsvc"
	$SERVICE[42][2] = "Manual"
	$SERVICE[43][1] = "IKEEXT"
	$SERVICE[43][2] = "Manual"
	$SERVICE[44][1] = "IPBusEnum"
	$SERVICE[44][2] = "Manual"
	$SERVICE[45][1] = "iphlpsvc"
	$SERVICE[45][2] = "Auto"
	$SERVICE[46][1] = "KeyIso"
	$SERVICE[46][2] = "Manual"
	$SERVICE[47][1] = "KtmRm"
	$SERVICE[47][2] = "Manual"
	$SERVICE[48][1] = "LanmanServer"
	$SERVICE[48][2] = "Auto"
	$SERVICE[49][1] = "LanmanWorkstation"
	$SERVICE[49][2] = "Auto"
	$SERVICE[50][1] = "lltdsvc"
	$SERVICE[50][2] = "Manual"
	$SERVICE[51][1] = "lmhosts"
	$SERVICE[51][2] = "Auto"
	$SERVICE[52][1] = "Mcx2Svc"
	$SERVICE[52][2] = "Disabled"
	$SERVICE[53][1] = "MMCSS"
	$SERVICE[53][2] = "Auto"
	$SERVICE[54][1] = "MpsSvc"
	$SERVICE[54][2] = "Auto"
	$SERVICE[55][1] = "MSDTC"
	$SERVICE[55][2] = "Manual"
	$SERVICE[56][1] = "MSiSCSI"
	$SERVICE[56][2] = "Manual"
	$SERVICE[57][1] = "msiserver"
	$SERVICE[57][2] = "Manual"
	$SERVICE[58][1] = "napagent"
	$SERVICE[58][2] = "Manual"
	$SERVICE[59][1] = "Netlogon"
	$SERVICE[59][2] = "Manual"
	$SERVICE[60][1] = "Netman"
	$SERVICE[60][2] = "Manual"
	$SERVICE[61][1] = "netprofm"
	$SERVICE[61][2] = "Manual"
	$SERVICE[62][1] = "NetTcpPortSharing"
	$SERVICE[62][2] = "Disabled"
	$SERVICE[63][1] = "NlaSvc"
	$SERVICE[63][2] = "Auto"
	$SERVICE[64][1] = "nsi"
	$SERVICE[64][2] = "Auto"
	$SERVICE[65][1] = "p2pimsvc"
	$SERVICE[65][2] = "Manual"
	$SERVICE[66][1] = "p2psvc"
	$SERVICE[66][2] = "Manual"
	$SERVICE[67][1] = "PcaSvc"
	$SERVICE[67][2] = "Auto"
	$SERVICE[68][1] = "PeerDistSvc"
	$SERVICE[68][2] = "Manual"
	$SERVICE[69][1] = "PerfHost"
	$SERVICE[69][2] = "Manual"
	$SERVICE[70][1] = "pla"
	$SERVICE[70][2] = "Manual"
	$SERVICE[71][1] = "PlugPlay"
	$SERVICE[71][2] = "Auto"
	$SERVICE[72][1] = "PNRPAutoReg"
	$SERVICE[72][2] = "Manual"
	$SERVICE[73][1] = "PNRPsvc"
	$SERVICE[73][2] = "Manual"
	$SERVICE[74][1] = "PolicyAgent"
	$SERVICE[74][2] = "Manual"
	$SERVICE[75][1] = "Power"
	$SERVICE[75][2] = "Auto"
	$SERVICE[76][1] = "ProfSvc"
	$SERVICE[76][2] = "Auto"
	$SERVICE[77][1] = "ProtectedStorage"
	$SERVICE[77][2] = "Auto"
	$SERVICE[78][1] = "QWAVE"
	$SERVICE[78][2] = "Manual"
	$SERVICE[79][1] = "RasAuto"
	$SERVICE[79][2] = "Manual"
	$SERVICE[80][1] = "RasMan"
	$SERVICE[80][2] = "Manual"
	$SERVICE[81][1] = "RemoteAccess"
	$SERVICE[81][2] = "Disabled"
	$SERVICE[82][1] = "RemoteRegistry"
	$SERVICE[82][2] = "Manual"
	$SERVICE[83][1] = "RpcEptMapper"
	$SERVICE[83][2] = "Auto"
	$SERVICE[84][1] = "RpcLocator"
	$SERVICE[84][2] = "Manual"
	$SERVICE[85][1] = "RpcSs"
	$SERVICE[85][2] = "Auto"
	$SERVICE[86][1] = "SamSs"
	$SERVICE[86][2] = "Auto"
	$SERVICE[87][1] = "SCardSvr"
	$SERVICE[87][2] = "Manual"
	$SERVICE[88][1] = "Schedule"
	$SERVICE[88][2] = "Auto"
	$SERVICE[89][1] = "SCPolicySvc"
	$SERVICE[89][2] = "Manual"
	$SERVICE[90][1] = "SDRSVC"
	$SERVICE[90][2] = "Manual"
	$SERVICE[91][1] = "seclogon"
	$SERVICE[91][2] = "Manual"
	$SERVICE[92][1] = "SENS"
	$SERVICE[92][2] = "Auto"
	$SERVICE[93][1] = "SensrSvc"
	$SERVICE[93][2] = "Manual"
	$SERVICE[94][1] = "SessionEnv"
	$SERVICE[94][2] = "Manual"
	$SERVICE[95][1] = "SharedAccess"
	$SERVICE[95][2] = "Disabled"
	$SERVICE[96][1] = "ShellHWDetection"
	$SERVICE[96][2] = "Auto"
	$SERVICE[97][1] = "SNMPTRAP"
	$SERVICE[97][2] = "Manual"
	$SERVICE[98][1] = "Spooler"
	$SERVICE[98][2] = "Auto"
	$SERVICE[99][1] = "sppsvc"
	$SERVICE[99][2] = "Delayed-Auto"
	$SERVICE[100][1] = "sppuinotify"
	$SERVICE[100][2] = "Manual"
	$SERVICE[101][1] = "SSDPSRV"
	$SERVICE[101][2] = "Manual"
	$SERVICE[102][1] = "SstpSvc"
	$SERVICE[102][2] = "Manual"
	$SERVICE[103][1] = "stisvc"
	$SERVICE[103][2] = "Manual"
	$SERVICE[104][1] = "swprv"
	$SERVICE[104][2] = "Manual"
	$SERVICE[105][1] = "SysMain"
	$SERVICE[105][2] = "Auto"
	$SERVICE[106][1] = "TabletInputService"
	$SERVICE[106][2] = "Manual"
	$SERVICE[107][1] = "TapiSrv"
	$SERVICE[107][2] = "Manual"
	$SERVICE[108][1] = "TBS"
	$SERVICE[108][2] = "Manual"
	$SERVICE[109][1] = "TermService"
	$SERVICE[109][2] = "Manual"
	$SERVICE[110][1] = "Themes"
	$SERVICE[110][2] = "Auto"
	$SERVICE[111][1] = "THREADORDER"
	$SERVICE[111][2] = "Manual"
	$SERVICE[112][1] = "TPAutoConnSvc"
	$SERVICE[112][2] = "Manual"
	$SERVICE[113][1] = "TPVCGateway"
	$SERVICE[113][2] = "Manual"
	$SERVICE[114][1] = "TrkWks"
	$SERVICE[114][2] = "Manual"
	$SERVICE[115][1] = "TrustedInstaller"
	$SERVICE[115][2] = "Manual"
	$SERVICE[116][1] = "UI0Detect"
	$SERVICE[116][2] = "Manual"
	$SERVICE[117][1] = "UmRdpService"
	$SERVICE[117][2] = "Manual"
	$SERVICE[118][1] = "upnphost"
	$SERVICE[118][2] = "Manual"
	$SERVICE[119][1] = "UxSms"
	$SERVICE[119][2] = "Auto"
	$SERVICE[120][1] = "VaultSvc"
	$SERVICE[120][2] = "Manual"
	$SERVICE[121][1] = "vds"
	$SERVICE[121][2] = "Manual"
	$SERVICE[122][1] = "VSS"
	$SERVICE[122][2] = "Manual"
	$SERVICE[123][1] = "W32Time"
	$SERVICE[123][2] = "Auto"
	$SERVICE[124][1] = "wbengine"
	$SERVICE[124][2] = "Manual"
	$SERVICE[125][1] = "WbioSrvc"
	$SERVICE[125][2] = "Auto"
	$SERVICE[126][1] = "wcncsvc"
	$SERVICE[126][2] = "Manual"
	$SERVICE[127][1] = "WcsPlugInService"
	$SERVICE[127][2] = "Manual"
	$SERVICE[128][1] = "WdiServiceHost"
	$SERVICE[128][2] = "Manual"
	$SERVICE[129][1] = "WdiSystemHost"
	$SERVICE[129][2] = "Manual"
	$SERVICE[130][1] = "WebClient"
	$SERVICE[130][2] = "Manual"
	$SERVICE[131][1] = "Wecsvc"
	$SERVICE[131][2] = "Manual"
	$SERVICE[132][1] = "wercplsupport"
	$SERVICE[132][2] = "Manual"
	$SERVICE[133][1] = "WerSvc"
	$SERVICE[133][2] = "Manual"
	$SERVICE[134][1] = "WinDefend"
	$SERVICE[134][2] = "Delayed-Auto"
	$SERVICE[135][1] = "WinHttpAutoProxySvc"
	$SERVICE[135][2] = "Manual"
	$SERVICE[136][1] = "Winmgmt"
	$SERVICE[136][2] = "Auto"
	$SERVICE[137][1] = "WinRM"
	$SERVICE[137][2] = "Manual"
	$SERVICE[138][1] = "wmiApSrv"
	$SERVICE[138][2] = "Manual"
	$SERVICE[139][1] = "WMPNetworkSvc"
	$SERVICE[139][2] = "Manual"
	$SERVICE[140][1] = "WPCSvc"
	$SERVICE[140][2] = "Manual"
	$SERVICE[141][1] = "WPDBusEnum"
	$SERVICE[141][2] = "Manual"
	$SERVICE[142][1] = "wscsvc"
	$SERVICE[142][2] = "Delayed-Auto"
	$SERVICE[143][1] = "WSearch"
	$SERVICE[143][2] = "Delayed-Auto"
	$SERVICE[144][1] = "wuauserv"
	$SERVICE[144][2] = "Delayed-Auto"
	$SERVICE[145][1] = "wudfsvc"
	$SERVICE[145][2] = "Manual"
	$SERVICE[146][1] = "WwanSvc"
	$SERVICE[146][2] = "Manual"
	$SERVICE[147][1] = "ZhuDongFangYu"
	$SERVICE[147][2] = "Auto"
	Return $SERVICE
EndFunc   ;==>WinHome
Func WinPerson()
	Local $SERVICE[148][3]
	$SERVICE[0][0] = 147
	$SERVICE[1][1] = "AxInstSV"
	$SERVICE[2][1] = "SensrSvc"
	$SERVICE[3][1] = "AeLookupSvc"
	$SERVICE[4][1] = "AppIDSvc"
	$SERVICE[5][1] = "Appinfo"
	$SERVICE[6][1] = "ALG"
	$SERVICE[7][1] = "AppMgmt"
	$SERVICE[8][1] = "aspnet_state"
	$SERVICE[9][1] = "BITS"
	$SERVICE[10][1] = "BFE"
	$SERVICE[11][1] = "BDESVC"
	$SERVICE[12][1] = "wbengine"
	$SERVICE[13][1] = "PeerDistSvc"
	$SERVICE[14][1] = "CertPropSvc"
	$SERVICE[15][1] = "KeyIso"
	$SERVICE[16][1] = "EventSystem"
	$SERVICE[17][1] = "COMSysApp"
	$SERVICE[18][1] = "Browser"
	$SERVICE[19][1] = "VaultSvc"
	$SERVICE[20][1] = "CryptSvc"
	$SERVICE[21][1] = "DcomLaunch"
	$SERVICE[22][1] = "UxSms"
	$SERVICE[23][1] = "Dhcp"
	$SERVICE[24][1] = "DPS"
	$SERVICE[25][1] = "WdiServiceHost"
	$SERVICE[26][1] = "WdiSystemHost"
	$SERVICE[27][1] = "defragsvc"
	$SERVICE[28][1] = "TrkWks"
	$SERVICE[29][1] = "MSDTC"
	$SERVICE[30][1] = "Dnscache"
	$SERVICE[31][1] = "EFS"
	$SERVICE[32][1] = "EapHost"
	$SERVICE[33][1] = "fdPHost"
	$SERVICE[34][1] = "FDResPub"
	$SERVICE[35][1] = "gpsvc"
	$SERVICE[36][1] = "hkmsvc"
	$SERVICE[37][1] = "HomeGroupListener"
	$SERVICE[38][1] = "HomeGroupProvider"
	$SERVICE[39][1] = "hidserv"
	$SERVICE[40][1] = "IKEEXT"
	$SERVICE[41][1] = "UI0Detect"
	$SERVICE[42][1] = "SharedAccess"
	$SERVICE[43][1] = "iphlpsvc"
	$SERVICE[44][1] = "PolicyAgent"
	$SERVICE[45][1] = "KtmRm"
	$SERVICE[46][1] = "lltdsvc"
	$SERVICE[47][1] = "clr_optimization_v2.0.50727_64"
	$SERVICE[48][1] = "clr_optimization_v2.0.50727_32"
	$SERVICE[49][1] = "clr_optimization_v4.0.30319_64"
	$SERVICE[50][1] = "clr_optimization_v4.0.30319_32"
	$SERVICE[51][1] = "MSiSCSI"
	$SERVICE[52][1] = "swprv"
	$SERVICE[53][1] = "MMCSS"
	$SERVICE[54][1] = "NetMsmqActivator"
	$SERVICE[55][1] = "NetPipeActivator"
	$SERVICE[56][1] = "NetTcpActivator"
	$SERVICE[57][1] = "NetTcpPortSharing"
	$SERVICE[58][1] = "Netlogon"
	$SERVICE[59][1] = "napagent"
	$SERVICE[60][1] = "Netman"
	$SERVICE[61][1] = "netprofm"
	$SERVICE[62][1] = "NlaSvc"
	$SERVICE[63][1] = "nsi"
	$SERVICE[64][1] = "CscService"
	$SERVICE[65][1] = "WPCSvc"
	$SERVICE[66][1] = "PNRPsvc"
	$SERVICE[67][1] = "p2psvc"
	$SERVICE[68][1] = "p2pimsvc"
	$SERVICE[69][1] = "PerfHost"
	$SERVICE[70][1] = "pla"
	$SERVICE[71][1] = "PlugPlay"
	$SERVICE[72][1] = "IPBusEnum"
	$SERVICE[73][1] = "PNRPAutoReg"
	$SERVICE[74][1] = "WPDBusEnum"
	$SERVICE[75][1] = "Power"
	$SERVICE[76][1] = "Spooler"
	$SERVICE[77][1] = "wercplsupport"
	$SERVICE[78][1] = "PcaSvc"
	$SERVICE[79][1] = "ProtectedStorage"
	$SERVICE[80][1] = "QWAVE"
	$SERVICE[81][1] = "RasAuto"
	$SERVICE[82][1] = "RasMan"
	$SERVICE[83][1] = "SessionEnv"
	$SERVICE[84][1] = "TermService"
	$SERVICE[85][1] = "UmRdpService"
	$SERVICE[86][1] = "RpcSs"
	$SERVICE[87][1] = "RpcLocator"
	$SERVICE[88][1] = "RemoteRegistry"
	$SERVICE[89][1] = "RemoteAccess"
	$SERVICE[90][1] = "RpcEptMapper"
	$SERVICE[91][1] = "seclogon"
	$SERVICE[92][1] = "SstpSvc"
	$SERVICE[93][1] = "SamSs"
	$SERVICE[94][1] = "wscsvc"
	$SERVICE[95][1] = "LanmanServer"
	$SERVICE[96][1] = "ShellHWDetection"
	$SERVICE[97][1] = "SCardSvr"
	$SERVICE[98][1] = "SCPolicySvc"
	$SERVICE[99][1] = "SNMPTRAP"
	$SERVICE[100][1] = "sppsvc"
	$SERVICE[101][1] = "sppuinotify"
	$SERVICE[102][1] = "SSDPSRV"
	$SERVICE[103][1] = "StorSvc"
	$SERVICE[104][1] = "SysMain"
	$SERVICE[105][1] = "SENS"
	$SERVICE[106][1] = "TabletInputService"
	$SERVICE[107][1] = "Schedule"
	$SERVICE[108][1] = "lmhosts"
	$SERVICE[109][1] = "TapiSrv"
	$SERVICE[110][1] = "Themes"
	$SERVICE[111][1] = "THREADORDER"
	$SERVICE[112][1] = "TBS"
	$SERVICE[113][1] = "upnphost"
	$SERVICE[114][1] = "ProfSvc"
	$SERVICE[115][1] = "vds"
	$SERVICE[116][1] = "VSS"
	$SERVICE[117][1] = "WebClient"
	$SERVICE[118][1] = "AudioSrv"
	$SERVICE[119][1] = "AudioEndpointBuilder"
	$SERVICE[120][1] = "SDRSVC"
	$SERVICE[121][1] = "WbioSrvc"
	$SERVICE[122][1] = "idsvc"
	$SERVICE[123][1] = "WcsPlugInService"
	$SERVICE[124][1] = "wcncsvc"
	$SERVICE[125][1] = "wudfsvc"
	$SERVICE[126][1] = "WerSvc"
	$SERVICE[127][1] = "Wecsvc"
	$SERVICE[128][1] = "eventlog"
	$SERVICE[129][1] = "MpsSvc"
	$SERVICE[130][1] = "FontCache"
	$SERVICE[131][1] = "stisvc"
	$SERVICE[132][1] = "msiserver"
	$SERVICE[133][1] = "Winmgmt"
	$SERVICE[134][1] = "WMPNetworkSvc"
	$SERVICE[135][1] = "TrustedInstaller"
	$SERVICE[136][1] = "FontCache3.0.0.0"
	$SERVICE[137][1] = "WinRM"
	$SERVICE[138][1] = "WSearch"
	$SERVICE[139][1] = "W32Time"
	$SERVICE[140][1] = "wuauserv"
	$SERVICE[141][1] = "WinHttpAutoProxySvc"
	$SERVICE[142][1] = "dot3svc"
	$SERVICE[143][1] = "Wlansvc"
	$SERVICE[144][1] = "wmiApSrv"
	$SERVICE[145][1] = "LanmanWorkstation"
	$SERVICE[146][1] = "WwanSvc"
	$SERVICE[147][1] = "WindowsDefenderService"
	$SERVICE[1][2] = "Disable"
	$SERVICE[2][2] = "Disable"
	$SERVICE[3][2] = "Manual"
	$SERVICE[4][2] = "Manual"
	$SERVICE[5][2] = "Manual"
	$SERVICE[6][2] = "Disable"
	$SERVICE[7][2] = "Disable"
	$SERVICE[8][2] = "Disable"
	$SERVICE[9][2] = "Manual"
	$SERVICE[10][2] = "Automatic"
	$SERVICE[11][2] = "Disable"
	$SERVICE[12][2] = "Disable"
	$SERVICE[13][2] = "Disable"
	$SERVICE[14][2] = "Disable"
	$SERVICE[15][2] = "Manual"
	$SERVICE[16][2] = "Automatic"
	$SERVICE[17][2] = "Manual"
	$SERVICE[18][2] = "Manual"
	$SERVICE[19][2] = "Disable"
	$SERVICE[20][2] = "Automatic"
	$SERVICE[21][2] = "Automatic"
	$SERVICE[22][2] = "Automatic"
	$SERVICE[23][2] = "Automatic"
	$SERVICE[24][2] = "Disable"
	$SERVICE[25][2] = "Disable"
	$SERVICE[26][2] = "Disable"
	$SERVICE[27][2] = "Manual"
	$SERVICE[28][2] = "Disable"
	$SERVICE[29][2] = "Manual"
	$SERVICE[30][2] = "Automatic"
	$SERVICE[31][2] = "Disable"
	$SERVICE[32][2] = "Manual"
	$SERVICE[33][2] = "Disable"
	$SERVICE[34][2] = "Disable"
	$SERVICE[35][2] = "Automatic"
	$SERVICE[36][2] = "Disable"
	$SERVICE[37][2] = "Disable"
	$SERVICE[38][2] = "Disable"
	$SERVICE[39][2] = "Automatic"
	$SERVICE[40][2] = "Automatic"
	$SERVICE[41][2] = "Disable"
	$SERVICE[42][2] = "Disable"
	$SERVICE[43][2] = "Disable"
	$SERVICE[44][2] = "Automatic"
	$SERVICE[45][2] = "Manual"
	$SERVICE[46][2] = "Disable"
	$SERVICE[47][2] = "Manual"
	$SERVICE[48][2] = "Manual"
	$SERVICE[49][2] = "Manual"
	$SERVICE[50][2] = "Manual"
	$SERVICE[51][2] = "Automatic"
	$SERVICE[52][2] = "Manual"
	$SERVICE[53][2] = "Disable"
	$SERVICE[54][2] = "Disable"
	$SERVICE[55][2] = "Disable"
	$SERVICE[56][2] = "Disable"
	$SERVICE[57][2] = "Disable"
	$SERVICE[58][2] = "Disable"
	$SERVICE[59][2] = "Disable"
	$SERVICE[60][2] = "Manual"
	$SERVICE[61][2] = "Manual"
	$SERVICE[62][2] = "Automatic"
	$SERVICE[63][2] = "Automatic"
	$SERVICE[64][2] = "Disable"
	$SERVICE[65][2] = "Disable"
	$SERVICE[66][2] = "Disable"
	$SERVICE[67][2] = "Disable"
	$SERVICE[68][2] = "Disable"
	$SERVICE[69][2] = "Manual"
	$SERVICE[70][2] = "Manual"
	$SERVICE[71][2] = "Automatic"
	$SERVICE[72][2] = "Disable"
	$SERVICE[73][2] = "Disable"
	$SERVICE[74][2] = "Disable"
	$SERVICE[75][2] = "Automatic"
	$SERVICE[76][2] = "Disable"
	$SERVICE[77][2] = "Disable"
	$SERVICE[78][2] = "Disable"
	$SERVICE[79][2] = "Manual"
	$SERVICE[80][2] = "Disable"
	$SERVICE[81][2] = "Manual"
	$SERVICE[82][2] = "Automatic"
	$SERVICE[83][2] = "Disable"
	$SERVICE[84][2] = "Manual"
	$SERVICE[85][2] = "Disable"
	$SERVICE[86][2] = "Automatic"
	$SERVICE[87][2] = "Disable"
	$SERVICE[88][2] = "Disable"
	$SERVICE[89][2] = "Disable"
	$SERVICE[90][2] = "Automatic"
	$SERVICE[91][2] = "Manual"
	$SERVICE[92][2] = "Manual"
	$SERVICE[93][2] = "Automatic"
	$SERVICE[94][2] = "Disable"
	$SERVICE[95][2] = "Disable"
	$SERVICE[96][2] = "Automatic"
	$SERVICE[97][2] = "Disable"
	$SERVICE[98][2] = "Disable"
	$SERVICE[99][2] = "Disable"
	$SERVICE[100][2] = "Automatic"
	$SERVICE[101][2] = "Manual"
	$SERVICE[102][2] = "Manual"
	$SERVICE[103][2] = "Manual"
	$SERVICE[104][2] = "Automatic"
	$SERVICE[105][2] = "Automatic"
	$SERVICE[106][2] = "Disable"
	$SERVICE[107][2] = "Automatic"
	$SERVICE[108][2] = "Automatic"
	$SERVICE[109][2] = "Manual"
	$SERVICE[110][2] = "Automatic"
	$SERVICE[111][2] = "Manual"
	$SERVICE[112][2] = "Disable"
	$SERVICE[113][2] = "Manual"
	$SERVICE[114][2] = "Automatic"
	$SERVICE[115][2] = "Manual"
	$SERVICE[116][2] = "Manual"
	$SERVICE[117][2] = "Disable"
	$SERVICE[118][2] = "Automatic"
	$SERVICE[119][2] = "Automatic"
	$SERVICE[120][2] = "Disable"
	$SERVICE[121][2] = "Disable"
	$SERVICE[122][2] = "Manual"
	$SERVICE[123][2] = "Disable"
	$SERVICE[124][2] = "Disable"
	$SERVICE[125][2] = "Manual"
	$SERVICE[126][2] = "Disable"
	$SERVICE[127][2] = "Manual"
	$SERVICE[128][2] = "Automatic"
	$SERVICE[129][2] = "Disable"
	$SERVICE[130][2] = "Manual"
	$SERVICE[131][2] = "Manual"
	$SERVICE[132][2] = "Manual"
	$SERVICE[133][2] = "Automatic"
	$SERVICE[134][2] = "Manual"
	$SERVICE[135][2] = "Manual"
	$SERVICE[136][2] = "Manual"
	$SERVICE[137][2] = "Disable"
	$SERVICE[138][2] = "Disable"
	$SERVICE[139][2] = "Disable"
	$SERVICE[140][2] = "Manual"
	$SERVICE[141][2] = "Disable"
	$SERVICE[142][2] = "Disable"
	$SERVICE[143][2] = "Automatic"
	$SERVICE[144][2] = "Manual"
	$SERVICE[145][2] = "Manual"
	$SERVICE[146][2] = "Disable"
	$SERVICE[147][2] = "Disable"
	Return $SERVICE
EndFunc   ;==>WinPerson
Func windowsServiceTweaks()
	Local $string = GUICtrlRead($w7ServiceList)
	Local $ServiceVer, $i
	Switch $string
		Case "系统默认服务方案"
			$ServiceVer = WinDefault()
		Case "极速服务优化方案"
			$ServiceVer = WinHighSpeed()
		Case "家用服务优化方案"
			$ServiceVer = WinHome()
		Case "个人&网吧服务优化方案"
			$ServiceVer = WinPerson()
			Return 1
	EndSwitch
	For $i = 1 To UBound($ServiceVer) - 1
		Switch $ServiceVer[$i][2]
			Case "Auto"
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 2)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 2)
			Case "Delayed-Auto"
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 2)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 2)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\services\" & $ServiceVer[$i][1], "DelayedAutoStart", "REG_DWORD", 1)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\" & $ServiceVer[$i][1], "DelayedAutoStart", "REG_DWORD", 1)
			Case "Manual"
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 3)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 3)
			Case "Disabled"
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 4)
				RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\" & $ServiceVer[$i][1], "Start", "REG_DWORD", 4)
		EndSwitch
	Next
	MsgBox(0, '提示', '已经将您选择的优化项目应用到当前系统!')
EndFunc   ;==>windowsServiceTweaks
Func _SetHomePage()
	Local $HomePageUrl = GUICtrlRead($HomePage)
	If $HomePageUrl = '' Then
		$HomePageUrl = 'about:blank'
	EndIf
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\Main', 'Default_Page_URL', 'REG_SZ', $HomePageUrl)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Internet Explorer\Main', 'Start Page', 'REG_SZ', $HomePageUrl)
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main', 'Start Page', 'REG_SZ', $HomePageUrl)
	MsgBox(0, '提示', '设置当前计算机主页完成！！', 5)
EndFunc   ;==>_SetHomePage

;=============================================================
; 个人资料转移
;=============================================================
;文本选中

Func ToogleListviewCheck()
	Local $hLast = @GUI_CtrlId
	$TreePos = ControlGetPos($Form1, '', $TreeView)
	$x = _GUICtrlTreeView_DisplayRect($TreeView, @GUI_CtrlId, True) ;取点击项文本框的坐标
	$curX = GUIGetCursorInfo()
	If Not @error And IsArray($curX) And IsArray($TreePos) And IsArray($x) Then
		If $curX[0] - $TreePos[0] >= $x[0] Then
			GUICtrlSetState($hLast, (BitAND(GUICtrlRead($hLast), $GUI_CHECKED)) ? $GUI_UNCHECKED : $GUI_CHECKED)
		EndIf
	EndIf
	Local $HidParent = _GUICtrlTreeView_GetParentHandle($TreeView, $hLast)
	Local $bCheck = _GUICtrlTreeView_GetChecked($TreeView, $hLast)
	If $HidParent = 0 Then
		;表示点击的是父项目
		Local $iChildcount = _GUICtrlTreeView_GetChildCount($TreeView, $hLast)
		For $i = 0 To $iChildcount - 1
			_GUICtrlTreeView_SetCheckedByIndex($TreeView, $hLast, $i, $bCheck)
		Next
		_GUICtrlTreeView_Expand($TreeView, $hLast, $bCheck)
	Else
		;表示点击的是子项目
		Local $iChildcount = _GUICtrlTreeView_GetChildCount($TreeView, $HidParent)
		_GUICtrlTreeView_SetChecked($TreeView, $HidParent, $bCheck)
		For $i = 0 To $iChildcount - 1
			_GUICtrlTreeView_SetCheckedByIndex($TreeView, $HidParent, $i, $bCheck)
		Next
		_GUICtrlTreeView_Expand($TreeView, $HidParent, $bCheck)
	EndIf
EndFunc   ;==>ToogleListviewCheck
Func QuickSetDrive()
	;检测是否选择浏览
	Local $targetpath = GUICtrlRead($TargetDrive)
	If $targetpath <> '选择目标盘符或路径' Then
		If $targetpath = '浏览...' Then
			Local $dir = FileSelectFolder('请选择要用于存储转移资料的目录', '', 1 + 4, '')
			If Not @error Then
				For $i = 2 To 44 Step 3
					If _GUICtrlTreeView_GetChecked($TreeView, _GUICtrlTreeView_GetParentHandle($TreeView, $aTreeView[$i])) = True Then
						Local $sNewPath = $dir & '\' & _GetDirNameFromStr(_GUICtrlTreeView_GetText($TreeView, $aTreeView[$i]))
						_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i], $sNewPath)
					EndIf
				Next
			EndIf
		Else
			For $i = 2 To 44 Step 3
				If _GUICtrlTreeView_GetChecked($TreeView, _GUICtrlTreeView_GetParentHandle($TreeView, $aTreeView[$i])) = True Then
					Local $sNewPath = StringRegExpReplace(_GUICtrlTreeView_GetText($TreeView, $aTreeView[$i]), '\w:', $targetpath)
					_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i], $sNewPath)
				EndIf
			Next
		EndIf
	EndIf
EndFunc   ;==>QuickSetDrive
;~ $option 说明：
;~ 4       不显示进度条
;~ 8       如果目标路径存在相同源文件或目录则自动修改名称，如：复件 autoit3
;~ 16       显示任何对话框都点击"全是"
;~ 64       如果可能的话,保留撤销信息，
;~ 128      执行该操作仅当通配符指定文件名(*.*)。
;~ 256     显示进度条但不显示文件名（复制目录时不显示）
;~ 512     如果操作需要建立一个新目录，不确认建立一个新目录
;~ 1024    如果出现错误,不显示用户界面，
;~ 4096    禁用递归
;~ 8192    不复制的一组连接的文件。仅复制指定的文件
Func _FileCopy($fromFile, $ToDir, $option = 16)
	$winShell = ObjCreate("shell.application")
	If Not FileExists($ToDir) Then
		DirCreate($ToDir)
	EndIf
	$winShell.namespace($ToDir).CopyHere($fromFile, $option)
EndFunc   ;==>_FileCopy
Func _FileMove($fromFile, $ToDir, $option = 16)
	$winShell = ObjCreate("shell.application")
	If Not FileExists($ToDir) Then
		DirCreate($ToDir)
	EndIf
	$winShell.namespace($ToDir).MoveHere($fromFile, $option)
EndFunc   ;==>_FileMove
Func _GetDirNameFromStr($sdir)
	Local $smatch = StringRegExp($sdir, '[^\\]*$', 3)
	If Not @error Then
		Return $smatch[0]
	EndIf
EndFunc   ;==>_GetDirNameFromStr
Func TransDir()
;~ 	MsgBox(0,'',$UserSid)
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	Local $DirRegkey = 'HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
	For $i = 0 To 44 Step 3
		If _GUICtrlTreeView_GetChecked($TreeView, $aTreeView[$i]) = True Then
			Local $sOPeration = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i])
			Local $sSourceDir = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i + 1])
			Local $sNewDir = _GUICtrlTreeView_GetText($TreeView, $aTreeView[$i + 2])
			Local $sRegKey = $aDataTreeView[$i / 3][2]
			$aText = '开始进行个人资料[' & $sOPeration & ']转移操作.....'
			If $sSourceDir = $sNewDir Then
				$aText = '个人资料转移操作[' & $sOPeration & ']源路径和目标路径相同，自动跳过...'
				ContinueLoop
			EndIf
			RegWrite($DirRegkey, $sRegKey, 'REG_SZ', $sNewDir)
			If GUICtrlRead($optFileCopy) = $GUI_CHECKED Then
				_FileCopy($sSourceDir, $sNewDir)
			ElseIf GUICtrlRead($optFileMove) = $GUI_CHECKED Then
				_FileMove($sSourceDir, $sNewDir)
			Else
;~ 				;不做任何事情
			EndIf
		EndIf
	Next
	$aText = '正在处理，请稍后..'
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	_ForceUpdate()
EndFunc   ;==>TransDir
Func RestoreDefaultOpt()
	For $i = 0 To 44 Step 3
		If _GUICtrlTreeView_GetChecked($TreeView, $aTreeView[$i]) = True Then
			Local $sDefaultPath = $aDataTreeView[$i / 3][3]
			_GUICtrlTreeView_SetText($TreeView, $aTreeView[$i + 2], _WinAPI_PathSearchAndQualify(_WinAPI_ExpandEnvironmentStrings($sDefaultPath)))
		EndIf
	Next
	MsgBox(0, '提示', '已经设置为默认值，请点击[执行操作]进行应用！', 5, $Form1)
EndFunc   ;==>RestoreDefaultOpt
Func _BackUPServiceToBat()
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = ""
	Local $strComputer = "localhost"
	Local $cmdscstr = ""
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_Service", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	If IsObj($colItems) Then
		Local $BatFile = FileSaveDialog('请选择您保存文件的位置', '', '批处理文件(*.bat;*.cmd)', 16)
		If @error Then Return
		For $objItem In $colItems
			$cmdscstr &= 'sc config "' & $objItem.Name & '" start= ' & _ConvertServiceStatus($objItem.StartMode) & @CRLF
		Next
		$Mainstr = '@echo off ' & @CRLF & _
				'title 计算机服务备份还原[' & @YEAR & '-' & @MON & '-' & @MDAY & ']' & @CRLF & _
				'echo 虫子樱桃提示您：正在还原系统服务状态到[' & @YEAR & '-' & @MON & '-' & @MDAY & ']' & @CRLF & _
				$cmdscstr & @CRLF & _
				'cls ' & @CRLF & _
				'echo 虫子樱桃提示您：系统服务状态已经还原到[' & @YEAR & '-' & @MON & '-' & @MDAY & ']' & @CRLF & _
				'timeout 3	'
		If Not (StringInStr($BatFile, '.bat') Or StringInStr($BatFile, '.cmd')) Then
			$BatFile &= '.bat'
		EndIf
		Local $Fh = FileOpen($BatFile, 2 + 8)
		FileWrite($Fh, $Mainstr)
		FileClose($Fh)
		MsgBox(0, '提示', '已经成功备份当前系统服务状态为批处理', 5)
	Else
		MsgBox(16, "错误", "备份系统服务状态为批处理失败！", 5)
	EndIf
EndFunc   ;==>_BackUPServiceToBat

Func _ConvertServiceStatus($sStatus)
	If $sStatus <> '' Then
		If StringUpper($sStatus) = 'MANUAL' Then
			Return 'demand'
		Else
			Return $sStatus
		EndIf
	EndIf
EndFunc   ;==>_ConvertServiceStatus
;小众人群插件
Func Convert2bmp()
	If RegRead('HKEY_CLASSES_ROOT\*\shell\转为Alpha通道bmp\command', '') = '' Then
		If @OSArch = "X86" Then
			FileInstall('.\file\img2bmp32.exe', @WindowsDir & '\img2bmp.exe', 1)
		ElseIf @OSArch = "X64" Then
			FileInstall('.\file\img2bmp64.exe', @WindowsDir & '\img2bmp.exe', 1)
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
		FileInstall('.\file\upx.exe', $Path & '\upx.exe', 1)
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
			FileInstall('.\file\RemoveDriveX64.exe', @WindowsDir & '\RemoveDrive.exe', 1)
		Else
			FileInstall('.\file\RemoveDriveX86.exe', @WindowsDir & '\RemoveDrive.exe', 1)
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
	FileInstall('.\file\uwd.exe', @TempDir & '\uwd.exe')
	Run(@TempDir & '\uwd.exe')
EndFunc   ;==>UWD
;; KClock
Func KClock()
	If RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'KClock') = '' Then
		If @OSArch = 'X86' Then
			FileInstall('.\file\KClockx86.exe', @WindowsDir & '\KClock.exe', 1)
		ElseIf @OSArch = 'X64' Then
			FileInstall('.\file\KClockx64.exe', @WindowsDir & '\KClock.exe', 1)
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
			FileInstall('.\file\JunctionMasterX86.exe', @WindowsDir & '\JunctionMaster.exe', 1)
		ElseIf @OSArch = 'X64' Then
			FileInstall('.\file\JunctionMasterX64.exe', @WindowsDir & '\JunctionMaster.exe', 1)
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
;;windows7激活相关

;退出的事件响应
Func quitForm()
	Run(@ComSpec & ' /c taskkill /im "bios.exe" /f', @WindowsDir, @SW_HIDE)
	_WinAPI_AnimateWindow($ActForm, BitOR($AW_BLEND, $AW_HIDE), 500)
	GUIDelete($ActForm)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>quitForm
Func _BiosTool()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	$ActForm = _GUICreate("BIOS辅助工具", 265, 71, 172, 135, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("", 8, 8, 249, 49)
	GUICtrlCreateButton("BIOS SLIC动态加载工具", 16, 24, 139, 25)
	GUICtrlSetTip(-1, '动态加载SLIC文件，模拟OEM', '提示', 1)
	GUICtrlSetOnEvent(-1, '_RunDBSLDR')
	Global $BtnBAKBIOS = GUICtrlCreateButton("备份BIOS及证书", 160, 24, 91, 25)
	GUICtrlSetTip(-1, '证书及BIOS等信息辅助工具，请右键' & @LF & '选择所需选项进行执行', '提示', 1)
	$MBiosTool = GUICtrlCreateContextMenu($BtnBAKBIOS)
	GUICtrlCreateMenuItem('备份BIOS及证书', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'BackupInfo')
	GUICtrlSetTip(-1, '备份BIOS文件、证书、密匙等信息')
	GUICtrlCreateMenuItem('安装OEM证书及密匙[如果可用]', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'InstallOEMCertKey')
	GUICtrlCreateMenuItem('手工执行BIOS.exe', $MBiosTool)
	GUICtrlSetOnEvent(-1, 'ManualRunBiosTool')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'quitForm')
EndFunc   ;==>_BiosTool
Func BackupInfo()
	GUICtrlSetState($BtnBAKBIOS, $GUI_DISABLE)
	FileInstall('.\file\bios.exe', @TempDir & '\', 1)
	Local $dir = FileSelectFolder("请选择您要备份的证书和BIOS文件夹位置", "", 1 + 4)
	If FileExists($dir) = 1 And StringInStr(FileGetAttrib($dir), 'D') = 1 Then
		FileCopy(@TempDir & '\bios.exe', $dir, 1)
		TrayTip('提示', '正在进行备份，请稍后..', 5, 1)
		Local $cmd = Run($dir & '\bios.exe  /DUMP', $dir, @SW_HIDE, $STDOUT_CHILD)
		ProcessWaitClose($cmd)
		Local $result = StdoutRead($cmd)
		If $result <> '' Then
			MsgBox(0, '提示', '恭喜您！您的计算机为品牌为' & $result & @LF & '已经成功备份系统的激活信息到文件夹' & $dir & '!')
		EndIf
		FileDelete($dir & '\bios.exe')
	Else
		MsgBox(0, '', '请选择正确的文件夹')
	EndIf
	GUICtrlSetState($BtnBAKBIOS, $GUI_ENABLE)
EndFunc   ;==>BackupInfo
Func InstallOEMCertKey()
	GUICtrlSetState($BtnBAKBIOS, $GUI_DISABLE)
	FileInstall('.\file\bios.exe', @TempDir & '\', 1)
	TrayTip('提示', '正在安装证书及密匙，请稍后..', 5, 1)
	RunWait(@TempDir & '\bios.exe /CERT/KEY', @TempDir, @SW_HIDE)
	FileDelete(@TempDir & '\bios.exe')
	TrayTip('', '', 1)
	GUICtrlSetState($BtnBAKBIOS, $GUI_ENABLE)
	MsgBox(0, '提示', '已经成功安装OEM证书及密匙~', 5)
EndFunc   ;==>InstallOEMCertKey
Func ManualRunBiosTool()
	FileInstall('.\file\bios.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\bios.exe')
	FileDelete(@TempDir & '\bios.exe')
EndFunc   ;==>ManualRunBiosTool
Func _RunDBSLDR()
	FileInstall('.\file\DBSLDR.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\DBSLDR.exe')
	FileDelete(@TempDir & '\DBSLDR.exe')
EndFunc   ;==>_RunDBSLDR
Func KMSVLALL()
	GUICtrlSetState($kmsvlbtn, $GUI_DISABLE)
	PreFiles()
	FileDelete(@TempDir & '\HWIDGen.exe')
	GUICtrlSetState($kmsvlbtn, $GUI_ENABLE)
EndFunc   ;==>KMSVLALL

Func PreFiles()
	FileInstall('.\file\HWIDGen.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\HWIDGen.exe', @TempDir, @SW_HIDE)
EndFunc   ;==>PreFiles

Func _UEFIActor()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $UEFIForm = _GUICreate("UEFI激活辅助工具", 361, 47, 124, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("安装UEFI激活", 4, 10, 91, 25)
	GUICtrlSetOnEvent(-1, '_InstallUEFI')
	GUICtrlCreateButton("卸载UEFI激活", 96, 10, 251, 25)
	GUICtrlSetOnEvent(-1, '_UnInstallUEFI')
	GUICtrlCreateGroup("", 2, 2, 353, 37)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitUEFIForm')
EndFunc   ;==>_UEFIActor
Func QuitUEFIForm()
	_WinAPI_AnimateWindow($UEFIForm, BitOR($AW_BLEND, $AW_HIDE), 500)
	GUIDelete($UEFIForm)
	FileDelete(@TempDir & '\KMS_VL_ALL.exe')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitUEFIForm
Func _InstallUEFI()
	_Installer_EFI_cli()
	_AcerLicFile()
	Local $sCMD = '@ECHO OFF' & @CRLF & _
			'SET SLMGR=cscript //NOLOGO "%SYSTEMROOT%\System32\slmgr.vbs"' & @CRLF & _
			'SET BCDEDIT=%SYSTEMROOT%\System32\bcdedit.exe' & @CRLF & _
			'SET /a COUNT=0' & @CRLF & _
			'ECHO removing boot entry.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'%BCDEDIT% /set {bootmgr} path "\EFI\Microsoft\Boot\bootmgfw.efi" >nul' & @CRLF & _
			'FOR /F "tokens=2" %%A IN (''%BCDEDIT% /enum BOOTMGR ^| FINDSTR /I /R /C:"{........-.*}"'') DO (' & @CRLF & _
			'	%BCDEDIT% /enum %%A | FIND /I "\EFI\WindSLIC\BOOTX64.EFI" >nul' & @CRLF & _
			'	IF NOT !ERRORLEVEL!==1 (' & @CRLF & _
			'		SET /A COUNT=%COUNT%+1' & @CRLF & _
			'		ECHO found WindSLIC boot entry.' & @CRLF & _
			'		ECHO deleting %%A' & @CRLF & _
			'		%BCDEDIT% /delete %%A >nul' & @CRLF & _
			'		ECHO setting boot order.' & @CRLF & _
			'		%BCDEDIT% /set {fwbootmgr} displayorder {bootmgr} /addfirst >nul' & @CRLF & _
			'	)' & @CRLF & _
			')' & @CRLF & _
			'IF %COUNT%==0 ECHO WindSLIC boot entry not found.' & @CRLF & _
			'"%~dp0Installer_EFI_cli.exe"' & @CRLF & _
			'ECHO installing certificate...' & @CRLF & _
			'%SLMGR% -ilc "%~dp0ACER.XRM-MS" >nul' & @CRLF & _
			'ECHO installing key.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'CALL :PRODUCT_VER_CHECK' & @CRLF & _
			'%SLMGR% -ipk %PID_KEY% >nul' & @CRLF & _
			'ECHO restart computer to finish activation.' & @CRLF & _
			'timeout 5' & @CRLF & _
			'EXIT' & @CRLF & _
			':PRODUCT_VER_CHECK' & @CRLF & _
			'   REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductName" | FINDSTR /C:"Windows 7" >nul' & @CRLF & _
			'   IF ERRORLEVEL 1 ECHO ERROR: not Windows 7 & PAUSE & EXIT' & @CRLF & _
			'   FOR /F "tokens=3" %%A IN (''REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "EditionID"'') DO SET EditionID=%%A' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Starter" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :STARTER_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "HomeBasic" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :HOMEBASIC_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "HomePremium" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :HOMEPREMIUM_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Professional" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :PROFESSIONAL_KEY & GOTO :EOF' & @CRLF & _
			'   ECHO %EditionID% | FINDSTR /I "Ultimate" >nul' & @CRLF & _
			'   IF NOT ERRORLEVEL 1 CALL :ULTIMATE_KEY & GOTO :EOF' & @CRLF & _
			'   IF ERRORLEVEL 1 ECHO ERROR: OS is unsupported & PAUSE & EXIT' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':STARTER_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=RDJXR-3M32B-FJT32-QMPGB-GCFF6' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=6K6WB-X73TD-KG794-FJYHG-YCJVG' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=36Q3Y-BBT84-MGJ3H-FT7VD-FG72J' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=RH98C-M9PW4-6DHR7-X99PJ-3FGDB' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=273P4-GQ8V6-97YYM-9YTHF-DC2VP' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':HOMEBASIC_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=MB4HF-2Q8V3-W88WR-K7287-2H4CP' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=89G97-VYHYT-Y6G8H-PJXV6-77GQM' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=36T88-RT7C6-R38TQ-RV8M9-WWTCY' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=DX8R9-BVCGB-PPKRR-8J7T4-TJHTH' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=22MFQ-HDH7V-RBV79-QMVK9-PTMXQ' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':HOMEPREMIUM_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=VQB3X-Q3KP8-WJ2H8-R6B6D-7QJB7' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=38JTJ-VBPFW-XFQDR-PJ794-8447M' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=2QDBX-9T8HR-2QWT6-HCQXJ-9YQTR' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=7JQWQ-K6KWQ-BJD6C-K3YVH-DVQJG' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=6RBBT-F8VPQ-QCPVQ-KHRB8-RMV82' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':PROFESSIONAL_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=YKHFT-KW986-GK4PY-FDWYH-7TP9F' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=2WCJK-R8B4Y-CWRF2-TRJKB-PV9HW' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=32KD2-K9CTF-M3DJT-4J3WC-733WD' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=PT9YK-BC2J9-WWYF9-R9DCR-QB9CK' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=862R9-99CD6-DD6WM-GHDG2-Y8M37' & @CRLF & _
			'GOTO :EOF' & @CRLF & _
			':ULTIMATE_KEY' & @CRLF & _
			'   SET MAX_RANDOM=5' & @CRLF & _
			'   SET /A RANDOM_PID_KEY=%RANDOM% %% %MAX_RANDOM%' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''0'' SET PID_KEY=FJGCP-4DFJD-GJY49-VJBQ7-HYRR2' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''1'' SET PID_KEY=VQ3PY-VRX6D-CBG4J-8C6R2-TCVBD' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''2'' SET PID_KEY=2Y4WT-DHTBF-Q6MMK-KYK6X-VKM6G' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''3'' SET PID_KEY=342DG-6YJR8-X92GV-V7DCV-P4K27' & @CRLF & _
			'   IF ''%RANDOM_PID_KEY%''==''4'' SET PID_KEY=78FPJ-C8Q77-QV7B8-9MH3V-XXBTK' & @CRLF & _
			'GOTO :EOF'
	Local $FhcmdFile = FileOpen(@TempDir & '\UEFIInstall.bat', 2 + 8)
	FileWrite($FhcmdFile, $sCMD)
	FileClose($FhcmdFile)
	Run(@TempDir & '\UEFIInstall.bat')
EndFunc   ;==>_InstallUEFI
Func _UnInstallUEFI()
	_Installer_EFI_cli()
	_AcerLicFile
	Local $sCMD = '@ECHO OFF' & @CRLF & _
			'SETLOCAL ENABLEDELAYEDEXPANSION' & @CRLF & _
			'SET BCDEDIT=%SYSTEMROOT%\System32\bcdedit.exe' & @CRLF & _
			'SET FREEDRIVELETTER=0' & @CRLF & _
			'SET /a COUNT=0' & @CRLF & _
			'::' & @CRLF & _
			'ECHO removing boot entry.' & @CRLF & _
			'ECHO please wait...' & @CRLF & _
			'%BCDEDIT% /set {bootmgr} path "\EFI\Microsoft\Boot\bootmgfw.efi" >nul' & @CRLF & _
			'FOR /F "tokens=2" %%A IN (''%BCDEDIT% /enum BOOTMGR ^| FINDSTR /I /R /C:"{........-.*}"'') DO (' & @CRLF & _
			'	%BCDEDIT% /enum %%A | FIND /I "\EFI\WindSLIC\BOOTX64.EFI" >nul' & @CRLF & _
			'	IF NOT !ERRORLEVEL!==1 (' & @CRLF & _
			'		SET /A COUNT=%COUNT%+1' & @CRLF & _
			'		ECHO found WindSLIC boot entry.' & @CRLF & _
			'		ECHO deleting %%A' & @CRLF & _
			'		%BCDEDIT% /delete %%A >nul' & @CRLF & _
			'		ECHO setting boot order.' & @CRLF & _
			'		%BCDEDIT% /set {fwbootmgr} displayorder {bootmgr} /addfirst >nul' & @CRLF & _
			'	)' & @CRLF & _
			')' & @CRLF & _
			'IF %COUNT%==0 ECHO WindSLIC boot entry not found.' & @CRLF & _
			'"%~dp0Installer_EFI_cli.exe" /u' & @CRLF & _
			'timeout 5'
	Local $FhcmdFile = FileOpen(@TempDir & '\UEFIUnInstall.bat', 2 + 8)
	FileWrite($FhcmdFile, $sCMD)
	FileClose($FhcmdFile)
	Run(@TempDir & '\UEFIUnInstall.bat')
EndFunc   ;==>_UnInstallUEFI


Func _Installer_EFI_cli($bSaveBinary = True, $sSavePath = @TempDir)
	Local $Installer_EFI_cli
	$Installer_EFI_cli &= 'TVqQAAMAAAAEAAAA//8AALgAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8AAAAA4fug4AtAnNIbgBTM0hVGhpcyBwcm9ncmFtIGNhbm5vdCBiZSBydW4gaW4gRE9TIG1vZGUuDQ0KJAAAAAAAAAA1KsbHcUuolHFLqJRxS6iUatY2lGNLqJRq1gOUREuolGrWApQPS6iUcUuplBJLqJR4MzuUeEuolGrWB5R1S6iUatYylHBLqJRq1jWUcEuolFJpY2hxS6iUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUEUAAEwBBQDrFN1PAAAAAAAAAADgAAIBCwEKAABKAQAAzAAAAAAAAEhrAAAAEAAAAGABAAAAQAAAEAAAAAIAAAUAAQAAAAAABQABAAAAAAAAYAIAAAQAAMNAAgADAECBAAAQAAAQAAAAABAAABAAAAAAAAAQAAAAAAAAAAAAAAAsrAEAZAAAAAAAAgBAPgAAAAAAAAAAAAAAAAAAAAAAAABAAgCcEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlQEAQAAAAAAAAAAAAAAAAGABAIABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAudGV4dAAAAAhJAQAAEAAAAEoBAAAEAAAAAAAAAAAAAAAAAAAgAABgLnJkYXRhAAAAVQAAAGABAABWAAAATgEAAAAAAAAAAAAAAAAAQAAAQC5kYXRhAAAAxDUAAADAAQAAFgAAAKQBAAAAAAAAAAAAAAAAAEAAAMAucnNyYwAAAEA+AAAAAAIAAEAAAAC6AQAAAAAAAAAAAAAAAABAAABALnJlbG9jAAB+HgAAAEACAAAgAAAA+gEAAAAAAAAAAAAAAAAAQAAAQgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGigAQAAuAVYQQDocWYAAI2FVP7//1DoowkAADPAM9uJXfyNfdyrq6tqMKuNhXz///9TUMeFYP///wEAAADorqwAAIPEDGoFWWoHvuiPQQCNfcjzpVkzwL78j0EAjX2s86WNvWj///+rq6urU6tqFI2FaP///1BqWomdRP///4mdZP///4mdTP///4mdXP///4mdUP///4mdVP///4mdWP////8VdGFBAIXAdQmDvXj///8CdDtoGJBBAOjFRQAAWWoCXoNN/P+NjbT+///oeQoAAI2FtP7//1DHhbT+//80k0EA6NQ5AABZi8bpkgcAAOjbIQAAhcB1EGhAkEEA6IFFAAAz9llG67pqEMZF/AHoMjkAAFmL+L4IAgAAVom9TP///+geOQAAWVaJhVz////oETkAAFlWiYVQ////6AQ5AABZVomFVP///+j3OAAAWWpIiYVY////6Ok4AACL8Fk783QUakhTVuiDqwAAg8QMibVk////6waJnWT///9X6Bw3AACNhWT///9Q6JAhAABZWYP4DnU5agGNhWD///9QjY0U////x4Vg////lJJBAOjnRAAAx4UU////LGJBAGjMpkEAjYUU////UOjhXwAA/7Vk////izVsYUEA'
	$Installer_EFI_cli &= 'V2hokEEA/7Vc/////9ZXaICQQQD/tVD/////1o1FrFD/tVz///9opJBBAP+1VP/////WjUWsUP+1ZP///2iwkEEA/7VY/////9bohTUAAFfovzYAAIPEQP+1UP///+ghJAAAWf+1XP///+gVJAAAWTvDdApqZP8VXGBBAOvmi0UMi0AEO8N0Q7nIkEEAZosQZjsRdR5mO9N0FWaLUAJmO1ECdQ+DwASDwQRmO9N13jPA6wUbwIPY/zvDdQ9o0JBBAOjiQwAA6aUEAABT/7Vc/////xU4YEEAhcAPhH4EAAD/tVT///9oAJFBAOi4QwAAiz0QYEEAWVloOJFBAGplagD/14sdFGBBAIvwVmoA/9NWagCJhTz/////FRhgQQD/tTz///+L8Og+NwAAWf+1PP///4mFSP///1aLNRxgQQD/1lD/tUj////oJlsAAIPEDGhAkUEAamZqAP/Xi/hXagD/01CJhTj////o+zYAAFlXi9gz/1eJnSD/////FRhgQQD/tTj///9Q/9ZQU+jiWgAAV+giRQAAUOjpRAAAg8QUM/aD/hBzFejsRAAAal2ZWff5gMIhiFQ13Ebr5moPWDP2O7U4////cxOKTAXcMAweSIP4/3UDag9YRuvlM8CD+BBzB/ZUBdxA6/SJvUD///+LhTz///+DwPo5hUD///8Pg5IBAACLnUD///8DnUj///8zyTP2gDtTiY0s////iY0k////iY0o////iY0w////iY00////dUeAewFMdUGAewJQdTuAewNTdTWAewRUdS+AewVSdSlqCFkzwGoKi/vzq1hQuEiRQQBQU+gEWgAAM/9Hg8QMib0k////M8nrAzP/R4A7S3UvgHsBRXUpgHsCWXUjgHsDS3UdgHsERXUXgHsFWXURjXXci/ulpaWlM/Yz/0YzyUeAO1N1O4B7AUx1NYB7Akl1L4B7A0N1KYB7BHZ1I4B7BQF1Hf+1OP////+1IP///1PoiFkAAIPEDIm9LP///zPJgDtBdR2AewFBdReAewJBdRGAewNBdQtqCliJA4m9KP///4A7QnUfgHsBQnUZgHsCQnUTgHsDQnUNuAAADwCJA4m9MP///4A7Q3UfgHsBQ3UZgHsCQ3UTgHsDQ3UNuP//DwCJA4m9NP///zvxdCg5jSz///90IDmNJP///3QYOY00////dBA5jTD///90CDmNKP///3UL/4VA////6Vn+////tVT///+NhVT+//9Q6AcFAAAz2zmdrP7//3RXU/+1PP///42FVP7///+1SP///1Do+QIAAI2FWP7//+jrDAAAO8N1L4uFVP7//4tIBI2MDVT+//+LQQyDyAI5WTh1A4PIBIPgF4lBDIVBEHQGU+iXGwAA/7VI////6PVCAAD/tSD////o6kIAAFlZ6GwnAADoJyUAAOiyKQAAi/iD//91EGiQkUEA6GVAAABZ6TIBAABXjYV8////aMiRQQBQ/xVsYUEA/7VY////jYVE////UFONTcjowioAAIPEGIP4DnU4agGNhWD///9QjY38/v//x4Vg////lJJBAOgoQAAAx4X8/v//LGJBAGjMpkEAjYX8/v//6Tz7////tUT////orTMAAFn/tVj///+L8I2FRP///1BWjU3I6F4qAACDxAw7w3Q9g/gOdWtqAY2FYP///1CNjQj////HhWD///+UkkEA6MA/AADHhQj///8sYkEAaMymQQCNhQj////p1Pr//42FfP///1Bo4JFBAOh9PwAAWVn/tUT///+NhXz///9WaMDUQQBQ/xUkYEEAV+joIQAAWVaJnWD////oskEAAOnl/v///xUgYEEAUGhUkUEA6Dk/AABZWegeJgAA6NkjAAD/tUz////oPjIAAFn/tWT////oeUEAAP+1WP///+huQQAA/7VU////6GNBAAD/tVz////oWEEAAP+1UP///+hNQQAA/7VM////6EJBAACDTfz/g8QYjY20/v//6JQDAACN'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'i0SO+IlEj/iLRI78iUSP/I0EjQAAAAAD8AP4/ySVwG9AAIv/0G9AANhvQADkb0AA+G9AAItFCF5fycOQigaIB4tFCF5fycOQigaIB4pGAYhHAYtFCF5fycONSQCKBogHikYBiEcBikYCiEcCi0UIXl/Jw5CNdDH8jXw5/PfHAwAAAHUkwekCg+IDg/kIcg3986X8/ySVXHFAAIv/99n/JI0McUAAjUkAi8e6AwAAAIP5BHIMg+ADK8j/JIVgcEAA/ySNXHFAAJBwcEAAlHBAALxwQACKRgMj0YhHA4PuAcHpAoPvAYP5CHKy/fOl/P8klVxxQACNSQCKRgMj0YhHA4pGAsHpAohHAoPuAoPvAoP5CHKI/fOl/P8klVxxQACQikYDI9GIRwOKRgKIRwKKRgHB6QKIRwGD7gOD7wOD+QgPglb////986X8/ySVXHFAAI1JABBxQAAYcUAAIHFAAChxQAAwcUAAOHFAAEBxQABTcUAAi0SOHIlEjxyLRI4YiUSPGItEjhSJRI8Ui0SOEIlEjxCLRI4MiUSPDItEjgiJRI8Ii0SOBIlEjwSNBI0AAAAAA/AD+P8klVxxQACL/2xxQAB0cUAAhHFAAJhxQACLRQheX8nDkIpGA4hHA4tFCF5fycONSQCKRgOIRwOKRgKIRwKLRQheX8nDkIpGA4hHA4pGAohHAopGAYhHAYtFCF5fycOL/1WL7IPsIItFCFZXaghZvuBjQQCNfeDzpYlF+ItFDF+JRfxehcB0DPYACHQHx0X0AECZAY1F9FD/dfD/deT/deD/FaRgQQDJwggAi/9Vi+xRU4tFDIPADIlF/GSLHQAAAACLA2SjAAAAAItFCItdDItt/Itj/P/gW8nCCABYWYcEJP/gi/9Vi+xRUVNWV2SLNQAAAACJdfzHRfhhckAAagD/dQz/dfj/dQjoI+EAAItFDItABIPg/YtNDIlBBGSLPQAAAACLXfyJO2SJHQAAAABfXlvJwggAVYvsg+wIU1ZX/IlF/DPAUFBQ/3X8/3UU/3UQ/3UM/3UI6AoSAACDxCCJRfhfXluLRfiL5V3Di/9Vi+xW/It1DItOCDPO6KHj//9qAFb/dhT/dgxqAP91EP92EP91COjNEQAAg8QgXl3Di/9Vi+yD7DhTgX0IIwEAAHUSuJ5zQACLTQyJATPAQOmwAAAAg2XYAMdF3MpzQAChkMRBAI1N2DPBiUXgi0UYiUXki0UMiUXoi0UciUXsi0UgiUXwg2X0AINl+ACDZfwAiWX0iW34ZKEAAAAAiUXYjUXYZKMAAAAAx0XIAQAAAItFCIlFzItFEIlF0OjlMgAAi4CAAAAAiUXUjUXMUItFCP8w/1XUWVmDZcgAg338AHQXZIsdAAAAAIsDi13YiQNkiR0AAAAA6wmLRdhkowAAAACLRchbycOL/1WL7FFT/ItFDItICDNNDOiV4v//i0UIi0AEg+BmdBGLRQzHQCQBAAAAM8BA62zramoBi0UM/3AYi0UM/3AUi0UM/3AMagD/dRCLRQz/cBD/dQjolxAAAIPEIItFDIN4JAB1C/91CP91DOj8/f//agBqAGoAagBqAI1F/FBoIwEAAOih/v//g8Qci0X8i10Mi2Mci2sg/+AzwEBbycOL/1WL7FFTVleLfQiLRxCLdwyJRfyL3usrg/7/dQXokVoAAItNEE6LxmvAFANF/DlIBH0FO0gIfgWD/v91Cf9NDItdCIl1CIN9DAB9zItFFEaJMItFGIkYO18MdwQ783YF6E5aAACLxmvAFANF/F9eW8nDi/9Vi+yLRQxWi3UIiQboeTEAAIuAmAAAAIlGBOhrMQAAibCYAAAAi8ZeXcOL/1WL7OhWMQAAi4CYAAAA6wqLCDtNCHQKi0AEhcB18kBdwzPAXcOL/1WL7FboLjEAAIt1CDuwmAAAAHUR6B4xAACLTgSJiJgAAABeXcPoDTEAAIuAmAAAAOsJi0gEO/F0D4vBg3gEAHXxXl3ppFkA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'FhkAAIPI/+s/i3UQhfZ0CoP+AXQFg/4Cddr/dQjoptL//1mDZfwAVv91DP91COgf////g8QMiUXkx0X8/v///+gJAAAAi0Xk6LwZAADD/3UI6OXS//9Zw4v/VovxhfZ0G4XAdBc7xnQTV2o2WYv486WDIABQ6AxkAABZX17Di/9Vi+xTVzPbM/85XRB+IlaNdRCDxgT/Nv91DP91COgBbgAAg8QMhcB1C0c7fRB8415fW13DU1NTU1PoChgAAMyL/1WL7FNWV4t9CGiQAAAAM9tTV+gMNQAAi3UMigaDxAyEwHUHM8Dp4gAAADwudTGNRgE4GHQqag9QjYeAAAAAahBQ6LVHAACDxBCFwHUIiJ+PAAAA685TU1NTU+ioFwAAaGhlQQBWiV0M6OZtAAA7w+mNAAAAg30MAI08MIofdReD+EAPg4EAAACA+y50fFBWakD/dQjrO4N9DAF1FoP4QHNogPtfdGNQi0UIVmpAg8BA6x6DfQwCdVGD+BBzTITbdAWA+yx1Q1CLRQhWahCD6IBQ6CVHAACDxBCFwHU0gPssD4Q9////hNsPhDX/////RQyNdwFoaGVBAFboVG0AAIXAWVkPhWv///+DyP9fXltdwzPAUFBQUFDpPf///4v/VYvsU1aLdRBW/3UM/3UI6GEaAACDxAwz24XAdUGNRkA4GHQWUGhwZUEAagL/dQz/dQjoZ/7//4PEFI2GgAAAADgYXlt0FlBobGVBAGoC/3UM/3UI6EX+//+DxBRdw1NTU1NT6IAWAADMi/9Vi+yD7BBTM9tDaFUDAACJXfToJRIAAFmJRfCFwA+EPQEAAFeNeATGBwCJGP92WLtRAwAAaHhlQQD/NaxkQQBqA1NX6Ov9//+NRliDxBjHRfysZEEAiUX4aHRlQQBTV+j0awAAg8QMhcAPhZYAAACLRfiNSBD/MYlN+P8w6FgaAABZWYXAdASDZfQAi0X4/zCDRfwMaHhlQQCJRfiLRfz/MGoDU1foif3//4PEGIF9/NxkQQB8ooN99AB1VYtGUIsddGBBAIXAdBBQ/9OFwHUJ/3ZQ6FXf//9Zi0ZUhcB0EFD/04XAdQn/dlToPt///1mLRfCDZlQAg2ZMAIlGUIl+SIvH61ozwFBQUFBQ6GwVAAD/dfDoFN///4tGUIs9dGBBADPbWTvDdBBQ/9eFwHUJ/3ZQ6PXe//9Zi0ZUO8N0EFD/14XAdQn/dlTo3t7//1mLRmiJXlSJXkyJXlCJXkhfW8nDi/9Vi+yB7LQAAAChkMRBADPFiUX8i0UMU1aLdQhXi30UiYVk////i0UYib1c////iYVg////6HMbAACNiMQAAACJjVT///+NiMgAAACNmLwAAAAFSwEAAImNWP///4mFaP///4X2D4SkAQAAg71k////AA+ElwEAAIN9EAAPhI0BAACAPkN1U4B+AQB1TWioY0EA/3UQ/7Vk////6AYYAACDxAyFwHUnhf90C2aJB2aJRwJmiUcEi4Vg////hcB0A4MgAIuFZP///+lDAQAAM8BQUFBQUOg/FAAAVugl4v//v4MAAABZiYVQ////O8dzLFb/tWj////oeRgAAFlZhcAPhKMAAABW/7VY////6GMYAABZWYXAD4SNAAAAg6VM////AI2FbP///1ZQ6OD7//9ZWYXAD4XVAAAAjYVs////UFNQ6PBvAACDxAyFwA+EvAAAAA+3QwSLjVT///+JAY2FbP///1BX/7Vo////6L38//+DxAyAPgB0CouFUP///zvHcguLhUz///++nmNBAEBQVlf/tVj////ob0MAAIPEEIXAD4Ul////M/Y5tVz///90EWoGU/+1XP///+jU4f//g8QMObVg////dBZqBP+1VP////+1YP///+i24f//g8QM/7Vo/////3UQ/7Vk////6LAWAACDxAyFwHUIi4Vo////6wxWVlZWVunG/v//M8CLTfxfXjPNW+icyf//ycOL/1WL7IHsyAEAAKGQ'
	$Installer_EFI_cli &= 'xEEAM8WJRfyLRQhTi9lXiZ1w/v//iYVo/v//6GAZAACL+FONhVz+//9QjYVQ/v//UGiDAAAAjYV4////UP+1aP7//+iK/f//g8QYhcB1EDPAi038XzPNW+gwyf//ycPB4wQD3v9zSI2FeP///1Do1RYAAFlZhcB1BYtDSOvTjYV4////UOhO4P//g8AFUImFdP7//+gSDgAAWVmJhWz+//+FwHSqi0NIi41w/v//iYVo/v//jUSODImFWP7//4sAiYVI/v//jUEGa8AGA8ZqBlCJhWT+//+NhTj+//9Q6IXg//+LRgSNjXj///9Ri410/v//iYVM/v//i4Vs/v//g8H8g8AEUVDobRUAAIPEGIXAD4UJAgAAi4Vs/v//i41Y/v//g8AEiUNID7eFUP7//4kBagaNhVD+//9Q/7Vk/v//6CLg//+DxAyDvXD+//8CD4UZAQAAi4Vc/v//g6V0/v//AIlGBIuH9AEAAIuP8AEAAImFZP7//42H0AEAAItWBDsQdDaLEP+FdP7//4kIi41k/v//iZVA/v//i1AEiUgEi41A/v//g8AIg710/v//BYmVZP7//3zF6y2LhXT+//+FwHQjjYTH0AEAAIsQiZfQAQAAi1AEiZfUAQAAiQiLjWT+//+JSASDvXT+//8FdXJqAf92FI2FeP7///92BFBqf2joZEEAagFqAOgnhQAAg8QghcB0PDPAuf8BAABmIYxFeP7//0CD+H9y7Wj+AAAA/zWAxEEAjYV4/v//UOi5bgAAg8QM99gbwECJh9QBAADrB4On1AEAAACLRgSJh9ABAACLh9QBAACJhqgAAACDvXD+//8BdQmLhVz+//+JRgiLhXD+//9rwAxW/5CoZEEAWYXAdDGLhWj+////tWz+//+JQ0jo8tn//4uFSP7//1mLjVj+//+JAYuFTP7//4lGBOmI/f//gb1o/v//QMhBAHQui71w/v//g8cFA///NP7/FXRgQQCFwHUW/zT+6KnZ////c1Toodn//4NjTABZWYuNcP7//4uFbP7//4PBBQPJxwABAAAAiQTO6Vn9//8zwFBQUFBQ6MAPAADMi/9Vi+yB7JgAAAChkMRBADPFiUX8i0UIU1Yz24vyV4m1aP///zvLdBs7w3QMUOiT/P//WenUAQAAA8mLRM5I6ckBAADHhXD///8BAAAAiZ10////O8MPhKwBAACAOEwPhTABAACAeAFDD4UmAQAAgHgCXw+FHAEAAIv4aHxlQQBX6IWEAACL2FlZhdsPhP8AAAArx4mFcP///w+E8QAAAIA7Ow+E6AAAAMeFbP///wEAAAC+rGRBAOsGi4Vw////UFf/NuiBgwAAg8QMhcB1EP826NTc//9ZOYVw////dBH/hWz///+DxgyB/txkQQB+yUNodGVBAFPoDmUAAIv4M/ZZWTv+dQmAOzsPhYEAAACDvWz///8Ff0RXU42FeP///2iDAAAAUOiHPgAAg8QQhcB1VIuNbP///4u1aP///4iEPXj///+NhXj///9Q6HT7//9ZhcB0Bv+FdP///wP7gD8AdApHgD8AD4UN////M8A5hXT///8PhJEAAACLtWj////pgQAAAFZWVlZW6C4OAAAzwOt4U1NTaIMAAACNjXj///9RUOj7+P//g8QYO8N0XI1+SIXbdDX/N42FeP///1DoVRIAAFlZhcB0G42FeP///1CLy+js+v//WYXAdQghhXD////rBv+FdP///0ODxxCD+wV+vjPAOYVw////dQg5hXT///90Begz9///i038X14zzVvoRsT//8nDahRoUKJBAOiTDgAAg2XgAIN9CAV2F+gsDgAAxwAWAAAA6M8NAAAzwOk5AQAA6AUUAACL8Il15OjlWwAAg05wEINl/AAz/0dXaNgAAADoVQkAAFlZi9iJXdyF2w+E9gAAAGoM6EUeAABZiX38i05si8PovfT//4Nl/ADoswAAAP91DItNCIvT6Fj9//9ZiUXghcAP'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'i0UQOYVA5f//D4L5/f//6QgDAACLDooT/4U45f//iFQPNIsOiUQPOOnvAgAAM8mLA/ZEOASAD4ShAgAAgL0/5f//AImNROX//w+FqAAAAIudNOX//zlNEA+G/QIAAIvLM/YrjTTl//+NhUjl//87TRBzJooTQ0GJnSDl//+A+gp1C/+FMOX//8YADUBGiBBARoH+/xMAAHLVi/CNhUjl//8r8GoAjYUo5f//UFaNhUjl//9Qi4Uk5f//iwD/NAf/FQBhQQCFwA+EQwIAAIuFKOX//wGFOOX//zvGD4w7AgAAi8MrhTTl//87RRAPgmz////pJQIAAIC9P+X//wIPhc0AAACLnTTl//85TRAPhkgCAACDpUDl//8Ai8srjTTl//9qAo2FSOX//147TRBzQw+3EwPeA86JnSDl//+D+gp1GgG1MOX//2oNW2aJGIudIOX//wPGAbVA5f//AbVA5f//ZokQA8aBvUDl///+EwAAcriL8I2FSOX//yvwagCNhSjl//9QVo2FSOX//1CLhSTl//+LAP80B/8VAGFBAIXAD4RpAQAAi4Uo5f//AYU45f//O8YPjGEBAACLwyuFNOX//ztFEA+CR////+lLAQAAi4U05f//iYUs5f//OU0QD4Z1AQAAi40s5f//g6VA5f//ACuNNOX//2oCjYVI+f//XjtNEHM7i5Us5f//D7cSAbUs5f//A86D+gp1DmoNW2aJGAPGAbVA5f//AbVA5f//ZokQA8aBvUDl//+oBgAAcsAz9lZWaFUNAACNjfDr//9RjY1I+f//K8GZK8LR+FCLwVBWaOn9AAD/FahgQQCL2DveD4SXAAAAagCNhSjl//9Qi8MrxlCNhDXw6///UIuFJOX//4sA/zQH/xUAYUEAhcB0DAO1KOX//zvef8vrDP8VIGBBAImFROX//zvef1yLhSzl//8rhTTl//+JhTjl//87RRAPggv////rP1GNjSjl//9R/3UQ/7U05f///zQ4/xUAYUEAhcB0FYuFKOX//4OlROX//wCJhTjl///rDP8VIGBBAImFROX//4O9OOX//wB1bIO9ROX//wB0LWoFXjm1ROX//3UU6E7n///HAAkAAADoVuf//4kw6z//tUTl///oWuf//1nrMYuFJOX//4sA9kQHBEB0D4uFNOX//4A4GnUEM8DrJOgO5///xwAcAAAA6Bbn//+DIACDyP/rDIuFOOX//yuFMOX//1uLTfxfM81e6N+c///Jw2oQaHijQQDoLOf//4tdCIP7/nUb6Nrm//+DIADov+b//8cACQAAAIPI/+mUAAAAhdt4CDsdjORBAHIa6LPm//+DIADomOb//8cACQAAAOg75v//69KLw8H4BY08haDkQQCL84PmH8HmBosHD75EMASD4AF0xlPoSHMAAFmDZfwAiwf2RDAEAXQU/3UQ/3UMU+hu+P//g8QMiUXk6xfoPub//8cACQAAAOhG5v//gyAAg03k/8dF/P7////oDAAAAItF5Oi15v//w4tdCFPokHMAAFnDi/9Vi+z/BXTWQQBoABAAAOgS4f//WYtNCIlBCIXAdA2DSQwIx0EYABAAAOsRg0kMBI1BFIlBCMdBGAIAAACLQQiDYQQAiQFdw4v/VYvsVot1CIX2dRXoseX//8cAFgAAAOhU5f//6foAAACLRgyogw+E7wAAAKhAD4XnAAAAqAJ0C4PIIIlGDOnYAAAAg8gBiUYMqQwBAAB1CVboYP///1nrBYtGCIkG/3YY/3YIVuhV9///WVDoSnoAAIPEDIlGBIXAD4SLAAAAg/j/D4SCAAAA9kYMgnVRVugr9///WYP4/3QwVugf9///WYP4/nQkV1boEvf//8H4BVaNPIWg5EEA6AL3//+D4B9ZweAGAwdZX+sFuCDGQQCKQAQkgjyCdQeBTgwAIAAAgX4YAAIAAHUVi0YMqAh0DqkABAAAdQfHRhgAEAAAiw7/TgQPtgFBiQ7rFPfYG8CD4BCD'
	$Installer_EFI_cli &= 'wBAJRgyDZgQAg8j/Xl3DV4vGg+APhcAPhcEAAACL0YPhf8HqB3Rl6waNmwAAAABmD28GZg9vThBmD29WIGYPb14wZg9/B2YPf08QZg9/VyBmD39fMGYPb2ZAZg9vblBmD292YGYPb35wZg9/Z0BmD39vUGYPf3dgZg9/f3CNtoAAAACNv4AAAABKdaOFyXRJi9HB6gSF0nQXjZsAAAAAZg9vBmYPfweNdhCNfxBKde+D4Q90JIvBwekCdA2LFokXjXYEjX8ESXXzi8iD4QN0CYoGiAdGR0l191heX13DuhAAAAAr0CvKUYvCi8iD4QN0CYoWiBdGR0l198HoAnQNixaJF412BI1/BEh181npC////2oK/xUMYUEAo3DkQQAzwMPMzMzMzMyLVCQMi0wkBIXSdGkzwIpEJAiEwHUWgfqAAAAAcg6DPXDkQQAAdAXpS3kAAFeL+YP6BHIx99mD4QN0DCvRiAeDxwGD6QF19ovIweAIA8GLyMHgEAPBi8qD4gPB6QJ0BvOrhdJ0CogHg8cBg+oBdfaLRCQIX8OLRCQEw4v/VYvsUVGLRQxWi3UIiUX4i0UQV1aJRfzoam8AAIPP/1k7x3UR6OPi///HAAkAAACLx4vX60r/dRSNTfxR/3X4UP8VEGFBAIlF+DvHdRP/FSBgQQCFwHQJUOjV4v//WevPi8bB+AWLBIWg5EEAg+YfweYGjUQwBIAg/YtF+ItV/F9eycNqFGiYo0EA6NXi//+Dy/+JXdyJXeCLRQiD+P51HOh64v//gyAA6F/i///HAAkAAACLw4vT6aEAAACFwHgIOwWM5EEAchroUuL//4MgAOg34v//xwAJAAAA6Nrh///r0YvIwfkFjTyNoORBAIvwg+YfweYGiw8PvkwxBIPhAXTGUOjnbgAAWYNl/ACLB/ZEMAQBdBz/dRT/dRD/dQz/dQjo1/7//4PEEIlF3IlV4OsZ6NXh///HAAkAAADo3eH//4MgAIld3Ild4MdF/P7////oDAAAAItF3ItV4OhH4v//w/91COgjbwAAWcOL/1WL7LggEAAA6NhsAAChkMRBADPFiUX8U1aLdQhXVuh38///i9gzwFmJnejv//85RgR9A4lGBGoBUFBT6NT+//+DxBCL+Im97O///4mV8O///4XSfxB8BIX/cwqDyP8L0OnUAgAAi8PB+AWNBIWg5EEAg+MfiYXk7///iwDB4wYDw4pIJALJ0Pn3RgwIAQAAiI377///dReLRgSLjfDv//+ZK/gbyovHi9HpiwIAAIsOi1YMi/krfgiJvfTv///2wgMPhFsBAACAvfvv//8BD4UaAQAAM9I5UDAPhA8BAADR74m94O///zlWBHURi4Xs7///i5Xw7///6TwCAABS/3As/3Ao/7Xo7///6AX+//+L8IuF5O///4sAg8QQi/o7dBgoD4Uz////O3wYLA+FKf///2oAjY307///UWgAEAAAjY387///Uf80GP8VFGFBAIXAD4QD////agD/tfDv////tezv////tejv///oo/3//4PEEIXSfw4PjN3+//+FwA+C1f7//4uN9O///4ud4O///zvZD4fB/v//jYX87///hdt0N42UDfzv//9LO8JzK4oIgPkNdRONSv87wXMYjUgBgDkKdRCLwesMD7bJD76JYNBBAAPBQIXbddCNjfzv//8rwTPSA8YT1+lLAQAA9kAEgHQVi1YI6wyAOgp1Bv+F9O///0I70XLwi5Xs7///C5Xw7///dR+LhfTv///pFwEAAITSeOPoct///8cAFgAAAOkl/v//9kYMAQ+E1gAAAItWBIXSdQshlfTv///pxAAAACtOCPZABICNPAoPhJwAAABqAmoAagD/tejv///oofz//4PEEDuF7O///3UkO5Xw7///dRyLRgiNDDjrB4A4CnUBR0A7wXL190YMACAAAOtZagD/tfDv////tezv////tejv///oWfz//4PEEIXSfw4PjJP9//+F'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '/3UQUOhcbAAAi/CDxBSF9nVi/xUgYEEAg/h6dXhWVv91FP91EP+1eP///+g1bAAAg8QUiYVw////hcB0WEZWUOg3zv//i9hZWYXbdEj/tXD///+JtXT///9T/3UU/3UQ/7V4////6PprAACL8IPEFIX2dBpqAVboAM7//4kHM/9ZWTvHdSE5vXT///90B1PolJv//1mDyP+LTfxfXjPNW+h0iP//ycONTv9RU1ZQ6LkBAACDxBCFwHUTOb10////dAdT6GCb//9ZM8Dry1dXV1dX6KHR//+DfQwCdUiLNThhQQAzwFBQ/3UUiQf/dRD/1ovYhdt0HmoCU+h9zf//WVmJB4XAdA5TUP91FP91EP/WhcB1tP836Ayb//+DJwBZ6XD///+DfQwAD4Vm////g6V4////AGoCjYV4////UItFFA0AAAAgUP91EP8VOGFBAIXAD4Q8////ioV4////iAfpY////4v/VYvsi0UIo7DjQQBdw2oIaBikQQDo89H//+iG1///i0B4hcB0FoNl/AD/0OsHM8BAw4tl6MdF/P7////obs3//+gM0v//w+hZ1///i0B8hcB0Av/Q6bT///9qCGg4pEEA6KfR////NbTjQQD/FYxgQQCFwHQWg2X8AP/Q6wczwEDDi2Xox0X8/v///+h9////zGjRzkAA/xWIYEEAo7TjQQDDzMzMzMzMzMzMzFWL7IPsBFNRi0UMg8AMiUX8i0UIVf91EItNEItt/Oh5awAAVlf/0F9ei91di00QVYvrgfkAAQAAdQW5AgAAAFHoV2sAAF1ZW8nCDAC4MMhBAMO4gMdBAMOL/1WL7ItFCFMz21ZXOV0UdRA7w3UQOV0MdRIzwF9eW13DO8N0B4t9DDv7dxPoftD//2oWXokw6CLQ//+LxuvdOV0UdQSIGOvSi1UQO9N1BIgY69mDfRT/i8h1E4vwK/KKCogMFkI6y3QiT3Xz6x2L8ivwihQOiBFBOtN0CE90Bf9NFHXuOV0UdQKIGTv7dYuDfRT/dQ+LTQxqUIhcCP9Y6Xj///+IGOgE0P//aiJZiQiL8euCi/9Vi+yDfQgAdRXo68///8cAFgAAAOiOz///g8j/XcP/dQhqAP81dNtBAP8VPGFBAF3Di/9Vi+wzwECDfQgAdQIzwF3DahBoWKRBAOgC0P//M9sz/4l95GoB6ALg//9ZiV38M/aJdeA7NcD1QQAPjcoAAAChqOVBAI0EsDkYdFuLAItADKiDdUipAIAAAHVBjUb9g/gQdxKNRhBQ6P7e//9ZhcAPhJQAAAChqOVBAP80sFbo4Ij//1lZoajlQQCLBLD2QAyDdAxQVug3if//WVlG65GL+Il95OtjajjoNMr//1mLDajlQQCJBLE7w3ROaKAPAAChqOVBAIsEsIPAIFD/FfBgQQCFwKGo5UEAdRP/NLDo75f//1mhqOVBAIkcsOsbiwSwg8AgUP8VgGBBAKGo5UEAizywiX3kiV8MO/t0FoFnDACAAACJXwSJXwiJH4lfHINPEP/HRfz+////6AsAAACLx+gtz///w4t95GoB6BLe//9Zw8zMzMzMzMzMzMzMU1ZXi1QkEItEJBSLTCQYVVJQUVFokNJAAGT/NQAAAAChkMRBADPEiUQkCGSJJQAAAACLRCQwi1gIi0wkLDMZi3AMg/7+dDuLVCQ0g/r+dAQ78nYujTR2jVyzEIsLiUgMg3sEAHXMaAEBAACLQwjoomgAALkBAAAAi0MI6LRoAADrsGSPBQAAAACDxBhfXlvDi0wkBPdBBAYAAAC4AQAAAHQzi0QkCItICDPI6MWD//9Vi2gY/3AM/3AQ/3AU6D7///+DxAxdi0QkCItUJBCJArgDAAAAw1WLTCQIiyn/cRz/cRj/cSjoFf///4PEDF3CBABVVldTi+ozwDPbM9Iz9jP//9FbX15dw4vqi/GLwWoB6P9nAAAzwDPbM8kz0jP//+ZVi+xTVldqAFJoNtNAAFHoToAAAF9e'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'RfRqAlDoHO7//wv4jYYUAQAAUGpNU41F9GoCUOgF7v//g8RQC/iNhhgBAABQak5TjUX0agJQ6Ovt//8L+I2GHAEAAFBqT1NqAo1F9FDo1O3//wv4jYYgAQAAUGo4U41F9GoCUOi97f//C/iNhiQBAABQajlTjUX0agJQ6Kbt//+DxFAL+I2GKAEAAFBqOlONRfRqAlDojO3//wv4jYYsAQAAUGo7U41F9GoCUOh17f//C/iNhjABAABQajxTjUX0agJQ6F7t//8L+I2GNAEAAFBqPVONRfRqAlDoR+3//4PEUAv4jYY4AQAAUGo+U41F9GoCUOgt7f//C/iNhjwBAABQaj9TjUX0agJQ6Bbt//8L+I2GQAEAAFBqQFONRfRqAlDo/+z//wv4jYZEAQAAUGpBU41F9GoCUOjo7P//g8RQC/iNhkgBAABQakJTjUX0agJQ6M7s//8L+I2GTAEAAFBqQ1ONRfRqAlDot+z//wv4jYZQAQAAUGooU41F9GoCUOig7P//C/iNhlQBAABQailTagJbjUX0U1Doh+z//4PEUAv4jYZYAQAAUGof/3X8jUX0U1DobOz//wv4jYZcAQAAUGog/3X8jUX0U1DoVOz//4HGYAEAAFZoAxAAAP91/Av4jUX0U1DoOez//4PEPAvHX15bycOL/1WL7FaLdQiF9g+EYwMAAP92BOiEiP///3YI6HyI////dgzodIj///92EOhsiP///3YU6GSI////dhjoXIj///826FWI////diDoTYj///92JOhFiP///3Yo6D2I////dizoNYj///92MOgtiP///3Y06CWI////dhzoHYj///92OOgViP///3Y86A2I//+DxED/dkDoAoj///92ROj6h////3ZI6PKH////dkzo6of///92UOjih////3ZU6NqH////dljo0of///92XOjKh////3Zg6MKH////dmTouof///92aOiyh////3Zs6KqH////dnDooof///92dOiah////3Z46JKH////dnzoiof//4PEQP+2gAAAAOh8h////7aEAAAA6HGH////togAAADoZof///+2jAAAAOhbh////7aQAAAA6FCH////tpQAAADoRYf///+2mAAAAOg6h////7acAAAA6C+H////tqAAAADoJIf///+2pAAAAOgZh////7aoAAAA6A6H////trwAAADoA4f///+2wAAAAOj4hv///7bEAAAA6O2G////tsgAAADo4ob///+2zAAAAOjXhv//g8RA/7bQAAAA6MmG////trgAAADovob///+22AAAAOizhv///7bcAAAA6KiG////tuAAAADonYb///+25AAAAOiShv///7boAAAA6IeG////tuwAAADofIb///+21AAAAOhxhv///7bwAAAA6GaG////tvQAAADoW4b///+2+AAAAOhQhv///7b8AAAA6EWG////tgABAADoOob///+2BAEAAOgvhv///7YIAQAA6CSG//+DxED/tgwBAADoFob///+2EAEAAOgLhv///7YUAQAA6ACG////thgBAADo9YX///+2HAEAAOjqhf///7YgAQAA6N+F////tiQBAADo1IX///+2KAEAAOjJhf///7YsAQAA6L6F////tjABAADos4X///+2NAEAAOiohf///7Y4AQAA6J2F////tjwBAADokoX///+2QAEAAOiHhf///7ZEAQAA6HyF////tkgBAADocYX//4PEQP+2TAEAAOhjhf///7ZQAQAA6FiF////tlQBAADoTYX///+2WAEAAOhChf///7ZcAQAA6DeF////tmABAADoLIX//4PEGF5dw4v/VYvsU1aLdQiDfiAAV7tIyEEAdEJoZAEAAGoB6Fi3//+L+FlZhf91BTPAQOtJi8aLz+hS9P//hcB0EFfoR/z//1fo3oT//1lZ697Hh7QAAAABAAAA6wKL+4uG1AAAADvDdAwFtAAAAFD/FXRg'
	$Installer_EFI_cli &= 'QQCJvtQAAAAzwF9eW13Di/9Vi+xWi3UIhfZ0WYsGOwWwykEAdAdQ6IyE//9Zi0YEOwW0ykEAdAdQ6HqE//9Zi0YIOwW4ykEAdAdQ6GiE//9Zi0YwOwXgykEAdAdQ6FaE//9Zi3Y0OzXkykEAdAdW6ESE//9ZXl3Di/9Vi+yD7BBTVot1CFcz/4l18Il99Dl+HHUVOX4YdRCJffyJffi7sMpBAOllAQAAalBqAehbtv//i9hZWTvfdQgzwEDpogEAAIu2vAAAAGoUWYv7agTzpejytf//M/9ZiUX4O8d1CVPo04P//1nr0Yt1CIk4OX4cD4TZAAAAagToyrX//1mJRfw7x3UaM/ZGU+iqg////3X46KKD//9ZWYvG6UQBAACJOA+3dj5Tag5WjUXwagFQ6Bbn//+L+I1DBFBqD1aNRfBqAVDoAuf//wv4jUMIUGoQVo1F8GoBUOju5v//C/iNQzBQag5WjUXwagJQ6Nrm//+DxFAL+I1DNFBqD1aNRfBqAlDow+b//4PEFAvHdA9T6Hv+//9Zg87/6Wv///+LQwjrEooIgPkwfBKA+Tl/DYDpMIgIQIA4AHXp6z6A+Tt184vwik4BiA5GgD4AdfXr5aGwykEAiQOhtMpBAIlDBKG4ykEAiUMIoeDKQQCJQzCh5MpBAIl9/IlDNItN+It1CDPAQIkBi038hcl0AokBi4a0AAAAiz10YEEAhcB0A1D/14uGsAAAAIXAdB9Q/9eFwHUY/7awAAAA6HyC////trwAAADocYL//1lZi0X8iYa0AAAAi0X4iYawAAAAiZ68AAAAM8BfXlvJw4v/VYvsVot1CIX2D4TqAAAAi0YMOwW8ykEAdAdQ6C6C//9Zi0YQOwXAykEAdAdQ6ByC//9Zi0YUOwXEykEAdAdQ6AqC//9Zi0YYOwXIykEAdAdQ6PiB//9Zi0YcOwXMykEAdAdQ6OaB//9Zi0YgOwXQykEAdAdQ6NSB//9Zi0YkOwXUykEAdAdQ6MKB//9Zi0Y4OwXoykEAdAdQ6LCB//9Zi0Y8OwXsykEAdAdQ6J6B//9Zi0ZAOwXwykEAdAdQ6IyB//9Zi0ZEOwX0ykEAdAdQ6HqB//9Zi0ZIOwX4ykEAdAdQ6GiB//9Zi3ZMOzX8ykEAdAdW6FaB//9ZXl3Di/9Vi+yD7BBTVot1CFcz/4l9/Il18Il99Dl+GHUVOX4cdRCJffyJffi7sMpBAOnQAgAAalBqAehqs///i9hZWTvfdQgzwEDpDwMAAGoE6A6z//9ZiUX4O8d1CVPo8YD//1nr4Ik4OX4YD4Q0AgAAagTo67L//1mJRfw7x3URU+jOgP///3X46MaA//9Z69KJOA+3djiNQwxQahVWjUXwagFQ6D3k//+L+I1DEFBqFFaNRfBqAVDoKeT//wv4jUMUUGoWVo1F8GoBUOgV5P//C/iNQxhQahdWjUXwagFQ6AHk//+DxFAL+I1DHFBqGFaNRfBqAVDo6uP//wv4jUMgUGpQVo1F8GoBUOjW4///C/iNQyRQalFWjUXwagFQ6MLj//8L+I1DKFBqGlaNRfBqAFDoruP//4PEUAv4jUMpUGoZVmoAjUXwUOiX4///C/iNQypQalRWjUXwagBQ6IPj//8L+I1DK1BqVVaNRfBqAFDob+P//wv4jUMsUGpWVo1F8GoAUOhb4///g8RQC/iNQy1QaldWjUXwagBQ6ETj//8L+I1DLlBqUlaNRfBqAFDoMOP//wv4jUMvUGpTVo1F8GoAUOgc4///C/iNQzhQahVWjUXwagJQ6Ajj//+DxFAL+I1DPFBqFFaNRfBqAlDo8eL//wv4jUNAUGoWVo1F8GoCUOjd4v//C/iNQ0RQahdWjUXwagJQ6Mni//8L+I1DSFBqUFaNRfBqAlDoteL//4PEUAv4jUNMUGpRVo1F8GoCUOie4v//g8QUC8d0JFPor/z//1Po+X7///91+Ojxfv///3X86Ol+//+DxBDp0/3//4tDHOsS'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'AQAAQDvHcr/rUo2GHQEAAMeF5Pr//5////8zySmF5Pr//4uV5Pr//42EDh0BAAAD0I1aIIP7GXcKgEwOHRCNUSDrDYP6GXcMgEwOHSCNUeCIEOsDxgAAQTvPcsaLTfxfM81b6Ill///Jw2oMaLikQQDo1q///+hptf//i/ihlMpBAIVHcHQdg39sAHQXi3dohfZ1CGog6Ce+//9Zi8bo7q///8NqDeivv///WYNl/ACLd2iJdeQ7NTDPQQB0NoX2dBpW/xV0YEEAhcB1D4H+CMtBAHQHVugleP//WaEwz0EAiUdoizUwz0EAiXXkVv8VcGBBAMdF/P7////oBQAAAOuOi3Xkag3odb7//1nDi/9Vi+yD7BBTM9tTjU3w6B+i//+JHcDjQQCD/v51HscFwONBAAEAAAD/FURhQQA4Xfx0RYtN+INhcP3rPIP+/XUSxwXA40EAAQAAAP8VQGFBAOvbg/78dRKLRfCLQATHBcDjQQABAAAA68Q4Xfx0B4tF+INgcP2LxlvJw4v/VYvsg+wgoZDEQQAzxYlF/FOLXQxWi3UIV+hk////i/gz9ol9CDv+dQ6Lw+i6/P//M8DpoQEAAIl15DPAObg4z0EAD4SRAAAA/0Xkg8AwPfAAAABy54H/6P0AAA+EdAEAAIH/6f0AAA+EaAEAAA+3x1D/FUhhQQCFwA+EVgEAAI1F6FBX/xW0YEEAhcAPhDcBAABoAQEAAI1DHFZQ6D/K//8z0kKDxAyJewSJcww5VegPhvwAAACAfe4AD4TTAAAAjXXvig6EyQ+ExgAAAA+2Rv8PtsnpqQAAAGgBAQAAjUMcVlDo+Mn//4tN5IPEDGvJMIl14I2xSM9BAIl15OsrikYBhMB0KQ+2Pg+2wOsSi0XgioA0z0EACEQ7HQ+2RgFHO/h26ot9CIPGAoA+AHXQi3Xk/0Xgg8YIg33gBIl15HLpi8eJewTHQwgBAAAA6Gn7//9qBolDDI1DEI2JPM9BAFpmizFmiTCDwQKDwAJKdfGL8+jX+///6bT+//+ATAMdBEA7wXb2g8YCgH7/AA+FMP///41DHrn+AAAAgAgIQEl1+YtDBOgR+///iUMMiVMI6wOJcwgzwA+3yIvBweEQC8GNexCrq6vrpzk1wONBAA+FVP7//4PI/4tN/F9eM81b6IBi///Jw2oUaNikQQDozaz//4NN4P/oXLL//4v4iX3c6Nj8//+LX2iLdQjocf3//4lFCDtDBA+EVwEAAGggAgAA6Fyn//9Zi9iF2w+ERgEAALmIAAAAi3doi/vzpYMjAFP/dQjotP3//1lZiUXghcAPhfwAAACLddz/dmj/FXRgQQCFwHURi0ZoPQjLQQB0B1Do/XT//1mJXmhTiz1wYEEA/9f2RnACD4XqAAAA9gWUykEAAQ+F3QAAAGoN6Cy8//9Zg2X8AItDBKPQ40EAi0MIo9TjQQCLQwyj2ONBADPAiUXkg/gFfRBmi0xDEGaJDEXE40EAQOvoM8CJReQ9AQEAAH0NikwYHIiIKM1BAEDr6TPAiUXkPQABAAB9EIqMGB0BAACIiDDOQQBA6+b/NTDPQQD/FXRgQQCFwHUToTDPQQA9CMtBAHQHUOhEdP//WYkdMM9BAFP/18dF/P7////oAgAAAOswag3oprr//1nD6yWD+P91IIH7CMtBAHQHU+gOdP//Wej8qv//xwAWAAAA6wSDZeAAi0Xg6IWr///Dgz2A5EEAAHUSav3oVv7//1nHBYDkQQABAAAAM8DDi/9Vi+yLTQhWV4XJdAeLfQyF/3UT6K+q//9qFl6JMOhTqv//i8brQYtVEIXSdQXGAQDr4YvxgD4AdARGT3X3hf907CvyigKIBBZChMB0A09184X/dRHGAQDoa6r//2oiWYkIi/HruDPAX15dw8zMzMxVi+xWM8BQUFBQUFBQUItVDI1JAIoCCsB0CYPCAQ+rBCTr8Yt1CIPJ/41JAIPBAYoGCsB0CYPGAQ+jBCRz7ovB'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'g2cIAIXAdFuAOAB0VosDhcB0DoA4AHQJi/fo9f7//+sHi/foU////4N/CAAPhYQAAABXakBoeIRBAOjr+f//g8QMhcB0Zosbhdt0DoA7AHQJi/fovP7//+tSi/foGv///+tJixuF23QwgDsAdCtT6BBx//+D6AP32FkbwGoBQGi990AAiUcU/xVUYUEA9kcIBHUZg2cIAOsTx0cIBAEAAP8VTGFBAIlHGIlHHIN/CAAPhOsAAACLdQiLxoPogPfeG/Yj8OjD+f//i/CJdQiF9g+EywAAAIH+6P0AAA+EvwAAAIH+6f0AAA+EswAAAA+3xlD/FUhhQQCFwA+EoQAAAGoB/3cY/xVYYUEAhcAPhI4AAACLRQyFwHQTZotPGGaJCGaLTxxmiUgCZolwBItdEIXbdGiLNVBhQQC5FAgAAGY5CHUgaFSHQQBqQFPo1KX//4PEDIXAdB0zwFBQUFBQ6DSi//9qQFNoARAAAP93GP/WhcB0LGpAjUNAUGgCEAAA/3cc/9aFwHQYagpqEIPrgFP/dQjofEoAAIPEEDPAQOsCM8BfXltdw4v/VYvsVleLfRCLx4PoAA+EtxQAAEgPhJ8UAABID4RsFAAASA+EIRQAAEgPhJkTAACLTQyLRQhTaiBa6TIEAACLMDsxdHQPtjAPthkr83QTM9uF9g+fw410G/+F9g+FKwQAAA+2cAEPtlkBK/N0EzPbhfYPn8ONdBv/hfYPhQwEAAAPtnACD7ZZAivzdBMz24X2D5/DjXQb/4X2D4XtAwAAD7ZwAw+2WQMr83QPM9uF9g+fw410G//rAjP2hfYPhcoDAACLcAQ7cQR0dg+2cAQPtlkEK/N0EzPbhfYPn8ONdBv/hfYPhaMDAAAPtnAFD7ZZBSvzdBMz24X2D5/DjXQb/4X2D4WEAwAAD7ZwBg+2WQYr83QTM9uF9g+fw410G/+F9g+FZQMAAA+2cAcPtlkHK/N0DzPbhfYPn8ONdBv/6wIz9oX2D4VCAwAAi3AIO3EIdHYPtnAID7ZZCCvzdBMz24X2D5/DjXQb/4X2D4UbAwAAD7ZwCQ+2WQkr83QTM9uF9g+fw410G/+F9g+F/AIAAA+2cAoPtlkKK/N0EzPbhfYPn8ONdBv/hfYPhd0CAAAPtnALD7ZZCyvzdA8z24X2D5/DjXQb/+sCM/aF9g+FugIAAItwDDtxDHR2D7ZwDA+2WQwr83QTM9uF9g+fw410G/+F9g+FkwIAAA+2cA0PtlkNK/N0EzPbhfYPn8ONdBv/hfYPhXQCAAAPtnAOD7ZZDivzdBMz24X2D5/DjXQb/4X2D4VVAgAAD7ZwDw+2WQ8r83QPM9uF9g+fw410G//rAjP2hfYPhTICAACLcBA7cRB0dg+2WRAPtnAQK/N0EzPbhfYPn8ONdBv/hfYPhQsCAAAPtnARD7ZZESvzdBMz24X2D5/DjXQb/4X2D4XsAQAAD7ZwEg+2WRIr83QTM9uF9g+fw410G/+F9g+FzQEAAA+2cBMPtlkTK/N0DzPbhfYPn8ONdBv/6wIz9oX2D4WqAQAAi3AUO3EUdHYPtnAUD7ZZFCvzdBMz24X2D5/DjXQb/4X2D4WDAQAAD7ZwFQ+2WRUr83QTM9uF9g+fw410G/+F9g+FZAEAAA+2cBYPtlkWK/N0EzPbhfYPn8ONdBv/hfYPhUUBAAAPtnAXD7ZZFyvzdA8z24X2D5/DjXQb/+sCM/aF9g+FIgEAAItwGDtxGHR2D7ZwGA+2WRgr83QTM9uF9g+fw410G/+F9g+F+wAAAA+2cBkPtlkZK/N0EzPbhfYPn8ONdBv/hfYPhdwAAAAPtnAaD7ZZGivzdBMz24X2D5/DjXQb/4X2D4W9AAAAD7ZwGw+2WRsr83QPM9uF9g+fw410G//rAjP2hfYPhZoAAACLcBw7cRx0ag+2cBwPtlkcK/N0DzPbhfYPn8ONdBv/hfZ1dw+2cB0PtlkdK/N0DzPbhfYPn8ONdBv/hfZ1XA+2'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'NYtFCA+3AP9NDFCLw+iW////g0UIAoM+/1l1D4M/KnUQaj+Lw+h+////WYN9DAB/0IM/AHUFi0X8iQdeycOL/1WL7IHseAQAAKGQxEEAM8WJRfxTi10UVot1CDPAV/91EIt9DI2NtPv//4m11Pv//4md5Pv//4mFrPv//4mF+Pv//4mF2Pv//4mF9Pv//4mF3Pv//4mFsPv//4mF0Pv//+i8c///6GqA//+JhZz7//+F9nUr6FuA///HABYAAADo/n///4C9wPv//wB0CouFvPv//4NgcP2DyP/p7QoAADP2O/50zw+3F4m16Pv//4m17Pv//4m1xPv//4m1qPv//4mV4Pv//2Y71g+EpAoAAGoCWQP5ib2g+///ObXo+///D4x4CgAAjULgZoP4WHcPD7fCD7aAWI9BAIPgD+sCM8CLtcT7//9rwAkPtoQweI9BAGoIwegEXomFxPv//zvGD4RP////g/gHD4cNCgAA/ySFQitBADPAg430+////4mFmPv//4mFsPv//4mF2Pv//4mF3Pv//4mF+Pv//4mF0Pv//+ngCQAAD7fCg+ggdEiD6AN0NCvGdCQrwXQUg+gDD4W2CQAACbX4+///6bcJAACDjfj7//8E6asJAACDjfj7//8B6Z8JAACBjfj7//+AAAAA6ZAJAAAJjfj7///phQkAAGaD+ip1K4sDg8MEiZ3k+///iYXY+///hcAPiWYJAACDjfj7//8E953Y+///6VQJAACLhdj7//9rwAoPt8qNRAjQiYXY+///6TkJAACDpfT7//8A6S0JAABmg/oqdSWLA4PDBImd5Pv//4mF9Pv//4XAD4kOCQAAg430+////+kCCQAAi4X0+///a8AKD7fKjUQI0ImF9Pv//+nnCAAAD7fCg/hJdFGD+Gh0QIP4bHQYg/h3D4XMCAAAgY34+///AAgAAOm9CAAAZoM/bHURA/mBjfj7//8AEAAA6aYIAACDjfj7//8Q6ZoIAACDjfj7//8g6Y4IAAAPtweD+DZ1GWaDfwI0dRKDxwSBjfj7//8AgAAA6W0IAACD+DN1GWaDfwIydRKDxwSBpfj7////f///6U8IAACD+GQPhEYIAACD+GkPhD0IAACD+G8PhDQIAACD+HUPhCsIAACD+HgPhCIIAACD+FgPhBkIAACDpcT7//8Ai4XU+///Uo216Pv//8eF0Pv//wEAAADoF/z//1np8AcAAA+3woP4ZA+PMQIAAA+EvwIAAIP4Uw+PHAEAAHR/g+hBdBArwXRaK8F0CCvBD4XhBQAAg8Igx4WY+///AQAAAImV4Pv//4uN9Pv//4ON+Pv//0CNvfz7//+4AAIAAIm98Pv//4mF7Pv//4XJD4mOAgAAx4X0+///BgAAAOneAgAA94X4+///MAgAAA+FyQAAAION+Pv//yDpvQAAAPeF+Pv//zAIAAB1B4ON+Pv//yCLvfT7//+D//91Bb////9/g8ME9oX4+///IImd5Pv//4tb/Imd8Pv//w+E+QQAAIXbdQuhMNBBAImF8Pv//4Ol7Pv//wCLtfD7//+F/w+OEQUAAIoGhMAPhAcFAACNjbT7//8PtsBRUOiv+P//WVmFwHQBRkb/hez7//85vez7//980OncBAAAg+hYD4TfAgAAK8EPhJUAAACD6AcPhPT+//8rwQ+FugQAAA+3A4PDBDP2RvaF+Pv//yCJtdD7//+JneT7//+JhaT7//90QoiFyPv//42FtPv//1CLhbT7///Ghcn7//8A/7CsAAAAjYXI+///UI2F/Pv//1Do6/b//4PEEIXAeQ+JtbD7///rB2aJhfz7//+Nhfz7//+JhfD7//+Jtez7///pNgQAAIsDg8MEiZ3k+///hcB0OotIBIXJdDP3hfj7//8ACAAAD78AiY3w+///dBKZK8LHhdD7//8BAAAA6fEDAACDpdD7//8A6ecDAAChMNBBAImF8Pv//1Dojkj//1np0AMAAIP4cA+P5QEA'
	$Installer_EFI_cli &= 'AA+EzQEAAIP4ZQ+MvgMAAIP4Zw+O5/3//4P4aXRug/hudCSD+G8PhaIDAAD2hfj7//+AibXg+///dGKBjfj7//8AAgAA61aDwwSJneT7//+LW/zo6PX//4XAD4R4+v//9oX4+///IHQMZouF6Pv//2aJA+sIi4Xo+///iQPHhbD7//8BAAAA6fcEAACDjfj7//9Ax4Xg+///CgAAAPeF+Pv//wCAAAAPhJkBAAAD3otD+ItT/OnVAQAAdRJmg/pndVfHhfT7//8BAAAA60s7yH4IiYX0+///i8iB+aMAAAB+N42xXQEAAFboZXX//4uV4Pv//1mJhaj7//+FwHQQiYXw+///ibXs+///i/jrCseF9Pv//6MAAACLA4s1jGBBAIPDCImFkPv//4tD/ImFlPv//42FtPv//1D/tZj7//8PvsL/tfT7//+JneT7//9Q/7Xs+///jYWQ+///V1D/NVDQQQD/1v/Qi534+///g8QcgeOAAAAAdB2DvfT7//8AdRSNhbT7//9QV/81XNBBAP/W/9BZWWaDveD7//9ndRiF23UUjYW0+///UFf/NVjQQQD/1v/QWVmAPy11EYGN+Pv//wABAABHib3w+///V+kZ/v//ibX0+///x4Ws+///BwAAAOskg+hzD4R7/P//K8EPhJz+//+D6AMPhc4BAADHhaz7//8nAAAA9oX4+///gMeF4Pv//xAAAAAPhHz+//9qMFhmiYXM+///i4Ws+///g8BRZomFzvv//4mN3Pv//+lX/v//94X4+///ABAAAA+FV/7//4PDBPaF+Pv//yB0HPaF+Pv//0CJneT7//90Bg+/Q/zrBA+3Q/yZ6xf2hfj7//9Ai0P8dAOZ6wIz0omd5Pv///aF+Pv//0B0G4XSfxd8BIXAcxH32IPSAPfagY34+///AAEAAPeF+Pv//wCQAACL+ovYdQIz/4O99Pv//wB9DMeF9Pv//wEAAADrGoOl+Pv///e4AAIAADmF9Pv//34GiYX0+///i8MLx3UGIYXc+///jbX7/f//i4X0+////430+///hcB/BovDC8d0LYuF4Pv//5lSUFdT6K70//+DwTCJnYz7//+L2Iv6g/k5fgYDjaz7//+IDk7rvY2F+/3//yvGRveF+Pv//wACAACJhez7//+JtfD7//90XoXAdAeLxoA4MHRT/43w+///i4Xw+////4Xs+///xgAw6zyF23ULoTTQQQCJhfD7//+LhfD7///HhdD7//8BAAAA6wlPZoM4AHQGA8GF/3XzK4Xw+///0fiJhez7//+DvbD7//8AD4WoAQAAi4X4+///qEB0K6kAAQAAdARqLesOqAF0BGor6waoAnQUaiBZZomNzPv//8eF3Pv//wEAAACLvdj7//8rvez7//8rvdz7//+JveD7//+oDHUk6x6LhdT7//9qII216Pv//0/oivX//4O96Pv///9ZdASF/3/e/7Xc+///i72c+///i53U+///jYXM+///UI2F6Pv//+iH9f//9oX4+///CFlZdC/2hfj7//8EdSaLveD7///rGmowjbXo+///i8NP6Cz1//+Dvej7////WXQEhf9/4oO90Pv//wB1a4ud7Pv//4XbfmGLvfD7//+NhbT7//9Qi4W0+////7CsAAAAjYWk+///V1BL6G7x//+DxBCJhYz7//+FwH4k/7Wk+///i4XU+///jbXo+///6MD0//8DvYz7//9Zhdt/sOsug43o+////+sl/7Xs+///i72c+////7Xw+///i53U+///jYXo+///6Lb0//9ZWYO96Pv//wB8M/aF+Pv//wR0Kou94Pv//+sei4XU+///aiCNtej7//9P6Ff0//+Dvej7////WXQEhf9/3oO9qPv//wB0E/+1qPv//+itPv//g6Wo+///AFmLvaD7//+LneT7//8Ptwcz9omF4Pv//2Y7xnQHi9DpcfX//zm1xPv//3QNg73E+///Bw+FAfX//4C9wPv/'
	$Installer_EFI_cli &= '/wB0CouFvPv//4NgcP2Lhej7//+LTfxfXjPNW+g4K///ycONSQDZIkEA2SBBAAshQQBmIUEAsiFBAL4hQQAEIkEA+yJBAIv/VYvsi0UIozDkQQBdw4v/VYvsUYM9cNFBAP51Beg6IAAAoXDRQQCD+P91B7j//wAAycNqAI1N/FFqAY1NCFFQ/xVsYEEAhcB04maLRQjJw8zMzMzMzMzMzMzMzMxRjUwkBCvIG8D30CPIi8QlAPD//zvIcgqLwVmUiwCJBCTDLQAQAACFAOvpi/9Vi+yLRQhWV4XAeFk7BYzkQQBzUYvIwfkFi/CD5h+NPI2g5EEAiw/B5gaDPA7/dTWDPVDEQQABU4tdDHUeg+gAdBBIdAhIdRNTavTrCFNq9esDU2r2/xVYYEEAiweJHAYzwFvrFughdP//xwAJAAAA6Cl0//+DIACDyP9fXl3Di/9Vi+yLTQhTM9tWVzvLfFs7DYzkQQBzU4vBwfgFi/GD5h+NPIWg5EEAiwfB5gb2RDAEAXQ2gzww/3Qwgz1QxEEAAXUdK8t0EEl0CEl1E1Nq9OsIU2r16wNTavb/FVhgQQCLB4MMBv8zwOsV6Jtz///HAAkAAADoo3P//4kYg8j/X15bXcOL/1WL7ItFCIP4/nUY6Idz//+DIADobHP//8cACQAAAIPI/13DhcB4CDsFjORBAHIa6GNz//+DIADoSHP//8cACQAAAOjrcv//69WLyMH5BYsMjaDkQQCD4B/B4Ab2RAgEAXTNiwQIXcNqDGg4pUEA6Glz//+LfQiLx8H4BYv3g+YfweYGAzSFoORBAMdF5AEAAAAz2zleCHU1agroS4P//1mJXfw5Xgh1GWigDwAAjUYMUP8V8GBBAIXAdQOJXeT/RgjHRfz+////6DAAAAA5XeR0HYvHwfgFg+cfwecGiwSFoORBAI1EOAxQ/xWAYEEAi0Xk6Cpz///DM9uLfQhqCugNgv//WcOL/1WL7ItFCIvIg+AfwfkFiwyNoORBAMHgBo1EAQxQ/xWEYEEAXcNqGGhYpUEA6KNy//+DTeT/M/+JfdxqC+jfgf//WYXAdQiDyP/pYQEAAGoL6I2C//9ZiX38iX3Yg/9AD407AQAAizS9oORBAIX2D4S5AAAAiXXgiwS9oORBAAUACAAAO/APg5YAAAD2RgQBdVuDfggAdThqCuhEgv//WTPbQ4ld/IN+CAB1G2igDwAAjUYMUP8V8GBBAIXAdQWJXdzrA/9GCINl/ADoKAAAAIN93AB1F41eDFP/FYBgQQD2RgQBdBtT/xWEYEEAg8ZA64OLfdiLdeBqCugLgf//WcODfdwAdebGRgQBgw7/KzS9oORBAMH+BovHweAFA/CJdeSDfeT/dXlH6Sz///9qQGog6KZs//9ZWYlF4IXAdGGNDL2g5EEAiQGDBYzkQQAgixGBwgAIAAA7wnMXxkAEAIMI/8ZABQqDYAgAg8BAiUXg693B5wWJfeSLx8H4BYvPg+EfweEGiwSFoORBAMZECAQBV+jI/f//WYXAdQSDTeT/x0X8/v///+gJAAAAi0Xk6GVx///DagvoTYD//1nDi/9Vi+yD7ByLVRBWi3UIav5YiUXsiVXkO/B1G+iwcP//gyAA6JVw///HAAkAAACDyP/pfQUAAFMz2zvzfAg7NYzkQQByH+iGcP//iRjobHD//8cACQAAAOgPcP//g8j/6U4FAACLxsH4BVeD5h+NPIWg5EEAiwfB5gaKTDAE9sEBdRToSXD//4kY6C9w///HAAkAAADraIH6////f3dOiV30O9MPhAYFAAD2wQIPhf0EAAA5XQx0NYpEMCQCwND4iEX+D77ASGoEWXQZSHUOi8L30KgBdBaD4v6JVRCLXQyJXfDreovC99CoAXUZ6N9v//+JGOjFb///xwAWAAAA6Ghv///rNovC0eiJTRA7wXIDiUUQ/3UQ6L1q//+L2FmJXfCF23Ue6JNv///HAAwAAADom2///8cACAAAAIPI'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'BWoA/3UU/3UQi00M6B7///9dw4v/VYvsUVaLdQxW6Opp//+JRQyLRgxZqIJ1GejdV///xwAJAAAAg04MILj//wAA6T0BAACoQHQN6MBX///HACIAAADr4agBdBeDZgQAqBAPhI0AAACLTgiD4P6JDolGDItGDINmBACDZfwAU2oCg+DvWwvDiUYMqQwBAAB1LOj/D///g8AgO/B0DOjzD///g8BAO/B1Df91DOhn0P//WYXAdQdW6Ehx//9Z90YMCAEAAFcPhIMAAACLRgiLPo1IAokOi04YK/gry4lOBIX/fh1XUP91DOhDcP//g8QMiUX8606DyCCJRgzpPf///4tNDIP5/3Qbg/n+dBaLwYPgH4vRwfoFweAGAwSVoORBAOsFuCDGQQD2QAQgdBVTagBqAFHoTnT//yPCg8QQg/j/dC2LRgiLXQhmiRjrHWoCjUX8UP91DIv7i10IZold/OjLb///g8QMiUX8OX38dAuDTgwguP//AADrB4vDJf//AABfW17Jw4v/VYvsg+wQU1aLdQwz21eLfRA783URO/t2DYtFCDvDdAKJGDPA63uLRQg7w3QDgwj/gf////9/dhPoSlb//2oWXokw6O5V//+LxutW/3UYjU3w6H5J//+LRfA5WBQPhZAAAABmi0UUuf8AAABmO8F2NjvzdA87+3YLV1NW6H9y//+DxAzo/1X//8cAKgAAAOj0Vf//iwA4Xfx0B4tN+INhcP1fXlvJwzvzdCY7+3cg6NRV//9qIl6JMOh4Vf//OF38dIWLRfiDYHD96Xn///+IBotFCDvDdAbHAAEAAAA4XfwPhDz///+LRfiDYHD96TD///+NTQxRU1dWagGNTRRRU4ldDP9wBP8VqGBBADvDdBQ5XQwPhWr///+LTQg7y3S9iQHruf8VIGBBAIP4eg+FUP///zvzD4Rz////O/sPhmv///9XU1botHH//4PEDOlb////i/9Vi+xqAP91FP91EP91DP91COiT/v//g8QUXcNqAujeY///WcOL/1WL7FG4//8AAGY5RQh1BDPAycO4AAEAAGY5RQhzEA+3RQiLDYjEQQAPtwRB6x2NRfxQagGNRQhQagH/FVxhQQCFwHUDIUX8D7dF/A+3TQwjwcnDM8BQUGoDUGoDaAAAAEBo1I9BAP8VLGBBAKNw0UEAw6Fw0UEAg/j/dAyD+P50B1D/FTRgQQDDi/9Vi+yD7BhTVlcz22oBU1P/dQiJXfCJXfToVnH//4lF6CPCg8QQiVXsg/j/dFlqAlNT/3UI6Dpx//+LyCPKg8QQg/n/dEGLdQyLfRAr8Bv6D4jGAAAAfwg78w+GvAAAALsAEAAAU2oI/xXAYEEAUP8VoGBBAIlF/IXAdRfoAVT//8cADAAAAOj2U///iwBfXlvJw2gAgAAA/3UI6BUBAABZWYlF+IX/fAp/BDvzcgSLw+sCi8ZQ/3X8/3UI6ORl//+DxAyD+P90Npkr8Bv6eAZ/04X2dc+LdfD/dfj/dQjo0QAAAFlZ/3X8agD/FcBgQQBQ/xWUYEEAM9vphgAAAOiRU///gzgFdQvodFP//8cADQAAAIPO/4l19Ou9O/t/cXwEO/Nza1P/dRD/dQz/dQjoP3D//yPCg8QQg/j/D4RE/////3UI6LHf//9ZUP8VYGBBAPfYG8D32EiZiUXwI8KJVfSD+P91KegVU///xwANAAAA6B1T//+L8P8VIGBBAIkGi3XwI3X0g/7/D4T2/v//U/917P916P91COjUb///I8KDxBCD+P8PhNn+//8zwOnZ/v//i/9Vi+xTi10MVot1CIvGwfgFjRSFoORBAIsKg+YfweYGA86KQSQCwFcPtnkED77AgeeAAAAA0fiB+wBAAAB0UIH7AIAAAHRCgfsAAAEAdCaB+wAAAgB0HoH7AAAEAHU9gEkEgIsKjUwxJIoRgOKBgMoBiBHrJ4BJBICLCo1MMSSKEYDigoDKAuvogGEEf+sNgEkEgIsKjUwx'
	$Installer_EFI_cli &= 'JIAhgIX/X15bdQe4AIAAAF3D99gbwCUAwAAABQBAAABdw4v/VYvsi0UIhcB1FegBUv//xwAWAAAA6KRR//9qFlhdw4sNTORBAIkIM8Bdw4v/VYvsuP//AACD7BRmOUUID4SHAAAAU1b/dQyNTezoDkX//4t17ItOFDPbO8t1FYtFCI1Iv2aD+Rl3BGaDwCAPt8DrS7gAAQAAagFmOUUIcx7/dQjoffz//1mFwA+3RQhZdCyLjswAAAAPtgQB6yCNVfxSagGNVQhSUFHo7QMAAIPEGIXAD7dFCHQED7dF/Dhd+HQHi030g2Fw/V5bycOL/1WL7IPsGFNW/3UMjU3o6H1E//+LXQi+AAEAADvec1SLTeiDuawAAAABfhSNRehQagFT6CDG//+LTeiDxAzrDYuByAAAAA+3BFiD4AGFwHQPi4HMAAAAD7YEGOmjAAAAgH30AHQHi0Xwg2Bw/YvD6ZwAAACLReiDuKwAAAABfjGJXQjBfQgIjUXoUItFCCX/AAAAUOj5zP//WVmFwHQSikUIagKIRfyIXf3GRf4AWesV6I5Q///HACoAAAAzyYhd/MZF/QBBi0XoagH/cASNVfhqA1JRjU38UVb/cBSNRehQ6BlG//+DxCSFwA+Eb////4P4AQ+2Rfh0CQ+2TfnB4AgLwYB99AB0B4tN8INhcP1eW8nDi/9Vi+yD7BxW/3UIjU3k6GlD//+LRRCLdQyFwHQCiTCF9nUk6AdQ///HABYAAADoqk///4B98AB0B4tF7INgcP0zwOngAQAAg30UAHQMg30UAnzQg30UJH/Kg2X8AItN5FOKHleNfgGDuawAAAABfheNReRQD7bDaghQ6MTE//+LTeSDxAzrEIuRyAAAAA+2ww+3BEKD4AiFwHQFih9H68eA+y11BoNNGALrBYD7K3UDih9Hi0UUhcAPiE8BAACD+AEPhEYBAACD+CQPjz0BAACFwHUqgPswdAnHRRQKAAAA6zaKBzx4dA08WHQJx0UUCAAAAOsjx0UUEAAAAOsKg/gQdRWA+zB1EIoHPHh0BDxYdQaKXwGDxwKDyP8z0vd1FIuxyAAAAIlV+A+2yw+3DE6L0YPiBHQID77Lg+kw6xmB4QMBAAB0MI1Ln4D5GQ++y3cDg+kgg8HJO00UcxqDTRgIOUX8cih1BTtN+HYhg00YBIN9EAB1I4tFGE+oCHUgg30QAHQDi30Mg2X8AOtbi1X8D69VFAPRiVX8ih9H64q+////f6gEdRuoAXU9g+ACdAmBffwAAACAdwmFwHUrOXX8diboZ07///ZFGAHHACIAAAB0BoNN/P/rD/ZFGAJqAFgPlcADxolF/ItFEIXAdAKJOPZFGAJ0A/dd/IB98AB0B4tF7INgcP2LRfzrGItFEIXAdAKJMIB98AB0B4tF7INgcP0zwF9bXsnDi/9Vi+wzwFD/dRD/dQz/dQg5BZTWQQB1B2iMykEA6wFQ6K/9//+DxBRdw8zMVYvsV1ZTi00QC8l0TYt1CIt9DLdBs1q2II1JAIomCuSKB3QnCsB0I4PGAYPHATrncgY643cCAuY6x3IGOsN3AgLGOuB1C4PpAXXRM8k64HQJuf////9yAvfZi8FbXl/Jw4v/VYvsi0UUhcB+C1D/dRDoTgAAAFlZ/3Uc/3UYUP91EP91DP91CP8VrGBBAF3Di0QkCItMJBALyItMJAx1CYtEJAT34cIQAFP34YvYi0QkCPdkJBQD2ItEJAj34QPTW8IQAIv/VYvsM8A5RQx2EotNCGaDOQB0CUCDwQI7RQxy8V3D/yV4YUEAzMzMzMzMV1ZTM/+LRCQUC8B9FEeLVCQQ99j32oPYAIlEJBSJVCQQi0QkHAvAfRRHi1QkGPfY99qD2ACJRCQciVQkGAvAdRiLTCQYi0QkFDPS9/GL2ItEJBD38YvT60GL2ItMJBiLVCQUi0QkENHr0dnR6tHYC9t19Pfxi/D3ZCQci8iLRCQY9+YD0XIOO1QkFHcIcgc7'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAgACAAIAAgACAAIAAgACAAKAAoACgAKAAoACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAEgAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAhACEAIQAhACEAIQAhACEAIQAhAAQABAAEAAQABAAEAAQAIEAgQCBAIEAgQCBAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAQABAAEAAQABAAEACCAIIAggCCAIIAggACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAEAAQABAAEAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAIAAgACAAIAAgACAAIAAgAGgAKAAoACgAKAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABIABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAIQAhACEAIQAhACEAIQAhACEAIQAEAAQABAAEAAQABAAEACBAYEBgQGBAYEBgQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBEAAQABAAEAAQABAAggGCAYIBggGCAYIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECARAAEAAQABAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAASAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAFAAUABAAEAAQABAAEAAUABAAEAAQABAAEAAQAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEQAAEBAQEBAQEBAQEBAQEBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBEAACAQIBAgECAQIBAgECAQIBAQEAAAAAgIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXmJmam5ydnp+goaKjpKWmp6ipqqusra6vsLGys7S1tre4ubq7vL2+v8DBwsPExcbHyMnKy8zNzs/Q0dLT1NXW19jZ2tvc3d7f4OHi4+Tl5ufo6err7O3u7/Dx8vP09fb3+Pn6+/z9/v8AAQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYnKCkqKywtLi8wMTIzNDU2Nzg5Ojs8PT4/QGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6W1xdXl9gYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXp7fH1+f4CBgoOEhYaHiImKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6Slpqeoqaqr'
	$Installer_EFI_cli &= 'rK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/gIGCg4SFhoeIiYqLjI2Oj5CRkpOUlZaXmJmam5ydnp+goaKjpKWmp6ipqqusra6vsLGys7S1tre4ubq7vL2+v8DBwsPExcbHyMnKy8zNzs/Q0dLT1NXW19jZ2tvc3d7f4OHi4+Tl5ufo6err7O3u7/Dx8vP09fb3+Pn6+/z9/v8AAQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyAhIiMkJSYnKCkqKywtLi8wMTIzNDU2Nzg5Ojs8PT4/QEFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaW1xdXl9gQUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVp7fH1+f4CBgoOEhYaHiImKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/oNZBAPjWQQBLAEUAUgBOAEUATAAzADIALgBEAEwATAAAAAAARmxzRnJlZQBGbHNTZXRWYWx1ZQBGbHNHZXRWYWx1ZQBGbHNBbGxvYwAAAABDb3JFeGl0UHJvY2VzcwAAbQBzAGMAbwByAGUAZQAuAGQAbABsAAAAcgB1AG4AdABpAG0AZQAgAGUAcgByAG8AcgAgAAAAAAANAAoAAAAAAFQATABPAFMAUwAgAGUAcgByAG8AcgANAAoAAABTAEkATgBHACAAZQByAHIAbwByAA0ACgAAAAAARABPAE0AQQBJAE4AIABlAHIAcgBvAHIADQAKAAAAAABSADYAMAAzADMADQAKAC0AIABBAHQAdABlAG0AcAB0ACAAdABvACAAdQBzAGUAIABNAFMASQBMACAAYwBvAGQAZQAgAGYAcgBvAG0AIAB0AGgAaQBzACAAYQBzAHMAZQBtAGIAbAB5ACAAZAB1AHIAaQBuAGcAIABuAGEAdABpAHYAZQAgAGMAbwBkAGUAIABpAG4AaQB0AGkAYQBsAGkAegBhAHQAaQBvAG4ACgBUAGgAaQBzACAAaQBuAGQAaQBjAGEAdABlAHMAIABhACAAYgB1AGcAIABpAG4AIAB5AG8AdQByACAAYQBwAHAAbABpAGMAYQB0AGkAbwBuAC4AIABJAHQAIABpAHMAIABtAG8AcwB0ACAAbABpAGsAZQBsAHkAIAB0AGgAZQAgAHIAZQBzAHUAbAB0ACAAbwBmACAAYwBhAGwAbABpAG4AZwAgAGEAbgAgAE0AUwBJAEwALQBjAG8AbQBwAGkAbABlAGQAIAAoAC8AYwBsAHIAKQAgAGYAdQBuAGMAdABpAG8AbgAgAGYAcgBvAG0AIABhACAAbgBhAHQAaQB2AGUAIABjAG8AbgBzAHQAcgB1AGMAdABvAHIAIABvAHIAIABmAHIAbwBtACAARABsAGwATQBhAGkAbgAuAA0ACgAAAAAAUgA2ADAAMwAyAA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAbABvAGMAYQBsAGUAIABpAG4AZgBvAHIAbQBhAHQAaQBvAG4ADQAKAAAAAABSADYAMAAzADEADQAKAC0AIABBAHQAdABlAG0AcAB0ACAAdABvACAAaQBuAGkAdABpAGEAbABpAHoAZQAgAHQAaABlACAAQwBSAFQAIABtAG8AcgBlACAAdABoAGEAbgAgAG8AbgBjAGUALgAKAFQAaABpAHMAIABpAG4AZABpAGMAYQB0AGUAcwAgAGEAIABiAHUAZwAgAGkAbgAgAHkAbwB1AHIAIABhAHAAcABsAGkAYwBhAHQA'
	$Installer_EFI_cli &= 'aQBvAG4ALgANAAoAAAAAAFIANgAwADMAMAANAAoALQAgAEMAUgBUACAAbgBvAHQAIABpAG4AaQB0AGkAYQBsAGkAegBlAGQADQAKAAAAAABSADYAMAAyADgADQAKAC0AIAB1AG4AYQBiAGwAZQAgAHQAbwAgAGkAbgBpAHQAaQBhAGwAaQB6AGUAIABoAGUAYQBwAA0ACgAAAAAAAAAAAFIANgAwADIANwANAAoALQAgAG4AbwB0ACAAZQBuAG8AdQBnAGgAIABzAHAAYQBjAGUAIABmAG8AcgAgAGwAbwB3AGkAbwAgAGkAbgBpAHQAaQBhAGwAaQB6AGEAdABpAG8AbgANAAoAAAAAAAAAAABSADYAMAAyADYADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABzAHQAZABpAG8AIABpAG4AaQB0AGkAYQBsAGkAegBhAHQAaQBvAG4ADQAKAAAAAAAAAAAAUgA2ADAAMgA1AA0ACgAtACAAcAB1AHIAZQAgAHYAaQByAHQAdQBhAGwAIABmAHUAbgBjAHQAaQBvAG4AIABjAGEAbABsAA0ACgAAAAAAAABSADYAMAAyADQADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABfAG8AbgBlAHgAaQB0AC8AYQB0AGUAeABpAHQAIAB0AGEAYgBsAGUADQAKAAAAAAAAAAAAUgA2ADAAMQA5AA0ACgAtACAAdQBuAGEAYgBsAGUAIAB0AG8AIABvAHAAZQBuACAAYwBvAG4AcwBvAGwAZQAgAGQAZQB2AGkAYwBlAA0ACgAAAAAAAAAAAFIANgAwADEAOAANAAoALQAgAHUAbgBlAHgAcABlAGMAdABlAGQAIABoAGUAYQBwACAAZQByAHIAbwByAA0ACgAAAAAAAAAAAFIANgAwADEANwANAAoALQAgAHUAbgBlAHgAcABlAGMAdABlAGQAIABtAHUAbAB0AGkAdABoAHIAZQBhAGQAIABsAG8AYwBrACAAZQByAHIAbwByAA0ACgAAAAAAAAAAAFIANgAwADEANgANAAoALQAgAG4AbwB0ACAAZQBuAG8AdQBnAGgAIABzAHAAYQBjAGUAIABmAG8AcgAgAHQAaAByAGUAYQBkACAAZABhAHQAYQANAAoAAABSADYAMAAxADAADQAKAC0AIABhAGIAbwByAHQAKAApACAAaABhAHMAIABiAGUAZQBuACAAYwBhAGwAbABlAGQADQAKAAAAAABSADYAMAAwADkADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABlAG4AdgBpAHIAbwBuAG0AZQBuAHQADQAKAAAAUgA2ADAAMAA4AA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAYQByAGcAdQBtAGUAbgB0AHMADQAKAAAAAAAAAFIANgAwADAAMgANAAoALQAgAGYAbABvAGEAdABpAG4AZwAgAHAAbwBpAG4AdAAgAHMAdQBwAHAAbwByAHQAIABuAG8AdAAgAGwAbwBhAGQAZQBkAA0ACgAAAAAAAAAAAAIAAAAgdkEACAAAAMh1QQAJAAAAcHVBAAoAAAAodUEAEAAAANB0QQARAAAAcHRBABIAAAAodEEAEwAAANBzQQAYAAAAYHNBABkAAAAQc0EAGgAAAKByQQAbAAAAMHJBABwAAADgcUEAHgAAAKBxQQAfAAAA2HBBACAAAABwcEEAIQAAAIBuQQB4AAAAYG5BAHkAAABEbkEAegAAAChuQQD8AAAAIG5BAP8AAAAAbkEATQBpAGMAcgBvAHMAbwBmAHQAIABWAGkAcwB1AGEAbAAgAEMAKwArACAAUgB1AG4AdABpAG0AZQAgAEwA'
	$Installer_EFI_cli &= 'aQBiAHIAYQByAHkAAAAAAAoACgAAAAAALgAuAC4AAAA8AHAAcgBvAGcAcgBhAG0AIABuAGEAbQBlACAAdQBuAGsAbgBvAHcAbgA+AAAAAABSAHUAbgB0AGkAbQBlACAARQByAHIAbwByACEACgAKAFAAcgBvAGcAcgBhAG0AOgAgAAAABQAAwAsAAAAAAAAAHQAAwAQAAAAAAAAAlgAAwAQAAAAAAAAAjQAAwAgAAAAAAAAAjgAAwAgAAAAAAAAAjwAAwAgAAAAAAAAAkAAAwAgAAAAAAAAAkQAAwAgAAAAAAAAAkgAAwAgAAAAAAAAAkwAAwAgAAAAAAAAAtAIAwAgAAAAAAAAAtQIAwAgAAAAAAAAAAwAAAAkAAACQAAAADAAAAElsbGVnYWwgYnl0ZSBzZXF1ZW5jZQAAAERpcmVjdG9yeSBub3QgZW1wdHkARnVuY3Rpb24gbm90IGltcGxlbWVudGVkAAAAAE5vIGxvY2tzIGF2YWlsYWJsZQAARmlsZW5hbWUgdG9vIGxvbmcAAABSZXNvdXJjZSBkZWFkbG9jayBhdm9pZGVkAAAAUmVzdWx0IHRvbyBsYXJnZQAAAABEb21haW4gZXJyb3IAAAAAQnJva2VuIHBpcGUAVG9vIG1hbnkgbGlua3MAAFJlYWQtb25seSBmaWxlIHN5c3RlbQAAAEludmFsaWQgc2VlawAAAABObyBzcGFjZSBsZWZ0IG9uIGRldmljZQBGaWxlIHRvbyBsYXJnZQAASW5hcHByb3ByaWF0ZSBJL08gY29udHJvbCBvcGVyYXRpb24AVG9vIG1hbnkgb3BlbiBmaWxlcwBUb28gbWFueSBvcGVuIGZpbGVzIGluIHN5c3RlbQAAAEludmFsaWQgYXJndW1lbnQAAAAASXMgYSBkaXJlY3RvcnkAAE5vdCBhIGRpcmVjdG9yeQBObyBzdWNoIGRldmljZQAASW1wcm9wZXIgbGluawAAAEZpbGUgZXhpc3RzAFJlc291cmNlIGRldmljZQBVbmtub3duIGVycm9yAAAAQmFkIGFkZHJlc3MAUGVybWlzc2lvbiBkZW5pZWQAAABOb3QgZW5vdWdoIHNwYWNlAAAAAFJlc291cmNlIHRlbXBvcmFyaWx5IHVuYXZhaWxhYmxlAAAAAE5vIGNoaWxkIHByb2Nlc3NlcwAAQmFkIGZpbGUgZGVzY3JpcHRvcgBFeGVjIGZvcm1hdCBlcnJvcgAAAEFyZyBsaXN0IHRvbyBsb25nAAAATm8gc3VjaCBkZXZpY2Ugb3IgYWRkcmVzcwAAAElucHV0L291dHB1dCBlcnJvcgAASW50ZXJydXB0ZWQgZnVuY3Rpb24gY2FsbAAAAE5vIHN1Y2ggcHJvY2VzcwBObyBzdWNoIGZpbGUgb3IgZGlyZWN0b3J5AAAAT3BlcmF0aW9uIG5vdCBwZXJtaXR0ZWQATm8gZXJyb3IAAAAAY2NzAFVURi04AAAAVVRGLTE2TEUAAAAAVU5JQ09ERQBjAGMAcwAAAFUAVABGAC0AOAAAAFUAVABGAC0AMQA2AEwARQAAAAAAVQBOAEkAQwBPAEQARQAAAEgASAA6AG0AbQA6AHMAcwAAAAAAZABkAGQAZAAsACAATQBNAE0ATQAgAGQAZAAsACAAeQB5AHkAeQAAAE0ATQAvAGQAZAAvAHkAeQAAAAAAUABNAAAAAABBAE0AAAAAAEQAZQBjAGUAbQBiAGUAcgAAAAAATgBvAHYAZQBtAGIAZQByAAAAAABPAGMAdABvAGIAZQByAAAAUwBlAHAAdABlAG0AYgBlAHIAAABBAHUAZwB1AHMAdAAAAAAASgB1AGwAeQAAAAAASgB1AG4AZQAAAAAAQQBwAHIAaQBsAAAATQBhAHIAYwBoAAAARgBlAGIAcgB1AGEAcgB5AAAAAABKAGEAbgB1AGEAcgB5AAAARABlAGMAAABOAG8AdgAAAE8AYwB0AAAA'
	$Installer_EFI_cli &= 'UwBlAHAAAABBAHUAZwAAAEoAdQBsAAAASgB1AG4AAABNAGEAeQAAAEEAcAByAAAATQBhAHIAAABGAGUAYgAAAEoAYQBuAAAAUwBhAHQAdQByAGQAYQB5AAAAAABGAHIAaQBkAGEAeQAAAAAAVABoAHUAcgBzAGQAYQB5AAAAAABXAGUAZABuAGUAcwBkAGEAeQAAAFQAdQBlAHMAZABhAHkAAABNAG8AbgBkAGEAeQAAAAAAUwB1AG4AZABhAHkAAAAAAFMAYQB0AAAARgByAGkAAABUAGgAdQAAAFcAZQBkAAAAVAB1AGUAAABNAG8AbgAAAFMAdQBuAAAASEg6bW06c3MAAAAAZGRkZCwgTU1NTSBkZCwgeXl5eQBNTS9kZC95eQAAAABQTQAAQU0AAERlY2VtYmVyAAAAAE5vdmVtYmVyAAAAAE9jdG9iZXIAU2VwdGVtYmVyAAAAQXVndXN0AABKdWx5AAAAAEp1bmUAAAAAQXByaWwAAABNYXJjaAAAAEZlYnJ1YXJ5AAAAAEphbnVhcnkARGVjAE5vdgBPY3QAU2VwAEF1ZwBKdWwASnVuAE1heQBBcHIATWFyAEZlYgBKYW4AU2F0dXJkYXkAAAAARnJpZGF5AABUaHVyc2RheQAAAABXZWRuZXNkYXkAAABUdWVzZGF5AE1vbmRheQAAU3VuZGF5AABTYXQARnJpAFRodQBXZWQAVHVlAE1vbgBTdW4AdW5pdGVkLXN0YXRlcwAAAHVuaXRlZC1raW5nZG9tAAB0cmluaWRhZCAmIHRvYmFnbwAAAHNvdXRoLWtvcmVhAHNvdXRoLWFmcmljYQAAAABzb3V0aCBrb3JlYQBzb3V0aCBhZnJpY2EAAAAAc2xvdmFrAABwdWVydG8tcmljbwBwci1jaGluYQAAAABwciBjaGluYQAAAABuegAAbmV3LXplYWxhbmQAaG9uZy1rb25nAAAAaG9sbGFuZABncmVhdCBicml0YWluAAAAZW5nbGFuZABjemVjaAAAAGNoaW5hAAAAYnJpdGFpbgBhbWVyaWNhAHVzYQB1cwAAdWsAAHN3aXNzAAAAc3dlZGlzaC1maW5sYW5kAHNwYW5pc2gtdmVuZXp1ZWxhAAAAc3BhbmlzaC11cnVndWF5AHNwYW5pc2gtcHVlcnRvIHJpY28Ac3BhbmlzaC1wZXJ1AAAAAHNwYW5pc2gtcGFyYWd1YXkAAAAAc3BhbmlzaC1wYW5hbWEAAHNwYW5pc2gtbmljYXJhZ3VhAAAAc3BhbmlzaC1tb2Rlcm4AAHNwYW5pc2gtbWV4aWNhbgBzcGFuaXNoLWhvbmR1cmFzAAAAAHNwYW5pc2gtZ3VhdGVtYWxhAAAAc3BhbmlzaC1lbCBzYWx2YWRvcgBzcGFuaXNoLWVjdWFkb3IAc3BhbmlzaC1kb21pbmljYW4gcmVwdWJsaWMAAHNwYW5pc2gtY29zdGEgcmljYQAAc3BhbmlzaC1jb2xvbWJpYQAAAABzcGFuaXNoLWNoaWxlAAAAc3BhbmlzaC1ib2xpdmlhAHNwYW5pc2gtYXJnZW50aW5hAAAAcG9ydHVndWVzZS1icmF6aWxpYW4AAAAAbm9yd2VnaWFuLW55bm9yc2sAAABub3J3ZWdpYW4tYm9rbWFsAAAAAG5vcndlZ2lhbgAAAGl0YWxpYW4tc3dpc3MAAABpcmlzaC1lbmdsaXNoAAAAZ2VybWFuLXN3aXNzAAAAAGdlcm1hbi1sdXhlbWJvdXJnAAAAZ2VybWFuLWxpY2h0ZW5zdGVpbgBnZXJtYW4tYXVzdHJpYW4AZnJlbmNoLXN3aXNzAAAAAGZyZW5jaC1sdXhlbWJvdXJnAAAAZnJlbmNoLWNhbmFkaWFuAGZyZW5jaC1iZWxnaWFuAABlbmdsaXNoLXVzYQBlbmdsaXNoLXVzAABlbmdsaXNoLXVrAABlbmdsaXNoLXRyaW5pZGFkIHkgdG9iYWdvAAAA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'eGl0IGRlc3RydWN0b3IgZm9yICcAAAAAYGR5bmFtaWMgaW5pdGlhbGl6ZXIgZm9yICcAAGBlaCB2ZWN0b3IgdmJhc2UgY29weSBjb25zdHJ1Y3RvciBpdGVyYXRvcicAYGVoIHZlY3RvciBjb3B5IGNvbnN0cnVjdG9yIGl0ZXJhdG9yJwAAAGBtYW5hZ2VkIHZlY3RvciBkZXN0cnVjdG9yIGl0ZXJhdG9yJwAAAABgbWFuYWdlZCB2ZWN0b3IgY29uc3RydWN0b3IgaXRlcmF0b3InAAAAYHBsYWNlbWVudCBkZWxldGVbXSBjbG9zdXJlJwAAAABgcGxhY2VtZW50IGRlbGV0ZSBjbG9zdXJlJwAAYG9tbmkgY2FsbHNpZycAACBkZWxldGVbXQAAACBuZXdbXQAAYGxvY2FsIHZmdGFibGUgY29uc3RydWN0b3IgY2xvc3VyZScAYGxvY2FsIHZmdGFibGUnAGBSVFRJAAAAYEVIAGB1ZHQgcmV0dXJuaW5nJwBgY29weSBjb25zdHJ1Y3RvciBjbG9zdXJlJwAAYGVoIHZlY3RvciB2YmFzZSBjb25zdHJ1Y3RvciBpdGVyYXRvcicAAGBlaCB2ZWN0b3IgZGVzdHJ1Y3RvciBpdGVyYXRvcicAYGVoIHZlY3RvciBjb25zdHJ1Y3RvciBpdGVyYXRvcicAAAAAYHZpcnR1YWwgZGlzcGxhY2VtZW50IG1hcCcAAGB2ZWN0b3IgdmJhc2UgY29uc3RydWN0b3IgaXRlcmF0b3InAGB2ZWN0b3IgZGVzdHJ1Y3RvciBpdGVyYXRvcicAAAAAYHZlY3RvciBjb25zdHJ1Y3RvciBpdGVyYXRvcicAAABgc2NhbGFyIGRlbGV0aW5nIGRlc3RydWN0b3InAAAAAGBkZWZhdWx0IGNvbnN0cnVjdG9yIGNsb3N1cmUnAAAAYHZlY3RvciBkZWxldGluZyBkZXN0cnVjdG9yJwAAAABgdmJhc2UgZGVzdHJ1Y3RvcicAAGBzdHJpbmcnAAAAAGBsb2NhbCBzdGF0aWMgZ3VhcmQnAAAAAGB0eXBlb2YnAAAAAGB2Y2FsbCcAYHZidGFibGUnAAAAYHZmdGFibGUnAAAAXj0AAHw9AAAmPQAAPDw9AD4+PQAlPQAALz0AAC09AAArPQAAKj0AAHx8AAAmJgAAfAAAAF4AAAB+AAAAKCkAACwAAAA+PQAAPgAAADw9AAA8AAAAJQAAAC8AAAAtPioAJgAAACsAAAAtAAAALS0AACsrAAAtPgAAb3BlcmF0b3IAAAAAW10AACE9AAA9PQAAIQAAADw8AAA+PgAAIGRlbGV0ZQAgbmV3AAAAAF9fdW5hbGlnbmVkAF9fcmVzdHJpY3QAAF9fcHRyNjQAX19lYWJpAABfX2NscmNhbGwAAABfX2Zhc3RjYWxsAABfX3RoaXNjYWxsAABfX3N0ZGNhbGwAAABfX3Bhc2NhbAAAAABfX2NkZWNsAF9fYmFzZWQoAAAAAGyNQQBkjUEAWI1BAEyNQQBAjUEANI1BACiNQQAgjUEAGI1BAAyNQQAAjUEAnmNBAPiMQQDwjEEAeGVBAOyMQQDojEEA5IxBAOCMQQDcjEEA2IxBAMyMQQDIjEEAnGNBAMSMQQDAjEEAvIxBALiMQQC0jEEAsIxBAKyMQQCojEEApIxBAKCMQQCcjEEAmIxBAJSMQQCQjEEAjIxBAIiMQQCEjEEAgIxBAHyMQQB4jEEAdIxBAHCMQQBsjEEAaIxBAGSMQQBgjEEAXIxBAFiMQQBUjEEASIxBADyMQQA0jEEAKIxBABCMQQAEjEEA8ItBANCLQQCwi0EAkItBAHCLQQBQi0EALItBABCLQQDsikEAzIpBAKSKQQCIikEAeIpBAHSKQQBsikEAXIpBADiKQQAwikEAJIpBABSKQQD4iUEA2IlBALCJQQCIiUEAYIlBADSJQQAYiUEA9IhBANCIQQCkiEEA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'AAAAAAAAAAACAAAApJpBAOSaQQCwmkEAAAAAAJzTQQAAAAAAAAAAAP////8AAAAAQAAAAMyaQQAAAAAAAAAAAAEAAADcmkEAsJpBAAAAAAAs1UEAAQAAAAAAAAD/////AAAAAEAAAACUmkEAAAAAAAAAAAAAAAAA/NFBABSbQQAAAAAAAAAAAAMAAAAkm0EAoJtBADSbQQBsm0EAAAAAANzRQQABAAAAAAAAAP////8AAAAAQAAAAFCbQQAAAAAAAAAAAAIAAABgm0EANJtBAGybQQAAAAAAvNFBAAAAAAAAAAAA/////wAAAABAAAAAiJtBAAAAAAAAAAAAAQAAAJibQQBsm0EAAAAAAPzRQQACAAAAAAAAAP////8AAAAAQAAAABSbQQAAAAAAYAAAAAAAAADI0kEA0JtBAAAAAAAAAAAABQAAAOCbQQBQnUEA+JtBAHCcQQBUnEEAOJxBAAAAAACM0kEAAwAAAAAAAAD/////AAAAAEAAAAAUnEEAAAAAAAAAAAAEAAAAJJxBAPibQQBwnEEAVJxBADicQQAAAAAAHNJBAAAAAAAIAAAAAAAAAAQAAABAAAAAAJ1BADjSQQABAAAAAAAAAAAAAAAEAAAAQAAAAMicQQBU0kEAAgAAAAAAAAAAAAAABAAAAFAAAACMnEEAAAAAAAAAAAADAAAAnJxBADSdQQCsnEEA5JxBAAAAAAA40kEAAQAAAAAAAAD/////AAAAAEAAAADInEEAAAAAAAAAAAACAAAA2JxBAKycQQDknEEAAAAAABzSQQAAAAAACAAAAP////8AAAAAQAAAAACdQQAAAAAAAAAAAAEAAAAQnUEAGJ1BAAAAAAAc0kEAAAAAAAAAAAD/////AAAAAEAAAAAAnUEAVNJBAAIAAAAAAAAA/////wAAAABAAAAAjJxBAMjSQQAEAAAAAAAAAP////8AAAAAQAAAANCbQQAAAAAAAAAAAAAAAABA00EAgJ1BAAAAAAAAAAAAAgAAAJCdQQDQnUEAnJ1BAAAAAAAE00EAAAAAAAAAAAD/////AAAAAEAAAAC4nUEAAAAAAAAAAAABAAAAyJ1BAJydQQAAAAAAQNNBAAEAAAAAAAAA/////wAAAABAAAAAgJ1BAAAAAADAcgAAynMAADChAACQ0gAAIDoBAEhUAQB2VAEAkVQBALBUAQDgVAEAEFUBAF9VAQCuVQEA01UBAPZVAQARVgEANlYBAFlWAQCGVgEAqVYBANZWAQD8VgEAH1cBAGxXAQCHVwEAqlcBAN9XAQAFWAEAAAAAAAAAAAAAAAAAAAAAAAAAAADMwEEAAAAAAP////8AAAAADAAAAFNOQAAAAAAAFTFAAAAAAACcnkEAAwAAAKyeQQBwnkEA2KVBAAAAAADswEEAAAAAAP////8AAAAADAAAAKBOQAAAAAAAFTFAAAAAAADYnkEAAwAAAOieQQBwnkEA2KVBAAAAAAAMwUEAAAAAAP////8AAAAADAAAAO1OQAD/////QFRBACIFkxkBAAAABJ9BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAP////9jVEEAAAAAAGtUQQAiBZMZAgAAADCfQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAA/v///wAAAADU////AAAAAP7///8AAAAAo1tAAAAAAAD+////AAAAANT///8AAAAA/v///wAAAAB1XUAAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAAMFeQAAAAAAA/v///wAAAADU////AAAAAP7///8AAAAAtF9AAAAAAAD+////AAAAANT///8AAAAA/v///wAAAACnZEAAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAADNmQAAAAAAA/v///wAAAADM////AAAAAP7///8AAAAAvmdAAAAAAAAAAAAAimdAAP7///8AAAAA1P///wAAAAD+////AAAAABBoQAAAAAAA'
	$Installer_EFI_cli &= '/v///wAAAADU////AAAAAP7///8AAAAAeWlAAAAAAAD+////AAAAAMz///8AAAAA/v///wprQAAea0AAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAAJp4QAAAAAAA/v///wAAAADQ////AAAAAP7///8AAAAAU3pAAAAAAAAVekAAH3pAAP7///8AAAAA2P///wAAAAD+////+3pAAAR7QABAAAAAAAAAAAAAAADue0AA/////wAAAAD/////AAAAAAAAAAAAAAAAAQAAAAEAAAAUoUEAIgWTGQIAAAAkoUEAAQAAADShQQAAAAAAAAAAAAAAAAABAAAAAAAAAP7///8AAAAAtP///wAAAAD+////AAAAACZ9QAAAAAAAlnxAAJ98QAD+////AAAAANT///8AAAAA/v///w1/QAARf0AAAAAAAP7///8AAAAA2P///wAAAAD+////pn9AAKp/QAAAAAAAt3hAAAAAAADkoUEAAgAAAPChQQDYpUEAAAAAAGDEQQAAAAAA/////wAAAAAMAAAAnYRAAAAAAAD+////AAAAANT///8AAAAA/v///wAAAABUhkAAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAAFqHQAAAAAAA/v///wAAAADM////AAAAAP7///8AAAAAnZNAAAAAAAAAAAAAWpNAAAAAAAAAAAAAbJNAAAAAAAD+////AAAAAND///8AAAAA/v///wAAAAA5o0AAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAACekQAAAAAAA/v///wAAAADY////AAAAAP7///8AAAAA16VAAP7///8AAAAA5qVAAP7///8AAAAA2P///wAAAAD+////AAAAAJmnQAD+////AAAAAKWnQAD+////AAAAAND///8AAAAA/v///wAAAABwrEAAAAAAAP7///8AAAAAwP///wAAAAD+////AAAAAOeuQAAAAAAA/v///wAAAADU////AAAAAP7///8AAAAA1bBAAAAAAAD+////AAAAAND///8AAAAA/v///wAAAABhukAAAAAAAP7///8AAAAAzP///wAAAAD+////AAAAAM++QAAAAAAA/v///wAAAADQ////AAAAAP7///8AAAAAhsJAAAAAAAD+////AAAAAND///8AAAAA/v///wAAAACPw0AAAAAAAP7///8AAAAA0P///wAAAAD+////AAAAACbFQAAAAAAA/v///wAAAADY////AAAAAP7////xzkAA9c5AAAAAAAD+////AAAAANj///8AAAAA/v///0HPQABFz0AAAAAAAP7///8AAAAA0P///wAAAAD+////AAAAAOnRQAAAAAAA/v///wAAAADQ////AAAAAP7///8AAAAASddAAAAAAAD+////AAAAANT///8AAAAA/v///wAAAAC/7kAAAAAAAP7///8AAAAA1P///wAAAAD+////AAAAAIbxQAAAAAAA/v///wAAAADM////AAAAAP7///8AAAAAWPVAAAAAAAD+////AAAAAMD///8AAAAA/v///wAAAAA2GUEAAAAAAP7///8AAAAA2P///wAAAAD+////2x5BAO4eQQAAAAAA/v///wAAAADU////AAAAAP7///8AAAAA7C1BAAAAAAD+////AAAAAMj///8AAAAA/v///wAAAACxL0EAAAAAAAAAAADtLkEA/v///wAAAADQ////AAAAAP7///8AAAAAXDZBAAAAAAD+////AAAAAMz///8AAAAA/v///wAAAAD9QkEAAAAAAHzTQQAAAAAA/////wAAAAAMAAAAYzFAAAAAAACc00EAAAAAAP////8AAAAADAAAANBXQAACAAAAvKVBANilQQAAAAAAFTFAAAAAAAD0pUEAAAAAALjTQQAAAAAA/////wAAAAAUAAAA+jBAAAAAAADc00EAAAAAAP////8AAAAAFAAAADkxQAAEAAAA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'AQAAAASuAQAAAAAAAAAAACyuAQB0YQEAoKwBAAAAAAAAAAAAoq8BABBgAQD8rQEAAAAAAAAAAAC8rwEAbGEBAJCsAQAAAAAAAAAAAAywAQAAYAEAAAAAAAAAAAAAAAAAAAAAAAAAAADcrwEAyK8BAPSvAQAAAAAAUq4BAGKuAQB0rgEAhK4BAJSuAQCkrgEAxq4BAOiuAQD2rgEACK8BAD6uAQAorwEANq8BAEavAQBarwEAZq8BAHqvAQCOrwEAzrQBADauAQDetAEAFq8BAL6xAQC+tAEAJrABAD6wAQBWsAEAcrABAIqwAQCisAEAurABAMqwAQDasAEA9LABAACxAQASsQEAKLEBADSxAQBGsQEAXLEBAGyxAQCCsQEAjrEBAKKxAQDutAEA3LEBAPCxAQD8sQEACrIBABiyAQAisgEANrIBAEayAQBcsgEAbrIBAICyAQCQsgEAuLIBAMayAQDYsgEA5rIBAPKyAQACswEAFLMBADCzAQBCswEATrMBAGKzAQBwswEAhrMBAKCzAQC6swEA1LMBAOSzAQD6swEADLQBABi0AQAitAEALrQBAEC0AQBWtAEAaLQBAH60AQCOtAEAoLQBAK60AQAAAAAAsK8BAAAAAAAQrgEAGrABAAAAAACpAU50UXVlcnlTeXN0ZW1JbmZvcm1hdGlvbgAAbnRkbGwuZGxsALIEU2xlZXAAgQBDcmVhdGVEaXJlY3RvcnlXAABOAUZpbmRSZXNvdXJjZVcAsQRTaXplb2ZSZXNvdXJjZQAAQQNMb2FkUmVzb3VyY2UAAFQDTG9ja1Jlc291cmNlAAACAkdldExhc3RFcnJvcgAAbQRTZXRGaXJtd2FyZUVudmlyb25tZW50VmFyaWFibGVXAPcBR2V0RmlybXdhcmVFbnZpcm9ubWVudFZhcmlhYmxlVwCPAENyZWF0ZUZpbGVXAN0ARGV2aWNlSW9Db250cm9sAFIAQ2xvc2VIYW5kbGUAOQFGaW5kRmlyc3RGaWxlVwAA1gBEZWxldGVGaWxlVwBFAUZpbmROZXh0RmlsZVcAAwRSZW1vdmVEaXJlY3RvcnlXAAAuAUZpbmRDbG9zZQDAAUdldEN1cnJlbnRQcm9jZXNzAAkCR2V0TG9naWNhbERyaXZlcwAAzQBEZWZpbmVEb3NEZXZpY2VXAABLRVJORUwzMi5kbGwAADMDd3NwcmludGZXAFVTRVIzMi5kbGwAAPcBT3BlblByb2Nlc3NUb2tlbgAAlwFMb29rdXBQcml2aWxlZ2VWYWx1ZVcAHwBBZGp1c3RUb2tlblByaXZpbGVnZXMAQURWQVBJMzIuZGxsAADTBFJ0bFVud2luZADvAkludGVybG9ja2VkSW5jcmVtZW50AADrAkludGVybG9ja2VkRGVjcmVtZW50AADiAkluaXRpYWxpemVDcml0aWNhbFNlY3Rpb24A0QBEZWxldGVDcml0aWNhbFNlY3Rpb24A7gBFbnRlckNyaXRpY2FsU2VjdGlvbgAAOQNMZWF2ZUNyaXRpY2FsU2VjdGlvbgAA6gBFbmNvZGVQb2ludGVyAMoARGVjb2RlUG9pbnRlcgB5AkdldFN5c3RlbVRpbWVBc0ZpbGVUaW1lAM8CSGVhcEZyZWUAAIcBR2V0Q29tbWFuZExpbmVXANMCSGVhcFNldEluZm9ybWF0aW9uAADLAkhlYXBBbGxvYwCxA1JhaXNlRXhjZXB0aW9uAAARBVdpZGVDaGFyVG9NdWx0aUJ5dGUALQNMQ01hcFN0cmluZ1cAAGcDTXVsdGlCeXRlVG9XaWRlQ2hhcgByAUdldENQSW5mbwDABFRlcm1pbmF0ZVByb2Nlc3MAANMEVW5oYW5kbGVkRXhjZXB0aW9uRmlsdGVyAAClBFNldFVuaGFuZGxlZEV4Y2VwdGlvbkZpbHRlcgAAA0lzRGVidWdnZXJQcmVzZW50AMUEVGxzQWxsb2MAAMcEVGxzR2V0'
	$Installer_EFI_cli &= 'VmFsdWUAyARUbHNTZXRWYWx1ZQDGBFRsc0ZyZWUAGAJHZXRNb2R1bGVIYW5kbGVXAABzBFNldExhc3RFcnJvcgAAxQFHZXRDdXJyZW50VGhyZWFkSWQAAEUCR2V0UHJvY0FkZHJlc3MAAG8EU2V0SGFuZGxlQ291bnQAAGQCR2V0U3RkSGFuZGxlAADjAkluaXRpYWxpemVDcml0aWNhbFNlY3Rpb25BbmRTcGluQ291bnQA8wFHZXRGaWxlVHlwZQBjAkdldFN0YXJ0dXBJbmZvVwAZAUV4aXRQcm9jZXNzACUFV3JpdGVGaWxlAJoBR2V0Q29uc29sZUNQAACsAUdldENvbnNvbGVNb2RlAAAEA0lzUHJvY2Vzc29yRmVhdHVyZVByZXNlbnQAZgRTZXRGaWxlUG9pbnRlcgAAwANSZWFkRmlsZQAAVwFGbHVzaEZpbGVCdWZmZXJzAADNAkhlYXBDcmVhdGUAABQCR2V0TW9kdWxlRmlsZU5hbWVXAABhAUZyZWVFbnZpcm9ubWVudFN0cmluZ3NXANoBR2V0RW52aXJvbm1lbnRTdHJpbmdzVwAApwNRdWVyeVBlcmZvcm1hbmNlQ291bnRlcgCTAkdldFRpY2tDb3VudAAAwQFHZXRDdXJyZW50UHJvY2Vzc0lkAAYCR2V0TG9jYWxlSW5mb1cAANQCSGVhcFNpemUAAGgBR2V0QUNQAAA3AkdldE9FTUNQAAAKA0lzVmFsaWRDb2RlUGFnZQCbAkdldFVzZXJEZWZhdWx0TENJRAAABAJHZXRMb2NhbGVJbmZvQQAADQFFbnVtU3lzdGVtTG9jYWxlc0EAAAwDSXNWYWxpZExvY2FsZQBpAkdldFN0cmluZ1R5cGVXAADSAkhlYXBSZUFsbG9jAD8DTG9hZExpYnJhcnlXAAAkBVdyaXRlQ29uc29sZVcAhwRTZXRTdGRIYW5kbGUAAFMEU2V0RW5kT2ZGaWxlAABKAkdldFByb2Nlc3NIZWFwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAANxjQQAAAAAALj9BVmVycm9yX2NhdGVnb3J5QHN0ZEBAAAAAANxjQQAAAAAALj9BVl9HZW5lcmljX2Vycm9yX2NhdGVnb3J5QHN0ZEBAAAAA3GNBAAAAAAAuP0FWX0lvc3RyZWFtX2Vycm9yX2NhdGVnb3J5QHN0ZEBAAADcY0EAAAAAAC4/QVZfU3lzdGVtX2Vycm9yX2NhdGVnb3J5QHN0ZEBAAAAAABBiQQAEYkEARGJBADRiQQBoYkEABGJBAFxiQQD/////3GNBAAAAAAAuP0FWbG9naWNfZXJyb3JAc3RkQEAAAADcY0EAAAAAAC4/QVZsZW5ndGhfZXJyb3JAc3RkQEAAANxjQQAAAAAALj9BVm91dF9vZl9yYW5nZUBzdGRAQAAA3GNBAAAAAAAuP0FWX0xvY2ltcEBsb2NhbGVAc3RkQEAAAAAACgAAAAAAAABDb3B5cmlnaHQgKGMpIDE5OTItMjAwNCBieSBQLkouIFBsYXVnZXIsIGxpY2Vuc2VkIGJ5IERpbmt1bXdhcmUsIEx0ZC4gQUxMIFJJR0hUUyBSRVNFUlZFRC4AANxjQQAAAAAALj9BVnR5cGVfaW5mb0BAAAAAAADA5UEAAAAAAMDlQQABAQAA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'c3RkQEAAAADcY0EAAAAAAC4/QVZydW50aW1lX2Vycm9yQHN0ZEBAANxjQQAAAAAALj9BVmV4Y2VwdGlvbkBzdGRAQADcY0EAAAAAAC4/QVZmYWlsdXJlQGlvc19iYXNlQHN0ZEBAAADcY0EAAAAAAC4/QVZzeXN0ZW1fZXJyb3JAc3RkQEAAAAAAAAB7ADgAQgBFADQARABGADYAMQAtADkAMwBDAEEALQAxADEAZAAyAC0AQQBBADAARAAtADAAMABFADAAOQA4ADAAMwAyAEIAOABDAH0AAAAAAChzKsEf+NIRuksAoMk+yTt7ADgAQgBFADQARABGADYAMQAtADkAMwBDAEEALQAxADEAZAAyAC0AQQBBADAARAAtADAAMABFADAAOQA4ADAAMwAyAEIAOABDAH0AAAAAAChzKsEf+NIRuksAoMk+yTt7ADgAQgBFADQARABGADYAMQAtADkAMwBDAEEALQAxADEAZAAyAC0AQQBBADAARAAtADAAMABFADAAOQA4ADAAMwAyAEIAOABDAH0AAAAAANxjQQAAAAAALj9BVmJhZF9jYXN0QHN0ZEBAAADcY0EAAAAAAC4/QVZiYWRfYWxsb2NAc3RkQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAEAAQDQAACAIAAAgBgAAABAAACAAAAAAAAAAAAEAAAAAAACAGUAAABYAACAZgAAAHAAAIAAAAAAAAAAAAQAAAAAAAEAAQAAAIgAAIAAAAAAAAAAAAQAAAAAAAEACQQAAKAAAAAAAAAAAAAAAAQAAAAAAAEACQQAALAAAAAAAAAAAAAAAAQAAAAAAAEACQQAAMAAAADYAAIAwDkAAOQEAAAAAAAAmDoCAHYBAADkBAAAAAAAABA8AgAwAgAA5AQAAAAAAAADAFIAQQBXAE1aAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAUEUAAGSGBQAAAAAAAAAAAAAAAADwACIgCwIKACAkAAAgEwAAAAAAANAfAACAAgAAAAAAgAEAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAAAADAOQAAgAIAAAAAAAAKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABgOQAARAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALnRleHQAAAAZJAAAgAIAACAkAACAAgAAAAAAAAAAAAAAAAAAIAAAYC5yZGF0YQAAFAsAAKAmAAAgCwAAoCYAAAAAAAAAAAAAAAAAAEAAAEAuZGF0YQAAADgFAADAMQAAQAUAAMAxAAAAAAAAAAAAAAAAAABAAADAAAAAAAAAAABMAgAAADcAAGACAAAANwAAAAAAAAAAAAAAAAAAQAAAQC5yZWxvYwAARAAAAGA5AABgAAAAYDkAAAAAAAAAAAAA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'YQBiAGwAZQANAAoAAAAAAAAAAABFAFIAUgBPAFIAOgAgAGEAbABsAG8AYwBhAHQAZQAgAG0AZQBtAG8AcgB5ADoAIAAlAHIADQAKAAAAAAAAAAAARQBSAFIATwBSADoAIABTAHQAYQByAHQASQBtAGEAZwBlACAAcwB0AGEAdAB1AHMAIAAlAHIADQAKAAAAAAAAAEUAUgBSAE8AUgA6ACAATABvAGEAZAAgAEkAbQBhAGcAZQA6ACAAJQByAA0ACgAAAFcAQQBSAE4ASQBOAEcAOgAgAEMAbABvAHMAZQAgAFIAbwBvAHQAOgAgACUAcgANAAoAAAAAAAAAVwBBAFIATgBJAE4ARwA6ACAAQwBsAG8AcwBlACAARgBpAGwAZQA6ACAAJQByAA0ACgAAAAAAAABFAFIAUgBPAFIAOgAgAFIAZQBhAGQAIABGAGkAbABlADoAIAAlAHIADQAKAAAAAABFAFIAUgBPAFIAOgAgAEEAbABsAG8AYwBhAHQAZQAgAE0AZQBtAG8AcgB5ADoAIAAlAHIADQAKAAAAAAAAAAAARQBSAFIATwBSADoAIABGAGkAbABlACAAUwBpAHoAZQA6ACAAJQByAA0ACgAAAAAARQBSAFIATwBSADoAIABPAHAAZQBuACAARgBpAGwAZQA6ACAAJQBzACAAJQByAA0ACgAAAAAAAAAAAAAAAAAAAFwARQBGAEkAXABNAGkAYwByAG8AcwBvAGYAdABcAEIATwBPAFQAXABCAE8ATwBUAE0ARwBGAFcALgBFAEYASQAAAAAAAAAAAEUAUgBSAE8AUgA6ACAATwBwAGUAbgAgAFYAbwBsAHUAbQBlADoAIAAlAHMAIAAlAHIADQAKAAAARQBSAFIATwBSADoAIABGAGkAbABlACAAUwB5AHMAdABlAG0AIABQAHIAbwB0AG8AYwBvAGwAOgAgACUAcgANAAoAAAAAAAAAAAAAAAAAAABFAFIAUgBPAFIAOgAgAEwAbwBhAGQAZQBkACAASQBtAGEAZwBlACAAUAByAG8AdABvAGMAbwBsADoAIAAlAHIADQAKAAAAAAAAAAAAAAAAAFAAcgBlAHMAcwAgAEUAUwBDACAAawBlAHkAIAB0AG8AIABiAG8AbwB0ACAAVwBpAG4AZABvAHcAcwAgAHcAaQB0AGgAbwB1AHQAIABXAGkAbgBkAFMATABJAEMADQAKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwBAAArgQAAGQvAAAAAAAAAAAAADAEAACuBAAAZC8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAcAAIwHAACkLwAAAAAAAAAAAACABwAAjAcAAKQvAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADQDAAA+gwAABgwAAAAAAAAAAAAANAMAAD6DAAAGDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAPAAB/DwAAtDAAAAAAAAB/DwAAwg8AAKAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB/DwAAwg8AAKAwAAAAAAAAAAAAAEAPAAB/DwAAtDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPAaAACqGwAALDEAAAAAAAAAAAAAAAAAAPAaAACqGwAALDEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAiAADqIgAAZDEAAAAAAAAAAAAA'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwAABEAAAA6KH4oQiiGKIoojiiSKJYomiieKKIopiiqKK4osii2KLooviiCKMYoyijOKNIo1ijaKN4o4ijmKOoowAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFNMSUN2AQAAAT5BQ1JTWVNBQ1JQUkRDVAEAAABBTk5JAQAAAAAAAACcAAAABgIAAAAkAABSU0ExAAQAAAEAAQCzbYNgjYNlbuZLp284BDHB4kW/NGYfF5F/XBUStwFNV22OrmvkzPig4bt5/whT43fn1HBeXO9vgd0bXzDimZu50JNGq9gXeuDwp0wy1JGGuqFsojxzz4YtlZoGUPP3fgZbXidmAToxnwyxkZZJXMyBuncyUrIQXVvK3p0lkJX3lwEAAAC2AAAAAAACAEFDUlNZU0FDUlBSRENUV0lORE9XUyABAAIAAAAAAAAAAAAAAAAAAAAAAEmQrDQ7mIhSYiz7JaipoH0tEnDu1Zp8zwyDtCkbVTuIpffmKaks5xddeu44TSfgqWl8/CBKaAtdg63l1m5JwWYo5NTOcmShfL6TrWQy2sxyJEf+tJeHAVWgXS/vBpPoh4RZ05slUyfnynVlzw5AyTuqA/KDfifnykekSx/Fd9+MUEE8YXNzZW1ibHkgeG1sbnM9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206YXNtLnYxIiBtYW5pZmVzdFZlcnNpb249IjEuMCI+PHRydXN0SW5mbyB4bWxucz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTphc20udjMiPjxzZWN1cml0eT48cmVxdWVzdGVkUHJpdmlsZWdlcz48cmVxdWVzdGVkRXhlY3V0aW9uTGV2ZWwgbGV2ZWw9InJlcXVpcmVBZG1pbmlzdHJhdG9yIiB1aUFjY2Vzcz0iZmFsc2UiPjwvcmVxdWVzdGVkRXhlY3V0aW9uTGV2ZWw+PC9yZXF1ZXN0ZWRQcml2aWxlZ2VzPjwvc2VjdXJpdHk+PC90cnVzdEluZm8+PGNvbXBhdGliaWxpdHkgeG1sbnM9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206Y29tcGF0aWJpbGl0eS52MSI+PGFwcGxpY2F0aW9uPjxzdXBwb3J0ZWRPUyBJZD0ie2UyMDExNDU3LTE1NDYtNDNjNS1hNWZlLTAwOGRlZWUzZDNmMH0iPjwvc3VwcG9ydGVkT1M+PHN1cHBvcnRlZE9TIElkPSJ7MzUxMzhi'
	$Installer_EFI_cli &= 'OWEtNWQ5Ni00ZmJkLThlMmQtYTI0NDAyMjVmOTNhfSI+PC9zdXBwb3J0ZWRPUz48L2FwcGxpY2F0aW9uPjwvY29tcGF0aWJpbGl0eT48L2Fzc2VtYmx5PlBBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkdQQURESU5HWFhQQURESU5HUEFERElOR1hYUEFERElOR1BBRERJTkdYWFBBRERJTkcAEAAAiAAAAAYwSzBYMKQwtjDfMPowrDG7McAx2DHeMewxAzIaMlQyZTKZMrAywzLOMtUy4TL3MhgzLjNaM0E0FjYtNjQ2azZ6Nn820zbiNuc2/jYXNx43PDdCN8Q3VDh1OJY4pThoOcE50znaOeo5FjoiOmI6dDqQOk47ZjuAO407nTvxOzE+ACAAAGgAAAA1MD0w6DDwMMYxWDLVMh0zMjOGNNE04DX5Nf41NDZBNlU2fDbNNhw3ITeIN6c3iDjMONY44TgXOY855TkgOjk6Pjp2OoM6lzobOyY7NDurOyE8ijxFP00/az9zP84/9D8AMAAA7AAAACgwLzBXMF8whjCOMAoxSzFzMasxxDHJMeAx8DFXMngyhTKeMrEy8zL4MgMzCTMmMzUz2jPgM+kzBTRNNHk0hTShNNo0ETU0Nbc1vjU4NmY2eDbdNuY2BjdRN5Q36jf9Nwc4IzhJOFg4YjhvOJg43Tg5OUY5TTliOZc5nDn2Ofs5ATpUOl06YjpyOqc6rDoCOwc7DTs6O0w7pjurO8A7yjsJPA48FDxUPFs8bDx8PIY8sTy7PHc9gT2HPY09mD2iPf89BD4TPiI+YT5mPmw+pD6rPrw+yT7TPv4+CD9XP2E/yj8AAABAAACcAAAADjAZMB4wKjBjMGgwFjEoMcQxzjHZMVEyWzJmMrEyvTLEMt0yIjNLM1czXjN3M8YzLDRgNIo0mjWkNa81cje3N8831jfkN/03BTgTOFM4YTh7OKg4zzjWOCE5cjnROSI60DoIO5o79DtTPb49xj3QPeA97D3yPfw9DD4qPkc+ZT6LPpY+sj7YPuM+/z45P4I/jj8AAABQAAC8AAAAJTA2MG4weTCKMJYwnjCkMLMwvDAcMTwxTTHvMRcyQzJRMmkyeTKfMs0y1zLtMiUzMjM8M0Ez4jXyNQI2EjYfNjE2NzY9NkQ2TTZUNlo2YTZtNnc2qDbBNjU3gjeeN7M34TcHOBc4ozj+OAQ5HjktOTo5RjlWOV05bDl4OYU5qTm7Ock53jnoOQ46QTpQOlk6fTqsOrU6GjshO0M7SjsIPZs9uD3dPWU+zj4zPzo/XD9jP+o/AGAAAOwAAAAcMDQwOzBDMEgwTDBQMHkwnzC9MMQwyDDMMNAw1DDYMNww4DAqMTAxNDE4MTwxojGtMcgxzzHUMdgx3DH9MScyWTJgMmQyaDJsMnAydDJ4MnwyxjLMMtAy1DLYMjU0SjX2NfA2EzceN0E3kDfKN0s4UThWOF44bjh4OH44kjgTOZY5nDmuOcU5'
	$Installer_EFI_cli &= '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'
	$Installer_EFI_cli &= 'yjfQN9g3HzgkOF44YzhqOG84djh7OIk46jjzOPk4ejmiOcU53zkAOiI6azq0OmU7aztxO4E7jDswPJ48WD5dPm8+jT6hPqc+rj8AAAAgAQBsAAAAmTCxMNUw3jMiNV02oDbMNu421zhCO0Y7SjtOO1I7VjtaO147azt5O4Y7pTv7Ow48HzxEPH88kjyqPMo8HT1FPV49ej2nPdQ93z0NPhs+JD5kPnY+sj7XPuQ+DD8+P0Y/hD/6PwAwAQCAAAAAKzCwMWYycDIkMzMzqjO3M4w0ljQ2NXQ1pjXONSo3TTdYN143bjdzN4Q3jDeSN5w3ojesN7I3vDfFN9A31TfeN+g38zcuOEg4Yji/OMY4zDjwOAY5oDkMOnE6fTr1Og87GDvbPFs9xj3ZPfg9Cj4dPi8+bz6PPgAAAEABAEgAAABkMYYxvzHmMQYyEDInMkwybzIcMzw0DjZNN4U5jDn5Ohc7kDuoO8471DvZO9878DtgPGc84zzqPEU9cj3APYk+AFABAHAAAACGMo0yKjOGM1o0iDSjNM80/DQiNXE1wDXlNQg2IzZINnU2mDbFNug2DjcxN343mTe8N/E3JDguODo4RjhSOFw4aDh0OIA4ijiWOKM4pziuOLI4uTi9OMM4zTjXOOE46zj2OPo4/zgAAABgAQDgAAAAhDGIMYwxkDGUMZgxnDGgMawxsDG0MbgxvDHIMcwx6DHsMfAx9DH4MfwxADIMMhAyFDIYMhwyIDIkMigyLDIwMkAyRDJIMkwyUDJUMlgyZDJoMmwycDJ0MngyfDKYMpwyoDKkMqgyrDKwMrQyuDK8MsAyxDLIMswy0DLUMtgy3DLgMuQy6DLsMvAy9DL4MvwylDOYM6AzpDOsM7AztDPMM9Az1DPYM9wzQDRENEg0TDSgNKg0rDSwNLQ0uDS8NMA0xDTINMw00DTUNNg03DTgNOQ0iD2MPQAAAHABADQAAACENow2lDacNqQ2rDa0Nrw2xDbMNtQ23DbkNuw29Db8NgQ3DDcUNxw3JDcsNwCAAQB8AQAAeDSANIg0kDSYNKA0qDSwNLg0wDTINNA02DTgNOg08DT4NAA1CDUQNRg1IDUoNTA1ODVANUg1UDVYNWA1aDVwNXg1gDWINZA1mDWgNag1sDW4NcA1yDXQNdg14DXoNfA1+DUANgg2EDYYNiA2KDYwNjg2QDZINlA2WDZgNmg2cDZ4NoA2iDaQNpg2oDaoNrA2uDbANsg20DbYNuA26DbwNvg2ADcINxA3GDcgNyg3MDd4PXw9gD2EPYg9jD2QPZQ9mD2cPaA9pD2oPaw9sD20Pbg9vD3APcQ9yD3MPdA91D3YPdw94D3kPeg97D3wPfQ9+D38PQA+BD4IPgw+ED4UPhg+HD4gPiQ+KD4sPjA+ND44Pjw+QD5EPkg+TD5QPlQ+WD5cPmA+ZD5oPmw+cD50Png+fD6APoQ+iD6MPpA+lD6YPpw+oD6kPqg+rD6wPrQ+uD68PsA+xD7IPsw+0D7UPtg+3D7gPuQ+6D7sPvA+9D74PgAAAJABAFwCAAAgMiQyKDIsMjAyNDI4MjwyQDJEMkgyTDJQMlQyWDJcMmAyZDJwMnQyeDJ8MoAyhDKIMowykDIwMzQzODM8M0AzRDNIM0wzUDNUM1gzXDNgM2QzaDNsM3AzdDN4M3wzgDOEM4gzjDOQM5QzmDOcM6AzpDOoM6wzsDO0M7gzvDPAM8QzPDVANVQ1WDVoNWw1dDWMNZw1oDWwNbQ1uDXANdg16DXsNfw1ADYENgw2JDY0Njg2SDZMNlA2VDZcNnQ2hDaINpg2nDagNqg2wDbQNtQ25DboNuw28Db4NhA3IDckNzQ3ODc8N0A3SDdgN3A3dDeEN4g3jDeUN6w3vDfAN9A31DfkN+g37Df0Nww4HDggODA4NDg8OFQ4ZDhoOHg4fDiAOIg4oDiwOLQ4xDjIOMw40DjUONw49DgEOQg5GDkcOSA5JDksOUQ5VDlYOWg5bDlwOXQ5'
	$Installer_EFI_cli &= 'fDmUOaQ5qDmsObQ5zDncOeA58Dn0OQQ6CDoMOhQ6LDo8OkA6UDpUOmQ6aDp4Onw6jDqQOqA6pDqoOrA6yDrYOtw65Dr8Ogw7EDsgOyQ7KDssOzQ7TDtcO2A7ZDtsO4Q7lDuYO6A7uDvIO8w73DvgO+Q76DvsO/A7+DsQPCA8JDwoPCw8MDw4PFA8VDxsPHA8iDyYPJw8oDykPKw8xDzUPNg83DzkPPw8DD0QPRg9MD00PUw9UD1oPXg9fD2MPZA9lD2cPbQ9xD3IPdA96D10Pog+kD6YPqA+pD6oPrA+xD7MPtQ+3D7gPuQ+7D4APwg/FD80Pzw/SD+AP6A/wD/gPwCgAQBgAQAAADAgMEAwTDBoMIgwpDCoMMgw6DDwMPQwDDEQMSAxRDFQMVgxiDGQMZQxrDGwMcwx0DHYMeAx6DHsMfQxCDIoMkgyaDJ0MoAyoDLAMuAy7DIIMxQzMDNQM3AzkDOwM9Az8DMQNCw0MDRMNFA0cDSQNLA00DTwNBA1LDUwNVA1cDV8NZg1uDXANdQ13DXwNfg1/DUENgw2FDYoNjA2RDZMNlA2VDZYNmA2aDZwNoQ2jDaQNpg2oDaoNrw2xDbINtA22DbwNvg2DDcYNyA3SDdQN2Q3cDd4N6A3qDe8N8g30DfoN/A3+DcAOAg4FDg0ODw4RDhMOFQ4YDiAOIw4rDi4OAA5EDkkOTg5RDlMOWQ5cDmQOZw5vDnIOeg59DkUOiA6QDpMOmw6eDqYOqg6sDq8OvQ6CDsUOxw7NDtAO2A7aDuAO5A7pDuwO7g70DvoO/A7BDwQPBg8AAAAwAEAfAEAAAQwKDBUMIAwrDCwMLQwuDC8MMAwxDDMMOwwDDEsMbQx0DHYMWA0gDSENIg0gDeEN4g3jDeQN5Q3mDecN6A3pDeoN6w3sDe0N7g3vDfAN8Q3yDfMN9A31DfYN9w34DfkN+g37DfwN/Q3+Df8NwA4BDgIOAw4EDgUOBg4HDggOCQ4KDgsOEg4TDhQOFQ4WDhcOGA4ZDhoOGw4cDh0OHg4fDiAOIQ4iDiMOJA4lDiYOJw4oDikOKg4rDiwOLQ4uDi8OMA4xDjIOMw40DjUONg43DjgOOQ46DjsOPA4ADkEOQg5DDkQORQ5GDkcOSA5JDkoOSw5MDk0OTg5PDlAOUQ5SDlMOVA5VDlYOVw5YDlkOWg5bDlwOXQ5eDl8OYA5hDmIOYw5kDmUOZg5nDmgOaQ5qDkIOhg6KDo4Okg6bDp4Onw6gDqEOog6jDqQOrA6tDq4Orw6wDrEOsg6zDrQOtQ64DrkOug67DrwOvQ6+Dr8OgA7MD8AAADQAQBEAAAAMDA0MDgwPDBAMEQwSDBMMFAwVDBYMFwwgDGcMbwx3DH8MRwyODJUMowyyDIEM0AzfDOcM7gz3DMQNSw1AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
	$Installer_EFI_cli &= 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
	$Installer_EFI_cli &= 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=='
	Local $bString = Binary(_WinAPI_Base64Decode($Installer_EFI_cli))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\Installer_EFI_cli.exe", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_Installer_EFI_cli


Func _AcerLicFile($bSaveBinary = True, $sSavePath = @TempDir)
	Local $AcerLicFile
	$AcerLicFile &= 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48cjpsaWNlbnNlIHhtbG5zOnI9InVybjptcGVnOm1wZWcyMToyMDAzOjAxLVJFTC1SLU5TIiBsaWNlbnNlSWQ9InszOTFjMzJlMy1lNTk5LTRhN2EtYmFiOS1jM2NlOTBhYzA0NjN9IiB4bWxuczpzeD0idXJuOm1wZWc6bXBlZzIxOjIwMDM6MDEtUkVMLVNYLU5TIiB4bWxuczpteD0idXJuOm1wZWc6bXBlZzIxOjIwMDM6MDEtUkVMLU1YLU5TIiB4bWxuczpzbD0iaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL0RSTS9Yck1MMi9TTC92MiIgeG1sbnM6dG09Imh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9EUk0vWHJNTDIvVE0vdjIiPjxyOnRpdGxlPk9FTSBDZXJ0aWZpY2F0ZTwvcjp0aXRsZT48cjpncmFudD48c2w6YmluZGluZz48c2w6ZGF0YSBBbGdvcml0aG09Im1zZnQ6cm0vYWxnb3JpdGhtL2Jpb3MvNC4wIj5rZ0FBQUFBQUFnQkJRMUpUV1ZNQkFBRUFzMjJEWUkyRFpXN21TNmR2T0FReHdlSkZ2elJtSHhlUmYxd1ZFcmNCVFZkdGpxNXI1TXo0b09HN2VmOElVK04zNTlSd1hsenZiNEhkRzE4dzRwbWJ1ZENUUnF2WUYzcmc4S2RNTXRTUmhycWhiS0k4YzgrR0xaV2FCbER6OTM0R1cxNG5aZ0U2TVo4TXNaR1dTVnpNZ2JwM01sS3lFRjFieXQ2ZEpaQ1Y5NWM9PC9zbDpkYXRhPjwvc2w6YmluZGluZz48cjpwb3NzZXNzUHJvcGVydHkvPjxzeDpwcm9wZXJ0eVVyaSBkZWZpbml0aW9uPSJ0cnVzdGVkT2VtIi8+PC9yOmdyYW50PjxyOmlzc3Vlcj48U2lnbmF0dXJlIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjIj48U2lnbmVkSW5mbz48Q2Fub25pY2FsaXphdGlvbk1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS94cm1sL2x3YzE0biIvPjxTaWduYXR1cmVNZXRob2QgQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjcnNhLXNoYTEiLz48UmVmZXJlbmNlPjxUcmFuc2Zvcm1zPjxUcmFuc2Zvcm0gQWxnb3JpdGhtPSJ1cm46bXBlZzptcGVnMjE6MjAwMzowMS1SRUwtUi1OUzpsaWNlbnNlVHJhbnNmb3JtIi8+PFRyYW5zZm9ybSBBbGdvcml0aG09Imh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS94cm1sL2x3YzE0biIvPjwvVHJhbnNmb3Jtcz48RGlnZXN0TWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMC8wOS94bWxkc2lnI3NoYTEiLz48RGlnZXN0VmFsdWU+UmZkSjYvT1dkN1Z0SDRKN1NIcC9zL082cFVzPTwvRGlnZXN0VmFsdWU+PC9SZWZlcmVuY2U+PC9TaWduZWRJbmZvPjxTaWduYXR1cmVWYWx1ZT5QQ1ZRV3kyL2JSWTBiTENrcXJJRW5TaHNjWlkrZExnbjdaczBRelpxUGlpNTJpWElsenE5cjFqU2dLMzNrUjI1eUNKRWg0WlFsRXY0OUZMV3VJZnd3Z3BBdlA4WE1Rei8yNGZZUkNsTjBTV2g4ZktaWitHOCt5aENOZEJ4RGpzRVFPR3kyNC95elZIT3BGa3ZiVlUzM09OSldTcXFIZFR3OThuUE1LbFA1Y2ZzUGRQUmgwYXFwbi9PV21oQ2I4OXdsR1JOVW1ia3VhczFQcC8wcng1UDZY'
	$AcerLicFile &= 'NmgvbXFPZEZzRFc4RWtJTWI4cDRzL3VNZW81eHNYM1RWUDZQMVJoQU9RUUpJSlFIU3FnS2xzMXNIdm5jY3BFZlk2Qm9McHlDdWZDajV3S3VyY1JpblpCQWtRSWlFRGM0Z08rcnpYcnhOVlBLWXBNa0V4N0hQUGpXYTVtTGMydkE9PTwvU2lnbmF0dXJlVmFsdWU+PEtleUluZm8+PEtleVZhbHVlPjxSU0FLZXlWYWx1ZT48TW9kdWx1cz5zb3Rabit3OWp1S1BmN2JNTzlyTkZyaUIrMTB2L3Q5Ym8vWFdHK3J6b0Ridy91RjRJTlo1ckdSSWl0aUlUWS9iSTRyQU5rdjRaNWhHLzhWeEdNYnF2cWNhWEpxblJGZGE3WEFqZ20xejl3a2dYMVIvZDJ0WExVVVVRUDBKMVh1U2JnelI4OVQvbHBuYzVxMkNkdnk3R3YycFp2QXpTZUxPcG9uWGM4SjN6T0ZyMElVWEJHcHJYS25lbVZrMWlKQkZueVFHbFdHM1VvU3BkbEYwaWNoQlF3UHgvUGdvVGJjWnNBN0dnNjJCR3dQeC91REEzWmd3b3dyUGxSd2ZMVkFPNnFFOXhQSnFSWmRSRmZQSGJkUWpwMVlBcTI3d2M2Y1R6NXNQU1RCMXBKNEw5TUQrTnB2SGoyT01aVjUrTEorYnhaYlRxaFBjcnpDcDdja2t5RDdIenc9PTwvTW9kdWx1cz48RXhwb25lbnQ+QVFBQjwvRXhwb25lbnQ+PC9SU0FLZXlWYWx1ZT48L0tleVZhbHVlPjwvS2V5SW5mbz48L1NpZ25hdHVyZT48cjpkZXRhaWxzPjxyOnRpbWVPZklzc3VlPjIwMDktMDItMTFUMjI6NTU6MTlaPC9yOnRpbWVPZklzc3VlPjwvcjpkZXRhaWxzPjwvcjppc3N1ZXI+PHI6b3RoZXJJbmZvIHhtbG5zOnI9InVybjptcGVnOm1wZWcyMToyMDAzOjAxLVJFTC1SLU5TIj48dG06aW5mb1RhYmxlcyB4bWxuczp0bT0iaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL0RSTS9Yck1MMi9UTS92MiI+PHRtOmluZm9MaXN0IHRhZz0iI2dsb2JhbCI+PHRtOmluZm9TdHIgbmFtZT0iYXBwbGljYXRpb25JZCI+ezU1YzkyNzM0LWQ2ODItNGQ3MS05ODNlLWQ2ZWMzZjE2MDU5Zn08L3RtOmluZm9TdHI+PHRtOmluZm9TdHIgbmFtZT0ibGljZW5zZUNhdGVnb3J5Ij5tc2Z0OnNsL1BQRDwvdG06aW5mb1N0cj48dG06aW5mb1N0ciBuYW1lPSJsaWNlbnNlVHlwZSI+bXNmdDpzbC9PRU1DRVJUPC90bTppbmZvU3RyPjx0bTppbmZvU3RyIG5hbWU9ImxpY2Vuc2VWZXJzaW9uIj4yLjA8L3RtOmluZm9TdHI+PHRtOmluZm9TdHIgbmFtZT0ibGljZW5zb3JVcmwiPmh0dHA6Ly9saWNlbnNpbmcubWljcm9zb2Z0LmNvbTwvdG06aW5mb1N0cj48L3RtOmluZm9MaXN0PjwvdG06aW5mb1RhYmxlcz48L3I6b3RoZXJJbmZvPjwvcjpsaWNlbnNlPg=='
	Local $bString = Binary(_WinAPI_Base64Decode($AcerLicFile))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\ACER.XRM-MS", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_AcerLicFile

Func KMS10()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	FileInstall('.\file\KMS10.exe', @TempDir & '\', 1)
	RunWait(@TempDir & '\KMS10.exe')
	FileDelete(@TempDir & '\KMS10.exe')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>KMS10

#cs
	SSD优化
#ce


;关闭SSD的节能功能
Func _IsProcessorFeaturePresent($iFeature)
	#cs
		_IsProcessorFeaturePresent(7) ; PF_3DNOW_INSTRUCTIONS_AVAILABLE
		_IsProcessorFeaturePresent(6) ; PF_XMMI_INSTRUCTIONS_AVAILABLE (SSE)
		_IsProcessorFeaturePresent(10) ; PF_XMMI64_INSTRUCTIONS_AVAILABLE (SSE2)
	#ce
	; http://msdn.microsoft.com/en-us/library/ms724482%28v=VS.85%29.aspx
	$iRes = DllCall("Kernel32.dll", "int", "IsProcessorFeaturePresent", "DWORD", $iFeature)
	Return $iRes[0]
EndFunc   ;==>_IsProcessorFeaturePresent

Func _CPUType()
	Local $s_CPU_Detected = "Unknown CPU"
	If _IsProcessorFeaturePresent(7) Then
		$s_CPU_Detected = "AMD"
	ElseIf _IsProcessorFeaturePresent(10) Then
		$s_CPU_Detected = "Intel"
	ElseIf _IsProcessorFeaturePresent(6) Then
		$s_CPU_Detected = "Intel"
	EndIf
	Return $s_CPU_Detected
EndFunc   ;==>_CPUType

Func TurnOffSSD_SE()
	Local $CpuType = _CPUType()
	If StringInStr($CpuType, 'intel') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port0', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port1', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port2', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port3', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port4', 'DIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'LPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'LPMDSTATE', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\iaStor\Parameters\Port5', 'DIPM', 'REG_DWORD', '00000000')
	EndIf
	If StringInStr($CpuType, 'amd') Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableALPEDisableHotplug', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableCCC', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CCCTimeoutValue', 'REG_DWORD', '0000000a')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CCCCompletionValue', 'REG_DWORD', '00000020')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'NCQEnableDiskIDBits', 'REG_DWORD', '00000001')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableHIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableDIPM', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'EnableHDDParking', 'REG_DWORD', '00000000')
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\amdsbs\Settings\CAM', 'CAMTimeOutValue', 'REG_DWORD', '00000005')
	EndIf
EndFunc   ;==>TurnOffSSD_SE
;关闭预读取
Func TurnOffPrefetch()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableSuperfetch', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnablePrefetcher', 'REG_DWORD', '00000000')
EndFunc   ;==>TurnOffPrefetch
;关闭启动跟踪
Func TurnOffBoottrace()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000000')
EndFunc   ;==>TurnOffBoottrace
Func TurnOnBoottrace()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters', 'EnableBootTrace', 'REG_DWORD', '00000001')
	MsgBox(0, '提示', '已经开启启动跟踪功能！', 5)
EndFunc   ;==>TurnOnBoottrace
Func TurnOffJournal()
	RunWait('fsutil usn deletejournal /n ' & @HomeDrive, @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffJournal
Func TurnOffcheckdiskOnBoot()
	;启动时不整理磁盘
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'N')
EndFunc   ;==>TurnOffcheckdiskOnBoot
Func TurnOncheckdiskOnBoot()
	;启动时整理磁盘
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction', 'Enable', 'REG_SZ', 'Y')
	MsgBox(0, '提示', '已经设置系统启动时整理磁盘！', 5)
EndFunc   ;==>TurnOncheckdiskOnBoot
Func removefeedbacktool()
	;去除feedbacktool
	RegWrite('HKEY_CURRENT_USER\Control Panel\Desktop', 'FeedbackToolEnabled', 'REG_DWORD', '00000000')
EndFunc   ;==>removefeedbacktool
Func turnOffsysRestore()
	;关闭系统还原功能
	RunWait(@ComSpec & ' /c net stop WindowsBackup ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WindowsBackup start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>turnOffsysRestore
Func turnOnsysRestore()
	;开启系统还原功能
	RunWait(@ComSpec & ' /c net start WindowsBackup ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WindowsBackup start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启系统还原功能！', 5)
EndFunc   ;==>turnOnsysRestore
Func TurnOffSysHy()
	;关闭休眠功能
	RunWait(@ComSpec & ' /c powercfg -h off', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffSysHy
Func TurnOnSysHy()
	;开启休眠功能
	RunWait(@ComSpec & ' /c powercfg -h on', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启系统休眠功能！', 5)
EndFunc   ;==>TurnOnSysHy
Func TurnOffLastAccess()
	;关闭最后时间访问
	RunWait('fsutil behavior set disablelastaccess 1', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffLastAccess
Func TurnOnLastAccess()
	;开启最后时间访问
	RunWait('fsutil behavior set disablelastaccess 0', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启文件最后访问时间！', 5)
EndFunc   ;==>TurnOnLastAccess
Func TurnOffDos83()
	RunWait('fsutil behavior set disable8dot3 1', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffDos83
Func TurnOnDos83()
	RunWait('fsutil behavior set disable8dot3 0', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启DOS 8.3文件名支持！', 5)
EndFunc   ;==>TurnOnDos83
Func TurnOffWinsearch()
	RunWait(@ComSpec & ' /c net stop WSearch ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WSearch start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffWinsearch
Func TurnOnWinsearch()
	RunWait(@ComSpec & ' /c net start WSearch ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config WSearch start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经开启WindowsSearch服务！', 5)
EndFunc   ;==>TurnOnWinsearch
;关机时不清除页面文件
Func NotClearPFileOnOff()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'clearPageFilesAtShutdown', 'REG_DWORD', '0')
EndFunc   ;==>NotClearPFileOnOff
Func ClearPFileOnOff()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management', 'clearPageFilesAtShutdown', 'REG_DWORD', '1')
	MsgBox(0, '提示', '已经设置关机时清空页面文件！', 5)
EndFunc   ;==>ClearPFileOnOff
Func DisGUIBoot()
	RunWait(@ComSpec & ' /c bcdedit /set {current} quietboot Yes', @WindowsDir, @SW_HIDE)
EndFunc   ;==>DisGUIBoot
Func EnGUIBoot()
	RunWait(@ComSpec & ' /c bcdedit /deletevalue {current} quietboot', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经还原系统设置为GUI引导方式！', 5)
EndFunc   ;==>EnGUIBoot
;关闭磁盘整理服务
Func TurnOffdefrag()
	RunWait(@ComSpec & ' /c net stop defragsvc ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config defragsvc start= disabled', @WindowsDir, @SW_HIDE)
EndFunc   ;==>TurnOffdefrag
Func TurnOndefrag()
	RunWait(@ComSpec & ' /c net start defragsvc ', @WindowsDir, @SW_HIDE)
	RunWait(@ComSpec & ' /c sc config defragsvc start= Auto', @WindowsDir, @SW_HIDE)
	MsgBox(0, '提示', '已经设置磁盘整理服务为自动启动！', 5)
EndFunc   ;==>TurnOndefrag
Func SSDTweaksApply()
	If $HasSSD Then
		Local $SeletedCount = 0
		For $i = 1 To 14
			If GUICtrlRead($SSDbox[$i]) = $GUI_CHECKED Then
				$SeletedCount += 1
			EndIf
		Next
		If $SeletedCount > 0 Then
			Local $percent = 100 / $SeletedCount
			_GUIDisable($Form1, 1, 45, 0x51D0F7)
			_DisableTrayMenu()
			GUISetState(@SW_SHOW, $LoadingUI)
			Local $i = 0
			If GUICtrlRead($SSDbox[1]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭SSD节能功能..'
				$percent += $percent
				TurnOffSSD_SE()
			EndIf
			If GUICtrlRead($SSDbox[2]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭预读取..'
				$percent += $percent
				TurnOffPrefetch()
			EndIf
			If GUICtrlRead($SSDbox[3]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭SSD启动跟踪功能..'
				$percent += $percent
				TurnOffBoottrace()
			EndIf
			If GUICtrlRead($SSDbox[4]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭NTFS Journal功能..'
				$percent += $percent
				TurnOffJournal()
			EndIf
			If GUICtrlRead($SSDbox[5]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置启动时不整理磁盘..'
				$percent += $percent
				TurnOffcheckdiskOnBoot()
			EndIf
			If GUICtrlRead($SSDbox[6]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在移除Feedbacktool..'
				$percent += $percent
				removefeedbacktool()
			EndIf
			If GUICtrlRead($SSDbox[7]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭系统还原功能..'
				$percent += $percent
				turnOffsysRestore()
			EndIf
			If GUICtrlRead($SSDbox[8]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭系统休眠功能..'
				$percent += $percent
				TurnOffSysHy()
			EndIf
			If GUICtrlRead($SSDbox[9]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭文件最后访问时间功能..'
				$percent += $percent
				TurnOffLastAccess()
			EndIf
			If GUICtrlRead($SSDbox[10]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在移除系统DOS8.3文件格式支持功能..'
				$percent += $percent
				TurnOffDos83()
			EndIf
			If GUICtrlRead($SSDbox[11]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭Windows Search功能..'
				$percent += $percent
				TurnOffWinsearch()
			EndIf
			If GUICtrlRead($SSDbox[12]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置关机时不清空页面文件..'
				$percent += $percent
				NotClearPFileOnOff()
			EndIf
			If GUICtrlRead($SSDbox[13]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在设置当前系统无GUI引导..'
				$percent += $percent
				DisGUIBoot()
			EndIf
			If GUICtrlRead($SSDbox[14]) = $GUI_CHECKED Then
				$i += 1
				$aText = '[' & Round($i / $SeletedCount, 1) * 100 & '%] 正在关闭磁盘碎片整理功能..'
				$percent += $percent
				TurnOffdefrag()
			EndIf
			GUISetState(@SW_HIDE, $LoadingUI)
			_GUIDisable($Form1, 0)
			_EnableTrayMenu()
			$aText = '正在处理，请稍后'
			_ForceUpdate()
			MsgBox(0, '提示', '已经将' & $i & '个优化项成功应用于当前系统！', 6)
		Else
			MsgBox(16, '错误', '未选择优化项目！', 5)
		EndIf
	EndIf
EndFunc   ;==>SSDTweaksApply
;调出IESEC界面
Func IESEC()
	Run('rundll32.exe iesetup.dll,IEShowHardeningDialog', @WindowsDir & '\system32\')
EndFunc   ;==>IESEC


;========================================================================================
; Ip设置什么的
;========================================================================================
;Dlg
Func IpSetDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $ShareandIp = _GUICreate("IP地址设置", 370, 219, 120, 50, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("网络设置", 8, 0, 353, 209)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("IP地址：", 24, 24, 50, 17)
	GUICtrlCreateLabel("子网掩码：", 24, 48, 64, 17)
	GUICtrlCreateLabel("默认网关：", 24, 72, 64, 17)
	Global $zDNs = GUICtrlCreateLabel("主DNS：", 24, 128, 72, 17)
	Global $IPAddress = _GUICtrlIpAddress_Create($ShareandIp, 96, 24, 130, 21)
	Global $zmym = _GUICtrlIpAddress_Create($ShareandIp, 96, 48, 130, 21)
	Global $GateWay = _GUICtrlIpAddress_Create($ShareandIp, 96, 72, 130, 21)
	Global $FirstDns = _GUICtrlIpAddress_Create($ShareandIp, 96, 128, 130, 21)
	_GUICtrlIpAddress_Set($FirstDns, "0.0.0.0")
	Global $BakDns = _GUICtrlIpAddress_Create($ShareandIp, 96, 152, 130, 21)
	_GUICtrlIpAddress_Set($BakDns, "0.0.0.0")
	Global $DNS = GUICtrlCreateCombo("", 96, 96, 129, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetOnEvent(-1, 'LoadDNS')
	Global $DIDNS = _GUICtrlCreateCheckbox("自定DNS", 16, 169, 81, 17)
	GUICtrlSetOnEvent(-1, '_DIUseSpecifyDNS')
	$IpSetDlg[1] = _GUICtrlCreateRadio("使用DHCP", 16, 184, 81, 17)
	GUICtrlSetTip($IpSetDlg[1], "勾选此选项将使计算机使用DHCP" & @LF & "来自动获取IP地址以及DNS地址", '说明', 1)
	GUICtrlSetOnEvent($IpSetDlg[1], '_ToogleIPControl')
	$IpSetDlg[2] = _GUICtrlCreateRadio("设置静态IP", 104, 184, 97, 17)
	GUICtrlSetTip($IpSetDlg[2], "勾选此选项将设置计" & @LF & "算机为静态IP地址！", '说明', 1)
	GUICtrlSetOnEvent($IpSetDlg[2], '_ToogleIPControl')
	GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
	GUICtrlCreateGroup("DNS线路", 242, 25, 85, 60)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$IpSetDlg[3] = _GUICtrlCreateRadio("电信线路", 248, 40, 73, 17)
	GUICtrlSetState($IpSetDlg[3], $GUI_CHECKED)
	GUICtrlSetOnEvent($IpSetDlg[3], 'ChooseLine')
	$IpSetDlg[4] = _GUICtrlCreateRadio("网通线路", 248, 64, 73, 17)
	GUICtrlSetOnEvent($IpSetDlg[4], 'ChooseLine')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateLabel("设置DNS", 40, 96, 51, 17)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $fDNs = GUICtrlCreateLabel("辅DNS：", 24, 152, 72, 17)
	Global $NetApt = GUICtrlCreateCombo("", 232, 143, 121, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetTip(-1, "请选择正在使用的网络！" & @LF & "否则可能不生效！", '提示', 2)
	GUICtrlSetData(-1, $AdapterList[1][5])
	GUICtrlSetOnEvent(-1, '_LoadSpecifecInterfaceInfo')
	GUICtrlCreateLabel("请选择目标网络名称", 235, 128, 112, 15)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("IP地址方案", 240, 88, 89, 38)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $IpProjName = GUICtrlCreateLabel("无方案", 248, 104, 68, 17)
	GUICtrlSetColor(-1, 0x3399FF)
	GUICtrlSetTip(-1, "请点击此处以新建、编辑或" & @LF & "删除IP切换方案！", '提示', 1)
	GUICtrlSetOnEvent(-1, '_ManageIPPrjUI')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("设置", 230, 168, 67, 33)
	GUICtrlSetOnEvent(-1, 'SetIPS')
	GUICtrlCreateButton("关闭", 305, 168, 50, 33)
	GUICtrlSetOnEvent(-1, 'QuitIpSetTool')
	PrepDNS()
	LoadDNS()
	_loadNetInterface()
	_LoadSpecifecInterfaceInfo()
	_GUICtrlIpAddress_Disable($IPAddress, 0xf)
	_GUICtrlIpAddress_Disable($zmym, 0xf)
	_GUICtrlIpAddress_Disable($GateWay, 0xf)
	_GUICtrlIpAddress_Disable($FirstDns, 0xf)
	_GUICtrlIpAddress_Disable($BakDns, 0xf)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitIpSetTool')
EndFunc   ;==>IpSetDlg
Func _ToogleIPControl()
	If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
		;dhcp
		_GUICtrlIpAddress_Disable($IPAddress, 0xf)
		_GUICtrlIpAddress_Disable($zmym, 0xf)
		_GUICtrlIpAddress_Disable($GateWay, 0xf)
		_GUICtrlIpAddress_Disable($FirstDns, 0xf)
		_GUICtrlIpAddress_Disable($BakDns, 0xf)
		GUICtrlSetState($DNS, $GUI_DISABLE)
		GUICtrlSetState($DIDNS, $GUI_UNCHECKED)
		GUICtrlSetState($DIDNS, $GUI_ENABLE)
	Else
		_GUICtrlIpAddress_Disable($IPAddress)
		_GUICtrlIpAddress_Disable($zmym)
		_GUICtrlIpAddress_Disable($GateWay)
		_GUICtrlIpAddress_Disable($FirstDns)
		_GUICtrlIpAddress_Disable($BakDns)
		GUICtrlSetState($DNS, $GUI_ENABLE)
		GUICtrlSetState($DIDNS, $GUI_CHECKED)
		GUICtrlSetState($DIDNS, $GUI_DISABLE)
		;static
	EndIf
EndFunc   ;==>_ToogleIPControl
Func _DIUseSpecifyDNS()
	;设置DHCP 勾选进行切换
	;设置静态IP 无任何操作，切自动勾选DNS
	If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
		If GUICtrlRead($DIDNS) = $GUI_CHECKED Then
			_GUICtrlIpAddress_Disable($FirstDns)
			_GUICtrlIpAddress_Disable($BakDns)
			GUICtrlSetState($DNS, $GUI_ENABLE)
		Else
			_GUICtrlIpAddress_Disable($FirstDns, 0xf)
			_GUICtrlIpAddress_Disable($BakDns, 0xf)
			GUICtrlSetState($DNS, $GUI_DISABLE)
		EndIf
	EndIf
EndFunc   ;==>_DIUseSpecifyDNS
Func QuitIpSetTool()
	_WinAPI_AnimateWindow($ShareandIp, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($ShareandIp)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitIpSetTool
Func _ManageIPPrjUI()
	GUISetState(@SW_HIDE, $ShareandIp)
	Global $GManageIP = _GUICreate("IP地址方案维护", 248, 326, 180, 10, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择IP地址方案", 8, 8, 225, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $LName = GUICtrlCreateCombo("", 16, 24, 145, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetOnEvent(-1, '_LoadIpSet')
	GUICtrlCreateButton("+", 168, 24, 27, 25)
	GUICtrlSetTip(-1, '点击此按钮来新增一个IP地址方案', '提示', 1)
	GUICtrlSetOnEvent(-1, '_AddIpSet')
	GUICtrlCreateButton("-", 196, 24, 27, 25)
	GUICtrlSetTip(-1, '点击此按钮来删除一个IP地址方案', '提示', 1)
	GUICtrlSetOnEvent(-1, '_DelIPSet')
	GUICtrlCreateGroup("方案详情", 8, 64, 225, 225)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("方案名称", 16, 88, 52, 17)
	Global $GProjName = GUICtrlCreateInput("", 88, 88, 129, 21)
	GUICtrlCreateLabel("IP地址", 16, 120, 38, 17)
	Global $GIPAdress = _GUICtrlIpAddress_Create($GManageIP, 88, 120, 130, 21)
	_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
	GUICtrlCreateLabel("子网掩码", 16, 152, 52, 17)
	Global $GSubMask = _GUICtrlIpAddress_Create($GManageIP, 88, 152, 130, 21)
	_GUICtrlIpAddress_Set($GSubMask, "0.0.0.0")
	GUICtrlCreateLabel("默认网关", 16, 184, 52, 17)
	Global $GDefaultGateway = _GUICtrlIpAddress_Create($GManageIP, 88, 184, 130, 21)
	_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
	GUICtrlCreateLabel("首选DNS", 16, 216, 51, 17)
	Global $GDNS1 = _GUICtrlIpAddress_Create($GManageIP, 88, 216, 130, 21)
	_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
	GUICtrlCreateLabel("备用DNS", 16, 248, 51, 17)
	Global $GDNS2 = _GUICtrlIpAddress_Create($GManageIP, 88, 248, 130, 21)
	_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
	GUICtrlCreateButton("保存方案", 8, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_SaveIPSet')
	GUICtrlCreateButton("选定方案", 83, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_SelectIPSet')
	GUICtrlCreateButton("取消", 156, 296, 70, 25)
	GUICtrlSetOnEvent(-1, '_QuitManageIPUI')
	GUISetState(@SW_SHOW)
	_InitIpSetData()
	_loadIpsetNameToCombo()
	_LoadIpSet()
	_CleanZeroSizeFile()
	If $IPdataNotInit = True Then MsgBox(0, '提示', '未能正确加载IP设置方案，请检查' & @LF & 'IPSetData.ini文件内容！', 5)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitManageIPUI')
EndFunc   ;==>_ManageIPPrjUI
Func _QuitManageIPUI()
	GUISetState(@SW_SHOW, $ShareandIp)
	_WinAPI_AnimateWindow($GManageIP, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($GManageIP)
EndFunc   ;==>_QuitManageIPUI
Func _CleanZeroSizeFile()
	If FileExists($iniFile) And FileGetSize($iniFile) = 0 Then
		FileDelete($iniFile)
	EndIf
EndFunc   ;==>_CleanZeroSizeFile
Func _InitIpSetData()
	$IpSetStr = ''
	;0-方案名称;1-IP地址;2-子网掩码;3-默认网关;4-主DNS;5-辅DNS;6-序列
	$aSectionNames = IniReadSectionNames($iniFile)
	If Not @error Then
		Global $aIpSetData[$aSectionNames[0]][7]
		For $i = 0 To $aSectionNames[0] - 1
			$aIpSetData[$i][0] = $aSectionNames[$i + 1]
			$IpSetStr &= $aSectionNames[$i + 1] & '|'
			;IP地址
			$aIpSetData[$i][1] = IniRead($iniFile, $aSectionNames[$i + 1], 'IP', '0.0.0.0')
			;SubMask
			$aIpSetData[$i][2] = IniRead($iniFile, $aSectionNames[$i + 1], 'SubMask', '0.0.0.0')
			;DefaultGateWay
			$aIpSetData[$i][3] = IniRead($iniFile, $aSectionNames[$i + 1], 'DefaultGateWay', '0.0.0.0')
			;DNS1
			$aIpSetData[$i][4] = IniRead($iniFile, $aSectionNames[$i + 1], 'DNS1', '0.0.0.0')
			;DNS2
			$aIpSetData[$i][5] = IniRead($iniFile, $aSectionNames[$i + 1], 'DNS2', '0.0.0.0')
			;序列
			$aIpSetData[$i][6] = $i
		Next
		$IPdataNotInit = False
	Else
		$IPdataNotInit = True
	EndIf
EndFunc   ;==>_InitIpSetData
;加载所有方案到选框
Func _loadIpsetNameToCombo()
	If $IpSetStr <> '' Then
		Local $z = ''
		If StringInStr($IpSetStr, '|') Then
			Local $aTemp = StringSplit($IpSetStr, '|')
			If IsArray($aTemp) And Not @error Then
				$z = $aTemp[1]
			EndIf
			GUICtrlSetData($LName, $IpSetStr, $z)
		Else
			GUICtrlSetData($LName, $IpSetStr)
		EndIf
	EndIf
EndFunc   ;==>_loadIpsetNameToCombo
;加载指定的方案到界面显示
Func _LoadIpSet()
	If $IPdataNotInit = False Then
		Local $Index
		For $i = 0 To UBound($aIpSetData) - 1
			If GUICtrlRead($LName) = $aIpSetData[$i][0] Then
				$Index = $i
				ExitLoop
			EndIf
		Next
		GUICtrlSetData($GProjName, $aIpSetData[$Index][0])
		_GUICtrlIpAddress_Set($GIPAdress, $aIpSetData[$Index][1])
		_GUICtrlIpAddress_Set($GSubMask, $aIpSetData[$Index][2])
		_GUICtrlIpAddress_Set($GDefaultGateway, $aIpSetData[$Index][3])
		_GUICtrlIpAddress_Set($GDNS1, $aIpSetData[$Index][4])
		_GUICtrlIpAddress_Set($GDNS2, $aIpSetData[$Index][5])
	EndIf
EndFunc   ;==>_LoadIpSet
;新建IP设置方案
Func _AddIpSet()
	GUICtrlSetData($GProjName, '新建IP设置方案[' & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ']')
	;清理先前加载配置
	_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
	_GUICtrlIpAddress_Set($GSubMask, "255.255.255.0")
	_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
	_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
	_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
EndFunc   ;==>_AddIpSet
;删除IP设置方案
Func _DelIPSet()
	If GUICtrlRead($LName) <> '' Then
		If MsgBox(4, '提示', '是否删除IP设置方案[' & GUICtrlRead($LName) & ']?', 8) = 6 Then
			GUICtrlSetData($GProjName, '')
			_GUICtrlIpAddress_Set($GIPAdress, "0.0.0.0")
			_GUICtrlIpAddress_Set($GSubMask, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDefaultGateway, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDNS1, "0.0.0.0")
			_GUICtrlIpAddress_Set($GDNS2, "0.0.0.0")
			IniDelete($iniFile, GUICtrlRead($LName))
			MsgBox(0, '提示', 'IP设置方案[' & GUICtrlRead($LName) & ']删除成功！', 5)
			GUICtrlSetData($LName, '')
			_InitIpSetData()
			_loadIpsetNameToCombo()
			_LoadIpSet()
		EndIf
	Else
		MsgBox(0, '提示', '没有可供删除的IP设置方案！', 5)
	EndIf
	_CleanZeroSizeFile()
EndFunc   ;==>_DelIPSet
;保存IP地址方案，对ini文件进行相应的更新
Func _SaveIPSet()
	If MsgBox(4, '提示', '是否将当前正在编辑的IP设置方案保存为[' & GUICtrlRead($GProjName) & ']?', 8) = 6 Then
		Local $SectionName = GUICtrlRead($GProjName)
		Local $IsNameExist = False
		If FileExists($iniFile) And $IPdataNotInit = False Then
			_InitIpSetData()
			For $i = 0 To UBound($aIpSetData) - 1
				If $aIpSetData[$i][0] = $SectionName Then
					$IsNameExist = True
					MsgBox(16, '错误', '已经存在同名的IP设置方案！', 5)
					ExitLoop
				EndIf
			Next
		EndIf
		If $IsNameExist = False Then
			IniWrite($iniFile, $SectionName, 'IP', _GUICtrlIpAddress_Get($GIPAdress))
			IniWrite($iniFile, $SectionName, 'SubMask', _GUICtrlIpAddress_Get($GSubMask))
			IniWrite($iniFile, $SectionName, 'DefaultGateWay', _GUICtrlIpAddress_Get($GDefaultGateway))
			IniWrite($iniFile, $SectionName, 'DNS1', _GUICtrlIpAddress_Get($GDNS1))
			IniWrite($iniFile, $SectionName, 'DNS2', _GUICtrlIpAddress_Get($GDNS2))
			GUICtrlSetData($LName, '')
			_InitIpSetData()
			_loadIpsetNameToCombo()
			_LoadIpSet()
		EndIf
	EndIf
	_CleanZeroSizeFile()
EndFunc   ;==>_SaveIPSet

Func _SelectIPSet()
	_LoadIpSet()
	_GUICtrlIpAddress_Set($IPAddress, _GUICtrlIpAddress_Get($GIPAdress))
	_GUICtrlIpAddress_Set($zmym, _GUICtrlIpAddress_Get($GSubMask))
	_GUICtrlIpAddress_Set($GateWay, _GUICtrlIpAddress_Get($GDefaultGateway))
	_GUICtrlIpAddress_Set($FirstDns, _GUICtrlIpAddress_Get($GDNS1))
	_GUICtrlIpAddress_Set($BakDns, _GUICtrlIpAddress_Get($GDNS2))
	GUICtrlSetData($IpProjName, GUICtrlRead($GProjName))
	GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
	If $IPdataNotInit = True Then
		GUICtrlSetData($IpProjName, '无方案')
		_LoadSpecifecInterfaceInfo()
	EndIf
	_QuitManageIPUI()
	_CleanZeroSizeFile()
EndFunc   ;==>_SelectIPSet
Func MacChangeDlg()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $frmMacChanger = _GUICreate("Mac修改及绑定", 334, 114, 138, 120, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $cboAdapters = GUICtrlCreateCombo("", 8, 8, 313, 21, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
	GUICtrlSetTip(-1, '请选择您要修改Mac物理地址的网卡', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiShowMac")
	GUICtrlSetData(-1, $AdapterList[1][0])
	Global $txtMac0 = GUICtrlCreateInput("", 8, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac1 = GUICtrlCreateInput("", 33, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac2 = GUICtrlCreateInput("", 58, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac3 = GUICtrlCreateInput("", 83, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac4 = GUICtrlCreateInput("", 108, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $txtMac5 = GUICtrlCreateInput("", 133, 40, 21, 21, -1, $WS_EX_CLIENTEDGE)
	GUICtrlSetLimit(-1, 2)
	Global $gphModified = GUICtrlCreateGraphic(158, 42, 17, 17)
	GUICtrlSetBkColor(-1, 0xFF0000)
	$win81dirOp[2] = GUICtrlCreateButton("还原Mac", 195, 38, 60, 25)
	GUICtrlSetTip(-1, '如果您的计算机在修改后存在' & @LF & '不能联网等情况，请点击此按钮！', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiRestoreMac")
	$Change = GUICtrlCreateButton("修改Mac", 260, 38, 60, 25)
	GUICtrlSetTip(-1, '修改完成以后，可能需要重启计算机以使修改生效！', '说明', 1)
	GUICtrlSetOnEvent(-1, "GuiChangeMac")
	Global $Bd = GUICtrlCreateButton("解除MAC绑定", 256, 78, 72, 25)
	GUICtrlSetOnEvent(-1, 'MacTIP')
	Global $MacIp = _GUICtrlIpAddress_Create($frmMacChanger, 112, 80, 138, 21)
	$UseBdMac[1] = _GUICtrlCreateCheckbox("启用MAC绑定", 16, 80, 97, 17)
	GUICtrlSetTip($UseBdMac[1], '不勾选，将删除现在选择网卡MAC地址的绑定！', '说明', 1)
	GUICtrlSetOnEvent($UseBdMac[1], 'toogleStatus')
	For $i = 1 To $AdapterList[0][0]
		GUICtrlSetData($cboAdapters, $AdapterList[$i][0])
	Next
	For $i = 0 To 5
		GUICtrlSetOnEvent(Eval('txtMac' & $i), 'GuiCheckHex')
		GUICtrlSetTip(Eval('txtMac' & $i), '按下[CTRL+1]可以一键复制MAC地址', '提示', 1)
	Next
	GUISetOnEvent($GUI_EVENT_CLOSE, "QuitMacChangeDlg")
	GuiShowMac()
	GUISetState(@SW_SHOW)
	If IsHWnd($frmMacChanger) Then
		HotKeySet('^{1}', '_PutMacToClip')
	EndIf
	_GUICtrlIpAddress_Disable($MacIp, 0xf)
EndFunc   ;==>MacChangeDlg

Func QuitMacChangeDlg()
	_WinAPI_AnimateWindow($frmMacChanger, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($frmMacChanger)
	HotKeySet('^{1}')
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitMacChangeDlg
Func CreateWifiDlg()
	HotKeySet('^{1}', 'CleanWifi')
	HotKeySet('^{2}', 'ReloadWifi')
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $Wifi = _GUICreate("创建Wifi热点", 259, 157, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $WifiName = GUICtrlCreateInput("", 16, 16, 225, 21)
	GUICtrlSetTip(-1, "您要共享出来的Wifi显示名称，最好是英文！")
	Global $WifiPwd = GUICtrlCreateInput("", 16, 75, 225, 21, $ES_PASSWORD)
	_GUICtrlEdit_SetPasswordChar(-1, '#')
	GUICtrlSetTip(-1, "密码至少8位以上，否则可能创建失败！")
	Global $ICSFrom = GUICtrlCreateCombo("", 16, 16, 225, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $ICSTo = GUICtrlCreateCombo("", 17, 73, 225, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $PreStep = GUICtrlCreateButton("<", 8, 128, 35, 25)
	GUICtrlSetTip(-1, "返回上一步操作")
	GUICtrlSetOnEvent(-1, '_PreStep')
	GUICtrlSetState(-1, $GUI_DISABLE)
	Global $BtnCreateWifi = GUICtrlCreateButton("创建Wifi热点[&C]", 48, 128, 163, 25)
	GUICtrlSetTip(-1, '按CTRL+1可以清除已经创建的wifi热点' & @LF & '按CTRL+2可以激活已经创建的Wifi热点', '说明', 1, 2)
	GUICtrlSetOnEvent(-1, 'CreateWifi')
	Global $BtnSetICS = GUICtrlCreateButton("应用ICS设置[&A]", 48, 128, 163, 25)
	GUICtrlSetOnEvent(-1, 'ApplyICS')
	GUICtrlSetState(-1, $GUI_HIDE)
	Global $NextStep = GUICtrlCreateButton(">", 216, 128, 35, 25)
	GUICtrlSetTip(-1, "进行下一步操作")
	GUICtrlSetOnEvent(-1, '_NextStep')
	Global $GwifiName = GUICtrlCreateGroup("Wifi热点名称", 8, 0, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $GICSFrom = GUICtrlCreateGroup("要使用的网络连接", 8, 0, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $GwifiPwd = GUICtrlCreateGroup("Wifi热点密码", 10, 58, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $GICSTo = GUICtrlCreateGroup("用于创建wifi热点的连接", 10, 58, 241, 45)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$FlagShowPassword[2] = _GUICtrlCreateCheckbox("显示密码", 16, 104, 97, 17)
	GUICtrlSetOnEvent($FlagShowPassword[2], '_ShowPassword')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWifiDlg')
EndFunc   ;==>CreateWifiDlg
Func QuitWifiDlg()
	ToolTip("")
	_WinAPI_AnimateWindow($Wifi, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Wifi)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	HotKeySet('^{1}')
	HotKeySet('^{2}')
EndFunc   ;==>QuitWifiDlg
Func _ShowPassword()
	If GUICtrlRead($FlagShowPassword[2]) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($WifiPwd)
	Else
		_GUICtrlEdit_SetPasswordChar($WifiPwd, '#')
	EndIf
	GUICtrlSetState($WifiPwd, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($WifiPwd, -1, -1)
EndFunc   ;==>_ShowPassword
Func CreateWifi()
	If GUICtrlRead($WifiName) <> '' And GUICtrlRead($WifiPwd) <> '' Then
		GUISetState(@SW_HIDE, $Wifi)
		$cmd = Run(@ComSpec & ' /c netsh wlan show drivers', @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
		ProcessWaitClose($cmd)
		$result = StdoutRead($cmd)
		If StringInStr($result, '支持的承载网络  : 是') Then
			;MsgBox(0,'','支持')
			ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '开始设置服务模式和SSID，PASS' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			RunWait(@ComSpec & ' /c netsh wlan set hostednetwork mode=allow ssid="' & GUICtrlRead($WifiName) & '" key="' & GUICtrlRead($WifiPwd) & '"', @SystemDir & '\', @SW_HIDE)
			ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在启动服务' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			RunWait(@ComSpec & ' /c netsh wlan start hostednetwork', @SystemDir & '\', @SW_HIDE)
			GUISetState(@SW_SHOW, $Wifi)
			$sHalfDone = _
					'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆' & @CRLF & _
					'Wifi热点创建完毕，请点击[>]按钮进入下一步操作，或' & @CRLF & _
					'通过手工方式进行操作，手工操作方式如下：' & @CRLF & _
					'打开网络共享中心--更改适配器设置,右击您当前使用的' & @CRLF & _
					'网络，选择属性,点击共享，勾选“允许其他网络用户通' & @CRLF & _
					'过连接来连接”选项,在下拉菜单中选择您刚才创建的Wi' & @CRLF & _
					'fi名称。' & @CRLF & _
					'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆'
			ToolTip($sHalfDone, @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
			Sleep(5000)
		Else
			MsgBox(0, '', '您当前系统不支持！')
		EndIf
		GUISetState(@SW_SHOW, $Wifi)
	Else
		MsgBox(16, '', 'Wifi热点名称和Wifi热点密码都不能为空！请填写后再试！', 5)
	EndIf
EndFunc   ;==>CreateWifi
Func ApplyICS()
	Local $sourceNet = GUICtrlRead($ICSFrom), $destinNet = GUICtrlRead($ICSTo)
	If $sourceNet <> '' And $destinNet <> '' Then
		_SetICSbyName("on", $destinNet, $sourceNet)
		$sFinished = _
				'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆' & @CRLF & _
				'创建wifi成功，请尽情享受wifi带来的畅快与便捷吧！' & @CRLF & _
				'★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆'
	Else
		MsgBox(16, '错误', '请选择要进行设置的连接', 5)
	EndIf
	ToolTip($sFinished, @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	Sleep(4000)
EndFunc   ;==>ApplyICS
Func sApName()
	$NetInfo = _GetNetworkAdapterInfo()
	Local $NewAdapterList = GetAdaptersList()
	Local $sName = ''
	For $i = 0 To UBound($NewAdapterList) - 1
		$sName &= $NewAdapterList[$i][5] & '|'
	Next
	Return $sName
EndFunc   ;==>sApName
Func _SetICSbyName($switch, $con1 = "", $con2 = "")
	Const $ICSSC_DEFAULT = 0
	Const $CONNECTION_PUBLIC = 0
	Const $CONNECTION_PRIVATE = 1
	Const $CONNECTION_ALL = 2
	$NetSharingManager = ObjCreate("HNetCfg.HNetShare.1")
	If (IsObj($NetSharingManager)) = False Then
		ConsoleWrite("Unable to get the HNetCfg.HnetShare.1 object" & @CRLF)
		Return
	EndIf
	;如果已经开启连接共享，先关闭
	$Connections = $NetSharingManager.EnumPublicConnections($ICSSC_DEFAULT)
	If $Connections.Count > 0 Then
		For $Item In $Connections
			$PublicConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
			$PublicConnection.DisableSharing
		Next
	EndIf
	$Connections = $NetSharingManager.EnumPrivateConnections($ICSSC_DEFAULT)
	If $Connections.Count > 0 Then
		For $Item In $Connections
			$PrivateConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
			$PrivateConnection.DisableSharing
		Next
	EndIf
	If $switch = "off" Then Return
	;如果是关闭共享，到止为止，下面不执行
	$EveryConnectionCollection = $NetSharingManager.EnumEveryConnection
	For $Item In $EveryConnectionCollection
		$EveryConnection = $NetSharingManager.INetSharingConfigurationForINetConnection($Item)
		$objNCProps = $NetSharingManager.NetConnectionProps($Item)

		If $objNCProps.Name = $con1 Then
			$EveryConnection.EnableSharing($CONNECTION_PRIVATE)
		EndIf

		If $objNCProps.Name = $con2 Then
			$EveryConnection.EnableSharing($CONNECTION_PUBLIC)
		EndIf
	Next

EndFunc   ;==>_SetICSbyName
Func _NextStep()
	GUICtrlSetState($WifiName, $GUI_HIDE)
	GUICtrlSetState($WifiPwd, $GUI_HIDE)
	GUICtrlSetState($PreStep, $GUI_ENABLE)
	GUICtrlSetState($BtnCreateWifi, $GUI_HIDE)
	GUICtrlSetState($NextStep, $GUI_DISABLE)
	GUICtrlSetState($FlagShowPassword[2], $GUI_DISABLE)
	GUICtrlSetState($GwifiName, $GUI_HIDE)
	GUICtrlSetState($GwifiPwd, $GUI_HIDE)
	GUICtrlSetState($BtnCreateWifi, $GUI_HIDE)
	;显示之前创建的控件
	GUICtrlSetState($ICSFrom, $GUI_SHOW)
	GUICtrlSetState($ICSTo, $GUI_SHOW)
	GUICtrlSetState($BtnSetICS, $GUI_SHOW)
	GUICtrlSetState($GICSFrom, $GUI_SHOW)
	GUICtrlSetState($GICSTo, $GUI_SHOW)
	GUICtrlSetState($BtnSetICS, $GUI_SHOW)

	Local $sComData = sApName()
	GUICtrlSetData($ICSFrom, '')
	GUICtrlSetData($ICSTo, '')
	GUICtrlSetData($ICSFrom, $sComData)
	GUICtrlSetData($ICSTo, $sComData)
EndFunc   ;==>_NextStep
Func _PreStep()
	;隐藏之前创建的控件
	GUICtrlSetState($ICSFrom, $GUI_HIDE)
	GUICtrlSetState($ICSTo, $GUI_HIDE)
	GUICtrlSetState($BtnSetICS, $GUI_HIDE)
	GUICtrlSetState($GICSFrom, $GUI_HIDE)
	GUICtrlSetState($GICSTo, $GUI_HIDE)
	GUICtrlSetState($BtnSetICS, $GUI_HIDE)

	GUICtrlSetState($WifiName, $GUI_SHOW)
	GUICtrlSetState($WifiPwd, $GUI_SHOW)
	GUICtrlSetState($PreStep, $GUI_DISABLE)
	GUICtrlSetState($BtnCreateWifi, $GUI_SHOW)
	GUICtrlSetState($NextStep, $GUI_ENABLE)
	GUICtrlSetState($FlagShowPassword[2], $GUI_ENABLE)
	GUICtrlSetState($GwifiName, $GUI_SHOW)
	GUICtrlSetState($GwifiPwd, $GUI_SHOW)
	GUICtrlSetState($BtnCreateWifi, $GUI_SHOW)
EndFunc   ;==>_PreStep
Func CleanWifi()
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在停止服务..' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan stop hostednetwork', @SystemDir & '\', @SW_HIDE)
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在清理...' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan set hostednetwork mode=disallow', @SystemDir & '\', @SW_HIDE)
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '清理完成，(*^__^*) 嘻嘻' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
EndFunc   ;==>CleanWifi
Func ReloadWifi()
	ToolTip('★☆★☆★☆★☆★☆★☆' & @LF & '正在启动服务..' & @LF & '★☆★☆★☆★☆★☆★☆', @DesktopWidth / 2 + 350, @DesktopHeight / 2 + 270)
	RunWait(@ComSpec & ' /c netsh wlan start hostednetwork', @SystemDir & '\', @SW_HIDE)
EndFunc   ;==>ReloadWifi
Func ChangeSingleUserPassword()
	$PasswordChangeMode = 0
	ChangeUserPasswordDlg()
EndFunc   ;==>ChangeSingleUserPassword
Func ChangeListUserPassword()
	$PasswordChangeMode = 1
	ChangeUserPasswordDlg()
EndFunc   ;==>ChangeListUserPassword
Func ChangeUserDescDlg()
	Local $UserNameToSet = GUICtrlRead($ComboUserList)
	Local $UserDescinfo = GUICtrlRead($UserDesc)
	If $UserNameToSet <> '' Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Global $FormUserChangeDesc = _GUICreate("更改用户描述", 259, 140, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		Global $UserNameToSetDesc = GUICtrlCreateInput($UserNameToSet, 16, 16, 225, 21)
		GUICtrlSetState(-1, $GUI_DISABLE)
		Global $UserDescToChange = GUICtrlCreateInput($UserDescinfo, 16, 75, 225, 21)
		GUICtrlCreateButton("更改用户描述信息[&C]", 8, 110, 243, 25)
		GUICtrlSetOnEvent(-1, '_ChangeSelectedUserDesc')
		GUICtrlCreateGroup("要更改描述的用户名称", 8, 0, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("用户描述信息", 10, 58, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitChangeUserDescDlg')
	Else
		MsgBox(0, '提示', '请先选择要进行描述设置的用户名~~', 5)
	EndIf
EndFunc   ;==>ChangeUserDescDlg
Func QuitChangeUserDescDlg()
	_WinAPI_AnimateWindow($FormUserChangeDesc, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormUserChangeDesc)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitChangeUserDescDlg
Func ChangeUserPasswordDlg()
	Local $UserNameToSet = GUICtrlRead($ComboUserList)
	If $UserNameToSet <> '' Then
		_GUIDisable($Form1, 1, 45, 0x51D0F7)
		_DisableTrayMenu()
		Global $FormUserChangePWD = _GUICreate("更改用户密码", 259, 157, 175, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
		Global $UserNameToSetPWD = GUICtrlCreateInput($UserNameToSet, 16, 16, 225, 21)
		If $PasswordChangeMode = 1 Then GUICtrlSetData($UserNameToSetPWD, '用户列表全部用户')
		GUICtrlSetState(-1, $GUI_DISABLE)
		Global $UserPwdToChange = GUICtrlCreateInput("", 16, 75, 225, 21, $ES_PASSWORD)
		_GUICtrlEdit_SetPasswordChar(-1, '#')
		GUICtrlCreateButton("更改用户密码[&C]", 8, 125, 243, 25)
		GUICtrlSetOnEvent(-1, '_ChangeUserPassword')
		GUICtrlCreateGroup("要更改密码的用户名称", 8, 0, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		GUICtrlCreateGroup("新的用户密码", 10, 58, 241, 45)
		_removeEffect()
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
		GUICtrlCreateGroup("", -99, -99, 1, 1)
		$FlagShowPassword[1] = _GUICtrlCreateCheckbox("显示密码", 16, 104, 97, 17)
		GUICtrlSetOnEvent($FlagShowPassword[1], '_ShowUserPassword')
		GUISetState(@SW_SHOW)
		GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitChangeUserPasswordDlg')
	Else
		MsgBox(0, '提示', '请先选择要进行密码设置的用户名~~', 5)
	EndIf
EndFunc   ;==>ChangeUserPasswordDlg
Func QuitChangeUserPasswordDlg()
	_WinAPI_AnimateWindow($FormUserChangePWD, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormUserChangePWD)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitChangeUserPasswordDlg
Func _ShowUserPassword()
	If GUICtrlRead($FlagShowPassword[1]) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($UserPwdToChange)
	Else
		_GUICtrlEdit_SetPasswordChar($UserPwdToChange, '#')
	EndIf
	GUICtrlSetState($UserPwdToChange, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($UserPwdToChange, -1, -1)
EndFunc   ;==>_ShowUserPassword
Func _ChangeUserPassword()
	Local $UserPassword = GUICtrlRead($UserPwdToChange)
	If $PasswordChangeMode = 0 Then
		Local $UserName = GUICtrlRead($UserNameToSetPWD)
		Local $iResult = _NetUserSetPassword($UserName, $UserPassword)
		If $iResult Then
			MsgBox(0, "提示", "用户密码更改成功~", 6)
		Else
			MsgBox(0, '错误', @error & "用户密码更改失败！", 6)
		EndIf
	Else
		Local $iResult
		For $iUser = 0 To UBound($aUserInfo) - 1
			$iResult = _NetUserSetPassword($aUserInfo[$iUser][0], $UserPassword)
		Next
		If $iResult Then
			MsgBox(0, "提示", "统一设置列表用户密码成功~", 6)
		Else
			MsgBox(0, '错误', @error & "统一设置列表用户密码失败！", 6)
		EndIf
	EndIf
EndFunc   ;==>_ChangeUserPassword
Func _ChangeSelectedUserDesc()
	Local $iResult = _SetUserDesc(GUICtrlRead($UserNameToSetDesc), GUICtrlRead($UserDescToChange))
	If $iResult Then
		MsgBox(0, '提示', '修改用户描述成功！', 5)
		_LoadUserNameToArray()
	Else
		MsgBox(16, '提示', '修改用户描述失败！', 5)
	EndIf
EndFunc   ;==>_ChangeSelectedUserDesc
Func ResetWinsock()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	GUISetState(@SW_SHOW, $LoadingUI)
	$aText = '正在重置Winsock，请稍候..'
	RunWait(@ComSpec & ' /c netsh winsock reset', '', @SW_HIDE)
	GUISetState(@SW_HIDE, $LoadingUI)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
	$aText = '正在处理，请稍后'
	MsgBox(0, '提示', '重置Winsock成功，重启后生效。', 5)
EndFunc   ;==>ResetWinsock
Func _NetWorkConfigsTool()
	Global $NetWorkConfigsUI = _GUICreate("网络配置备份与恢复", 277, 66, 144, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("备份网络配置[&B]", 8, 8, 259, 20)
	GUICtrlSetOnEvent(-1, '_MakeNetworkConfigBackup')
	GUICtrlCreateButton("还原网络配置[&R]", 8, 30, 259, 27)
	GUICtrlSetOnEvent(-1, '_RestroreNetworkConfigBackup')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitConfigUI')
EndFunc   ;==>_NetWorkConfigsTool
Func _QuitConfigUI()
	_WinAPI_AnimateWindow($NetWorkConfigsUI, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($NetWorkConfigsUI)
EndFunc   ;==>_QuitConfigUI
Func _MakeNetworkConfigBackup()
	Local $File = FileSaveDialog('请设置网络配置备份要进行保存的文件名称', '', '所有文件(*.*)', 16, '', $NetWorkConfigsUI)
	If Not @error Then
		TrayTip('提示', '正在备份网络配置，请稍候..', 3, 1)
		RunWait(@ComSpec & ' /c netsh dump >"' & $File & '"', @WindowsDir, @SW_HIDE)
		TrayTip('', '', 0)
		MsgBox(0, '提示', '已经成功备份当前网络配置~', 5, $NetWorkConfigsUI)
	Else
		TrayTip('提示', '用户取消了备份操作..', 3, 1)
	EndIf
EndFunc   ;==>_MakeNetworkConfigBackup
Func _RestroreNetworkConfigBackup()
	Local $File = FileOpenDialog('请选择网络配置备份文件', '', '所有文件(*.*)', 1, '', $NetWorkConfigsUI)
	If Not @error Then
		TrayTip('提示', '正在还原网络配置，请稍候..', 3, 1)
		RunWait(@ComSpec & ' /c netsh exec "' & $File & '"', @WindowsDir, @SW_HIDE)
		TrayTip('', '', 0)
		MsgBox(0, '提示', '已经成功还原网络配置到当前系统~', 5, $NetWorkConfigsUI)
	Else
		TrayTip('提示', '用户取消了还原操作..', 3, 1)
	EndIf
EndFunc   ;==>_RestroreNetworkConfigBackup
Func PrepDNS()
	Global $aDns[2][47][3]
	;电信DNS
	$aDns[0][0][0] = '本地DNS'
	$aDns[0][0][1] = '0.0.0.0'
	$aDns[0][0][2] = '0.0.0.0'
	$aDns[0][1][0] = "北京DNS"
	$aDns[0][1][1] = "202.96.199.133"
	$aDns[0][1][2] = "202.96.0.133"
	$aDns[0][10][0] = "湖南DNS"
	$aDns[0][10][1] = "202.103.0.68"
	$aDns[0][10][2] = "202.103.96.68"
	$aDns[0][11][0] = "江苏DNS"
	$aDns[0][11][1] = "202.102.15.162"
	$aDns[0][11][2] = "202.102.29.3"
	$aDns[0][12][0] = "陕西DNS"
	$aDns[0][12][1] = "202.100.13.11"
	$aDns[0][12][2] = "202.100.4.16"
	$aDns[0][13][0] = "西安DNS"
	$aDns[0][13][1] = "202.100.4.15"
	$aDns[0][13][2] = "202.100.0.68"
	$aDns[0][14][0] = "湖北DNS"
	$aDns[0][14][1] = "202.103.0.68"
	$aDns[0][14][2] = "202.103.0.117"
	$aDns[0][15][0] = "山东DNS"
	$aDns[0][15][1] = "202.102.154.3"
	$aDns[0][15][2] = "202.102.152.3"
	$aDns[0][16][0] = "浙江DNS"
	$aDns[0][16][1] = "202.96.102.3"
	$aDns[0][16][2] = "202.96.104.18"
	$aDns[0][17][0] = "辽宁DNS"
	$aDns[0][17][1] = "219.149.6.99"
	$aDns[0][17][2] = "219.148.204.66"
	$aDns[0][18][0] = "安徽DNS"
	$aDns[0][18][1] = "202.102.192.68"
	$aDns[0][18][2] = "202.102.199.68"
	$aDns[0][19][0] = "重庆DNS"
	$aDns[0][19][1] = "61.128.128.68"
	$aDns[0][19][2] = "10.150.0.1"
	$aDns[0][2][0] = "上海DNS"
	$aDns[0][2][1] = "202.96.199.132"
	$aDns[0][2][2] = "202.96.199.133"
	$aDns[0][20][0] = "黑龙江DNS"
	$aDns[0][20][1] = "202.97.229.133"
	$aDns[0][20][2] = "202.97.224.68"
	$aDns[0][21][0] = "河北DNS"
	$aDns[0][21][1] = "222.222.202.202"
	$aDns[0][21][2] = "222.222.222.222"
	$aDns[0][22][0] = "保定DNS"
	$aDns[0][22][1] = "202.99.160.68"
	$aDns[0][22][2] = "202.99.166.4"
	$aDns[0][23][0] = "吉林DNS"
	$aDns[0][23][1] = "202.98.14.18"
	$aDns[0][23][2] = "202.98.14.19"
	$aDns[0][24][0] = "江西DNS"
	$aDns[0][24][1] = "202.101.224.68"
	$aDns[0][24][2] = "202.101.240.36"
	$aDns[0][25][0] = "山西DNS"
	$aDns[0][25][1] = "202.99.192.68"
	$aDns[0][25][2] = "202.99.198.6"
	$aDns[0][26][0] = "新疆DNS"
	$aDns[0][26][1] = "61.128.99.133"
	$aDns[0][26][2] = "61.128.99.134"
	$aDns[0][27][0] = "贵州DNS"
	$aDns[0][27][1] = "202.98.192.68"
	$aDns[0][27][2] = "10.157.2.15"
	$aDns[0][28][0] = "云南DNS"
	$aDns[0][28][1] = "202.98.96.68"
	$aDns[0][28][2] = "202.98.160.68"
	$aDns[0][29][0] = "四川DNS"
	$aDns[0][29][1] = "202.98.96.68"
	$aDns[0][29][2] = "61.139.2.69"
	$aDns[0][3][0] = "天津DNS"
	$aDns[0][3][1] = "202.99.96.68"
	$aDns[0][3][2] = "10.10.64.68"
	$aDns[0][30][0] = "重庆DNS"
	$aDns[0][30][1] = "61.128.128.68"
	$aDns[0][30][2] = "61.128.192.4"
	$aDns[0][31][0] = "成都DNS"
	$aDns[0][31][1] = "202.98.96.68"
	$aDns[0][31][2] = "202.98.96.69"
	$aDns[0][32][0] = "内蒙古DNS"
	$aDns[0][32][1] = "222.74.1.200"
	$aDns[0][32][2] = "10.29.0.2"
	$aDns[0][33][0] = "青海DNS"
	$aDns[0][33][1] = "202.100.128.68"
	$aDns[0][33][2] = "10.184.0.1"
	$aDns[0][34][0] = "海南DNS"
	$aDns[0][34][1] = "202.100.192.68"
	$aDns[0][34][2] = "202.100.199.8"
	$aDns[0][35][0] = "宁夏DNS"
	$aDns[0][35][1] = "202.100.0.68"
	$aDns[0][35][2] = "202.100.96.68"
	$aDns[0][36][0] = "甘肃DNS"
	$aDns[0][36][1] = "202.100.72.13"
	$aDns[0][36][2] = "10.179.64.1"
	$aDns[0][37][0] = "香港DNS"
	$aDns[0][37][1] = "205.252.144.126"
	$aDns[0][37][2] = "218.102.62.71"
	$aDns[0][38][0] = "澳门DNS"
	$aDns[0][38][1] = "202.175.3.8"
	$aDns[0][38][2] = "202.175.3.3"
	$aDns[0][39][0] = "谷歌DNS"
	$aDns[0][39][1] = "8.8.8.8"
	$aDns[0][39][2] = "8.8.4.4"
	$aDns[0][4][0] = "广东DNS"
	$aDns[0][4][1] = "202.96.128.143"
	$aDns[0][4][2] = "202.96.128.68"
	$aDns[0][40][0] = "阿里公共DNS"
	$aDns[0][40][1] = "223.5.5.5"
	$aDns[0][40][2] = "223.6.6.6"
	$aDns[0][41][0] = "百度公共DNS"
	$aDns[0][41][1] = "180.76.76.76"
	$aDns[0][41][2] = "114.114.114.114"
	$aDns[0][42][0] = "OpenDNS"
	$aDns[0][42][1] = "208.67.222.222"
	$aDns[0][42][2] = "208.67.220.220Norton DNS"
	$aDns[0][43][0] = "OpenDNS Family"
	$aDns[0][43][1] = "208.67.222.123"
	$aDns[0][43][2] = "208.67.220.123"
	$aDns[0][44][0] = "Comodo Secure DNS"
	$aDns[0][44][1] = "156.154.70.22"
	$aDns[0][44][2] = "156.154.71.22"
	$aDns[0][45][0] = "ScrubIt DNS"
	$aDns[0][45][1] = "67.138.54.100"
	$aDns[0][45][2] = "207.225.209.66"
	$aDns[0][46][0] = "DNS Advantage"
	$aDns[0][46][1] = "156.154.70.1"
	$aDns[0][46][2] = "156.154.71.1"
	$aDns[0][5][0] = "深圳DNS"
	$aDns[0][5][1] = "202.96.134.133"
	$aDns[0][5][2] = "202.96.154.8"
	$aDns[0][6][0] = "河南DNS"
	$aDns[0][6][1] = "202.102.227.68"
	$aDns[0][6][2] = "202.102.224.68"
	$aDns[0][7][0] = "广西DNS"
	$aDns[0][7][1] = "202.103.224.68"
	$aDns[0][7][2] = "202.103.225.68"
	$aDns[0][8][0] = "福建DNS"
	$aDns[0][8][1] = "218.85.157.99"
	$aDns[0][8][2] = "202.101.115.55"
	$aDns[0][9][0] = "厦门DNS"
	$aDns[0][9][1] = "202.101.103.55"
	$aDns[0][9][2] = "202.101.103.54"
	;网通DNS
	$aDns[1][1][0] = "北京DNS"
	$aDns[1][1][1] = "ns.bta.net.cn"
	$aDns[1][1][2] = "202.96.0.133"
	$aDns[1][10][0] = "天津DNS"
	$aDns[1][10][1] = "202.99.96.68"
	$aDns[1][10][2] = "10.10.64.68"
	$aDns[1][11][0] = "辽宁DNS"
	$aDns[1][11][1] = "202.96.75.68"
	$aDns[1][11][2] = "202.96.75.64"
	$aDns[1][12][0] = "江苏DNS"
	$aDns[1][12][1] = "202.102.29.3"
	$aDns[1][12][2] = "202.102.13.141"
	$aDns[1][13][0] = "安徽DNS"
	$aDns[1][13][1] = "202.102.192.68"
	$aDns[1][13][2] = "202.102.199.68"
	$aDns[1][14][0] = "四川DNS"
	$aDns[1][14][1] = "119.6.6.6"
	$aDns[1][14][2] = "221.10.251.197"
	$aDns[1][15][0] = "重庆DNS"
	$aDns[1][15][1] = "61.128.128.68"
	$aDns[1][15][2] = "61.128.192.4"
	$aDns[1][16][0] = "成都DNS"
	$aDns[1][16][1] = "202.98.96.68"
	$aDns[1][16][2] = "202.98.96.69"
	$aDns[1][17][0] = "河北DNS"
	$aDns[1][17][1] = "202.99.160.68"
	$aDns[1][17][2] = "10.17.128.90"
	$aDns[1][18][0] = "保定DNS"
	$aDns[1][18][1] = "202.99.160.68"
	$aDns[1][18][2] = "202.99.166.4"
	$aDns[1][19][0] = "山西DNS"
	$aDns[1][19][1] = "202.99.198.6"
	$aDns[1][19][2] = "202.99.192.68"
	$aDns[1][2][0] = "香港DNS"
	$aDns[1][2][1] = "205.252.144.228"
	$aDns[1][2][2] = "0.0.0.0"
	$aDns[1][20][0] = "吉林DNS"
	$aDns[1][20][1] = "202.98.5.68"
	$aDns[1][20][2] = "202.98.14.19"
	$aDns[1][21][0] = "山东DNS"
	$aDns[1][21][1] = "202.102.152.3"
	$aDns[1][21][2] = "202.102.128.68"
	$aDns[1][22][0] = "福建DNS"
	$aDns[1][22][1] = "202.101.98.55"
	$aDns[1][22][2] = "202.101.115.55"
	$aDns[1][23][0] = "湖南DNS"
	$aDns[1][23][1] = "202.103.100.206"
	$aDns[1][23][2] = "202.103.96.68"
	$aDns[1][24][0] = "广西DNS"
	$aDns[1][24][1] = "202.103.224.68"
	$aDns[1][24][2] = "202.103.225.68"
	$aDns[1][25][0] = "江西DNS"
	$aDns[1][25][1] = "202.109.129.2"
	$aDns[1][25][2] = "202.101.224.68"
	$aDns[1][26][0] = "云南DNS"
	$aDns[1][26][1] = "202.98.160.68"
	$aDns[1][26][2] = "202.98.96.68"
	$aDns[1][27][0] = "河南DNS"
	$aDns[1][27][1] = "202.102.227.68"
	$aDns[1][27][2] = "202.102.224.68"
	$aDns[1][28][0] = "新疆DNS"
	$aDns[1][28][1] = "61.128.97.73"
	$aDns[1][28][2] = "61.128.97.74"
	$aDns[1][29][0] = "乌鲁木齐DNS"
	$aDns[1][29][1] = "61.128.97.73"
	$aDns[1][29][2] = "61.128.97.74"
	$aDns[1][3][0] = "澳门DNS"
	$aDns[1][3][1] = "202.175.3.8"
	$aDns[1][3][2] = "0.0.0.0"
	$aDns[1][30][0] = "武汉DNS"
	$aDns[1][30][1] = "202.103.24.68"
	$aDns[1][30][2] = "202.103.0.117"
	$aDns[1][31][0] = "厦门DNS"
	$aDns[1][31][1] = "202.101.103.55"
	$aDns[1][31][2] = "202.101.103.54"
	$aDns[1][32][0] = "山东DNS"
	$aDns[1][32][1] = "202.102.134.68"
	$aDns[1][32][2] = "202.102.152.3"
	$aDns[1][33][0] = "长沙DNS"
	$aDns[1][33][1] = "202.103.96.68"
	$aDns[1][33][2] = "202.103.96.112"
	$aDns[1][34][0] = "谷歌DNS"
	$aDns[1][34][1] = "8.8.8.8"
	$aDns[1][34][2] = "8.8.4.4"
	$aDns[1][35][0] = "阿里公共DNS"
	$aDns[1][35][1] = "223.5.5.5"
	$aDns[1][35][2] = "223.6.6.6"
	$aDns[1][36][0] = "百度公共DNS"
	$aDns[1][36][1] = "180.76.76.76"
	$aDns[1][36][2] = "114.114.114.114"
	$aDns[1][37][0] = "OpenDNS"
	$aDns[1][37][1] = "208.67.222.222"
	$aDns[1][37][2] = "208.67.220.220"
	$aDns[1][38][0] = "OpenDNS Family"
	$aDns[1][38][1] = "208.67.222.123"
	$aDns[1][38][2] = "208.67.220.123"
	$aDns[1][39][0] = "Comodo Secure DNS"
	$aDns[1][39][1] = "156.154.70.22"
	$aDns[1][39][2] = "156.154.71.22"
	$aDns[1][4][0] = "深圳DNS"
	$aDns[1][4][1] = "220.250.64.26"
	$aDns[1][4][2] = "202.96.134.133"
	$aDns[1][40][0] = "ScrubIt DNS"
	$aDns[1][40][1] = "67.138.54.100"
	$aDns[1][40][2] = "207.225.209.66"
	$aDns[1][41][0] = "DNS Advantage"
	$aDns[1][41][1] = "156.154.70.1"
	$aDns[1][41][2] = "156.154.71.1"
	$aDns[1][5][0] = "广东DNS"
	$aDns[1][5][1] = "202.96.128.143"
	$aDns[1][5][2] = "202.96.128.68"
	$aDns[1][6][0] = "上海DNS"
	$aDns[1][6][1] = "202.96.199.132"
	$aDns[1][6][2] = "202.96.199.133"
	$aDns[1][7][0] = "浙江DNS"
	$aDns[1][7][1] = "202.96.102.3"
	$aDns[1][7][2] = "202.96.96.68"
	$aDns[1][8][0] = "陕西DNS"
	$aDns[1][8][1] = "202.100.13.11"
	$aDns[1][8][2] = "202.100.4.16"
	$aDns[1][9][0] = "西安DNS"
	$aDns[1][9][1] = "202.100.4.15"
	$aDns[1][9][2] = "202.100.0.68"
	GUICtrlSetData($DNS, '')
	If GUICtrlRead($IpSetDlg[3]) = $GUI_CHECKED Then
		For $i = 0 To UBound($aDns, 2) - 1
			Local $CityName = $aDns[0][$i][0]
			If $CityName <> '' Then
				GUICtrlSetData($DNS, $aDns[0][$i][0])
			EndIf
		Next
	Else
		For $i = 0 To UBound($aDns, 2) - 1
			Local $CityName = $aDns[1][$i][0]
			If $CityName <> '' Then
				GUICtrlSetData($DNS, $aDns[1][$i][0])
			EndIf
		Next
	EndIf
EndFunc   ;==>PrepDNS
;设置Dns函数
Func LoadDNS()
	If GUICtrlRead($IpSetDlg[3]) = $GUI_CHECKED Then
		For $i = 0 To UBound($aDns, 2) - 1
			If GUICtrlRead($DNS) = $aDns[0][$i][0] Then
				_GUICtrlIpAddress_Set($FirstDns, $aDns[0][$i][1])
				_GUICtrlIpAddress_Set($BakDns, $aDns[0][$i][2])
			EndIf
		Next
	Else
		For $i = 0 To UBound($aDns, 2) - 1
			If GUICtrlRead($DNS) = $aDns[1][$i][0] Then
				_GUICtrlIpAddress_Set($FirstDns, $aDns[1][$i][1])
				_GUICtrlIpAddress_Set($BakDns, $aDns[1][$i][2])
			EndIf
		Next
	EndIf
EndFunc   ;==>LoadDNS
;线路选择触发事件函数
Func ChooseLine()
;~ 	PrepDNS()
	LoadDNS()
EndFunc   ;==>ChooseLine

;设置DNS
Func SetIPS()
	If GUICtrlRead($NetApt) <> '' Then
		Local $Ip = _GUICtrlIpAddress_Get($IPAddress)
		Local $SubMask = _GUICtrlIpAddress_Get($zmym)
		Local $DefGateWay = _GUICtrlIpAddress_Get($GateWay)
		Local $protDns = _GUICtrlIpAddress_Get($FirstDns)
		Local $SecDns = _GUICtrlIpAddress_Get($BakDns)
		Local $ConName = GUICtrlRead($NetApt)
		If GUICtrlRead($IpSetDlg[2]) = $GUI_CHECKED Then
			;设置IP地址及子网掩码、网关
			RunWait(@ComSpec & ' /c netsh interface ip set address name="' & $ConName & '" static ' & $Ip & ' ' & $SubMask & ' ' & $DefGateWay, @WindowsDir, @SW_HIDE)
			_SetCmpIP($InterFaceGUID, $Ip, $SubMask, $DefGateWay, $protDns & ',' & $SecDns)
			;刷新DNS缓存
			DllCall('Dnsapi.dll', 'BOOL', 'DnsFlushResolverCache')
			_updateArryInfo()
			MsgBox(0, '提示', '设置静态IP成功！', 5)
		EndIf
		If GUICtrlRead($IpSetDlg[1]) = $GUI_CHECKED Then
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\" & $InterFaceGUID, "EnableDHCP", "REG_DWORD", "1")
			RunWait(@ComSpec & ' /c netsh interface ip set address name="' & $ConName & '" source=dhcp ', @ScriptDir & '\', @SW_HIDE)
			If GUICtrlRead($DIDNS) = $GUI_CHECKED Then
				RunWait('netsh interface ipv4 set dnsservers "' & $ConName & '" static ' & $protDns & ' primary validate=no', @ScriptDir & '\', @SW_HIDE)
				RunWait('netsh interface ipv4 set dnsservers "' & $ConName & '" static ' & $SecDns & ' index=2 validate=no', @ScriptDir & '\', @SW_HIDE)
			Else
				RunWait(@ComSpec & ' /c netsh interface ip set dns name="' & $ConName & '" source=dhcp ', @ScriptDir & '\', @SW_HIDE)
			EndIf
			_ForceUpdate()
			DllCall('Dnsapi.dll', 'BOOL', 'DnsFlushResolverCache')
			MsgBox(0, '提示', '设置计算机IP为自动获取成功！', 5)
		EndIf
	ElseIf GUICtrlRead($NetApt) = '' Then
		MsgBox(0, '', '请选择您要进行设置的网络！', 3)
	Else
	EndIf
EndFunc   ;==>SetIPS

Func _loadNetInterface()
	For $i = 1 To UBound($NetInfo) - 1
		GUICtrlSetData($NetApt, $NetInfo[$i][3])
	Next
EndFunc   ;==>_loadNetInterface
Func _LoadSpecifecInterfaceInfo()
	For $i = 1 To UBound($NetInfo) - 1
		If GUICtrlRead($NetApt) == $NetInfo[$i][3] Then
			$InterFaceGUID = $NetInfo[$i][5]
			If $NetInfo[$i][6] = '' Then
				_GUICtrlIpAddress_Set($IPAddress, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($IPAddress, $NetInfo[$i][6])
			EndIf
			If $NetInfo[$i][8] = '' Then
				_GUICtrlIpAddress_Set($zmym, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($zmym, $NetInfo[$i][8])
			EndIf
			If $NetInfo[$i][7] = '' Then
				_GUICtrlIpAddress_Set($GateWay, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($GateWay, $NetInfo[$i][7])
			EndIf
			If $NetInfo[$i][9] = '' Then
				_GUICtrlIpAddress_Set($FirstDns, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($FirstDns, $NetInfo[$i][9])
			EndIf
			If $NetInfo[$i][10] = '' Then
				_GUICtrlIpAddress_Set($BakDns, '0.0.0.0')
			Else
				_GUICtrlIpAddress_Set($BakDns, $NetInfo[$i][10])
			EndIf
			$InterFaceGUID = $NetInfo[$i][5]
			If $NetInfo[$i][12] = True Then
				GUICtrlSetState($IpSetDlg[1], $GUI_CHECKED)
			Else
				GUICtrlSetState($IpSetDlg[2], $GUI_CHECKED)
			EndIf
			_ToogleIPControl()
			GUICtrlSetData($IpProjName, '无方案')
			_GUICtrlComboBox_SelectString($DNS, '本地DNS')
			ExitLoop
		EndIf
	Next
EndFunc   ;==>_LoadSpecifecInterfaceInfo

Func _updateArryInfo()
	Local $Ip = _GUICtrlIpAddress_Get($IPAddress)
	Local $SubMask = _GUICtrlIpAddress_Get($zmym)
	Local $DefGateWay = _GUICtrlIpAddress_Get($GateWay)
	Local $protDns = _GUICtrlIpAddress_Get($FirstDns)
	Local $SecDns = _GUICtrlIpAddress_Get($BakDns)
	Local $ConName = GUICtrlRead($NetApt)
	For $i = 1 To UBound($NetInfo) - 1
		If $ConName == $NetInfo[$i][3] Then
			If GUICtrlRead($IpSetDlg[2]) = $GUI_CHECKED Then
				If $Ip = '' Then
					$NetInfo[$i][6] = '0.0.0.0'
				EndIf
				If $SubMask = '' Then
					$NetInfo[$i][8] = '0.0.0.0'
				Else
					$NetInfo[$i][8] = $SubMask
				EndIf
				If $DefGateWay = '' Then
					$NetInfo[$i][7] = '0.0.0.0'
				Else
					$NetInfo[$i][7] = $DefGateWay
				EndIf
				If $protDns = '' Then
					$NetInfo[$i][9] = '0.0.0.0'
				Else
					$NetInfo[$i][9] = $protDns
				EndIf
				If $SecDns = '' Then
					$NetInfo[$i][10] = '0.0.0.0'
				Else
					$NetInfo[$i][10] = $SecDns
				EndIf
			EndIf

			ExitLoop
		EndIf
	Next
EndFunc   ;==>_updateArryInfo
Func _GetNetworkAdapterInfo()
	Local $colItem
	Local $objItem
	Local $colItems
	Local $objItems
	Local $objWMIService
	Local $Adapters[1][13]
	$Adapters[0][0] = 0
	$objWMIService = ObjGet("winmgmts:\\localhost\root\CIMV2")
	$colItem = $objWMIService.ExecQuery("Select * FROM Win32_NetworkAdapter Where NetConnectionStatus >0", "WQL", 0x30)
	If IsObj($colItem) Then
		For $objItem In $colItem
			If $objItem.MACAddress = "00:00:00:00:00:00" Then ContinueLoop
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][13]
			$Adapters[$Adapters[0][0]][0] += $Adapters[0][0]
			$Adapters[$Adapters[0][0]][1] = $objItem.NetConnectionStatus
			$Adapters[$Adapters[0][0]][2] = $objItem.Description
			$Adapters[$Adapters[0][0]][3] = $objItem.NetConnectionID
			$Adapters[$Adapters[0][0]][4] = $objItem.MACAddress
			;WidnowsNT6上的网卡ID
			If @OSBuild > 6000 Then
				$Adapters[$Adapters[0][0]][5] = $objItem.Guid
			Else
				$Adapters[$Adapters[0][0]][5] = ''
			EndIf
			$colItems = $objWMIService.ExecQuery('Select * FROM Win32_NetworkAdapterConfiguration Where MACAddress = "' & $Adapters[$Adapters[0][0]][4] & '" And IPEnabled = True ', "WQL", 0x30)
			If IsObj($colItems) Then
				For $objItems In $colItems
;~ 					if $objItems.IPAddress(0) = "0.0.0.0" Then ContinueLoop
					$Adapters[$Adapters[0][0]][6] = $objItems.IPAddress(0)
					$Adapters[$Adapters[0][0]][7] = $objItems.DefaultIPGateway(0)
					$Adapters[$Adapters[0][0]][8] = $objItems.IPSubnet(0)
					$sDNS = _WMIArrayToString($objItems.DNSServerSearchOrder())
					$aDns = StringSplit($sDNS, '|')
					If Not @error Then
						$Adapters[$Adapters[0][0]][9] = $aDns[1]
						$Adapters[$Adapters[0][0]][10] = $aDns[2]
					Else
						$Adapters[$Adapters[0][0]][9] = $aDns[1]
						$Adapters[$Adapters[0][0]][10] = '0.0.0.0'
					EndIf
					$Adapters[$Adapters[0][0]][11] = $objItems.SettingID
					$Adapters[$Adapters[0][0]][12] = $objItems.DHCPEnabled
				Next
			EndIf
		Next
	EndIf
	Return $Adapters
EndFunc   ;==>_GetNetworkAdapterInfo
Func _WMIArrayToString($aArray, $sDelimeter = '|')
	Local $sString = ''
	If UBound($aArray) Then
		For $i = 0 To UBound($aArray) - 1
			$sString &= $aArray[$i] & $sDelimeter
		Next
		$sString = StringTrimRight($sString, StringLen($sDelimeter))
	EndIf
	Return $sString
EndFunc   ;==>_WMIArrayToString

Func GetAdaptersList()
	Local $Adapters[1][4]
	$Adapters[0][0] = 0

	If @OSType = "WIN32_NT" Then
		;Use WMI
		Local $i
		For $i = 1 To UBound($NetInfo) - 1
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][6]
			$Adapters[$Adapters[0][0]][0] = $NetInfo[$i][2] ;adapter name
			$Adapters[$Adapters[0][0]][1] = $NetInfo[$i][4] ;adapter real mac address
			Local $AdapterReg = GetAdapterRegKey($NetInfo[$i][2])
			$Adapters[$Adapters[0][0]][2] = $AdapterReg[0] ;adapter regkey
			If @OSBuild < 6000 Then
				$NetInfo[$i][5] = RegRead($AdapterReg[0], 'NetCfgInstanceId')
			EndIf
			$Adapters[$Adapters[0][0]][3] = $AdapterReg[1] ;virtual mac
			$Adapters[$Adapters[0][0]][4] = $NetInfo[$i][6] ;IP地址
			$Adapters[$Adapters[0][0]][5] = $NetInfo[$i][3] ;连接名称
		Next
	Else
		;Use a lista do registro se for win9x
		Local $AdapterRegList = GetAdapterRegKey()
		Local $i = 0
		For $i = 1 To $AdapterRegList[0][0]
			$Adapters[0][0] += 1
			ReDim $Adapters[UBound($Adapters) + 1][4]
			$Adapters[$Adapters[0][0]][0] = $AdapterRegList[$i][0] ;adapter name
			$Adapters[$Adapters[0][0]][1] = "" ;adapter real mac address
			$Adapters[$Adapters[0][0]][2] = $AdapterRegList[$i][1] ;adapter regkey
			$Adapters[$Adapters[0][0]][3] = $AdapterRegList[$i][2] ;virtual mac
		Next
	EndIf
	Return $Adapters
EndFunc   ;==>GetAdaptersList

;------------------------------------------------------------------------------------------------------------
Func GetAdapterRegKey($Adapter = "")
	Local $RetVal[2]
	Local $NetKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
	If @OSType = "WIN32_WINDOWS" Then
		$NetKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\System\CurrentControlSet\Services\Class\Net"
	EndIf
	Local $i = 0
	While 1
		$i += 1
		Local $Key = RegEnumKey($NetKey, $i)
		If @error <> 0 Then ExitLoop
		Local $AdapterKey = $NetKey & "\" & $Key
		Local $j = 0
		While 1
			$j += 1
			Local $Value = RegEnumVal($AdapterKey, $j)
			If @error <> 0 Then ExitLoop
			If $Value = "DriverDesc" Then
				If $Adapter <> "" Then
					;vai retornar somente o adaptador que pedi
					If $Adapter = RegRead($AdapterKey, $Value) Then
						$RetVal[0] = $AdapterKey
						$RetVal[1] = RegRead($AdapterKey, "networkaddress")
						ExitLoop
					EndIf
				Else
					;retorne a lista com os adaptadores
					ReDim $RetVal[$i + 1][3]
					$RetVal[0][0] = $i
					$RetVal[$i][0] = RegRead($AdapterKey, $Value)
					$RetVal[$i][1] = $AdapterKey
					$RetVal[$i][2] = RegRead($AdapterKey, "networkaddress")
				EndIf
			EndIf
		WEnd
	WEnd
	Return $RetVal
EndFunc   ;==>GetAdapterRegKey

Func _SetCmpIP($LanID, $setIP, $setZW, $setWG, $setDNS)
	;======================================================
	; 函数名称:       _SetCmpIP($AdapterID,$strComputerName,$setIP,$setZW,$setWG,$setDNS)
	; 详细信息:        修改机器IP
	; $LanID 网卡ID
	; $setIP 机器IP
	; $setZW 子网掩码
	; $setWG 默认网关 如 8.8.8.8,8.8.4.4
	;======================================================
	$SetKey1 = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet001\"
	$SetKey2 = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\ControlSet002\"
	$CtrlKey = "HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\"
	$LanReg1 = $SetKey1 & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	$LanReg2 = $SetKey2 & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	$LanReg3 = $CtrlKey & "Services\Tcpip\Parameters\Interfaces\" & $LanID
	;通过注册表修改网卡自动获取IP为固定IP
	RegWrite($LanReg3, "EnableDHCP", "REG_DWORD", "0")
	;通过注册表修改IP
	RegWrite($LanReg1, "IPAddress", "REG_MULTI_SZ", $setIP)
	RegWrite($LanReg2, "IPAddress", "REG_MULTI_SZ", $setIP)
	RegWrite($LanReg3, "IPAddress", "REG_MULTI_SZ", $setIP)
	;通过注册表修改子网掩码
	RegWrite($LanReg1, "SubnetMask", "REG_MULTI_SZ", $setZW)
	RegWrite($LanReg2, "SubnetMask", "REG_MULTI_SZ", $setZW)
	RegWrite($LanReg3, "SubnetMask", "REG_MULTI_SZ", $setZW)
	;通过注册表修改网关
	RegWrite($LanReg1, "DefaultGateway", "REG_MULTI_SZ", $setWG)
	RegWrite($LanReg2, "DefaultGateway", "REG_MULTI_SZ", $setWG)
	RegWrite($LanReg3, "DefaultGateway", "REG_MULTI_SZ", $setWG)

	;通过注册表修改DNS
	RegWrite($LanReg1, "NameServer", "REG_SZ", $setDNS)
	RegWrite($LanReg2, "NameServer", "REG_SZ", $setDNS)
	RegWrite($LanReg3, "NameServer", "REG_SZ", $setDNS)
	_ForceUpdate()
EndFunc   ;==>_SetCmpIP

;------------------------------------------------------------------------------------------------------------
Func GuiClearMac()
	For $i = 0 To 5
		GUICtrlSetData(Eval('txtMac' & $i), '')
	Next
EndFunc   ;==>GuiClearMac

;------------------------------------------------------------------------------------------------------------
Func GuiCheckHex()
	Local $data = GUICtrlRead(@GUI_CtrlId)
	Dec($data)
	If @error Then
		GUICtrlSetData(@GUI_CtrlId, "")
	Else
		GUICtrlSetData(@GUI_CtrlId, StringUpper($data))
	EndIf
EndFunc   ;==>GuiCheckHex

;------------------------------------------------------------------------------------------------------------
Func GuiRestoreMac()
	GuiClearMac()
	GuiChangeMac()
EndFunc   ;==>GuiRestoreMac

;------------------------------------------------------------------------------------------------------------
Func GuiChangeMac()
	Local $NewMac = GUICtrlRead($txtMac0) & GUICtrlRead($txtMac1) & GUICtrlRead($txtMac2) & GUICtrlRead($txtMac3) & GUICtrlRead($txtMac4) & GUICtrlRead($txtMac5)
	Local $MacLen = StringLen($NewMac)
	If $MacLen = 12 Or $MacLen = 0 Then
		If WriteNewMac($AdapterList, GUICtrlRead($cboAdapters), $NewMac) Then
			$AdapterList = GetAdaptersList()
			GuiShowMac()
			MsgBox(0, '提示', '修改Mac地址成功，可能需要重启才可生效！', 5)
		EndIf
	Else
		MsgBox(16, "错误", "新的MAC地址必须包含12个16进制字符或者设置为空以供删除！", 5)
	EndIf
EndFunc   ;==>GuiChangeMac

;------------------------------------------------------------------------------------------------------------
Func GuiShowMac()
	$Adapter = GUICtrlRead($cboAdapters)
	GUICtrlSetBkColor($gphModified, $GUI_BKCOLOR_TRANSPARENT)
	GuiClearMac()
	If StringLen($Adapter) Then
		Local $i = 0
		For $i = 1 To $AdapterList[0][0]
			If $AdapterList[$i][0] = $Adapter Then
				If $AdapterList[$i][4] = '' Then
					_GUICtrlIpAddress_Set($MacIp, '0.0.0.0')
				Else
					_GUICtrlIpAddress_Set($MacIp, $AdapterList[$i][4])
				EndIf
				GUICtrlSetTip($cboAdapters, '修改连接[' & $AdapterList[$i][5] & ']的MAC地址信息', '说明', 1)
				Local $Mac = $AdapterList[$i][3]
				If StringLen($Mac) = 0 Then
					$Mac = $AdapterList[$i][1]
				Else
					GUICtrlSetBkColor($gphModified, 0xFF0000)
				EndIf
				$Mac = StringReplace($Mac, ":", "")
				GUICtrlSetData($txtMac0, StringMid($Mac, 1, 2))
				GUICtrlSetData($txtMac1, StringMid($Mac, 3, 2))
				GUICtrlSetData($txtMac2, StringMid($Mac, 5, 2))
				GUICtrlSetData($txtMac3, StringMid($Mac, 7, 2))
				GUICtrlSetData($txtMac4, StringMid($Mac, 9, 2))
				GUICtrlSetData($txtMac5, StringMid($Mac, 11, 2))
				ExitLoop
			EndIf
		Next
	EndIf
EndFunc   ;==>GuiShowMac

;------------------------------------------------------------------------------------------------------------
Func WriteNewMac($AdapterList, $AdapterName, $NewMac = "")
	If UBound($AdapterList) Then
		Local $i
		Local $AdapterKey = ""
		For $i = 1 To $AdapterList[0][0]
			If $AdapterList[$i][0] = $AdapterName Then
				$AdapterKey = $AdapterList[$i][2]
			EndIf
		Next
		If StringLen($AdapterKey) Then
			If StringLen($NewMac) Then
				RegWrite($AdapterKey, "networkaddress", "REG_SZ", $NewMac)
			Else
				RegDelete($AdapterKey, "networkaddress")
			EndIf
			_ForceUpdate()
			Return 1
		EndIf
	EndIf
	Return 0
EndFunc   ;==>WriteNewMac
Func _PutMacToClip()
	Local $MacStr = ''
	For $i = 0 To 5
		$MacStr &= GUICtrlRead(Eval('txtMac' & $i)) & ':'
	Next
	ClipPut(StringTrimRight($MacStr, 1))
	TrayTip('提示', 'MAC地址已经复制到剪切板上！', 3)
EndFunc   ;==>_PutMacToClip
Func MacTIp()
	If GUICtrlRead($UseBdMac[1]) = $GUI_CHECKED Then
		If Not _GUICtrlIpAddress_IsBlank($MacIp) Then
			$macadress = ''
			For $i = 0 To 5
				If $i <> 5 Then
					$macadress &= GUICtrlRead(Eval('txtMac' & $i)) & '-'
				Else
					$macadress &= GUICtrlRead(Eval('txtMac' & $i))
				EndIf
			Next
			ProcessWaitClose(Run(@ComSpec & ' /c arp -s ' & _GUICtrlIpAddress_Get($MacIp) & ' ' & $macadress, '', @SW_HIDE))
			MsgBox(0, '', 'MAC地址绑定操作执行完成！', 5)
		Else
			MsgBox(0, '', '请手工填写网卡的MAC地址后再行尝试！')
		EndIf
	Else
		If Not _GUICtrlIpAddress_IsBlank($MacIp) Then
			ProcessWaitClose(Run(@ComSpec & ' /c arp -d ' & _GUICtrlIpAddress_Get($MacIp), '', @SW_HIDE))
			MsgBox(0, '', 'MAC地址解除绑定操作执行完成！', 5)
		Else
			MsgBox(0, '', '请手工填写网卡的MAC地址后再行尝试！')
		EndIf
	EndIf
EndFunc   ;==>MacTIp
;设置控件状态
Func toogleStatus()
	If GUICtrlRead($UseBdMac[1]) = $GUI_CHECKED Then
		GUICtrlSetData($Bd, '进行MAC绑定')
		_GUICtrlIpAddress_Disable($MacIp)
	Else
		GUICtrlSetData($Bd, '解除MAC绑定')
		_GUICtrlIpAddress_Disable($MacIp, 0xf)
	EndIf
EndFunc   ;==>toogleStatus

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
;=========================================================================================
;校准系统时间
;=========================================================================================
Func _IsConnectedToInternet()
	If _WinAPI_GetVersion() < '6.0' Then
		Local $NetCon = DllCall("sensapi.dll", "int", "IsNetworkAlive", "str", $NETWORK_ALIVE_LAN)
		$x = $NetCon[0]
		If $x = 1 Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return _WinAPI_IsInternetConnected()
	EndIf
EndFunc   ;==>_IsConnectedToInternet
Func SynSysTime()
	;先判定网络是否连接，0表示断开，1表示连接
	If _IsConnectedToInternet() Then
		;预先读取时间格式
		Local $Regkey = 'HKEY_CURRENT_USER\Control Panel\International'
		Local $sShortDate = RegRead($Regkey, 'sShortDate')
		Local $sLongDate = RegRead($Regkey, 'sLongDate')
		Local $sTimeFormat = RegRead($Regkey, 'sTimeFormat')
		Local $sShortTime = RegRead($Regkey, 'sShortTime')
		;如果不是标准时间格式，那么就修改为标准时间格式
		If $sShortDate <> 'yyyy/M/d' Then
			RegWrite($Regkey, 'sShortDate', 'REG_SZ', 'yyyy/M/d')
		EndIf
		If $sLongDate <> "yyyy'年'M'月'd'日'" Then
			RegWrite($Regkey, 'sLongDate', 'REG_SZ', "yyyy'年'M'月'd'日'")
		EndIf
		If $sTimeFormat <> 'H:mm:ss' Then
			RegWrite($Regkey, 'sTimeFormat', 'REG_SZ', 'H:mm:ss')
		EndIf
		If $sShortTime <> 'H:mm' Then
			RegWrite($Regkey, 'sShortTime', 'REG_SZ', 'H:mm')
		EndIf
		;开始同步时间
		$_Now_date = _GetSrv_Date()
		$_Now_Splt = StringSplit($_Now_date, " ")
		If StringInStr($_Now_Splt[1], '/') Then
			$NowData = StringSplit($_Now_Splt[1], "/")
		Else
			$NowData = StringSplit($_Now_Splt[1], "-")
		EndIf
		$NowTime = StringSplit($_Now_Splt[2], ":")
		_SetDate($NowData[3], $NowData[2], $NowData[1])
		_SetTime($NowTime[1], $NowTime[2], $NowTime[3])
		;还原时间格式设置
		RegWrite($Regkey, 'sShortDate', 'REG_SZ', $sShortDate)
		RegWrite($Regkey, 'sLongDate', 'REG_SZ', $sLongDate)
		RegWrite($Regkey, 'sTimeFormat', 'REG_SZ', $sTimeFormat)
		RegWrite($Regkey, 'sShortTime', 'REG_SZ', $sShortTime)
		MsgBox(64, "我滴小伙伴！", "当前系统的时间已经校准完成！", 5)
	Else
		MsgBox(16, '我滴小伙伴！', '貌似当前没能连接到互联网' & @LF & '哦！所以校准不了时间！', 5)
	EndIf
EndFunc   ;==>SynSysTime

Func _GetSrv_Date()
	Local $_Srvlist[15] = ["ntp.api.bz", _
			"time-nw.nist.gov", _
			"time-a.nist.gov", _
			"time-b.nist.gov", _
			"time-a.timefreq.bldrdoc.gov", _
			"time-b.timefreq.bldrdoc.gov", _
			"time-c.timefreq.bldrdoc.gov", _
			"utcnist.colorado.edu", _
			"time.nist.gov", _
			"nist1.datum.com", _
			"nist1.dc.glassey.com", _
			"nist1.ny.glassey.com", _
			"nist1.sj.glassey.com", _
			"nist1.aol-ca.truetime.com", _
			"nist1.aol-va.truetime.com"]
	UDPStartup()
	Local $_Time_Srv
	For $x = 0 To UBound($_Srvlist) - 1
		$_Time_Srv = $_Srvlist[$x]
		Local $Socket = UDPOpen(TCPNameToIP($_Time_Srv), 123)
		If @error <> 0 Then ContinueLoop
		$status = UDPSend($Socket, MakePacket())
		If $status = 0 Then ContinueLoop
		Local $data = "", $i = 0
		While $data = ""
			$i += 1
			$data = UDPRecv($Socket, 100)
			If $i = 5 Then ContinueLoop (2)
			Sleep(88)
		WEnd
		UDPCloseSocket($Socket)
		UDPShutdown()
		ExitLoop
	Next
	If $data = "" Then Return 0
	$data = UnsignedHexToDec(StringMid($data, 83, 8))
	$data = _DateTimeFormat(_DateAdd("s", $data, "1900/01/01 08:00:00"), 0)
;~ 	ConsoleWrite('第['&$x&']个OK '&$data&@lf)
	Return $data
EndFunc   ;==>_GetSrv_Date

Func MakePacket()
	Local $P, $D = "1b0e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
	While $D
		$P &= Chr(Dec(StringLeft($D, 2)))
		$D = StringTrimLeft($D, 2)
	WEnd
	Return $P
EndFunc   ;==>MakePacket
Func _Rainymood()
	Global $FRainyMood = GUICreate("Rainymood", 133, 198, 192, 124, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $oWMP = ObjCreate("WMPlayer.OCX")
	GUICtrlCreateObj($oWMP, 0, 0, 133, 181)
	AdlibRegister("SetWMPStaus")
	Global $WMPStatus = GUICtrlCreateLabel('', 1, 181, 133, 17)
	$oWMP.URL = "https://czyt.tech/0.m4a"
	$oWMP.controls.play()
	$oWMP.stretchToFit = True
	$oWMP.windowlessVideo = True
	$oWMP.fullscreen = True
	$oWMP.uiMode = 'none'
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitRainymood')
EndFunc   ;==>_Rainymood
Func _getPlaystatus()
	If IsObj($oWMP) Then
		Switch $oWMP.playState()
;~ 		1=停止，2=暂停，3=播放，6=正在缓冲，9=正在连接，10=准备就绪
			Case 1
				Return "停止"
			Case 2
				Return "暂停[VOL:" & $oWMP.settings.volume & ']'
			Case 3
				Return "播放" & $oWMP.controls.currentPositionString()
			Case 6
				Return "正在缓冲[VOL:" & $oWMP.settings.volume & ']'
			Case 9
				Return "正在连接"
			Case 10
				Return "准备就绪"
		EndSwitch
	EndIf
EndFunc   ;==>_getPlaystatus

Func SetWMPStaus()
	GUICtrlSetData($WMPStatus, '播放状态：' & _getPlaystatus())
EndFunc   ;==>SetWMPStaus
Func QuitRainymood()
	AdlibUnRegister("SetWMPStaus")
	$oWMP = ''
	_WinAPI_AnimateWindow($FRainyMood, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FRainyMood)
EndFunc   ;==>QuitRainymood
Func UnsignedHexToDec($_Data)
	Return Dec(StringTrimRight($_Data, 1)) * 16 + Dec(StringRight($_Data, 1))
EndFunc   ;==>UnsignedHexToDec

Func _RasEnumEntries($sPhonebook)
	Local $iResult, $aResult[1][3], $tBuffer, $pBuffer, $iSizeofBuffer, $tagBuffer, $iIndex

	$tBuffer = DllStructCreate("dword;char[257];dword;char[261]")
	$pBuffer = DllStructGetPtr($tBuffer)
	$iSizeofBuffer = DllStructGetSize($tBuffer)
	DllStructSetData($tBuffer, 1, $iSizeofBuffer)

	$iResult = DllCall("rasapi32.dll", "dword", "RasEnumEntries", _
			"ptr", 0, "str", $sPhonebook, _
			"ptr", $pBuffer, "int*", $iSizeofBuffer, "int*", 0)
	$tBuffer = 0
	$aResult[0][0] = $iResult[5]
	ReDim $aResult[$iResult[5] + 1][3]
	If $iResult[5] = 0 Then Return SetError($iResult[0], 0, $aResult)

	For $i = 1 To $iResult[5]
		$tagBuffer &= "dword;char[257];dword;char[261];"
	Next

	$tBuffer = DllStructCreate($tagBuffer)
	$pBuffer = DllStructGetPtr($tBuffer)
	DllStructSetData($tBuffer, 1, $iSizeofBuffer)

	$iResult = DllCall("rasapi32.dll", "dword", "RasEnumEntries", _
			"ptr", 0, "str", $sPhonebook, _
			"ptr", $pBuffer, "int*", $iResult[4], "int*", 0)
	For $i = 2 To $iResult[5] * 4 Step 4
		$iIndex += 1
		$aResult[$iIndex][0] = DllStructGetData($tBuffer, $i)
		$aResult[$iIndex][1] = DllStructGetData($tBuffer, $i + 2)
		$aResult[$iIndex][2] = DllStructGetData($tBuffer, $i + 1)
	Next
	$tBuffer = 0
	Return SetError($iResult[0], $iResult[5], $aResult)
EndFunc   ;==>_RasEnumEntries

Func CreateDigUp()
	$sPnebk = @AppDataCommonDir & "\Microsoft\Network\Connections\Pbk\rasphone.pbk"
	$aEntry = _RasEnumEntries($sPnebk)
	If UBound($aEntry) > 1 Then
		MsgBox(16, '', '当前系统已经存在宽带连接！请检查！', 5)
	Else
		GUISetState(@SW_MINIMIZE, $Form1)
		Local $strConnectionName = '宽带连接'
		Run('rasphone.exe -a')
		If @OSBuild < 6000 Then
			WinActivate('[Class:#32770]')
			$Hwin = WinWait('[Class:#32770]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:4]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:6]')
			WinActivate($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:13]')
			FileCreateShortcut('%SystemRoot%\System32\Rasphone.exe', @DesktopDir & '\' & $strConnectionName & '.lnk', @WindowsDir, '-d "' & $strConnectionName & '"', '宽带连接，通过这个您可以使用宽带供应商为您提供的帐号和密码进行拨号上网', '%SystemRoot%\system32\netshell.dll', '', '105')
		Else
			$Hwin = WinWait('Set up a new connection', '', 5)
			WinActive($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:4]')
			WinWait($Hwin)
			WinActive($Hwin)
			WinWait($Hwin)
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:9]')
			ControlClick($Hwin, '', '[CLASS:Button; INSTANCE:1]')
			FileCreateShortcut('%SystemRoot%\System32\Rasphone.exe', @DesktopDir & '\' & $strConnectionName & '.lnk', @WindowsDir, '-d "' & $strConnectionName & '"', '宽带连接，通过这个您可以使用宽带供应商为您提供的帐号和密码进行拨号上网', '%SystemRoot%\system32\netshell.dll', '', '105')
		EndIf
		MsgBox(0, '提示', '成功创建宽带连接！', 5)
		GUISetState(@SW_RESTORE, $Form1)
	EndIf
EndFunc   ;==>CreateDigUp
Func _GetRemoteDeskPort()
	Local $port = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp', 'PortNumber')
	If Not @error Then
		Return $port
	EndIf
EndFunc   ;==>_GetRemoteDeskPort
Func _IsFirewallOpen()
	$fwMgr = ObjCreate("HNetCfg.FwMgr")
	$profile = $fwMgr.LocalPolicy.CurrentProfile
	$isOpen = $profile.FirewallEnabled
	$fwMgr = 0
	Return $isOpen
EndFunc   ;==>_IsFirewallOpen
Func ChangeTerminPort()
	Local $port = _GetRemoteDeskPort()
	Global $FChangeTerminPort = _GUICreate("远程桌面端口修改器", 430, 65, 64, 120, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("当前远程桌面端口", 9, 0, 143, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $oldport = GUICtrlCreateLabel($port, 16, 16, 124, 17, BitOR($SS_CENTER, $SS_CENTERIMAGE, $WS_BORDER))
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("修改为端口", 160, 0, 137, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $NewPort = GUICtrlCreateInput($port, 168, 16, 121, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_NUMBER))
	GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0xFF0000)
	GUICtrlSetResizing(-1, $GUI_DOCKHCENTER + $GUI_DOCKHEIGHT)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("修改", 304, 8, 115, 33)
	GUICtrlSetOnEvent(-1, 'ChangeTermPortNum')
	Global $TakeEffNow = _GUICtrlCreateCheckbox("立即生效", 8, 45, 70, 17)
	GUICtrlSetTip(-1, '勾选此项目将立即生效，但会注销所有的远程登录会话。', '提示', 1)
	If _IsFirewallOpen() Then
		Global $addRuleinfw = _GUICtrlCreateCheckbox("在系统防火墙添加开放端口的防火墙规则", 81, 45, 312, 17)
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTerminChange')
EndFunc   ;==>ChangeTerminPort
Func QuitTerminChange()
	_WinAPI_AnimateWindow($FChangeTerminPort, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FChangeTerminPort)
EndFunc   ;==>QuitTerminChange
Func ChangeTermPortNum()
	Local $oldPortNum = GUICtrlRead($oldport)
	Local $NewPortNum = GUICtrlRead($NewPort)
	If $NewPortNum <> $oldPortNum Then
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp', 'PortNumber', 'REG_DWORD', $NewPortNum)
		RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentContro1Set\Control\Terminal Server\WinStations\RDP-Tcp', 'PortNumber', 'REG_DWORD', $NewPortNum)
		If _IsFirewallOpen() Then
			RunWait(@ComSpec & ' /c netsh advfirewall firewall delete rule name="WindowsNTRDP"', @WindowsDir, @SW_HIDE)
			If GUICtrlRead($addRuleinfw) = $GUI_CHECKED Then
				RunWait(@ComSpec & ' /c netsh advfirewall firewall add rule name="WindowsNTRDP" dir=in action=allow protocol=TCP localport=' & $NewPortNum, @WindowsDir, @SW_HIDE)
			EndIf
			If GUICtrlRead($TakeEffNow) = $GUI_CHECKED Then
				Run(@ComSpec & ' /c logoff rdp-tcp ', @WindowsDir, @SW_HIDE)
			EndIf
		EndIf
		_ForceUpdate()
		GUICtrlSetData($oldport, $NewPortNum)
		MsgBox(0, '', '已经成功修改远程桌面端口！！', 5)
	Else
		MsgBox(0, '', '未对端口号进行更改！！', 5)
	EndIf
EndFunc   ;==>ChangeTermPortNum
Func _FormRegJump()
	Global $FormRegJump = _GUICreate("注册表一键跳转", 506, 80, 35, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("注册表键值", 8, 0, 481, 41)
	Global $RegKeyToJmp = GUICtrlCreateInput("", 16, 16, 465, 21)
	GUICtrlSetResizing(-1, $GUI_DOCKAUTO + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("跳转到注册表项目", 8, 48, 483, 25)
	GUICtrlSetOnEvent(-1, 'JumpToKey')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitRegJump')
EndFunc   ;==>_FormRegJump
Func QuitRegJump()
	_WinAPI_AnimateWindow($FormRegJump, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormRegJump)
EndFunc   ;==>QuitRegJump
Func JumpToKey()
	$Key = GUICtrlRead($RegKeyToJmp)
	If $RegKeyToJmp <> '' Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit', 'LastKey', 'REG_SZ', $Key)
		Run('regedit -m')
	EndIf
EndFunc   ;==>JumpToKey
Func _NetUserChangeName($sUserName, $sNewName, $sSystem = "")
	Local $iResult, $tName, $pName, $tUserName, $pUserName
	$tName = DllStructCreate("wchar[256]")
	$pName = DllStructGetPtr($tName)
	DllStructSetData($tName, 1, $sNewName)
	$tUserName = DllStructCreate("ptr")
	$pUserName = DllStructGetPtr($tUserName)
	DllStructSetData($tUserName, 1, $pName)
	$iResult = DllCall("netapi32.dll", "dword", "NetUserSetInfo", _
			"wstr", $sSystem, "wstr", $sUserName, _
			"dword", 0, "ptr", $pUserName, "int*", 0)
	$tName = 0
	$tUserName = 0
	Return SetError($iResult[0], 0, $iResult[0] = 0)
EndFunc   ;==>_NetUserChangeName
Func _SetUserFullName($UserName, $FullName)
	If $FullName <> '' Then
		$objuser = ObjGet("WinNT://" & @ComputerName & "/" & $UserName & ",User")
		$objuser.FullName = $FullName
		$objuser.SetInfo
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_SetUserFullName
Func _SetUserDesc($UserName, $Desc)
	If $Desc <> '' Then
		$objuser = ObjGet("WinNT://" & @ComputerName & "/" & $UserName & ",User")
		$objuser.Description = $Desc
		$objuser.SetInfo
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_SetUserDesc
Func _NetUserSetPassword($sUserName, $sPassword, $sSystem = "")
	Local $iResult, $tName, $pName, $tUserName, $pUserName
	$tName = DllStructCreate("wchar[256]")
	$pName = DllStructGetPtr($tName)
	DllStructSetData($tName, 1, $sPassword)
	$tUserName = DllStructCreate("ptr")
	$pUserName = DllStructGetPtr($tUserName)
	DllStructSetData($tUserName, 1, $pName)
	$iResult = DllCall("netapi32.dll", "dword", "NetUserSetInfo", _
			"wstr", $sSystem, "wstr", $sUserName, _
			"dword", 1003, "ptr", $pUserName, "int*", 0)
	$tName = 0
	$tUserName = 0
	Return SetError($iResult[0], 0, $iResult[0] = 0)
EndFunc   ;==>_NetUserSetPassword
Func _LoadUserNameToArray()
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $colItems = "", $sUserList = ''
	Local $strComputer = "localhost"
	Local $objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\CIMV2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_UserAccount", "WQL", _
			$wbemFlagReturnImmediately + $wbemFlagForwardOnly)

	If IsObj($colItems) Then
		Local $i = 0
		For $objItem In $colItems
			ReDim $aUserInfo[$i + 1][4]
			$aUserInfo[$i][0] = $objItem.Name
			$aUserInfo[$i][1] = $objItem.Disabled
			$aUserInfo[$i][2] = $objItem.FullName
			$aUserInfo[$i][3] = $objItem.Description
			$i += 1
		Next
	EndIf

	For $i = 0 To UBound($aUserInfo) - 1
		$sUserList &= $aUserInfo[$i][0] & '|'
	Next
	GUICtrlSetData($ComboUserList, '')
	GUICtrlSetData($ComboUserList, $sUserList)
	_GUICtrlComboBox_SetCurSel($ComboUserList, 0)
	_loadUserNameToEdit()
EndFunc   ;==>_LoadUserNameToArray
Func _loadUserNameToEdit()
	Local $sUserName = GUICtrlRead($ComboUserList)
	GUICtrlSetData($NewUserName, $sUserName)
	For $i = 0 To UBound($aUserInfo) - 1
		If $aUserInfo[$i][0] = $sUserName Then
			If $aUserInfo[$i][1] = True Then
				GUICtrlSetTip($ComboUserList, '该用户帐号在当前系统被禁用，修改后请' & @LF & '在系统中启用该用户帐号~', '警告', 2, 2)
				GUICtrlSetColor($NewUserName, 0xFFFFFF)
				GUICtrlSetBkColor($NewUserName, 0xFF0000)
				If $aUserInfo[$i][2] <> '' Then
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为[' & $aUserInfo[$i][2] & ']！', '说明', 1)
				Else
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为空！', '说明', 1)
				EndIf
				GUICtrlSetData($UserDesc, StringStripWS($aUserInfo[$i][3], 1 + 2))
			Else
				GUICtrlSetTip($ComboUserList, '修改将立即生效至当前选择用户帐号~', '提示', 1, 2)
				GUICtrlSetColor($NewUserName, 0x000000)
				GUICtrlSetBkColor($NewUserName, 0xFFFFFF)
				If $aUserInfo[$i][2] <> '' Then
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为[' & $aUserInfo[$i][2] & ']！', '说明', 1)
				Else
					GUICtrlSetTip($ChangeUserFullNameOnly, '用户全名为登录界面显示的名称，所' & @LF & '选账户的用户全名为空！', '说明', 1)
				EndIf
				GUICtrlSetData($UserDesc, StringStripWS($aUserInfo[$i][3], 1 + 2))
			EndIf
		EndIf
	Next
EndFunc   ;==>_loadUserNameToEdit
;=========================================================================================
; 网络唤醒
;=========================================================================================
Func WOLUI()
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $WOL = _GUICreate("网络唤醒", 349, 114, 130, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("任务设定", 16, 8, 89, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$RdWOL[1] = _GUICtrlCreateRadio("单个唤醒", 24, 24, 72, 17)
	GUICtrlSetState($RdWOL[1], $GUI_CHECKED)
	GUICtrlSetOnEvent($RdWOL[1], 'ToogleWOLTaskType')
	$RdWOL[2] = _GUICtrlCreateRadio("批量唤醒", 24, 40, 72, 17)
	GUICtrlSetOnEvent($RdWOL[2], 'ToogleWOLTaskType')
	Global $MacToWOL = GUICtrlCreateInput("", 112, 40, 177, 21)
	Global $WOLLabel = GUICtrlCreateLabel("请输入要唤醒的计算机MAC地址", 112, 16, 220, 17)
	Global $WOLStatusLabel = GUICtrlCreateLabel("", 8, 100, 220, 18)
	Global $LocateMacFile = GUICtrlCreateButton("...", 296, 40, 43, 21)
	GUICtrlSetState(-1, $GUI_HIDE)
	GUICtrlSetTip(-1, '请选择包含要网络唤醒的计算机' & @LF & '的MAC地址的文件，每行一个MAC' & @LF & '地址,MAC地址可以是使用:或-进' & @LF & '行分割，也可以是无分割的', '提示', 1)
	GUICtrlSetOnEvent(-1, 'SelectMACFile')
	Global $startWOL = GUICtrlCreateButton("开始唤醒操作[&W]", 16, 72, 131, 25)
	GUICtrlSetOnEvent(-1, 'WOLMain')
	GUICtrlCreateButton("关闭[&Q]", 177, 73, 131, 25)
	GUICtrlSetOnEvent(-1, 'QuitWOL')
	GUISetState(@SW_SHOW, $WOL)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWOL', $WOL)
EndFunc   ;==>WOLUI

Func QuitWOL()
	_WinAPI_AnimateWindow($WOL, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($WOL)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitWOL

;切换单个任务和多个任务状态
Func ToogleWOLTaskType()
	Switch GUICtrlRead($RdWOL[1])
		Case $GUI_CHECKED
			GUICtrlSetData($MacToWOL, '')
			GUICtrlSetData($WOLLabel, '请输入要唤醒的计算机MAC地址')
			GUICtrlSetState($LocateMacFile, $GUI_HIDE)
			GUICtrlSetState($MacToWOL, $GUI_NODROPACCEPTED)
		Case $GUI_UNCHECKED
			GUICtrlSetData($MacToWOL, '')
			GUICtrlSetData($WOLLabel, '请选择包含要唤醒计算机MAC地址的文件')
			GUICtrlSetState($LocateMacFile, $GUI_SHOW)
			GUICtrlSetState($MacToWOL, $GUI_DROPACCEPTED)
	EndSwitch
EndFunc   ;==>ToogleWOLTaskType
;选择包含MAC地址的文本文件
Func SelectMACFile()
	Local $File = FileOpenDialog('请选择包含计算机MAC地址的文件', '', '所有支持的文件(*.*)')
	If FileExists($File) Then GUICtrlSetData($MacToWOL, $File)
EndFunc   ;==>SelectMACFile
; 网络唤醒
Func WOLMain()
	Local $macSome = GUICtrlRead($MacToWOL)
	If $macSome <> '' Then
		GUICtrlSetState($LocateMacFile, $GUI_DISABLE)
		GUICtrlSetState($RdWOL[1], $GUI_DISABLE)
		GUICtrlSetState($RdWOL[2], $GUI_DISABLE)
		GUICtrlSetState($MacToWOL, $GUI_DISABLE)
		GUICtrlSetState($startWOL, $GUI_DISABLE)
		Switch GUICtrlRead($RdWOL[1])
			Case $GUI_CHECKED
				_WOL($macSome)
			Case $GUI_UNCHECKED
				If FileExists($macSome) Then
					Local $macArry
					_FileReadToArray($macSome, $macArry)
					If Not @error Then
						_ArrayDelete($macArry, 0)
						If UBound($macArry) > 0 Then
							_WOL($macArry)
						EndIf
					EndIf
				EndIf
		EndSwitch
		GUICtrlSetState($LocateMacFile, $GUI_ENABLE)
		GUICtrlSetState($RdWOL[1], $GUI_ENABLE)
		GUICtrlSetState($RdWOL[2], $GUI_ENABLE)
		GUICtrlSetState($MacToWOL, $GUI_ENABLE)
		GUICtrlSetState($startWOL, $GUI_ENABLE)
		GUICtrlSetData($WOLStatusLabel, '')
		MsgBox(0, '嘻嘻', '成功执行网络唤醒操作!', 5, $WOL)
	Else
		MsgBox(16, '提示', GUICtrlRead($WOLLabel), 5, $WOL)
	EndIf
EndFunc   ;==>WOLMain

;核心函数
; ===================================================================
; 函数 *=== 此功能返回生成 "数据包" ===*
; ===================================================================
Func GenerateMagicPacket($strMACAddress)
	$MagicPacket = Binary("0xFFFFFFFFFFFF")
	For $P = 1 To 16 ;
		$MagicPacket &= $strMACAddress
	Next
	$MagicPacket &= ("000000000000") ;最后6个字节是密码，没有密码的话可以0x00填充
;~ 	ConsoleWrite($MagicPacket & @CRLF)
	Return $MagicPacket
EndFunc   ;==>GenerateMagicPacket

; ===================================================================
; 网络唤醒
;功能说明 数组形式传递MAC，可以一次唤醒多机 直接唤醒一台机的MAC
; MAC格式支持:跟-分隔符的，或是不带分隔符的
;参数 $mac MAC格式的字符串或是数组都可以，程序自动识别 $port，程序运行端口，
;错误返回 0为网络错误
; -1参数不对
; -2MAC格式不对
; ===================================================================
Func _WOL($Mac, $port = 7)
	$IPAddress = "255.255.255.255" ; 这是广播地址 !
	UDPStartup() ;开始 UDP 服务.
	$connexion = UDPOpen($IPAddress, $port, 1) ;连接到服务器进行会话,port为7赋给变量"$connexion"
	If $connexion[0] == 0 Then Return ;如果出错则返回 @error: windows API WSAGetError 返回值

	If IsArray($Mac) Then
		$dims = UBound($Mac, 0)
		If $dims > 1 Then Return -1 ;参数不对

		For $element In $Mac
			ConsoleWrite($element & @CRLF)
			$element = StringReplace($element, ":", "")
			$element = StringReplace($element, "-", "")
			$strLen = StringLen($element)
			If StringIsXDigit($element) And $strLen < 13 Then
				GUICtrlSetData($WOLStatusLabel, '正在网络唤醒MAC地址为[' & $element & ']的计算机..')
				$res = UDPSend($connexion, GenerateMagicPacket($element)) ;打开的套接字(socket)上面发送数据,GenerateMagicPacket($MACAddress)调用函数
			Else
				GUICtrlSetData($WOLStatusLabel, 'MAC地址[' & $element & ']错误，无法执行唤醒操作..')
				Return -2 ;MAC格式不对
			EndIf
		Next
	Else
		$Mac = StringReplace($Mac, ":", "")
		$Mac = StringReplace($Mac, "-", "")
		$strLen = StringLen($Mac)
		ConsoleWrite($Mac & @CRLF)
		If StringIsXDigit($Mac) And $strLen < 13 Then
			GUICtrlSetData($WOLStatusLabel, '正在网络唤醒MAC地址为[' & $Mac & ']的计算机..')
			$res = UDPSend($connexion, GenerateMagicPacket($Mac)) ;打开的套接字(socket)上面发送数据,GenerateMagicPacket($MACAddress)调用函数
		Else
			GUICtrlSetData($WOLStatusLabel, 'MAC地址[' & $Mac & ']错误，无法执行唤醒操作..')
			Return -2 ;MAC格式不对
		EndIf
	EndIf

EndFunc   ;==>_WOL

Func VirtualDrive()
	FileInstall('file\virtualdrivemaster.sfx.exe', @TempDir & '\', 1)
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
Func OneKeySetShareUI()
	Global $FSetShare = _GUICreate("一键共享开关", 237, 45, 186, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("开启网络共享", 16, 8, 100, 25)
	GUICtrlSetOnEvent(-1, '_OpenShare')
	GUICtrlCreateButton("关闭网络共享", 129, 8, 100, 25)
	GUICtrlSetOnEvent(-1, '_CloseShare')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitFsetShare')
EndFunc   ;==>OneKeySetShareUI

Func _QuitFsetShare()
	_WinAPI_AnimateWindow($FSetShare, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FSetShare)
EndFunc   ;==>_QuitFsetShare

Func _OpenShare()
	Switch @OSVersion
		Case "WIN_2008R2" Or "WIN_7" Or "WIN_2008" Or "WIN_VISTA"
			Run(@ComSpec & ' /c  sc config nsi start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start nsi ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config DcomLaunch start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start DcomLaunch ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RpcEptMapper start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcEptMapper ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RpcSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SamSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SamSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lanmanworkstation start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lanmanworkstation ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dnscache start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dnscache ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dhcp start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dhcp ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config NlaSvc start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start NlaSvc ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config netprofm start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start netprofm ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config fdPHost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start fdPHost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config FDResPub start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start FDResPub ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config HomeGroupProvider start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start HomeGroupProvider ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config HomeGroupListener start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start HomeGroupListener ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Netman start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Netman ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lmhosts start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lmhosts ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Spooler start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Spooler ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SSDPSRV start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SSDPSRV ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config upnphost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start upnphost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh advfirewall set allprofiles state off ', @WindowsDir & '\', @SW_HIDE)
			ShareComm()
		Case "WIN_2003" Or "WIN_XP"
			Run(@ComSpec & ' /c  sc config RpcSs start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RpcSs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lanmanworkstation start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lanmanworkstation ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config PlugPlay start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start PlugPlay ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config TapiSrv start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start TapiSrv ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config RasMan start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start RasMan ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Netman start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Netman ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dnscache start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dnscache ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Dhcp start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Dhcp ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config lmhosts start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start lmhosts ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Nla start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Nla ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Spooler start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start Spooler ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config SSDPSRV start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start SSDPSRV ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config upnphost start= auto ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net start upnphost ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh firewall set opmode mode=disable ', @WindowsDir & '\', @SW_HIDE)
			ShareComm()
	EndSwitch
	MsgBox(0, '提示', '执行开启共享操作完成！！', 5)
EndFunc   ;==>_OpenShare
Func _CloseShare()
	Local $drive = DriveGetDrive("FIXED")
	Run(@ComSpec & ' /c net share admin$ /del', '', @SW_HIDE)
	Run(@ComSpec & ' /c net share IPC$ /del', '', @SW_HIDE)
	For $i In $drive
		If StringInStr($i, ':') Then
			Run(@ComSpec & ' /c net share ' & StringReplace($i, ':', '$') & ' /del', '', @SW_HIDE)
		EndIf
	Next
	Switch @OSVersion
		Case "WIN_2008R2" Or "WIN_7" Or "WIN_2008" Or "WIN_VISTA"
			Run(@ComSpec & ' /c  sc config HomeGroupListener start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop HomeGroupListener ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh advfirewall set allprofiles state on ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config Browser start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop Browser ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  sc config LanmanServer start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop LanmanServer ', @WindowsDir & '\', @SW_HIDE)
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'AutoShareServer', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'AutoShareWks', 'REG_DWORD', '00000000')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters', 'restrictnullsessaccess', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Terminal Server', 'fDenyTSConnections', 'REG_DWORD', '00000001')
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
		Case "WIN_2003" Or "WIN_XP"
			RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000001')
			Run(@ComSpec & ' /c  sc config dfs start= disabled ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  net stop dfs ', @WindowsDir & '\', @SW_HIDE)
			Run(@ComSpec & ' /c  netsh firewall set opmode mode=enable ', @WindowsDir & '\', @SW_HIDE)
	EndSwitch
	MsgBox(0, '提示', '执行关闭共享操作完成！！', 5)
EndFunc   ;==>_CloseShare
;通用代码
Func ShareComm()
	FileInstall('file\ntrights.exe', @WindowsDir & '\', 1)
	Run(@ComSpec & ' /c  sc config ALG start= disabled ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net stop ALG ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net start w32time ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  w32tm /resync ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net user guest /active ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  Ntrights.exe -u Guest +r SeNetworkLogonRight ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  Ntrights.exe -u Guest -r SeDenyNetworkLogonRight ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  net config server /hidden:no ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  regsvr32 /s atl.dll ', @WindowsDir & '\', @SW_HIDE)
	Run(@ComSpec & ' /c  regsvr32 /s netshell.dll ', @WindowsDir & '\', @SW_HIDE)
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'forceguest', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'everyoneincludesanonymous', 'REG_DWORD', '00000001')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'NoLmHash', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa', 'restrictanonymoussam', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\System\CurrentControlSet\Services\LanManServer\Parameters', 'restrictnullsessaccess', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Browser\Parameters', 'MaintainServerList', 'REG_SZ', 'Auto')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Services\Browser\Parameters', 'IsDomainMaster', 'REG_SZ', 'FALSE')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa', 'limitblankpassworduse', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa', 'restrictanonymous', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0', 'NtlmMinClientSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0', 'NtlmMinServerSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa\MSV1_0', 'NtlmMinClientSec', 'REG_DWORD', '00000000')
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SYSTEM\ControlSet001\Control\Lsa\MSV1_0', 'NtlmMinServerSec', 'REG_DWORD', '00000000')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{2227A280-3AEA-1069-A2DE-08002B30309D}')
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RemoteComputer\NameSpace\{D6277990-4C6A-11CF-8D87-00AA0060F5BF}')
	If ProcessExists('ntrights.exe') Then Run(@ComSpec & ' /c tsakkill /f/im "ntrights.exe"', @WindowsDir, @SW_HIDE)
	FileDelete(@WindowsDir & '\ntrights.exe')
EndFunc   ;==>ShareComm

Func ExplorerDirManager()
	Global $FW81DirSet = _GUICreate('Windows X"这台电脑"文件夹一键设置', 349, 127, 130, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("操作类型", 8, 8, 121, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$win81dirOp[1] = _GUICtrlCreateRadio("移除", 16, 32, 47, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$win81dirOp[2] = _GUICtrlCreateRadio("恢复", 64, 32, 49, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("效果范围", 8, 64, 121, 57)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$win81dirOp[3] = _GUICtrlCreateCheckbox("这台电脑", 13, 80, 105, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$win81dirOp[4] = _GUICtrlCreateCheckbox("导航窗口", 13, 99, 105, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("操作内容", 136, 8, 161, 81)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$W81Dir[1] = _GUICtrlCreateCheckbox("视频", 144, 24, 49, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[2] = _GUICtrlCreateCheckbox("图片", 200, 24, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[3] = _GUICtrlCreateCheckbox("文档", 144, 48, 49, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[4] = _GUICtrlCreateCheckbox("下载", 200, 48, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[5] = _GUICtrlCreateCheckbox("音乐", 248, 24, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	$W81Dir[6] = _GUICtrlCreateCheckbox("桌面", 248, 48, 41, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	If @OSBuild >= 16226 Then
		ReDim $W81Dir[UBound($W81Dir) + 1]
		$W81Dir[7] = _GUICtrlCreateCheckbox("3D对象", 144, 72, 57, 17)
		GUICtrlSetState(-1, $GUI_CHECKED)
	EndIf
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$selectW81ALL = _GUICtrlCreateRadio("全选", 304, 16, 41, 17)
	GUICtrlSetOnEvent($selectW81ALL, 'W81DirCheckAll')
	GUICtrlSetState(-1, $GUI_CHECKED)
	$ReverseSelcetW81 = _GUICtrlCreateRadio("反选", 304, 40, 41, 17)
	GUICtrlSetOnEvent($ReverseSelcetW81, 'W81Dirreverse')
	GUICtrlCreateButton("应用设置[&A]", 136, 96, 203, 26)
	GUICtrlSetOnEvent(-1, 'W81DirTweak')
;~ 	GUICtrlCreateButton("退出", 264, 64, 75, 25)
;~ 	GUICtrlSetOnEvent(-1, 'QuitDirForm')
	GUISetState(@SW_SHOW, $FW81DirSet)
	W81DirCheckAll()
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitDirForm', $FW81DirSet)
EndFunc   ;==>ExplorerDirManager

Func QuitDirForm()
	_WinAPI_AnimateWindow($FW81DirSet, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FW81DirSet)
EndFunc   ;==>QuitDirForm

Func W81DirTweak()
	If MsgBox(4, '提示', '是否应用当前勾选设置项？', 5) = 6 Then
		Local $aReg[2] = ["HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace", "HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"]
		Local $aRegWin10[2] = ['HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions', 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions']
		Local $aNameSpaceStr[6] = ["{A0953C92-50DC-43bf-BE83-3742FED03C9C}", "{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}", "{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}", "{374DE290-123F-4565-9164-39C4925E467B}", "{1CF1260C-4DD0-4ebb-811F-33C572699FDE}", "{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"]
		Local $aNamespaceWin10Str[7] = ['{35286a68-3c57-41a1-bbb1-0eae73d76c95}', '{0ddd015d-b06c-45d5-8c4c-f59713854639}', '{f42ee2d3-909f-4907-8871-4c22fc0bf756}', '{7d83ee9b-2244-4e70-b1f5-5393042af1e4}', '{a0c69a99-21c8-4671-8703-7934162fcf1d}', '{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}', '{31C0DD25-9439-4F12-BF41-7FF4EDA38722}']
		;隐藏
		If GUICtrlRead($win81dirOp[1]) = $GUI_CHECKED Then
			For $j = 1 To @OSBuild >= 16226 ? 7 : 6
				If GUICtrlRead($W81Dir[$j]) = $GUI_CHECKED Then
					If @OSVersion = 'WIN_81' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegDelete($aReg[0] & '\' & $aNameSpaceStr[$j - 1])
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegDelete($aReg[1] & '\' & $aNameSpaceStr[$j - 1])
					EndIf
					If @OSVersion = 'WIN_10' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aRegWin10[0] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Hide')
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aRegWin10[1] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Hide')

					EndIf
				EndIf
			Next
		EndIf
		;显示
		If GUICtrlRead($win81dirOp[2]) = $GUI_CHECKED Then
			For $j = 1 To @OSBuild >= 16232 ? 7 : 6
				If GUICtrlRead($W81Dir[$j]) = $GUI_CHECKED Then
					If @OSVersion = 'WIN_81' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aReg[0] & '\' & $aNameSpaceStr[$j - 1])
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aReg[1] & '\' & $aNameSpaceStr[$j - 1])
					EndIf
					If @OSVersion = 'WIN_10' Then
						If GUICtrlRead($win81dirOp[3]) = $GUI_CHECKED Then RegWrite($aRegWin10[0] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Show')
						If GUICtrlRead($win81dirOp[4]) = $GUI_CHECKED Then RegWrite($aRegWin10[1] & '\' & $aNamespaceWin10Str[$j - 1] & '\PropertyBag', 'ThisPCPolicy', 'REG_SZ', 'Show')
					EndIf
				EndIf
			Next
		EndIf
		_ForceUpdate()
		MsgBox(0, '提示', '所选设定已经成功应用到当前系统', 5)
	EndIf
EndFunc   ;==>W81DirTweak


Func NCSIServerUI()
	Global $FormNCSIServerForm = _GUICreate("windows NCSI服务器设置", 351, 123, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择NCSI服务器", 16, 8, 273, 65)
	_removeEffect()
	Global $OptMicroSoft = GUICtrlCreateRadio("microsoft", 32, 32, 65, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $OptDebian = GUICtrlCreateRadio("debian", 120, 32, 65, 17)
	Global $OptFirefox = GUICtrlCreateRadio("firefox", 208, 32, 65, 17)
	GUICtrlCreateButton("设置NCSI服务器", 48, 80, 211, 25)
	GUICtrlSetOnEvent(-1, 'ApplyNCSISetting')
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitNCSIUI')
EndFunc   ;==>NCSIServerUI

Func ApplyNCSISetting()
	If GUICtrlRead($OptMicroSoft) = $GUI_CHECKED Then
		microsoftNCSI()
	EndIf
	If GUICtrlRead($OptDebian) = $GUI_CHECKED Then
		debianNCSI()
	EndIf
	If GUICtrlRead($OptFirefox) = $GUI_CHECKED Then
		firefoxNCSI()
	EndIf

EndFunc   ;==>ApplyNCSISetting

Func debianNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "208.67.222.222")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "2620:119:35::35")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "NetworkManager is online")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "NetworkManager is online")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "network-test.debian.org")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "network-test.debian.org")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "nm")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "nm")
	MsgBox(0, '提示', '所选Debian NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>debianNCSI

Func microsoftNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "131.107.255.255")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "fd3e:4f5a:5b81::1")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "dns.msftncsi.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "dns.msftncsi.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "Microsoft Connect Test")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "Microsoft Connect Test")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "www.msftconnecttest.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "ipv6.msftconnecttest.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "connecttest.txt")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "connecttest.txt")
	MsgBox(0, '提示', '所选Microsoft NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>microsoftNCSI

Func firefoxNCSI()
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContent", "REG_SZ", "208.67.222.222")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeContentV6", "REG_SZ", "2620:119:35::35")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHost", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveDnsProbeHostV6", "REG_SZ", "resolver1.opendns.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContent", "REG_SZ", "success")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeContentV6", "REG_SZ", "success")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHost", "REG_SZ", "detectportal.firefox.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbeHostV6", "REG_SZ", "detectportal.firefox.com")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePath", "REG_SZ", "success.txt")
	RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet", "ActiveWebProbePathV6", "REG_SZ", "success.txt")
	MsgBox(0, '提示', '所选Firefox NCSI设置已经成功应用到当前系统', 5)
EndFunc   ;==>firefoxNCSI

Func QuitNCSIUI()
	_WinAPI_AnimateWindow($FormNCSIServerForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($OptMicroSoft)
	GUIDelete($OptFirefox)
	GUIDelete($OptDebian)
EndFunc   ;==>QuitNCSIUI

Func ReleseCacheUI()
	Global $FormReleaseCache = _GUICreate("释放Windows8.1更新缓存", 380, 89, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $StartReleaseCache = GUICtrlCreateButton("一键释放更新缓存", 8, 56, 363, 25)
	GUICtrlSetOnEvent(-1, 'ReleaseCache')
	GUICtrlSetTip(-1, "该操作不可逆，释放后将无法卸载" & @LF & "安装的Windows更新", '提示', 1, 2)
	$OptResetBase[1] = _GUICtrlCreateCheckbox("重置被取代的基本组件", 16, 24, 305, 17)
	GUICtrlSetTip(-1, "该选项可进一步减小组件存储的大" & @LF & "小，但会消耗更多的时间", '提示', 1, 2)
	GUICtrlCreateGroup("释放选项", 8, 8, 361, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFormReleaseForm')
EndFunc   ;==>ReleseCacheUI
Func QuitFormReleaseForm()
	_WinAPI_AnimateWindow($FormReleaseCache, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormReleaseCache)
EndFunc   ;==>QuitFormReleaseForm
Func ReleaseCache()
	Local $sCMD = ''
	If GUICtrlRead($OptResetBase) = $GUI_CHECKED Then
		$sCMD = 'dism /online /Cleanup-Image /startComponentCleanup '
	Else
		$sCMD = 'dism /online /Cleanup-Image /startComponentCleanup /ResetBase '
	EndIf
	GUICtrlSetState($StartReleaseCache, $GUI_DISABLE)
	GUICtrlSetState($OptResetBase, $GUI_DISABLE)
	GUICtrlSetData($StartReleaseCache, '正在释放更新缓存...')
	$PidCleanCache = Run(@ComSpec & ' /c ' & $sCMD, @WindowsDir, @SW_HIDE)
	TrayTip("提示", "正在释放更新缓存，请稍后..", 10, 1)
	AdlibRegister('_NofierCacheDone')
EndFunc   ;==>ReleaseCache
Func _NofierCacheDone()
	If Not ProcessExists($PidCleanCache) Then
		GUICtrlSetState($StartReleaseCache, $GUI_ENABLE)
		GUICtrlSetState($OptResetBase, $GUI_ENABLE)
		GUICtrlSetData($StartReleaseCache, '一键释放更新缓存')
		AdlibUnRegister('_NofierCacheDone')
		MsgBox(0, '提示', '释放更新缓存操作完成！', 5, $FormReleaseCache)
	EndIf
EndFunc   ;==>_NofierCacheDone

Func InstallNetFrame35UI()
	Global $FormInsdotNet = _GUICreate("Windows8.1+.NET Framework3.5安装工具", 368, 109, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("选择Windows8.1+源安装盘", 8, 8, 353, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $InsSourceDriveList = GUICtrlCreateCombo("", 16, 24, 337, 25, BitOR($CBS_DROPDOWNLIST, $WS_HSCROLL))
	GUICtrlSetData(-1, "")
	$MSetCustomDir = GUICtrlCreateContextMenu($InsSourceDriveList)
	GUICtrlCreateMenuItem('添加自定义目录进行安装', $MSetCustomDir)
	GUICtrlSetOnEvent(-1, 'AddCustomSourceDir')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Btn_installdotnet35 = GUICtrlCreateButton("从源安装盘安装.NET Framework3.5", 8, 74, 355, 25, BitOR($BS_DEFPUSHBUTTON, $BS_PUSHLIKE))
	GUICtrlSetOnEvent(-1, '_InstallNF35Frommedia')
	Global $ShowCMD = GUICtrlCreateCheckbox("显示命令行界面", 8, 56, 113, 17)
	GUICtrlSetTip(-1, '勾选此选项将显示命令提示符界面以便查看进度', '说明', 1)
	Global $LimitAccess = GUICtrlCreateCheckbox("安装时不检查更新服务器", 128, 56, 169, 17)
	GUICtrlSetTip(-1, '勾选此选项将部分提高安装的速度', '说明', 1)
	GUISetState(@SW_SHOW)
	_GetSourceDrivesToCombo()
	GUIRegisterMsg($WM_DEVICECHANGE, '_DEVICECHANGE')
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitDotNetForm')
EndFunc   ;==>InstallNetFrame35UI
Func QuitDotNetForm()
	GUIRegisterMsg($WM_DEVICECHANGE, '')
	_WinAPI_AnimateWindow($FormInsdotNet, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormInsdotNet)
EndFunc   ;==>QuitDotNetForm

Func Win11RightMenuToogleUI()
	Global $Win11RightMenuForm = _GUICreate("Windows 11 右键菜单风格切换", 307, 89, 121, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateButton("windows11新版风格", 24, 16, 113, 33)
	GUICtrlSetOnEvent(-1, 'windows11StyleRightMenu')
	GUICtrlCreateButton("windows旧版风格", 140, 15, 97, 33)
	GUICtrlSetOnEvent(-1, 'windowsOldStyleRightMenu')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitWin11RightMenuForm')
EndFunc   ;==>Win11RightMenuToogleUI

Func windows11StyleRightMenu()
	RegDelete('HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}')
	RestartExplorer()
	MsgBox(0, '提示', '设置右键菜单为windows11新版风格成功！', 5, $Win11RightMenuForm)
EndFunc   ;==>windows11StyleRightMenu
Func windowsOldStyleRightMenu()
	RegWrite('HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32', '', "REG_SZ", "")
	RestartExplorer()
	MsgBox(0, '提示', '设置右键菜单为windows旧版本风格成功！', 5, $Win11RightMenuForm)
EndFunc   ;==>windowsOldStyleRightMenu

Func RestartExplorer()
	Local $ifailure = 100, $zfailure = 100, $rPID = 0, $iExplorerPath = @WindowsDir & "\Explorer.exe"
	_WinAPI_ShellChangeNotify($shcne_AssocChanged, 0, 0, 0) ; Save icon positions
	Local $hSystray = _WinAPI_FindWindow("Shell_TrayWnd", "")
	_SendMessage($hSystray, 1460, 0, 0) ; Close the Explorer shell gracefully
	While ProcessExists("Explorer.exe") ; Try Close the Explorer
		Sleep(10)
		$ifailure -= ProcessClose("Explorer.exe") ? 0 : 1
		If $ifailure < 1 Then Return SetError(1, 0, 0)
	WEnd
	While (Not ProcessExists("Explorer.exe")) ; Start the Explorer
		If Not FileExists($iExplorerPath) Then Return SetError(-1, 0, 0)
		Sleep(500)
		$rPID = ShellExecute($iExplorerPath)
		$zfailure -= $rPID ? 0 : 1
		If $zfailure < 1 Then Return SetError(2, 0, 0)
	WEnd
	Return $rPID
EndFunc   ;==>RestartExplorer

Func QuitWin11RightMenuForm()
	_WinAPI_AnimateWindow($Win11RightMenuForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Win11RightMenuForm)
EndFunc   ;==>QuitWin11RightMenuForm

Func _DEVICECHANGE($hWnd, $Msg, $WParam, $LParam)
	Switch $WParam
		Case $DBT_DEVICEARRIVAL, $DBT_DEVICEREMOVECOMPLETE
			_GetSourceDrivesToCombo()

	EndSwitch
EndFunc   ;==>_DEVICECHANGE
Func _GetSourceDrivesToCombo()
	Local $aDrive = DriveGetDrive('ALL'), $str = ''
	For $i = 1 To $aDrive[0]
		If FileExists($aDrive[$i] & '\sources\sxs') Then
			Local $DriveLabel = DriveGetLabel($aDrive[$i])
			If $DriveLabel = '' Then
				$str &= StringUpper($aDrive[$i]) & '|'
			Else
				$str &= StringUpper($aDrive[$i]) & '[' & $DriveLabel & ']|'
			EndIf
		EndIf
		GUICtrlSetData($InsSourceDriveList, '')
		GUICtrlSetData($InsSourceDriveList, $str)
	Next
EndFunc   ;==>_GetSourceDrivesToCombo
Func AddCustomSourceDir()
	Local $dir = FileSelectFolder('请选择Windows8.1系统安装文件所在目录[包含Sources的文件目录]', '')
	If Not @error And $dir <> '' Then
		GUICtrlSetData($InsSourceDriveList, $dir)
		_GUICtrlComboBox_SetCurSel($InsSourceDriveList, _GUICtrlComboBox_SelectString($InsSourceDriveList, $dir))
	EndIf
EndFunc   ;==>AddCustomSourceDir
Func _InstallNF35Frommedia()
	Local $sourceData = GUICtrlRead($InsSourceDriveList), $sSourceDrive = ''
	If $sourceData <> '' Then
		If StringInStr($sourceData, ':\') Then
			$sSourceDrive = $sourceData
		Else
			$sSourceDrive = StringLeft($sourceData, 2)
		EndIf
	EndIf
	If FileExists($sSourceDrive & '\sources\sxs') Then
		Local $sParam = ''
		Local $ShowFlag = @SW_HIDE
		If GUICtrlRead($ShowCMD) = $GUI_CHECKED Then
			$ShowFlag = @SW_SHOW
		EndIf
		If GUICtrlRead($LimitAccess) = $GUI_CHECKED Then
			$sParam = '/LimitAccess'
		EndIf
		GUICtrlSetData($Btn_installdotnet35, '正在安装安装.NET Framework3.5，请稍后..')
		GUICtrlSetState($Btn_installdotnet35, $GUI_DISABLE)
		GUICtrlSetState($InsSourceDriveList, $GUI_DISABLE)
		TrayTip("提示", "正在安装安装.NET Framework3.5，请稍后..", 10, 1)
		$PidInstallNet35 = Run(@ComSpec & ' /c dism.exe /online /enable-feature /featurename:NetFX3 /Source:' & $sSourceDrive & '\sources\sxs ' & $sParam, @WindowsDir, $ShowFlag)
		AdlibRegister('_NofierNetComplete')
	Else
		MsgBox(16, '提示', '请插入可用的Windows安装介质！', 5)
	EndIf
EndFunc   ;==>_InstallNF35Frommedia
Func _NofierNetComplete()
	If Not ProcessExists($PidInstallNet35) Then
		TrayTip('', '', 0)
		GUICtrlSetData($Btn_installdotnet35, '从源安装盘安装.NET Framework3.5')
		GUICtrlSetState($Btn_installdotnet35, $GUI_ENABLE)
		GUICtrlSetState($InsSourceDriveList, $GUI_ENABLE)
		AdlibUnRegister('_NofierNetComplete')
		MsgBox(0, '提示', '已经成功安装.NET Framework3.5', 5)
	EndIf
EndFunc   ;==>_NofierNetComplete
Func ForceDelToolUI()
	Global $ForceDelTool = _GUICreate("文件免权限强制删除工具", 353, 147, 120, 100, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("", 8, 8, 337, 129)
	GUICtrlSetState(-1, $GUI_ACCEPTFILES)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $DelProcess = GUICtrlCreateLabel("拖动您要强制删除的文件或者文件夹到这里来..", 30, 40, 300, 33)
	GUICtrlSetColor(-1, 0x808080)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitForceDelTool')
	GUISetOnEvent($GUI_EVENT_DROPPED, 'ForceDelFiles')
	GUIRegisterMsg($WM_DROPFILES, "WM_DropFiles")
EndFunc   ;==>ForceDelToolUI

Func QuitForceDelTool()
	_WinAPI_AnimateWindow($ForceDelTool, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($ForceDelTool)
	GUIRegisterMsg($WM_DROPFILES, "")
EndFunc   ;==>QuitForceDelTool
Func WM_DropFiles($hWnd, $MsgID, $WParam, $LParam)
	Local $nSize, $pFileName
	Local $nAmt = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", 0xFFFFFFFF, "ptr", 0, "int", 255)
	For $i = 0 To $nAmt[0] - 1
		$nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", $i, "ptr", 0, "int", 0)
		$nSize = $nSize[0] + 1
		$pFileName = DllStructCreate("char[" & $nSize & "]")
		DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $WParam, "int", $i, "ptr", DllStructGetPtr($pFileName), "int", $nSize)
		ReDim $gaDropFiles[$i + 1]
		$gaDropFiles[$i] = DllStructGetData($pFileName, 1)
		$pFileName = 0
	Next
EndFunc   ;==>WM_DropFiles
Func ForceDelFiles()
	If @OSArch = 'x86' Then _xdelexe()
	If @OSArch = 'x64' Then _xdel64exe()
	GUICtrlSetData($DelProcess, '正在进行文件强制删除操作,请稍后...')
	For $i = 0 To UBound($gaDropFiles) - 1
		RunWait(@ComSpec & ' /c del/s/f/q "' & $gaDropFiles[$i] & '" |' & @TempDir & '\xdel.exe "' & $gaDropFiles[$i] & '"', @TempDir, @SW_HIDE)
		GUICtrlSetData($DelProcess, '正在删除文件：' & $gaDropFiles[$i] & '..')
	Next
	GUICtrlSetData($DelProcess, '文件删除完成..(*^__^*) 嘻嘻')
	Sleep(500)
	GUICtrlSetData($DelProcess, '拖动您要强制删除的文件或者文件夹到这里来..')
EndFunc   ;==>ForceDelFiles
Func _xdelexe($bSaveBinary = True, $sSavePath = @TempDir)
	Local $xdelexe
	$xdelexe &= '0rgATVqQAAMAAACCBAAw//8AALgAOC0BAEAEOBkAgAAMDh8Aug4AtAnNIbgAAUzNIVRoaXMAIHByb2dyYW0AIGNhbm5vdCAAYmUgcnVuIGkAbiBET1MgbW+AZGUuDQ0KJASGAFBFAABMAQUAEHbrVEwFV+AAD4ADCwECOAAwAAyCQgADAgAAMBEAB74QBZgABAELABcBtwEEvyMGlAAM62MAAtcAAL4gAysBBAIHBgYDAHAAGQYGIHZMAC50ZXh0eYADdC8ESIF1BmIDAGAAAFBgLmRhdGFNgAUsBcqAeQA0ixNAIAAwwC5yAxRUBysBqoABCIABNo4TQC5oYnNzgQXUAzCU60B4wC5pwxPCRsBIwhM+/88df0I/AD8APwA/AD8AMQAAVYnlg+wIofAAcUAAyf/gZpAF5AHg6AFTg+w0xwAEJFARQADoXQAuAACD7AToxQAlAADoMCoAAECNRfDHRfAhCYkARCQQoQBAQABAx0QkBARg4AAEDCQAwADgAgyNRfQBwAAI6F4tAAChAhiAAoXAdUroWBGgAYsVBEAGiRDoBIMnIAvk8Oi7Kc0gC0YhAyEHCKEhCQABBAShYgkEJOi6ExFgDcPoK0AEiRwkpOjTQQUd3OAVoyIJ0UAFi0MQAQURhQ1jAlowYQL94GhoAlBhAukBYALpb////410GibjIRhAF+Fs/xXMAeAK6Pj+//+Qjby0JuYl4QOBjuQD2OsDQeAlFItFCIsgGD0AkQAAwHc7PY3xwAByS7thBqEjAQVACAlBauhzoA+D+AEPRoSAr8AiD4Wq4AAxAMCDxBRbXcIECAA9lEAHdFk9lhHBABs9k8AAdeHrGLU9BQAB4RV0RT2aHWECzegK4QDoG+MKQHRzhcB0sIQCjSB2AP/QuCAd/+vCn+QVMdvpauABqAdSC6EH3SujB1EgEoSWbgEEAwOQ5AfpXOQlw8QYxAJmkOlDpAliHYVkEY+hCcj/6SdrA7UiDXNkAwtrA2IjV2ADUIXbdQpDDunBLOhiu+BE6+6QBQDgLV0Y6WcoIBPmAVdWUwBQuJgCAQDovwEAVImVgP3+/4tARfBCiYWEIAF0AEiLXQyF2w+VAMEx0oN9CAAPAJXChcp1O4t1QAyF9g+VwyAvfQIQgALAhdgPhZ8JgBD2heEHEA+FMkMgE4MBAQ+FBYABjQBl9FteX13DMQD2MdIx24l0JBQYuIEXv4EAiVwkABSJVCQQi00MAaFYiXwkBIlMJAgMi7VBEIk0JOhSpMEe7ByAM4UBZ7lAAFBAAIuVogNMcCQIuEjAAUFUYAgMBIs9oVuDx0CJPMgk6IRAGulPgS/kNwj/McCAD3wkGLrFQS25gQ+LdRBhCmAQFgygEuEQCIAKBIu9i8ILgAgnhQ8PhB2gBKnBArtoEAe6YQeLYhKVwAMIgAME0TuLDQIIgMFAiQwk6AMBCLLnoBiNtvMjkAIEdw2ubOABAES1EZCXAbJQbmHgNonG6LAgPoAPDABmg3xG/lwPhIJaQAtmxwRGXNAEADHSZsdERgIq4YANjY2Y/SAl4ACQDRQxwHAGEHEUjb3Et2ABcAmBDQzREtEFDHIHABiD+P+Jw3Un9OkPIAWQ8SkgQnMEERBc6N6QB9AJgQ+DURo8mCS6rpEWgA7oElMJss5AAbm0QQEBA/2QJeVAAbmCB5WIoQzQFCQSBbBDTWCJi00Qi5VNJAYIAR+xFk0IwRJuS1EBGghcFQh1gvIJ6EJ7AQH4EnQnkRa60riAB7jUIwkIMkrJH1aH0AgxTw9CBARxD1Q5IAHpZdAF9CA0FYWsAxAaMRUAAEh16+lSntAA6BGSBgJBLtKIg/gFgS/adLvSJ+lxH7j4YQd0IBUBKzEMZakHDHAG647yYPI1qDXxNV+wOIlCK/A1Mf+oib14YRHGgRHMoQEgw4XbdB4QCV7+QFx1FkuF2wAJXpAAAHXtgQ+NvBACczACMAyYDnAAkjXRACJHkAbADZAcD4TmYByo'
	$xdelexe &= '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'
	$xdelexe &= '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'
	$xdelexe &= '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'
	$xdelexe &= '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'
	$xdelexe &= 'uvdhTOiQAIEFKZI9ewPiMBzgGLvxz2EF0gGwMiHO6F3QAfvBUfLHgey8YWA9sQuFQP90CI1l9NKDx0hFmEEAAKGUMASNIH2Yx0Wc4QDHRYKgYQCJRbihmIABKMdFpFMBqFMBvKEqnFIBrFMBsFMBwKGKoFIBtOMAxKGkcQkQRcihqHIAzKGsEXIA0KGwcgDUD7eEBbSQAGaJRdjAprj/FXxwEjIU4qVxwBJlUA5UUAvoUSAs0fEPAISPAQBCtwAAiQQkMcm+VAAAAACJTCQEiQB0JAjocAIAAADHQwR4PkAAuQIBAGDHQwiAOkAAAKFEYEAAxwORAaiLFUgBLEMoACwAAIlDFKEMQECAAIlTGIsVEAEQkEMcoVQCPiz/AAAAiVMgiUMwoRQRADKLFRgCPjShZIEAPolTOIsVaAEIUEM8oXQCMEQDMEBAiUNIixUgACuhIhwCWVC6HwJpTIkA2CHIg/gBGcAAJCAByQRBiIQEKkgAMUp556GUklYAKIVoAA2hmAIKqmwBCpwCCnABCqACCqp0AQqkAgp4AQqoAgUKfAEFrAEFRYChsEGCA4QPtwW0gARmYIlFiI2FgTIAlf8AFWxxQAAPt/AAg+wEhfZ1QjEA0oXSdR6JHCTU6MuBTzwAEHwAEIAOQA+3wOgv/QAawwiJHZSAbY1DBKMihIIDCKOkgQNl9ABbXl9dw4nw6AIIABM52InydbFQ67Ho44AjkAcAUQCJ4YPBCD0AEEAAAHIQgemBA4MICQAtgQPr6SnBAYAFieCJzIsIixBABP/ggBf/JcCrgD+BA8iEA8SEA9iEA1LkhAMUcoMD6MQDLFXEA9DEA/TEARzEBSBVxAEExAH4xAcoxAMAVcQBJMQBCMQBEMQB/FXECxjEA+zEA9TEAQxVxAWwxAN4xAF0xAGoVcQBlMQBmMQBrMQBgFXEAYjEAYTEAaTEAaBVxAFwxAGQxAGcxAG4VcQBtMQBYMQBZMQBVFXEAVDEAVjEAVzEATQBwi9VieVd6WfTjP//xG/Bs1A/QMHJ/gDBAgICPwA/AAQAwiTAE/5wbBTtAB8AHwAfAB8AHwD/HwAfAB8AHwAfAB8AHwAfAAEbAFMAZQB0AE5QAGEAbSABZOIBY0AAdQByAGngAnkAAEkAbgBmAG9QACAAKOACaOAEblQAZ2AEIGACd2ABZRUgBSngCCEgAiUAc0WgACfiACcAOiICdQwACv8M+gxEAEEAaEMATKIMLiAAoQAAVABG4AZu4AhOYAR4uyAI4QFsYAEBAGcRRuAI3eMCZOwR5QfhAHJgBScIukXgCSBgEScHoQFvoASr6QbtDiigDmOgBG0gAH0hGnQiB2EWfQ01B3cQT0QAcGACbgBQ4AFvRWAHZWAKcwBUYAFrd+ICZSCpHyDgCqEr4QNhrABiogJhAmhyAFQwAa2xAyCwBVUdc7ABaZAGdiAwAFEadrYEcRlRFE2tVgNzkhyRAHlQBnVwAFZh9ABxHCAQHGTSDW7bMADxD3JwAfEIcnIkUQB6ZbAFYTAGcQExBvEFV9USBHdyB2xSBnS2ADEEunlWDWTyAxEmWQ1mFAu6czQfRxICdxI1J3KwCX1xB2mwANETfxMdBlEDbCsyAREZJRApMjABIAD4SwBCtC4VFf8UURvXFNuxFAEATBAFcQl1HwIwANpW0ARssAGzAk4SCdcNffMIdTImkQ6/HzMMkQR01/gR8zdxGm5yAXWwBJEKqicyBVPwEUTyBFk0HfdxDPkEcSFvcgqRELEeUQS9MQdhshqxHTEDtwoskhR3UTDRPxMgeVIBUyCzHmS3sAHxI5EGcFIFURdykiR33xizHREmahIMGR6fFHO1+hpH8hpE2AQxByX0NtX3FSjyRCm6TEVSE/EF6zECsSRBcAts/yP/I7YFL78CvwLdCDEIJfAGNgC6NJIBYhAUkQKbDU2SDQkBAIBfMAA6TWluAGd3IHJ1bnRpAG1lIGZhaWx1AHJlOgoAICBWAGly'
	$xdelexe &= 'dHVhbFF1CGVyeYIBZWQgZgBvciAlZCBieQB0ZXMgYXQgYQBkZHJlc3MgJQJwEQUgIFVua24Ab3duIHBzZXUAZG8gcmVsb2MQYXRpbxABcm90AG9jb2wgdmVy4nMBASVkLhELPwM3AwBiaXQgc2l6ZQG1Ai1MSUJHQ0MAVzMyLUVILTMALVNKTEotR1SASFItTUlOR2ABATACdzMyX3NoYQByZWRwdHItPoniAz09YgRvZigwAgBfRUhfU0hBUkRFREJYLi4vIABnAGNjLTMuNC41AZEAL2NvbmZpZ0AvaTM4Ni/wBC0l8wQtAAUuY/JCZXQAQXRvbU5hbWUQQSAoYaAALCBzAyAAMwZzKSkgIT38IDA/dQ8ADwAPAA8ADwDfDwAPAA8ADwAHAGQSHQMAwIR1AABQcdAiOAEq5DABbDAB1DgBZHZoAADAMAFIMAAFAHStMAE042kOADxwAVQwAKpqMACCMACWMACqtAKqwnAAzjAA3DAA6jAAqvgwAASgLBAwACQwAKo0MABEMABYMABwMACqhjAAljAApDAAsDAAKsQwANowAPgwAAp0VTMFGnAAKjAAOjAASFUwAFowAGwwAHYwAIBVMACIMACSMACeMACsVTAAtDAAvjAAxjAA0lUwANwwAOYwAPAwAPpVMAAEMBAOMAAYMAAkVTAALjAAODAAQjAATPswAAEAVnQAvw6/Dr8Ovw4/vw6/Dr8Ovw6/DrsOIrOg3HQAAOYAMPAAMIL6ADAEdQAADgAYqhgAGCQAGC4ADDgADFpCAAxMAAwBAFYEHBkAAEFkanVzdFQAb2tlblByaXYAaWxlZ2VzAOsIAEdlAyhJbmZvAHJtYXRpb24AABcBTG9va3VwAQZQVmFsdWVXABBlAU9wAT5vY2UEc3MCNQAAyAFTAGV0RW50cmllAHNJbkFjbFcABADRARNOYW1lZABTZWN1cml0eREBXVcAAQCFZEF0AG9tQQAAJgBDAGxvc2VIYW5kAGxlAG4ARGVsEGV0ZUYAblcAnCAARXhpdARnALDQAEZpbgQ2soIFghwEALiCBUZpcnN0KQEbRXiAPMCCCU5l4ngCCVcA3YFvAR2BRgmAOhsBgAdDdXJyNGVuhi82gQkBF0F0QYBiYnV0ZXOCJTcLjwuACkWBCkxhc3QARXJyb3IAABIAAkxvY2FsQWxAbG9jAAAWgwZGAHJlZQB4AlJlAG1vdmVEaXJlIGN0b3J5gB6+AouAjI4p44EKVW5ogoXAZEV4Y2VwgcOAEwB0ZXIAHgNWaaBydHVhbAAsdEASCAAAIUUEUXVlcgJ5QCoAX19nZXQAbWFpbmFyZ3MEAE3AA3BfX2VuSHZpcoBzAE/DA2aAbW9kZQAAY0ADAHNldF9hcHBfqHR5cEAEb0AEdwkQAACJAF9hc3NlAHJ0AJMAX2NlAUBjAAAKAV9pbwBiAAB/AV9vblmCBKoBARJDFa/AAm4Ad3ByaW50ZgBAAEcCYWJvQA9OiAJhdEMPcQJmAUV1QEVmRgl5wAJAh0AFpAgCbWFDUKoCbWVobWNwQDWrQQIBUAAGrEECQBoAALoCcgJlAwrCAnNpZ24AYWwAAOwCdmYBRRT0Andjc2NtUHAAAPlBAmxBqPwVQQJugRT+QQJyY2gQcgAIAwUhSwBT9kgBZEC2ckK/wGMAAEAQAdEAQURWQVBJM6AyLkRMTIEJFMAEA/8AxwBLRVJORUyJwBdkbEA2AAAowAQH/wB/AGUAbXN2Y3IKdKMPPOABU0hFTP/BEcQdHwAfAB8AHwAfAB8APx8AHwAfAB8AHwAEAA=='
	$xdelexe = _WinAPI_Base64Decode($xdelexe)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($xdelexe) & ']')
	DllStructSetData($tSource, 1, $xdelexe)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 17920)
	$tSource = 0
	Local $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\xdel.exe", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_xdelexe

Func _xdel64exe($bSaveBinary = True, $sSavePath = @TempDir)
	Local $xdel64exe
	$xdel64exe &= 'groATVqQAAMAAACCBAAw//8AALgAOC0BAEAEOBkAgAAMDh8Aug4AtAnNIbgAAUzNIVRoaXMAIHByb2dyYW0AIGNhbm5vdCAAYmUgcnVuIGkAbiBET1MgbW+AZGUuDQ0KJASGAFBFAABkhgcAEHjrVEwFV/AAL4ACCwICFABKAAyCHgADCgAAMBUAB7YQCJkBCwIDtwEABQEMRQEAwAPM3ZIAAtcAPAAgBy8JCAYPCgUAAGCQAABwDCB+FQCwCAAAGDAbLnRleHp0gVZJBEiBfQVuBAAgAABQYC5kYXRhSYS9AGCDgQBOixNAIABQwC5yAxSgCCUACHCDoQBQjhNALshic3PBAtAJBRXReXBgwC5pwxPCRsBIAAoOwABazRMwwC5D1FJUwQJoAQGgxCcCA0HJCUDALnRswh1I68RMwglqzQlgQXM/AD8ADz8APwA/ABAASIPsCIBIg8QIww8foj8h4AE4iwU2IEZEiwAN308AAEyNBUT4b+ACjRXpwgANIt7AAIkF9IIBBe0BwQCJRCQg6DtGRcEC1eEBg8Q4wAmEAeULKGaBPZPv/1D/TVrH4gUBwALHVAXnJgHhJgHbJAF0IHkxwIsN4QKJBYKHoACFyXRXuQFEhOjdwIVIx8H/AAAA6MEzAACLFctRIhAFvHjCAL3BAIsEBQKAD4kQ6H81BSEEGSEI0nQKiwWCryEBwHR7McBgFCIoYBRAALnhDeiGCcAK66fhAUhjFSUTYBVAG+LuwQAEAoEiOGGUD4VpYA4PtwBQGEiNSBhmgSD6CwF0U8EAAg8khU8gA4O44R0OD4SGQoABRIuA+KABAEWFwA+VwA+2CMDpL4ACZg8fRIUCKOngFv8VN4MhHgdhEyEQJBJmkIN5XAGACP3+//8xwIPMudBBKGAI6e4AAuIHQEFVMcC5DaACQQBUVVdWU0iB7IKYgAFEiyWzboELAFQkIEWF5EiJgNfzSKsPhdFgJkBlSIsEJTAhMYsAWAgxwPBID7EYHZ93wAEAITVIORDDD4RZoARIiz1EPoLAEPbrCWICRQlgArnoAKj/10iJCvCCBmqDBnXfiwUCZ0ABMduD+AEPxIQwAAWLBVYAAoAdhIRuoAHHBahtgxpYiwU+4ALCBCUAA4WI23UKARCHBR9BCRCLBZBNwxAMRTEEwLrBOzHJ/9DoFgqANqAk0wAC/xWhioHCOl4gCugxOQIDJEpdgQcd/8BV/9MRwAcPhBoBGI0VWcEBA4nB/xXsQAPhChIJoAUc/UAv0OgVEjyBJB2O4AhFhdsUdGSgD8ZACzHJSACLAA+2EID6IAgPjzFgFoTSD5UgwoTJdAgAAYUrgQICdAxIg8ABgwSAfvD2RCRcAYANhMTsoEOJBS12QOYhQatIiRUxYAEPhQtg6KBWHWABiy2zbAHhJDH2jU0BSGMAyUjB4QPoLEMAAABJicQxwIUK7WAulgAEfkFIi4AMH4PGAegIYAMARI1oAU1j7UwQienoAUIFBBxIQIsUH02J6EAbSACDwwjo8kIAAIA59X/KSGPtwFMi7YJsixVUIAlJxxYEIsaAG7lAIEyJJSI2oAKLDSygAEiJIBBMiwUuIQGLFSIfwADoIhRBIhUnEbAAiQUFUABFhdKYD4QPMA+QP+lr8QAgyXUL6IvgBosFIuXwAEiBxLEmW17AX11BXEFd4DPwKACJy4PzAYD6IkgPRMthEumvgSq3IEQkYOn3kABmkICLBTp1AAC74SBJgSCF0PAYuR8xNzotggUc0AGCAd6AAQ8fKXEceYtyHmJgAOgdMUACxwXzkHHxIem5AUACSInR/xURf0XQACHRAI0VafMCSjFgAMcFyKACIj3jQUUQAnoSAg0jW7QiZlCQD4XSMwEbNQEPFIXAEwEJEQEV336RwiMPhMhQAemlQABwicHonsAE9DvwTMeMBULgEAEA6L048k5wKOlk/OEL8EPyASJr8AFSCJ31AUT0ASA7iQGQEuwoSIsBiwCEPZEA'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= 'OGdcUKQAIEyJvCRYgACxARj/FRNABlBaxg+EYqVAD/8VayAIUArQpVcKHVQKvTCQEYBAArWAKAqFKGzgTI4o40EBlY0ocoEVcoAakIsjVgBJizQkMcmD7SQEifMAie3wdf/XQEmJ6EiJ8lBZ6ETsL5EVx+nhQnUVpOls5GL/0jAdw3ALTTQdNIActApxSjMdEUWxCidwAw8fQHEvCSkwDOj08AS48Q/pPaP7IrEMTYnxoAR1YA+RlQz/Fb8wBum/QJSVEH1MUATT0AHorlAEjOnTQAH4jg3BTZABppSQARA0zVgVNJNgUhAxwOnPwAJNhfZseGmCEgESwtIVExQaaygHThM9EQg98AM0Zc2bMBBUD96gDlQPe0lTDxIboQm1+fCMifBBAIPmAUjR6EwJAPDySA8qwPIPUFjA64QQBIsQBOkGkTAC+A+D7Fjo5yInYVYN0Dfzm0hIQo1SjEwkTEzgAEDNsF9Ik29xV7oukQ4AAhFQCkzoLDCOSIPEGFjDkAMA8ARoSIkAXCQoSInTSIkUdCQAXXywBInOTASJz5EzQEyJZCQkSEyQAFBM4AFYTGngAWBN4D47YQXAX4nAxUSJ7egt0ADgRuBBicboIqAAdSEAAQDERIn2R40sLkToQgEDjUxvEblvFlxiiHBBLFABQY1FAAFHjWwsAkWJkOBMifrwAUdcgQ0ALgJIjQxH6AkZIAJmQkADAQf4SIuNwQqLkQqgSzhIizEKJosxCpAAUEyAAVhMozFNQA5ow2bxDVj0DTkgA0yJ0MTyDZoNSYmA1EmJzehoLQEbYcA9if7oXLAAIAqJEMVMiepgDo18PVgB6IAwARAMcxEMcwJcUBzoTIni6GrrUAEAAXvRCdiECSIK3wlNghdmAQD2HFa6IY5TgkiApYPsKOgVwASWupAhsATGYAfoBSEHIIX2D5TC0MN0IgCE0kiNWAJ1DwhIjV6wEVACSDlQxkgPRhC62KAFKABbXsOQhNJ18X/SAfAAYAEgAfsGUAbQD1wXEJHwEBACfBEfz+htAiygD8OJxo1LBQCDwwFIAcnoE+sQATIa+uE9hdAAQA7QMl9QAFJqIQTADnIOMNAGOKLD8nFIKcoiBtFQE8FVF4nTg8IFICXQHLAS6LsrUm1kQy12BV94HcME9woiEkQLy3cL6DbooATJEtjwAMYSdSV1oBBxYgbZhAoiC9QK6QJTEn0AhNIPhYgDIQSRFELwSCneSAFAD9HoicaDwAVxAAsA6AoCC8EqAQt8X9AALxAlEPAmcAggMAKJwMaJx41OBYCdwRTcxioxBJGIMQQ4NgRQAAp4UJy09xmmuQBIicLpSv///wKQBABWU0iJy0gAg+wohdJ0KYsAQQiFwHQiMfZAZi4PH4QAAQBIAIsDifKDxgFIAIsM0Oi3KgAAADlzCHfqSIsLBOiqABhIg8QoSECJ2Vte6ZwAGg/IH0AAC55RCAAMF55iZwVPx0MIAhwATlsQXsNmZggvg+w4EEiJXCQAZnQkMCAx9jlRCABgdiwAQYnRRItDCEoIjQzNAiaJyEgDAANBg+gBRDnCIEiLMEjHAj1yIIhEiUMAMPBIiwFCJosAQoAxOMOKR0EpANBJweADSo1UAMgISI0MCOgIZwBLAS4BJ+u+gEaLR0gjh0eBdYl8JIBQbCQgQEyJx0SAoInWAEE50HJHi0EMAEE5wHNDRDnGAEiLAXJeifZICI0s9QEhg0MIAahIiTyAIPgIS4sBI0aLACMAUEjDZoU3MQD/69cBwIlBDACJwEiLCUiNFCLFgQroXSkDUUiJAgMAMHOiifFBKYbwADADho1MyAgBaTEAFyjoOgAVgHLriBgPH0SFpwAcic65BhACTkAg6IYoAAAAifFIicNIweFIA+h4QQNzDMAWSHyJ2IVmAymBKwJQ4ENIIInWi2kIwEE5xQRzLcBAie9Iwed5gBQ0OENACWVLPxA8bAPAJAY8xXMkielBICnoSI08Djw46JZJgAoB'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= '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'
	$xdel64exe &= 'dGWFfwBgbQNUbHOAUQK7AMR2AxYRAI4DhCLADmJ0wDkAAJBFBAJGAEAATgBfX2QATm5AZXhpdABRQANnEGV0bWEAHHJncxQAUsADacBnZW52hABTwQJvYl9mADyDQFlAA2xjb252wgcIAABgwANzZXRfAGFwcF90eXBlSAAAYkMEdXPAL2FQdGhlcsAjbMAEdwEJGABwAF9hY20gZGxuAHdAAm1zBGdfAiIAggBfYwFDAsYAX2Ztb2QZQBT1AAIbQDZtACIEAV9Ae2sAbwFfAcQumgFfc253cAByaW50ZgAA0BABX3VuIgQyAmGAYm9ydAA+AqBCiSJERwIjC1UCZsQFCFsCZsFFAGICZh0mCGNgASBPoAKNAm0BJAeTAm1lbWNwjeAmlCEBAUgAogJgbQHCA6sCc2lnbmEAbAAAugJzdHIKbKGOvCEBbmNtcBAA1QJ2xQ0A3QLId2NzgQIA4iEBIgUq5SEBboEL5yEBcmMgaHIA8QLFEZsAzFNIQUjgmnJhQTwgSAQAkHMAQURWQVAwSTMyLgA7IAIAFD9gAn8AfwB/AH8AaQBLRdBSTkVM5xQoYAJ/AA9/AH8AfwBlAG1zdmMUcnQjFDzgAVNIRf5MSBYfAB8AHwAfAB8AHwA/HwAfAB8AHwAfABwAEBCWQE8BAABgdAFQRP8B6QEA4ENzAaB0AA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8APw8ADwAPAA8ADwAPAEGwJXMbRHQAYIBzAECg//8cDwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8ABw8ADwAPAA=='
	$xdel64exe = _WinAPI_Base64Decode($xdel64exe)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($xdel64exe) & ']')
	DllStructSetData($tSource, 1, $xdel64exe)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 27648)
	$tSource = 0
	Local $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\xdel.exe", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_xdel64exe

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

Func RemoveDP()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '77', 'REG_SZ', '%systemroot%\system32\imageres.dll,197')
	FileSetAttrib(@LocalAppDataDir & '\Local\iconcache.db', '-SRH')
	If ProcessExists("explorer.exe") Then ProcessClose('explorer.exe')
	FileDelete(@LocalAppDataDir & '\Local\iconcache.db')
	If Not ProcessExists("explorer.exe") Then Run(@WindowsDir & '\explorer.exe')
	_ForceUpdate()
	MsgBox(0, '提示', '已经移除小盾牌图标！', 5)
EndFunc   ;==>RemoveDP
Func RestoreDP()
	RegDelete('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons', '77')
	FileSetAttrib(@LocalAppDataDir & '\Local\iconcache.db', '-SRH')
	If ProcessExists("explorer.exe") Then ProcessClose('explorer.exe')
	FileDelete(@LocalAppDataDir & '\Local\iconcache.db')
	If Not ProcessExists("explorer.exe") Then Run(@WindowsDir & '\explorer.exe')
	_ForceUpdate()
	MsgBox(0, '提示', '已经还原小盾牌图标！', 5)
EndFunc   ;==>RestoreDP
;=========================================================================================
; 关于程序
;=========================================================================================
Func _History()
	If Not FileExists(@TempDir & '\更新记录.txt') Then FileInstall('readMe.txt', @TempDir & '\更新记录.txt', 1)
	Local $Fh = FileOpen(@TempDir & '\更新记录.txt')
	Local $data = FileRead($Fh)
	FileClose($Fh)
	FileDelete(@TempDir & '\更新记录.txt')
	_GUIDisable($Form1, 1, 45, 0x51D0F7)
	_DisableTrayMenu()
	Global $FormHistory = _GUICreate("程序版本更新记录", 437, 400, 86, -20, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_POPUP), BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateLabel('Windows NT6+快速设置工具版本更新记录', 3, 1, 400, 20, $SS_CENTER)
	GUICtrlSetFont(-1, 12, 800, 0, "微软雅黑")
	GUICtrlSetColor(-1, 0x3399FF)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	_ScrollingCredits($data, 3, 25, 431, 350, 5, '更多信息请访问' & $UerHome, '黑体')
	GUICtrlCreateButton("我已阅读，谢谢！", 8, 380, 419, 20)
	GUICtrlSetOnEvent(-1, 'QuitHisForm')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitHisForm')
EndFunc   ;==>_History

Func QuitHisForm()
	_WinAPI_AnimateWindow($FormHistory, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormHistory)
	_GUIDisable($Form1, 0)
	_EnableTrayMenu()
EndFunc   ;==>QuitHisForm
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


;Code below was generated by: 'File to Base64 String' Code Generator v1.12 Build 2014-01-04

Func _Background_Image($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $Background_Image
	$Background_Image &= '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'
	$Background_Image &= 'OR0x8Y8oFOxv/HRD4ifBw77N5NltAkE2Akh+Z8r9oB2gVZTyjBYvE19I/wMiBrhq2KwUyxDAXGaeQj2u4rTg0S3Ii0Zvsad9NIOyKldpnoOqVt5U+IwCDPHsNhqfVxW/QPvjLIH2AqylMdncjgdYRwK+E077SqyB9NaopPZllvqrugdaVE7I/ZzEGAnRyWK6Opc20IbWyNL5dfDH362YyIRbXrsW7iJb08lePg/sx3nAq63gaQvkFm0MYdKPeOmdfcSxrnulKIQ6IF1NoXCqG5V+f/M+CpRABCQa0pSocln4O5miSczjmWZf4vYs3DB4KWsaAJc37fGN+mvJfMAq4STlx/lkMoHfHgl1PWX0bDhFkQP8/6BSp5OqUrKn8fyd/YMPKNVNonGpjIO6DVj8dDaMyv24RiLkfpqL8PP51c9n4vgAzH2Bsv+tbFwP292uVhOytAr7SZs1XTE7/apaQ3uyou+1uh7VpPrhW4hO8cNbAfz9PC68vSCqOjS1wTyaUxX73/gEH0i1v/QuapOF4MUl/rgXlqphCAvCwaHPMDHZf09Pf7w/+PXdB77g7wfidHzhfLK2asKRa+zhLysPftdyjDR1fHk0Nm9l6mFZ5eATcWB3mORbkh7rjd+KJSPpQn6OlqirYpcf+EDvfZkN8Ffe5H1/bTkBxQf1WcTDp929UQ3FKpX5QOap24FNw+4/3iCGPsXDpK0Zg+ajmobQwFNkvZa59rzZUuEZBjwFs0dbxM8P6D/fuPj4wBgZn1/RnMGff0Uvg0YACNipw6uyTcEH/pYicc5fu5eAn8hhcsFO+ZDtjf5y2ovP72hifLqyCpX/HIq6P7BQwb8osgxT5JbzErTqcdPA89yxJuul2y3fx7wVUUUSgIgsnym520dvihOrp1MfSDa/Brn44Z77mqGACnYxbV4aesAg70SicdaHrIml0h8nTTsjRyeFX5eoHzcX/sWK3fB2rLF9VkBzHpg2hkgOABKr2uCGZphH/fgyBz5uJir/Bqv9sariS6T3gfj2B+f9TfZfnwcv4QPb8S+sgA9M7l/A9f8AeBKge49HiNoAAAAASUVORK5CYII='
	Local $bString = Binary(_WinAPI_Base64Decode($Background_Image))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\bg.png", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_Background_Image

Func _WinAPI_Base64Decode($sB64String)
	Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
	Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
	$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($bBuffer, 1)
EndFunc   ;==>_WinAPI_Base64Decode
Func _WinAPI_LZNTDecompress(ByRef $tInput, ByRef $tOutput, $iBufferSize)
	$tOutput = DllStructCreate("byte[" & $iBufferSize & "]")
	If @error Then Return SetError(1, 0, 0)
	Local $aRet = DllCall("ntdll.dll", "uint", "RtlDecompressBuffer", "ushort", 0x0002, "struct*", $tOutput, "ulong", $iBufferSize, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "ulong*", 0)
	If @error Then Return SetError(2, 0, 0)
	If $aRet[0] Then Return SetError(3, $aRet[0], 0)
	Return $aRet[6]
EndFunc   ;==>_WinAPI_LZNTDecompress
;检测是否有ssd硬盘
Func HasSSD()
	;经过测试，NT5使用ssd检测会蓝屏，故屏蔽
	If @OSBuild > 6000 Then
		Local $aDrive = DriveGetDrive('ALL')
		For $i In $aDrive
			If DriveGetType($i, 2) = 'SSD' Then
				Return True
				ExitLoop
			EndIf
		Next
	EndIf
	Return False
EndFunc   ;==>HasSSD

Func AutoLoginTool()
	Local $UserPwd = RegRead('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon', 'DefaultPassword')
	If @error Then
		$UserPwd = ''
	EndIf
	Global $FSetAuto = _GUICreate("自动登录设置器", 353, 141, 128, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("用户登录信息", 16, 8, 217, 97)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateLabel("用户名", 24, 34, 40, 17)
	Global $AutoUsername = GUICtrlCreateInput(@UserName, 82, 32, 137, 21)
	GUICtrlCreateLabel("用户密码", 24, 60, 52, 17)
	Global $UserAccPwd = GUICtrlCreateInput("", 82, 60, 137, 21, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	_GUICtrlEdit_SetPasswordChar(-1, '#')
	GUICtrlSetData(-1, $UserPwd)
	Global $ShowUserLoginPassword = _GUICtrlCreateCheckbox("显示为明文密码", 24, 85, 105, 17)
	GUICtrlSetTip(-1, '勾选此选项，将在用户密码框中' & @LF & '明文显示用户输入的密码', '说明', 1)
	GUICtrlSetOnEvent(-1, '_ShowUserLoginPassword')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $SetAuto = _GUICtrlCreateRadio("设置自动登录", 16, 112, 97, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	Global $CancelAuto = _GUICtrlCreateRadio("取消自动登录", 120, 112, 97, 17)
	Global $LogoutAutoLogin = _GUICtrlCreateCheckbox("注销后自动登录", 240, 88, 105, 17)
	GUICtrlSetTip(-1, '勾选此选项，用户选择注销后将自' & @LF & '动重新登录，不需要再次输入密码', '说明', 1)
	$BtnSet = GUICtrlCreateButton("设置", 240, 24, 75, 25)
	GUICtrlSetOnEvent(-1, 'SetAutoLogin')
	$MSys = GUICtrlCreateContextMenu($BtnSet)
	GUICtrlCreateMenuItem('使用系统自带功能进行设置', $MSys)
	GUICtrlSetOnEvent(-1, 'UseBuildInAuto')
	GUICtrlCreateButton("退出程序", 240, 56, 75, 25)
	GUICtrlSetOnEvent(-1, 'QuitFSetAuto')
	GUICtrlCreateLabel(@ComputerName, 224, 112, 82, 17)
	GUICtrlSetColor(-1, 0x0066CC)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFSetAuto')
EndFunc   ;==>AutoLoginTool

Func QuitFSetAuto()
	_WinAPI_AnimateWindow($FSetAuto, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FSetAuto)
EndFunc   ;==>QuitFSetAuto

Func SetAutoLogin()
	If GUICtrlRead($SetAuto) = $GUI_CHECKED Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SYSTEM\CurrentControlSet\Control\Lsa", "LmCompatabilityLevel", "REG_DWORD", "2")
		If GUICtrlRead($LogoutAutoLogin) = $GUI_CHECKED Then
			RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "ForceAutoLogon", "REG_SZ", "1")
		EndIf
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "REG_SZ", "1")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName", "REG_SZ", GUICtrlRead($AutoUsername))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword", "REG_SZ", GUICtrlRead($UserAccPwd))
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName", "REG_SZ", @ComputerName)
		MsgBox(0, '提示', '设置用户' & GUICtrlRead($AutoUsername) & '自动登录成功！' & @LF & '请重启以进行验证！', 5)
	EndIf
	If GUICtrlRead($CancelAuto) = $GUI_CHECKED Then
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "AutoAdminLogon", "REG_SZ", "0")
		RegWrite("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "ForceAutoLogon", "REG_SZ", "0")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultUserName")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultPassword")
		RegDelete("HKEY_LOCAL_MACHINE" & $OSFlag & "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon", "DefaultDomainName")
		MsgBox(0, '提示', '取消自动登录完成！', 5)
	EndIf
EndFunc   ;==>SetAutoLogin
Func _ShowUserLoginPassword()
	If GUICtrlRead($ShowUserLoginPassword) = $GUI_CHECKED Then
		_GUICtrlEdit_SetPasswordChar($UserAccPwd)
	Else
		_GUICtrlEdit_SetPasswordChar($UserAccPwd, '#')
	EndIf
	GUICtrlSetState($UserAccPwd, $GUI_FOCUS)
	_GUICtrlEdit_SetSel($UserAccPwd, -1, -1)
EndFunc   ;==>_ShowUserLoginPassword
Func UseBuildInAuto()
	Run('control.exe userpasswords2', @WindowsDir)
	If GUICtrlRead($SetAuto) = $GUI_CHECKED Then
		WinActivate('[CLASS:#32770]')
		WinWaitActive('[CLASS:#32770]')
		If ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "IsChecked", "") = 0 Then
			MsgBox(0, '提示', '系统貌似已经设置了用户' & GUICtrlRead($AutoUsername) & '自动登录~~', 5)
		Else
			ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "UnCheck", "")
			ControlClick('', '', '[CLASS:Button; INSTANCE:9]')
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:1]', GUICtrlRead($AutoUsername))
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:2]', GUICtrlRead($UserAccPwd))
			ControlSetText('', '', '[CLASS:Edit; INSTANCE:3]', GUICtrlRead($UserAccPwd))
			ControlClick('', '', '[CLASS:Button; INSTANCE:1]')
			MsgBox(0, '提示', '调用系统内建功能设置用户' & GUICtrlRead($AutoUsername) & '自动登录成功！', 5)
		EndIf
	ElseIf GUICtrlRead($CancelAuto) = $GUI_CHECKED Then
		WinActivate('[CLASS:#32770]')
		WinWaitActive('[CLASS:#32770]')
		If ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "IsChecked", "") = 1 Then
			MsgBox(0, '提示', '系统貌似未设置用户' & GUICtrlRead($AutoUsername) & '自动登录~~', 5)
		Else
			ControlCommand('', '', '[CLASS:Button; INSTANCE:1]', "Check", "")
			ControlClick('', '', '[CLASS:Button; INSTANCE:9]')
			MsgBox(0, '提示', '调用系统内建功能取消用户' & GUICtrlRead($AutoUsername) & '自动登录成功！', 5)
		EndIf
	Else
	EndIf
EndFunc   ;==>UseBuildInAuto
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

Func GetTotalKSize($size)
	Local $aTest = StringRegExp($size, '\d+', 3)
	Local $num = $aTest[0]
	Local $TotalK = 0
	If StringInStr($size, 'KB') Then $TotalK = $num * 1024
	If StringInStr($size, 'MB') Then $TotalK = $num * 1024 * 1024
	If StringInStr($size, 'GB') Then $TotalK = $num * 1024 * 1024 * 1024
	Return $TotalK
EndFunc   ;==>GetTotalKSize

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

Func TPHotKeySet()
	Global $FormTPset = _GUICreate("Thinkpad 热键定义程序", 281, 149, 164, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("按键设定", 8, 8, 145, 81)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$aThinkHotkey[1] = _GUICtrlCreateRadio("ThinkVantage", 24, 32, 113, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetOnEvent($aThinkHotkey[1], '_LoadradioSet')
	$aThinkHotkey[2] = _GUICtrlCreateRadio("FN+", 24, 56, 35, 17)
	GUICtrlSetOnEvent($aThinkHotkey[2], '_LoadradioSet')
	Global $CmbKey = GUICtrlCreateCombo("F1", 64, 56, 49, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetOnEvent(-1, '_LoadradioSet')
	Local $sKey = ''
	For $i = 2 To 12
		$sKey &= 'F' & $i & '|'
	Next
	GUICtrlSetData(-1, $sKey)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateLabel("执行程序", 8, 98, 52, 17)
	Global $TPFilePath = GUICtrlCreateInput("", 64, 96, 177, 21)
	GUICtrlCreateButton("..", 248, 96, 19, 21)
	GUICtrlSetOnEvent(-1, 'locateExecutor')
	GUICtrlCreateLabel("程序执行参数", 8, 127, 88, 17)
	Global $TParam = GUICtrlCreateInput("", 85, 125, 180, 21)
	GUICtrlCreateButton("设定[&S]", 168, 16, 99, 25)
	GUICtrlSetOnEvent(-1, 'TpSetKey')
	GUICtrlCreateButton("清除[&C]", 167, 53, 99, 25)
	GUICtrlSetOnEvent(-1, 'TPClearkey')
	_LoadradioSet()
	GUISetState(@SW_SHOW, $FormTPset)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitTP')
EndFunc   ;==>TPHotKeySet

Func ReadOEMKEY()
	Local $sKey[29], $Value = 0, $hi = 0, $n = 0, $i = 0, $dlen = 29, $slen = 15, $result, $bKey, $iKeyOffset = 52, $Regkey
	$bKey = RegRead("HKLM64\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "DigitalProductId")
	If Not BinaryLen($bKey) Then Return ""
	Local $aKeys[BinaryLen($bKey)]
	For $i = 0 To UBound($aKeys) - 1
		$aKeys[$i] = Int(BinaryMid($bKey, $i + 1, 1))
	Next
	Local Const $isWin8 = BitAND(BitShift($aKeys[$iKeyOffset + 14], 3), 1)
	$aKeys[$iKeyOffset + 14] = BitOR(BitAND($aKeys[$iKeyOffset + 14], 0xF7), BitShift(BitAND($isWin8, 2), -2))
	$i = 24
	Local $sChars = "BCDFGHJKMPQRTVWXY2346789", $iCur, $iX, $sKeyOutput, $iLast
	While $i > -1
		$iCur = 0
		$iX = 14
		While $iX > -1
			$iCur = BitShift($iCur, -8)
			$iCur = $aKeys[$iX + $iKeyOffset] + $iCur
			$aKeys[$iX + $iKeyOffset] = Int($iCur / 24)
			$iCur = Mod($iCur, 24)
			$iX -= 1
		WEnd
		$i -= 1
		$sKeyOutput = StringMid($sChars, $iCur + 1, 1) & $sKeyOutput
		$iLast = $iCur
	WEnd
	If $isWin8 Then
		$sKeyOutput = StringMid($sKeyOutput, 2, $iLast) & "N" & StringTrimLeft($sKeyOutput, $iLast + 1)
	EndIf
	Local $Key = StringRegExpReplace($sKeyOutput, '(\w{5})(\w{5})(\w{5})(\w{5})(\w{5})', '\1-\2-\3-\4-\5')
	If $Key = '' Then
		MsgBox(16, '错误', '未能读取到系统密匙信息！', 5)
	Else
		If MsgBox(4, '提示', '已经成功读取系统密匙信息为' & @LF & $Key & @LF & '是否复制到剪切板？', 5) = 6 Then
			ClipPut($Key)
			MsgBox(0, '提示', '已经复制系统密匙到剪切板，请妥善保存！', 5)
		EndIf
	EndIf
EndFunc   ;==>ReadOEMKEY

Func QuitTP()
	_WinAPI_AnimateWindow($FormTPset, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormTPset)
EndFunc   ;==>QuitTP
Func _IsWirelessAdapter($sAdapter)

	Local $hDLL = DllOpen("wlanapi.dll"), $aResult, $hClientHandle, $pInterfaceList, _
			$tInterfaceList, $iInterfaceCount, $tInterface, $pInterface, $tGUID, $pGUID

	$aResult = DllCall($hDLL, "dword", "WlanOpenHandle", "dword", 2, "ptr", 0, "dword*", 0, "hwnd*", 0)
	If @error Or $aResult[0] Then Return 0

	$hClientHandle = $aResult[4]

	$aResult = DllCall($hDLL, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle, "ptr", 0, "ptr*", 0)
	If @error Or $aResult[0] Then Return 0

	$pInterfaceList = $aResult[3]

	$tInterfaceList = DllStructCreate("dword", $pInterfaceList)
	$iInterfaceCount = DllStructGetData($tInterfaceList, 1)
	If Not $iInterfaceCount Then Return 0

	Local $abGUIDs[$iInterfaceCount]

	For $i = 0 To $iInterfaceCount - 1
		$pInterface = Ptr(Number($pInterfaceList) + ($i * 532 + 8))
		$tInterface = DllStructCreate("byte GUID[16]; wchar descr[256]; int State", $pInterface)
		$abGUIDs[$i] = DllStructGetData($tInterface, "GUID")

		If DllStructGetData($tInterface, "descr") == $sAdapter Then Return 1

	Next


	DllCall($hDLL, "dword", "WlanFreeMemory", "ptr", $pInterfaceList)

	$tGUID = DllStructCreate("byte[16]")
	DllStructSetData($tGUID, 1, $abGUIDs[0])
	$pGUID = DllStructGetPtr($tGUID)


	DllCall($hDLL, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", 0)
	DllClose($hDLL)

	Return 0

EndFunc   ;==>_IsWirelessAdapter
Func X62intelWlanLed()
	Global $x62intelWlan = GUICreate("X62 intel 无线状态灯设置程序", 337, 165, 155, 80, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("连接名称", 16, 0, 313, 65)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $ConnNameWlan = GUICtrlCreateCombo("", 24, 16, 297, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetOnEvent(-1, 'showNCNameInGUI')
	GUICtrlCreateLabel("网卡名称:", 24, 40, 80, 17)
	Global $NcName = GUICtrlCreateLabel("", 104, 40, 296, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("状态选择", 16, 64, 313, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $LedStatus = GUICtrlCreateCombo("[0]总是关闭状态灯", 24, 80, 297, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "[1]状态灯随无线网络状态闪烁|[2]状态灯常亮|[3]状态灯随无线网络状态闪烁")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("设定选项", 16, 128, 315, 25)
	GUICtrlSetOnEvent(-1, '_ApplyIntelWlansetting')
	Global $ReStartInterface = GUICtrlCreateCheckbox("重新启用指定连接以使选项生效", 16, 112, 233, 17)
	loadConnNameToCombo()
	GUISetState(@SW_SHOW, $x62intelWlan)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'Quit62wlan')
EndFunc   ;==>X62intelWlanLed
Func Quit62wlan()
	_WinAPI_AnimateWindow($x62intelWlan, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($x62intelWlan)
EndFunc   ;==>Quit62wlan
Func loadConnNameToCombo()
	;加载连接到列表
	Local $s = ''
	For $i = 0 To $AdapterList[0][0]
		If _IsWirelessAdapter($AdapterList[$i][0]) Then
			$s &= $AdapterList[$i][5] & '|'
		EndIf
	Next
	GUICtrlSetData($ConnNameWlan, $s)
EndFunc   ;==>loadConnNameToCombo
Func showNCNameInGUI()
	For $i = 0 To $AdapterList[0][0]
		If GUICtrlRead($ConnNameWlan) = $AdapterList[$i][5] Then
			GUICtrlSetData($NcName, $AdapterList[$i][0])
		EndIf
	Next
EndFunc   ;==>showNCNameInGUI
Func _ApplyIntelWlansetting()
	For $i = 0 To $AdapterList[0][0]
		If GUICtrlRead($NcName) = $AdapterList[$i][0] Then
			Local $aSRE = StringRegExp(GUICtrlRead($LedStatus), '\d', 3)
			If Not @error Then
				RegWrite($AdapterList[$i][2], 'LedMode', 'REG_DWORD', $aSRE[0])
				If GUICtrlRead($ReStartInterface) = $GUI_CHECKED Then
					RunWait(@ComSpec & ' /c PowerShell Restart-NetAdapter -Name ' & GUICtrlRead($ConnNameWlan), @WindowsDir, @SW_HIDE)
				EndIf
				MsgBox(0, '提示', '已经将配置应用到指定连接！', 5)
			EndIf
		EndIf
	Next
EndFunc   ;==>_ApplyIntelWlansetting
Func locateExecutor()
	Local $File = FileOpenDialog('请选择可执行程序的路径', '', '可执行程序(*.exe;*.bat;*.cmd;*.ps1)', 1 + 8, '')
	If FileExists($File) Then GUICtrlSetData($TPFilePath, $File)
EndFunc   ;==>locateExecutor
Func TPHokey($parmeter = 0)
	Local $sRegKey = ''
	If GUICtrlRead($aThinkHotkey[1]) = $GUI_CHECKED Then
		$sRegKey = 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\IBM\TPHOTKEY\8001'
	EndIf
	If GUICtrlRead($aThinkHotkey[2]) = $GUI_CHECKED Then
		Local $stemp = StringRegExp(GUICtrlRead($CmbKey), '\d+', 3)
		$sRegKey = 'HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\IBM\TPHOTKEY\Class\01\' & $aKey[$stemp[0] - 1]
	EndIf
	;模式值=0 读取
	;模式值=1 写入
	If $parmeter = 0 Then
		Local $executor = RegRead($sRegKey, 'File')
		GUICtrlSetData($TPFilePath, $executor)
		Local $exeparam = RegRead($sRegKey, 'Parameters')
		GUICtrlSetData($TParam, $exeparam)
	EndIf
	If $parmeter = 1 Then
		Local $executor = GUICtrlRead($TPFilePath)
		If FileExists($executor) Then
			RegWrite($sRegKey, 'File', 'REG_SZ', $executor)
			RegWrite($sRegKey, 'Parameters', 'REG_SZ', GUICtrlRead($TParam))
		EndIf
		If $executor = '' Then
			RegWrite($sRegKey, 'File', 'REG_SZ', '')
			RegWrite($sRegKey, 'Parameters', 'REG_SZ', '')
		EndIf
	EndIf
EndFunc   ;==>TPHokey
Func _LoadradioSet()
	;状态设定
	If GUICtrlRead($aThinkHotkey[1]) = $GUI_CHECKED Then
		GUICtrlSetState($CmbKey, $GUI_DISABLE)
	EndIf
	If GUICtrlRead($aThinkHotkey[2]) = $GUI_CHECKED Then
		GUICtrlSetState($CmbKey, $GUI_ENABLE)
	EndIf
	;加载已经定义热键相关内容
	TPHokey(0)
EndFunc   ;==>_LoadradioSet
Func TpSetKey()
	TPHokey(1)
	MsgBox(0, '提示', '设定对应热键功能完成！', 5)
EndFunc   ;==>TpSetKey
Func TPClearkey()
	GUICtrlSetData($TPFilePath, '')
	GUICtrlSetData($TParam, '')
	TPHokey(1)
	MsgBox(0, '提示', '清除对应热键功能完成！', 5)
EndFunc   ;==>TPClearkey
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
Func SystemSecuritySet()
	Global $SecuritySetForm = _GUICreate("Windows安全选项设置", 429, 90, 100, 105, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	$SecuritySet[1] = _GUICtrlCreateCheckbox("禁止导入注册表文件", 8, 8, 145, 17)
	$MSecurity1 = GUICtrlCreateContextMenu($SecuritySet[1])
	GUICtrlCreateMenuItem('允许导入注册表文件', $MSecurity1)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet1')
	$SecuritySet[2] = _GUICtrlCreateCheckbox("禁用控制面板", 8, 32, 97, 17)
	$MSecurity2 = GUICtrlCreateContextMenu($SecuritySet[2])
	GUICtrlCreateMenuItem('启用控制面板', $MSecurity2)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet2')
	$SecuritySet[3] = _GUICtrlCreateCheckbox("禁用文件夹选项菜单", 8, 56, 137, 17)
	$MSecurity3 = GUICtrlCreateContextMenu($SecuritySet[3])
	GUICtrlCreateMenuItem('启用文件夹选项菜单', $MSecurity3)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet3')
	$SecuritySet[4] = _GUICtrlCreateCheckbox("禁用注册表编辑器", 160, 8, 121, 17)
	$MSecurity4 = GUICtrlCreateContextMenu($SecuritySet[4])
	GUICtrlCreateMenuItem('启用注册表编辑器', $MSecurity4)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet4')
	$SecuritySet[5] = _GUICtrlCreateCheckbox("禁用任务管理器", 160, 32, 113, 17)
	$MSecurity5 = GUICtrlCreateContextMenu($SecuritySet[5])
	GUICtrlCreateMenuItem('启用任务管理器', $MSecurity5)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet5')
	$SecuritySet[6] = _GUICtrlCreateCheckbox("禁用命令提示符", 160, 56, 113, 17)
	$MSecurity6 = GUICtrlCreateContextMenu($SecuritySet[6])
	GUICtrlCreateMenuItem('启用命令提示符', $MSecurity6)
	GUICtrlSetOnEvent(-1, 'RemoveSecuritySet6')
	GUICtrlCreateGroup("便捷选择", 288, 8, 129, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	$SecurityAllselectAll = _GUICtrlCreateRadio("全选", 296, 24, 49, 17)
	GUICtrlSetOnEvent($SecurityAllselectAll, 'SecurityCheckAll')
	$SecurityReverseselect = _GUICtrlCreateRadio("反选", 352, 24, 57, 17)
	GUICtrlSetOnEvent($SecurityReverseselect, 'SecurityReverse')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("应用设置[&A]", 288, 58, 131, 25)
	GUICtrlSetOnEvent(-1, 'ApplySecuritySet')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitSecurityForm')
EndFunc   ;==>SystemSecuritySet

Func QuitSecurityForm()
	_WinAPI_AnimateWindow($SecuritySetForm, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($SecuritySetForm)
EndFunc   ;==>QuitSecurityForm
Func ApplySecuritySet()
	Local $n = 0
	For $i = 1 To UBound($SecuritySet) - 1
		If GUICtrlRead($SecuritySet[$i]) = $GUI_CHECKED Then
			$n += 1
		EndIf
	Next
	If $n > 0 Then
		If MsgBox(4, '提示', '是否应用当前勾选的' & $n & '个安全设置项？', 5) = 6 Then
			If GUICtrlRead($SecuritySet[1]) = $GUI_CHECKED Then
				RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\.reg', '', 'REG_SZ', 'txtfile')
			EndIf
			If GUICtrlRead($SecuritySet[2]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoControlPanel', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[3]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoFolderOptions', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[4]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableRegistryTools', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[5]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableTaskMgr', 'REG_DWORD', '00000001')
			EndIf
			If GUICtrlRead($SecuritySet[6]) = $GUI_CHECKED Then
				RegWrite('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows\System', 'DisableCMD', 'REG_DWORD', '00000002')
			EndIf
			_ForceUpdate()
			MsgBox(0, '提示', '已经将所选' & $n & '个安全选项应用到当前系统！', 5)
		EndIf
	Else
		MsgBox(16, '提示', '请勾选要进行设置的项目！！', 5)
	EndIf
EndFunc   ;==>ApplySecuritySet

Func RemoveSecuritySet1()
	RegWrite('HKEY_LOCAL_MACHINE' & $OSFlag & '\SOFTWARE\Classes\.reg', '', 'REG_SZ', 'regfile')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用系统注册表文件导入功能！', 5)
EndFunc   ;==>RemoveSecuritySet1
Func RemoveSecuritySet2()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoControlPanel')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用系统控制面板！', 5)
EndFunc   ;==>RemoveSecuritySet2
Func RemoveSecuritySet3()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer', 'NoFolderOptions')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用文件夹选项菜单！', 5)
EndFunc   ;==>RemoveSecuritySet3
Func RemoveSecuritySet4()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableRegistryTools')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用注册表编辑器！', 5)
EndFunc   ;==>RemoveSecuritySet4
Func RemoveSecuritySet5()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Microsoft\Windows\CurrentVersion\Policies\System', 'DisableTaskMgr')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用任务管理器！', 5)
EndFunc   ;==>RemoveSecuritySet5
Func RemoveSecuritySet6()
	RegDelete('HKEY_USERS\' & $UserSid & '\Software\Policies\Microsoft\Windows\System', 'DisableCMD')
	_ForceUpdate()
	MsgBox(0, '提示', '已经启用命令提示符！', 5)
EndFunc   ;==>RemoveSecuritySet6
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
Func GuiSYSCMD()
	Global $FormSysRun = _GUICreate("SYSTEM用户执行操作模拟", 448, 80, 85, 100, -1, BitOR($WS_EX_ACCEPTFILES, $WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_MDICHILD), $Form1)
	Global $HCommand = GUICtrlCreateInput("", 12, 16, 369, 21)
	GUICtrlSetState(-1, 8)
	GUICtrlCreateGroup("输入要执行的程序或系统命令", 8, 0, 433, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateButton("...", 392, 16, 43, 21)
	GUICtrlSetOnEvent(-1, '_LocateFile')
	GUICtrlCreateButton("以SYSTEM用户身份执行[&R]", 8, 48, 433, 25)
	GUICtrlSetOnEvent(-1, '_RunCommandOrExe')
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, 'QuitFormSysRun')
EndFunc   ;==>GuiSYSCMD
Func QuitFormSysRun()
	_WinAPI_AnimateWindow($FormSysRun, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormSysRun)
EndFunc   ;==>QuitFormSysRun

Func _LocateFile()
	Local $CommandExe = FileOpenDialog('选择要以SYSTEM用户执行的可执行程序', '', '可执行程序(*.exe;*.msi)', 1)
	If $CommandExe <> '' Then
		GUICtrlSetData($HCommand, $CommandExe)
	EndIf
EndFunc   ;==>_LocateFile

Func _RunCommandOrExe()
	Local $CommandToRun = GUICtrlRead($HCommand)
	If $CommandToRun <> '' Then
		If @OSBuild < 8000 Then
			Local $tProcessInfo = _SeCreateSystemProcess($CommandToRun, @WorkingDir)
			Local $iError = @error
			Local $iExtended = @extended
			If IsDllStruct($tProcessInfo) Then
				TrayTip('提示', '已经成功模拟SYSTEM用户执行操作~', 3, 1)
				Local $hProcess = DllStructGetData($tProcessInfo, "hProcess") ; 进程句柄。
				Local $hThread = DllStructGetData($tProcessInfo, "hThread") ; 主线程句柄。
				Local $iProcessID = DllStructGetData($tProcessInfo, "ProcessID") ; 进程ID。
				Local $iThreadID = DllStructGetData($tProcessInfo, "ThreadID") ; 主线程ID。
				DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
				DllCall("Kernel32.dll", "bool", "CloseHandle", "handle", $hThread)
			Else
				TrayTip('提示', '模拟SYSTEM用户执行操作失败~' & @LF & StringFormat("error=%d, extended=%d\n", $iError, $iExtended), 3, 3)
			EndIf
		Else
			RunAsSYSTEMWindows81($CommandToRun)
			If Not @error Then
				TrayTip('提示', '已经成功模拟SYSTEM用户执行操作~', 3, 1)
			Else
				TrayTip('提示', '模拟SYSTEM用户执行操作失败~', 3, 3)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_RunCommandOrExe

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

Func s2er($iResult)
	If $iResult Then
		Return 0
	Else
		$iResult = DllCall("Kernel32.dll", "long", "GetLastError")

		Return $iResult[0]
	EndIf
EndFunc   ;==>s2er
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


;以下代码由: 'File to Base64 String' 代码生成器 v1.16 Build 2014-06-05汉化版 By 虫子樱桃 生成

;以下代码由: 文件转换为Base64字符代码生成器汉化版By 虫子樱桃 生成

Func _MakeLogo($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $MakeLogo
	$MakeLogo &= 'mLxAQk1A9gEAAQA2BQAwKAAwZAIAAEZRADgBABgCuAoAfBIMCwACDAUAyZcuyACXLMaVK8WUKgEACsOSKL2MIq7AfRa/jiTGACICBADIlizKmC7JlxAty5ovAATMmzACzQIEzJouypgtYMiWK8mXAEABEMUAkyjGlCnKmS0Az5wx0J4yz50RAQXRnzMAAtKgNEDOnDDLmS0AAs8AnDDPnTDRnjEG0AAgASMxzZwuzAKaABosyZcqypgAK8+dL9KfMdIAnzLRoDHOmy000qAARDEAAgAU1KEAM9ilN9mmONaMozUACwARz5wuACMBAAXWozTZpjfYAKU216Q12aU2ANqmNtmmNtejgDTYpTXWozOABQMABAAB16U026c3MQAB3ao5AAGDBdyoIQEB36s53gAKqTgA3qs5058u0p4GLYACAAHXpDLirgA846894q064wCuPOKtO+CsOgDfrDjhrTrlsRA+5rNAAQGyP+UAsj7krzzjrjsA4aw54a053aiANeCsOOKuOgABQOSvO+ayPQAB50CzPuaxPOcCBOkAtkDruUPquEERAATptT+AAuizPQDhrDfRnCnkrwY5gQgAAbQ+67hBAOy6Q+y5Qu27CkQBAbwBAe69Re0AvEPsukLruEAC7AABuUHrtz/rALU967Y+7btBQO++Re+/RkAB8CC/RvHCSIMA774QRO66QYAA8L9FYPDARfHAQAeEAO8AvkLvvULuukAA7rg+7rk/8L8AQ/LBRfLBRvEAwUXwvUHywkYDggOCAMJG9MdK9QDJTPTGSfPER4FABPG9QfG8QEABAYAD9chL9chK9CjHSfWAAMiBAPTFMEf0xkhAAUEExkiE9ceAAEf2yUqAALj3y0yAAMMCRQRLhAAAzUz0v0H0vkABgQC/QPXDRPjPAE740E/4zkz4BM5NgQDNTPfMSoFAAfnSUPnTUYEAAwACgADQTvnPTfgAzEv4y0r3x0bA+MtJ+M1LgwDABQGBANJP+dBN+dEATvrST/rUUPsA11P61lH601ABgQPTUPnPTPjIgEbvtjj5zElCBBBP+tJOgglS+9UQUfvYU4oA11H7GtQADk6BCUMKzkv6IM9M+9RPQAf82eJUQwH82lWDAEAQwQjg0k771lHBDoAAAAIFgwDUwAVN+s9L+iDNSfrOSoAD+9YCUMEF1U/60Ev7fNVQwRSFAMMUQQcBHU3xgAz5zEhAAcAB5BQAFntAAKAG1cETwQSgEqAA0XpNQgBMAxbDBEMSRADTA6IAYATTTvfFQ/d8xEJDAGAiQSShJKADTsEBKM5M+c1KoACBAmzUUUAAAitOIAKhLcsASffJSPbFRPdAyEf4ykn3QADJ5kggMkEAzEvBAQIBoTkdwDrOwECAAqE/9sdHAPTAQeavMvXCsEP2yEhBAKBFyCAILksHRmABQwDJwExI9ATERkMA88JE8r6AQfK/QvPDRcJPDkqhAAMBYQFK88NGKPLAQ0AA8+BZwkUM88JFWoBcvkHwuwBA77k+7bY87gS4PWBe8b9D8L6QQ++9QcIBQu9gagNFAOBl8cBG771DAUBp7bg/6rQ76ASzOkAA7blA77xgQ+67Qu3gAkEAQBsgAuBx7AJzoADqtT0RQADptTxBdbY/60S3QEAA6bQ9RgDqALY+6bU+6LI8AOi0PdynMtumgjFDAN+qNei0QAMAP+izPOezPeUEsDxAit6sN9+sADnirz3grj3eAKw826o62ag6ANakN9SiNdGgADTQnjPMmy/OnaGrM0MAgAJDAM+dwAEBAQHTojXVozjSAKE10J80z540EaAAzJwxoMC3hh5Ax5YszJwyQADLYJsxzZ0zoAOjAM4BRQDPnzXOnTLOA2AEYMGcMNGfMtAgnjDOmizgsNOhfDHYIrDgsEAAALJDANRgoTLQnS8BBCC5oEgx06DhudGeAMEwAM6cLcyZLMqXACrIlSjJlinMAeIIz5wvzZstyeCXKc2bLkDDQwDAxAPgxcAN'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'wI4kwY8yJaAGyJZgEAAWMM3AmzHNnDHORQCAEfjIliuAEaAAQAAgEeIRE6AYgQLJlyEXzZsviM6dMEAAz50xQwATIAJAANCdACUz0Z4AMtKgM9SiNNA2nuACgAUuQCGgJM+cIi/AKNShNEAA06HtwAQxICZgK9RhAWAHoQMRAC7QnS4DAdajNATXpEAANdilNtk0pjdAANqgAGABpTYA3ao63qs72qiAN9ilNdajM0AAI0A2gAXbpzdAANypADjdqjnbqDfcAKg33ak426c2AN6rOeGtPN+rADreqjnjrz3jgLA946883amgCSIzQADbpzVAAN6qADjeqzjapjTdgKg236s44KwgBQA85bE+5bI+5glA4bRAQwDjrzvdAKg15K875rI9POeyouRC5Gblw+XmsX48wGEA5cDlYOXgYkIAN8fA5YDmoGbruEEG5WnlIO27Q+u3oORB64+C46AA4nFh5e25QUAAxyF3QOSC4+++RUAAgOPjZuWg5PHARmPlAAEAgsdBAKCBIIa+Q/GAiaDk+8HowARFYeVgi2EBBOUAjmbxQJPgAr9DAEfhcsYeSYFyIwDgcqFzSvbMwSBOTvXJSvUAAoBy+sQgS0RQALZycU+wcuIAgSB1981M+M9PUVEyzIEA+NAgALFy9cTmRSAAsXLHRzBWkFZCc05IQXNAWCBy0lAiAE+I+dNRIAD601GwWuuBXbZy0eBgUIgAsXIhAOrOcmHWkGVQAV9gX4BgisrwX0hAc/nNSnABP4dyJgCwciEDsmZzZ9FN+ZBo+s+ycqJnN3EhAIdvmXQB2FPhALNy1VFRA39TchAEsAODb7Nv1ASCctH/8nEjdbMGQAcxdNEBhHIjAJeDBlAGkH3VQgrPTLFy30ANIAO8ciZyEQFRAREQAfmAANZRAAKzcsEUIISQcfrMUG9K5ACwEsCG8BfTiMelFiAAUHL2xES2cmN0+1FysQBMQRwgAFCQAx0SASexcoByIADBQeBy9MHeQrAA4CGEcrxyyKKXs3IMwkQgcoBy8r9B8n+wcmBxsHLwcSAAICchAEfPIwDTnVNygJ/zw7Fy4C2G8CByU3K6Pu+8saIfg3IxpEBwsHJgdLxC7iy5PrBygHLtUHK2PMOxcnBzuUDtuiAAwHReQrNy0DcRrCCru5CqRMejrCBysHLlsDlQAIZy27Nyg3LnIHJBAUCAchBzAYAA6rdA6bY/4mStOVBy2qfxR7BO1QCkNs6gM8aWLiDClC++kVFvuY4AMLiOMbWLL7Qgii6zijAgALKJgC+thCuofyZQABSuhiAALCMArYUrIyAAgACsgysjAKmBEihQAK2FEQGofygApX0lpXwkpHuAI6N7JKR8JOAAwKqCKqyELCEAMAKChRAELa6GLa8hABArr4UpkHS5jCsAvpAswpIsxJPwKsiXK2BfwVkCcSFy/qIhAABxIAC5csBc4ABQAN9wARABgHIgAIJyKYAAAXexgnLOnC+gcLFymoFyRMmWgXLKlytQAMb8lCfgZhBzAHoyAhFzJgCfAGiQaEBqsHJQCcaUwG5iJyAAwY8kEHO0cpSvAHcAdHABJXKU8GssgHL8w5KwbHFt8HSwclBy43Jx0HPIlyywckABtXIk8bByv40jcAS6cuhyMAhPM3GDciJ+UAAqyiB+mDNQfoR+zpyBclAA0J56MuFynLRy8HHghLBy0S6fcAHABZACLyOEzZqALNKfMtekNrFyxxAW4nLAAtajNcNxUAAvg3IjABAZ4nI1hHKnOINQcuEApTbcqTmxcsancAHAmDHVopACEXMY2aU1UHIgAN6rOmFxc6g326kRc1By4QStO+By4q0847AiPiAA4q47s3LXogYxsCqwAN+rOdyoDjYgAINyAALksD3mhLI/IQCzP+e1gXIBgADksDzapTLigK465bA85rHickEgcrQ/6LVA4KLnurLQozywciMAQjFAMOYHs3JQctPl57I867cdu3K9tXIwOKDlt0Dr'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'gQjOTPqASgIu7YJ0TQQBAA3RAjoCKAFAiQAE1VIBgs5M+IBWD4ACgCYABIAIz034zYBM+tNR+dJPAweDAQGAj81M98pJgJKO+AEQABaAvEn3ywC4AEn2xkb2yEf3yMlI9wDByUkBuIC8rwDfAAcC0IECzoPaSoDazPbJguMA6MhJAQECBAD0w0Xzv0Hyu1A85a4zhQAygADkAqyEAOOsMuqzNwDrtDjxvD/zwQBE88JF9MdI9ADGSPXHSvTGSQGGAPK/Q/C7P/AAvEDutzznsDYA5K0z5q817bYAO/C7QPC8QeoEszlAAfG+Q/C+AEPxv0TuuT/vALo/8L1C8L9ECPHARUAB775C7wa8gQNAAe+9Q+66AEHuvEHvvkTuEYID8MBGQATstjwA6bM76rQ857EAOeawOOu1POcEsjpDBOu2Puu3ED/suEAAAuq1PUTqtIEA57I7wQK2ED/ruEFAAeiyPAjqt0DAAum0PuYgsTvkrzlAAeWwAjoAAui0PuexPADkrzrptT/lsgA94q482ac50ACgNsaZNJBtJDhkSRm/AL8AngCHZAAesYQmtogktwCHH7uKHsCOIQDIlSfNmizOmxAtxZMlAALPnC4Az50v0J4wy5gAK8yZK82aLc8gnC/QnTBAAM6cgC7Mmi3OnS+gAATNm2EBzJstzpsAL8yZLc2aLtAAnTHKmCzHlSgAxJImxZMnwpAAJMGOI8aUJ8MAkCXFkifEkicAxpQpx5UqyJYiKwABxZMoQwDDkSAmxpQoxuAClywBQAPDkSfHlSvIAJYsxZMpwpAmiMGPJaMAwI4kIQIAkSfBkCbFlCrCwwAHkijCkKAMIAsIKcORwQHFkyrKIJgvypkvQAnHljAsxpUroABACcqYRC7EognEkiiAC8k8lywAAcABQADDDcqaUWAZL82bABwxQwDPAJ0y0J4zz50xI6AAwAHMmy9gAc6c5wAEwASAIzLMQQYAJQAEBSAFMcAf8ubV//+A/9+8fdKgM0AAAYAC0Z8y1adJ/AT59eECu33UoTNA1KE08ePLwAH3AO7h16lK06AyANKgMdajNdWiEDTToTKgANSiM3GAAtWiM0YAgAUAANggrlvoz6ZjAfbqANfhslDeqzvdIKo66cSBIALs0wCo2KU12KQz2cClNd6zXvNCDAAAQO3Qnd+rOkAA4QCtPOCsO9yoNwDeqjnfrDr26oLWQRKrOd6qOEAAAOCwTdOfLdikwDLgrDnrxgEKoQwQ58z9+iEX+vHhAOW0UOSvPOWxMD3msj6hAEUA5bAAPOWyPOezPuZEsj0AAe7Kg0Eb5QDD8MyE78uE7wzKgwABQQDNhe7KgILtx4HuyYKCAiKDAAHtyIEgC/nsAteAbuy7Q+27REDtvEXuvkZBAL3BAQHwwUjvwKIAIQIaRIECvSCAAAFE8MAQR/vu2GEN3qzwAr9gBEbvvEPtuSRA7wCFwUdDAPC/gEXxwEbxwkdBAALDIAJG8sNH/vsO9qMbHwAaAPjUb/YAzE72y033zU+g9s1O9cignEiApDcA5UMAAuVKAeUA4sxNwPfOT/fOToACwKkfQOSC40LnoKuAAslK8+C9P/XDRICwA+Lh4+EB4lD50lGgAIECA+U34gIEASECTcTl5eb61z5UQQBg32HEoNUBAfrW+lNixEuBxWAEgdQhy4PLx0ADAOUgzvvXVEDYQQBBAwHaVvvZVKEA2OdgCpF0YQLWUcFuEAGwb/8waxJ20AGwAAFu0nAjAFFs92JxMgKgc1FRAOYAggARBJ7S0gcgCYAAMAXTT1Byr/FxJQDXCmF0SjEC1vAFnlRQADML0Q2TccxJsW9/4m+TcUEQoAEhD9EQ8XHNH1CHInKSdIFyUnL0vT7o9cNDsAD4sAYjGDMX/3IWo4shcnBz4o0RjsBxMI+VsY1KsAD1ggD4z4IeB/GPlB0hAMtM9MRGGPPBQxAicJT1x0hxIHLyv0IjALFywCPG4kmwcvXISyAAsXKy'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'wn9jQAGQcem9ZLZyIADwRNOecwHisU1gL+REsTxTcue0QLFysOe0cgB0t3LMhfFxsHKAcgHAccuD7sqC7cdOgSAAgHLhAMiB4HL6zvCxcjA18XG/RxFztXLy74BvwEghAHJzhHIAdEK+cHND7r1Es3L3xN2sEAHvvUTgckCyN4AAsnJgAkSQcRG1wEaPwHEhclJyswD21YgRDQT47BBw+OCt+N+wrPjgrFQAIQCtcAEjKQBAAfzx2eEV14ktsHL2UHJQAMywck729MtN8XHHIE7iciMA0HMZEFLKTFEAU3LMTfaPgFQgVLMAsnL3zUxRAM1wAcuQyxHK+M4gWoNyn+BvUXIjALFygFrJSSPP1wF0MnSxcs61cs9wYWBxZRBkVFEA1VJwYVEA0zcFYkNk4GPRsgDicvfJxkggZhBn+9lW0nC1cvrZIABWIQAwdINy0wFQAP/wcYBvgAATc4IAkGtgBRMBPPvXogFQAFBv4ADYVP/QASYAJHKic7ZyUHUCcWRx/9ABVHLzbhAK8m4ictMEUgn/8ghRcjICsXIQcDCDsgDwAv+xEoADUHLxdHJzsBIwFLNyTs5A4jARQHNM9xAZyJ5ItuS3csKJoXDERfCM/yFywOMiG1Mb4uSxcgHmKR48y0uQIMCSUJPhIcVHGPPAQyAAgHL0xUaBE+XxvEDxuz+wAMExI8lM9MVIs3LwcfD1yUv0EHNCc5GbgHL/IpzkchPlFXPwceBygOSAAHeB5FLkUADuouWxcvCkvztBMSEAvDACouWCAO25HkCxckDlUgBD5ey5QQdUciAAUHKzPOu2P5eAACByETq7cTrrubByzkJA5VNyceWwOyMAROWIsz7mUgDlsj5QSAjYpjhx5Zg1aEwOGi8ALwAlABa7CBpoTHkgtYotvwCSLseXL8ybMADSnzLToDLRnwEACDHRnjDPnS8I0J4wAALPnC/SAKAyzZotzpsuEQAC0J0vAQWeMMyImi3NAQgxz50ALBMAJgECzZoAIy/LmQAtzJouzZsvygCYLMiWKsmXKkEABciXKseVAQLJRJcsAAXGlCkDAsVgkyjIlisABIALzASaLwAcy5ovypkALsmYLciWLMNgkSfEkiiAAgABwsCQJsGQJsIABAAKBJMpgwLFlCrDkhgowpAAE4AFK8WTKioBBJOAMi4AAceVECzGlSuAEceWLMDIly3HlyyABQAcOMWTKQArgC+AKcCOgCTBjyW/jSOABYTKmQBqMM6cMYACI4BfgALQnjMAAc+dd4EIAE8ADc4AEIERAAcuEYALz54xgAXix5gA////7Nq+0Z4QMvLm1YAF37t9QNKgM9CdMQCRzQCbLc6cL9CfMRjgvX4ADQMA5cmZyNOgM8BW06FBAYBUQYBd0Z4v06EBYtTEoTNAAdWiNAACQAEI1qMzQw3WpDTZAKY326g53qo6AN6qO9+sPOzQBp3GFAAA+vTr6cwAm9ilNdmlNdoEpjaAANunN9ypADjdqjngrDveQqoADjnfrDrAAuEgrDv26taBKqs5AYMA4Kw64q079wTr1wAF8deq5LAAPeWxPuazQOYgsz/msj8AAvbmAsyABu/WqeOuOwDmsz7otUHnswI/QQG0QOaxPegAtEDntD/nsz4Y7sqDiSQhAPjr1gDlsDrsukLtvBBF7r1GQAHtvEQRgADvwEiBAL9G7iC9Re68REcBvUUA7btD775F++8C2IAP9t2r7r1EAO+9RPC/Ruy4kj8BAsFHgQDARoAAAO68Qe+9Q/DAAEXyw0jyxEnyAMVK8sRI8cFGGPbTh+0pRCvaivYgzU72zU+EAMxOAPXHSvTER/TGgEj0xUf1x0kBAkzGSAACgQDISoAA9gjJS/eADMpM9stATPfNTffMgQD2AMpL9spK98tMHQIBSwABQQOgAM5O+AjPT/igANBQ+dOAUvnTUfnRUQABAPfMTPbISPfLAksAAfnRT/nUUoj50lGjAPjPTmEBINFQ+dBPQAD6'
	$MakeLogo &= '1WBT+tZU+kADYAfSFYAIUWEB1AAET/jNEEz5z02hANJQ+CDLSvjKSaAA98kCSKAA+tVR+tdUKPvYVaEA1yAIU/sk2VZBANhUYAH61X5SpAADAWAKAAHABKAA0xJQoQDUUeAC+c1LucAB+9dCBiACgA7QoBUwTvrUUAEKIQtU+o7XQgagA6UA+dBNQgB3IQVBG0AA0AIBowCCAvr/ABngCOAOIAvgDuEIQgCADpPpGqAAzEtBAM1MQQDdwAHPIAvgI6AMTgMKwCWxQQDNTPfCBEEqy0AG6Ez4zuAvS6AAoQOjACjRUPjgBdBAAFD2IMlJ9cRFQDD2yJRJ9yELT+E1zk4hOGsgAuM4yWA9SmA9wT3JR8EBY0BgAfXJSqBC8yTCRUEAwURgAfK/AELxvEDxvUHxTLs/AAGAR/THoEVLZaAA9KFISfRgAcEBSUDzxEjzw0egAPIgw0fywUZAAPG/gkQBAcNG8cBFYAES8EAAvkNgAe64PiMCAeACRvC+gGJD7QC5Pu65QO69Qgjwv0UhYr9F776AQ+26Qe67QqQAoLlB67U9QgA8wGcA67c/7LhA67ZaPgAB6qIAYQG24AJAgulgBLdA7LlCoG8I7btEQADsukPrALlC6bQ+5rE7COeyPKEAsTzkrwI6QADmsDvlsDsM5rGAAkEA5LE93wCrOtimOM+gN8DCljNpTRpfAF8AB18AXwBfABq0iSy+IJEuyJgxYOXRnvIxYeWeMKAAwLXE5YHg4i9AA8qXKkDkAAFAAAMgAiC/ypgqypgreMybLQDlwMGAwoACy+CYLMyZLSBy4HJQAITHldBwKMaUJ4Ny+MmWK1AAk3Fyc1EA4ADkxZThcsqYEXbwaLBy8SAAyZctEG3wa1NyUADxEG3AjyXgchZzUHJBcwaQAAKxAL+OJcCO0iWwAMaUIAYrEATQcDFQcsaWK4ByIADJmMYu8AJABMaUKiByUAAAvIogsX8YtYNuGSAA4HIgBsfgCVAJl94rJQkQc9B/kHcsIAATcztBc4AAm/GA4A+wctu5InwgVPPn1QCD8udxtHLnzqYQASAAEAHxGuYgANSjAQMA9u7gOPTo1iIAAQIkAObVQNGiRM6bLFAY1mSjNbRyozSAAFMD1yCkNdilNuBy3KgQOd2pOiEAqjrqxM6c0wHp0aZQdYByINWiMtSgMB0u1iCiMtejM7AA1aEIMdilcHY126c2CN2pOEAr4a0893LqYXHequAAAHThcuEArTvmumLv1akPgHIjAOByIADjrzzhIK467tWo8AL9+gD13qk14aw54gCtOuOvO+SwPATmspAyPeKuOuMgrjrlsDyzcvTbAKvqt0HptkHoILZA6rhCIADruRBD6LQ+QDTptT8I4q04UADfqjXTIJ4r9enVIADircI34HLqt0DqUDmgOgC3QOu4Qey7Q8tAcIA57LAAuUGAcrAAueNy7byhAbdyYEG+QEBORbA/MUGAcr9GgELvAL5E7rpB7bc+EXBA7rpAgUK9Q/EiwhFG9dOG4Qz37AD33Kr33av33BCr9tuqsgCq+N/ArPnhrfjgIACBACUhAOJRAPzw4Qb31xCI9clMIXLLTfacy02wALNyMVDDRvRQIMBD8r5BgAD0w35GIFGxUWB0AnThVGFxTvdQAFNyIQDL4nKxV+VyE3NM0FAhAABZzUywWvbEx0exWsdG90B2sl27IQCQXM8QWwRfEXPSAmXP8WshclAAIQDVU5BiMHEHwGLAcbAA9sVF8bkQOvW+PiAA98hHq3Bz5GnS0mrSEnDWcG3/QXbRamFxoG3CBfNx0AFDAX9wdmJ0sANAAQFxsABTb84ATPjLSffJR/gfYHT0blAAsW9RA9JP+CzMSqABUQDKIHtJ+P7MYQiSAscI5ABTCQMIhnuf4glhcaB/IACwb8pJ4Aw49sREYA6wAGAO9sZ7EBPgbEo0dKCFQBOgE8z3hHJAc1RyzhEBhBUhAIEYAVGKy0r1xUb0w4JE4HL0'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '0p8ygYAA0J0wz5wvgABA0Z8x0qAzgADTBKE0AwLQnTHMmQAtyZYqy5gsyQCXK8uZLMiWKgeAAMACQAHHlSnKmAAszZsvzpww0ESeMoAAzpwxgwDLAJkuyJYrxZMoCMSSJ4EAkyjDkgAnw5Enx5UryQSYLYEAly3KmC4RQAHIliwABcWTKUEACMWUKsOSQAooQMKRJ8GQJoAAvwCNJL6MI8GPJgODAMABxJIpxpUsJsOiAOAFyJegCS/KEUIAyJYtoAPFkyoh4ALHlSzGwAqVKkDHlizJmC6AC8TskylAAEEGloAXgQ6gAGMDEKAPxpQpoBIgF88KnQAZM0IAMtGfNOOgAGAZzJovoAADAUAARM6b4R3RnzNAANKgoDTToTUiJjTBJUCaLs6bLs8AIp1EMc4gI5svz8ArnYAwzpwu06AzIC8A1qM12KU42aYAOdimONajNteApTfYpTfTokAJAjFAANShM9KfMAFAANWiNNakNdkApzjaqDnapziI3Kk6pgDbqDlAAAFgAdmlNtmmNtqMpjegAEAA2KU1oAAA26c33qo62qYANtyoON+rO+Kkrz5AAN+toFc8QADA4q484Kw7RgCBAgCsO9+rOuOvPXjksD5AAAABYAQAAeYAs0Dksj7ksT5BoADjrzzlsQBkPwdDAGABQADntEDntYBA6bdC6rhEQwABYAHmsj7nsz/nALQ/6bZB6LVAROi1AQHquEOhb7MFQAM+QGzptT/qtgeBbkBvA3DotD7ptEA967lC7b2Ad0cY779IoACgeO/BSYjvwEdgee27RKAAgOy6Qu27Q+3jfQTAR0MA8MFI8cMESvBghcJJ775FAO27Qu68Qu69weCJRe68Q+8AAUIAI4ACAYvDSfJBkEz0LMhNoABiAUugAPHDQkfBkb9F8cJgl0QNAZrC4Jhhl/TJTfR0yEyhAMfApqEAwAH1hMpNQADzxUnzAaNnoKLBo+Skx0pAA6KlS9EAqffOUEAA9gCvJKpeTkGuRgAgrYCzysC4T1j3z1BBAAABzaAGT0z40CC8ggLQUCQCz4+gz0EAYQTAAdJS+IDd8SDI1VX6QgBgAYC8YeKPwNNgykEAxM33zUwjy3+kAwDNAQGiA6HP4AJg3FFY+tZVQ+Qi5lUCAVW/QeqgDKAAYetj5aDqVYEF30AARN5hAQAEguNOwdxgAc8BDUUA4AviCPrWYgdh8XMBFoPg+NHg+ALlIAXO/UDYS4PsZOWjAHN/4nIxC5zRUSNy4XKAcs1NgXK8ykswcaANoG1TgflREv5SAgghALlyInLhAIAD8XGPsADycZFx4XJP9swgcv2wAEyAbyByEnMhAOFyUB5LsXIgHk23cslMMCDzGsVgI0iDcoQAx0vx/MBDgHIiACByUXIgcuNyiPHBRoBy8L5CgACvJ3KBAOADwClJkynwIHKcvUOEcoAqgHK/RiEAYeRyR/DARwAv8XG4Pj/gcoAwEHMjAOBy6rYsPe3gM7EzRFRyvUXG7NA0kjXqtz8AOIBywOm0PueyOyAAgAD46bU+s3JTAAE7UAAgP38lAFByQHPgcoBy8HGwcuMErjqAAOeyPt6rEDjdqjmxcqE5wyCYNn5dHy8AgF4CH6Bqg2AghGEgAfBrh2MhiGUiyPC6gPv6UHKAbywA428A1ff0yb6tbY0AaSSMaCOrjkxY8/DG9XEjANcuANhA7enAkGojIQBryiQgAJElAJJsJwDgAACPaiONaCOKZggitouzcjLQnzT00qFAcDCwclNyVgCjcybRUACCctKgsQDNmoAuypcrypcqYHESy3BzlysmAMeVKBcQAbJyoHYxIADNmzAxlmXHlipQcuByxZQhcHAmw5EmgADGlX+gahRqUAChc1IAJgBQcsIhUHWSKMGRtHLAjuIlUHLDkSiwAIEAUHJElCtQAMWUK+Byx/6WsXIjAMB3gHLQAbNyUADf4HKzclN4oHOhAZZAAYByGCvIl6B/JADEkihYy5ouiHKz'
	$MakeLogo &= 'cjPQc8n+l4APgXLQDaANYA6wgSAAv4NyUwDgEoAAIAOyci9AE2MjAINyzZsuIBLAFNSkoTSActek0G05gABVsXKk4XLUunIx8HTVGqOQAjeBcrVy3ao7PyAAg3IQASAAsHKActuofZB3NnNz4HLgALBygADWBKMzsHLjsD/grYo8IgA7QHDirj0kcvfRc4EA4gA7I3JQAENzUAB45bI/gXIiAMNxEAHnHLRBMHTjcrJyQei20bdy6rlDQAHocAGycv9QAOBys3JTqKBzgAACdIByDaA3QeFyIAC2QOexHjwwOyFygHK2csBI7uC9Ruu4QYJycT2wcn9jPiAAUHIgAONysXKwAL7+RrJykAJQdYEAQXPAQbIAk4BFUEXyxYBIS/Ozcu7EcEmhSbtyRRC+EAHwSschcvFxsXL1yk4gAHFzuyAAEHPHcASDcsC/SbIADVAASHDEYnRI88JGwPXLTffPUQJxsHL/8W5xcyZyIQCkc5FZBALycX9ZACUAgXJhX/BooQGyclLncdNQcrNy1VQ147Jy1nC/wGhgYrFjImP2awHgUHFnZ+B4cNzR4lb6suS1clb/sGwBd4NyYmsk3kbo4nXR4t1xAVKH5Ebl4W9NceuCe/nxAtVUgwOycuFys3Lh7X2xbEwTBMRxtnLwBSAA0/5SoQ2yfrJy0X+zclByJHLBsHLJSvXHSIAA8BH/BYZygoAAZHEiA8NxI28icn9Dc1YAs+QnAPIaUXK0ckx/IB62ctABQ+UjcsEgpJRLH0DlEuWg5bNyIgBwuyDER/HBRgEgwEUA77tB8sNH88UQSvPGSwEQxUryAMVJ88ZK8cNIAO+8QvC+RO++kETwv0UBFMBGAiAARfHCSPDBR/AEv0YBCsBG779GAO69ROy3P+y4OkAACusCBAAWAArqtQA96rY+7LhB7RC7Q+6+AExF778iRwAK7LpDABHtuwBE6rc/6bQ95yCyPOm0PgEFtT8A6bU+6rZA67hCQgAC6rdB6gAIuSJDAALptUAAAui0AD/nsz7msTznBLI9AAjksDvkrwEBAuKtOeWwPOYAsj7dqjfXpDQA16Y5z6I6wpYANIBeIIJfIIQAYSGGYiGIZCJAimUii2YjAAKMCmcHAY0DAWgjlXIALr+ub9/Wp/Yg88n//9YDAfz7ANLj26/Ds3OWAHMtkGoklXArgYACtJhW///YDgEC2Q0B/tmjfzqUqG0llQMBbgEBlgEBUiYAAZdvBwGYAAFwACa2iy7AkzDKAJoy0J8z0Z8yQM6bLtCdMAAB0QSeMYYCz50w0qAiMwAB0J4xgBHRnwEACjHOmy/KlytAy5gsyJYqAwHJRJcrAAHHlSkAAcoAmCzMmi7PnDEUzZsAHzKAAsuZLhFABMyaL0AKxJInAYAAxZQpw5InxgSVKgACyJYsyZdGLYAAAwLKmC6AAMcClUATK8WUKsSTgCnCkSfDkiiAACDBkCbBj4EAv40IJMKQwBEpvowjALyKIcKRKMeVIixAAcGQJ4AAxJOAKsaVLMmYL4MAGMiWLUAHgADGlCuBQA3HlivJmC6AADjGlSsAF4AYAxrIlw+AM4oAwAVAAc6dMtAcnjMAMkABgADRnzSRwALHlSoCNS/OgzkMnDDCAsFK27Vu5xDPp+jQgQDdu30Az50xzJotzZswL82aLsBNgADXrGBb3bp83IIAgFTTIKE02KU4gADZpgI5gADYpjfYpjgY1aM1gABBW54w0wChM9CdL9KfMADUoTPXpDbaqII5gQCnONypOoAAQN6rO9uoOYMA2QCmN9qnN9qmN4jbqDhDAdmlNsCnANuoN9+0X+G+AH3lzaTt1KjwANeq6MF04K08AN2qON2rOeGtADzhrjzgrDveDKo5gACAA+OwPeMgrz3jsD4AAuvGEIHrx4KAAOe4U0DksT7ksT2BALABgQDlsT7lsj/nRLRBAMLmsj/ACPEA16nx2KrvzpEU57WA0kSDAOzCZgDx1Z7z2avz2QCq'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'uUWkbdiqCdE0rjq2cvTcrO0AwFjsvEfsvUYc7b0AcSEAQHPtvUfxIHLru0Smc7A8s3IgACO5coBy7cFlxhTxyQBq78BI7r9H8uTPhbRy3axQciBy8ETBUQC9RfHDSr5yAEoASvDAR+y3Pu3guUHvvUQQcxBJMEqDgEvhcsVK9taJVgaI99eKUE70yE1QTmD1z2354tQEMRfsPs6gc7BRUG+AcrFyyk390nBOUAC2csBxI1dSdQIC8xJz4Ff3zuBd4nISc+NaUyAAMHT3zsB3TcFcyTtgaDBrU1AAIADhdctN95Bc8F9zc/bgY0NzEHOgcJrVIGxVMGXhYMhKsHJ/AGWkAXBq0AEwayUAUWnW/lazaYdsMHGycpJxIWwhb87TAAihcIBp+tawcoVv/3ABhnWFAHRtsHI1BRQHsQDBogTPUPTFR7EJQAr8xkhQb/ECEARRDLIMEgfXYAuxAKRwUFQJzyEAYHG/E3OyD8B0IgBhdKAHUAVx/xFw4xIgAEEBk3FxcwGJwBTPQxkCjCCN8nHESFONURs3EAHhAMACTmNxcHDyxGJIcHDxv0SAACIARzNgIOAh9MehH9EfyU2B8HHvvELuu0Gxcuy+RFNycXbGcZcRc7Vy81AAwHHwwlFyIwBicbFySeFyvkTkcr5GgHLrPLc/EC7xAvB00KC+Rj+wovChgXJQAIMAEHO2P9+AciAA8HEpAIJyQ3CpAHEA4aw34q045bCNIG84YK3gcum1QJFxHrZRAFByoXPicui0QBjotUHgchFzsj7nILM+5rI9UHLjroI7snJA57VA5mBBALE/3as71aQ4CM6fOLBytoctt5ElALiILiYAuYknAAMw4GvgL9rOf/bzF4AzMXEuAOlQAOvlv9jOoUZAcHRwjyEAcnC5IQDDkCQA4G8jAMUjAIqSIQDGIwCTMccoAAjIlDIgALOIK76QkS/HlzBiMc+1ciMgAKDlz50w4XKdMZGAcsqXK3DQ0p+wcs4yYAKSAuFyypjQ1iEA/smRbuDhVADAYiMAEmezcgVAai6Q476MIsCO4iQQc7+NI2DdpuWgAf9zc9F24nKwcuNyIABwbaHofJMpUHIRc7FygHLEccKMkigQATBxu4ohUHIjYHFz5biHHhABuonwILWEG7MAAHTA6TDpn/AFk3fABTEIsO2XLbJyvaBwMmAL8HEgAJBxyeN7AbAJKrsAly3IlizHlSsDACAAgMaVKsmXLADKmC3Lmi7MmyAv8ufV/wIA2rgAe8+dMtGfNM8AnjLOmzDOnDBA0aAz58+mA3TzIOfVz50xACjPnAAw0J0x0Z4y02CgNNKfMwM6AADVAKM21KI10qAzGNOhMwBYAyjPnC8Azpst0J0w0qACMgAX3bJe/fr1gQYy9urX+O/hBg4BAAver07cqTraAKc42KU24LlvAwksCQDs1Kjt1KmBAwvmwYDbpzcAAkDdqjnjvHAJMvoA8OH469f79ewBhgj58OHmtlLiAK484q475LE+AYQ77NfcqDbksAA95rRB5bE+4QStOgVP1teiMNoApjPdqTbfqzgI5bE9gwvw16njAK8757Q/8dSeAxJPBgDwzITptkEA6rhC6rZB6LSAP+m1P+q3QYMCQOu4Qvru2AMT8gDPhuy6Q/bgt0GER+bD7bxFAAHuIMBH89GGAwr13RCs7r1FAAHtvEQBgALvvkbwwUj3BN+tBBnhrvHDSgDxwknwwEfwwQBH7btC7Lc/7gS8QwEBu0HvvUQA775F8L9G8cOASfPGTPnmukMNAP314/TITfrqEMT89OOJLf304wDzyFvyxEnzxYBK9MlM9MlNgQACxwICyEz0x0v8jPHZRCXBBUvzxUAKAkkAAvTGSvXKTQD1y072zE/2zZ5QhgABBYUAgAb1y0ABCE33zsAIT/XJTAD3z1HzxEf2zAZOAAJAAfXIS/LBAET0xEfzw0bxIL1B8sBDAAL0xgBI9stN981P+CDSUvXJS4AA988iT4AA'
	$MakeLogo &= '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'
	$MakeLogo &= 'gHIgAPC+RMEhAL9F8cJHU3IQJcGxcsVK8sNJ8HEhAG1Bc0tAKIVyRIFyIAC8/EPt0HDgAAApkCngLTIsZxOgIS1DoL9HIABFLkZI7LtDhHK6Q4hyQJlRALlC4XKAcrpEIwCPsHJRqCF1sDk+6LMhABjnsj0gALJyO+i2YVADROq4QyAAQqxDA+ByVnLlsj3ksDwXYD4gcrFyr7JysT7kARABsT7grT3YqIA8zZ41w5U0M3G2viAAAnG/JQADccEjAIqOIQDCIwCPMMMoANvRcCIAxSAAMnHGIAADcd8iANRwJQDUcCUAy9BwKAAlAHHNJQDOlyoAz5giMyAAs4cpsHLDkjGx0sycL6FbYFmgM8+AAEBegHLhz54xRtDAX70x0Z0gADBikGWA1Sygc6Ugcsdy1smXYHcr0dacmS7Ad3BkE3PJmABryCzKmVEAxZSAbyEARyByIACwcsORJpB0y/CZL8qYQW1QcsNrgXLhkQIqw5Io0G0jANBwBMGQIAAnw5IpwokQBJMpgADEkypwAYi6iSBQAMeWLYhy79EEUACCAAAFKiAAA3qAcu8mALAGEAcVczDhcrVyQA3/g+QGfbAA4AzgD4ByQeJx4mIxNuDcun2FcmAUM4GAcs+cMefQp7xyg2IU4nKdMdShNTZWCNelN6HlozXWowA25sqa6NCn6BzPpmACJQCAGDDZpgA426g63K1N6mDOnPPkzHDlIADwHN3A8AIQduDk2aU34NuoOdmn4XLgADDmASAA3rBP6cWC6ADEgefEgeW+ckDcqjneqzq3csQHsXIgALBy36w74q8APuKuPerGgvSM4cFAcCAA9+vXwAIA5Lli4a883qooOOGsUDA9E3Pw1wKqIADv0p3bpzUM4q2gNLRy89qs82Daq/HVnrByIQC2AQA1P+azP/HXqXEgAO3Jg7ByIwAxqrgAQ+zCZ+/MhPAMzoYgAIBv8c+G9ADbrPTaq+vAZX8gOaA6Aa3icjDmMLCxcr4Bt3LwzYX13Kz/AP8PuwL/AAD779juvkcA779I7r9H7r0QRvPShwGo///3AN6t7LtD7bxEgQAI7r1F7r5FABQI9+CtA3T44K7yAMVL8cNK8cNJAQAK8MFI8MBH74S+RQgERO68QwBGAPPITfPGTPfZBosDcAAA9tSI+N8Arfvw2PnmufYA1Yjzx0zyxkoA8sVK88ZL9McCTAECyU31zFD1IMtP9cpOAAvzxwBL+OCj+uSv+YDkr/XJTfTJACMBAClL88VJ9cpNQPbNUPbMTwAF9yTOUQEC0VMADvXIAEz1ykz1y030JscCIwAgy04BCMtOBPbMAAJP88JG9QDJTPjRU/jSVBEAAfnTVQEE0VL4CtMAB1MABPbNT/cgzU/1yUsAAffODwAuBAGBEQIQ989R+QLTABxU+dRV+dURAB9T988AQ073zyBQ9spM9wIE984iT4AC+NJSAhNU+O7TADcBAQEK0AIfgB0AAf+DIwA9AUCBIwAcATEAIgMBf4EjAgoCH4EUgAIAKAEHUsUCRlAAE/bMTQA9BQHwS/XISgANAyuAMgEu5wIBgYAAEMtNAGfAAkEBPcAOy0BJwBqAMIEA99DDATiCBk/1y0xBFsEFJk6AVIAD9cgAF0v03MZJwFDEVgFWT4AAgGAjwFmAZvTHSoAA8sPCRsICS/PGSgACRgHA77xB8sNHwHdBeS+CAAB6gXVBAUxAgvLDIkiAAPC+Q4AA8cKCR4YA8sNJ8sSAFXBJ8cFHAQKAAMCYxgGAoknwv0XvvUQBgADtuEDtu0LuRr1BoIAA779FAKfwgMFH78BG776BAKLtALa7Q+7AAr9AviZHAAKBAL1FA7zruQhB67dAEETqt0AA6rY/6rU/6rZGQEAEQAHsu0SCAEUY67lDAAJAAeq5QgFBAbdB6LM+57IQPeaxPIUAO+OvgDrptkHquENBASC5ROm3QoAA6LUAQeaxPeSvO+QAsDznsz/lsT0A5rM/5LE85K8i'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'AwAA1KI1INWjNtSjoAA1+QT064MC6dCn0p8AMtOhM9OgM9UAojXYpjjcqToA2qc52qc426gQOtypO2AB1qM1ANShM9akNdWigDTVojPYpTeiAzA52aY3gAUAAd2qCDvfq0AAPOCtPQDfrDzhrj3dqhA67dSoQwzmw4BA3ao53qo6QADgIKw74q8+AATjsRA/47A+QwDirj1g3qs636uhA0AA2gSmNaAA3ak426cANt2qON+rOeCGrGAHwAE14a074GIo5rRBRQBAwGfntABB57VC6bhD5cSxPgBn4647gALiAsBA5rQ/6LbBbWABEaAA67pFQQC7RuzcvEcAAeBxonJCIHdBAGC4Qeq5Q2N5QXu8MEX67timJ4Qs0oik7r5hhe6/wIVIYAEI89CGQwP23azsALlC67hB67dAAQCI7bxE7r5F9wTfraMD+OCu8MLgSfHDSvDAl8CUYpGG72CawJG/RvDBQJADoADAmkvzyE3yxghM88dAAE321H0RRg/22ZXgnvHBRltinSCkTAEBwATGYKlNQUGoyk/1zFChqMzMT/TjAmKp9MlACWAE/8C1gLZAvWEEgbYAxIC/QAAH4AWgA2UE8sJG9cgSTEG3xUigAPTHSmnhvMZJ4QLJgMuAwlHhQQDPUffQoACgwwABv2TK4cIgwoLIIcsE1lJgAZMBAWDQ01TB1tVWAAFn4ctgB+DLzU9BAMYBz5/i1EDb5dqAAiDd+dUCB87SAgHiCOHa0FFAAGAHA6AAANn1yUv1yEp/hOCAAuLdgAWD5qEJgeBR84HdYNnKS6PkwwFh5eMOf4EFYhCj6sAKgRqAC6AbSr+k5ADiAQcB30PkYSLQIB3/wSKB4GAlY+UA5aASYQdhAdej5AMHpO3KwDRKQeRhLhBJ8L5DAeXBRvEgv0TxwEVBAMFGAYDg77tB8sJH897F8HTBHSIAgG9J8yCAGwGxcr5E771D8MA2RiAAsHLwQATwJsRJNwAmQ3OycksAJqAo778bsnLBcUQhALADv0buO3ArkSlGICpRAIByvEQfsHKRAnBzkC+hAUfuvzhH7r0wdLByAHFD6wS5QaFwtT/nsjzA5rE76LM9sHLRc765oAEUc5E1UAAwMrnwOFA+57I9kQK0IAM9u+AAtHK2MTgicrJytpE7wOSwPOKuOvBxoD344q054HKAcsM+UABQcgFQAOWyPuKwPuEArz7ZqTzSpDqAvJA5zJYyzSMAYpchAM6XMyEAAnHPGJgz0CMAAHGZM9FBIwCaM9KaNCMA0xqbJADUIACgcJw01UUjAJ0hANadNSMA1xvQcCIA2CAA0HCfNdlBIwCgNdqgNiYA24qhJADcIwCiNt0lAADeoza6jjm+jyegZGFfQFvPnbJynzKJ4XKdMYNyzZouUVr+oJFfIHLQAZBfIADwAoByMdBeyZgsMHHwccWTMCjDkSZQALAAyJduK0ABFnPwZcpQAABimTgtxpXBcZACU3LFlPIpUQCTKZBoMAIicrRyiMaVKxBtwI4l8HHAwY8mv40j4ABwcx/DblAA4HIjcpBxxZQrAVAAvIoivIsiuwSKIUBzvo0kv47QJcCPJjICKiAA8AIjYAKTAsiXLvBxxJL9kH0sEHPQB+AGcwegcyJ7j4F1cnDADkBzMMyaIA9tIAAxRnNBDZgBCwAU83G1ctq5fIByJgBwc8/wnTLmzrRyIHVwEyAAAwAUgIfUojbVozcI1KE1uHI00qAzhMyaoHkp5tKxEAFA/Pn12q9dIBjULKE0AHEwdNdwcKg6GNmmOCMAgHLXpDZXIACAAOAA1+FyM+AA2eClN9ilNiAAEAGAcnjeqzxTAEBw4HIQK950qzu4coGQdNJwEHA5MVAA3Kk4kAJAc9+s8DvhrTwgAMB0YXThA/FRctyoNyAAsHJwc7IAcDbdqTcjAEBz03Pilq3gpTAyP/My5rNwczhA5rLBcdBzsDPntRJBEHPotpB0QOi1YkEgAOezPyB1g6vsNrwR'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'AATtvkfqELhB6rcBBOm2QAEABOq2Qem1QOsBAIK8Reu6ROq4AELqt0LotD/lALA85K875rI9AOi1QOe0P+m2gEHotUHotEAAAgDnsz/ntEDlsQA95rI+6bdD6gC4ROm4ROi2QhLpADi3QwAI5rI/AOKuO+OvPOWxAD7jrjzksD3iDK07AAIACOCsOuGLAAsBFD4EArE/5AAmBK89AALhrTzirwEAIzzfrDzdqjoA3qs72KY31KEANNOgM9alNtUgpTbWpDcAAduqADzbqj3bqT3WAKY71aU71qc8ANWlPNSlPdSkAD3Toz3QoTrTAKU+06Q+0aI9CNOlQAAB1KZE2ACuVN26b9++eADctmbYrlHXqQBG1qhD0qM+0QCjPNGiPM6fOADJmzTKmzTNngA10aE40KA10ACfNdCeM9KgNADSnzPToTXUoQA11qM11aI10wMARgIB0Z8yz5wwQM6bL9CdMYACzQMCBIACzpwwzJouwMuZLc+dMQAfgB1A0qAz0J4yASWgADTPnTLJmCzJIpcBAciWK4ACypgOLQAEABkAHMuaL8oEmS4AAcaUKsORACfCkCbEkijHpJUrgADJl4AJLAACAMaVK8WUKseWkCzEkymAAMmYwAshQA0vyJYtwAjJlwIuAALFkyrAjybAwZAnwpEoQwGAA4+AAAMCQASAAMOSKYMABsQAC0EEKMKRKcJgkCjEkiqAAMAFxdiUK8fAFMEXMIAAwAJnAwuAAMARwpFBEAAFxxaVQCWAMy6AAMqYL4PAIMMjy5owzJtANBHADi/KmEAlLMiXbCzLgQZACi0AAoAAzQCcMcyaMMmYLTcAAkBGgks2iQCAYMyaGi+AAM4CCIBR0Z8z/wBKQAEDVoMDgF1AWwFZwAVgoDTVojZAaoBs1RyjNoAAAGtACtilOAjbqDuJANyqO9kEpzkBmKI02KU3iNmmOEMB16Q2BAIEpTbAAtqnOdypMDrdqjuGAAWnPN4UqjuAAN1BBzrfrOHAFDjapzdAAYADAQgQqjriroC3QeSyAYAAQOOxQOKwPpLgQLiuPYAA4KxAwZMBAsC84a6BveOwQcEFgsM/wMXlskDmtBEB1Om4RUAA57VCMcBk5bI/QADgaOOvxjuAa4AC57RBQACAbisBcCBxt6IAuAB5ROpquUAARcJzQ4F3oH64DaAJQmB5QgNE67tFCOu5RMAB67pF7RS9R2KFSkkA7r5ICOu5Q0AA7LtF7Yy8RkAAIInsu0SgABGABe6/R8MB67lCMSCP7r1GIAKgjfDCMkojlfDBAJdClr9HQPHDS/PHTkoAyABO8sVM8cRK8MLAoANK8sRLoABBABTCScQBxAABSfLFgEvzxkzzx01AAAD0yE70yU70ysVgB0wAAfPITUEAoANixsABTfLEoAbgBUoM88fgBYACS/XKTwj2zlJAAPfPUvZgzFH1zE/ABMAH9WDKTvTHTKEAwAHHc2AHwQf1y6EDoABBAMoQTvbMUKAG99FTAPjRVPfRVPbNTFH1oAPhAk/0oA/IAYALTfbOUfbNUNNBAAABzlGhDM6iBkMABtCiAGIE9ctO9cy6TmIBTyAIAAFBANGhAwdAAyEFAA3TVPnUVvFDAPjTVUAA4AKgDAAE30AGAw3jBQEBQAbOIQIABJz0x4ERxgRBA9BRRga5QQ/KTQAHABlLAFPBFjrMQCFLYQQBHyIjyEz/Ix3BImABwiXEIkIAIAvCDc+CKQMoYiiBL8NIoAAgL+FBAMVK9MjABAAQQABPgAWhNqAzQwDxwiAFSsjyw0kAAfHDodvAAfzwwSBBgT6jAyE74DtCPzFAQu+/RkBFQADuvUuATQDfRMDi78BATkf3AAFBAAHlR8Plwk9i5aFUkkYA5ey8QuS8RGTlj0AAQOegV2Ll7b1GAut/wFUAW2HlQADAXqTkYWdCP0AAYGHA5QEBYuVgZ+ezfj5g5aAAoORg5UAAYXC3/6ByYAGB5sDlYOUAAQNzQwDBAeW3'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= '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'
	$MakeLogo &= 'qzwACgAW2yaoAIgAlDfeAC6rO8Dhrj7grT0DBAAWoQEcrDzcqAA6OgA6gQAE4q8+47A/AAII5LFAAAXhrjzcAKk43ak44q49AOWyQOWyQeWzAQEC5LJA46894wSwPgAF4a065LEAP+a0Que1QucCtgIFtULotkPnALVB5rRB5LA8BOWyAB1A57RB6US4RAAC6rlFAAXnALNA5rM/57RAQOayPui2QQAI6AC2Quu6Ruy8R0Dru0bru0WAAuyAu0bquEPquQAZAETsvEbtvkjtRr0BCgIBReu6AQrrILlD67tEgQW7RQDtvEbuv0jvwRBK8MJKgAXruEIJgA7suoACQu28RQjwwksAAfHDTO+AwUnuv0buvQIBRL9HAwTvwEgAAfAMwUmAHQAB8cNK8oDETPHDS/HEgQVA8MJJ8sVMAAHxAMVL8sZN88hOgwABgQvBSPHDSYECAsKEAvPHTfTJT0OADoECx03yxYA4SQDxwkjzxkzzyBBM9MpPDQHITfJCw4AOS/PHTAAB9SDKT/XLUIAA9sxyUUAB9MlBB4AAAAL2AMxQ9s5S9s1RSYAA9cyBBvXKQBlNQPPGSvXLT8MF9sLOQgHNUffPQAoAERBQ9MhLgAn1zE/xwAL30FPABUMBAQVDEJDITPXLwgLLT4AGyPjRVEAB9s9BEIEJ80EWwRH30AMOghhBGQAFZk8AAsEOzE5AAYEDzUZQgAxAEPjSVIAD9HzHSwAXACAAAgAIBxfM8FD1yk1BHAIgQAHBIP8AAoAAgBtABwMdADLBAsEFt4Q/gANBGVGAJ0AB9EBM4MVK88dLQQEAUEIBH8AOAEeBUcJWQATyxEnNQVjHQCKBV/TJQBNAPQsAHYEA8wBowUbyw/BJ8sRKQAGBaYMAwQ6ATPHESe+9RIAAdUBw8oASxsCAABTAdEqo8MBHQHzvAZJDgoEHwYlDi4MA8MFH78CAR+27Qu69RcCbOO+/R8CVw5hAAe28wUCsQ+27ROwBp0EBkOy7RO9Ar8BJoABY7b5GQF2hXboAWERzQAAhAr5HYATDAQBb6gHAW7pE6rZB6bYAQOm1QOm2QeqGt0BdwApG7L1GwAEA5bA85rI95rJiPAAB57M/42hAAOhgtUHnsz7gbkEAs0A/5bE95K+AdD7k5bEgAj/mAHOhAGBzBkFgAeAC5LE+464foXhAAGAB4IDiAkDhrUEghjnfrTreoACr0DreqjlAAOLCgsCFAOOvPuGtPN2qADnbpzfapjbeAKs636w64a49A+OMRgDcqTnXpDNQ2aY22sGUNsAB3SipOtyhnDpgl9imEDbToDFAANilNgjbqDggAtqnONlEpzjAndWiNEAA1OChM9KfMMCgIAJCACuBoaCl1wAEo6ADNNAAnS/RnjHSoDIA06Az1qM21KICNUAA06E0z50wAM6cL8+cMM2aTi4AAaAAYAHToEAGNQDSoDTPnjHQnoIyQADNmy/OnCAFLDDQIgLhBZtBAMyaEC/KmC2gAMmXLBjJmCygAMABy5kuAMuaL82cMc6dADHIlizEkijFAJMpxJInw5EnIMaUKsyaoAYwy4SZL0ADxZQpxEADIJMpxZQqoADCkAgnxJIgBSnFkyqIxpQrQgAqxpXABAIroAPDkinCkSgkxJMgBSrDQQYrxgSVK6AAwZAnvo1QJL+PJaEAjaEAvgCNJQAA'
	$MakeLogo = _WinAPI_Base64Decode($MakeLogo)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($MakeLogo) & ']')
	DllStructSetData($tSource, 1, $MakeLogo)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 128576)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\logo.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_MakeLogo

Func _MakeOffBmp($bSaveBinary = True, $sSavePath = @TempDir)
	Local $MakeOffBmp
	$MakeOffBmp &= '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'
	$MakeOffBmp &= 'uLuzqTAH8Ac0ALrwAIy5sbwE8AC4sKVwdw7xMge1obEA8fL0AAC1raAAtq+jAP63PwA/AD0AsAs6AD8CsgU4ta2hsgYxB7EH8vKi8rIg9/j78Br48hr/Mx01AHMbPwA/AD8AOwCxBR8xBrEGMQexBzGcuLOq//IAMQkxAPFQ8TlxAHEaMQHymjEAkYM/AD8APwA5AF/xBbAGMQexBz9y//Kpg0B4awDHxsSwPex/MqJ/uz8APwA/AD8APwD2APb2AIZ8bwCoRKOdsqXe3t6wdubH8iKxCfEB/f39vwM/AA8/AD8APgCxBdLPywAIh31wMAicAL68ALkA0NDQAM3NIM0Azs7Osqvz837zPwg/AD8APwA/ADQI1IzRzTIIPQC2s68yCH9xEL8DPwA/AD8APwC/3eFA390AtrGqMgi3/LSwshi/Aj8APwA/AD8Axz8AMQCxKLCrpDII8SB/PwI/AD8APwA/AD8AdRDW/NTR8gdx0z8CPwA/AD8Afz8APwA1AHH08QdxAHcBCLAQ/wD//y8wAAA='
	$MakeOffBmp = _WinAPI_Base64Decode($MakeOffBmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($MakeOffBmp) & ']')
	DllStructSetData($tSource, 1, $MakeOffBmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 4152)
	$tSource = 0
	Local $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\off.bmp", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_MakeOffBmp

Func _MakeOnBmp($bSaveBinary = True, $sSavePath = @TempDir)
	Local $MakeOnBmp
	$MakeOnBmp &= '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'
	$MakeOnBmp &= 'AL8AMQC7s6kwB8vwBzQAuvAAubG8BPAA6LiwpXB38TIHtaGxAALxsFy1raAAtq/4owC3PwA/AD0AsAs6AOM/ArIFta2hsgYxB7EHiPLy8rIg9/j78Br++PIaMx01AHMbPwA/AD8AfzsAsQUxBrEGMQexBzGcuPyzqvIAMQkxAPFQ8TlxAMtxGjEBmjEAkYM/AD8Afz8AOQDxBbAGMQexB/+s/wHyqYN4awDHxsTwAOzs7DKif7s/AD8ABz8APwA/APb29gCGQHxvAKijnbKl3vDe3gDmMDvxIrEJ8QH4/f39vwM/AD8APwA+AAGxBdLPywCHfXABMAicAL68uQDQANDQAM3NzQDOxM7Osqvz8/M/CD8Ajz8APwA/ADQI1NHNMgjxPQC2s68yCHEQvwM/AA8/AD8APwC/3eHf3QCItrGqMgi3tLCyGP+/Aj8APwA/AD8APwAxALEo+LCrpDII8SA/Aj8APwCPPwA/AD8AdRDW1NHyB/9x0z8CPwA/AD8APwA/ADUAD3H08QdxAHcBCLAQ/wD//y8wAAA='
	$MakeOnBmp = _WinAPI_Base64Decode($MakeOnBmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($MakeOnBmp) & ']')
	DllStructSetData($tSource, 1, $MakeOnBmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 4152)
	$tSource = 0
	Local $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local $hFile = FileOpen($sSavePath & "\on.bmp", 18)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_MakeOnBmp


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
Func _ChangeWindowMessageFilterEx($hWnd, $iMsg, $iAction)
	Local $aCall = DllCall("user32.dll", "bool", "ChangeWindowMessageFilterEx", _
			"hwnd", $hWnd, _
			"dword", $iMsg, _
			"dword", $iAction, _
			"ptr", 0)
	If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)
	Return 1
EndFunc   ;==>_ChangeWindowMessageFilterEx
Func _Monitor_OFF()
	Local $Progman_hwnd = WinGetHandle('[CLASS:Progman]')
	DllCall('user32.dll', 'int', 'SendMessage', _
			'hwnd', $Progman_hwnd, _
			'int', 274, _
			'int', 61808, _
			'int', 2)
EndFunc   ;==>_Monitor_OFF

Func _IMGAPPbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMGAPPbmp
	$IMGAPPbmp &= '77SgQk2YrgACADYAMIIoADDvAQAAHgA4KAEAGAK4YgB8ww4jAwwFAPHu7SEI7+wA7dnU7piN85MAh/PTze/s6e0I7+vtAArd2O58AG70nZLyrqTxAMa+8OLe7rSrgPG+tvDr6O0AC0C2rfGkmvIAI+oA5u2imPKIe/QAubHwppvyQCwA+CoU+ScQ+iUCDgECJxH5Ji/pABWhshiFwCobgPYmD/okDfoABRwnEQEIAyMADjUa6gBpQa1fOrhPLQDLjDulrjmYmABFlrl4V+igHUDypxLxphMAAfAEphQAAfSmEvSoABH2qxT5iTX5ADx5+iuK+iaOAPoVnfoQofoPEqMBARCiAQcVnfkAEaHtH6GcTcQAM43rD6T4EKQA+BKi9xKj9xECpAEBDan5Daj5AA6o+Q+p+Q+qAPoQqvoSq/kZAK35FKv5EKv5ABSs+SGw+YnPEPPY5u4GlOju7YLsAgTw7u3m7w2jIQEK6+7s7QQH6+4A7eLv7ent7e4I7e3vBQrs7O3k/OruBgd/Ab8AvwC/AL8A/78AvwC/AF8AXwBfAF8AXwD/XwBfAF8AXwBfAF8AXwBfABlfAAAL/7nkuevtySDC77iw8aC6zMYA78K78ODb7tQAz+/AuPBdTPYATzz3STb3cWIA9auh8YR39IIAdfTPyO/Ox+8AnpPynJHyr6UA8crE73lq9I4MgfOguiC8UD33KQwT+SG2QronE/kkADfnGLCtGpa5ADoy8ygT+SkOHvgjuWAEQwAgBS0U8QBjPLOZZXiLVwCLjlGOz3ZQ4uCNMeidIAC447mgAADvpRXxohf0jwAp9Zci9Ywu+CBWYfobl8G4EaEB5LkOpPoOo/gPCKT5D6G29RKl7gAYprQ7vDSN6g3juRHAAkIAFKH2ETCk+A+mhLlAABGqAPoVrPkWrPkXQKz5E6z5EmIBh2DO89Tl78CvgLLB+O3t0+W5IbPgJvQpwLgM2O+BvyC86+zt2PDn7unsYQF/MV8AXwD/XwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAPxc/7kvAIH1uefj7unl7oC3R8BcMLmgW3Bh9cBcNwAi+SwW+SsW+QAzHvlHM/g7J4D4Pir4eGn1MAIASDX4RjL4TjuA92tc9VA+92C8CL218BC+QzD4KBwS+SC6IACxWhL5JAA06Bi0qxSvrIgqK+/gACgP+cNcAWACLhD3UQ3pTQAN6y8Q9S4U8ABTLMt8TZuhauBtzok98jJc8FxgXAEgAPOoEfSpEPMApRT0lyH1lCTA+G1K+SmKNlwhXQtgufK5+fJc9RCm8QATp9sirpxKxUAwkOwNpvn5XBOEofawuhCm+BDyXAXAXBMwuar5Eqr5AByu+SKx+BivAPkbrvl8y/TLBOLvULfb7u165sDvtu3u3u+UuRBegUAA8ers8evsw7kG7hJewFzD8O3Z7wGUX+Pq7r/f8N3+6MABnxcvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8Afy8ALwAvAC8ALwAvAC8A7QDxrbSI7u3xnSEAAACwGgDg2+6Ie/Q8KAD4KBL5JQ76JgYPBAGABSMN+iQN+PonEAEHAARABEMBwAUAMBv5YVD2bF3w9Tgj+QAOwAiAAAECABH6KBT4Iy3sABmvrhOtrCQnGO8nEwEIxg4rDvgAXA3lbA3fMg4A9S8R9FskzrkAcF7ejzLonCAI8qcSgADupBbtwKMY86gR84IDAQIAmx71hzD4TmZA+hac+g+jgQAOgYAApPkPo/cTxAIBQgGj9hClziqzAJpMxkiA4xCkoviGABGj94AAEkABAKT3D6j5D6r5gBGq+RSq+RZC'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= 'y8rJDQ0N0M0OzIAMwAiABsbDwvQg8fGdnJuAA+jlAOQmJSVUU1KeBJ2cwAVSUFATE4ATvLm46ufnwAUAMDAwmZeXr60CrMAFCgoKycbFCLWzskANeXd3vQS7ugAIJycnj40AjKajoxUVFYdEhYRAGcrHxoEAyADHcnBwPz8/mgCYmNXS0fLw70D18/JjY2LAC7EAr67z8fDNzMsABAQECAgIYmIOYcAUQATAIwsLC5Qgk5Ll4uEDCygnACeNi4u0sbByIHFwBgYGABTX1ELTgRLy8szKwT6pBKinQATq5+bs6R7oQDpDRgAIQDqdm5sAYF9furi37eqA6WJhYScmJkA6CMC+vcARc3JyoWCfnrm3tgAOwB2PBI6NwEqEgoFhXzBfu7i4QBAAU5iWApYAAunm5YB/fgB+fHvY1tX08RDwnJuawAignp4IamloQAfV09ImACYmERERVlVVgQAFsq+v1tPSgCERwBTMysmAJ8C9vHjCwL8ATYMAQ0aAVIVEhIOAPOLf3oAA0wDQz8vJyNrY18Dy7++cmpmgAyAgGLWysoACQwDc2dk46OblQA8gGgATbm0wbJSSkgABIwJzcgJxADqTkZGIh4b4i4qJ4A7AHP9HXwBfAP9fAF8AXwBfAF8AXwBfAF8Ag18A+Lnu6u3r6AEBMSC55uHuYAEgAuzpAO3Y0++mnPJL4Dj3Kxb5A7ggsKOx8SCzKRP54ALmueMCwAH/IwLGuCO5oADgBWMBQwCBuQGAAhT5JCjvFKQAsQ3UmRWctSoAMulMMc+cZ3UAtHtXpG5qgVMAklk2wIFTk3UAS6DBmj3opxoA86gQ86gR8qcGEkAAAwHxphPwpgAU5p8g8KUW9gCQKfh4Q/lCcwD6G5f6EaD6F7Cb+hSe4bmEuaJBAANCt6S6D6P3EaTnABqr1yWw9hGkAPoOpPQSpeEiAKjMMrFkkdQvAMjjGOroEerrABHo6xHl6w/hAOwNz/IKt/cKYK75Cav56blEAKsA+gqw+QvA9g8A4PAR8e0R9+wAEvfsGPnsVvMA6H3k7XrT8oQA0fO53fDU5e8A0uXv3+nu6ewC7cC74unuzuPv4Obr7ursXLdVAJ+5A/+5AVkHBweKiIgBoFXz8O9jYmE+xD4+4ADOy8sgRYBLGGNiYoBIMEEXFxcDM1xARn59fL68uwfjA+AA0FUcHByWkxCTq6mooE/f3dyBgAN8enq/vbyAAACMioqkoaHm4xDi6ebm4ACAfn4Am5qZFhYWnZoGmjAIEwepp6by7+Lu0AGFg4PARKAHYE2Ij42NoElbW1uAUYMgS/RcYmIxMTGAVBHQB2RjY9AHIiIiOGhnZ6AH81xwCoyLIopgVtfV1NABg4EwgaCenbAA0A1RUABQKioq0s/OysTIyFBLqqinAAJwTACzsK/Bv7/e2ybaUAPEXPHwAF+dmyKa8FzBvr6wCeDeRt3AApALPj098G6sAKqpxMHA39zbB6ABkAiAURsbG7KwBq8gBlAMqKalnJoGmgBTgAAmJiU3NvA2joyMMAhgBTNiEBNHAFbgBtAEUVBPoGEZABkZX15eu7m4ONvZ2KEZ8VzhZhAQcBAODg4wBQkAEBCGBIWEIBvp5+bu6w7qUAATWJMIKysrleCTk8bEw0ABIwCgATjf3NygE9BzEAdhYHBfYWBgEGrAFyYALAAsLE1NTXFwb/jDwL/QcN8iLwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAJ8vAC8ALwD/XHO46ub1ngVARukSAeftpZryAGJR9jUg+SoU+6RYxLkRxLlQXba3QQESAQ8gAIMAZgKDADMe+SsOFfG5w7wgADAa+UcANfg3PuwVqq4ADOSRDtaYI1QA10o41HNKpGUAQLFRL8hGJtUAPB/hd0yetn6AVeepGPOrDzBcKSJdEPQgAKm0Xe+lABX1qQ/0qBH3AJUn+J0j+XdByPouhvFcHZYhusO5H1MAkblw'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= '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'
	$IMGAPPbmp &= 'TPhEcfogLIj6G5gBtR2WAPocl/oYmvpDAHX6jTH6rhT6AKca85Yt+KgYAPqAPvlnXPprkFL6UmbhBRWdQQAHobpCAAO7DqP3EKUI8RSooADwG6ZoAJ7RI+DlFuzoABPv6RPt6hHkgO0Q1fALufdAuj2AuQqMucG7QQCgtwzCAPYQ3/ES4/AQAOXwENnyEMj1wBSx+BGr+Yy5SQADA7tAuhut+Um99uzH4wC54i/tQbq/OV8A/18AXwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8Afy8ALwAvAC8ALwD/XC4A8ALtkVzq5u3Tzu8AsajxX072PSjA+C0X+SsVYbmDt/92uEZecAFGW8lcIABwAfG8AWICKxr3Q0jsPADgpyL4kRz5jsfGXCMAYLkR7JDwXPO5AcBcKPWIe9lWowDJPU7bbSfrhAAs8YVH6nWQ0YBJ6pkr9kZxwbYzolhXAA2kobgQu6UaASFdrBL6rxD6pAAe+Zc8+qYb+gSQLGG8VmL6PngPIbryuVRdhACk+Q+kAOghqm6Yz1+mANQq2OMT6+oTAO7qEu/rEurtwBDc8Au39yO6IQAOqiIAxblQAAu99g8A4/AS7u4U9u0BIAAV9O1R5e9UAMrzL7v3HbD5BBKrIQAUq/kYrcD5Ha75FqzhAMBcByAAgAAgXRes+Ti2APe63vDp7O3q4Ozt2efuUAAPGpca/zJftgAPAi8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwA/LwAvAC8ALwAvACAAHbWI8e7tfSEgICAJBwTw7YcF6+jt2NIA77218Id69IIAdPR5a/SOgfMATTr3Lhj5JxCC+gABJg/6JQ4BBAODBQEEEfowG/k+MCr4KhSEEQQNEvkFAAEogAIR+ikQ+QA0GPZMP/NDVwDmJNahHveQHQT5j4wAHPiPGPQYjxr1AQKAAx75jgAi94xQ53BA6wB5Ie6JHfGMHwD3jSf2iWbbaADgh0b0PHz4JQCP+hyX+g6j+iQQooEAEaGBADGFAPpWYfqIM/qtEBP6sBKBAJMq+gCbI/qSKfptTQD6hzT6pRn6hQA3+j53+g2k+iQTn4EMD6MAEfUTAKTpH6nWMa/KAD61sla9dZHOACvZ4xLq6hPvAOkV8eoT8ewSAO7tDtDzC7r3AAqv+Qqs+Qy4APcMxPUMwPYLArsBAg3H9Q7P8wAR7+4S9u0T+ADsFfnsI/jsiADi7K3P6pbb8QB30PNyyPRnxAD1bMb0esr0kQTR8gACLbP4E6sQ+RGq+oAAEKr6ABmt+T64977fAPDr7O3s7O3iwOru5+vu7ohmjwD/AAA/g78AvwBfAF8AXwBfAP9fAF8AXwBfAF8AXwBfAF8A/18AXwBfAF8AXwBfAF8AXwAfXwBfAF8AXwD4ue/s7Qjh3O7GAd3Y7o0AgPNzZPWnnfIA1tDv2tXu0szA74p98zIdJLNkuMnpthD6QAMrFQEEwQEGEUIAQAMb9SYY9gOjA+ACMBf4PTD0AFFu4h/YnhfxeJAc9+S2TLrJAUC6H2D4jh73jnABpgE4AO9/v4Ro9CmPePkSoQFZ0FgjAFNdOgB7+nNH+pwg+gSvESEArBf6hDgA+qQa+n09+l8AWfqOLPqtEvqgpB36b06CYKEhAwAOo+8bpeApqwDAR7XHQbbXMwCz7B+uo2TCPQDI3hjr6BPx6gAV8OkT9OoT9wDrEe7uEN3xDQDD9Q7A9hLX8gAQ5+8P3/EO0gDzEebvEezuEQDt7hLy7RX07QAV+Owb+exB9wDsp+7tyeLu1gDm7tzp7tjm7gDP5O/O5O/U5QDv3ejuyuLvfsTL8yBdF6z5UF1QAAAss/hcwfXR5AbvU1oA'
	$IMGAPPbmp &= 'ANfm7uns/+8bLwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwBPLwAvAP9c+lzq57QA7gDq7eHd7sK78CDIwfDn40Re5eGA7qSa8kw59yRdkBD6KRNRAC0XMVxdpFsPJADjuiQAEsdfLgAT9zQc+Eg49gCYnutR464d78CTFfOOGvb9XC8AAaleJPCQKO2QQgDlf7yGafEsjw75M7ljXCS6oPpHcUD6hjj6qBfBXK4AEvqlHvqAPPoApxf6myL6ji8g+qMa+q5AXhL6AJgp+lJm+iOQAPoToPUUpdkvALDAR7bFQ7XDAEW37hys9BasANM2tYSCykXCANwg5+cT8uoUAPXrFPjsE/nsABHx7hPq7yHlAO8r7O4U9e0QAOzuEODwEvPtAaABEvrsF/jsIAD27R/37DT37ABp8uyg8O2x4iDvz+Xv8MgX6uww7ejr7hC44F2BzADzN7b3KbL4NQC1+FrA9Z7V8vjk6u7GApAC/7kvAC8A/ywAEGKgvs+8LwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAtAKyziO7t8e0iICAg0gUg7Ont7+tBAernAwECAwXq5u23rvEAqZ/xZFT2MRwA+SsV+SkT+SeAEfoqFPkoEoEAQCcQ+iYP+kMBJBoNwgIRhQCDBhH6OQAW9GtW9KKY8gDW1eyV7sYz9QCaFPSOFPCPG4D3jxz4jx35lgAAHviPJvCQMuIAkTnckUbOkVUAyoley3uMnoUA2kSb+BOm+hGApPoQo/oRoYEAABCi+hOf+lFnAPqWKvqvE/qvABH6sBL6qhX6AKAf+qwT+q0TwPqsFPquEcEFgAAApxz5f0X5Z20A+UOF8C+o3zgAs+A0sc4+tcsAPbXxGaveLLIAxE271lO9sGwAxFO+2x7u6RMA+OwT+ewV+OwAFPfsFPXtKuIA8ELs7hf27REA8O4Q4PAT7+4BAwQc+ew09+wyAPHtZ+3txOvsAKHv7Knt7tvrQO7i6u7v7YEp8ADu7ePq7sXh7wDH4e/l6u7a5wDur9rxndXys5Db8MriIQLo6yQF40YAQAbp7O0AAD87UQABoAnh6e6T0vLQ/uRAAf8FXwBfAF8AXwBfAP9fAF8AXwBfAF8AXwBfAF8A/18AXwBfAF8AXwBfAF8AXwD/XwBfAC8ALwAvAC8ALwAvAD8vAC8ALwD/XC8AKgDu6gDt4Nvu19HvoACV8oh79Ek295wwGyFdU11DWysWsQDxoF4uGPmwAKNeEwEgAAAzHvlGLfa3qxDw4t7uYGLT8OAAa/SyKvSXFvMYjxn1/1wqAB/3jwAr6pE23pI72wCQRNqIk8JXpwC/SpyWluY1rMD5E6r6EqfxXJBcABCi+BKj8CKeQPpnU/qmHsJcFOHwXPmxFvogAIBdIQAQFfmxF4EArhf5AJ4n+XZr9Le5APWdoueLuON+AMnscsf1Sbr5AC2w9Ta1yVS+ANdgwu2GzvCDAM2/n9RW3eUSFZBc+RFbFIAA8+0SAOHwE/TtEfftABPy7RDb8RPxAO0R8u0U6u8bAPPtKPLtQeHwAIvk79zq7ufqgOzj7O3i6+6GVGPAWQAA5OruoFuiAO1A3+nuxuHvUADr/uzRAZBbgACQV7AAKV3pAIcvAC8Aanrt7dbmwWL/nGIvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwD/LwAvAC8ALwAvAC8ALwAvAP8vAC8ALwAvAC8ALwAvAC8A/y8ALwAvAC8ALwAvAC8ALwB/LwAvAC8ALwAvAC8A/1wAAAA='
	$IMGAPPbmp = _WinAPI_Base64Decode($IMGAPPbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMGAPPbmp) & ']')
	DllStructSetData($tSource, 1, $IMGAPPbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 44696)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_APP.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMGAPPbmp
Func _x62_Img_app($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $x62_Img_app
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= 'UwBTc1I6AAP8PQT4Nwb+/PL61LtJWJlZYFPwU1Bg/wlcs7QgAJACIAAAWf9cs1f/tgAQW2O5YAIwBWO2Y7ngAP+gAewD8F9gBfZc8AUwCIMAn/AIcwf/XCMAIUucmwC5DwBQ8FPgACA/Ozs7izyJidBGwFPwRBABz8wfwE/xXBBMcEZAAYKAgOMgAfACkI+O4EXgSEAEiKypqVNg9fPzMAIRUEubmZhQA5+dnB+AA+BUAwWQRHABKCgow1C3EmRiOTk54MCAAwPQAYCu3tzbUlFRAbAAEhISUFBQhnyFhcBTEKb2XACt4LrLjsnhq4Cl8FxnZ2bAWX/5XPAL862AqJCqUFewA4IAgYAvLy+npaSPMAugAQAAwLw8PDwAZePATTBr5+TjkAJwBOBdT4BXsK4wVnCv8/BADfLHUA8gA3Bbt7Sz8AgAFIcgvZEFkV+bHh4ekLw/4AAgDGACkFNQBsAIdXQedNBqMAhQVza/wL29f7AP0BOwDPBToASQXyBdicSIh0Bz8O3s8lzxC8CVk5KTkZAQbSMAx6ATIAAwGoWDgvBcYA7/1hyWCPDLkAKwGLke4AbQB8fQE5AOAAWXlZXwF9MEA3BnIABDQkJ7enk4mpiXAAj/uSIAf7iI7fHujSEAAACAAgDq7u3u7e3v6QDq6+vp69jgzgCuyJWiw4eKtQCNgrB4lLtMvgDVNdXiI+juEAD3+g/1+g/x+gAQ8PoQ7/oP8AD6DvH6D+/6DAGAAur6E+7zLeoA1rnNRezDD/IAwgn2wQT4wQIBDwH1wgXxwgrnAMQTithyE/PnAAz27SHy2YvagGbnxQ32wQOGCQj3wQOAAO3DCpoA1kMi75sW8aQIEvKngwAW7qQUBPGmgAAT8acf5gCnS7ugw1Ne8gAlZvcVkvkNqQD6DKz5DK7zEgCt+guv8Rau+QARsvgRr79FqgCrTbd3W9oqjgDxJpHzEZ76EACf+haz3h3SswAk7I8k7o0j6RiUJe0BAoEAEnA3AAb1OAP+aFb+AO3y/NLS/Pb7MPypof1ABIQABP5A9Pr82938RgRLgCf+7vL8vrrICHAD/mtUAQWJCUYEnuSU/QAUeWZBAcAXSQ0RmABcQP7ADpKG/T+AGwACgAAAAswIQBPl58eBBsAsgAOGd/0DAgAFD0McgAOAIUAEPQr+kQR1/gmD9fLynZsAmycnJ5WTk+MA4N/18/JjYmJANjY2kI6NQAf2APTzBQUFYmFhAMzKycrJyBkZgBm9u7rz8fAABUB5eHjq5+bAC1IAUVEfHx+1srIACwsLj46N8O2A7PTy8eLg38AIQGFfX7GureACnwycnIAF4ALh394GAAYGkY+PmpiXACsrK5uZmfPwAu8gDjk5ObOwsGL0IguVk5LgAgABlGCSkbOxsCAOgAvKAMjH6OXk8vDvcSMUFRUVAAoAAaAJ2wDY1w8PD2VlZAiqqKdgE52cmxcAFxeKiYjd2tkI4N7d4AhfXV3XBNTTgAvs6uk+PQA9REREn52c0ATNzAAcysfGHh6AHomHh5yamaAMCM7Ly6EM7+708Q7x4AhgByARYWBfiTyIh4AgwA3AByAOPz8AP2BfXmNiYWIgYWCDgYHgBfXzAvPAKBwcHNHOzQDp5+bLycmBgAKAIAVDQ0KcmpoArayrt7a129kG2IAd4Bedm5pfXjBd2tjXACKgBo6MEIy7uLcAHMvJyAgSEhKgDLm3tu5c6+oAFsAuYhCYQgCZAUgAmDw8PIeGhnjCv7/ADaY5IREFOpjclpbAGWk9oSfyoSegGPGAGmFgYIAaQwBgGUAAADQ0NHh3d6Wj8KPX1dQAEJ+JXwBfAP9fAF8AXwBfAF8AXwBfAF8AB18A8rlJAO3b4cbSAONp3Owg6fEeAOnyKOLtKOPtACXx9hj09xL2QPkU8/oR8EC3+gYRQABAuvH6DvL6AA3x+hHn+RvqAOtS4q+N1nOHAMODprRm6cEUGPXBBaC6oADzwgcDQADgs93G'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= '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'
	$x62_Img_app &= 'AC8ALwAvAC8ALwAjAAJ/ALoA'
	$x62_Img_app = _WinAPI_Base64Decode($x62_Img_app)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($x62_Img_app) & ']')
	DllStructSetData($tSource, 1, $x62_Img_app)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 44696)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_APP.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_x62_Img_app
Func _IMG_CLOSE_Hbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_CLOSE_Hbmp
	$IMG_CLOSE_Hbmp &= 'WLGgQk02FAACADYAMOooBDAgABgBAigAAAB8DBMLAwwFADQ0pf///w9/AH8AfwB/AH8AfwB/AP9/AH8AfwB/AH8AfwB/AH8A/38AfwB/AH8AfwB/AH8AfwD/fwB/AH8AfwB/AH8APwA/AJ8/AD8APwA/AD8Apf8JAP9/AX8BPwA/AD8APwA/AD8A/78Iswi/CT8APwA/AD8APwD/PwA/AD0Jvwk/AD8APwA/AP8/AD8APwA/Cr8JPwA/AD8A/z8APwA/AD8A/xM/Cj8APwD/PwA/AD8APwC/Cf8nPwo/AP8/AD8APwA/AD8Avwn/O38B/z8APwA/AD8APwA/AD8APwD/PwA/AD8APwA/AD8APwA/AP8/AD8APwA/AD8APwA/AD8A/z8APwA/AD8APwA/AD8APwD/PwA/AD8APwA/AD8APwA/AP8/AD8APwA/AD8APwA/AD8AAz8ANwAGsBCl/zQ0LzQ='
	$IMG_CLOSE_Hbmp = _WinAPI_Base64Decode($IMG_CLOSE_Hbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_CLOSE_Hbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_CLOSE_Hbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_CLOSE_H.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_CLOSE_Hbmp

Func _IMG_CLOSE_Nbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_CLOSE_Nbmp
	$IMG_CLOSE_Nbmp &= 'WLGgQk02FAACADYAMOooBDAgABgBAigAAAB8DBMLAwwFAD8/0////w9/AH8AfwB/AH8AfwB/AP9/AH8AfwB/AH8AfwB/AH8A/38AfwB/AH8AfwB/AH8AfwD/fwB/AH8AfwB/AH8APwA/AJ8/AD8APwA/AD8A0/8JAP9/AX8BPwA/AD8APwA/AD8A/78Iswi/CT8APwA/AD8APwD/PwA/AD0Jvwk/AD8APwA/AP8/AD8APwA/Cr8JPwA/AD8A/z8APwA/AD8A/xM/Cj8APwD/PwA/AD8APwC/Cf8nPwo/AP8/AD8APwA/AD8Avwn/O38B/z8APwA/AD8APwA/AD8APwD/PwA/AD8APwA/AD8APwA/AP8/AD8APwA/AD8APwA/AD8A/z8APwA/AD8APwA/AD8APwD/PwA/AD8APwA/AD8APwA/AP8/AD8APwA/AD8APwA/AD8AAz8ANwAGsBDT/z8/LzQ='
	$IMG_CLOSE_Nbmp = _WinAPI_Base64Decode($IMG_CLOSE_Nbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_CLOSE_Nbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_CLOSE_Nbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_CLOSE_N.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_CLOSE_Nbmp

Func _IMG_MAX_Hbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_MAX_Hbmp
	$IMG_MAX_Hbmp &= 'ULGgQk02FAACADYAMOooBDAgABgBAigAAAB8/BMLAwz/Ax8AHwAfAB8A/x8AHwAfAB8AHwAfAB8AHwB/HwAfAB8AHwAfAB8AFgD//38AcgAfAB8AHwD/EP8THwD/HwD/Ex8A/wIPAA8ADwAPAP8PAP8GDwAPAP8CDwAPAA8A/w8ADwD/Bg8ADwD/Ag8ADwD/DwAPAA8A/wYPAA8A/wIPAP8PAA8ADwAPAP8GDwD/Av8C/w8ADwAPAA8ADwB/OT8APwD//wkPAA8ADwAPAA8Avwc/AP8/AA8ADwAPAA8ADwD/CT8A/z8APwAPAA8ADwAPAA8A/wn/PwA/AP8JDwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8ADw8ADwAPAAYAA7ACADIE'
	$IMG_MAX_Hbmp = _WinAPI_Base64Decode($IMG_MAX_Hbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_MAX_Hbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_MAX_Hbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_MAX_H.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_MAX_Hbmp

Func _IMG_MAX_Nbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_MAX_Nbmp
	$IMG_MAX_Nbmp &= 'U7GgQk02FAACADYAMOooBDAgABgBAigAAAB8/BMLAwz/Ax8AHwAfAB8A/x8AHwAfAB8AHwAfAB8AHwB/HwAfAB8AHwAfAB8AEwBn+Gdn/38AbwA/Cx8AHwD//xP/Ex8AHwD/Ez8F/wIPAP8PAA8ADwAPAP8GnwEPAP8C/w8ADwAPAA8ADwD/Bg8ADwD//wIPAA8ADwAPAA8A/wYPAP8PAP8CDwAPAA8ADwAPAP8G/w8A/wL/Ag8ADwAPAA8ADwD//zs/AD8A/wkPAA8ADwAPAP8PAL8HPwA/AP8JDwAPAA8A/w8A/wm/Bz8APwCfBA8ADwD/DwAPAP8JPwA/AP8JDwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8Afw8ADwAPAA8ADwAPAAkAA7ACADIE'
	$IMG_MAX_Nbmp = _WinAPI_Base64Decode($IMG_MAX_Nbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_MAX_Nbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_MAX_Nbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_MAX_N.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_MAX_Nbmp

Func _IMG_MIN_Hbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_MIN_Hbmp
	$IMG_MIN_Hbmp &= 'VrGgQk02FAACADYAMOooBDAgABgBAigAAAB8/BMLAwz/Ax8AHwAfAB8A/x8AHwAfAB8AHwAfAB8AHwD/HwAfAB8AHwAfAB8AHwARAJAYGBj/fwAY/z8J/x8AHwD/E/8THwAfAB8A/wn/PwD/CQ8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8AAQkAA7ACADIE'
	$IMG_MIN_Hbmp = _WinAPI_Base64Decode($IMG_MIN_Hbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_MIN_Hbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_MIN_Hbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_MIN_H.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_MIN_Hbmp

Func _IMG_MIN_Nbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $IMG_MIN_Nbmp
	$IMG_MIN_Nbmp &= 'VrGgQk02FAACADYAMOooBDAgABgBAigAAAB8/BMLAwz/Ax8AHwAfAB8A/x8AHwAfAB8AHwAfAB8AHwD/HwAfAB8AHwAfAB8AHwARAJBnZ2f/fwBn/z8J/x8AHwD/E/8THwAfAB8A/wn/PwD/CQ8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8ADwAPAA8ADwD/DwAPAA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8AAQkAA7ACADIE'
	$IMG_MIN_Nbmp = _WinAPI_Base64Decode($IMG_MIN_Nbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($IMG_MIN_Nbmp) & ']')
	DllStructSetData($tSource, 1, $IMG_MIN_Nbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 5174)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\IMG_MIN_N.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_IMG_MIN_Nbmp
Func Wave()
	Local $Wave
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= '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'
	$Wave &= 'CwCyAHX/w/+xAMX/T/8JAar/MP9SAU7/fP83AS3/y//YAHn/tv+hAOf/TP/PAAAAA/8pAbb/Iv9DAWz/ff/5AIv/nf+cAPv/V/+UAEIA+f7kABwA5/4oAcX/Lv8IAbH/d/+hAAQAaP9kAGgADv+SAHMA0P7rACcA8f77AO3/SP+mABEAb/9GAHcANP9DALAA3P6WAIYA0P7OADgAHP+fACoAa/83AHUAYP8EAMsACv82ANIA0f6EAIsA/f6FAFIAXf8vAHAAg//d/8kAR//h//4A9f4pANYA9/5TAIUAT/8kAHAAm//I/7UAif+d/wgBN//M/wcBEP8NALsASP8OAHwApf/C/5kAwv91//IAiP95/w=='
	Return Binary(_WinAPI_Base64Decode($Wave))
EndFunc   ;==>Wave
Func _HDDbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $HDDbmp
	$HDDbmp &= 'W7SgQk24CgACADYAMCooADA4ABgQABgBAMoYAriCAHwSCwMMBgAEHvzGCAEf/AQiAPwOKvwZNPwcgDf8FzL8ECwHBzkAARo1hwUJAQAKFjGDEA2AIA0p/AMhzFMAAiD8Cif8HTgA/C9H/TdP/TSQTP0lPwQHNk6BCDgzS/2DBQkBgwsrRHMNDYMgJD6BdL8qCVMAHB77QAFARsAXTmP9BEpfwSkRLfwoQQD8PlX9Rlz9MARI/cACQFb9SV6Q/UJY/QAFSF7BBSAySv0gOoQJQ1mQ/ThP/cAITWKBCRmABiM9vyqJAPsAHADrABvgX3DvugDC+Kiu3Wd36gGAVyA36X+N+Olg6ep8iOUAI8AC0gDV8JWe5n+O/QCfqvvGy/N9igLnQE8sRPp+jfsBgAl+i+p/jfqvALj8vcLoWWvv5EddgSoiPAGAPymCAAD4ABvjABnRACAXxH+L5wAdEi4A/AAd9gAZ0AAAFrv9/f4PK/wIABrdwAK+xfY/AFX2ABe/ABSqABAkts7T+n2LgO8UMPwAGM6ACQPBO4IGMEPV3d/sCGBw6UBeKkP8Ew4vfxBfAEMAHOoAGgLXQAB/jfV+i/CDQE5hEx3yABjKABAEITvCFhfCvsb+AEpe8gAc7wAZANIAFa8/UdDsfO78ICYAB8AEwGdBBhoA2AAWto+b8Zfwoew6UeEp4EcfEF8AAewU85ii7lJl8ABKX/c/Vvw/Uk7bABDAT2EEF8TgFE+cYu5AgeFEQBUXwqADD8Bt4xTABEID6QAYy+A/UdO+xoEpoAOBAgd/EF8A4Wgc7AAa2gHhFIzsnKf3R1wE9UCAFFTsP1HUCe8UHzmBgwAc7gDgGc/5+frpFCBxoUgAHfZPYu2yueuPg4b/FF8AhJIAHfRBKgAb4H+M7n6N+C3ADQyAX+E+zAAQLEUo/QYjgFDN4BRTZg7uoCTAaqBjX3Du1STY8wETGdHABC5HB2F/YFtAsZ+q+ZiiePAHJCEX/2hfAEMA+dtBEsANHuBioHjl4EqADnGDONXV1mCOwAFgAaoEsN+gY0tg/UVbAP1SZfHu8P5PAGP0AB31ABznD8AEwJSAlWAHb3/37uDw/SA35sA0gDXhICN/EF8AABztwXka3gCPmu/e4fre4hD8jJn24CkwRu8IvsTyACW4v/YwjEj8YAGgD87U/KAqAUAAr7f3P1TvACAb5DBF4cMEvsZC+0ID/J+p82CaAMwb4sFJIDUe+n8QLwBDLwCRL84AFrUgRQAEE6NRABjHABnVA2A74QAToAAXwAAcFbK0ACYAQAEa2QAgGdQAFKmqARSkWAAXw9EuQQrxYhr7L08HLwAvAH4K78E+F8XnoQcjAHAKGMyAM+cAoAfz1gFGARrbcQqJA6kBYAU/TwovAC8ALwD2KTAFG+R4ABvf0B8hACAb4QDh+xQB4QDg1wE2AgAjgWyIA/mpAR33TwovAC8ALwAvAH8vAC8ALwAvAC8ALwAtAAA='
	$HDDbmp = _WinAPI_Base64Decode($HDDbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($HDDbmp) & ']')
	DllStructSetData($tSource, 1, $HDDbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 2744)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\HDD.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_HDDbmp

Func _BIOSbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $BIOSbmp
	$BIOSbmp &= 'rLSgQk24CgACADYAMCooADA4ABgQABgBAMoYAriCAHwSCwMMBQAI9odRywhS9olUAPaOW/eTYveU5mQKAYAIkWCHCwkHlQUFAQdjhAWSYfaNWgj2iFPDU4hS9osCVgAr+J1x+KB2AQcBoXf4n3T4mz5uhAsJB5UFBhPFBfeXBmmBKj8ph1HzhVAI74NPwFP4nXD5IKmC+Kd/gRilfYj5q4ZAAfeXaMQFAKiB+J9z95ZnAPeabPimfuypCIrvpEAEdPmpgwPAC8QFpXz1qYbqAKiL9aB4+auFgYAS95tu95BePykBgADof0zYd0fhAJ6D99TI5tvYAOi5p/fHtfjgANngw7n4nnL1BKiIwwXitKL3kABf945b7b2q3wDDuPO1nPC1nkD53NLlva3BL5MAYvXDsOTNxeEAuan1sJT43NJA48G0+KJ5gDn3DI9dPymAAOR9S8oAb0KyYTrFkX0I9uHbgJPFbEG0AGM7+ePb6q+WwON8S8uUfsAFgEVA9IZQ9sa0wCbbAHhIz3JEsGA6AKpdOO/Kve7EArQAI+O+sO7QxgFAPchuQrtnPvsA8O3uo4H3lWUY949c3xBfAFHpgABN1HRGzHBDzgCWf/vk3PeWZgPAaiAR9dHE6LKcQPWGUdSYgOEClQBl4nxK+vDt82CmhuZ+TAAEwBm1AGQ8xX9h/Pb1geAs362a6rKdQ3KI7IteQDDtpYb/FAdfAOdTQCrSc0XQlgB//Orl7qeI9gCoh/PFtOfc2YD1lmntgk7P4xfElWVgBP39/kA5QGMA8oVQ13ZHznEQRL1oPoAC8qJ/A+CGIH3ypYDtuKIA+e/t9c2+9ooeVeCA/2hfAOSS539MiNV1RuMU8KeHYFXA7dfQ9cu7oHVgPYHsFPWfdfeYaqEVDItWozzhFKF79pIQY+fQyEBU5rGcONOGZcAfgVOgk45bH38QXwDhkuB9QDnWmYFD4z7AasdtQftgK6Umg2Ai5AKUY0AS+emw5OyrkGGCYY5oQDxA5Y9q7ujnwD3oAMCy9tvS9opWiOqBTQAK6se6/2gfXwCHKSBQYB8ADe2khhjex79gi+AL9ZRmmQFMp4jAZ+QCn3MgBYjfpo9gLvWifMGRBKR7ACv529H2vwCq0HJF2bKk9gze14ACQBj1mW/f/N/ggZL/U18AQABADyApAwAogDX05+P89/YzwHyhJ+jkAEyAUO60Yp3jAvTc1GAlYGfTBKCMwH/41Mf6zwC/9eHb7Luo3wB6SdFzRbFsTADv2ND649v5zvC/7tHH4H3Bx/9TLwAFLwBRkAjceUjBagBApFo2nlc0nARWMyMApls3wmqAQM1wQ69gOXMBB6BGYEHgSKVbNqNZ8DaoXDcgA/A+MAIQBADNcUSnXDefV0Y0gAMgAKFYNfA13fx5SUF58G6vBy8ALwB8XsSATdAQv2k/kAgpAI9wClAqdgHgANZ2R3AKfsCYAgAOEArjVHkB9gLr/IFOUVd/By8ALwB+SSBUgbAb2nhI2XdHJgD/0BBAAbAScwHgANA9QCKZAuNAATBN7IJOEEMcBPMC+PGET6AlTwcvAC8ALwB/LwAvAC8ALwAvAC8ALwAAAAA='
	$BIOSbmp = _WinAPI_Base64Decode($BIOSbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($BIOSbmp) & ']')
	DllStructSetData($tSource, 1, $BIOSbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 2744)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\BIOS.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_BIOSbmp

Func _SSDbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $SSDbmp
	$SSDbmp &= '/LOgQk24CgACADYAMCooADA4ABgQABgBAMoYAriCAHwSCwMMBQAIB44qzwgIjisLAJAtFZQ2H5k/iCKaQQABIJpAgwUHBgQVCgkBHZg9FJQQNQqPLdRTCY8sCA+SMQA0NaNRPACmVzymWDmlVQ+CBQYEFQoJAVg6pVU4Kp5IwDu/KpMAjCoIB4opgEIuoEtEAKpfVa5sZax2AEOlW1GwaT+oAloABUOpXlOtagEABUKlW06uZztEpVYABUWqX8ACRwSrYUAHTa5mS60AZEKpXTikVCgcnUaAEn8lkACGKAYAfiUHhSeexqUAvM/Al7ufebQAg8jdzKXDrDAAoU2fx6bG08kgkbuaebMBBZu/AqMATaPJqtvj3QClxKykyqu914DB1OHXkLqZwCyIPadZgAwZljp/JQGPAAaDJwZ4IwYAcyKjvqm80sEBgQNzIgVsIOnxAOtWp2ajwKmwBMu1QDEGdCIFb4Ah9Pf1RaFawAIA1OLXaKt0BWsAIAVgHClxON9g6uGTvZxAf8BTGByWOH8l8xRgEGofiGCrjnmtgqBLYEwqAJFA09zVZqxzAIiykFedZAyQAi6DAtzg3lWnZwAGeSTU5ddhqgBxB4coBncjBQBjHWiZcfL18wA0olAjm0IXlQ43/w5fAE4AiCgGgRImQT+KKaBpU6poAIu7lenw67DPIrYgAgeNKoACXauOcIACgCmDAgZ1I+AUOGCpcUESQC1AFW0g+P39/uBW/xRfAPlowChAK5dDv9HDQFSIILSQQotQ4AIlnIBEK5dCwNPE4AKJgQKMUMAWHpk+4EQj4xQABBGSMiFcdCI4+fn6/xRfAPpofSUABoAmo8OpyNwwzA6RMKA5IBeryQKygGKjxaq91sEHQY2CAgAWMaFOBnoR4T5iqnMABCacRYEAfIi2kN7n4eCbOByYPP99XwD0U3YjAAVuIJa0nM7gBtLAiyChQp9V29sA3BOTNKPCqbUE0bqDAlSlY97eAt+AJgeEJ7XIugBprXlQr2lKrRBkZa11QEJ5r4M/YECgxgCy/w5fAPEpeSQB4BQpcDjI2czUAOTXsNG2yNrMAeB9BoInKXg61ODh1sjezIMCgFAAK/jU4NYAE2B8oCpAAKAw+GmndCAy4BRDWp8OLwADLwAsAIspBn8mBkRyIhBGBVwbUQBeSYIAbCABMmYeTAEFMmQRAQRaJwCRAnsk4UEKiCgHjH8KLwAvAJsvAC8AKuFFIBVvIWEI0SUABnAhgVRuTQGQF/MZAZQCfCUBLE8KLwAvAH8vAC8AJj+gCtJJMTUjAID+JhEBoBZMAeAAGQFCAcAj/3AZTwovAC8ALwAvAC8ALwAfLwAvAC8ALwAvAAAA'
	$SSDbmp = _WinAPI_Base64Decode($SSDbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($SSDbmp) & ']')
	DllStructSetData($tSource, 1, $SSDbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 2744)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\SSD.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_SSDbmp

Func _UEFIbmp($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $UEFIbmp
	$UEFIbmp &= 'TrSgQk24CgACADYAMCooADA4ABgQABgBAMoYAriCAHwSCwMMBQAIR0pPyQhIS1BKAE1SUVRZWFtgQFlcYFdaXoACWwBeYlhaX1NVWj+ACwMHCQEJE4MUABNMTwZUCRYAClBTWElMIlFIUk9SV4AsaWuAb21vc2dpbQAECG9xdYAFYmRpXMRfYwAHbnB0BgEADXBsbnJmAhMDB4MUVoxZXQMiBgpgY2eAKuM/KcMpS05TwCkAU0AfQIGChoOFiMAafAB+gXV3e2BiZgPATUAcfX+Dd3p9gUAfb3J2dnh8gAYIYWRowwV6fH9x4HN3ZGZrgCSAAAACCHR2egMFZWhsVQxXXD8pgABGSU5FBEhNgCp2eHvIyADKoqOljo+S0GDQ0qqrrQAawB2aAJud1NXWwsPEAKmqrLGytbGyALTKysyEhYiaRJyewwWkpaiAeFIAVVlDRktiZGgAsbG029vcnp+AooOEh1pcYf9TA4MAABc/QkZBREgY4+PkAFPAAjU4OwA0NjrZ2tuDhAKIQEM9P0Sur7AIsLGzQQpBRjk7AD+vsLGBg4U7jD5CwwWAjVNWW4AqAQAIOTxANTc72YzZ24AtQEBLTlLgNUPfEF8AT0JFSSARNwA5Pf39/l5hZQHACkBCRzg6PrEgsbOlpqiAYkNFIkqAEaeoq2BAl5gCm4A+f4GDYWNmD6AG4AJgBKA/kZKVgkSDhkAnQENIQAnaANrbX2FmUFNX/+AUoBXfEF8A6hRASwB8IwKPYBBAP8MBYAG4uLpgPTi6urygOaAGwC48PwBDsLGyzMzOpwCoqsXGx4SGiY8gWUAq4xRACVpdYsB/z38QXwCBaMAlPkD8FAA9wMDBw4CBhOARYEMH4BFgPUAVrq+xxsYAyH5/gsXFx4EEg4aAL01QVTo8AkDjFF1gZFRXW///kl8A4RSAaCARgAvgFCCSD2ANIDVgEOsUsq2usIFgJYGChWtucUAnQHBydkJFSuoCbfBxk5SXgJVgHOAUQAl4Y2ZqoD9fKl8AgX1EBEdMoABCREnV1R7W4Ikgj0NgoHugoaNHYA1gGWABnp+hYBNyBHV4oFGbnJ6Fhn6JwAfpAkCQwEAgm+AXvYy9vwCX4JhqbHAAH4eAL58RnH1KPkFF4D4I2Nja4CnS0tR4jHp94CPgUOzs7UAAH0ASZgEggAAlYHnr6+wIgoSG7ALY2dr1APX2c3V42NjZgQAB09PUlJWXgBQvIDJffi8ATDREER8wMgA2LjAzLS8yNow4PNBGUAAwMjUQAcEQRjQ3Oi8xsQDQAR8mAAACoAEzAnwBMjQ440MBAAI+QEVAJU8HLwDnLwDPU8E+Oj4gBiAA4Ej/AFAwNeYAtgApAH8BfwGwAPFgGkRHS39JLwAvAP8pv6AKQE+AMzBckFOyAEfmAH+BALIAKQB/AX8BsABAJUb+Sf8ULwAvAC8ALwAvAC8AHy8ALwAvAC8AJAAAAA=='
	$UEFIbmp = _WinAPI_Base64Decode($UEFIbmp)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($UEFIbmp) & ']')
	DllStructSetData($tSource, 1, $UEFIbmp)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 2744)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\UEFI.bmp", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_UEFIbmp
Func _Setico($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $Setico
	$Setico &= 'D7RIAAABABAgIAFwIAAAqBAAABYAAMwAKAAYAJAAQAAYAVwNAQCAAGwQAgE4ODgACSIiIhYnJyc+Gv8A3wDBGsEcwR4nOgA6DTlIUVg5R8BRhDdFTov/AN8AQcEaOUhUWDrAHm8Ao8ond7LcyHKAr9vwca7b8v8AB98AwRrAHMlvo9EnAIrN+jmMzv3dAITI+vqCx/r/F/8AfwBhDY1gDojO/gA6g8n+PoXL/gDee8b7+XnF/B7/fwB/AH0AYQ2FzP4C3mEPcMH+Qm3BAP7gZr3892O8fPz/fwB/AH0AYQ1hDm4Awv5DW7r+TlQAtv7iTbP99kv4svz/fwB/AH0AYQ1hDgBYtv5RSLH+XwA+rf3kOqv79vA4qvz/fwB/AH0AYQ0CPWAOR7H/YD6tAPxqNan85TKnwPv1Mab7/38AfwAHfQBhDWEOQK38azgAqvpwMKb65i+Apfr0LqX6/38Ah38AfQBhDTCm++ZgIQBwM6j6diyk+gDmK6P49Cuj+U7/fwB/AH8A+PRhDjMAp/p3LqT5hScAofnmJ6H48yj4ofj/fwB/AD8AOwCxBgExBy2k+YcnoPgAlCOe9+Yknvbg8yWf9/8/AD8APwA/PwA/ADcAsQYxB7AHlSEAnPOeH5z25iGAnfXzIp72/z8Afz8APwA/AD8ANwCxBjIHnAD1nhyZ8qMamCDz5h2a9DAB9f//PwA/AD8APwA/ADcAsQYxBwAcmfSjFpTwqgAWlvLmGZjz8/AcmvT/PwA/AD8APwAPPwA3ALEGMQcWlvGqgBCS77USk/CxAPDzGZjysAE/AD8APwCHPwA/ADUAFpXx8zEHABCR7rYNkO2/MA6S7+bwADAJ8f//PwA/AD8APwA/ADcAsQYxBwGxBwmN7sQJj+7w5g6Q7zEJsQE/AD8APz8APwA/ADQAsQYxBwmNQOzFCo7ryfMH7uDzE5Pv/z8APwA/AD8/AD8ANwCxBjEHsQdIqQDurFSw8NJVrMDv6Vmu8P8/AD8APz8APwA/ADcAsQYxB0iqAPCsVKnyFVqsAO4fVqHmkHCy4PH/cbPyPwA/AD8ADz8APwAwADEGV6LnjwcxB7EHRbBdsfGAc8DE/f91xf4/AD8ADz8APwA/ADAAdMP9/xBgsvB/TbhhtfEAgHfG/v95x/8DPwAwAHfG/fxvv8D55m7A+d8/AD8AAz8AMwBtvvjbXrME7l79B2a28H98QMj+/3/K/z4AfADH/fxsvPawVYCq6TBPp+cgPwAHPwA/ADMATKrlHlQMjeKxvwoAYLTtVQB2wffYecP53wE6AMT53W+996T4V6/nQ+wPAA8ADwAPAAEMAFWq1AZbreMMHFcwCjkAWqzmH/BOnNcNHwMPAA8ADwAfDwAPAA8ADwAHABmwOgA6AP8MADuaFwDAAAQAAwYDH///wD8BA28='
	$Setico = _WinAPI_Base64Decode($Setico)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($Setico) & ']')
	DllStructSetData($tSource, 1, $Setico)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 4286)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\Set.ico", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_Setico

Func _Toico($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $Toico
	$Toico &= '+LFIAAABABAgIAFwIAAAqBAAABYAAMwAKAAYAJAAQAAYAVwNAQCAAGwNAEAAgP8BgQenisT/0cLgEeIBtJvNyh5mM5lG/z8AKwCEW63KIMHArdX/4tnr6gAJAOPpDcFAUhiM+mvJTMET//+A/x9/AH8AfwD/D38AfwCP/w//D38AbwBcJZJiCz99AOFX6Q9/BmMAeQ9vQP6fH2cfABoAbX//Dx8AHwAHBwDhfHkgek2m/5o8ebx+AOGlaX9/Brz/+I9qtH9AfwD/T38AfwD//w//D3wVcRL/Fz8APwA/AP//Bz8CNQCxVvlafzB7Cj9r/z8AMQD5H3Vt+R7xLLEGvQL/v1+3Pw8ADwAPAA8ADwB/b/9/EnsSf20/AA8ADwAFADEz/38H/xd5BbEAcRS/AncgPQD/cTaxBnkEPyI/AHkQORsBAP/xHL8CPwA1APkDvwc/AD8A/zOZv1N/Ar8H+yb/Lj8APwD/MwDxIn8UfwK/BwMAvxs/AP8/AD8eOQh/EHcbvy5/Aj8A2/8kPyW0Pgh/Apl2pLEb/f8Bmb8/fy8PAA8ADwAPAP8PAPQgsQb9B3ELDwAPAA8A/w8ADwALAL80s08xCH9WPwD/PwA/AD8AMwD/Zz8APwA/AP8/AD8APwA/AD8APwA/AD8Afz8APwA/AD8APwA/ADsACbBQgP9AADcwAHwA'
	$Toico = _WinAPI_Base64Decode($Toico)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($Toico) & ']')
	DllStructSetData($tSource, 1, $Toico)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 4286)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\To.ico", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_Toico

Func _Fromico($bSaveBinary = False, $sSavePath = @ScriptDir)
	Local $Fromico
	$Fromico &= '2bFIAAABABAgIAFwIAAAqBAAABYAAMwAKAAYAJAAQAAYAVwNAQCAAGwNAMCAAP8BAQbPn0D/6tWtEP/v4MJaBuXNmzD/xowYAnMFA9KmxE3/aQD169mKP4FLj20AgbeRP4FN3bx5zgH44cSKyh/BBNEfyQX/AP/LAME2/x//H/8f/x//H/8f4/EP4UTMmTN/AH8AbgD//w8fAB8AHwD/Dx8AHwD/D///Dx8AHwD/D/8/fwB/AP8///9ffwD/X/8Pfwl/AP8P/w//fwB/AP8Hfwb/H78bPwA/AP8/AP8f/wf/Lw8ADwAPAA8A/w8A/y//Bw8ADwAPAA8ADwD//wf/Bw8ADwAPAA8ADwD/B///B/8fPwA/AD8APwD/H/8H//8vPwA/AD8APwD/L/8HfwH/PwA/AD8APwD/B/8HfwE/AP8/AD8APwD/B/8H/6c/AD8A/z8APwA1AHG//yfzB3HHDwD/DwAPAA8ADwAPAP23/8cPAP8PAA8ADwAPAAEA8Ra9GTEI/3EB8Rc/ADsAvcw/AD8ANQD/cRi/IT8APwAzALHbOQj/BP8/AD8APwA/AD8A/yLzD/3kfz8APwA/AD8APwC38gkAyfySJX8CPwA/AD8APwA/AAM2ELEP4cQKsKCK/8CAADYwAHwA'
	$Fromico = _WinAPI_Base64Decode($Fromico)
	Local $tSource = DllStructCreate('byte[' & BinaryLen($Fromico) & ']')
	DllStructSetData($tSource, 1, $Fromico)
	Local $tDecompress
	_WinAPI_LZNTDecompress($tSource, $tDecompress, 4286)
	$tSource = 0
	Local Const $bString = Binary(DllStructGetData($tDecompress, 1))
	If $bSaveBinary Then
		Local Const $hFile = FileOpen($sSavePath & "\From.ico", 18)
		If @error Then Return SetError(1, 0, 0)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_Fromico
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

Func _UpdateStats()

	Local $aEnd_Values, $iRecived, $iSent, $sNew_Label, $iLargest_Value

	$aEnd_Values = _GetAllTraffic()
	$iRecived = $aEnd_Values[0] - $aStart_Values[0]
	$iSent = $aEnd_Values[1] - $aStart_Values[1]

	If Not ($iRecived + $iSent) Then ; No Activity
		Local $sZero = '↓DL [0.0 kB/秒]' & @LF & '↑UL [0.0 kB/秒]'
		If $sLast_Label <> $sZero Then GUICtrlSetData($Label1, $sZero)
		$aStart_Values = $aEnd_Values
		$sLast_Label = $sZero
		Return
	EndIf
	If $iSent >= $iRecived Then
		$iLargest_Value = $iSent
	Else
		$iLargest_Value = $iRecived
	EndIf

	If $iLargest_Value >= 1048576 Then
		$sNew_Label = '↓DL [' & StringFormat('%.2f', Round($iRecived / 1048576, 2)) & ' mB/秒]' & @LF & '↑UL [' & StringFormat('%.2f', Round($iSent / 1048576, 2)) & ' mB/秒]'
		If $sNew_Label <> $sLast_Label Then GUICtrlSetData($Label1, $sNew_Label)
	Else
		$sNew_Label = '↓DL[' & StringFormat('%.1f', Round($iRecived / 1024, 1)) & ' kB/秒]' & @LF & '↑UL[' & StringFormat('%.1f', Round($iSent / 1024, 1)) & 'kB/秒]'
		If $sNew_Label <> $sLast_Label Then GUICtrlSetData($Label1, $sNew_Label)
	EndIf

	$sLast_Label = $sNew_Label
	$aStart_Values = $aEnd_Values

EndFunc   ;==>_UpdateStats

Func _GetAllTraffic()

	Local $Total_Values[2], $Adapter_Values
	Local $ifcount = _GetNumberofInterfaces()

;~ 	If $Global_IF_Count <> $ifcount Then
;~ 		TrayTip("网卡数量信息发生改变", "流量统计功能尝试重新初始化...", 10, 3)
;~ 		$Global_IF_Count = $ifcount
;~ 		$Table_Data = _WinAPI_GetIfTable()
;~ 		$aStart_Values = _GetAllTraffic()
;~ 	EndIf

	For $i = 1 To $Table_Data[0][0]
		$Adapter_Values = _WinAPI_GetIfEntry($Table_Data[$i][1])
		If IsArray($Adapter_Values) Then
			$Total_Values[0] += $Adapter_Values[0] ;Recived
			$Total_Values[1] += $Adapter_Values[1] ;Sent
;~ 		Else
;~ 			;ConsoleWrite('Error: Adaptor Count has change.' & @CRLF & 'Attepting to reinitalize...')
;~             TrayTip("网卡数量信息发生改变", "流量统计功能尝试重新初始化...", 10, 3)
;~ 			$Table_Data = _WinAPI_GetIfTable()
		EndIf
	Next

	Return $Total_Values

EndFunc   ;==>_GetAllTraffic

Func _WinAPI_GetIfEntry($iIndex)

	Local $ret, $Stats[2]
	Static $tMIB_IFROW = DllStructCreate($tagMIB_IFROW)

	DllStructSetData($tMIB_IFROW, 2, $iIndex)

	$ret = DllCall($IPHlpApi_Dll, 'dword', 'GetIfEntry', 'ptr', DllStructGetPtr($tMIB_IFROW))
	If (@error) Or ($ret[0]) Then Return SetError($ret[0], 0, 0)

	$Stats[0] = DllStructGetData($tMIB_IFROW, 'InOctets') ;Recived
	$Stats[1] = DllStructGetData($tMIB_IFROW, 'OutOctets') ;Sent

	Return $Stats

EndFunc   ;==>_WinAPI_GetIfEntry

Func _GetNumberofInterfaces()
	Local $Adaptor_Count = DllCall($IPHlpApi_Dll, 'int', 'GetNumberOfInterfaces', 'dword*', 0)
	Return $Adaptor_Count[1]
EndFunc   ;==>_GetNumberofInterfaces

Func _WinAPI_GetIfTable($iType = 0)

	Local $ret, $Row, $Type, $Tag, $Tab, $Addr, $count, $Lenght, $tMIB_IFTABLE
	Local $tMIB_IFROW = DllStructCreate($tagMIB_IFROW)

	$Row = 'byte[' & DllStructGetSize($tMIB_IFROW) & ']'
	$Tag = 'dword;'
	For $i = 1 To 32
		$Tag &= $Row & ';'
	Next
	$tMIB_IFTABLE = DllStructCreate($Tag)
	$ret = DllCall($IPHlpApi_Dll, 'dword', 'GetIfTable', 'ptr', DllStructGetPtr($tMIB_IFTABLE), 'long*', DllStructGetSize($tMIB_IFTABLE), 'int', 1)
	If (@error) Or ($ret[0]) Then Return SetError($ret[0], 0, 0)

	$count = DllStructGetData($tMIB_IFTABLE, 1)
	Dim $Tab[$count + 1][20]
	$Tab[0][0] = 0
	$Tab[0][1] = 'Index'
	$Tab[0][2] = 'Type'
	$Tab[0][3] = 'Mtu'
	$Tab[0][4] = 'Speed'
	$Tab[0][5] = 'Address'
	$Tab[0][6] = 'AdminStatus'
	$Tab[0][7] = 'OperStatus'
	$Tab[0][8] = 'InOctets'
	$Tab[0][9] = 'InUcastPkts'
	$Tab[0][10] = 'InNUcastPkts'
	$Tab[0][11] = 'InDiscards'
	$Tab[0][12] = 'InErrors'
	$Tab[0][13] = 'InUnknownProtos'
	$Tab[0][14] = 'OutOctets'
	$Tab[0][15] = 'OutUcastPkts'
	$Tab[0][16] = 'OutNUcastPkts'
	$Tab[0][17] = 'OutDiscards'
	$Tab[0][18] = 'OutErrors'

	For $i = 1 To $count
		$tMIB_IFROW = DllStructCreate($tagMIB_IFROW, DllStructGetPtr($tMIB_IFTABLE, $i + 1))
		$Type = DllStructGetData($tMIB_IFROW, 'Type')
		If $Type <> $MIB_IF_TYPE_SOFTWARE_LOOPBACK Then
			$Tab[0][0] += 1

			$Lenght = DllStructGetData($tMIB_IFROW, 'PhysAddrLen')
			$Addr = ''
			For $j = 1 To $Lenght
				$Addr &= Hex(DllStructGetData($tMIB_IFROW, 'PhysAddr', $j), 2) & '-'
			Next
			$Addr = StringTrimRight($Addr, 1)

			_ArraySearch($Tab, $Addr, 1, $Tab[0][0] - 1, 1, 0, 1, 5)
			If @error <> 6 Or $Addr = '' Or StringLen($Addr) > 17 Then
				$Tab[0][0] -= 1
				ContinueLoop
			EndIf

			$Tab[$Tab[0][0]][0] = DllStructGetData($tMIB_IFROW, 'Name')
			$Tab[$Tab[0][0]][1] = DllStructGetData($tMIB_IFROW, 'Index')
			$Tab[$Tab[0][0]][2] = $Type
			$Tab[$Tab[0][0]][3] = DllStructGetData($tMIB_IFROW, 'Mtu')
			$Tab[$Tab[0][0]][4] = DllStructGetData($tMIB_IFROW, 'Speed')
			$Tab[$Tab[0][0]][5] = $Addr
			$Tab[$Tab[0][0]][6] = DllStructGetData($tMIB_IFROW, 'AdminStatus')
			$Tab[$Tab[0][0]][7] = DllStructGetData($tMIB_IFROW, 'OperStatus')
			$Tab[$Tab[0][0]][8] = DllStructGetData($tMIB_IFROW, 'InOctets')
			$Tab[$Tab[0][0]][9] = DllStructGetData($tMIB_IFROW, 'InUcastPkts')
			$Tab[$Tab[0][0]][10] = DllStructGetData($tMIB_IFROW, 'InNUcastPkts')
			$Tab[$Tab[0][0]][11] = DllStructGetData($tMIB_IFROW, 'InDiscards')
			$Tab[$Tab[0][0]][12] = DllStructGetData($tMIB_IFROW, 'InErrors')
			$Tab[$Tab[0][0]][13] = DllStructGetData($tMIB_IFROW, 'InUnknownProtos')
			$Tab[$Tab[0][0]][14] = DllStructGetData($tMIB_IFROW, 'OutOctets')
			$Tab[$Tab[0][0]][15] = DllStructGetData($tMIB_IFROW, 'OutUcastPkts')
			$Tab[$Tab[0][0]][16] = DllStructGetData($tMIB_IFROW, 'OutNUcastPkts')
			$Tab[$Tab[0][0]][17] = DllStructGetData($tMIB_IFROW, 'OutDiscards')
			$Tab[$Tab[0][0]][18] = DllStructGetData($tMIB_IFROW, 'OutErrors')
			$Tab[$Tab[0][0]][19] = StringLeft(DllStructGetData($tMIB_IFROW, 'Descr'), DllStructGetData($tMIB_IFROW, 'DescrLen') - 1)
		EndIf
	Next

	If $Tab[0][0] < $count Then ReDim $Tab[$Tab[0][0] + 1][20]

	Return $Tab
EndFunc   ;==>_WinAPI_GetIfTable

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
Func _GuiDownloadBingWallPaper()
	Global $FormBingWallPaper = GUICreate("Bing 18天壁纸下载器", 311, 124, 170, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("壁纸保存目录", 8, 8, 281, 41)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $BingWallpaperSavePath = GUICtrlCreateInput("", 16, 24, 209, 21)
	GUICtrlSetState(-1, $GUI_ACCEPTFILES)
	GUICtrlCreateButton("....", 232, 24, 43, 21)
	GUICtrlSetOnEvent(-1, '_SelectWPSavePath')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $WallPaperDownloadProcess = GUICtrlCreateProgress(8, 56, 278, 9, $PBS_SMOOTH)
	GUICtrlSetColor(-1, 0x008000)
	Global $StartDownLoadWP = GUICtrlCreateButton("下载壁纸", 8, 96, 283, 25)
	GUICtrlSetOnEvent(-1, '_DownloadBingWallPapers')
	Global $WallPaperDownloadLB = GUICtrlCreateLabel("", 8, 72, 292, 17)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_QuitWPUI')
EndFunc   ;==>_GuiDownloadBingWallPaper
Func _QuitWPUI()
	_WinAPI_AnimateWindow($FormBingWallPaper, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormBingWallPaper)
EndFunc   ;==>_QuitWPUI
Func _SelectWPSavePath()
	Local $dir = FileSelectFolder('请选择您所下载壁纸的保存路径', '')
	If $dir <> '' Then
		GUICtrlSetData($BingWallpaperSavePath, $dir)
	EndIf
EndFunc   ;==>_SelectWPSavePath
Func _DownloadBingWallPapers()
	$SavePath = GUICtrlRead($BingWallpaperSavePath)
	GUICtrlSetData($WallPaperDownloadLB, '等待下载操作...')
	GUICtrlSetData($StartDownLoadWP, '正在下载壁纸...')
	GUICtrlSetState($StartDownLoadWP, $GUI_DISABLE)
	For $i = -1 To 16
		Local $xml = BinaryToString(InetRead('http://cn.bing.com/HPImageArchive.aspx?format=xml&idx=' & $i & '&n=1'))
		Local $url = _XML_GetElementsByTag($xml, 'url')
		Local $Date = _XML_GetElementsByTag($xml, 'startdate')
		GUICtrlSetData($WallPaperDownloadProcess, ($i + 2) / 18 * 100)
		If $Date <> '' Then
			GUICtrlSetData($WallPaperDownloadLB, '[' & $i + 2 & '/18]开始下载壁纸' & $Date[0])
			InetGet('http://s.cn.bing.net/' & $url[0], $SavePath & '\WallPaper' & $Date[0] & '.JPG')
		Else
			GUICtrlSetData($WallPaperDownloadLB, '[' & $i + 2 & '/18]获取壁纸失败，程序自动跳过...')
			ContinueLoop
		EndIf
	Next
	GUICtrlSetData($StartDownLoadWP, '开始下载壁纸')
	GUICtrlSetState($StartDownLoadWP, $GUI_ENABLE)
	GUICtrlSetData($WallPaperDownloadLB, '恭喜~！壁纸下载完成~~')
	MsgBox(0, '', '壁纸下载完成~~', 5)
	GUICtrlSetData($WallPaperDownloadProcess, 0)
EndFunc   ;==>_DownloadBingWallPapers
Func _XML_GetElementsByTag($sSource, $sTag = "", $fIsCDATA = Default)
	Local $aMatches
	$sTag = ($sTag ? '\Q' & $sTag & '\E.*?' : '\w+?')

	$aMatches = StringRegExp($sSource, '(?s)' & _
			'<' & $sTag & '>' & ($fIsCDATA ? '<!\[CDATA\[' : '') & _ ; beginning
			'(.*?)' & _ ; body
			($fIsCDATA ? ']]>' : '') & '</' & $sTag & '>', 3) ;         ending
	If @error Then Return SetError(1, 0, "")

	If Not $fIsCDATA Then
		For $i = 0 To UBound($aMatches) - 1
			$aMatches[$i] = (StringLeft($aMatches[$i], 9) = '<![CDATA[' ? StringMid($aMatches[$i], 10, StringLen($aMatches[$i]) - 12) : $aMatches[$i])
		Next
	EndIf

	Return $aMatches
EndFunc   ;==>_XML_GetElementsByTag
Func RemoveWD()
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}')
	RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	_ForceUpdate()
	MsgBox(0, '提示', '移除Windows Defender右键菜单成功！', 5)
EndFunc   ;==>RemoveWD
Func RestoreWD()
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\EPP', '', 'REG_SZ', '{09A47860-11B0-4DA5-AFA5-26D86198A780}')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0', '', 'REG_SZ', 'Morro Shell Extension 1.0 Type Library')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\0\win32', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender\shellext.dll')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\FLAGS', '', 'REG_SZ', '0')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\TypeLib\{93EB5B57-E8B9-4576-8425-C0D3D6195B4F}\1.0\HELPDIR', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32', '', 'REG_SZ', 'C:\Program Files (x86)\Windows Defender\shellext.dll')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32', 'ThreadingModel', 'REG_SZ', 'Apartment')
	RegWrite('HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\Version', '', 'REG_SZ', '4.0.0106.0')
	_ForceUpdate()
	MsgBox(0, '提示', '恢复Windows Defender右键菜单成功！', 5)
EndFunc   ;==>RestoreWD

Func FormWinX()
	Global $Formwinx = GUICreate("Win+X一键设置", 303, 51, 170, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("Win+X默认打开cmdlet", 8, 0, 281, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	Global $CbWinxOpt = GUICtrlCreateCombo("CMD", 16, 16, 145, 25, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, "PowerShell")
	GUICtrlCreateButton("设置", 208, 16, 75, 25)
	GUICtrlSetOnEvent(-1, '_SetWinX')
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_Quitwinx')

EndFunc   ;==>FormWinX

Func _SetWinX()
	If GUICtrlRead($CbWinxOpt) = "CMD" Then
;~ 		Reg.exe add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DontUsePowerShellOnWinX" /t REG_DWORD /d "1" /f
		RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DontUsePowerShellOnWinX', 'REG_DWORD', '1')
	Else
		RegWrite('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'DontUsePowerShellOnWinX', 'REG_DWORD', '0')
	EndIf
	_ForceUpdate()
	MsgBox(0, '提示', '应用选项成功！', 5)
EndFunc   ;==>_SetWinX


Func _Quitwinx()
	_WinAPI_AnimateWindow($Formwinx, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($Formwinx)
EndFunc   ;==>_Quitwinx

Func formdefaultFileName()

	Global $FormdefaultFileName = GUICreate("修改新建默认文件名", 298, 51, 170, 150, -1, BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE, $WS_EX_ACCEPTFILES, $WS_EX_MDICHILD), $Form1)
	GUICtrlCreateGroup("新建默认文件名", 8, 0, 281, 49)
	_removeEffect()
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetBkColor(-1, $aGroupBkcolor[$ibkcolor])
	GUICtrlCreateButton("修改", 216, 16, 67, 25)
	GUICtrlSetOnEvent(-1, '_SetDefaultFileName')
	Global $sdefaultFileName = GUICtrlCreateInput("%s", 24, 16, 153, 21)
	GUICtrlCreateLabel("默认", 184, 24, 28, 17)
	GUICtrlSetOnEvent(-1, '_setsysdafaultFileName')
	GUICtrlSetFont(-1, 4, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x800080)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_Quitwindfn')

EndFunc   ;==>formdefaultFileName
Func _Quitwindfn()
	_WinAPI_AnimateWindow($FormdefaultFileName, BitOR($AW_BLEND, $AW_HIDE))
	GUIDelete($FormdefaultFileName)
EndFunc   ;==>_Quitwindfn
Func _setsysdafaultFileName()
	GUICtrlSetData($sdefaultFileName, '%s')
EndFunc   ;==>_setsysdafaultFileName
Func _SetDefaultFileName()
	If GUICtrlRead($sdefaultFileName) <> "" Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates', 'RenameNameTemplate', 'REG_SZ', GUICtrlRead($sdefaultFileName))
		_ForceUpdate()
		MsgBox(0, '提示', '修改新建默认文件名成功！', 5)
	Else
		MsgBox(16, '提示', '默认文件名不能为空！', 5)
	EndIf
EndFunc   ;==>_SetDefaultFileName

Func IsUEFIBoot()
	Local Const $ERROR_INVALID_FUNCTION = 0x1
	Local $hDLL = DllOpen("Kernel32.dll")
	If @OSBuild > 8000 Then
		Local $aCall = DllCall($hDLL, "int", "GetFirmwareType", "int*", 0)
		DllClose($hDLL)
		If Not @error And $aCall[0] Then
			Switch $aCall[1]
				; 1 - bios 2- uefi 3-unknown
				Case 2
					Return True
				Case Else
					Return False
			EndSwitch
		EndIf
		Return False


	Else
		DllCall($hDLL, "dword", "GetFirmwareEnvironmentVariableW", "wstr", "", "wstr", '{00000000-0000-0000-0000-000000000000}', "wstr", Null, "dword", 0)
		DllClose($hDLL)
		If _WinAPI_GetLastError() = $ERROR_INVALID_FUNCTION Then
			Return False
		Else
			Return True
		EndIf
	EndIf
EndFunc   ;==>IsUEFIBoot
Func CheckUpdate()
	Local $version = ""
	$data = InetRead($UerHome, 1)
	Local $aSRE = StringRegExp(BinaryToString($data), 'id="nt6ver">(.+)</button>', 3)
	If Not @error Then
		$version = $aSRE[0]
	EndIf
	If $version = $EXEVerson Then
		MsgBox(0, '提示', '当前版本已经是最新！' & @LF & "官网:" & $version & "<->当前:" & $EXEVerson, 5)
	ElseIf $version = "" Then
		If MsgBox(4, '提示', '获取版本信息失败,是否立即前往官网？', 5) = 6 Then
			ShellExecute($UerHome)
		EndIf
	ElseIf $version > $EXEVerson Then
		If MsgBox(4, '提示', '发现官网新版本' & $version & ',是否立即前往官网？', 5) = 6 Then
			ShellExecute($UerHome)
		EndIf
	Else
		MsgBox(0, '提示', '您属于高级VIP用户，正在使用内部版本，请勿对外传播当前版本！！' & @LF & "官网:" & $version & "<->当前:" & $EXEVerson, 5)
	EndIf
EndFunc   ;==>CheckUpdate
