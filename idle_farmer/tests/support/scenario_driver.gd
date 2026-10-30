class_name ScenarioDriver
extends RefCounted
## Runs one scripted farming scenario through a GameController in a chosen time mode, so the same
## accepted inputs at the same simulated times can be compared across 1×, 60×, offline and mixed
## partitions (M01-T14, V06/V08, T-021, AV-001-03). All randomness is seeded.
##
## Script steps: [time_us, action, plot_id, crop_id] with action "plant" or "harvest". Times must be
## multiples of 60 μs so that a 60× mode reaches them exactly.

const MODE_ACTIVE_1X: String = "active_1x"
const MODE_ACTIVE_60X: String = "active_60x"
const MODE_OFFLINE: String = "offline"
const MODE_MIXED: String = "mixed"

var controller: GameController
var sink: FakeCommitSink
var mode: String
var events: Array:
	get:
		return _collector.events
var results: Array[CommandResult] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _intent_seq: int = 0
## Listener target kept separate from the driver: a lambda capturing `self` would form a
## driver → controller → listener → driver reference cycle and leak.
var _collector: EventCollector = EventCollector.new()


class EventCollector:
	extends RefCounted

	var events: Array = []

	func record(batch: Array) -> void:
		for event: SimulationEvent in batch:
			events.append(event.to_primitive())


func _init(state: GameState, epoch: String, p_mode: String, seed: int, catalog: ManifestCatalog = null) -> void:
	mode = p_mode
	_rng.seed = seed
	sink = FakeCommitSink.new()
	controller = GameController.new(catalog if catalog != null else ManifestFixtures.catalog(), sink)
	var errors: PackedStringArray = controller.start(state, epoch)
	assert(errors.is_empty(), str(errors))
	controller.add_commit_listener(_collector.record)


## Runs `script` and finally advances to `final_time_us`.
func run(script: Array[Array], final_time_us: int) -> void:
	for step: Array in script:
		advance_to(step[0])
		var plot_id: int = step[2]
		var intent: RawIntent
		_intent_seq += 1
		var intent_id: String = "intent-%d" % _intent_seq
		if step[1] == "plant":
			intent = RawIntent.plant(intent_id, plot_id, controller.quote_plant(step[3]))
		else:
			var cycle: CropCycle = controller.snapshot().plot(plot_id).crop_cycle
			intent = RawIntent.harvest(intent_id, plot_id, cycle.cycle_id if cycle != null else null)
		results.append(controller.submit_intent(intent))
	advance_to(final_time_us)


## Reaches simulated `target_us` exactly using this driver's partitioning mode.
func advance_to(target_us: int) -> void:
	var gap: int = target_us - controller.now_us()
	assert(gap >= 0, "scenario time went backward")
	if gap == 0:
		return
	match mode:
		MODE_ACTIVE_1X:
			controller.set_speed_multiplier(1)
			for piece: int in _split(gap):
				controller.advance_active(piece)
		MODE_ACTIVE_60X:
			assert(gap % 60 == 0, "60× mode needs gaps divisible by 60")
			controller.set_speed_multiplier(60)
			for piece: int in _split(gap / 60):
				controller.advance_active(piece)
		MODE_OFFLINE:
			controller.advance_offline(gap)
		MODE_MIXED:
			for piece: int in _split(gap):
				match _rng.randi_range(0, 3):
					0:
						controller.set_speed_multiplier(1)
						controller.advance_active(piece)
					1:
						controller.advance_suspended(piece)
					2:
						controller.advance_offline(piece)
					3:
						if piece % 60 == 0:
							controller.set_speed_multiplier(60)
							controller.advance_active(piece / 60)
						else:
							controller.set_speed_multiplier(1)
							controller.advance_active(piece)
	assert(controller.now_us() == target_us, "driver reached %d, wanted %d" % [controller.now_us(), target_us])


func events_digest() -> String:
	return CanonicalCodec.digest(events)


func final_state() -> GameState:
	return controller.snapshot()


## Splits `total` into 1–6 random positive pieces (or one piece when small).
func _split(total: int) -> Array[int]:
	var pieces: Array[int] = []
	var remaining: int = total
	var count: int = _rng.randi_range(1, 6)
	for i: int in count - 1:
		if remaining <= 1:
			break
		var piece: int = 1 + _rng.randi() % remaining
		piece = mini(piece, remaining - 1)
		pieces.append(piece)
		remaining -= piece
	pieces.append(remaining)
	return pieces
