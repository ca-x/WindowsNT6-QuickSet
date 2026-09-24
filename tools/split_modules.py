# -*- coding: utf-8 -*-
"""
把 WindowsNT6+快速设置工具.au3 单文件脚本按功能模块拆分为多个 #include 文件。

目录约定：
    WindowsNT6+快速设置工具.au3   入口/项目文件（编译目标，放在根目录）
    src\\app\\                    主流程（顺序敏感）
    src\\core\\                   通用基础库
    src\\features\\<功能域>\\      功能模块，按功能域分目录
    src\\os\\                     按系统版本分文件的实现
    src\\file\\                   运行时载荷（FileInstall 源）+ 本地 UDF
    src\\img\\                    图片/图标资源

- 函数级拆分：每个函数（含其前面的注释块）原样搬到对应模块。
- 主流程拆分：顶层可执行代码按原顺序拆成 src\\app\\App_*.au3。
- 入口文件：只保留编译指令 + #include 清单。

用法：
    python tools/split_modules.py            # 执行拆分
    python tools/split_modules.py --check    # 只做覆盖性/一致性校验，不写文件
"""
import io
import os
import re
import sys
from collections import OrderedDict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'WindowsNT6+快速设置工具.au3')
BACKUP_DIR = os.path.join(ROOT, 'backup')
BACKUP_SINGLE = os.path.join(BACKUP_DIR, 'WindowsNT6+快速设置工具.single-file.au3')

# ---------------------------------------------------------------- 主流程分段
APP_PARTS = [
    ('src/app/init.au3', 48, 264, '程序初始化',
     '全局常量/变量、运行环境检测、加载动画、托盘菜单、单实例检查'),
    ('src/app/main_window.au3', 265, 1121, '主窗口构建',
     '主窗口及各选项卡控件的创建、控件事件绑定、初始数据装载'),
    ('src/app/main_loop.au3', 1122, 1147, '主循环',
     '窗口显示、输入框回调注册、定时器、消息循环'),
]

# ---------------------------------------------------------------- 模块定义
# 模块 id -> (输出路径, 标题, 说明)
MODULES = OrderedDict()
MODULE_PATHS = {}

