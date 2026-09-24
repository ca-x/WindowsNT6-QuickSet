#Region ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#PRE_Icon=src\img\ToolIco.ico
#PRE_Outfile=WindowsNT6+快速设置工具.exe
#PRE_Outfile_x64=WindowsNT6+快速设置工具_x64.exe
#PRE_UseUpx=y
#PRE_Compile_Both=y
#PRE_Res_Comment=Windows NT6+ 快速设置工具 By 虫子樱桃
#PRE_Res_Description=Windows NT6+ 快速设置工具By 虫子樱桃
#PRE_Res_Fileversion=1.8.6.6
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
;===============================================================================
; 项目入口文件：只保留编译指令与 #include 清单，代码按功能模块存放于 src\ 目录
; 目录说明：src\app 主流程 / src\core 基础库 / src\features 功能模块 /
;           src\os 按系统版本的实现 / src\file 运行时载荷 / src\img 资源
;===============================================================================

#Region ;**** 本地 UDF 与 AutoIt 标准库 ****
#include 'src\file\_GUIDisable.au3'
#include 'src\file\GUICtrlOnHover.au3'
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
#include <InetConstants.au3>
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
#EndRegion ;**** 本地 UDF 与 AutoIt 标准库 ****

#Region ;**** 通用基础库 src\core ****
#include 'src\core\Core_Utils.au3'
#include 'src\core\Core_WinAPI.au3'
#include 'src\core\Core_Gui.au3'
#include 'src\core\Core_Net.au3'
#include 'src\core\Core_Assets.au3'
#EndRegion ;**** 通用基础库 ****

#Region ;**** 功能模块 src\features（按功能域分组） ****
; ---- 网络 ----
#include 'src\features\net\Feat_NetTools.au3'
#include 'src\features\net\Feat_IpSet.au3'
#include 'src\features\net\Feat_MacChange.au3'
#include 'src\features\net\Feat_WifiShare.au3'
#include 'src\features\net\Feat_WOL.au3'
#include 'src\features\net\Feat_NCSI.au3'
; ---- 系统优化 ----
#include 'src\features\system\Feat_RegTweaks.au3'
#include 'src\features\system\Feat_Plugins.au3'
#include 'src\features\system\Feat_Services.au3'
#include 'src\features\system\Feat_SSD.au3'
#include 'src\features\system\Feat_Security.au3'
#include 'src\features\system\Feat_Cache.au3'
#include 'src\features\system\Feat_ProcessBL.au3'
; ---- 资源管理器与外壳 ----
#include 'src\features\shell\Feat_ExplorerMenu.au3'
#include 'src\features\shell\Feat_ShellTweaks.au3'
#include 'src\features\shell\Feat_Share.au3'
#include 'src\features\shell\Feat_DirTransfer.au3'
; ---- 个性化 ----
#include 'src\features\personalize\Feat_OemInfo.au3'
#include 'src\features\personalize\Feat_Wallpaper.au3'
#include 'src\features\personalize\Feat_ScreenSaver.au3'
; ---- 账户与权限 ----
#include 'src\features\account\Feat_UserAccount.au3'
#include 'src\features\account\Feat_SysRun.au3'
; ---- 激活与授权 ----
#include 'src\features\license\Feat_Activation.au3'
; ---- 实用工具 ----
#include 'src\features\tools\Feat_TrayTools.au3'
#include 'src\features\tools\Feat_FileCreate.au3'
#include 'src\features\tools\Feat_DotNet.au3'
#include 'src\features\tools\Feat_History.au3'
#include 'src\features\tools\Feat_Insider.au3'
#include 'src\features\tools\Feat_MkLink.au3'
#include 'src\features\tools\Feat_ForceDel.au3'
#include 'src\features\tools\Feat_TPHotkey.au3'
#EndRegion ;**** 功能模块 ****

#Region ;**** 按系统版本的实现 src\os ****
; Vista 及以后通用实现
#include 'src\os\Os_Common.au3'
; Windows XP / 2003
#include 'src\os\Os_Xp.au3'
; Vista / Win7 / 2008R2
#include 'src\os\Os_Vista7.au3'
; Windows 8 / 8.1 / 2012
#include 'src\os\Os_Win8.au3'
; Windows 10
#include 'src\os\Os_Win10.au3'
; Windows 11
#include 'src\os\Os_Win11.au3'
; Windows Server
#include 'src\os\Os_Server.au3'
#EndRegion ;**** 按系统版本的实现 ****

#Region ;**** 主流程（顺序敏感，勿调整） ****
#include 'src\app\App_Init.au3'
#include 'src\app\App_MainWindow.au3'
#include 'src\app\App_MainLoop.au3'
#EndRegion ;**** 主流程 ****
