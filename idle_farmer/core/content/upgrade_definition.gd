class_name UpgradeDefinition
extends Resource
## One rank of a permanent equipment family (FRS §6.1, FR-AUD-006). Rank n requires owning rank n−1
## of the same family (rank 1 requires nothing), sufficient coins and `min_level` (1 for v1).
## Effects apply to future plantings only.

const EFFECT_GROWTH_REDUCTION: String = "growth_reduction"
const EFFECT_COIN_BONUS: String = "coin_bonus"

@export var family_id: String = ""
@export var display_name: String = ""
@export var rank: int = 1
@export var cost: int = 0
@export var effect_kind: String = EFFECT_GROWTH_REDUCTION
## Effect of this rank alone, in basis points; owning rank r gives the sum over ranks 1..r.
@export var effect_bp: int = 0
@export var min_level: int = 1
