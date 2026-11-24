import re,difflib,sys
exec(open('hobbit_cmp.py').read().split("PAIRS=")[0])
def full(mem,lo,hi):
    # linear sweep; code/data mix gives noise but long matches are meaningful
    return listing(mem,lo,hi)
ha=full(H,24576,62464); ma=full(M,24576,65536)
# mugsy code region only up to ~ 42112+? keep all
hs=[norm(x[1]) for x in ha]; ms=[norm(x[1]) for x in ma]
# index mugsy 8-grams
K=10
idx={}
for i in range(len(ms)-K): idx.setdefault(tuple(ms[i:i+K]),[]).append(i)
used=set();runs=[]
i=0
while i<len(hs)-K:
    best=None
    for j in idx.get(tuple(hs[i:i+K]),[]):
        n=K
        while i+n<len(hs) and j+n<len(ms) and hs[i+n]==ms[j+n]: n+=1
        if best is None or n>best[1]: best=(j,n)
    if best and best[1]>=K:
        runs.append((i,best[0],best[1])); i+=best[1]
    else: i+=1
tot=0
for i,j,n in runs:
    tot+=n
    # skip trivial runs (all same op)
    seg=set(hs[i:i+n])
    if len(seg)<4: continue
    print('hobbit %X-%X  mugsy %d-%d  %d instrs  e.g. %s'%(ha[i][0],ha[i+n-1][0],ma[j][0],ma[j+n-1][0],n,' ; '.join(hs[i:i+4])))
print('total instrs in runs>=%d: %d of %d hobbit instrs'%(K,tot,len(hs)))
