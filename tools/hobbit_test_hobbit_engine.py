exec(open('hobbit_behav.py').read().split("# Hobbit picture index")[0])
import sys
sys.argv=['x']
def parse(data):
    i=0;out=[]
    while i<len(data):
        c=data[i]
        if c==0: break
        i+=1
        if c==8: i+=2;k='move'
        elif c==16: w,hh=data[i+2],data[i+3]; i+=4+w*hh;k='bitmap16'
        elif c&0x80: i+=1;k='line'
        elif c&0x40: i+=2;k='fill'
        elif c&0x20:
            i+=2
            while data[i]!=0xFF: i+=1
            i+=1;k='attr'
        else: k='other'
        out.append(k)
    return out
for a in (57583,58673,59397,60526,61625,63601,64646):
    body=MB[a-16384:a-16384+1200]
    kinds=parse(body); cnt={k:kinds.count(k) for k in set(kinds)}
    m=mmem(); ms,md,mn=run(m,31247,{'IY':a})
    h=hmem(); data=bytes([0,0x38])+body; h[0xF800:0xF800+len(data)]=data
    hs,hd,hn=run(h,0x8985,{"HL":0xF800},4000)
    d,t=bits_diff(hs,ms,0,48,128)
    print('%d cmds=%s | mugsy frames %d, hobbit done=%s frames %d | pixels differing in the shared band: %d of %d (%.1f%%)'%(a,cnt,mn,hd,hn,d,t,100*d/max(t,1)))
