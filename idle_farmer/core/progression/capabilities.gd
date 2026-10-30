class_name Capabilities
extends RefCounted
## Abilities currently owned, derived from allocated skill ranks under the profile's manifest
## (M02 E12). Never stored: a reset that refunds a node removes its capability immediately, and
## re-buying it restores the capability without re-arming anything (E11).

const BATCH_PLANTING: String = "batch_planting"
const BATCH_HARVESTING: String = "batch_harvesting"
const AUTOMATIC_HARVESTING: String = "automatic_harvesting"
const AUTOMATIC_REPLANTING: String = "automatic_replanting"
const SMART_FERTILIZER: String = "smart_fertilizer"
const FARM_PRESETS: String = "farm_presets"
const ENHANCED_BUDGET: String = "enhanced_budget_management"
const CROP_ROTATION: String = "crop_rotation"

var _owned: Dictionary[String, bool] = {}


static func of(state: GameState, registry: ContentRegistry) -> Capabilities:
	var caps: Capabilities = Capabilities.new()
	for skill_id: String in state.player.skill_ranks:
		var skill: SkillDefinition = registry.skill(skill_id)
		if skill != null and skill.effect_kind == SkillDefinition.EFFECT_CAPABILITY and state.player.skill_ranks[skill_id] >= 1:
			caps._owned[skill.capability_id] = true
	return caps


func has(capability_id: String) -> bool:
	return _owned.has(capability_id)


func owned() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray(_owned.keys())
	ids.sort()
	return ids