# 功能域 -> [(模块 id, 文件名, 标题, 说明), ...]   文件名一律小写、不带目录名前缀
FEATURE_DOMAINS = OrderedDict([
    ('net', ('网络', [
        ('NetTools', 'net_tools', '网络工具', 'Winsock 重置、网络配置备份还原、时间同步、远程桌面端口、雨声白噪音、宽带连接创建'),
        ('IpSet', 'ip_set', 'IP 地址设置', 'IP/DNS 静态与自动获取设置、方案管理、DNS 列表'),
        ('MacChange', 'mac_change', 'MAC 修改与绑定', '网卡 MAC 地址修改、绑定、还原'),
        ('WifiShare', 'wifi_share', 'Wifi 热点共享', '创建 Wifi 热点、ICS 共享设置'),
        ('WOL', 'wol', '网络唤醒', 'WOL 界面、魔术包生成与发送、计划任务'),
        ('NCSI', 'ncsi', 'NCSI 服务器设置', '微软/火狐/Debian NCSI 探测服务器切换'),
    ])),
    ('system', ('系统优化', [
        ('RegTweaks', 'reg_tweaks', '注册表优化项', '常规优化选项卡中的各项注册表优化及其移除/还原；各版本实现见 src\\os'),
        ('Plugins', 'plugins', '系统插件补丁', 'Notepad2/HashTab/Everything/CCleaner 等插件的安装与移除'),
        ('Services', 'services', '系统服务与方案', 'Windows 服务优化方案（默认/极速/家用/个人&网吧）、主页设置'),
        ('SSD', 'ssd', 'SSD 优化', 'SSD 节能、预读、休眠、系统还原、NTFS Journal 等开关'),
        ('Security', 'security', '系统安全设置', 'Windows 安全选项一键设置与还原'),
        ('Cache', 'cache', '缓存清理', '释放缓存、清理图标缓存'),
        ('ProcessBL', 'process_bl', '进程黑名单', '禁止运行指定进程的黑名单管理'),
    ])),
    ('shell', ('资源管理器与外壳', [
        ('ExplorerMenu', 'explorer_menu', '资源管理器右键菜单', 'Win11 新旧右键菜单切换、小盾牌、Defender 右键项、重启资源管理器'),
        ('ShellTweaks', 'shell_tweaks', '外壳微调', 'Win+X 菜单、新建文件默认名、注册表跳转'),
        ('Share', 'share', '共享与资源管理器', '一键共享开关、资源管理器目录管理、Win8.1 目录微调'),
        ('DirTransfer', 'dir_transfer', '个人资料转移', '用户资料目录的转移、还原与目标盘选择'),
    ])),
    ('personalize', ('个性化', [
        ('OemInfo', 'oem_info', 'OEM 信息与登录背景', '计算机所有者信息、品牌预设、OEM Logo、登录界面背景、工作组/环境变量'),
        ('Wallpaper', 'wallpaper', 'Bing 壁纸', '下载 Bing 每日壁纸'),
        ('ScreenSaver', 'screen_saver', '屏保扩展包', 'Aerial / Fliqlo 屏保安装与设置'),
    ])),
    ('account', ('账户与权限', [
        ('UserAccount', 'user_account', '用户账户', '用户改名、描述、密码修改、自动登录设置'),
        ('SysRun', 'sys_run', 'SYSTEM 权限运行', '以 SYSTEM 身份运行命令/程序'),
    ])),
    ('license', ('激活与授权', [
        ('Activation', 'activation', '系统激活', 'BIOS/UEFI 激活、KMS、HWIDGen、OEM 证书备份与安装'),
    ])),
    ('tools', ('实用工具', [
        ('TrayTools', 'tray_tools', '托盘小工具', '一键集成/卸载的独立小工具（UPX、KClock、JunctionMaster、虚拟光驱、图标缓存等）'),
        ('FileCreate', 'file_create', '批量创建文件', '创建指定大小的文件'),
        ('DotNet', 'dot_net', '.NET Framework 3.5', '从安装介质安装 .NET 3.5'),
        ('History', 'history', '版本记录与检查更新', '版本更新记录、在线检查新版本'),
        ('Insider', 'insider', 'Windows 预览体验计划', '预览体验计划通道切换与注册表配置'),
        ('MkLink', 'mk_link', '符号链接工具', 'MkLink 图形界面封装'),
        ('ForceDel', 'force_del', '文件强制删除', '无权限文件强制删除工具'),
        ('TPHotkey', 'tp_hotkey', 'ThinkPad 热键', 'ThinkPad 热键定义、X62 Intel 无线指示灯设置'),
    ])),
])

CORE_MODULES = [
    ('Core_Utils', 'utils', '通用工具库', '字符串/数组/路径处理、系统与硬件信息探测、编解码等与业务无关的工具函数'),
    ('Core_WinAPI', 'win_api', 'WinAPI 底层封装', '权限提升、LSA、以 SYSTEM 身份运行、窗口消息过滤、鼠标按键等底层调用'),
    ('Core_Gui', 'gui', 'GUI 辅助库', '窗口/控件创建封装、皮肤与悬停效果、托盘、消息回调、加载动画、全选反选'),
    ('Core_Net', 'net', '网络底层库', 'IPHLPAPI 接口表、网卡信息、WMI 适配器枚举、流量统计'),
    ('Core_Assets', 'assets', '内嵌资源库', '以 base64/LZNT 内嵌并还原 bmp/ico/exe/vbs 等资源（$bSaveBinary 系列）'),
]

# 按系统版本分文件的实现（由 tools/split_os_branches.py 生成）
OS_MODULES = [
    ('common.au3', 'Vista 及以后通用实现'),
    ('xp.au3', 'Windows XP / 2003'),
    ('vista7.au3', 'Vista / Win7 / 2008R2'),
    ('win8.au3', 'Windows 8 / 8.1 / 2012'),
    ('win10.au3', 'Windows 10'),
    ('win11.au3', 'Windows 11'),
    ('server.au3', 'Windows Server'),
]

