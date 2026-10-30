class_name LevelCurveV1
extends RefCounted
## Provisional cumulative XP table for levels 1–30 (FRS §5.1, DEC-002) and the approved option B
## continuation (FRS §5.1.1, C1): I(31) = 57,500, then I(L) = I(L−1) + ceil(I(L−1) × 10 / 100).

const THRESHOLDS: Array[int] = [
	0, 240, 650, 1300, 2300, 3600, 5200, 7300, 10000, 13500,
	18000, 24000, 29334, 34667, 40000, 50000, 60000, 70000, 88750, 107500,
	126250, 145000, 181250, 217500, 253750, 290000, 347500, 405000, 462500, 520000,
]

const CONTINUATION_FIRST_INCREMENT: int = 57_500
const CONTINUATION_GROWTH_PERCENT: int = 10
