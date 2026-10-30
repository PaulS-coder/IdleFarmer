class_name CropDefinition
extends Resource
## Versioned crop content (FRS §4.1–4.2, TRS §3.4). Built and frozen by ContentRegistry;
## callers receive copies, so a mutated copy never changes registered content.

const CLASS_BASIC: String = "basic"
const CLASS_ADVANCED: String = "advanced"
const STAGE_COUNT: int = 5

@export var id: String = ""
@export var display_name: String = ""
@export var crop_class: String = CLASS_BASIC
@export var required_level: int = 1
## Research project that unlocks this crop; "" only for start-unlocked crops.
@export var research_id: String = ""
@export var seed_cost: int = 0
@export var base_growth_us: int = 0
@export var base_coins: int = 0
@export var base_xp: int = 0
## Exactly five stage visual references (placeholders until M04).
@export var stage_art: PackedStringArray = PackedStringArray()
@export var animation_config: String = ""
