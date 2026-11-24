"""Write vm-script.txt: the game's bytecode scripts as decoded in mugsy.skool, one instruction per line."""
import os, re
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
out = ['Mugsy - the VM scripts, decoded (generated from mugsy.skool by tools/vmscript.py)',
       'Variables are shown by name (see the Variables page); * marks a jump target; message text is shown after SAY.', '']
last = None
for l in open(os.path.join(ROOT, 'mugsy.skool')):
    m = re.match(r'^([bcgistuw* ])(\d{5}) .*? ; VM: (.*)$', l.rstrip('\n'))
    if not m:
        continue
    a = int(m.group(2))
    if last is not None and m.group(1) in 'bcgistuw':
        out.append('')
    ins = re.sub(r'#R(\d{5})', r'\1', m.group(3))
    out.append('%s%d %s' % ('*' if m.group(1) == '*' else ' ', a, ins))
    last = a
open(os.path.join(ROOT, 'vm-script.txt'), 'w').write('\n'.join(out) + '\n')
print('vm-script.txt:', sum(1 for x in out if x[:1] in ' *' and x.strip()), 'instructions')
