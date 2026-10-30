class_name CommandFactory
extends RefCounted
## The single place that maps a command type to its typed class (M02 build plan E17). Both replay
## decoding (`GameCommand.from_primitive`) and intent acceptance (`RawIntent.to_command`) go
## through `build`, so adding a command type means adding one line here.


## Typed accepted command for `type` from its terms/args, or null for an unknown type or
## malformed terms.
static func build(type: String, id: CommandId, accepted_time_us: int, accepted_order: int, terms: Dictionary) -> GameCommand:
	match type:
		GameCommand.TYPE_PLANT_CROP:
			return PlantCropCommand.from_args(id, accepted_time_us, accepted_order, terms)
		GameCommand.TYPE_HARVEST_CROP:
			return HarvestCropCommand.from_args(id, accepted_time_us, accepted_order, terms)
		GameCommand.TYPE_PURCHASE_PLOT:
			return PurchasePlotCommand.from_args(id, accepted_time_us, accepted_order, terms)
		GameCommand.TYPE_ALLOCATE_SKILL:
			return AllocateSkillCommand.from_args(id, accepted_time_us, accepted_order, terms)
		GameCommand.TYPE_RESET_SKILLS:
			return ResetSkillsCommand.from_args(id, accepted_time_us, accepted_order, terms)
		GameCommand.TYPE_PURCHASE_UPGRADE:
			return PurchaseUpgradeCommand.from_args(id, accepted_time_us, accepted_order, terms)
	return null


static func is_known(type: String) -> bool:
	return type in [GameCommand.TYPE_PLANT_CROP, GameCommand.TYPE_HARVEST_CROP, GameCommand.TYPE_PURCHASE_PLOT,
		GameCommand.TYPE_ALLOCATE_SKILL, GameCommand.TYPE_RESET_SKILLS, GameCommand.TYPE_PURCHASE_UPGRADE]
