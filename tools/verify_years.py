import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import probe
def v36pokes(v):
    val = int(round(v * 100)); a = 33552 + 4 * 36
    return {a + i: (val >> (8 * i)) & 255 for i in range(4)}
seed = int(sys.argv[1]); v = float(sys.argv[2])
says = []
sim, f = probe.run(seed, {52607, 49774, 52705, 52631}, 40000, framepokes=v36pokes(v), says=says, yn='YYYYYYYN')
print('seed', seed, 'v36', v, 'frames', f, 'v36 now', probe.var(sim.memory, 36), 'year', probe.var(sim.memory, 6))
import collections; print(len(says)); print([(fr,a,y) for fr,a,y in says][:60])
