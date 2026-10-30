extends GutTest
## M02-T17 / V11, V14 (DEC-024/G5, FRS §12.1, B4): full-cost scripted strategies from the untouched
## new-game state at normalized 1×, active-only and mixed-offline. Each run reports time to level 7,
## to each of the four automation nodes and to full basic automation (loops armed on every plot),
## plus costs, points, idle plot time and stalls. The 3–5 h target is reported as met or missed and
## never tuned. Automated output is economics only: human engagement is unobserved.
## Run with `tools/run_tests.ps1 -Dir res://balancing`.

const CAP_US: int = 16 * StrategyPlayer.HOUR_US
const TARGET_MIN_US: int = 3 * StrategyPlayer.HOUR_US
const TARGET_MAX_US: int = 5 * StrategyPlayer.HOUR_US

const AUTOMATION: Array[Array] = [["batch_planting", 1], ["batch_harvesting", 1], ["automatic_harvesting", 1],
	["automatic_replanting", 1]]
const FILL: Array[Array] = [["efficient_harvest", 5], ["faster_germination", 5]]
const GROWTH_PROFIT_FIRST: Array[Array] = [["faster_germination", 1], ["efficient_harvest", 1], ["faster_germination", 2],
	["efficient_harvest", 2]]

var _report: Array[String] = []
var _trace: Array[String] = []


func after_all() -> void:
	print("\n=== M02 strategy pacing report (1×, full cost, human engagement unobserved) ===")
	for line: String in _report:
		print(line)
	print("\n=== Decision trace: focused_automation, active_only ===")
	for line: String in _trace:
		print(line)


static func strategies() -> Array[Dictionary]:
	return [
		{"name": "focused_automation", "skill_order": AUTOMATION + FILL, "metric": "coins", "reserve_percent": 0,
			"fertilizer": "none", "buy_plots": true, "equipment": [], "boost": false},
		{"name": "mixed_growth_profit", "skill_order": GROWTH_PROFIT_FIRST + AUTOMATION + FILL, "metric": "coins",
			"reserve_percent": 0, "fertilizer": "none", "buy_plots": true, "equipment": ["irrigation", "improved_soil"], "boost": true},
		{"name": "coin_xp", "skill_order": AUTOMATION + FILL, "metric": "xp", "reserve_percent": 0, "fertilizer": "none",
			"buy_plots": true, "equipment": [], "boost": false},
		{"name": "low_reserve", "skill_order": AUTOMATION + FILL, "metric": "coins", "reserve_percent": 0,
			"fertilizer": "positive", "buy_plots": true, "equipment": ["irrigation", "improved_soil"], "boost": true},
		{"name": "high_reserve", "skill_order": AUTOMATION + FILL, "metric": "coins", "reserve_percent": 50,
			"fertilizer": "none", "buy_plots": false, "equipment": [], "boost": false},
	]


func _play(strategy: Dictionary, mode: String) -> StrategyPlayer:
	var state: GameState = Fixtures.new_game_v2()
	assert_eq([state.player.coins, state.player.level, state.player.total_xp, state.research.completed.size(),
		state.unlocked_plot_count(), state.player.available_skill_points], [0, 1, 0, 0, 24, 0], "approved empty start, no grants")
	var player: StrategyPlayer = StrategyPlayer.new(strategy, mode, state, Fixtures.uuid("S"))
	player.play(CAP_US)
	return player


## Every coin and XP point is accounted for by real, paid, quoted costs (V14 "real costs").
func _check_costs(player: StrategyPlayer, label: String) -> void:
	var final: GameState = player.controller.snapshot()
	var registry: ContentRegistry = Fixtures.registry_v2()
	assert_eq(final.validate(registry), PackedStringArray(), label)
	assert_eq(player.rejected, {}, "%s: every intent matched its quote" % label)
	var ledger: StrategyPlayer.Ledger = player.ledger
	var seeds: int = ledger.harvested_seed_cost
	var fertilizer: int = ledger.harvested_fertilizer_cost
	for plot: PlotState in final.plots:
		if plot.crop_cycle != null:
			seeds += plot.crop_cycle.seed_cost_paid
			fertilizer += plot.crop_cycle.fertilizer_cost_paid
	var spend: Dictionary = ledger.spend
	assert_eq(final.player.coins, ledger.gross - seeds - fertilizer - spend["research"] - spend["boost"] - spend["plots"]
		- spend["equipment"] - spend["reset"], "%s: wallet reconciles" % label)
	assert_eq(final.player.total_xp, ledger.xp, "%s: XP only from harvests" % label)
	var research: int = 0
	for project_id: String in final.research.completed:
		research += registry.research(project_id).cost
	if not final.research.active_project_id.is_empty():
		research += registry.research(final.research.active_project_id).cost
	assert_eq(spend["research"], research, "%s: research paid at catalog cost" % label)
	var plots: int = 0
	for id: int in range(PlotState.INITIAL_UNLOCKED + 1, final.unlocked_plot_count() + 1):
		plots += registry.expansion_band(id).cost
	assert_eq(spend["plots"], plots, "%s: plots paid at band cost" % label)
	var equipment: int = 0
	for family: String in final.upgrades.ranks:
		for rank: int in range(1, final.upgrades.ranks[family] + 1):
			equipment += registry.upgrade(family, rank).cost
	assert_eq(spend["equipment"], equipment, "%s: equipment paid at rank cost" % label)
	var allocated: int = final.player.allocated_skill_points()
	assert_eq(allocated + final.player.available_skill_points, final.player.level - 1, "%s: one point per level" % label)


