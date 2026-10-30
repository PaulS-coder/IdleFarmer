class_name StrategyPlayer
extends RefCounted
## Scripted full-cost progression player for M02-T17 (V11/V14, B4, DEC-024/G5). It drives a real
## GameController from the untouched new-game state (no grants, no fixture unlocks): every crop,
## research run, boost, plot, equipment rank and skill rank comes from an explicit, confirmed intent
## that pays its real quoted cost. Time runs at normalized 1×.
##
## The player visits the farm every `POLL_US` while online. In `MODE_MIXED_OFFLINE` it is online for
## `ONLINE_US`, then the application is closed for `OFFLINE_US` (offline credit at 1×, no input).
## Automated traces measure economics only: human engagement is never inferred and is reported as
## unobserved. Pacing is reported, never tuned.

const MINUTE_US: int = 60_000_000
const HOUR_US: int = 60 * MINUTE_US
const POLL_US: int = MINUTE_US
const ONLINE_US: int = 20 * MINUTE_US
const OFFLINE_US: int = 40 * MINUTE_US

const MODE_ACTIVE: String = "active_only"
const MODE_MIXED_OFFLINE: String = "mixed_offline"

const AUTOMATION_NODES: PackedStringArray = ["batch_planting", "batch_harvesting", "automatic_harvesting", "automatic_replanting"]

var strategy: Dictionary
var mode: String
var controller: GameController
var ledger: Ledger = Ledger.new()
## Explicit accepted decisions: [sim_us, type, summary].
var decisions: Array[Array] = []
## Rejected intents by failure code (a correct player quotes exactly, so this should stay empty).
var rejected: Dictionary = {}
## Milestone → [sim_us, active_us].
var milestones: Dictionary = {}
var active_us: int = 0
var offline_us: int = 0

var _intent_seq: int = 0
var _armed_plan: String = ""
var _initial_digest: String = ""


## Event and harvest sink kept apart from the player, so the controller's listeners never point
## back at the object that owns the controller (no reference cycle).
class Ledger:
	extends RefCounted

	var gross: int = 0
	var xp: int = 0
	var harvests: Dictionary = {"manual": 0, "automatic": 0}
	var harvested_seed_cost: int = 0
	var harvested_fertilizer_cost: int = 0
	var spend: Dictionary = {"research": 0, "boost": 0, "plots": 0, "equipment": 0, "reset": 0}
	var level_at_us: Dictionary = {}
	var stalls: Dictionary = {}
	var idle_plot_us: int = 0
	var _idle_since: Dictionary = {}  # plot → sim_us it stopped producing

	func start_idle(plot_ids: Array, at_us: int) -> void:
		for id: int in plot_ids:
			_idle_since[id] = at_us

	func close_idle(at_us: int) -> void:
		for id: int in _idle_since:
			idle_plot_us += at_us - (_idle_since[id] as int)
		_idle_since.clear()

	func record(events: Array) -> void:
		for event: SimulationEvent in events:
			match event.type:
				SimulationEvent.CROP_PLANTED:
					if _idle_since.has(event.plot_id):
						idle_plot_us += event.time_us - (_idle_since[event.plot_id] as int)
						_idle_since.erase(event.plot_id)
				SimulationEvent.CROP_MATURED:
					_idle_since[event.plot_id] = event.time_us
				SimulationEvent.PLOT_PURCHASED:
					_idle_since[event.plot_id] = event.time_us
					spend["plots"] += event.data["cost"]
				SimulationEvent.LEVEL_GAINED:
					for level: int in range(event.data["from_level"] + 1, event.data["to_level"] + 1):
						level_at_us[level] = event.time_us
				SimulationEvent.RESEARCH_STARTED:
					spend["research"] += event.data["cost"]
				SimulationEvent.RESEARCH_BOOSTED:
					spend["boost"] += event.data["charge"]
				SimulationEvent.UPGRADE_PURCHASED:
					spend["equipment"] += event.data["cost"]
				SimulationEvent.SKILLS_RESET:
					spend["reset"] += event.data["price"]
				SimulationEvent.PLOT_STALLED:
					stalls[event.data["reason"]] = stalls.get(event.data["reason"], 0) + 1

	func harvest(record: CommittedHarvest) -> void:
		gross += record.gross()
		xp += record.xp()
		harvests[record.origin()] += 1
		harvested_seed_cost += record.seed_cost()
		harvested_fertilizer_cost += record.fertilizer_cost()


