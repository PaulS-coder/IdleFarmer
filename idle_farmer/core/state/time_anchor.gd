class_name TimeAnchor
extends RefCounted
## Credited-through UTC high-water and bounded accounted-interval summary (TRS §7.2, DEC-013).
## Plain fields only; no OS calls. Durable/clock metadata: excluded from the gameplay digest.

const MAX_INTERVALS: int = 64

var credited_through_utc_us: int = 0
var last_observed_utc_us: int = 0
var anomaly_count: int = 0
var intervals: Array[AccountedInterval] = []


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