for _mid, _fn, _title, _desc in CORE_MODULES:
    MODULE_PATHS[_mid] = 'src/core/%s.au3' % _fn
    MODULES[MODULE_PATHS[_mid]] = (_title, _desc)
for _dom, (_dom_title, _items) in FEATURE_DOMAINS.items():
    for _mid, _fn, _title, _desc in _items:
        MODULE_PATHS[_mid] = 'src/features/%s/%s.au3' % (_dom, _fn)
        MODULES[MODULE_PATHS[_mid]] = (_title, _desc)

# ---------------------------------------------------------------- 函数归属表
FUNC_MAP = {}
MODULE_ID = {}


def _assign(module_id, names):
    for n in names:
        if n in FUNC_MAP:
            raise SystemExit('函数重复分配: %s (%s / %s)' % (n, FUNC_MAP[n], module_id))
        FUNC_MAP[n] = module_id


_assign('Core_Utils', [
    'GetUserSID', 'getDriveInfo', '_VMDetect', 'DetecPcType', 'GetOSVersion',
    '_CamelStr', '_RemoveWS', 'RemoveDuplicateStr', '_GetDirNameFromStr',
    '_FileCopy', '_FileMove', 'UnsignedHexToDec', 's2er', 'GetTotalKSize',
    '_XML_GetElementsByTag', '_WinAPI_Base64Decode', '_WinAPI_LZNTDecompress',
    'HasSSD', '_IsProcessorFeaturePresent', '_CPUType', 'IsUEFIBoot',
])

_assign('Core_WinAPI', [
    '_SetPrivilege', '_LsaAddAccountRights', '_LsaOpenPolicy', '_LsaClose',
    '_LookupAccountName', '_IsValidSid', '_LsaNtStatusToWinError', 'NT_SUCCESS',
    '_GetEnvironmentBlock', '_SeImpersonateSystemContext', '_SeCreateSystemProcess',
    'RunAsSYSTEMWindows81', '_ChangeWindowMessageFilterEx',
    '_SwapMouseButton', '_SwithMouseBtn',
])

_assign('Core_Gui', [
    '_removeEffect', 'QuitTool', '_DisableTrayMenu', '_EnableTrayMenu', 'EndSessionProc',
    '_PrepBmp', 'NumLkStatus', 'ToogleNumLk', 'ToogleNumLkHk',
    'SelectAll', 'reverseSelect', 'regall', 'regreverse', 'pluginsall', 'pluginsreverse',
    'svcall', 'svcreverse', 'ssdall', 'ssdreverse', 'W81DirCheckAll', 'W81Dirreverse',
    'SecurityCheckAll', 'SecurityReverse',
    'ExitFunc', 'My_InputProc', '_DrawEditFrame', 'WM_COMMAND', '_DEVICECHANGE',
    '_GUICreate', '_GUICtrlCreateCheckbox', '_GUICtrlCreateRadio',
    '_GDIPlus_GraphicsGetDPIRatio', '_ShowMain', '_WinHide', '_WinHideMain',
    '_Monitor_OFF', '_MoveGUI', '_MinisizeGUI', '_Hover_Func',
    '_GUICtrlIpAddress_Disable', 'quitForm', '_Loader', '_GDIPlus_MutiColorLoader',
    '_ScrollingCredits',
])

_assign('Core_Net', [
    '_WinAPI_GetIfEntry', '_GetNumberofInterfaces', '_WinAPI_GetIfTable',
    '_UpdateStats', '_GetAllTraffic', '_GetNetworkAdapterInfo', '_WMIArrayToString',
    'GetAdaptersList', 'GetAdapterRegKey', '_loadNetInterface',
    '_LoadSpecifecInterfaceInfo', '_updateArryInfo', '_SetCmpIP',
    '_IsWirelessAdapter', '_RasEnumEntries', '_IsConnectedToInternet',
])

