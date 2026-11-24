import sys
sys.argv=['x','work/mugsy_tzx.z80','/tmp/catch','40000','']
src=open('tools/sim.py').read()
src=src.replace("sim.trace(24576, 65536, 0, 0, 1, draw, execmap, tr.keyboard, None, None)",
 "sim.trace(24576, int(os.environ['STOPAT']), 0, 0, 1, draw, execmap, tr.keyboard, None, None)\n    from skoolkit.simutils import SP,PC,A,F,B,C,D,E,H,L,I,IFF; r=sim.registers; sp=r[SP]; print('I',r[I],'IFF',r[IFF],'HL',r[H]*256+r[L],'DE',r[D]*256+r[E],'BC',r[B]*256+r[C],'A',r[A]); print('FRAME',state['n'],'PC',r[24],'SP',sp,'stack',[mem[sp+2*i]|mem[sp+2*i+1]<<8 for i in range(8)], 'regs', list(r[:16]))")
exec(compile(src,'sim','exec'))
