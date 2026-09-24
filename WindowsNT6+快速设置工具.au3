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
#include 'src\core\utils.au3'
#include 'src\core\win_api.au3'
#include 'src\core\gui.au3'
#include 'src\core\net.au3'
#include 'src\core\assets.au3'
#EndRegion ;**** 通用基础库 ****

#Region ;**** 功能模块 src\features（按功能域分组） ****
; ---- 网络 ----
#include 'src\features\net\net_tools.au3'
#include 'src\features\net\ip_set.au3'
#include 'src\features\net\mac_change.au3'
#include 'src\features\net\wifi_share.au3'
#include 'src\features\net\wol.au3'
#include 'src\features\net\ncsi.au3'
; ---- 系统优化 ----
#include 'src\features\system\reg_tweaks.au3'
#include 'src\features\system\plugins.au3'
#include 'src\features\system\services.au3'
#include 'src\features\system\ssd.au3'
#include 'src\features\system\security.au3'
#include 'src\features\system\cache.au3'
#include 'src\features\system\process_bl.au3'
; ---- 资源管理器与外壳 ----
#include 'src\features\shell\explorer_menu.au3'
#include 'src\features\shell\shell_tweaks.au3'
#include 'src\features\shell\share.au3'
#include 'src\features\shell\dir_transfer.au3'
; ---- 个性化 ----
#include 'src\features\personalize\oem_info.au3'
#include 'src\features\personalize\wallpaper.au3'
#include 'src\features\personalize\screen_saver.au3'
; ---- 账户与权限 ----
#include 'src\features\account\user_account.au3'
#include 'src\features\account\sys_run.au3'
; ---- 激活与授权 ----
#include 'src\features\license\activation.au3'
; ---- 实用工具 ----
#include 'src\features\tools\tray_tools.au3'
#include 'src\features\tools\file_create.au3'
#include 'src\features\tools\dot_net.au3'
#include 'src\features\tools\history.au3'
#include 'src\features\tools\insider.au3'
#include 'src\features\tools\mk_link.au3'
#include 'src\features\tools\force_del.au3'
#include 'src\features\tools\tp_hotkey.au3'
#EndRegion ;**** 功能模块 ****

#Region ;**** 按系统版本的实现 src\os ****
; Vista 及以后通用实现
#include 'src\os\common.au3'
; Windows XP / 2003
#include 'src\os\xp.au3'
; Vista / Win7 / 2008R2
#include 'src\os\vista7.au3'
; Windows 8 / 8.1 / 2012
#include 'src\os\win8.au3'
; Windows 10
#include 'src\os\win10.au3'
; Windows 11
#include 'src\os\win11.au3'
; Windows Server
#include 'src\os\server.au3'
#EndRegion ;**** 按系统版本的实现 ****

#Region ;**** 主流程（顺序敏感，勿调整） ****
#include 'src\app\init.au3'
#include 'src\app\main_window.au3'
#include 'src\app\main_loop.au3'
#EndRegion ;**** 主流程 ****
