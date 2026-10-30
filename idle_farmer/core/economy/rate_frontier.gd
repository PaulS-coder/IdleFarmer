class_name RateFrontier
extends RefCounted
## Exact multiple-choice optimizer behind Maximum Profit and Budget Protection (DEC-009, FRS §7.2,
## M02 build plan §3.7, B2). Each plot chooses one option {None} ∪ {tier: cost ≤ budget, gain > 0};
## the objective is Σ gain_i / duration_i under Σ cost ≤ budget.
##
## Ties (FRS §7.2): maximum rate; then lower spend; then, at the first differing plot ID, the
## higher tier.
##
## Method (all decisions exact; no floating point):
## 1. Plots with identical (duration, options) form a class, solved once over option *counts*.
##    Inside a class every plot has the same duration, so its frontier compares integer gains.
## 2. Classes are combined into a Pareto frontier over (spend, rate). Each state carries an integer
##    lower approximation of its rate: Σ_c floor(gain_c·S/d_c), error < 1 per class. A comparison
##    whose approximate difference is at least the class count is certain; otherwise (in practice
##    only exact ties) it is decided exactly with BigInt over the common denominator Π distinct d.
## 3. Pruning keeps a state only if its rate strictly exceeds every cheaper state's; equal
##    (spend, rate) states keep the canonical assignment, compared over the plots processed so far
##    (future classes extend both identically, so the first difference is already decided).

const PATH_APPROX: String = "approx"
const PATH_EXACT: String = "exact_fallback"
const _SCALE_CAP: int = 1 << 62
const _SORT_SPEND_LIMIT: int = 1 << 40
const _SORT_INDEX_BITS: int = 22


## plots: [[plot_id, duration_us, [[tier, cost, gain], ...]], ...]; tier 0 (None) is implicit.
## Returns {"ok", "tiers": Array[int] (ascending plot ID), "plot_ids", "spend", "rate_num": BigInt,
## "rate_den": BigInt, "path", "max_frontier", "exact_comparisons"}.
static func solve(plots: Array, budget: int) -> Dictionary:
	var solver: _Solver = _Solver.new()
	return solver.run(plots, budget)


class _Class:
	extends RefCounted

	var duration: int
	var plot_ids: Array[int] = []
	var option_tiers: Array[int] = [0]
	var option_costs: Array[int] = [0]
	var option_gains: Array[int] = [0]
	# Class frontier: parallel arrays; counts[k] = how many plots take option k.
	var f_spend: Array[int] = []
	var f_gain: Array[int] = []
	var f_counts: Array[PackedInt32Array] = []
	var weight: BigInt = null  # Π distinct durations except this one (lazy)
	var scaled: Array[int] = []  # floor(f_gain·S/d) per class-frontier state

	## Tiers given to this class's plots (ascending ID) by option counts: higher tiers to lower IDs.
	func expand(counts: PackedInt32Array) -> Array[int]:
		var order: Array[int] = []
		for k: int in option_tiers.size():
			order.append(k)
		order.sort_custom(func(a: int, b: int) -> bool: return option_tiers[a] > option_tiers[b])
		var tiers: Array[int] = []
		for k: int in order:
			for c: int in counts[k]:
				tiers.append(option_tiers[k])
		return tiers


