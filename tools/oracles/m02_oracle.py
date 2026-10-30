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


# Independent transcription of FRS §8 (research) for the T07 oracle: crop -> (level, coins, minutes).
RESEARCH = {
    "carrots": (2, 150, 8), "corn": (4, 800, 20), "tomatoes": (7, 2800, 45), "pumpkins": (10, 9000, 120),
    "sunflowers": (12, 10000, 60), "strawberries": (12, 12000, 45), "blueberries": (15, 24000, 90),
    "soybeans": (15, 26000, 60), "grapes": (18, 55000, 120), "coffee": (18, 55000, 120),
    "cotton": (22, 120000, 180), "rice": (22, 110000, 150), "vanilla": (26, 300000, 300), "saffron": (26, 250000, 240),
}


def boost(remaining):
    """DEC-007: new remaining = ceil(remaining/2); None when it saves no time."""
    halved = ceil_div(remaining, 2)
    return None if halved >= remaining else halved


def research_rows():
    rows = []
    for crop in sorted(RESEARCH):
        level, cost, minutes = RESEARCH[crop]
        duration = minutes * 60_000_000
        rows.append(["unlock_" + crop, crop, level, cost, duration, ceil_div(cost, 2), boost(duration)])
    return rows


def boost_rows(rng):
    minute = 60_000_000
    cases = [20 * minute, 10 * minute, 2, 1, 3, 4, 5, 7, 999_999, INT64_MAX]
    cases += [rng.randint(2, 10**12) for _ in range(20)]
    return [[r, -1 if boost(r) is None else boost(r), 0 if boost(r) is None else r - boost(r)] for r in cases]


def charge_rows():
    """ceil(C/2) for paid snapshots. Every FRS §8 cost is even, so odd costs (a repriced or migrated
    snapshot) are the only vectors that separate ceil from floor."""
    return [[c, ceil_div(c, 2)] for c in (0, 1, 2, 3, 599, 601, 799, 801, 150_001, INT64_MAX)]


def accepted_time_rows(rng):
    """AV-004-03: the preview ages; the accepted-time result halves what remains at acceptance.
    [project, quote elapsed_us, accept elapsed_us, expected completion offset from start or -1]."""
    rows = []
    for crop in ("carrots", "corn", "tomatoes", "vanilla"):
        duration = RESEARCH[crop][2] * 60_000_000
        for _ in range(3):
            quote_at = rng.randint(0, duration - 2)
            accept_at = rng.randint(quote_at, duration - 1)
            halved = boost(duration - accept_at)
            rows.append(["unlock_" + crop, quote_at, accept_at, -1 if halved is None else accept_at + halved])
        rows.append(["unlock_" + crop, duration - 2, duration - 1, -1])  # preview saved 1 us; at acceptance none
        rows.append(["unlock_" + crop, 0, duration - 2, duration - 1])
    return rows


def allocate(wallet, reserve, percent, seed_protection, candidates):
    """FRS §7.1 / FR-AUD-005 seed-first allocation with fixed-fertilizer exclusion and replan,
    written from the specification text (not from the GDScript).
    candidate = (plot, priority, seed, price, fixed, fallback)."""
    order = sorted(candidates, key=lambda c: (-c[1], c[0]))
    excluded = []
    passes = 0
    while True:
        passes += 1
        funded, seed_stalled, spent = [], [], 0
        for c in order:
            if c[0] in excluded:
                continue
            cap = max(0, wallet - reserve) if seed_protection and c[2] > 0 else wallet
            if spent + c[2] <= cap:
                spent += c[2]
                funded.append(c)
            else:
                seed_stalled.append(c[0])
        avail = max(0, wallet - spent - reserve)
        fixed_spend, plan, failed = 0, [], None
        for c in funded:
            if not c[4]:
                plan.append([c[0], 0, False])
            elif fixed_spend + c[3] <= avail:
                fixed_spend += c[3]
                plan.append([c[0], c[3], False])
            elif c[5]:
                plan.append([c[0], 0, True])
            else:
                failed = c[0]
                break
        if failed is None:
            break
        excluded.append(failed)
    assert len(excluded) <= len(candidates) and passes <= len(candidates) + 1
    stalls = sorted([[pid, "seed_funds"] for pid in seed_stalled] + [[pid, "fertilizer_funds"] for pid in excluded])
    m = avail - fixed_spend
    return plan, stalls, spent, avail, fixed_spend, m, m * percent // 100, passes, len(excluded)


