class_name ExtensionState
extends RefCounted
## Minimal, inert typed records reserved for later systems (M01-T05, build plan §4 stubs).
## Each validates, round-trips through primitives and deep-copies like the rest of GameState, so
## M02/M03/M05 extend them through migrations instead of replacing the kernel. No behavior here.


## Purchased permanent upgrade ranks (M02).
class Upgrades:
	extends RefCounted

	var ranks: Dictionary[String, int] = {}

	func validate() -> PackedStringArray:
		var errors: PackedStringArray = PackedStringArray()
		for upgrade_id: String in ranks:
			if ranks[upgrade_id] < 0:
				errors.append("UPGRADE_RANK_NEGATIVE: '%s'" % upgrade_id)
		return errors

	func to_primitive() -> Dictionary:
		return {"ranks": PrimitiveReader.plain(ranks)}

	static func from_primitive(value: Variant) -> Upgrades:
		var reader: PrimitiveReader = PrimitiveReader.new(value, "Upgrades")
		reader.expect_only(PackedStringArray(["ranks"]))
		var record: Upgrades = Upgrades.new()
		record.ranks = reader.int_map_field("ranks")
		return record if reader.ok() else null


## Contract offers/instances/claims (DEC-019/C2; behavior is M05). Instances are primitive records.
class Contracts:
	extends RefCounted

	var instances: Array[Dictionary] = []
	var claimed_offer_ids: PackedStringArray = PackedStringArray()

	func validate() -> PackedStringArray:
		return PackedStringArray()

	func to_primitive() -> Dictionary:
		return {"instances": PrimitiveReader.plain(instances), "claimed_offer_ids": Array(claimed_offer_ids)}

	static func from_primitive(value: Variant) -> Contracts:
		var reader: PrimitiveReader = PrimitiveReader.new(value, "Contracts")
		reader.expect_only(PackedStringArray(["instances", "claimed_offer_ids"]))
		var record: Contracts = Contracts.new()
		for item: Variant in reader.array_field("instances"):
			if typeof(item) != TYPE_DICTIONARY:
				reader.absorb(PackedStringArray(["Contracts: instance must be a dictionary"]))
				continue
			record.instances.append((item as Dictionary).duplicate(true))
		record.claimed_offer_ids = reader.string_array_field("claimed_offer_ids")
		return record if reader.ok() else null


## Statistics buckets and accounting segments (DEC-017/018; behavior is M05).
class Statistics:
	extends RefCounted

	var buckets: Array[Dictionary] = []
	var segments: Array[Dictionary] = []
	var lifetime: Dictionary[String, int] = {}

	func validate() -> PackedStringArray:
		return PackedStringArray()

	func to_primitive() -> Dictionary:
		return {"buckets": PrimitiveReader.plain(buckets), "segments": PrimitiveReader.plain(segments), "lifetime": PrimitiveReader.plain(lifetime)}

	static func from_primitive(value: Variant) -> Statistics:
		var reader: PrimitiveReader = PrimitiveReader.new(value, "Statistics")
		reader.expect_only(PackedStringArray(["buckets", "segments", "lifetime"]))
		var record: Statistics = Statistics.new()
		for key: String in ["buckets", "segments"]:
			for item: Variant in reader.array_field(key):
				if typeof(item) != TYPE_DICTIONARY:
					reader.absorb(PackedStringArray(["Statistics: %s entries must be dictionaries" % key]))
					continue
				var target: Array[Dictionary] = record.buckets if key == "buckets" else record.segments
				target.append((item as Dictionary).duplicate(true))
		record.lifetime = reader.int_map_field("lifetime")
		return record if reader.ok() else null
