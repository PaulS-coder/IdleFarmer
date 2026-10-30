class_name PlayerState
extends RefCounted
## Player progression and wallet (TRS §3.2). Level is derived from cumulative XP under the
## profile's bound manifest; earned points (level − 1) = unspent + allocated ranks (FR-AUD-003).
## `skill_ranks` is data only in M01 (build plan I3); allocation behavior is M02.

var player_id: String = ""
var level: int = 1
var total_xp: int = 0
var coins: int = 0
var available_skill_points: int = 0
var skill_ranks: Dictionary[String, int] = {}


## Sum of allocated rank points, or -1 if malformed ranks are negative or overflow.
func allocated_skill_points() -> int:
	var total: int = 0
	for skill_id: String in skill_ranks:
		var points: MathResult = IntegerMath.mul(skill_ranks[skill_id], SkillDefinition.POINT_COST_PER_RANK)
		var sum: MathResult = IntegerMath.add(total, points.value) if points.ok else points
		if not sum.ok or skill_ranks[skill_id] < 0:
			return -1
		total = sum.value
	return total


## Validates wallet/XP/level/point invariants against the bound manifest's registry.
func validate(registry: ContentRegistry) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if player_id.is_empty():
		errors.append("PLAYER_ID_EMPTY: player_id is required")
	if coins < 0 or total_xp < 0 or available_skill_points < 0:
		errors.append("PLAYER_NEGATIVE: coins/XP/points must be nonnegative")
		return errors
	var derived_level: int = registry.level_for_xp(total_xp)
	if derived_level != level:
		errors.append("PLAYER_LEVEL_MISMATCH: level %d but XP %d gives %d" % [level, total_xp, derived_level])
	for skill_id: String in skill_ranks:
		var definition: SkillDefinition = registry.skill(skill_id)
		var rank: int = skill_ranks[skill_id]
		if definition == null:
			errors.append("SKILL_UNKNOWN: '%s'" % skill_id)
			continue
		if rank < 1 or rank > definition.max_ranks:
			errors.append("SKILL_RANK_RANGE: '%s' rank %d (max %d)" % [skill_id, rank, definition.max_ranks])
		if level < definition.min_level:
			errors.append("SKILL_LEVEL_GATE: '%s' needs level %d" % [skill_id, definition.min_level])
		if not definition.prerequisite_id.is_empty() and skill_ranks.get(definition.prerequisite_id, 0) < 1:
			errors.append("SKILL_PREREQUISITE_UNMET: '%s' needs '%s'" % [skill_id, definition.prerequisite_id])
	var earned: int = level - 1
	var accounted: int = available_skill_points + allocated_skill_points()
	if accounted != earned:
		errors.append("SKILL_POINTS_NOT_CONSERVED: level−1 = %d but unspent + allocated = %d" % [earned, accounted])
	return errors


func to_primitive() -> Dictionary:
	return {
		"player_id": player_id,
		"level": level,
		"total_xp": total_xp,
		"coins": coins,
		"available_skill_points": available_skill_points,
		"skill_ranks": PrimitiveReader.plain(skill_ranks),
	}


static func from_primitive(value: Variant) -> PlayerState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "PlayerState")
	reader.expect_only(PackedStringArray(["player_id", "level", "total_xp", "coins", "available_skill_points", "skill_ranks"]))
	var player: PlayerState = PlayerState.new()
	player.player_id = reader.string_field("player_id")
	player.level = reader.int_field("level")
	player.total_xp = reader.int_field("total_xp")
	player.coins = reader.int_field("coins")
	player.available_skill_points = reader.int_field("available_skill_points")
	player.skill_ranks = reader.int_map_field("skill_ranks")
	return player if reader.ok() else null