## `p_strategy` keys: name, skill_order (Array of [skill ID, target rank]), metric ("coins" | "xp"), reserve_percent,
## fertilizer ("none" | "positive"), buy_plots (bool), equipment (Array of family IDs), boost (bool).
func _init(p_strategy: Dictionary, p_mode: String, state: GameState, epoch: String) -> void:
	strategy = p_strategy
	mode = p_mode
	_initial_digest = state.gameplay_digest()
	controller = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	var errors: PackedStringArray = controller.start(state, epoch)
	assert(errors.is_empty(), str(errors))
	controller.add_commit_listener(ledger.record)
	controller.add_committed_harvest_observer(ledger.harvest)
	var unlocked: Array = []
	for plot: PlotState in state.plots:
		if plot.unlocked and plot.crop_cycle == null:
			unlocked.append(plot.plot_id)
	ledger.start_idle(unlocked, state.simulation_time_us)


func initial_digest() -> String:
	return _initial_digest


## Plays until full basic automation runs on every unlocked plot at level ≥ 7, or `cap_us` of
## simulated time. Returns true when the goal was reached.
func play(cap_us: int) -> bool:
	while controller.now_us() < cap_us:
		if _online(controller.now_us()):
			_act()
			if milestones.has("full_automation"):
				break
			_advance(AccountedInterval.KIND_ACTIVE, POLL_US)
		else:
			_advance(AccountedInterval.KIND_OFFLINE, OFFLINE_US)
	ledger.close_idle(controller.now_us())
	return milestones.has("full_automation")


func _online(now_us: int) -> bool:
	return mode == MODE_ACTIVE or now_us % (ONLINE_US + OFFLINE_US) < ONLINE_US


func _advance(kind: String, real_us: int) -> void:
	var status: String = controller.advance_active(real_us) if kind == AccountedInterval.KIND_ACTIVE \
		else controller.advance_offline(real_us)
	assert(status == CommitSink.COMMITTED, "advance %s" % status)
	if kind == AccountedInterval.KIND_ACTIVE:
		active_us += real_us
	else:
		offline_us += real_us


## Simulated time after `ready_us` at which this player next looks at the farm.
func _next_visit(ready_us: int) -> int:
	var visit: int = ceili(float(ready_us) / POLL_US) * POLL_US
	if mode == MODE_MIXED_OFFLINE and not _online(visit):
		var period: int = ONLINE_US + OFFLINE_US
		visit = (visit / period + 1) * period
	return visit


func _submit(type: String, terms: Dictionary, summary: String) -> CommandResult:
	_intent_seq += 1
	var result: CommandResult = controller.submit_intent(RawIntent.new("%s-%d" % [strategy["name"], _intent_seq], type, terms))
	if result.success:
		decisions.append([controller.now_us(), type, summary])
	else:
		rejected[result.failure_code] = rejected.get(result.failure_code, 0) + 1
	return result


func _mark(name: String) -> void:
	if not milestones.has(name):
		milestones[name] = [controller.now_us(), active_us]


func _act() -> void:
	_harvest_ready()
	_allocate_skills()
	_research()
	_purchases()
	_farm()
	var state: GameState = controller.snapshot()
	if state.player.level >= 7:
		_mark("level_7")


func _harvest_ready() -> void:
	var state: GameState = controller.snapshot()
	var ready: Array = []
	for plot: PlotState in state.plots:
		if plot.crop_cycle != null and plot.crop_cycle.status == CropCycle.STATUS_READY:
			ready.append({"plot_id": plot.plot_id, "cycle_id": plot.crop_cycle.cycle_id.to_primitive()})
	if ready.is_empty():
		return
	if controller.capabilities().has(Capabilities.BATCH_HARVESTING):
		_submit(GameCommand.TYPE_BATCH_HARVEST, {"members": ready}, "harvest %d plots" % ready.size())
		return
	for member: Dictionary in ready:
		_submit(GameCommand.TYPE_HARVEST_CROP, member, "harvest plot %d" % member["plot_id"])


func _allocate_skills() -> void:
	var registry: ContentRegistry = ManifestFixtures.catalog().resolve(controller.snapshot().content_version)
	var progressed: bool = true
	while progressed:
		progressed = false
		var state: GameState = controller.snapshot()
		if state.player.available_skill_points <= 0:
			return
		for entry: Array in strategy["skill_order"]:
			var skill_id: String = entry[0]
			var skill: SkillDefinition = registry.skill(skill_id)
			var rank: int = state.player.skill_ranks.get(skill_id, 0)
			if rank >= mini(entry[1], skill.max_ranks) or state.player.level < skill.min_level:
				continue
			if not skill.prerequisite_id.is_empty() and state.player.skill_ranks.get(skill.prerequisite_id, 0) < 1:
				continue
			if _submit(GameCommand.TYPE_ALLOCATE_SKILL, controller.quote_skill(skill_id), "%s rank %d" % [skill_id, rank + 1]).success:
				if AUTOMATION_NODES.has(skill_id):
					_mark(skill_id)
				progressed = true
			break