def allocator_cases(rng):
    corn = 18
    cases = [
        # AV-005-01: plot 1 Corn+Premium(75) no fallback, plot 2 Corn+None; W=100, R=0.
        ("av005_01", 100, 0, 25, False, [(1, 0, corn, 75, True, False), (2, 0, corn, 0, False, False)]),
        # AV-005-01 with fallback accepted: plot 1 plants Corn with None.
        ("av005_01_fallback", 100, 0, 25, False, [(1, 0, corn, 75, True, True), (2, 0, corn, 0, False, False)]),
        # AV-005-03: Corn+Basic(20), Corn+Premium(75), Corn+None; W=100.
        ("av005_03", 100, 0, 25, False, [(1, 0, corn, 20, True, False), (2, 0, corn, 75, True, False), (3, 0, corn, 0, False, False)]),
        # DVS-008: W=1000, S=200, R=100, F=100 -> A=700, M=600, C=150 at 25%.
        ("dvs008", 1000, 100, 25, False, [(1, 0, 120, 100, True, False), (2, 0, 80, 0, False, False)]),
        # V04: R >= W: seeds still fundable, no optional spend.
        ("reserve_above_wallet", 50, 500, 25, False, [(1, 0, 18, 20, True, True), (2, 0, 0, 0, False, False)]),
        # AV-005-04: seed protection (fixture): paid seeds fit max(0, W-R); free seeds always fund.
        ("seed_protection", 100, 70, 25, True, [(1, 0, 18, 0, False, False), (2, 0, 18, 0, False, False), (3, 0, 0, 0, False, False)]),
        # B6: an unaffordable seed is skipped and a later cheaper one is still funded.
        ("skip_unaffordable_seed", 60, 0, 25, False, [(1, 0, 55, 0, False, False), (2, 0, 10, 0, False, False), (3, 0, 5, 0, False, False)]),
        # Exact wallet exhaustion.
        ("exact_exhaustion", 54, 0, 25, False, [(1, 0, 18, 0, False, False), (2, 0, 18, 0, False, False), (3, 0, 18, 0, False, False)]),
        # Priorities (fixture-only, Q3): higher priority is funded first.
        ("priority_order", 40, 0, 25, False, [(1, 0, 18, 0, False, False), (2, 5, 18, 0, False, False), (3, 0, 18, 0, False, False)]),
        # Cascading exclusions: each exclusion frees seed money that makes a later candidate fundable.
        ("cascade", 120, 0, 25, False, [(1, 0, 30, 60, True, False), (2, 0, 30, 50, True, False), (3, 0, 30, 40, True, False),
                                         (4, 0, 30, 0, False, False), (5, 0, 30, 0, False, False)]),
    ]
    for n in range(40):
        count = rng.randint(1, 10)
        candidates = []
        for pid in range(1, count + 1):
            fixed = rng.random() < 0.6
            candidates.append((pid, rng.choice([0, 0, 0, 1]) if n % 3 == 0 else 0, rng.choice([0, 18, 55, 185, 300, rng.randint(0, 400)]),
                               rng.choice([20, 41, 75, 95, 240, rng.randint(0, 500)]) if fixed else 0, fixed, rng.random() < 0.3))
        cases.append(("random_%02d" % n, rng.randint(0, 2500), rng.choice([0, 0, 50, 300]), rng.choice([0, 25, 50, 100]),
                      n % 7 == 0, candidates))
    return cases


