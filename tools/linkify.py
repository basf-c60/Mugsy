"""Turn bare addresses in prose into #R links.

An address is linked only if it is the address of a line in the skool file,
and only where it reads as a reference: not inside an HTML tag, <code>...</code> or #HTML[...],
not already after #R, not part of arithmetic (+, *, x, =) or of a BASIC
command (USR, CODE), and not inside double quotes.
"""
import re

ADDR = re.compile(r'(?<![\w#&;./=+*-])(?<!#R)(\d{5})(?![\d+*]|,\d|\s*[x*+=]\s*\d)')
SKIP_BEFORE = re.compile(r'(USR|CODE|x|\*|\+|=)\s*$')


def line_addresses(skool_text):
    return {int(m.group(1)) for m in re.finditer(r'(?m)^[bcgistuw* @]?(\d{5}) ', skool_text)}


def _protected(text):
    """Spans that must not be touched: HTML tags, #HTML[...] bodies and quoted strings."""
    spans = []
    for m in re.finditer(r'<code>.*?</code>', text):
        spans.append(m.span())
    for m in re.finditer(r'<[^>]*>', text):
        spans.append(m.span())
    for m in re.finditer(r'#HTML\[', text):
        depth, i = 1, m.end()
        while i < len(text) and depth:
            depth += {'[': 1, ']': -1}.get(text[i], 0)
            i += 1
        spans.append((m.start(), i))
    for m in re.finditer(r'"[^"\n]*"|&quot;.*?&quot;', text):
        spans.append(m.span())
    return spans


def linkify(text, addrs, count=None):
    spans = _protected(text)

    def rep(m):
        a = int(m.group(1))
        if a not in addrs:
            return m.group(0)
        if any(s <= m.start() < e for s, e in spans):
            return m.group(0)
        if SKIP_BEFORE.search(text[max(0, m.start() - 6):m.start()]):
            return m.group(0)
        if count is not None:
            count[0] += 1
        return '#R' + m.group(1)

    return ADDR.sub(rep, text)
