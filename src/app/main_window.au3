;==============================================================================
; 模块：主窗口构建
; 说明：主窗口及各选项卡控件的创建、控件事件绑定、初始数据装载
; 文件：src\app\main_window.au3
; 函数：共 0 个
;==============================================================================
#include-once

; 本文件为顶层可执行代码，由入口文件按顺序 #include，请勿调整 include 次序。

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
	GUICtrlCreateIcon(@ScriptDir & '\src\img\ToolIco.ico', -1, 5, 5, 20, 20)
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
	If @OSBuild < 10240 Then
		$plugins[5] = _GUICtrlCreateCheckbox("安装开发者证书", 8, 232, 169, 17)
		GUICtrlSetTip(-1, '安装开发者证书以后，可以允许您使用第三方Metro App应用程序！', '提示', 1)
	Else
		$plugins[5] = _GUICtrlCreateCheckbox("安装屏保扩展包", 8, 232, 169, 17)
		GUICtrlSetTip(-1, '扩展包包括Fliqlo翻页式时钟屏保和Aerial Apple TV风格屏保！', '提示', 1)
	EndIf
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