_assign('Core_Assets', [
    '_SuperHidden', '_Installer_EFI_cli', '_AcerLicFile', '_xdelexe', '_xdel64exe',
    '_MakeLogo', '_MakeOffBmp', '_MakeOnBmp', '_Background_Image',
    '_IMGAPPbmp', '_x62_Img_app', '_IMG_CLOSE_Hbmp', '_IMG_CLOSE_Nbmp',
    '_IMG_MAX_Hbmp', '_IMG_MAX_Nbmp', '_IMG_MIN_Hbmp', '_IMG_MIN_Nbmp',
    'Wave', '_HDDbmp', '_BIOSbmp', '_SSDbmp', '_UEFIbmp',
    '_Setico', '_Toico', '_Fromico',
])

_assign('RegTweaks', [
    '_ForceUpdate', 'AddRegTweaks', 'StartRegTweak', 'DllInstall', 'DllUnInstall',
    'RemoveRegTweak1', 'RemoveRegTweak2', 'RemoveRegTweak3', 'RemoveRegTweak4',
    'RemoveRegTweak5', 'RemoveRegTweak6', 'RemoveRegTweak7', 'RemoveRegTweak8',
    'RemoveRegTweak9', 'RemoveRegTweak10', 'RemoveRegTweak11', 'RemoveRegTweak12',
    'RemoveRegTweak12_1', 'RemoveRegTweak14', 'RemoveRegTweak15', 'RemoveRegTweak17',
    'RemoveRegTweak18_2', 'RemoveRegTweak18_3', 'RemoveRegTweak19', 'RemoveRegTweak21',
    'RestoreWin11NewStartMenu',
])

_assign('Plugins', [
    'pluginsTweaks', 'RemoveNotePad2', 'RemoveHashTab', 'Removeupdatedisabler',
    'RemoveCamera', 'RemoveEverything', 'RemoveCBX', 'RemoveReg2inf', 'RemoveCC',
    'RemoveUnlocker', 'RemoveSuperHide', 'RemoveVHD', 'RemoveW8Quick',
    '_ClearAllScope', 'RemoveIESearch',
])

_assign('TrayTools', [
    'Convert2bmp', 'UPX', 'RemoveUsb', 'UWD', 'KClock', 'JunctionMaster',
    'VirtualDrive', 'ClipExt', 'ReBuildIconache',
])

_assign('Services', [
    'Win08ServiceTweaks', 'DisableDesktopExp', 'DisableNetPrinterSpt', 'DisableWireless',
    'DisableTelnetCilent', 'DisableNetframe35', 'WinDefault', 'WinHighSpeed', 'WinHome',
    'WinPerson', 'windowsServiceTweaks', '_SetHomePage', '_BackUPServiceToBat',
    '_ConvertServiceStatus', 'IESEC',
])

_assign('SSD', [
    'TurnOffSSD_SE', 'TurnOffPrefetch', 'TurnOffBoottrace', 'TurnOnBoottrace',
    'TurnOffJournal', 'TurnOffcheckdiskOnBoot', 'TurnOncheckdiskOnBoot',
    'removefeedbacktool', 'turnOffsysRestore', 'turnOnsysRestore', 'TurnOffSysHy',
    'TurnOnSysHy', 'TurnOffLastAccess', 'TurnOnLastAccess', 'TurnOffDos83', 'TurnOnDos83',
    'TurnOffWinsearch', 'TurnOnWinsearch', 'NotClearPFileOnOff', 'ClearPFileOnOff',
    'DisGUIBoot', 'EnGUIBoot', 'TurnOffdefrag', 'TurnOndefrag', 'SSDTweaksApply',
])

_assign('OemInfo', [
    'preLoadOemInfo', 'previewOemlogo', 'QuitPreviewDlg', 'Selectoemlogo', 'setpcinfo',
    '_DropHandler', 'LoadPreOEM', '_SetBckDlg', 'QuitSetBkgForm', '_VFile',
    '_SelectBkgPic', '_Preview', '_PicDropEvent', '_RestoreOldSize', '_SetBG',
    '_SetWorkGroupName', '_GetWorkgroupName', '_EnvUpdate', '__NetApi_BufferSize',
    '__NetApi_BufferFree',
])

_assign('DirTransfer', [
    'ToogleListviewCheck', 'QuickSetDrive', 'TransDir', 'RestoreDefaultOpt',
])

