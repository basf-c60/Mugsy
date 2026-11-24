import sys,os
sys.path.insert(0,'/home/claude/mugsy/tools')
from skoolkit import CSimulator
from skoolkit.simutils import PC, ROM48
from sim import Tracer, screen_png
RET=23700
HB=open('/tmp/hob/hobbit.bin','rb').read()      # at 24576
MB=open('/home/claude/mugsy/work/mem.bin','rb').read()  # at 16384
ROM=open(ROM48,'rb').read()
def hmem():
    m=bytearray(65536); m[:16384]=ROM; m[24576:24576+len(HB)]=HB
    m[0x954D:0x954F]=bytes([0xA7,0xC9])   # patch "is Bilbo in the dark?" -> not dark
    return m
def mmem():
    m=bytearray(65536); m[:16384]=ROM; m[16384:]=MB; return m
def run(mem,entry,regs_extra,maxframes=600):
    mem[RET:RET+2]=bytes([0x18,0xFE]); sp=23552
    mem[sp-2]=RET&255; mem[sp-1]=RET>>8
    mem[16384:16384+6144]=bytes(6144); mem[22528:22528+768]=bytes([56])*768
    regs={'PC':entry,'SP':sp-2,'IY':23610,'A':0,'F':0}; regs.update(regs_extra)
    sim=CSimulator(mem,regs,{'im':1,'iff':0,'tstates':0}); tr=Tracer(); sim.set_tracer(tr)
    n=[0]
    def draw(scr,frame,border,kb):
        n[0]=frame; return frame<maxframes and sim.registers[PC]!=RET
    sim.trace(entry,RET,0,0,1,draw,set(),tr.keyboard,None,None)
    done = sim.registers[PC]==RET
    return bytes(sim.memory[16384:16384+6912]),done,n[0]
def rows(scr):  # 192 rows of 32 bytes
    return [bytes(scr[((y&0xC0)<<5)+((y&7)<<8)+(((y>>3)&7)<<5):][:32]) for y in range(192)]
def bits_diff(a,b,ya,yb,h):
    ra,rb=rows(a),rows(b); d=0;tot=0
    for k in range(h):
        for x in range(32):
            xa,xb=ra[ya+k][x],rb[yb+k][x]; d+=bin(xa^xb).count('1'); tot+=bin(xa|xb).count('1')
    return d,tot
# Hobbit picture index at $CC00: 3-byte entries room,lo,hi
idx=[];p=0xCC00-24576
while True:
    r,lo,hi=HB[p],HB[p+1],HB[p+2]
    if r==0xFF or p>0xCC00-24576+200: break
    idx.append((r,lo|hi<<8)); p+=3
print('hobbit picture index entries:',len(idx),[ (r,hex(a)) for r,a in idx][:30])
