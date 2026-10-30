class_name ContentRegistry
extends RefCounted
## Validated, frozen view of one ContentManifest (TRS §§3.4, 20.3; M01-T02/T03).
##
## `build()` copies each definition, validates it fail-fast and expands the XP curve. An invalid
## registry exposes its `errors` and must not be used to create or mutate game state. Getters return
## copies so callers cannot change registered definitions.

const _ID_PATTERN: String = "^[a-z][a-z0-9_]*$"
## DEC-008/G5: families deferred beyond v1 must never appear as saleable content.
const DEFERRED_CONTENT_IDS: PackedStringArray = ["seed_efficiency", "research_facilities", "growth_booster"]

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
# M02 tables (empty / null for content_m01_v1).
var _upgrade_order: PackedStringArray = PackedStringArray()
var _upgrades: Dictionary[String, Array] = {}  # family → Array[UpgradeDefinition] ordered by rank
var _fertilizer_order: PackedStringArray = PackedStringArray()  # by tier
var _fertilizers: Dictionary[String, FertilizerDefinition] = {}
var _bands: Array[ExpansionBand] = []
var _economy: EconomyParameters = null


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


## True for manifests that carry the M02 economy tables (content_m02_v1 and later).
func has_economy_tables() -> bool:
	return _economy != null


func growth_cap_bp() -> int:
	return _economy.growth_cap_bp if _economy != null else EconomyParameters.LEGACY_GROWTH_CAP_BP


## Copy of the economy parameters, or null for manifests without them.
func economy() -> EconomyParameters:
	return null if _economy == null else _economy.duplicate() as EconomyParameters


func upgrade_family_ids() -> PackedStringArray:
	return _upgrade_order.duplicate()


func upgrade_max_rank(family_id: String) -> int:
	return (_upgrades[family_id] as Array).size() if _upgrades.has(family_id) else 0


## Copy of rank `rank` of `family_id`, or null.
func upgrade(family_id: String, rank: int) -> UpgradeDefinition:
	if not _upgrades.has(family_id) or rank < 1 or rank > (_upgrades[family_id] as Array).size():
		return null
	return ((_upgrades[family_id] as Array)[rank - 1] as UpgradeDefinition).duplicate() as UpgradeDefinition


## Fertilizer IDs ordered by tier. `none` is always available, even without a fertilizer table.
func fertilizer_ids() -> PackedStringArray:
	if _fertilizer_order.is_empty():
		return PackedStringArray([FertilizerDefinition.NONE_ID])
	return _fertilizer_order.duplicate()


## Copy of the fertilizer, the implicit `none` when the manifest has no table, or null if unknown.
func fertilizer(fertilizer_id: String) -> FertilizerDefinition:
	if _fertilizers.has(fertilizer_id):
		return _fertilizers[fertilizer_id].duplicate() as FertilizerDefinition
	if fertilizer_id == FertilizerDefinition.NONE_ID and _fertilizers.is_empty():
		var none: FertilizerDefinition = FertilizerDefinition.new()
		none.id = FertilizerDefinition.NONE_ID
		none.display_name = "None"
		return none
	return null


## Copy of the band containing `plot_id`, or null (plots 1–24, or manifests without bands).
func expansion_band(plot_id: int) -> ExpansionBand:
	for band: ExpansionBand in _bands:
		if plot_id >= band.first_plot and plot_id <= band.last_plot:
			return band.duplicate() as ExpansionBand
	return null


func _load(manifest: ContentManifest) -> void:
	_manifest_id = manifest.manifest_id
	if _manifest_id.is_empty():
		errors.append("MANIFEST_ID_EMPTY: manifest_id is required")
	_load_curve(manifest.level_curve)
	_load_research(manifest.research)
	_load_crops(manifest.crops)
	_load_start_unlocks(manifest.start_unlocked_crop_ids)
	_load_skills(manifest.skills)
	_load_economy_tables(manifest)
	if not errors.is_empty():
		_crops.clear()
		_research.clear()
		_skills.clear()
		_thresholds = PackedInt64Array()
		_upgrades.clear()
		_upgrade_order = PackedStringArray()
		_fertilizers.clear()
		_fertilizer_order = PackedStringArray()
		_bands.clear()
		_economy = null


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