_assign('Activation', [
    '_BiosTool', 'BackupInfo', 'InstallOEMCertKey', 'ManualRunBiosTool', '_RunDBSLDR',
    'KMSVLALL', 'PreFiles', '_UEFIActor', 'QuitUEFIForm', '_InstallUEFI',
    '_UnInstallUEFI', 'KMS10', 'ReadOEMKEY',
])

_assign('IpSet', [
    'IpSetDlg', '_ToogleIPControl', '_DIUseSpecifyDNS', 'QuitIpSetTool', '_ManageIPPrjUI',
    '_QuitManageIPUI', '_CleanZeroSizeFile', '_InitIpSetData', '_loadIpsetNameToCombo',
    '_LoadIpSet', '_AddIpSet', '_DelIPSet', '_SaveIPSet', '_SelectIPSet',
    'PrepDNS', 'LoadDNS', 'ChooseLine', 'SetIPS',
])

_assign('MacChange', [
    'MacChangeDlg', 'QuitMacChangeDlg', 'GuiClearMac', 'GuiCheckHex', 'GuiRestoreMac',
    'GuiChangeMac', 'GuiShowMac', 'WriteNewMac', '_PutMacToClip', 'MacTIp', 'toogleStatus',
])

_assign('WifiShare', [
    'CreateWifiDlg', 'QuitWifiDlg', '_ShowPassword', 'CreateWifi', 'ApplyICS', 'sApName',
    '_SetICSbyName', '_NextStep', '_PreStep', 'CleanWifi', 'ReloadWifi',
])

_assign('UserAccount', [
    'ChangeSingleUserPassword', 'ChangeListUserPassword', 'ChangeUserDescDlg',
    'QuitChangeUserDescDlg', 'ChangeUserPasswordDlg', 'QuitChangeUserPasswordDlg',
    '_ShowUserPassword', '_ChangeUserPassword', '_ChangeSelectedUserDesc',
    '_NetUserChangeName', '_SetUserFullName', '_SetUserDesc', '_NetUserSetPassword',
    '_LoadUserNameToArray', '_loadUserNameToEdit',
    'AutoLoginTool', 'QuitFSetAuto', 'SetAutoLogin', '_ShowUserLoginPassword',
    'UseBuildInAuto',
])

_assign('NetTools', [
    'ResetWinsock', '_NetWorkConfigsTool', '_QuitConfigUI', '_MakeNetworkConfigBackup',
    '_RestroreNetworkConfigBackup', 'SynSysTime', '_GetSrv_Date', 'MakePacket',
    '_Rainymood', '_getPlaystatus', 'SetWMPStaus', 'QuitRainymood', 'CreateDigUp',
    '_GetRemoteDeskPort', '_IsFirewallOpen', 'ChangeTerminPort', 'QuitTerminChange',
    'ChangeTermPortNum',
])

_assign('WOL', [
    'WOLUI', 'QuitWOL', 'ToogleWOLTaskType', 'SelectMACFile', 'WOLMain',
    'GenerateMagicPacket', '_WOL',
])

_assign('Share', [
    'OneKeySetShareUI', '_QuitFsetShare', '_OpenShare', '_CloseShare', 'ShareComm',
    'ExplorerDirManager', 'QuitDirForm', 'W81DirTweak',
])

_assign('NCSI', [
    'NCSIServerUI', 'ApplyNCSISetting', 'debianNCSI', 'microsoftNCSI', 'firefoxNCSI',
    'QuitNCSIUI',
])

_assign('Cache', [
    'ReleseCacheUI', 'QuitFormReleaseForm', 'ReleaseCache', '_NofierCacheDone',
])

_assign('DotNet', [
    'InstallNetFrame35UI', 'QuitDotNetForm', '_GetSourceDrivesToCombo',
    'AddCustomSourceDir', '_InstallNF35Frommedia', '_NofierNetComplete',
])

_assign('ExplorerMenu', [
    'Win11RightMenuToogleUI', 'windows11StyleRightMenu', 'windowsOldStyleRightMenu',
    'RestartExplorer', 'QuitWin11RightMenuForm', 'RemoveDP', 'RestoreDP',
    'RemoveWD', 'RestoreWD',
])

_assign('ForceDel', [
    'ForceDelToolUI', 'QuitForceDelTool', 'WM_DropFiles', 'ForceDelFiles',
])

