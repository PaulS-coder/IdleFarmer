class_name FertilizerDefinition
extends Resource
## A coin-yield fertilizer (FRS §6.2). Price depends only on the crop's unmodified base coins B:
## max(price_floor, ceil(B × price_coef_bp / 10,000)). Exactly one per planting cycle; `none`
## (tier 0) is free and adds nothing.

const NONE_ID: String = "none"

@export var id: String = ""
@export var display_name: String = ""
## Ordering for stable ties and canonical assignments: none = 0, then increasing.
@export var tier: int = 0
@export var coin_bonus_bp: int = 0
@export var price_coef_bp: int = 0
@export var price_floor: int = 0
