class_name TimeAnchor
extends RefCounted
## Credited-through UTC high-water and bounded accounted-interval summary (TRS §7.2, DEC-013).
## Plain fields only; no OS calls. Durable/clock metadata: excluded from the gameplay digest.

const MAX_INTERVALS: int = 64

var credited_through_utc_us: int = 0
var last_observed_utc_us: int = 0
var anomaly_count: int = 0
var intervals: Array[AccountedInterval] = []


## Credits an accounted interval: the anchor advances by real elapsed time only (never by
## debug-scaled time or by an observed UTC value). Oldest summaries are compacted past the bound.
## Returns false, changing nothing, if the anchor would overflow.
func credit(interval: AccountedInterval) -> bool:
	if interval == null or not interval.validate().is_empty():
		return false
	var next: MathResult = IntegerMath.add(credited_through_utc_us, interval.real_us)
	if not next.ok:
		return false
	credited_through_utc_us = next.value
	intervals.append(interval)
	while intervals.size() > MAX_INTERVALS:
		intervals.pop_front()
	return true


## Records a wall-clock observation for diagnostics. A UTC value behind the anchor counts as an
## anomaly; the anchor itself never moves backward and is never set from observed UTC.
func observe_utc(utc_us: int) -> void:
	if utc_us < credited_through_utc_us:
		anomaly_count += 1
	last_observed_utc_us = maxi(0, utc_us)


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if credited_through_utc_us < 0 or last_observed_utc_us < 0 or anomaly_count < 0:
		errors.append("ANCHOR_NEGATIVE: anchor fields must be nonnegative")
	if intervals.size() > MAX_INTERVALS:
		errors.append("ANCHOR_INTERVALS_UNBOUNDED: %d > %d" % [intervals.size(), MAX_INTERVALS])
	for interval: AccountedInterval in intervals:
		errors.append_array(interval.validate())
	return errors


func to_primitive() -> Dictionary:
	var items: Array = []
	for interval: AccountedInterval in intervals:
		items.append(interval.to_primitive())
	return {
		"credited_through_utc_us": credited_through_utc_us,
		"last_observed_utc_us": last_observed_utc_us,
		"anomaly_count": anomaly_count,
		"intervals": items,
	}


static func from_primitive(value: Variant) -> TimeAnchor:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "TimeAnchor")
	reader.expect_only(PackedStringArray(["credited_through_utc_us", "last_observed_utc_us", "anomaly_count", "intervals"]))
	var anchor: TimeAnchor = TimeAnchor.new()
	anchor.credited_through_utc_us = reader.int_field("credited_through_utc_us")
	anchor.last_observed_utc_us = reader.int_field("last_observed_utc_us")
	anchor.anomaly_count = reader.int_field("anomaly_count")
	for item: Variant in reader.array_field("intervals"):
		var interval: AccountedInterval = AccountedInterval.from_primitive(item)
		if interval == null:
			reader.absorb(PackedStringArray(["TimeAnchor: malformed interval"]))
			continue
		anchor.intervals.append(interval)
	if not reader.ok():
		return null
	return anchor
