# -*- coding: utf-8 -*-
"""
按操作系统版本拆分优化实现。

把 Feat_RegTweaks.au3 / Feat_Plugins.au3 中按 @OSBuild / @OSVersion 分叉的代码块
整体搬移到 src\\os\\Os_*.au3，调用处只保留原来的判断条件 + 一次函数调用，
做到「版本判断留在主流程、版本实现按系统分文件」。

支持 If / ElseIf / Else 链：ElseIf 会被改写成嵌套 If/Else，语义完全等价。
搬移逐行原样进行，写盘前做内容守恒校验（结构行之外的每一行都必须原样保留）。

用法：
    python tools/split_os_branches.py            # 预演，只打印报告
    python tools/split_os_branches.py --apply    # 实际写入
"""
import io
import os
import re
import sys
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TARGETS = [
    ('src/features/system/Feat_RegTweaks.au3', 'AddRegTweaks'),
    ('src/features/system/Feat_Plugins.au3', 'pluginsTweaks'),
]

# 整函数搬移：(源文件, 函数名, 目标版本标签)
MOVE_FUNCS = [
    ('src/features/system/Feat_Services.au3', 'Win08ServiceTweaks', 'Server'),
]

# 各系统版本文件：(文件名, 标题, 说明)
OS_FILES = {
    'Xp': ('src/os/Os_Xp.au3', 'Windows XP / 2003',
           '适用于 @OSBuild < 6000 或 @OSVersion = WIN_XP / WIN_2003 的分支实现'),
    'Common': ('src/os/Os_Common.au3', 'Vista 及以后通用实现',
               '适用于 @OSBuild > 6000 的通用分支，以及无法再细分的兜底分支'),
    'Vista7': ('src/os/Os_Vista7.au3', 'Vista / Win7 / 2008R2',
               '适用于 6000 < @OSBuild <= 8000 的分支实现'),
    'Win8': ('src/os/Os_Win8.au3', 'Windows 8 / 8.1 / 2012',
             '适用于 8000 < @OSBuild <= 10240，或 @OSVersion = WIN_8 / WIN_81 的分支实现'),
    'Win10': ('src/os/Os_Win10.au3', 'Windows 10',
              '适用于 @OSBuild > 9000，或 @OSVersion = WIN_10 的分支实现'),
    'Win11': ('src/os/Os_Win11.au3', 'Windows 11',
              '适用于 @OSBuild > 19040 / 21900 / 21990 的分支实现'),
    'Server': ('src/os/Os_Server.au3', 'Windows Server',
               '适用于 @OSVersion = WIN_2003 / WIN_2008 / WIN_2008R2 的服务器版实现'),
}

