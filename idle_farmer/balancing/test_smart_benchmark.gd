extends GutTest
## M02 S5 benchmark (build plan B3/B4, V08): full Smart batches through FertilizerOptimizer for
## 32-plot farms, cold (empty cache) and warm (identical inputs). Not part of the default suite:
## run with `tools/run_tests.ps1 -Dir res://balancing`. Gate (B3, owner-amended): uniform cold
## ≤ 5 ms, worst cold ≤ 50 ms; warm is reported to show the caching condition.

const RUNS: int = 7
const MIN_US: int = 60_000_000
const GATE_WORST_MS: float = 50.0
const GATE_UNIFORM_MS: float = 5.0

## [minutes, options] for profitable crops (FRS §4.2 / §6.2, no other bonuses).
const CROPS: Array[Array] = [
	[60, [[1, 41, 26], [2, 95, 40], [3, 240, 30]]],
	[180, [[1, 180, 120], [2, 420, 180], [3, 936, 264]]],
	[90, [[1, 122, 80], [2, 284, 121], [3, 632, 178]]],
	[45, [[1, 67, 44], [2, 156, 66], [3, 348, 97]]],
	[120, [[1, 240, 160], [2, 560, 240], [3, 1248, 352]]],
	[60, [[1, 118, 78], [2, 275, 117], [3, 613, 172]]],
	[240, [[1, 885, 590], [2, 2065, 885], [3, 4602, 1298]]],
	[180, [[1, 660, 440], [2, 1540, 660], [3, 3432, 968]]],
]

var _report: Array[String] = []


func after_all() -> void:
	print("\n=== Smart batch benchmark (median of %d runs, 32 plots) ===" % RUNS)
	for line: String in _report:
		print(line)


func _members(mixed: bool) -> Array:
	var members: Array = []
	for id: int in range(1, 33):
		var crop: Array = CROPS[(id - 1) % CROPS.size()] if mixed else CROPS[0]
		members.append({"plot_id": id, "duration_us": crop[0] * MIN_US, "options": crop[1]})
	return members


func _measure(name: String, groups: Array, m: int, c: int) -> Array[float]:
	var cold: Array[float] = []
	var warm: Array[float] = []
	for run: int in RUNS:
		FertilizerOptimizer.clear_cache()
		var start: int = Time.get_ticks_usec()
		var first: Dictionary = FertilizerOptimizer.solve_groups(groups, m, c)
		cold.append((Time.get_ticks_usec() - start) / 1000.0)
		start = Time.get_ticks_usec()
		var second: Dictionary = FertilizerOptimizer.solve_groups(groups, m, c)
		warm.append((Time.get_ticks_usec() - start) / 1000.0)
		assert_eq(second, first, name)
	cold.sort()
	warm.sort()
	_report.append("%-30s cold %8.2f ms   warm %6.3f ms" % [name, cold[RUNS / 2], warm[RUNS / 2]])
	return [cold[RUNS / 2], warm[RUNS / 2]]


func test_uniform_and_mixed_batches() -> void:
	var uniform: Array[float] = _measure("uniform Tomatoes MP, ample", [["smart_mp", _members(false)]], 1_000_000, 250_000)
	var mixed: Array[float] = _measure("mixed 8 crops MP, ample", [["smart_mp", _members(true)]], 1_000_000, 250_000)
	var half: Array[float] = _measure("mixed 8 crops MP, half", [["smart_mp", _members(true)]], 20_000, 5_000)
	var split: Array = [["smart_mp", _members(true).slice(0, 11)], ["smart_ce", _members(true).slice(11, 22)],
		["smart_bp", _members(true).slice(22, 32)]]
	var modes: Array[float] = _measure("mixed MP/CE/BP groups, half", split, 20_000, 5_000)
	assert_lte(uniform[0], GATE_UNIFORM_MS, "uniform cold within the B3 gate")
	for timing: Array[float] in [mixed, half, modes]:
		assert_lte(timing[0], GATE_WORST_MS, "worst cold within the B3 gate")
		assert_lt(timing[1], timing[0], "a cached repeat is cheaper than a cold solve")