_assign('MkLink', [
    'MkLinkGUI', 'QuitFMklink', 'SetSourceFile', 'SetSourceDir', 'SetTargetFile',
    'SetTargetDir', 'MakeLink',
])

_assign('History', [
    '_History', 'QuitHisForm', 'CheckUpdate',
])

_assign('FileCreate', [
    'MutiCrateFiles', 'QuitMutiCreateTool', '_selectTargetDir', '_CreateMyFile',
    '_StartCreateFile',
])

_assign('TPHotkey', [
    'TPHotKeySet', 'QuitTP', 'TPHokey', '_LoadradioSet', 'TpSetKey', 'TPClearkey',
    'locateExecutor', 'X62intelWlanLed', 'Quit62wlan', 'loadConnNameToCombo',
    'showNCNameInGUI', '_ApplyIntelWlansetting',
])

_assign('ProcessBL', [
    'ProcessBL', 'LoadBlackList', 'QuitFormPBL', 'AddRecord', 'DelRecord', 'LoadToEdit',
    'UpdateRecord', 'SetProcessNameToEdit', 'SelectCurrentProcess', 'LoadProcessNameToEdit',
])

_assign('Security', [
    'SystemSecuritySet', 'QuitSecurityForm', 'ApplySecuritySet',
    'RemoveSecuritySet1', 'RemoveSecuritySet2', 'RemoveSecuritySet3',
    'RemoveSecuritySet4', 'RemoveSecuritySet5', 'RemoveSecuritySet6',
])

_assign('SysRun', [
    'GuiSYSCMD', 'QuitFormSysRun', '_LocateFile', '_RunCommandOrExe',
])

_assign('Insider', [
    'InsiderSwitchUI', '_QuitInsiderUI', 'ApplyInsiderSwitchSetting',
    'toogleNormalInsiderChannel', 'SwitchToDevChannel', 'SwitchToBetaChannel',
    'SwitchToReleasePreviewChannel', 'ResetInsiderConfig', '_EnRoll',
    'checkFlightSigningEnabled', 'SetFlightSigningOn', 'SetFlightSigningOff',
])

_assign('Wallpaper', [
    '_GuiDownloadBingWallPaper', '_QuitWPUI', '_SelectWPSavePath', '_DownloadBingWallPapers',
])

_assign('ScreenSaver', [
    '_Aerial', '_Fliqlo', '_ScreenSaverSet',
])

_assign('ShellTweaks', [
    'FormWinX', '_SetWinX', '_Quitwinx',
    'formdefaultFileName', '_Quitwindfn', '_setsysdafaultFileName', '_SetDefaultFileName',
    '_FormRegJump', 'QuitRegJump', 'JumpToKey',
])

# 标准 UDF / 本地 UDF 的 include（顺序保持与原文件一致）
STD_INCLUDES = [
    "#include 'src\\file\\_GUIDisable.au3'",
    "#include 'src\\file\\GUICtrlOnHover.au3'",
    "#include <Array.au3>",
    "#include <APIConstants.au3>",
    "#include <ButtonConstants.au3>",
    "#include <ComboConstants.au3>",
    "#include <Date.au3>",
    "#include <EditConstants.au3>",
    "#include <GUIConstantsEx.au3>",
    "#include <GuiComboBox.au3>",
    "#include <GuiEdit.au3>",
    "#include <GuiTreeView.au3>",
    "#include <GuiListView.au3>",
    "#include <GuiIPAddress.au3>",
    "#include <GuiTab.au3>",
    "#include <GDIPlus.au3>",
    "#include <InetConstants.au3>",
    "#include <ListViewConstants.au3>",
    "#include <TreeViewConstants.au3>",
    "#include <StaticConstants.au3>",
    "#include <ProgressConstants.au3>",
    "#include <TabConstants.au3>",
    "#include <WindowsConstants.au3>",
    "#include <WinAPIEx.au3>",
    "#include <File.au3>",
    "#include <Constants.au3>",
    "#include <Misc.au3>",
    "#include <WinAPIDiag.au3>",
]