func _load_economy_tables(manifest: ContentManifest) -> void:
	for skill_id: String in _skill_order:
		var skill: SkillDefinition = _skills[skill_id]
		if not SkillDefinition.EFFECT_KINDS.has(skill.effect_kind):
			errors.append("SKILL_EFFECT_INVALID: '%s' has effect '%s'" % [skill_id, skill.effect_kind])
		elif skill.effect_bp_per_rank < 0:
			errors.append("SKILL_EFFECT_NEGATIVE: '%s'" % skill_id)
		elif skill.effect_kind == SkillDefinition.EFFECT_CAPABILITY and skill.capability_id.is_empty():
			errors.append("SKILL_CAPABILITY_MISSING: '%s'" % skill_id)
		elif skill.effect_kind != SkillDefinition.EFFECT_CAPABILITY and not skill.capability_id.is_empty():
			errors.append("SKILL_CAPABILITY_UNEXPECTED: '%s'" % skill_id)
	var present: Array[bool] = [not manifest.upgrades.is_empty(), not manifest.fertilizers.is_empty(),
		not manifest.expansion_bands.is_empty(), manifest.economy != null]
	if not present.has(true):
		return
	if present.has(false):
		errors.append("ECONOMY_TABLES_INCOMPLETE: upgrades, fertilizers, expansion bands and economy must be supplied together")
		return
	_load_upgrades(manifest.upgrades)
	_load_fertilizers(manifest.fertilizers)
	_load_bands(manifest.expansion_bands)
	_load_economy(manifest.economy)


func _load_upgrades(items: Array[UpgradeDefinition]) -> void:
	var by_family: Dictionary[String, Array] = {}
	for item: UpgradeDefinition in items:
		if item == null or not _valid_id(item.family_id):
			errors.append("UPGRADE_ID_INVALID: '%s'" % ("" if item == null else item.family_id))
			continue
		if DEFERRED_CONTENT_IDS.has(item.family_id):
			errors.append("DEFERRED_CONTENT: '%s' is deferred beyond v1 (DEC-008)" % item.family_id)
			continue
		if item.cost <= 0 or item.effect_bp < 0 or item.min_level < 1:
			errors.append("UPGRADE_VALUE_INVALID: '%s' rank %d" % [item.family_id, item.rank])
		if item.effect_kind != UpgradeDefinition.EFFECT_GROWTH_REDUCTION and item.effect_kind != UpgradeDefinition.EFFECT_COIN_BONUS:
			errors.append("UPGRADE_EFFECT_INVALID: '%s' rank %d" % [item.family_id, item.rank])
		if not by_family.has(item.family_id):
			by_family[item.family_id] = []
			_upgrade_order.append(item.family_id)
		by_family[item.family_id].append(item.duplicate())
	for family_id: String in _upgrade_order:
		var ranks: Array = by_family[family_id]
		ranks.sort_custom(func(a: UpgradeDefinition, b: UpgradeDefinition) -> bool: return a.rank < b.rank)
		for i: int in ranks.size():
			if (ranks[i] as UpgradeDefinition).rank != i + 1:
				errors.append("UPGRADE_RANKS_NOT_CONTIGUOUS: '%s' must have ranks 1..%d" % [family_id, ranks.size()])
				break
		_upgrades[family_id] = ranks


