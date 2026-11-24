exec(open('hobbit_behav.py').read().split("# Hobbit picture index")[0])
def run2(mem,regs_extra,maxframes=600):
    # enter Mugsy's engine after its clear-screen call, with a solid line along row 47 as a ceiling
    entry=31253; mem[RET:RET+2]=bytes([0x18,0xFE]); sp=23552
    mem[sp-2]=RET&255; mem[sp-1]=RET>>8
    sp-=8
    mem[16384:16384+6144]=bytes(6144); mem[22528:22528+768]=bytes([56])*768
    y=47; a=0x4000+((y&0xC0)<<5)+((y&7)<<8)+(((y>>3)&7)<<5); mem[a:a+32]=b'\xff'*32
    regs={'PC':entry,'SP':sp,'IY':23610,'A':0,'F':0}; regs.update(regs_extra)
    sim=CSimulator(mem,regs,{'im':1,'iff':0,'tstates':0}); tr=Tracer(); sim.set_tracer(tr); n=[0]
    def draw(scr,frame,border,kb):
        n[0]=frame; return frame<maxframes and sim.registers[PC]!=RET
    sim.trace(entry,RET,0,0,1,draw,set(),tr.keyboard,None,None)
    return bytes(sim.memory[16384:16384+6912]),sim.registers[PC]==RET,n[0]
idx=[];p=0xCC00-24576
while HB[p]!=0xFF and len(idx)<22: idx.append((HB[p],HB[p+1]|HB[p+2]<<8)); p+=3
td=tb=0;ident=0
for r,a in idx:
    h=hmem(); hs,hd,hn=run(h,0x8985,{'HL':a})
    m=mmem(); chunk=HB[a-24576:a-24576+3000]; m[53793:53793+len(chunk)]=chunk
    ms,md,mn=run2(m,{'IY':53793+2})
    d,t=bits_diff(hs,ms,0,48,128); td+=d;tb+=t; ident+= (d==0)
    print('room %2d $%X  mugsy done=%s  differing pixels %d of %d'%(r,a,md,d,t))
    screen_png(ms,'/tmp/hob/out/M2on%d.png'%r)
print('identical pictures: %d of %d; total differing %d of %d'%(ident,len(idx),td,tb))
