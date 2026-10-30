class_name LevelCurveDefinition
extends Resource
## Cumulative XP curve source (FRS §5.1 table, §5.1.1 option B continuation, DEC-002/C1).
## `explicit_thresholds[i]` is the cumulative XP needed for level i + 1, so index 0 must be 0.
## After the explicit table, I(next) = first increment, then I(L) = I(L−1) + ceil(I(L−1) × percent / 100),
## each rounded per step. ContentRegistry expands this until the next threshold exceeds int64.

@export var explicit_thresholds: PackedInt64Array = PackedInt64Array()
@export var continuation_first_increment: int = 0
@export var continuation_growth_percent: int = 0
