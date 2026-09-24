;==============================================================================
; 模块：Bing 壁纸
; 说明：下载 Bing 每日壁纸
; 文件：src\features\personalize\Feat_Wallpaper.au3
; 函数：共 4 个
;==============================================================================
#include-once

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
