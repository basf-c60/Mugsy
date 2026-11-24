import math
def INT(x):
    return math.trunc(x)
def clamp(x, lo, hi):
    return max(lo, min(hi, x))
def terms(V, died=True):
    """Score terms as computed by the script at 26469 (V = variables in real units)."""
    t = {}
    t['base'] = 10.0
    t['survived'] = 0.0 if died else 10.0
    rem = V[36] - V[6]
    t['years'] = -3 * (rem if rem <= 4 else 4)
    growth = (V[3] - 40) * 100 / 40
    t['mob'] = clamp(INT(growth / 10), -0.05, 15)
    tph = V[16] / V[13] if V[13] else 0
    t['takings/hood'] = clamp(INT((tph - 25) * 2), 0, 10)
    cg = (V[8] - 400) * 100 / 400
    t['clients'] = clamp(INT(cg / 4), -0.10, 17)
    t['constant'] = 35
    t['blunders'] = -V[12]
    t['killed'] = -min(20, INT(V[10] / 4))
    ppc = V[17] / V[18] if V[18] else 0
    t['profit/client'] = clamp(INT((ppc - 2.5) * 20), -0.10, 10)
    t['total'] = min(100, sum(v for k, v in t.items()))
    return t
