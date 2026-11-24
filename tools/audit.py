import re, sys, os
sys.path.insert(0, os.path.dirname(__file__))
import notes as N
# parse mugsy.skool: routine blocks, count instructions and hand-commented ones
blocks=[]; cur=None
for line in open(os.path.join(os.path.dirname(__file__),'..','mugsy.skool'), encoding='utf-8'):
    if line.startswith(('c','b','t','w','g','u','s')) and re.match(r'^[cbtwgus]\d{5}',line):
        cur=[line[0], int(line[1:6]), line.split(' ',1)[1].strip() if ' ' in line else '', 0, 0]
        blocks.append(cur)
    elif cur and cur[0]=='c' and re.match(r'^[ @*]?\s*(\d{5})\s',line) or (cur and cur[0]=='c' and re.match(r'^[ *]\d{5} ',line)):
        a=int(re.search(r'(\d{5})',line).group(1))
        cur[3]+=1
        if a in N.C: cur[4]+=1
rows=[(b[3]-b[4],b) for b in blocks if b[0]=='c' and b[3]]
rows.sort(key=lambda x:-x[0])
tot=sum(b[3] for _,b in rows); hand=sum(b[4] for _,b in rows)
print('total',tot,'hand',hand)
for miss,b in rows[:40]:
    print('%5d  %5d/%5d  %s %s'%(miss,b[4],b[3],b[1],b[2][:60]))