def crop_options(crop):
    """Paid-tier options [tier, price, incremental net] for a crop with no other bonuses (FRS §6.2/§7.2)."""
    base = CROPS[crop][2]
    plain = base
    options = []
    for tier, fert in ((1, "basic"), (2, "premium"), (3, "advanced")):
        gross = base * (10000 + FERTILIZERS[fert][0]) // 10000
        price = fert_price(fert, base)
        options.append((tier, price, gross - plain - price))
    return options


def ce_solve(plots, funds):
    """Q2 Capital Efficiency, from the build plan text: repeatedly take the affordable step with
    positive delta-net and the highest delta-net/delta-cost; ties: higher delta-net/duration, lower
    delta-cost, lower plot ID, lower target tier. Steps without positive delta-cost are skipped."""
    cur = {pid: (0, 0, 0) for pid, _, _ in plots}  # tier, cost, net
    spent = 0
    while True:
        best = None
        for pid, duration, options in plots:
            tier, cost, net = cur[pid]
            for t, c, n in options:
                dc, dn = c - cost, n - net
                if t <= tier or n <= 0 or dc <= 0 or dn <= 0 or dc > funds - spent:
                    continue
                key = (-Fraction(dn, dc), -Fraction(dn, duration), dc, pid, t)
                if best is None or key < best[0]:
                    best = (key, pid, t, c, n, dc)
        if best is None:
            break
        _, pid, t, c, n, dc = best
        spent += dc
        cur[pid] = (t, c, n)
    return [cur[pid][0] for pid, _, _ in sorted(plots)], spent


def smart_batch(m, c, groups):
    """FRS §7.3: groups in order; MP/CE spend from remaining M; BP from min(remaining M, remaining C)."""
    tiers, total, bp_total = {}, 0, 0
    for mode, plots in groups:
        funds = min(m, c) if mode == "smart_bp" else m
        if mode == "smart_ce":
            chosen, spend = ce_solve(plots, funds)
        else:
            chosen, spend, _ = solve(sorted(plots), funds)
        for (pid, _, _), t in zip(sorted(plots), chosen):
            tiers[pid] = t
        m -= spend
        total += spend
        if mode == "smart_bp":
            c -= spend
            bp_total += spend
    return sorted([[pid, t] for pid, t in tiers.items()]), total, bp_total


def smart_cases(rng):
    minute = 60_000_000
    def plot(pid, crop):
        return (pid, CROPS[crop][0] * minute, crop_options(crop))
    toms = [plot(1, "tomatoes"), plot(2, "tomatoes")]
    cases = [
        # DVS-010: W=205, R=0, two 60-min Tomatoes -> A = 205 - 110 = 95.
        ("dvs010_mp", 95, 23, [("smart_mp", toms)]),
        ("dvs010_bp25", 95, 23, [("smart_bp", toms)]),
        ("dvs010_mp_budget41", 41, 10, [("smart_mp", toms)]),
        ("dvs010_ce", 95, 23, [("smart_ce", toms)]),
        # DVS-008 shape: M = 600, C = 150; all-BP, and MP before BP leaving BP less.
        ("dvs008_all_bp", 600, 150, [("smart_bp", [plot(1, "pumpkins"), plot(2, "sunflowers"), plot(3, "tomatoes")])]),
        ("dvs008_mp_then_bp", 600, 150, [("smart_mp", [plot(1, "pumpkins"), plot(2, "blueberries")]),
                                        ("smart_bp", [plot(3, "sunflowers"), plot(4, "tomatoes")])]),
        ("mp_ce_bp_order", 900, 300, [("smart_mp", [plot(1, "grapes")]), ("smart_ce", [plot(2, "coffee"), plot(3, "rice")]),
                                     ("smart_bp", [plot(4, "pumpkins"), plot(5, "soybeans")])]),
        # CE ranks by ROI across crops: Pumpkins Basic (120/180) before Strawberries Basic (44/67).
        ("ce_roi_order", 300, 75, [("smart_ce", [plot(1, "pumpkins"), plot(2, "strawberries")])]),
        ("wheat_carrots_corn", 10_000, 2_500, [("smart_mp", [plot(1, "wheat"), plot(2, "carrots"), plot(3, "corn")])]),
    ]
    profitable = ["tomatoes", "pumpkins", "sunflowers", "strawberries", "blueberries", "soybeans", "grapes", "coffee", "rice",
                  "corn", "cotton", "saffron", "vanilla"]
    for n in range(36):
        pid = 0
        groups = []
        for mode in ("smart_mp", "smart_ce", "smart_bp"):
            if rng.random() < 0.7:
                members = []
                for _ in range(rng.randint(1, 4)):
                    pid += 1
                    members.append(plot(pid, rng.choice(profitable)))
                groups.append((mode, members))
        if not groups:
            pid += 1
            groups.append(("smart_mp", [plot(pid, "tomatoes")]))
        m = rng.choice([0, rng.randint(0, 600), rng.randint(0, 6000), rng.randint(0, 40000)])
        c = m * rng.choice([0, 25, 50, 100]) // 100
        cases.append(("random_%02d" % n, m, c, groups))
    return cases