FUNC_RE = re.compile(r'^\s*Func\s+(\w+)')
ENDFUNC_RE = re.compile(r'^\s*EndFunc')


def module_path(module_id):
    try:
        return MODULE_PATHS[module_id]
    except KeyError:
        raise SystemExit('找不到模块路径: %s' % module_id)


def read_source():
    """读取原始单文件脚本。

    入口文件是本脚本的产物，不能作为输入，因此需要显式指定原始单文件脚本：
        python tools/split_modules.py --source <原始单文件脚本>
    未指定时，若 backup 目录下仍保留单文件快照则自动使用。
    """
    src = None
    if '--source' in sys.argv:
        src = sys.argv[sys.argv.index('--source') + 1]
        if not os.path.isabs(src):
            src = os.path.join(ROOT, src)
    elif os.path.exists(BACKUP_SINGLE):
        src = BACKUP_SINGLE
    if not src or not os.path.exists(src):
        raise SystemExit(
            '找不到原始单文件脚本。请用 --source 指定，例如：\n'
            '    git show cbe39cb:"WindowsNT6+快速设置工具.au3" > 原始单文件.au3\n'
            '    python tools/split_modules.py --source 原始单文件.au3')
    print('源文件：%s' % os.path.relpath(src, ROOT))
    with io.open(src, 'rb') as f:
        raw = f.read()
    return raw.decode('utf-8-sig').splitlines(keepends=True)


def collect_functions(lines, first_func_line):
    i = first_func_line - 1
    n = len(lines)
    pending = []
    funcs = []
    in_cs = False
    while i < n:
        raw = lines[i]
        low = raw.strip().lower()
        if low.startswith('#cs') or low.startswith('#comments-start'):
            in_cs = True
            pending.append(raw)
            i += 1
            continue
        if low.startswith('#ce') or low.startswith('#comments-end'):
            in_cs = False
            pending.append(raw)
            i += 1
            continue
        if not in_cs and FUNC_RE.match(raw):
            name = FUNC_RE.match(raw).group(1)
            block = pending
            pending = []
            block.append(raw)
            i += 1
            cs = False
            while i < n:
                r2 = lines[i]
                l2 = r2.strip().lower()
                if l2.startswith('#cs') or l2.startswith('#comments-start'):
                    cs = True
                if l2.startswith('#ce') or l2.startswith('#comments-end'):
                    cs = False
                block.append(r2)
                i += 1
                if not cs and ENDFUNC_RE.match(r2):
                    break
            funcs.append((name, block))
            continue
        pending.append(raw)
        i += 1
    return funcs, pending


def module_header(title, desc, count, path):
    bar = ';' + '=' * 78
    return [
        bar + '\r\n',
        '; 模块：%s\r\n' % title,
        '; 说明：%s\r\n' % desc,
        '; 文件：%s\r\n' % path.replace('/', '\\'),
        '; 函数：共 %d 个\r\n' % count,
        bar + '\r\n',
        '#include-once\r\n',
        '\r\n',
    ]


