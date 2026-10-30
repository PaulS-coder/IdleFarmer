class_name ContentRegistry
extends RefCounted
## Validated, frozen view of one ContentManifest (TRS §§3.4, 20.3; M01-T02/T03).
##
## `build()` copies each definition, validates it fail-fast and expands the XP curve. An invalid
## registry exposes its `errors` and must not be used to create or mutate game state. Getters return
## copies so callers cannot change registered definitions.

const _ID_PATTERN: String = "^[a-z][a-z0-9_]*$"

var errors: PackedStringArray = PackedStringArray()

var _manifest_id: String = ""
var _crop_order: PackedStringArray = PackedStringArray()
var _crops: Dictionary[String, CropDefinition] = {}
var _research: Dictionary[String, ResearchDefinition] = {}
var _skill_order: PackedStringArray = PackedStringArray()
var _skills: Dictionary[String, SkillDefinition] = {}
var _start_unlocked: PackedStringArray = PackedStringArray()
## `_thresholds[i]` = cumulative XP for level i + 1, up to the last int64-representable level.
var _thresholds: PackedInt64Array = PackedInt64Array()
var _explicit_level_count: int = 0


static func build(manifest: ContentManifest) -> ContentRegistry:
	var registry: ContentRegistry = ContentRegistry.new()
	if manifest == null:
		registry.errors.append("MANIFEST_MISSING: no manifest supplied")
		return registry
	registry._load(manifest)
	return registry


func is_valid() -> bool:
	return errors.is_empty()


func manifest_id() -> String:
	return _manifest_id


func crop_ids() -> PackedStringArray:
	return _crop_order.duplicate()


func has_crop(crop_id: String) -> bool:
	return _crops.has(crop_id)


func crop(crop_id: String) -> CropDefinition:
	if not _crops.has(crop_id):
		return null
	return _crops[crop_id].duplicate(true) as CropDefinition


func start_unlocked_crop_ids() -> PackedStringArray:
	return _start_unlocked.duplicate()


func research(research_id: String) -> ResearchDefinition:
	if not _research.has(research_id):
		return null
	return _research[research_id].duplicate(true) as ResearchDefinition


func research_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray(_research.keys())
	ids.sort()
	return ids


func skill_ids() -> PackedStringArray:
	return _skill_order.duplicate()


func skill(skill_id: String) -> SkillDefinition:
	if not _skills.has(skill_id):
		return null
	return _skills[skill_id].duplicate(true) as SkillDefinition


## Sum of all rank/node point costs (one point each, DEC-004).
func total_skill_point_capacity() -> int:
	var total: int = 0
	for skill_id: String in _skill_order:
		total += _skills[skill_id].max_ranks * SkillDefinition.POINT_COST_PER_RANK
	return total


## Highest level whose cumulative threshold is ≤ xp; -1 for negative XP.
func level_for_xp(xp: int) -> int:
	if xp < 0 or _thresholds.is_empty():
		return -1
	var lo: int = 0
	var hi: int = _thresholds.size() - 1
	while lo < hi:
		var mid: int = hi - (hi - lo) / 2
		if _thresholds[mid] <= xp:
			lo = mid
		else:
			hi = mid - 1
	return lo + 1


## Cumulative XP for `level`, or -1 when the level is below 1 or its threshold exceeds int64.
## -1 beyond the representable end is a representation boundary, not a gameplay level cap.
func threshold_for_level(level: int) -> int:
	if level < 1 or level > _thresholds.size():
		return -1
	return _thresholds[level - 1]


## Last level whose threshold fits in int64 (349 for the approved option B curve).
func max_representable_level() -> int:
	return _thresholds.size()


func explicit_level_count() -> int:
	return _explicit_level_count


