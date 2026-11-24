import re, difflib
from skoolkit.opcodes import decode
H=bytearray(65536); H[24576:24576+37888]=open('/tmp/hob/hobbit.bin','rb').read()
M=bytearray(65536); M[24576:]=open('/home/claude/mugsy/work/mem.bin','rb').read()[8192:8192+40960]
def listing(mem,lo,hi):
    out=[];pc=lo
    while pc<hi:
        d=next(decode(mem,pc,pc+1)); t=d[4]; n=d[1]; raw=bytes(mem[pc:pc+n])
        if not t.startswith(('JR','DJNZ')) and 'nn' not in t:
            if re.search(r'\bn\b',t): t=t+' #%d'%raw[-1]
        if re.search(r'\bd\b',t): t=t+' d%d'%raw[2 if raw[0] in (0xDD,0xFD) else 1]
        out.append((pc,t,raw)); pc+=n
    return out
def norm(t):
    return t
PAIRS=[('draw engine',(0x8985,0x8A4D),(31247,31484)),
 ('flood fill',(0x8A4F,0x8ACC),(31525,31755)),
 ('attr move up/down/left/right',(0x8AD3,0x8B09),(31755,31823)),
 ('pixel step helpers',(0x8B09,0x8B2F),(31823,31917)),
 ('line drawer',(0x8B2F,0x8B93),(31917,32034)),
 ('plot pixel',(0x8B93,0x8BBC),(32034,32066)),
 ('coord to address',(0x8BBC,0x8BE9),(32066,32126))]
if __name__=='__main__':
    for name,(h0,h1),(m0,m1) in PAIRS:
        a=listing(H,h0,h1); b=listing(M,m0,m1)
        sa=[norm(x[1]) for x in a]; sb=[norm(x[1]) for x in b]
        sm=difflib.SequenceMatcher(None,sa,sb,autojunk=False)
        same=sum(bl.size for bl in sm.get_matching_blocks())
        print('%-30s hobbit %3d instrs, mugsy %3d instrs, matching %3d (%.0f%% of hobbit, %.0f%% of mugsy), ratio %.2f'%(name,len(a),len(b),same,100*same/len(a),100*same/len(b),sm.ratio()))
