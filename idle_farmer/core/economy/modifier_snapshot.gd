class_name ModifierSnapshot
extends RefCounted
## Planting modifiers derived from skills, equipment and the chosen fertilizer (M02-T02, FRS
## §§5.2–5.3, 6.1–6.3; build plan §3.2). All sources are additive; growth reduction is capped by
## the profile manifest's cap, and coin bonuses never change XP. Values come from the profile's
## bound registry only (AV-003): a content_m01_v1 profile always has identity modifiers.
##
## Stored on the planted cycle via `to_dict()` and never recomputed afterwards.

const KEY_GROWTH: String = "growth_reduction_bp"
const KEY_COIN: String = "coin_bonus_bp"
const KEY_FERTILIZER: String = "fertilizer_bonus_bp"

var ok: bool = false
var uncapped_growth_reduction_bp: int = 0
var growth_reduction_bp: int = 0
## Skills + equipment, excluding the fertilizer bonus.
var coin_bonus_bp: int = 0
var fertilizer_id: String = FertilizerDefinition.NONE_ID
var fertilizer_bonus_bp: int = 0


## Modifiers for a new planting in `state` with `fertilizer_id`. `ok` is false for an unknown
## fertilizer or an unrepresentable sum.
static func for_state(state: GameState, registry: ContentRegistry, p_fertilizer_id: String) -> ModifierSnapshot:
	var snapshot: ModifierSnapshot = ModifierSnapshot.new()
	var fertilizer: FertilizerDefinition = registry.fertilizer(p_fertilizer_id)
	if fertilizer == null:
		return snapshot
	var growth: int = 0
	var coins: int = 0
	for skill_id: String in state.player.skill_ranks:
		var skill: SkillDefinition = registry.skill(skill_id)
		if skill == null:
			continue
		var effect: MathResult = IntegerMath.mul(state.player.skill_ranks[skill_id], skill.effect_bp_per_rank)
		if not effect.ok:
			return snapshot
		var sum: MathResult
		match skill.effect_kind:
			SkillDefinition.EFFECT_GROWTH_REDUCTION:
				sum = IntegerMath.add(growth, effect.value)
				growth = sum.value
			SkillDefinition.EFFECT_COIN_BONUS:
				sum = IntegerMath.add(coins, effect.value)
				coins = sum.value
			_:
				continue
		if not sum.ok:
			return snapshot
	for family_id: String in registry.upgrade_family_ids():
		var owned: int = mini(state.upgrades.ranks.get(family_id, 0), registry.upgrade_max_rank(family_id))
		for rank: int in range(1, owned + 1):
			var upgrade: UpgradeDefinition = registry.upgrade(family_id, rank)
			var sum: MathResult
			if upgrade.effect_kind == UpgradeDefinition.EFFECT_GROWTH_REDUCTION:
				sum = IntegerMath.add(growth, upgrade.effect_bp)
				growth = sum.value
			else:
				sum = IntegerMath.add(coins, upgrade.effect_bp)
				coins = sum.value
			if not sum.ok:
				return snapshot
	return from_values(growth, coins, registry.growth_cap_bp(), fertilizer)


## Snapshot from explicit inputs (tests and the optimizer's per-plot candidates).
static func from_values(uncapped_growth_bp: int, coin_bp: int, cap_bp: int, fertilizer: FertilizerDefinition) -> ModifierSnapshot:
	var snapshot: ModifierSnapshot = ModifierSnapshot.new()
	if uncapped_growth_bp < 0 or coin_bp < 0 or cap_bp < 0 or cap_bp > IntegerMath.BASIS_POINTS or fertilizer == null:
		return snapshot
	snapshot.uncapped_growth_reduction_bp = uncapped_growth_bp
	snapshot.growth_reduction_bp = mini(uncapped_growth_bp, cap_bp)
	snapshot.coin_bonus_bp = coin_bp
	snapshot.fertilizer_id = fertilizer.id
	snapshot.fertilizer_bonus_bp = fertilizer.coin_bonus_bp
	snapshot.ok = IntegerMath.add(coin_bp, fertilizer.coin_bonus_bp).ok
	return snapshot


## Growth reduction lost to the cap (shown in quotes so players see wasted upgrades).
func cap_waste_bp() -> int:
	return uncapped_growth_reduction_bp - growth_reduction_bp


func total_coin_bonus_bp() -> int:
	return coin_bonus_bp + fertilizer_bonus_bp


func to_dict() -> Dictionary[String, int]:
	return {KEY_GROWTH: growth_reduction_bp, KEY_COIN: coin_bonus_bp, KEY_FERTILIZER: fertilizer_bonus_bp}
