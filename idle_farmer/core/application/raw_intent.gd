class_name RawIntent
extends RefCounted
## An unaccepted player intent (TRS §20.4): a command type, the confirmation terms the player saw,
## and a stable pending-delivery `intent_id`. It carries no authoritative time and is never
## replayed; the controller turns it into an immutable accepted command at the current simulation
## time through CommandFactory. Terms use the same keys as the command's recorded args.

var intent_id: String = ""
var type: String = ""
var terms: Dictionary = {}


func _init(p_intent_id: String = "", p_type: String = "", p_terms: Dictionary = {}) -> void:
	intent_id = p_intent_id
	type = p_type
	terms = p_terms.duplicate(true)


static func plant(p_intent_id: String, plot_id: int, quote: PlantingQuote) -> RawIntent:
	return RawIntent.new(p_intent_id, GameCommand.TYPE_PLANT_CROP, {
		"plot_id": plot_id,
		"crop_id": quote.crop_id,
		"manifest_id": quote.manifest_id,
		"seed_cost": quote.seed_cost,
		"growth_us": quote.growth_us,
		"gross_coins": quote.gross_coins,
		"xp": quote.xp,
		"fertilizer_id": quote.fertilizer_id,
		"fertilizer_cost": quote.fertilizer_cost,
		"fallback_accepted": quote.fallback_accepted,
		"plan_digest": quote.plan_digest,
		"min_ending_balance": quote.min_ending_balance,
	})


static func harvest(p_intent_id: String, plot_id: int, cycle_id: EntityId) -> RawIntent:
	return RawIntent.new(p_intent_id, GameCommand.TYPE_HARVEST_CROP, {
		"plot_id": plot_id,
		"cycle_id": EntityId.nullable_to_primitive(cycle_id),
	})


## Accepted envelope for this intent, stamped by the controller. Null for an unknown type or
## malformed terms.
func to_command(id: CommandId, accepted_time_us: int, accepted_order: int) -> GameCommand:
	return CommandFactory.build(type, id, accepted_time_us, accepted_order, terms)
