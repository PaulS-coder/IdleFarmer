class_name EconomicTransaction
extends RefCounted
## Immutable record of one coin/XP movement (TRS §3.5). Fields are private and set once.
## `cycle_id` is null for movements not tied to a crop cycle (research, upgrades, plots, reset —
## M02). `origin` records whether the player, automation or the system caused it (M02 E13).

const TYPE_SEED_PURCHASE: String = "seed_purchase"
const TYPE_HARVEST_CREDIT: String = "harvest_credit"
const TYPE_FERTILIZER_PURCHASE: String = "fertilizer_purchase"
const TYPE_PLOT_PURCHASE: String = "plot_purchase"
const TYPE_UPGRADE_PURCHASE: String = "upgrade_purchase"
const TYPE_SKILL_RESET: String = "skill_reset"
const TYPE_RESEARCH_PURCHASE: String = "research_purchase"
const TYPE_RESEARCH_BOOST: String = "research_boost"

const CATEGORY_SEEDS: String = "seeds"
const CATEGORY_HARVEST: String = "harvest"
const CATEGORY_FERTILIZER: String = "fertilizer"
const CATEGORY_EXPANSION: String = "expansion"
const CATEGORY_EQUIPMENT: String = "equipment"
const CATEGORY_RESET: String = "reset"
const CATEGORY_RESEARCH: String = "research"

const ORIGIN_MANUAL: String = "manual"
const ORIGIN_AUTOMATIC: String = "automatic"
const ORIGIN_SYSTEM: String = "system"
const ORIGINS: PackedStringArray = ["manual", "automatic", "system"]

var _transaction_id: EntityId
var _time_us: int
var _type: String
var _plot_id: int
var _cycle_id: EntityId
var _coin_delta: int
var _xp_delta: int
var _category: String
var _content_version: String
var _origin: String


func _init(p_transaction_id: EntityId, p_time_us: int, p_type: String, p_plot_id: int, p_cycle_id: EntityId,
		p_coin_delta: int, p_xp_delta: int, p_category: String, p_content_version: String, p_origin: String) -> void:
	_transaction_id = p_transaction_id
	_time_us = p_time_us
	_type = p_type
	_plot_id = p_plot_id
	_cycle_id = p_cycle_id
	_coin_delta = p_coin_delta
	_xp_delta = p_xp_delta
	_category = p_category
	_content_version = p_content_version
	_origin = p_origin


func transaction_id() -> EntityId:
	return _transaction_id


func time_us() -> int:
	return _time_us


func type() -> String:
	return _type


func plot_id() -> int:
	return _plot_id


func cycle_id() -> EntityId:
	return _cycle_id


func coin_delta() -> int:
	return _coin_delta


func xp_delta() -> int:
	return _xp_delta


func category() -> String:
	return _category


func content_version() -> String:
	return _content_version


func origin() -> String:
	return _origin


func to_primitive() -> Dictionary:
	return {
		"transaction_id": EntityId.nullable_to_primitive(_transaction_id),
		"time_us": _time_us,
		"type": _type,
		"plot_id": _plot_id,
		"cycle_id": EntityId.nullable_to_primitive(_cycle_id),
		"coin_delta": _coin_delta,
		"xp_delta": _xp_delta,
		"category": _category,
		"content_version": _content_version,
		"origin": _origin,
	}


static func from_primitive(value: Variant) -> EconomicTransaction:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "EconomicTransaction")
	reader.expect_only(PackedStringArray(["transaction_id", "time_us", "type", "plot_id", "cycle_id", "coin_delta",
		"xp_delta", "category", "content_version", "origin"]))
	var id: EntityId = EntityId.from_primitive(reader.dict_field("transaction_id"))
	var cycle_value: Variant = reader.nullable_field("cycle_id")
	var cycle: EntityId = null if cycle_value == null else EntityId.from_primitive(cycle_value)
	var origin_value: String = reader.string_field("origin")
	var tx: EconomicTransaction = EconomicTransaction.new(id, reader.int_field("time_us"), reader.string_field("type"),
		reader.int_field("plot_id"), cycle, reader.int_field("coin_delta"), reader.int_field("xp_delta"),
		reader.string_field("category"), reader.string_field("content_version"), origin_value)
	if not reader.ok() or id == null or (cycle_value != null and cycle == null) or not ORIGINS.has(origin_value):
		return null
	return tx