func _load_fertilizers(items: Array[FertilizerDefinition]) -> void:
	var tiers: Dictionary[int, bool] = {}
	var sorted: Array[FertilizerDefinition] = []
	for item: FertilizerDefinition in items:
		if item == null or not _valid_id(item.id):
			errors.append("FERTILIZER_ID_INVALID: '%s'" % ("" if item == null else item.id))
			continue
		if DEFERRED_CONTENT_IDS.has(item.id):
			errors.append("DEFERRED_CONTENT: '%s' is deferred beyond v1 (DEC-008)" % item.id)
			continue
		if _fertilizers.has(item.id) or tiers.has(item.tier):
			errors.append("FERTILIZER_DUPLICATE: '%s' tier %d" % [item.id, item.tier])
			continue
		if item.tier < 0 or item.coin_bonus_bp < 0 or item.price_coef_bp < 0 or item.price_floor < 0:
			errors.append("FERTILIZER_VALUE_INVALID: '%s'" % item.id)
		var is_none: bool = item.id == FertilizerDefinition.NONE_ID
		if is_none and (item.tier != 0 or item.coin_bonus_bp != 0 or item.price_coef_bp != 0 or item.price_floor != 0):
			errors.append("FERTILIZER_NONE_INVALID: 'none' must be tier 0, free and without effect")
		if not is_none and item.tier == 0:
			errors.append("FERTILIZER_TIER_INVALID: only 'none' may be tier 0 ('%s')" % item.id)
		tiers[item.tier] = true
		_fertilizers[item.id] = item.duplicate() as FertilizerDefinition
		sorted.append(_fertilizers[item.id])
	if not _fertilizers.has(FertilizerDefinition.NONE_ID):
		errors.append("FERTILIZER_NONE_MISSING: a fertilizer table must include 'none'")
	sorted.sort_custom(func(a: FertilizerDefinition, b: FertilizerDefinition) -> bool: return a.tier < b.tier)
	for item: FertilizerDefinition in sorted:
		_fertilizer_order.append(item.id)


func _load_bands(items: Array[ExpansionBand]) -> void:
	var sorted: Array[ExpansionBand] = []
	for item: ExpansionBand in items:
		if item == null:
			errors.append("EXPANSION_BAND_NULL: null band")
			continue
		sorted.append(item.duplicate() as ExpansionBand)
	sorted.sort_custom(func(a: ExpansionBand, b: ExpansionBand) -> bool: return a.first_plot < b.first_plot)
	var expected: int = ExpansionBand.FIRST_PURCHASABLE_PLOT
	for band: ExpansionBand in sorted:
		if band.first_plot != expected or band.last_plot < band.first_plot:
			errors.append("EXPANSION_BANDS_NOT_CONTIGUOUS: expected a band starting at plot %d" % expected)
			return
		if band.cost <= 0 or band.required_level < 1 or (not _thresholds.is_empty() and band.required_level > _thresholds.size()):
			errors.append("EXPANSION_BAND_INVALID: plots %d-%d" % [band.first_plot, band.last_plot])
		expected = band.last_plot + 1
	if expected != ExpansionBand.LAST_PURCHASABLE_PLOT + 1:
		errors.append("EXPANSION_BANDS_INCOMPLETE: bands must cover plots %d-%d exactly" % [ExpansionBand.FIRST_PURCHASABLE_PLOT, ExpansionBand.LAST_PURCHASABLE_PLOT])
		return
	_bands = sorted


func _load_economy(parameters: EconomyParameters) -> void:
	if parameters.growth_cap_bp < 0 or parameters.growth_cap_bp > 10_000:
		errors.append("ECONOMY_GROWTH_CAP_RANGE: %d" % parameters.growth_cap_bp)
	if parameters.reset_minimum < 0 or parameters.reset_level_factor < 0:
		errors.append("ECONOMY_RESET_NEGATIVE: reset price inputs must be nonnegative")
	if parameters.budget_reserve_default < 0 or parameters.budget_protection_percent_default < 0 \
			or parameters.budget_protection_percent_default > 100:
		errors.append("ECONOMY_BUDGET_DEFAULT_RANGE: reserve >= 0, protection 0-100")
	_economy = parameters.duplicate() as EconomyParameters


func _valid_id(value: String) -> bool:
	var regex: RegEx = RegEx.create_from_string(_ID_PATTERN)
	return regex.search(value) != null
