class_name EconomyParameters
extends Resource
## Manifest-bound economy constants (M02 build plan §3.1): growth cap, reset price and budget
## defaults. All values are provisional balance data (FRS §§5.2, 5.5, 7.1).

## Used for manifests that predate this table (content_m01_v1): M01's code constant.
const LEGACY_GROWTH_CAP_BP: int = 6_000

@export var growth_cap_bp: int = LEGACY_GROWTH_CAP_BP
## Reset price = max(reset_minimum, reset_level_factor × level²).
@export var reset_minimum: int = 250
@export var reset_level_factor: int = 50
@export var budget_reserve_default: int = 0
@export var budget_protection_percent_default: int = 25
@export var budget_seed_protection_default: bool = false