## Coins the player keeps back before any non-farming purchase: the strategy reserve plus one full
## round of seeds for the current best crop, so purchases never starve planting.
func _spendable(state: GameState) -> int:
	var best: PlantingQuote = _first_affordable(_ranked_quotes(state, not _armed_plan.is_empty()), -1)
	var float_coins: int = best.seed_cost * state.unlocked_plot_count() if best != null else 0
	var reserve: int = state.player.coins * (strategy["reserve_percent"] as int) / 100
	return state.player.coins - maxi(reserve, float_coins)


func _research() -> void:
	var registry: ContentRegistry = ManifestFixtures.catalog().resolve(controller.snapshot().content_version)
	var state: GameState = controller.snapshot()
	if state.research.active_project_id.is_empty():
		for project_id: String in registry.research_ids():
			var project: ResearchDefinition = registry.research(project_id)
			if state.research.completed.has(project_id) or project.required_level > state.player.level:
				continue
			if project.cost <= _spendable(state):
				_submit(GameCommand.TYPE_START_RESEARCH, controller.quote_research(project_id),
					"research %s (%d)" % [project_id, project.cost])
			break  # research in catalog order; wait for the next affordable one
		return
	if strategy["boost"] and not state.research.boost_used:
		var terms: Dictionary = controller.quote_research_boost()
		if not terms.is_empty() and terms["charge"] <= _spendable(state):
			_submit(GameCommand.TYPE_ACCELERATE_RESEARCH, terms, "boost %s (%d)" % [state.research.active_project_id, terms["charge"]])


func _purchases() -> void:
	var registry: ContentRegistry = ManifestFixtures.catalog().resolve(controller.snapshot().content_version)
	if strategy["buy_plots"]:
		var state: GameState = controller.snapshot()
		var terms: Dictionary = controller.quote_plot_purchase()
		if not terms.is_empty():
			var band: ExpansionBand = registry.expansion_band(terms["plot_id"])
			if band.required_level <= state.player.level and terms["cost"] <= _spendable(state):
				_submit(GameCommand.TYPE_PURCHASE_PLOT, terms, "plot %d (%d)" % [terms["plot_id"], terms["cost"]])
	for family: String in strategy["equipment"]:
		var state: GameState = controller.snapshot()
		var terms: Dictionary = controller.quote_upgrade(family)
		if not terms.is_empty() and terms["cost"] <= _spendable(state):
			_submit(GameCommand.TYPE_PURCHASE_UPGRADE, terms, "%s rank %d (%d)" % [family, terms["target_rank"], terms["cost"]])


## Fertilizer options this strategy considers for `crop_id`.
func _fertilizers() -> PackedStringArray:
	return PackedStringArray(["none", "basic"]) if strategy["fertilizer"] == "positive" else PackedStringArray(["none"])


## Planting quotes for unlocked crops, best first by the strategy metric per effective cycle
## (ties keep catalog order). Without a running loop a crop only pays out when the player next
## visits, so its effective cycle lasts until that visit.
func _ranked_quotes(state: GameState, looping: bool) -> Array[PlantingQuote]:
	var rows: Array[Array] = []
	var registry: ContentRegistry = ManifestFixtures.catalog().resolve(state.content_version)
	for crop_id: String in registry.crop_ids():
		var crop: CropDefinition = registry.crop(crop_id)
		if crop.required_level > state.player.level or not (crop.research_id.is_empty() or state.research.completed.has(crop.research_id)):
			continue
		for fertilizer_id: String in _fertilizers():
			var quote: PlantingQuote = controller.quote_plant(crop_id, fertilizer_id)
			if not quote.ok or (fertilizer_id != "none" and quote.incremental_fertilizer_net() <= 0):
				continue
			var cost: int = quote.seed_cost + quote.fertilizer_cost
			var value: int = quote.xp if strategy["metric"] == "xp" else quote.gross_coins - cost
			var cycle: int = quote.growth_us if looping else _next_visit(state.simulation_time_us + quote.growth_us) - state.simulation_time_us
			rows.append([quote, value, cycle, rows.size()])
	# a/b > c/d compared exactly in integers.
	rows.sort_custom(func(a: Array, b: Array) -> bool:
		var left: int = (a[1] as int) * (b[2] as int)
		var right: int = (b[1] as int) * (a[2] as int)
		return left > right if left != right else a[3] < b[3])
	var quotes: Array[PlantingQuote] = []
	for row: Array in rows:
		quotes.append(row[0])
	return quotes


