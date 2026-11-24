#!/bin/sh
# Rebuild everything from the tools and package it. Run from /home/claude/mugsy.
set -e
(cd tools && python3 build.py && python3 vmscript.py)
cp images/*.png . 2>/dev/null || true
rm -rf html && skool2html.py -d html mugsy.skool > /tmp/html.log 2>&1
grep -c "ERROR" /tmp/html.log || true
skool2asm.py -q mugsy.skool > mugsy.asm 2>/dev/null
skool2ctl.py mugsy.skool > mugsy.ctl
skool2bin.py mugsy.skool /tmp/mugsy_rebuilt.bin >/dev/null 2>&1
python3 - <<'PY'
a=open('/tmp/mugsy_rebuilt.bin','rb').read()
m=open('work/mem.bin','rb').read()[8192:8192+40960]
print('byte-identical rebuild:', a==m)
PY
D=dist/mugsy-disassembly
rm -rf $D
mkdir -p $D/tools $D/images $D/screenshots $D/analysis
cp mugsy.skool mugsy.asm mugsy.ctl mugsy.ref vm-script.txt $D/
cp screenshots/* $D/screenshots/
cp analysis/* $D/analysis/
cp -r html $D/html
cp tools/*.py tools/package.sh $D/tools/
cp images/* $D/images/
cp -r theme $D/
cp tools/README.txt $D/README.txt
rm -f dist/mugsy-disassembly.zip
(cd dist && zip -qr mugsy-disassembly.zip mugsy-disassembly)
ls -la dist/mugsy-disassembly.zip
# optional: check the assembly listing with an external assembler if one is installed
if command -v sjasmplus >/dev/null 2>&1; then
  python3 -I -c "open('/tmp/ref.bin','wb').write(open('/home/claude/mugsy/work/mem.bin','rb').read()[8192:8192+40960])"
  rm -rf /tmp/asmchk && mkdir /tmp/asmchk && cp mugsy.asm /tmp/asmchk/
  ( cd /tmp/asmchk && sjasmplus --raw=out.bin --nologo mugsy.asm >/dev/null 2>&1 )
  cmp /tmp/asmchk/out.bin /tmp/ref.bin && echo "sjasmplus rebuild: identical"
fi
