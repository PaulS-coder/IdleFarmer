class_name SkillDefinition
extends Resource
## Skill rank/node content (FRS §§5.2–5.4, DEC-004). Data only in M01 (build plan I3): used for
## point-conservation and manifest-binding checks; skill effects and allocation rules are M02.

const POINT_COST_PER_RANK: int = 1

@export var id: String = ""
@export var branch: String = ""
@export var min_level: int = 1
@export var max_ranks: int = 1
## Predecessor skill that must have rank ≥ 1; "" when the skill starts its branch.
@export var prerequisite_id: String = ""
