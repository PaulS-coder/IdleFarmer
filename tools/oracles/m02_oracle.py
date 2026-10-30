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


# Independent transcription of FRS §4.2 (crops), §5.2–5.3 (skill effects), §6.1 (equipment) and
# §6.2 (fertilizers) for the modifier/price oracle.
CROPS = {
    "wheat": (8, 0, 16, 6), "carrots": (15, 0, 36, 12), "corn": (30, 18, 110, 32),
    "tomatoes": (60, 55, 270, 70), "pumpkins": (180, 300, 1200, 230), "sunflowers": (90, 230, 810, 125),
    "strawberries": (45, 185, 445, 105), "blueberries": (120, 450, 1600, 180), "soybeans": (60, 300, 785, 185),
    "grapes": (240, 2000, 5900, 480), "coffee": (180, 1900, 4400, 750), "cotton": (300, 4500, 12500, 950),
    "rice": (75, 1150, 2900, 370), "vanilla": (360, 7200, 24500, 1900), "saffron": (120, 6000, 10000, 1100),
}
GROWTH_SKILLS = {"faster_germination": (400, 5), "improved_cultivation": (300, 5), "climate_control": (500, 3)}
COIN_SKILLS = {"efficient_harvest": (800, 5), "soil_productivity": (1200, 5), "premium_produce": (2000, 3)}
IRRIGATION_BP = [500] * 6
SOIL_BP = [1000, 1000, 1500, 1500, 2000]
FERTILIZERS = {"none": (0, 0, 0), "basic": (2500, 1500, 20), "premium": (5000, 3500, 75), "advanced": (10000, 7800, 240)}
CAP_BP = 6000


def ceil_div(a, d):
    return -((-a) // d)


def fert_price(fert, base):
    bonus, coef, floor = FERTILIZERS[fert]
    return 0 if fert == "none" else max(floor, ceil_div(base * coef, 10000))


def modifier_case(crop, ranks, irrigation, soil, fert):
    minutes, seed, base, xp = CROPS[crop]
    growth = sum(GROWTH_SKILLS[s][0] * r for s, r in ranks.items() if s in GROWTH_SKILLS) + sum(IRRIGATION_BP[:irrigation])
    coins = sum(COIN_SKILLS[s][0] * r for s, r in ranks.items() if s in COIN_SKILLS) + sum(SOIL_BP[:soil])
    capped = min(growth, CAP_BP)
    growth_us = max(1, ceil_div(minutes * 60_000_000 * (10000 - capped), 10000))
    gross = base * (10000 + coins + FERTILIZERS[fert][0]) // 10000
    plain = base * (10000 + coins) // 10000
    price = fert_price(fert, base)
    return [crop, sorted([list(x) for x in ranks.items()]), irrigation, soil, fert, growth, capped, growth_us,
            gross, plain, xp, price, gross - plain - price, gross - seed - price]


def modifier_cases(rng):
    cases = [
        modifier_case("tomatoes", {}, 0, 0, "basic"),  # T-004: 55 / 41 / 337 / 70 / 241
        modifier_case("wheat", {"faster_germination": 5, "improved_cultivation": 5, "climate_control": 3}, 6, 0, "none"),
        modifier_case("tomatoes", {"faster_germination": 5, "improved_cultivation": 5, "climate_control": 3}, 6, 5, "advanced"),
        modifier_case("vanilla", {"efficient_harvest": 5, "soil_productivity": 5, "premium_produce": 3}, 0, 5, "advanced"),
    ]
    all_skills = list(GROWTH_SKILLS.items()) + list(COIN_SKILLS.items())
    for _ in range(80):
        ranks = {s: rng.randint(0, m) for s, (_, m) in all_skills if rng.random() < 0.6}
        ranks = {s: r for s, r in ranks.items() if r > 0}
        cases.append(modifier_case(rng.choice(sorted(CROPS)), ranks, rng.randint(0, 6), rng.randint(0, 5),
                                   rng.choice(sorted(FERTILIZERS))))
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
    lines += ["", "## [crop, [[skill, rank], ...], irrigation rank, soil rank, fertilizer, uncapped growth bp,",
              "##  capped growth bp, growth_us, gross, gross without fertilizer, xp, fertilizer price,",
              "##  incremental fertilizer net, completed-cycle profit]",
              "const MODIFIERS: Array[Array] = ["]
    for case in modifier_cases(rng):
        lines.append("	" + gd(case) + ",")
    lines += ["]", "", "## [crop, fertilizer, price] for every crop × fertilizer (FRS §6.2).", "const PRICES: Array[Array] = ["]
    for crop in sorted(CROPS):
        for fert in sorted(FERTILIZERS):
            lines.append("	" + gd([crop, fert, fert_price(fert, CROPS[crop][2])]) + ",")
    lines.append("]")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