func _load(manifest: ContentManifest) -> void:
	_manifest_id = manifest.manifest_id
	if _manifest_id.is_empty():
		errors.append("MANIFEST_ID_EMPTY: manifest_id is required")
	_load_curve(manifest.level_curve)
	_load_research(manifest.research)
	_load_crops(manifest.crops)
	_load_start_unlocks(manifest.start_unlocked_crop_ids)
	_load_skills(manifest.skills)
	if not errors.is_empty():
		_crops.clear()
		_research.clear()
		_skills.clear()
		_thresholds = PackedInt64Array()


func _load_curve(curve: LevelCurveDefinition) -> void:
	if curve == null:
		errors.append("CURVE_MISSING: level curve is required")
		return
	var explicit: PackedInt64Array = curve.explicit_thresholds
	if explicit.is_empty() or explicit[0] != 0:
		errors.append("CURVE_LEVEL1_NOT_ZERO: level 1 threshold must be 0")
		return
	for i: int in range(1, explicit.size()):
		if explicit[i] <= explicit[i - 1]:
			errors.append("CURVE_NOT_INCREASING: level %d threshold %d is not above level %d" % [i + 1, explicit[i], i])
			return
	if curve.continuation_first_increment <= 0 or curve.continuation_growth_percent <= 0:
		errors.append("CURVE_CONTINUATION_INVALID: continuation increment and growth must be positive")
		return
	_explicit_level_count = explicit.size()
	var thresholds: PackedInt64Array = explicit.duplicate()
	var increment: int = curve.continuation_first_increment
	while true:
		var next_threshold: MathResult = IntegerMath.add(thresholds[thresholds.size() - 1], increment)
		if not next_threshold.ok:
			break
		thresholds.append(next_threshold.value)
		var next_increment: MathResult = IntegerMath.next_increasing_increment(increment, curve.continuation_growth_percent)
		if not next_increment.ok:
			break
		increment = next_increment.value
	_thresholds = thresholds


func _load_research(items: Array[ResearchDefinition]) -> void:
	for item: ResearchDefinition in items:
		if item == null:
			errors.append("RESEARCH_NULL: null research entry")
			continue
		if not _valid_id(item.id):
			errors.append("RESEARCH_ID_INVALID: '%s'" % item.id)
			continue
		if _research.has(item.id):
			errors.append("RESEARCH_DUPLICATE_ID: '%s'" % item.id)
			continue
		if item.cost < 0:
			errors.append("RESEARCH_NEGATIVE_COST: '%s'" % item.id)
		if item.duration_us <= 0:
			errors.append("RESEARCH_NONPOSITIVE_DURATION: '%s'" % item.id)
		if item.required_level < 1:
			errors.append("RESEARCH_LEVEL_INVALID: '%s'" % item.id)
		_research[item.id] = item.duplicate() as ResearchDefinition


