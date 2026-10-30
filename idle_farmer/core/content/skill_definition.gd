class_name SkillDefinition
extends Resource
## Skill rank/node content (FRS §§5.2–5.4, DEC-004). Effects were added in content_m02_v1; a skill
## with an empty `effect_kind` (content_m01_v1) has no effect.

const POINT_COST_PER_RANK: int = 1

const EFFECT_NONE: String = ""
const EFFECT_GROWTH_REDUCTION: String = "growth_reduction"
const EFFECT_COIN_BONUS: String = "coin_bonus"
const EFFECT_CAPABILITY: String = "capability"
const EFFECT_KINDS: PackedStringArray = ["", "growth_reduction", "coin_bonus", "capability"]

@export var id: String = ""
@export var branch: String = ""
@export var min_level: int = 1
@export var max_ranks: int = 1
## Predecessor skill that must have rank ≥ 1; "" when the skill starts its branch.
@export var prerequisite_id: String = ""
@export var effect_kind: String = EFFECT_NONE
## Growth reduction or coin bonus per rank, in basis points.
@export var effect_bp_per_rank: int = 0
## Capability granted while ranked (automation nodes); equals the skill ID by convention.
@export var capability_id: String = ""