class _Solver:
	extends RefCounted

	var classes: Array[_Class] = []
	var denominator: BigInt = null
	var exact_comparisons: int = 0
	# Combined frontier history per class step: parent index into previous step and class choice.
	var step_parent: Array[PackedInt32Array] = []
	var step_choice: Array[PackedInt32Array] = []

	func run(plots: Array, budget: int) -> Dictionary:
		if budget < 0:
			return {"ok": false}
		if not _build_classes(plots, budget):
			return {"ok": false}
		for cls: _Class in classes:
			_class_frontier(cls, budget)
		_scale_classes()

		var spend: Array[int] = [0]
		var approx: Array[int] = [0]
		var max_frontier: int = 1
		for c: int in classes.size():
			var cls: _Class = classes[c]
			var cand_spend: Array[int] = []
			var cand_approx: Array[int] = []
			var cand_parent: PackedInt32Array = PackedInt32Array()
			var cand_choice: PackedInt32Array = PackedInt32Array()
			for s: int in spend.size():
				for g: int in cls.f_spend.size():
					var total: int = spend[s] + cls.f_spend[g]
					if total > budget:
						break  # class frontier is sorted by spend
					cand_spend.append(total)
					cand_approx.append(approx[s] + cls.scaled[g])
					cand_parent.append(s)
					cand_choice.append(g)
			var order: PackedInt64Array = _order_by_spend(cand_spend)
			var keep_parent: PackedInt32Array = PackedInt32Array()
			var keep_choice: PackedInt32Array = PackedInt32Array()
			var next_spend: Array[int] = []
			var next_approx: Array[int] = []
			var best: int = -1  # candidate index of the current frontier maximum
			var margin: int = c + 1  # approximation error bound: < 1 per class term per side
			var order_size: int = order.size()
			var i: int = 0
			while i < order_size:
				# Within one spend value pick the best candidate (rate, then canonical assignment).
				var group_best: int = order[i]
				var j: int = i + 1
				while j < order_size and cand_spend[order[j]] == cand_spend[group_best]:
					var other: int = order[j]
					var diff: int = cand_approx[other] - cand_approx[group_best]
					if diff >= margin:
						group_best = other
					elif diff > -margin:
						var cmp: int = _compare(c, cand_approx, cand_parent, cand_choice, other, group_best)
						if cmp > 0 or (cmp == 0 and _prefers(c, cand_parent, cand_choice, other, group_best)):
							group_best = other
					j += 1
				var better: bool = best == -1
				if not better:
					var lead: int = cand_approx[group_best] - cand_approx[best]
					if lead >= margin:
						better = true
					elif lead > -margin:
						better = _compare(c, cand_approx, cand_parent, cand_choice, group_best, best) > 0
				if better:
					best = group_best
					next_spend.append(cand_spend[group_best])
					next_approx.append(cand_approx[group_best])
					keep_parent.append(cand_parent[group_best])
					keep_choice.append(cand_choice[group_best])
				i = j
			step_parent.append(keep_parent)
			step_choice.append(keep_choice)
			spend = next_spend
			approx = next_approx
			max_frontier = maxi(max_frontier, spend.size())

		var last: int = spend.size() - 1
		var choices: Array[int] = _choices_of(classes.size() - 1, last)
		var by_plot: Dictionary = {}
		var numerator: BigInt = BigInt.zero()
		for c: int in classes.size():
			var cls: _Class = classes[c]
			var tiers: Array[int] = cls.expand(cls.f_counts[choices[c]])
			for k: int in cls.plot_ids.size():
				by_plot[cls.plot_ids[k]] = tiers[k]
			numerator = numerator.add(_class_weight(cls).mul_int(cls.f_gain[choices[c]]))
		var plot_ids: Array[int] = []
		for key: Variant in by_plot.keys():
			plot_ids.append(key)
		plot_ids.sort()
		var tiers_out: Array[int] = []
		for pid: int in plot_ids:
			tiers_out.append(by_plot[pid])
		return {
			"ok": true, "tiers": tiers_out, "plot_ids": plot_ids, "spend": spend[last],
			"rate_num": numerator, "rate_den": _denominator(),
			"path": PATH_EXACT if exact_comparisons > 0 else PATH_APPROX,
			"max_frontier": max_frontier, "exact_comparisons": exact_comparisons,
		}

	func _build_classes(plots: Array, budget: int) -> bool:
		var by_key: Dictionary = {}
		var ordered: Array = plots.duplicate()
		ordered.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
		for plot: Array in ordered:
			if plot[1] <= 0:
				return false
			var usable: Array = []
			for option: Array in plot[2]:
				if option[1] >= 0 and option[1] <= budget and option[2] > 0:
					usable.append(option)
			usable.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
			var key: String = str([plot[1], usable])
			if not by_key.has(key):
				var cls: _Class = _Class.new()
				cls.duration = plot[1]
				for option: Array in usable:
					cls.option_tiers.append(option[0])
					cls.option_costs.append(option[1])
					cls.option_gains.append(option[2])
				by_key[key] = cls
				classes.append(cls)  # first appearance = lowest plot ID: classes ordered by first ID
			(by_key[key] as _Class).plot_ids.append(plot[0])
		return true

	## Frontier over option counts for m identical plots (exact integer gains; same duration).
	## Plot-by-plot Pareto merge; candidates sorted natively by spend; equal (spend, gain) keeps the
	## canonical count vector (more plots on higher tiers, i.e. higher tiers on lower IDs).
	func _class_frontier(cls: _Class, budget: int) -> void:
		var k_count: int = cls.option_tiers.size()
		var spend: Array[int] = [0]
		var gain: Array[int] = [0]
		var counts: Array[PackedInt32Array] = []
		var zero: PackedInt32Array = PackedInt32Array()
		zero.resize(k_count)
		zero.fill(0)
		counts.append(zero)
		var costs: Array[int] = cls.option_costs
		var gains: Array[int] = cls.option_gains
		var desc: Array[int] = []  # option indices by tier, highest first
		for k: int in k_count:
			desc.append(k)
		desc.sort_custom(func(a: int, b: int) -> bool: return cls.option_tiers[a] > cls.option_tiers[b])
		for p: int in cls.plot_ids.size():
			var capacity: int = spend.size() * k_count
			var c_spend: Array[int] = []
			c_spend.resize(capacity)
			var c_gain: PackedInt64Array = PackedInt64Array()
			c_gain.resize(capacity)
			var c_from: PackedInt32Array = PackedInt32Array()
			c_from.resize(capacity)
			var c_option: PackedInt32Array = PackedInt32Array()
			c_option.resize(capacity)
			var n: int = 0
			for s: int in spend.size():
				var base_spend: int = spend[s]
				var base_gain: int = gain[s]
				for k: int in k_count:
					var total: int = base_spend + costs[k]
					if total > budget:
						continue
					c_spend[n] = total
					c_gain[n] = base_gain + gains[k]
					c_from[n] = s
					c_option[n] = k
					n += 1
			c_spend.resize(n)
			var order: PackedInt64Array = _order_by_spend(c_spend)
			var n_spend: Array[int] = []
			var n_gain: Array[int] = []
			var n_counts: Array[PackedInt32Array] = []
			var best_gain: int = -1
			var i: int = 0
			var total_candidates: int = order.size()
			while i < total_candidates:
				var pick: int = order[i]
				var j: int = i + 1
				while j < total_candidates and c_spend[order[j]] == c_spend[pick]:
					var other: int = order[j]
					if c_gain[other] > c_gain[pick]:
						pick = other
					elif c_gain[other] == c_gain[pick] and _counts_prefer(desc, counts[c_from[other]], c_option[other],
							counts[c_from[pick]], c_option[pick]):
						pick = other
					j += 1
				if c_gain[pick] > best_gain:
					best_gain = c_gain[pick]
					n_spend.append(c_spend[pick])
					n_gain.append(c_gain[pick])
					var next: PackedInt32Array = counts[c_from[pick]].duplicate()
					next[c_option[pick]] += 1
					n_counts.append(next)
				i = j
			spend = n_spend
			gain = n_gain
			counts = n_counts
		cls.f_spend = spend
		cls.f_gain = gain
		cls.f_counts = counts


	## Chooses S so that Σ_c floor(max_gain_c·S/d_c) ≤ 2^62, then precomputes each scaled term.
	func _scale_classes() -> void:
		var min_duration: int = IntegerMath.INT64_MAX
		var gain_total: int = 0
		for cls: _Class in classes:
			min_duration = mini(min_duration, cls.duration)
			var top: int = cls.f_gain[cls.f_gain.size() - 1] if not cls.f_gain.is_empty() else 0
			var sum: MathResult = IntegerMath.add(gain_total, top)
			gain_total = sum.value if sum.ok else IntegerMath.INT64_MAX
		var scale: int = _SCALE_CAP
		if gain_total > 0:
			var bounded: MathResult = IntegerMath.mul_div_floor(_SCALE_CAP, min_duration, gain_total)
			if bounded.ok:
				scale = maxi(1, mini(_SCALE_CAP, bounded.value))
		for cls: _Class in classes:
			cls.scaled = []
			for g: int in cls.f_gain:
				cls.scaled.append(IntegerMath.mul_div_floor(g, scale, cls.duration).value)

	## Candidate indices ordered by spend ascending (native sort when spend fits the packed key).
	func _order_by_spend(cand_spend: Array[int]) -> PackedInt64Array:
		var n: int = cand_spend.size()
		var keys: PackedInt64Array = PackedInt64Array()
		keys.resize(n)
		var packable: bool = n < (1 << _SORT_INDEX_BITS)
		for i: int in n:
			if cand_spend[i] >= _SORT_SPEND_LIMIT:
				packable = false
				break
			keys[i] = (cand_spend[i] << _SORT_INDEX_BITS) | i
		if packable:
			keys.sort()
			var mask: int = (1 << _SORT_INDEX_BITS) - 1
			for i: int in n:
				keys[i] = keys[i] & mask
			return keys
		var indices: Array[int] = []
		for i: int in n:
			indices.append(i)
		indices.sort_custom(func(a: int, b: int) -> bool: return cand_spend[a] < cand_spend[b] or (cand_spend[a] == cand_spend[b] and a < b))
		return PackedInt64Array(indices)

	## Exact sign of rate(a) − rate(b) for candidates at class step c.
	func _compare(c: int, cand_approx: Array[int], cand_parent: PackedInt32Array, cand_choice: PackedInt32Array, a: int, b: int) -> int:
		var diff: int = cand_approx[a] - cand_approx[b]
		var margin: int = c + 1  # one floor error < 1 per class term per side
		if diff >= margin:
			return 1
		if diff <= -margin:
			return -1
		exact_comparisons += 1
		var ca: Array[int] = _candidate_choices(c, cand_parent[a], cand_choice[a])
		var cb: Array[int] = _candidate_choices(c, cand_parent[b], cand_choice[b])
		var total: BigInt = BigInt.zero()
		for k: int in c + 1:
			var delta: int = classes[k].f_gain[ca[k]] - classes[k].f_gain[cb[k]]
			if delta != 0:
				total = total.add(_class_weight(classes[k]).mul_int(delta))
		return total.sign()

	## Canonical preference between two equal (spend, rate) candidates over plots processed so far.
	func _prefers(c: int, cand_parent: PackedInt32Array, cand_choice: PackedInt32Array, a: int, b: int) -> bool:
		var ta: Dictionary = _assignment(c, _candidate_choices(c, cand_parent[a], cand_choice[a]))
		var tb: Dictionary = _assignment(c, _candidate_choices(c, cand_parent[b], cand_choice[b]))
		var ids: Array = ta.keys()
		ids.sort()
		for pid: Variant in ids:
			if ta[pid] != tb[pid]:
				return ta[pid] > tb[pid]
		return false

	func _assignment(c: int, choices: Array[int]) -> Dictionary:
		var by_plot: Dictionary = {}
		for k: int in c + 1:
			var tiers: Array[int] = classes[k].expand(classes[k].f_counts[choices[k]])
			for i: int in classes[k].plot_ids.size():
				by_plot[classes[k].plot_ids[i]] = tiers[i]
		return by_plot

	## Class-frontier choice per class 0..c for a candidate built from (parent at step c−1, choice).
	func _candidate_choices(c: int, parent: int, choice: int) -> Array[int]:
		var choices: Array[int] = []
		choices.resize(c + 1)
		choices[c] = choice
		var index: int = parent
		for step: int in range(c - 1, -1, -1):
			choices[step] = step_choice[step][index]
			index = step_parent[step][index]
		return choices

	func _choices_of(step: int, index: int) -> Array[int]:
		var choices: Array[int] = []
		choices.resize(step + 1)
		var i: int = index
		for s: int in range(step, -1, -1):
			choices[s] = step_choice[s][i]
			i = step_parent[s][i]
		return choices

	func _class_weight(cls: _Class) -> BigInt:
		if cls.weight == null:
			var w: BigInt = BigInt.from_int(1)
			var seen: Array[int] = [cls.duration]
			for other: _Class in classes:
				if not seen.has(other.duration):
					seen.append(other.duration)
					w = w.mul_int(other.duration)
			cls.weight = w
		return cls.weight

	func _denominator() -> BigInt:
		if denominator == null:
			var product: BigInt = BigInt.from_int(1)
			var seen: Array[int] = []
			for cls: _Class in classes:
				if not seen.has(cls.duration):
					seen.append(cls.duration)
					product = product.mul_int(cls.duration)
			denominator = product
		return denominator

	## Canonical preference between count vectors (base_a + e_opt_a) and (base_b + e_opt_b): more
	## plots on the highest differing tier wins — identical to comparing the expanded assignments
	## (higher tiers on lower IDs) lexicographically, without allocating.
	static func _counts_prefer(desc: Array[int], base_a: PackedInt32Array, opt_a: int, base_b: PackedInt32Array, opt_b: int) -> bool:
		for k: int in desc:
			var ca: int = base_a[k] + (1 if k == opt_a else 0)
			var cb: int = base_b[k] + (1 if k == opt_b else 0)
			if ca != cb:
				return ca > cb
		return false