static func _verdict(player: StrategyPlayer) -> String:
	if not player.milestones.has("full_automation"):
		return "not reached by %s h" % StrategyPlayer.hours(CAP_US)
	var active: int = player.milestones["full_automation"][1]
	if active < TARGET_MIN_US:
		return "faster than 3–5 h"
	return "met (3–5 h)" if active <= TARGET_MAX_US else "missed (> 5 h)"


static func _at(player: StrategyPlayer, milestone: String) -> String:
	if not player.milestones.has(milestone):
		return "—"
	var at: Array = player.milestones[milestone]
	return StrategyPlayer.hours(at[1]) if player.mode == StrategyPlayer.MODE_ACTIVE \
		else "%s (%s)" % [StrategyPlayer.hours(at[1]), StrategyPlayer.hours(at[0])]


func _summarize(player: StrategyPlayer) -> void:
	var final: GameState = player.controller.snapshot()
	var ledger: StrategyPlayer.Ledger = player.ledger
	var seeds_fertilizer: Array[int] = [ledger.harvested_seed_cost, ledger.harvested_fertilizer_cost]
	for plot: PlotState in final.plots:
		if plot.crop_cycle != null:
			seeds_fertilizer[0] += plot.crop_cycle.seed_cost_paid
			seeds_fertilizer[1] += plot.crop_cycle.fertilizer_cost_paid
	var crop: String = SettingsResolver.effective(final, 1).crop_id
	_report.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % [player.strategy["name"], player.mode,
		_at(player, "level_7"), _at(player, "batch_planting"), _at(player, "batch_harvesting"), _at(player, "automatic_harvesting"),
		_at(player, "automatic_replanting"), _at(player, "full_automation"), _verdict(player), crop])
	_report.append("|   costs | seeds %d · fertilizer %d · research %d · boost %d · plots %d · equipment %d · reset %d | gross %d | harvests %d manual / %d auto | idle plot-h %s | stalls %s | decisions %d | coins %d · L%d · %d plots · ranks %s | online %s h · offline %s h | engagement unobserved |" % [
		seeds_fertilizer[0], seeds_fertilizer[1], ledger.spend["research"], ledger.spend["boost"], ledger.spend["plots"],
		ledger.spend["equipment"], ledger.spend["reset"], ledger.gross, ledger.harvests["manual"], ledger.harvests["automatic"],
		StrategyPlayer.hours(ledger.idle_plot_us), str(ledger.stalls), player.decisions.size(), final.player.coins,
		final.player.level, final.unlocked_plot_count(), str(final.player.skill_ranks), StrategyPlayer.hours(player.active_us), StrategyPlayer.hours(player.offline_us)])


func test_v11_strategies_active_and_mixed_offline() -> void:
	_report.append("| strategy | mode | L7 | batch planting | batch harvesting | auto harvest | auto replant | full automation | 3–5 h target | loop crop |")
	_report.append("|---|---|---|---|---|---|---|---|---|---|")
	for strategy: Dictionary in strategies():
		for mode: String in [StrategyPlayer.MODE_ACTIVE, StrategyPlayer.MODE_MIXED_OFFLINE]:
			var player: StrategyPlayer = _play(strategy, mode)
			var label: String = "%s/%s" % [strategy["name"], mode]
			_check_costs(player, label)
			assert_true(player.milestones.has("full_automation"), "%s reaches full basic automation within the cap" % label)
			for node: Array in AUTOMATION:
				assert_true(player.milestones.has(node[0]), "%s: %s bought with a real point" % [label, node[0]])
			_summarize(player)
			if strategy["name"] == "focused_automation" and mode == StrategyPlayer.MODE_ACTIVE:
				for decision: Array in player.decisions:
					if decision[1] != GameCommand.TYPE_HARVEST_CROP and decision[1] != GameCommand.TYPE_PLANT_CROP \
							and decision[1] != GameCommand.TYPE_BATCH_HARVEST and decision[1] != GameCommand.TYPE_BATCH_PLANT:
						_trace.append("%s h  %s  %s" % [StrategyPlayer.hours(decision[0]), decision[1], decision[2]])


func test_strategy_runs_are_deterministic() -> void:
	var strategy: Dictionary = strategies()[0]
	var first: StrategyPlayer = _play(strategy, StrategyPlayer.MODE_MIXED_OFFLINE)
	var second: StrategyPlayer = _play(strategy, StrategyPlayer.MODE_MIXED_OFFLINE)
	assert_eq(second.controller.snapshot().gameplay_digest(), first.controller.snapshot().gameplay_digest())
	assert_eq(second.decisions, first.decisions)
	assert_eq(second.milestones, first.milestones)
