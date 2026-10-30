extends GutTest
## M02 S0 benchmark for the exact rate frontier (build plan B3). Not part of the default suite:
## run with `tools/run_tests.ps1 -Dir res://balancing`. Reports median wall time over repeated
## solves of 32-plot groups; correctness is covered by tests/unit/test_rate_frontier.gd.
##
## Gate (provisional engineering threshold): worst case ≤ 50 ms, uniform single-class farm ≤ 5 ms
## (amended by the owner on 2026-10-30 after the S0 measurement of 3.0 ms; see build plan B3).

const RUNS: int = 7
const MIN_US: int = 60_000_000
const GATE_WORST_MS: float = 50.0
const GATE_UNIFORM_MS: float = 5.0

## FRS §4.2 / §6.2 net gains (Basic/Premium/Advanced) and prices for crops with profitable fertilizer.
const CROPS: Array[Array] = [
	# [minutes, [[1, basic_cost, basic_gain], [2, prem_cost, prem_gain], [3, adv_cost, adv_gain]]]
	[60, [[1, 41, 26], [2, 95, 40], [3, 240, 30]]],          # tomatoes
	[180, [[1, 180, 120], [2, 420, 180], [3, 936, 264]]],     # pumpkins
	[90, [[1, 122, 80], [2, 284, 121], [3, 632, 178]]],       # sunflowers
	[45, [[1, 67, 44], [2, 156, 66], [3, 348, 97]]],          # strawberries
	[120, [[1, 240, 160], [2, 560, 240], [3, 1248, 352]]],    # blueberries
	[60, [[1, 118, 78], [2, 275, 117], [3, 613, 172]]],       # soybeans
	[240, [[1, 885, 590], [2, 2065, 885], [3, 4602, 1298]]],  # grapes
	[180, [[1, 660, 440], [2, 1540, 660], [3, 3432, 968]]],   # coffee
]

var _report: Array[String] = []


func after_all() -> void:
	print("\n=== RateFrontier benchmark (median of %d runs, 32 plots) ===" % RUNS)
	for line: String in _report:
		print(line)


func _max_spend(plots: Array) -> int:
	var total: int = 0
	for plot: Array in plots:
		var best: int = 0
		for option: Array in plot[2]:
			best = maxi(best, option[1])
		total += best
	return total


func _measure(name: String, plots: Array, budget: int) -> float:
	var times: Array[float] = []
	var result: Dictionary = {}
	for run: int in RUNS:
		var start: int = Time.get_ticks_usec()
		result = RateFrontier.solve(plots, budget)
		times.append((Time.get_ticks_usec() - start) / 1000.0)
	times.sort()
	var median: float = times[RUNS / 2]
	assert_true(result["ok"], name)
	_report.append("%-34s %8.2f ms  path=%-6s frontier=%5d  spend=%d" % [name, median, result["path"], result["max_frontier"], result["spend"]])
	return median


func _uniform(count: int) -> Array:
	var plots: Array = []
	for id: int in range(1, count + 1):
		plots.append([id, 60 * MIN_US, CROPS[0][1]])
	return plots


func _mixed(count: int) -> Array:
	var plots: Array = []
	for id: int in range(1, count + 1):
		var crop: Array = CROPS[(id - 1) % CROPS.size()]
		plots.append([id, crop[0] * MIN_US, crop[1]])
	return plots


## Effective durations after varied growth reductions (ceil to μs): many distinct, odd durations.
func _modified(count: int) -> Array:
	var plots: Array = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	for id: int in range(1, count + 1):
		var crop: Array = CROPS[(id - 1) % CROPS.size()]
		var reduction_bp: int = rng.randi_range(0, 6000)
		var duration: int = IntegerMath.growth_us(crop[0] * MIN_US, reduction_bp, 6000).value + rng.randi_range(0, 997)
		plots.append([id, duration, crop[1]])
	return plots


## Adversarial: 32 distinct large prime-like durations and random price/gain pairs (BigInt path).
func _adversarial(count: int) -> Array:
	var plots: Array = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 13
	var d: int = 17_179_869_143
	for id: int in range(1, count + 1):
		d += rng.randi_range(2, 4000) * 2
		var options: Array = []
		for tier: int in [1, 2, 3]:
			options.append([tier, rng.randi_range(20, 3000), rng.randi_range(1, 4000)])
		plots.append([id, d, options])
	return plots


func test_benchmark_gate() -> void:
	var uniform: Array = _uniform(32)
	var mixed: Array = _mixed(32)
	var modified: Array = _modified(32)
	var adversarial: Array = _adversarial(32)
	for size: int in [1, 8, 16]:
		_measure("scaling: uniform tomatoes x%d" % size, _uniform(size), 1_000_000)
	var uniform_ms: float = _measure("uniform tomatoes, ample budget", uniform, 1_000_000)
	var worst: Array[float] = [
		_measure("uniform tomatoes, half budget", uniform, _max_spend(uniform) / 2),
		_measure("mixed 8 crops, ample budget", mixed, 1_000_000),
		_measure("mixed 8 crops, half budget", mixed, _max_spend(mixed) / 2),
		_measure("modified durations, half budget", modified, _max_spend(modified) / 2),
		_measure("adversarial BigInt, half budget", adversarial, _max_spend(adversarial) / 2),
		_measure("adversarial BigInt, ample budget", adversarial, 10_000_000),
	]
	worst.sort()
	var worst_ms: float = worst[worst.size() - 1]
	_report.append("GATE uniform %.2f ms (limit %.1f): %s; worst %.2f ms (limit %.1f): %s" % [
		uniform_ms, GATE_UNIFORM_MS, "PASS" if uniform_ms <= GATE_UNIFORM_MS else "FAIL",
		worst_ms, GATE_WORST_MS, "PASS" if worst_ms <= GATE_WORST_MS else "FAIL"])
	pass_test("benchmark recorded; gate verdict in report")
