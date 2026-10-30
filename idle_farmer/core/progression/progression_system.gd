class_name ProgressionSystem
extends RefCounted
## Cumulative XP and level awards (M01-T12, FRS §5.1/§5.1.1, DEC-002/004, FR-AUD-003).
## Level is the highest threshold reached under the profile's bound manifest; every crossed level
## grants one unallocated point exactly once. XP is never spent and points are never auto-allocated.


static func get_level_for_xp(registry: ContentRegistry, xp: int) -> int:
	return registry.level_for_xp(xp)


## Prepares adding `xp_delta` (≥ 0). Fails, with nothing to apply, if XP or points would exceed
## int64 (DEC-026). A valid XP total beyond the last representable threshold still resolves to
## the highest representable level; that is a representation boundary, not a level cap.
static func prepare_xp(player: PlayerState, registry: ContentRegistry, xp_delta: int) -> XpGrant:
	var grant: XpGrant = XpGrant.new()
	grant.old_level = player.level
	if xp_delta < 0:
		return grant
	var total: MathResult = IntegerMath.add(player.total_xp, xp_delta)
	if not total.ok:
		return grant
	var level: int = registry.level_for_xp(total.value)
	if level < player.level:
		return grant
	var points: MathResult = IntegerMath.add(player.available_skill_points, level - player.level)
	if not points.ok:
		return grant
	grant.new_total_xp = total.value
	grant.new_level = level
	grant.new_available_points = points.value
	grant.ok = true
	return grant


static func apply(player: PlayerState, grant: XpGrant) -> void:
	player.total_xp = grant.new_total_xp
	player.level = grant.new_level
	player.available_skill_points = grant.new_available_points