def gd(v):
    if isinstance(v, bool):
        return "true" if v else "false"
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
    research_rng = random.Random(SEED + 7)  # separate stream: earlier vectors stay byte-identical
    lines += ["", "## [project_id, crop, required level, cost, duration_us, boost charge ceil(C/2),",
              "##  remaining after a boost at start ceil(D/2)] (FRS §8, DEC-007).", "const RESEARCH: Array[Array] = ["]
    for row in research_rows():
        lines.append("	" + gd(row) + ",")
    lines += ["]", "", "## [remaining_us, new remaining_us (-1 = no time saved), saved_us].", "const BOOST: Array[Array] = ["]
    for row in boost_rows(research_rng):
        lines.append("	" + gd(row) + ",")
    lines += ["]", "", "## [paid cost C, boost charge ceil(C/2)].", "const BOOST_CHARGE: Array[Array] = ["]
    for row in charge_rows():
        lines.append("	" + gd(row) + ",")
    lines += ["]", "", "## [project_id, quote elapsed_us, accept elapsed_us, completion offset from start (-1 = NO_TIME_SAVED)].",
              "const BOOST_ACCEPTED: Array[Array] = ["]
    for row in accepted_time_rows(research_rng):
        lines.append("	" + gd(row) + ",")
    lines.append("]")
    alloc_rng = random.Random(SEED + 11)  # separate stream: earlier vectors stay byte-identical
    lines += ["", "## [name, W, R, percent, seed_protection, candidates [[plot, priority, seed, price, fixed, fallback]],",
              "##  funded [[plot, fertilizer price paid, fallback_used]] in allocation order, stalls [[plot, reason]],",
              "##  S, A, F, M, C, passes, exclusions] (FRS §7.1, FR-AUD-005, AV-005-01-04, DVS-008).",
              "const ALLOCATOR: Array[Array] = ["]
    for name, w, r, pct, prot, cands in allocator_cases(alloc_rng):
        plan, stalls, s_, a_, f_, m_, c_, passes, excl = allocate(w, r, pct, prot, cands)
        lines.append("\t" + gd([name, w, r, pct, prot, [list(c) for c in cands], plan, stalls, s_, a_, f_, m_, c_, passes, excl]) + ",")
    lines.append("]")
    smart_rng = random.Random(SEED + 13)  # separate stream: earlier vectors stay byte-identical
    lines += ["", "## [name, M, C, groups [[mode, [[plot, duration_us, [[tier, price, net], ...]], ...]]] in group order,",
              "##  expected [[plot, tier]], Smart spend, Budget Protection spend] (FRS §§7.2-7.3, Q2, DVS-008/010).",
              "const SMART: Array[Array] = ["]
    for name, m, c, groups in smart_cases(smart_rng):
        tiers, total, bp_total = smart_batch(m, c, groups)
        group_list = [[mode, [[pl[0], pl[1], [list(o) for o in pl[2]]] for pl in plots]] for mode, plots in groups]
        lines.append("\t" + gd([name, m, c, group_list, tiers, total, bp_total]) + ",")
    lines.append("]")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