# (条件匹配, 分支) -> 版本标签；按顺序匹配，先命中先得
RULES = [
    # 复合条件（ElseIf @OSBuild < 8000 And @OSBuild > 6000）——不满足即为 XP/2003
    (r'@OSBuild\s*<\s*8000\s+And\s+@OSBuild\s*>\s*6000', 'then', 'Vista7'),
    (r'@OSBuild\s*<\s*8000\s+And\s+@OSBuild\s*>\s*6000', 'else', 'Xp'),
    (r'@OSBuild\s*<\s*6000', 'then', 'Xp'),
    (r'@OSBuild\s*<\s*6000', 'else', 'Common'),
    (r'@OSBuild\s*<\s*8000', 'then', 'Vista7'),
    (r'@OSBuild\s*<\s*8000', 'else', 'Win8'),
    (r'@OSBuild\s*<\s*10240', 'then', 'Win8'),
    (r'@OSBuild\s*<\s*10240', 'else', 'Win10'),
    (r'@OSBuild\s*>\s*21990', 'then', 'Win11'),
    (r'@OSBuild\s*>\s*21990', 'else', 'Common'),
    (r'@OSBuild\s*>\s*21900', 'then', 'Win11'),
    (r'@OSBuild\s*>\s*21900', 'else', 'Common'),
    (r'@OSBuild\s*>\s*19040', 'then', 'Win11'),
    (r'@OSBuild\s*>\s*19040', 'else', 'Win10'),
    (r'@OSBuild\s*>\s*9000', 'then', 'Win10'),
    (r'@OSBuild\s*>\s*9000', 'else', 'Win8'),
    (r'@OSBuild\s*>\s*8000', 'then', 'Win8'),
    (r'@OSBuild\s*>\s*8000', 'else', 'Vista7'),
    (r'@OSBuild\s*>\s*6000', 'then', 'Common'),
    (r'@OSBuild\s*>\s*6000', 'else', 'Xp'),
    (r'@OSVersion\s*=\s*.WIN_XP', 'then', 'Xp'),
    (r'@OSVersion\s*=\s*.WIN_XP', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_81', 'then', 'Win8'),
    (r'@OSVersion\s*=\s*.WIN_81', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_8.', 'then', 'Win8'),
    (r'@OSVersion\s*=\s*.WIN_8.', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_10', 'then', 'Win10'),
    (r'@OSVersion\s*=\s*.WIN_10', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_2008R2', 'then', 'Server'),
    (r'@OSVersion\s*=\s*.WIN_2008R2', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_2008.', 'then', 'Server'),
    (r'@OSVersion\s*=\s*.WIN_2008.', 'else', 'Common'),
    (r'@OSVersion\s*=\s*.WIN_2003', 'then', 'Server'),
    (r'@OSVersion\s*=\s*.WIN_2003', 'else', 'Common'),
]

OSCOND_RE = re.compile(r'^\s*If\s+.*(@OSBuild|@OSVersion)')
INLINE_IF_RE = re.compile(r'Then\s+\S')
IF_RE = re.compile(r'^\s*If\b')
ELSEIF_RE = re.compile(r'^\s*ElseIf\b')
ELSE_RE = re.compile(r'^\s*Else\b')
ENDIF_RE = re.compile(r'^\s*EndIf\b')
CALL_RE = re.compile(r'^_Os\w+\(\s*\)$')


def tag_for(cond, branch):
    for pat, br, tag in RULES:
        if br == branch and re.search(pat, cond):
            return tag
    return None


def norm(seq):
    return Counter(x.strip() for x in seq if x.strip())


class Extractor(object):
    def __init__(self, func_name):
        self.func = func_name
        self.counter = 0
        self.gen = dict((k, []) for k in OS_FILES)
        self.notes = []
        self.warn = []
        self.skipped_inline = 0
        self.moved_lines = []       # 搬进版本文件的原始行
        self.consumed_lines = []    # 被替换掉的结构行（If/ElseIf/Else/EndIf）
        self.generated_lines = []   # 新生成的调度行

    def new_name(self, tag):
        self.counter += 1
        return '_Os%s_%s_%02d' % (tag, self.func, self.counter)

    @staticmethod
    def block_bounds(lines, start, limit):
        """返回 (EndIf 行号, [(分支标记行号, ElseIf 条件或 None), ...])。"""
        depth = 0
        j = start
        markers = []
        while j <= limit:
            st = lines[j].strip()
            if IF_RE.match(st) and not INLINE_IF_RE.search(st):
                depth += 1
            elif ENDIF_RE.match(st):
                depth -= 1
                if depth == 0:
                    return j, markers
            elif depth == 1:
                if ELSEIF_RE.match(st):
                    m = re.match(r'^ElseIf\s+(.*?)\s*Then$', st)
                    if not m:
                        raise SystemExit('不支持的 ElseIf 写法（行 %d）：%s' % (j + 1, st))
                    markers.append((j, m.group(1)))
                elif ELSE_RE.match(st):
                    markers.append((j, None))
            j += 1
        raise SystemExit('未能找到匹配的 EndIf: 行 %d' % (start + 1))

    def branch_out(self, tab, cond, kind, item, body):
        """处理一个分支：递归下沉子版本判断，然后把正文搬到版本文件并生成调用。"""
        if not body:
            return []
        processed = self.process(body, 0, len(body) - 1)
        if not any(x.strip() for x in processed):
            return []
        tag = tag_for(cond, kind)
        if tag is None:
            self.warn.append('未匹配到版本标签(%s): %s' % (kind, cond))
            return processed
        name = self.new_name(tag)
        self.emit(tag, name, cond, kind, item, processed)
        return ['%s\t%s()\r\n' % (tab, name)]

    def emit_chain(self, tab, markers, segs, parent_cond, item):
        """把 ElseIf 链改写成嵌套 If/Else，语义不变。"""
        mcond = markers[0][1]
        body = segs[1]
        rest_markers = markers[1:]
        rest_segs = segs[1:]
        if mcond is None:
            # 承接上一层已经生成的 Else，正文比 If/Else 关键字再缩进一层
            outer = tab[:-1] if tab.endswith('\t') else tab
            return self.branch_out(outer, parent_cond, 'else', item, body)
        out = ['%sIf %s Then\r\n' % (tab, mcond)]
        out.extend(self.branch_out(tab, mcond, 'then', item, body))
        if rest_markers:
            out.append('%sElse\r\n' % tab)
            out.extend(self.emit_chain(tab + '\t', rest_markers, rest_segs, mcond, item))
        out.append('%sEndIf\r\n' % tab)
        return out

    def process(self, lines, start, end):
        out = []
        i = start
        while i <= end:
            raw = lines[i]
            if OSCOND_RE.match(raw) and not INLINE_IF_RE.search(raw):
                cond = raw.strip()[3:-4].strip()
                endif_at, markers = self.block_bounds(lines, i, end)
                segs = []
                prev = i + 1
                for pos, _mc in markers:
                    segs.append(lines[prev:pos])
                    prev = pos + 1
                segs.append(lines[prev:endif_at])

                item = self.item_of(lines, i)
                tab = re.match(r'^[\t ]*', raw).group(0)
                block_out = ['%sIf %s Then\r\n' % (tab, cond)]
                block_out.extend(self.branch_out(tab, cond, 'then', item, segs[0]))
                if markers:
                    block_out.append('%sElse\r\n' % tab)
                    block_out.extend(self.emit_chain(tab + '\t', markers, segs, cond, item))
                block_out.append('%sEndIf\r\n' % tab)

                self.consumed_lines.append(raw)
                for pos, _mc in markers:
                    self.consumed_lines.append(lines[pos])
                self.consumed_lines.append(lines[endif_at])
                self.generated_lines.extend(block_out)

                out.extend(block_out)
                i = endif_at + 1
                continue
            if OSCOND_RE.match(raw):
                self.skipped_inline += 1
            out.append(raw)
            i += 1
        return out

    def emit(self, tag, name, cond, branch, item, body):
        expr = ('%s（不满足时走另一分支）' % cond) if branch == 'else' else cond
        head = ['\r\n',
                ';-------------------------------------------------------------------------------\r\n',
                '; %s\r\n' % name,
                '; 适用条件：%s\r\n' % expr,
                '; 来源：%s%s\r\n' % (self.func, (' / ' + item) if item else ''),
                ';-------------------------------------------------------------------------------\r\n',
                'Func %s()\r\n' % name]
        body = self.reindent(body)
        self.gen[tag].extend(head)
        self.gen[tag].extend(body)
        self.gen[tag].append('EndFunc   ;==>%s\r\n' % name)
        self.moved_lines.extend(body)
        self.notes.append('  %-10s %-34s <- %s %s' % (tag, name, cond, item))

    @staticmethod
    def item_of(lines, idx):
        for k in range(idx - 1, max(-1, idx - 10), -1):
            t = lines[k].strip()
            if re.match(r'^;\s*\d', t):
                return t.lstrip(';').strip()
            if t and not t.startswith(';') and not re.match(r'^(If|Else|ElseIf|EndIf)\b', t):
                break
        return ''

    @staticmethod
    def reindent(body):
        """把搬走的代码统一缩进到一层 Tab，保持相对层级。"""
        lead = [len(re.match(r'^[\t ]*', x).group(0)) for x in body if x.strip()]
        if not lead:
            return body
        m = min(lead)
        out = []
        for x in body:
            if not x.strip():
                out.append(x)
                continue
            out.append('\t' + x[m:])
        return out


def write_os_file(path, title, desc, chunks):
    out = os.path.join(ROOT, path.replace('/', os.sep))
    d = os.path.dirname(out)
    if not os.path.isdir(d):
        os.makedirs(d)
    existed = os.path.exists(out)
    mode = 'ab' if existed else 'wb'
    with io.open(out, mode) as f:
        if not existed:
            bar = ';' + '=' * 78 + '\r\n'
            f.write('\ufeff'.encode('utf-8'))
            f.write(bar.encode('utf-8'))
            f.write(('; 模块：%s\r\n' % title).encode('utf-8'))
            f.write(('; 说明：%s\r\n' % desc).encode('utf-8'))
            f.write(('; 文件：%s\r\n' % path.replace('/', '\\')).encode('utf-8'))
            f.write(bar.encode('utf-8'))
            f.write(b'#include-once\r\n')
        f.write(''.join(chunks).encode('utf-8'))


def read_lines(path):
    """二进制读取，避免通用换行把 CRLF 变成 LF。"""
    with io.open(path, 'rb') as f:
        return f.read().decode('utf-8-sig').splitlines(keepends=True)


def process_file(rel, func, apply_changes):
    full = os.path.join(ROOT, rel.replace('/', os.sep))
    lines = read_lines(full)

    fstart = next(i for i, l in enumerate(lines) if re.match(r'^Func\s+' + func + r'\b', l))
    fend = next(i for i in range(fstart, len(lines)) if re.match(r'^EndFunc', lines[i]))

    ex = Extractor(func)
    orig_body = lines[fstart + 1:fend]
    body = ex.process(lines, fstart + 1, fend - 1)
    new_lines = lines[:fstart + 1] + body + lines[fend:]

    print('=' * 78)
    print('%s : %s()' % (rel, func))
    print('  提取 %d 个版本分支函数，跳过单行 If %d 处' % (len(ex.notes), ex.skipped_inline))
    for n in ex.notes:
        print(n)
    for w in ex.warn:
        print('  !! %s' % w)
    for l in ex.moved_lines:
        if re.search(r'\b(Return|ExitLoop|ContinueLoop|Exit|GUIDelete|_GUIDisable)\b', l):
            print('  ?? 搬移内容含控制流/界面语句: %s' % l.strip()[:100])

    left = norm(orig_body) - norm(ex.consumed_lines)
    right = norm(body) + norm(ex.moved_lines) - norm(ex.generated_lines)
    missing = left - right
    extra = right - left
    if missing or extra:
        print('  !! 内容守恒校验失败')
        for k, v in list(missing.items())[:10]:
            print('     原始有、拆分后丢失 x%d: %s' % (v, k[:100]))
        for k, v in list(extra.items())[:10]:
            print('     拆分后多出 x%d: %s' % (v, k[:100]))
        if apply_changes:
            raise SystemExit('校验失败，已中止写入')
    else:
        print('  内容守恒校验通过（结构行之外无丢行、无改行）')

    if apply_changes:
        with io.open(full, 'wb') as f:
            f.write('\ufeff'.encode('utf-8'))
            f.write(''.join(new_lines).encode('utf-8'))
        for tag, (path, title, desc) in OS_FILES.items():
            if ex.gen[tag]:
                write_os_file(path, title, desc, ex.gen[tag])
    return ex


def move_whole_function(rel, func, tag, apply_changes):
    """把整个函数（含其前的注释块）原样搬到版本文件。"""
    full = os.path.join(ROOT, rel.replace('/', os.sep))
    lines = read_lines(full)
    fstart = next(i for i, l in enumerate(lines) if re.match(r'^Func\s+' + func + r'\b', l))
    fend = next(i for i in range(fstart, len(lines)) if re.match(r'^EndFunc', lines[i]))
    s = fstart
    while s > 0 and lines[s - 1].strip().startswith(';'):
        s -= 1
    block = lines[s:fend + 1]
    path, title, desc = OS_FILES[tag]
    print('=' * 78)
    print('%s : %s()  整函数搬到 %s（%d 行）' % (rel, func, path, len(block)))
    if apply_changes:
        with io.open(full, 'wb') as f:
            f.write('\ufeff'.encode('utf-8'))
            f.write(''.join(lines[:s] + lines[fend + 1:]).encode('utf-8'))
        head = ['\r\n',
                ';-------------------------------------------------------------------------------\r\n',
                '; %s  （整函数搬移，来源：%s）\r\n' % (func, rel),
                ';-------------------------------------------------------------------------------\r\n']
        write_os_file(path, title, desc, head + block)
    return len(block)


def main():
    apply_changes = '--apply' in sys.argv
    total = 0
    for rel, func in TARGETS:
        ex = process_file(rel, func, apply_changes)
        total += len(ex.notes)
    moved = 0
    for rel, func, tag in MOVE_FUNCS:
        moved += move_whole_function(rel, func, tag, apply_changes)
    print('=' * 78)
    print('合计提取 %d 个版本分支函数，整函数搬移 %d 行；模式：%s'
          % (total, moved, 'APPLY' if apply_changes else 'DRY-RUN'))


if __name__ == '__main__':
    main()
