class_name XpGrant
extends RefCounted
## A prepared XP award: the resulting XP/level/points, computed without mutating the player so the
## caller can apply it atomically with the rest of a batch, or discard it on any failure.

var ok: bool = false
var new_total_xp: int = 0
var old_level: int = 0
var new_level: int = 0
var new_available_points: int = 0


func levels_gained() -> int:
	return new_level - old_level