## First quote in `ranked` costing at most `coins` (any cost when `coins` < 0), or null.
static func _first_affordable(ranked: Array[PlantingQuote], coins: int) -> PlantingQuote:
	for quote: PlantingQuote in ranked:
		if coins < 0 or quote.seed_cost + quote.fertilizer_cost <= coins:
			return quote
	return null


func _farm() -> void:
	var caps: Capabilities = controller.capabilities()
	if caps.has(Capabilities.AUTOMATIC_HARVESTING) and not milestones.has("auto_harvest_on"):
		if _submit(GameCommand.TYPE_CONFIGURE_AUTOMATION, {"plot_id": 0, "field": FarmingSettings.AUTO_HARVEST, "set": true,
				"value": true}, "farm auto-harvest on").success:
			_mark("auto_harvest_on")
	_plant_empty()
	if caps.has(Capabilities.AUTOMATIC_REPLANTING):
		_arm_loops()


## Fills empty plots: the best crop while coins last, then the best free crop.
func _plant_empty() -> void:
	var state: GameState = controller.snapshot()
	var empty: Array[int] = []
	for plot: PlotState in state.plots:
		if plot.unlocked and plot.crop_cycle == null and (_armed_plan.is_empty() or not state.automation.plot(plot.plot_id).authorization.armed):
			empty.append(plot.plot_id)
	if empty.is_empty():
		return
	var coins: int = state.player.coins
	var ranked: Array[PlantingQuote] = _ranked_quotes(state, false)
	var specs: Array[Dictionary] = []
	for plot_id: int in empty:
		var quote: PlantingQuote = _first_affordable(ranked, coins)
		if quote == null:
			break
		coins -= quote.seed_cost + quote.fertilizer_cost
		specs.append({"plot_id": plot_id, "crop_id": quote.crop_id, "fertilizer_id": quote.fertilizer_id})
	if specs.is_empty():
		return
	if controller.capabilities().has(Capabilities.BATCH_PLANTING):
		_submit(GameCommand.TYPE_BATCH_PLANT, {"members": controller.quote_batch_plant(specs)}, "plant %d plots" % specs.size())
		return
	for spec: Dictionary in specs:
		var quote: PlantingQuote = controller.quote_plant_on(spec["plot_id"], spec["crop_id"], spec["fertilizer_id"])
		_submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("", spec["plot_id"], quote).terms,
			"plant plot %d %s+%s" % [spec["plot_id"], spec["crop_id"], spec["fertilizer_id"]])


## Arms (or re-arms after a plan change or a new plot) every unlocked plot with the best looping
## plan. Plots are already occupied, so ApplyAndStart only authorizes the future replant.
func _arm_loops() -> void:
	var state: GameState = controller.snapshot()
	var best: PlantingQuote = _first_affordable(_ranked_quotes(state, true), -1)
	if best == null:
		return
	var plan: String = "%s+%s" % [best.crop_id, best.fertilizer_id]
	var specs: Array[Dictionary] = []
	for plot: PlotState in state.plots:
		if not plot.unlocked:
			continue
		var record: PlotAutomation = state.automation.plot(plot.plot_id)
		var effective: FarmingSettings = SettingsResolver.effective(state, plot.plot_id)
		if plan == _armed_plan and record.authorization.armed and effective.crop_id == best.crop_id:
			continue
		specs.append({"plot_id": plot.plot_id, "crop_id": best.crop_id, "fertilizer_policy": best.fertilizer_id,
			"fallback_accepted": true})
	if specs.is_empty():
		return
	var result: CommandResult = _submit(GameCommand.TYPE_APPLY_AND_START, {"members": controller.quote_apply_and_start(specs)},
		"loop %s on %d plots" % [plan, specs.size()])
	if not result.success:
		return
	_armed_plan = plan
	state = controller.snapshot()
	for plot: PlotState in state.plots:
		if plot.unlocked and not state.automation.plot(plot.plot_id).authorization.armed:
			return
	if state.player.level >= 7 and milestones.has("auto_harvest_on"):
		_mark("full_automation")


## Sim microseconds → hours with two decimals, for reports.
static func hours(us: int) -> String:
	return "%.2f" % (float(us) / HOUR_US)
