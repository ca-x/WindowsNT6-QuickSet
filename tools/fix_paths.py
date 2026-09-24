# -*- coding: utf-8 -*-
"""
目录规范化后的路径修正：
  file\\  ->  src\\file\\
  img\\   ->  src\\img\\   （原 img 目录，代码中无引用）
  ToolIco.ico -> src\\img\\ToolIco.ico

FileInstall 的相对路径以「主脚本所在目录」为基准（已实测），因此全部需要同步改写。
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENTRY = os.path.join(ROOT, 'WindowsNT6+快速设置工具.au3')

REPLACEMENTS = [
    # FileInstall 源路径：.\file\xxx  ->  .\src\file\xxx
    ("FileInstall('.\\file\\", "FileInstall('.\\src\\file\\"),
    ("FileInstall('file\\", "FileInstall('src\\file\\"),
    # 本地 UDF 的 #include
    ("#include 'file\\", "#include 'src\\file\\"),
    # 编译图标（AccAu3Wrapper 指令 + 未编译运行时的图标）
    ("#PRE_Icon=ToolIco.ico", "#PRE_Icon=src\\img\\ToolIco.ico"),
    ("GUICtrlCreateIcon('ToolIco.ico'", "GUICtrlCreateIcon(@ScriptDir & '\\src\\img\\ToolIco.ico'"),
]

TARGETS = [ENTRY]
for dirpath, _dirnames, filenames in os.walk(os.path.join(ROOT, 'src')):
    for fn in filenames:
        if fn.lower().endswith('.au3'):
            TARGETS.append(os.path.join(dirpath, fn))

FI_RE = re.compile(r"FileInstall\('([^']+)'")


def main():
    changed = {}
    for path in TARGETS:
        with io.open(path, 'rb') as f:
            raw = f.read()
        text = raw.decode('utf-8-sig')
        new = text
        for old, rep in REPLACEMENTS:
            if old in new:
                n = new.count(old)
                new = new.replace(old, rep)
                changed[path] = changed.get(path, 0) + n
        if new != text:
            with io.open(path, 'wb') as f:
                f.write('\ufeff'.encode('utf-8'))
                f.write(new.encode('utf-8'))

    for p, n in sorted(changed.items()):
        print('%-58s %d 处' % (os.path.relpath(p, ROOT), n))

    # ---- 校验：所有 FileInstall 源文件必须真实存在
    bad = []
    total = 0
    for path in TARGETS:
        text = io.open(path, encoding='utf-8-sig').read()
        for m in FI_RE.finditer(text):
            src = m.group(1)
            total += 1
            if not os.path.exists(os.path.join(ROOT, src.lstrip('.\\').replace('\\', os.sep))):
                bad.append('%s -> %s' % (os.path.relpath(path, ROOT), src))
    print('\nFileInstall 源路径共 %d 条，缺失 %d 条' % (total, len(bad)))
    for b in bad:
        print('  !', b)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