func _load_crops(items: Array[CropDefinition]) -> void:
	if items.is_empty():
		errors.append("CROPS_EMPTY: at least one crop is required")
	for item: CropDefinition in items:
		if item == null:
			errors.append("CROP_NULL: null crop entry")
			continue
		if not _valid_id(item.id):
			errors.append("CROP_ID_INVALID: '%s'" % item.id)
			continue
		if _crops.has(item.id):
			errors.append("CROP_DUPLICATE_ID: '%s'" % item.id)
			continue
		if item.display_name.is_empty():
			errors.append("CROP_NAME_EMPTY: '%s'" % item.id)
		if item.crop_class != CropDefinition.CLASS_BASIC and item.crop_class != CropDefinition.CLASS_ADVANCED:
			errors.append("CROP_CLASS_INVALID: '%s' has class '%s'" % [item.id, item.crop_class])
		if item.base_growth_us <= 0:
			errors.append("CROP_NONPOSITIVE_DURATION: '%s'" % item.id)
		if item.seed_cost < 0 or item.base_coins < 0 or item.base_xp < 0:
			errors.append("CROP_NEGATIVE_VALUE: '%s'" % item.id)
		if item.crop_class == CropDefinition.CLASS_BASIC and item.seed_cost != 0:
			errors.append("CROP_BASIC_SEED_NOT_FREE: '%s'" % item.id)
		if item.required_level < 1 or (not _thresholds.is_empty() and item.required_level > _thresholds.size()):
			errors.append("CROP_LEVEL_GATE_INVALID: '%s' requires level %d" % [item.id, item.required_level])
		if item.stage_art.size() != CropDefinition.STAGE_COUNT:
			errors.append("CROP_STAGE_COUNT: '%s' has %d stage references, expected %d" % [item.id, item.stage_art.size(), CropDefinition.STAGE_COUNT])
		else:
			for ref: String in item.stage_art:
				if ref.is_empty():
					errors.append("CROP_STAGE_REF_EMPTY: '%s'" % item.id)
					break
		if not item.research_id.is_empty():
			if not _research.has(item.research_id):
				errors.append("CROP_RESEARCH_MISSING: '%s' references '%s'" % [item.id, item.research_id])
			elif _research[item.research_id].crop_id != item.id:
				errors.append("CROP_RESEARCH_MISMATCH: '%s' research '%s' unlocks '%s'" % [item.id, item.research_id, _research[item.research_id].crop_id])
		_crops[item.id] = item.duplicate() as CropDefinition
		_crop_order.append(item.id)
	for research_id: String in _research:
		if not _crops.has(_research[research_id].crop_id):
			errors.append("RESEARCH_CROP_MISSING: '%s' unlocks unknown crop '%s'" % [research_id, _research[research_id].crop_id])


func _load_start_unlocks(ids: PackedStringArray) -> void:
	if ids.is_empty():
		errors.append("START_UNLOCKS_EMPTY: at least one start-unlocked crop is required")
	for crop_id: String in ids:
		if not _crops.has(crop_id):
			errors.append("START_UNLOCK_UNKNOWN: '%s'" % crop_id)
		elif not _crops[crop_id].research_id.is_empty():
			errors.append("START_UNLOCK_HAS_RESEARCH: '%s'" % crop_id)
		elif _start_unlocked.has(crop_id):
			errors.append("START_UNLOCK_DUPLICATE: '%s'" % crop_id)
		else:
			_start_unlocked.append(crop_id)
	for crop_id: String in _crop_order:
		if _crops[crop_id].research_id.is_empty() and not _start_unlocked.has(crop_id):
			errors.append("CROP_UNREACHABLE: '%s' has no research and is not start-unlocked" % crop_id)


func _load_skills(items: Array[SkillDefinition]) -> void:
	for item: SkillDefinition in items:
		if item == null:
			errors.append("SKILL_NULL: null skill entry")
			continue
		if not _valid_id(item.id):
			errors.append("SKILL_ID_INVALID: '%s'" % item.id)
			continue
		if _skills.has(item.id):
			errors.append("SKILL_DUPLICATE_ID: '%s'" % item.id)
			continue
		if item.max_ranks < 1 or item.min_level < 1:
			errors.append("SKILL_RANK_OR_LEVEL_INVALID: '%s'" % item.id)
		_skills[item.id] = item.duplicate() as SkillDefinition
		_skill_order.append(item.id)
	for skill_id: String in _skill_order:
		var prerequisite: String = _skills[skill_id].prerequisite_id
		if not prerequisite.is_empty() and not _skills.has(prerequisite):
			errors.append("SKILL_PREREQUISITE_MISSING: '%s' requires '%s'" % [skill_id, prerequisite])
	# Prerequisites form chains; walking more than N steps means a cycle.
	for skill_id: String in _skill_order:
		var current: String = skill_id
		var steps: int = 0
		while not current.is_empty() and _skills.has(current) and steps <= _skill_order.size():
			current = _skills[current].prerequisite_id
			steps += 1
		if steps > _skill_order.size():
			errors.append("SKILL_PREREQUISITE_CYCLE: '%s'" % skill_id)


func _valid_id(value: String) -> bool:
	var regex: RegEx = RegEx.create_from_string(_ID_PATTERN)
	return regex.search(value) != null
