"""Independent test oracle for M02 (build plan E15).

Python integers and fractions.Fraction share no code with the GDScript implementation.
Writes idle_farmer/tests/fixtures/m02_oracle_vectors.gd:
  - BIGINT: [a, b, a+b, a-b, a*b, cmp(a,b)] as decimal strings (limb boundaries, signs, sizes)
  - FRONTIER: exhaustive optimum of the exact rate objective (MP/BP core, DEC-009) for small
    plot sets, under the approved tie rules: maximize sum(gain_i / duration_i); then lower total
    spend; then, at the first differing plot (ascending ID), the higher tier wins.

    python -I tools/oracles/m02_oracle.py
"""

import itertools
import pathlib
import random
from fractions import Fraction

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "idle_farmer" / "tests" / "fixtures" / "m02_oracle_vectors.gd"
INT64_MAX = 2**63 - 1
INT64_MIN = -(2**63)
SEED = 20261030


def bigint_cases(rng: random.Random) -> list[tuple[int, int]]:
    edges = [0, 1, -1, 2**24 - 1, 2**24, 2**48 - 1, 2**48, INT64_MAX, INT64_MIN, 2**63, -(2**63) - 1,
             10**18, -(10**18), 2**100 + 7]
    cases = [(a, b) for a in edges for b in (0, 1, -1, 2**24, INT64_MAX, -(2**70))]
    for _ in range(60):
        bits_a = rng.choice([8, 24, 47, 63, 64, 96, 200, 700])
        bits_b = rng.choice([8, 24, 48, 63, 65, 128, 300])
        a = rng.getrandbits(bits_a) * rng.choice([1, -1])
        b = rng.getrandbits(bits_b) * rng.choice([1, -1])
        cases.append((a, b))
    return cases


def solve(plots, budget):
    """plots: [(plot_id, duration, [(tier, cost, gain), ...])]; None (tier 0) is implicit."""
    choices = []
    for _, _, options in plots:
        usable = [(0, 0, 0)] + [o for o in options if o[1] <= budget and o[2] > 0]
        choices.append(usable)
    best = None
    for combo in itertools.product(*choices):
        spend = sum(o[1] for o in combo)
        if spend > budget:
            continue
        rate = sum((Fraction(o[2], plots[i][1]) for i, o in enumerate(combo)), Fraction(0))
        key = (-rate, spend, tuple(-o[0] for o in combo))
        if best is None or key < best[0]:
            best = (key, combo, spend, rate)
    _, combo, spend, rate = best
    return [o[0] for o in combo], spend, rate


def frontier_cases(rng: random.Random):
    min_us = 60_000_000
    cases = []
    # DVS-010: two 60-minute Tomatoes plots; Basic 41/+26, Premium 95/+40, Advanced 240/+30.
    tomato = [(1, 41, 26), (2, 95, 40), (3, 240, 30)]
    for budget in (95, 41, 23, 82, 0, 1000):
        cases.append(("dvs010_budget_%d" % budget, [(1, 60 * min_us, tomato), (2, 60 * min_us, tomato)], budget))
    # Cross-class exact ties: different durations whose rates are equal (g/d == 2g/2d), so the
    # integer approximation cannot decide and the exact fallback plus canonical tie rule must.
    for k, (cost_a, cost_b) in enumerate([(30, 30), (30, 60), (45, 45)]):
        tie_plots = [
            (1, 30 * min_us, [(1, cost_a, 50), (2, 90, 70)]),
            (2, 60 * min_us, [(1, cost_b, 100), (2, 90, 140)]),
            (3, 90 * min_us, [(1, cost_a, 150)]),
        ]
        for budget in (30, 60, 90, 120):
            cases.append(("cross_class_tie_%d_b%d" % (k, budget), tie_plots, budget))
    # Within-class count ties: identical plots where different option-count mixes give exactly the
    # same spend and gain (e.g. one tier-2 vs two tier-1). The canonical rule (higher tier on the
    # lower plot ID) must pick the mix with more plots on the highest tier.
    linear = [(1, 10, 10), (2, 20, 20), (3, 30, 30)]
    for count, budget in ((2, 20), (3, 30), (3, 40), (4, 50)):
        plots = [(pid, 45 * min_us, linear) for pid in range(1, count + 1)]
        cases.append(("class_count_tie_%d_b%d" % (count, budget), plots, budget))
    big_primes = [17179869143, 17179869209, 17179869233, 17179869239, 17179869251, 17179869257]
    for n in range(40):
        count = rng.randint(1, 6)
        plots = []
        for pid in range(1, count + 1):
            if n % 4 == 3:
                duration = rng.choice(big_primes)  # forces the BigInt common-denominator path
            else:
                duration = rng.choice([8, 15, 30, 45, 60, 75, 90, 120, 180]) * min_us + rng.choice([0, 0, 1, 7, 999])
            options = []
            for tier in (1, 2, 3):
                options.append((tier, rng.randint(0, 3000), rng.randint(-200, 4000)))
            plots.append((pid, duration, options))
        if n % 5 == 0 and count >= 2:
            plots[1] = (2, plots[0][1], list(plots[0][2]))  # identical plots: tie handling
        budget = rng.choice([0, rng.randint(0, 2000), rng.randint(0, 9000), 10**6])
        cases.append(("random_%02d" % n, plots, budget))
    return cases


def gd(v):
    if isinstance(v, str):
        return '"' + v + '"'
    if isinstance(v, (list, tuple)):
        return "[" + ", ".join(gd(x) for x in v) + "]"
    return str(v)


def main() -> None:
    rng = random.Random(SEED)
    lines = [
        "class_name M02OracleVectors",
        "extends RefCounted",
        "## GENERATED by tools/oracles/m02_oracle.py (independent Python oracle). Do not edit.",
        "",
        "## [a, b, a+b, a-b, a*b, cmp(a, b)] as decimal strings / int.",
        "const BIGINT: Array[Array] = [",
    ]
    for a, b in bigint_cases(rng):
        cmp = (a > b) - (a < b)
        lines.append("\t" + gd([str(a), str(b), str(a + b), str(a - b), str(a * b), cmp]) + ",")
    lines += ["]", "",
              "## [name, budget, plots[[plot_id, duration_us, [[tier, cost, gain], ...]]], expected tiers,",
              "##  expected spend, expected rate numerator (decimal), rate denominator (decimal)].",
              "const FRONTIER: Array[Array] = ["]
    for name, plots, budget in frontier_cases(rng):
        tiers, spend, rate = solve(plots, budget)
        plot_list = [[p[0], p[1], [list(o) for o in p[2]]] for p in plots]
        lines.append("\t" + gd([name, budget, plot_list, tiers, spend, str(rate.numerator), str(rate.denominator)]) + ",")
    lines.append("]")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