def build_entry():
    entry = []
    entry.append(';===============================================================================\r\n')
    entry.append('; 项目入口文件：只保留编译指令与 #include 清单，代码按功能模块存放于 src\\ 目录\r\n')
    entry.append('; 目录说明：src\\app 主流程 / src\\core 基础库 / src\\features 功能模块 /\r\n')
    entry.append(';           src\\os 按系统版本的实现 / src\\file 运行时载荷 / src\\img 资源\r\n')
    entry.append(';===============================================================================\r\n')
    entry.append('\r\n')
    entry.append('#Region ;**** 本地 UDF 与 AutoIt 标准库 ****\r\n')
    for inc in STD_INCLUDES:
        entry.append(inc + '\r\n')
    entry.append('#EndRegion ;**** 本地 UDF 与 AutoIt 标准库 ****\r\n')
    entry.append('\r\n')
    entry.append('#Region ;**** 通用基础库 src\\core ****\r\n')
    for path in MODULES:
        if path.startswith('src/core/'):
            entry.append("#include '%s'\r\n" % path.replace('/', '\\'))
    entry.append('#EndRegion ;**** 通用基础库 ****\r\n')
    entry.append('\r\n')
    entry.append('#Region ;**** 功能模块 src\\features（按功能域分组） ****\r\n')
    for dom, (dom_title, items) in FEATURE_DOMAINS.items():
        entry.append('; ---- %s ----\r\n' % dom_title)
        for _mid, _fn, _title, _desc in items:
            entry.append("#include 'src\\features\\%s\\%s.au3'\r\n" % (dom, _fn))
    entry.append('#EndRegion ;**** 功能模块 ****\r\n')
    entry.append('\r\n')
    entry.append('#Region ;**** 按系统版本的实现 src\\os ****\r\n')
    for fn, title in OS_MODULES:
        entry.append('; %s\r\n' % title)
        entry.append("#include 'src\\os\\%s'\r\n" % fn)
    entry.append('#EndRegion ;**** 按系统版本的实现 ****\r\n')
    entry.append('\r\n')
    entry.append('#Region ;**** 主流程（顺序敏感，勿调整） ****\r\n')
    for path, s, e, t, d in APP_PARTS:
        entry.append("#include '%s'\r\n" % path.replace('/', '\\'))
    entry.append('#EndRegion ;**** 主流程 ****\r\n')
    return entry


def main():
    check_only = '--check' in sys.argv
    src_lines = read_source()

    first_func_line = APP_PARTS[-1][2] + 1
    funcs, tail = collect_functions(src_lines, first_func_line)

    missing = [name for name, _ in funcs if name not in FUNC_MAP]
    if missing:
        raise SystemExit('以下函数未分配模块：\n  ' + '\n  '.join(missing))
    unknown = [k for k in FUNC_MAP if k not in dict(funcs)]
    if unknown:
        raise SystemExit('归属表中有不存在的函数：\n  ' + '\n  '.join(unknown))

    mod_blocks = OrderedDict((m, []) for m in MODULES)
    for name, block in funcs:
        mod_blocks[module_path(FUNC_MAP[name])].extend(block)
    if tail:
        mod_blocks[list(MODULES)[-1]].extend(tail)

    # 内容守恒校验
    accounted = []
    for path, s, e, t, d in APP_PARTS:
        accounted.extend(src_lines[s - 1:e])
    for m, blk in mod_blocks.items():
        accounted.extend(blk)
    body_ref = src_lines[47:]
    if sorted(x.rstrip('\r\n') for x in accounted) != sorted(x.rstrip('\r\n') for x in body_ref):
        from collections import Counter
        c1 = Counter(x.rstrip('\r\n') for x in accounted)
        c2 = Counter(x.rstrip('\r\n') for x in body_ref)
        raise SystemExit('内容不一致!\n拆分后多出:\n%s\n原文件多出:\n%s'
                         % (list((c1 - c2).elements())[:10], list((c2 - c1).elements())[:10]))

    print('函数总数: %d' % len(funcs))
    print('模块数: %d (+ %d 个主流程文件)' % (len(MODULES), len(APP_PARTS)))
    if check_only:
        print('校验通过（--check 模式，未写文件）')
        return

    def write_out(rel, lines_out):
        full = os.path.join(ROOT, rel.replace('/', os.sep))
        d = os.path.dirname(full)
        if not os.path.isdir(d):
            os.makedirs(d)
        with io.open(full, 'wb') as f:
            f.write('\ufeff'.encode('utf-8'))
            f.write(''.join(lines_out).encode('utf-8'))

    for path, (title, desc) in MODULES.items():
        blk = mod_blocks[path]
        count = sum(1 for x in blk if FUNC_RE.match(x))
        write_out(path, module_header(title, desc, count, path) + blk)

    for path, s, e, title, desc in APP_PARTS:
        head = module_header(title, desc, 0, path)
        head.append('; 本文件为顶层可执行代码，由入口文件按顺序 #include，请勿调整 include 次序。\r\n')
        head.append('\r\n')
        write_out(path, head + src_lines[s - 1:e])

    entry = list(src_lines[:19])
    entry.extend(build_entry())
    write_out('WindowsNT6+快速设置工具.au3', entry)

    print('拆分完成。')


if __name__ == '__main__':
    main()
