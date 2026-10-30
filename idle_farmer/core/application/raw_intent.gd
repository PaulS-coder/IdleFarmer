class_name RawIntent
extends RefCounted
## An unaccepted player intent (TRS §20.4): target plus the confirmation terms the player saw, and
## a stable pending-delivery `intent_id`. It carries no authoritative time and is never replayed;
## the controller turns it into an immutable accepted GameCommand at the current simulation time.

var intent_id: String = ""
var type: String = ""
var plot_id: int = 0
## PlantCrop confirmation terms (from a PlantingQuote).
var crop_id: String = ""
var manifest_id: String = ""
var seed_cost: int = 0
var growth_us: int = 0
var gross_coins: int = 0
var xp: int = 0
## HarvestCrop confirmation term.
var cycle_id: EntityId = null


static func plant(p_intent_id: String, p_plot_id: int, quote: PlantingQuote) -> RawIntent:
	var intent: RawIntent = RawIntent.new()
	intent.intent_id = p_intent_id
	intent.type = GameCommand.TYPE_PLANT_CROP
	intent.plot_id = p_plot_id
	intent.crop_id = quote.crop_id
	intent.manifest_id = quote.manifest_id
	intent.seed_cost = quote.seed_cost
	intent.growth_us = quote.growth_us
	intent.gross_coins = quote.gross_coins
	intent.xp = quote.xp
	return intent


static func harvest(p_intent_id: String, p_plot_id: int, p_cycle_id: EntityId) -> RawIntent:
	var intent: RawIntent = RawIntent.new()
	intent.intent_id = p_intent_id
	intent.type = GameCommand.TYPE_HARVEST_CROP
	intent.plot_id = p_plot_id
	intent.cycle_id = p_cycle_id
	return intent


## Accepted envelope for this intent, stamped by the controller. Null for an unknown type.
func to_command(id: CommandId, accepted_time_us: int, accepted_order: int) -> GameCommand:
	match type:
		GameCommand.TYPE_PLANT_CROP:
			return PlantCropCommand.new(id, accepted_time_us, accepted_order, plot_id, crop_id, manifest_id,
				seed_cost, growth_us, gross_coins, xp)
		GameCommand.TYPE_HARVEST_CROP:
			return HarvestCropCommand.new(id, accepted_time_us, accepted_order, plot_id, cycle_id)
	return null
