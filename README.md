# WindowsNT6-QuickSet
 WindowsNT6+快速设置工具
 界面功能截图
![image](https://user-images.githubusercontent.com/19337206/138220647-c738c59b-6410-48a1-b0f5-58c8ebfb520f.png)
托盘菜单
![image](https://user-images.githubusercontent.com/19337206/138220699-eb5d2048-c018-4d89-904b-6204609fa18d.png)

![image](https://user-images.githubusercontent.com/19337206/138220794-6551dd26-f748-4149-9ee1-13cb923e2955.png)

## 源码结构

原单文件脚本（1.2 万行）已按功能模块拆分，按系统版本分文件的实现也单独成目录：

```
WindowsNT6+快速设置工具.au3   入口/项目文件（编译目标，AccAu3Wrapper 指令保持原样）
src\app\                      主流程（初始化 / 主窗口 / 消息循环，include 顺序敏感）
src\core\                     通用基础库（utils / win_api / gui / net / assets）
src\features\<功能域>\        功能模块，按功能域分目录
                              net / system / shell / personalize / account / license / tools
src\os\                       按系统版本的优化实现（common / xp / vista7 / win8 / win10 / win11 / server）
src\file\                     运行时载荷（FileInstall 源）与本地 UDF
src\img\                      图片与图标资源
```

目录名与模块文件名一律小写，文件名不重复所在目录的名字（如 `src\core\utils.au3`）。
模块职责、按系统版本分文件的对应关系、编译方法与维护注意事项见 [docs/模块结构.md](docs/模块结构.md)。

### 编译

用 AccAu3Wrapper_GUI 打开根目录的 `WindowsNT6+快速设置工具.au3` 直接编译即可（支持一键编译 x86/x64）；
也可用 Aut2Exe：

```bat
Aut2exe.exe /in "WindowsNT6+快速设置工具.au3" /out "WindowsNT6+快速设置工具.exe" /x86
Aut2exe.exe /in "WindowsNT6+快速设置工具.au3" /out "WindowsNT6+快速设置工具_x64.exe" /x64
```
