class_name EventScheduler
extends RefCounted
## Deterministic binary-heap event queue (M01-T07, TRS §4.2–4.3).
##
## - Pops in ScheduledEvent.precedes order; insertion sequences are unique.
## - Cancellation is lazy (tombstones) and compacted once tombstones outnumber live events,
##   so memory stays bounded by pending logical work, never by history (V08).
## - Pending events are not serialized: `rebuild(state)` reconstructs identical keys from the
##   cycle snapshots (build plan B2).

var _heap: Array[ScheduledEvent] = []
var _live: Dictionary[int, bool] = {}
var _cancelled: Dictionary[int, bool] = {}


## Adds an event. Returns false (and adds nothing) when its insertion sequence is already queued.
func push(event: ScheduledEvent) -> bool:
	if _live.has(event.insertion_seq) or _cancelled.has(event.insertion_seq):
		return false
	_live[event.insertion_seq] = true
	_heap.append(event)
	_sift_up(_heap.size() - 1)
	return true


## Cancels a queued event by insertion sequence. Returns false if it is not pending.
func cancel(insertion_seq: int) -> bool:
	if not _live.has(insertion_seq):
		return false
	_live.erase(insertion_seq)
	_cancelled[insertion_seq] = true
	if _cancelled.size() > _live.size():
		_compact()
	return true


## Number of pending (non-cancelled) events.
func size() -> int:
	return _live.size()


## Heap slots including tombstones; bounded by 2 × size() + 1 after compaction.
func storage_size() -> int:
	return _heap.size()


## Time of the earliest pending event, or -1 when empty.
func peek_time() -> int:
	_drop_cancelled_top()
	return -1 if _heap.is_empty() else _heap[0].time_us


## Removes and returns the earliest pending event, or null when empty.
func pop_next() -> ScheduledEvent:
	_drop_cancelled_top()
	if _heap.is_empty():
		return null
	var top: ScheduledEvent = _heap[0]
	_remove_top()
	_live.erase(top.insertion_seq)
	return top


## Removes and returns every pending event at exactly `time_us`, in key order.
func pop_at(time_us: int) -> Array[ScheduledEvent]:
	var result: Array[ScheduledEvent] = []
	while peek_time() == time_us:
		result.append(pop_next())
	return result


## Pending events in pop order without modifying the queue (inspection and tests).
func pending_in_order() -> Array[ScheduledEvent]:
	var copy: EventScheduler = EventScheduler.new()
	for event: ScheduledEvent in _heap:
		if _live.has(event.insertion_seq):
			copy.push(event)
	var ordered: Array[ScheduledEvent] = []
	var next: ScheduledEvent = copy.pop_next()
	while next != null:
		ordered.append(next)
		next = copy.pop_next()
	return ordered


## Reconstructs the pending queue from authoritative state: one maturity event per growing cycle.
## Research completion events are added here when M02 introduces running research.
static func rebuild(state: GameState) -> EventScheduler:
	var scheduler: EventScheduler = EventScheduler.new()
	for plot: PlotState in state.plots:
		var cycle: CropCycle = plot.crop_cycle
		if cycle != null and cycle.status == CropCycle.STATUS_GROWING:
			scheduler.push(ScheduledEvent.for_maturity(cycle))
	return scheduler


func _drop_cancelled_top() -> void:
	while not _heap.is_empty() and not _live.has(_heap[0].insertion_seq):
		_cancelled.erase(_heap[0].insertion_seq)
		_remove_top()


func _remove_top() -> void:
	var last: ScheduledEvent = _heap.pop_back()
	if not _heap.is_empty():
		_heap[0] = last
		_sift_down(0)


func _compact() -> void:
	var kept: Array[ScheduledEvent] = []
	for event: ScheduledEvent in _heap:
		if _live.has(event.insertion_seq):
			kept.append(event)
	_heap = []
	_cancelled.clear()
	for event: ScheduledEvent in kept:
		_heap.append(event)
		_sift_up(_heap.size() - 1)


func _sift_up(index: int) -> void:
	var i: int = index
	while i > 0:
		var parent: int = (i - 1) / 2
		if not _heap[i].precedes(_heap[parent]):
			return
		var tmp: ScheduledEvent = _heap[i]
		_heap[i] = _heap[parent]
		_heap[parent] = tmp
		i = parent


func _sift_down(index: int) -> void:
	var i: int = index
	var count: int = _heap.size()
	while true:
		var left: int = 2 * i + 1
		var right: int = left + 1
		var smallest: int = i
		if left < count and _heap[left].precedes(_heap[smallest]):
			smallest = left
		if right < count and _heap[right].precedes(_heap[smallest]):
			smallest = right
		if smallest == i:
			return
		var tmp: ScheduledEvent = _heap[i]
		_heap[i] = _heap[smallest]
		_heap[smallest] = tmp
		i = smallest
