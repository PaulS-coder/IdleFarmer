class_name SettingsResolver
extends RefCounted
## Effective settings and recurring-loop status (M02 E10/E11, Q1, FRS §§7.1, 9.2; build plan §3.4).
## Resolution walks Plot > Group > Farm per field; an explicit false/""/0 that is set stays set.
## A loop is *runnable* only when it is armed for the current effective plan digest, Auto Replant
## is enabled and owned, and a Smart policy (if any) has the Smart Fertilizer capability. A stored
## but unusable rule stays inactive and never authorizes spending.

const LOOP_RUNNABLE: String = "runnable"


## Fully set effective settings for `plot_id` (farm defaults for an unknown plot).
static func effective(state: GameState, plot_id: int) -> FarmingSettings:
	var automation: AutomationState = state.automation
	var result: FarmingSettings = FarmingSettings.new()
	var record: PlotAutomation = automation.plot(plot_id)
	var layers: Array[FarmingSettings] = []
	if record != null:
		layers.append(record.settings)
		if automation.groups.has(record.group_id):
			layers.append(automation.groups[record.group_id])
	layers.append(automation.defaults)
	for field: String in FarmingSettings.FIELDS:
		for layer: FarmingSettings in layers:
			if layer.is_set(field):
				result.set_value(field, layer.value(field))
				break
	return result


## Canonical digest of the recurring purchase plan {crop, fertilizer policy, fallback} (Q1).
static func plan_digest(settings: FarmingSettings) -> String:
	return CanonicalCodec.digest({
		"crop_id": settings.crop_id,
		"fertilizer_policy": settings.fertilizer_policy,
		"fallback_accepted": settings.fallback_accepted,
	})


static func effective_plan_digest(state: GameState, plot_id: int) -> String:
	return plan_digest(effective(state, plot_id))


## LOOP_RUNNABLE, or the PlotState stall reason explaining why the plot's loop cannot run.
static func loop_status(state: GameState, caps: Capabilities, plot_id: int) -> String:
	var settings: FarmingSettings = effective(state, plot_id)
	var auth: LoopAuthorization = state.automation.plot(plot_id).authorization
	if not settings.auto_replant or settings.crop_id.is_empty():
		return PlotState.STALL_UNARMED
	if not caps.has(Capabilities.AUTOMATIC_REPLANTING):
		return PlotState.STALL_CAPABILITY
	if FarmingSettings.is_smart(settings.fertilizer_policy) and not caps.has(Capabilities.SMART_FERTILIZER):
		return PlotState.STALL_CAPABILITY
	if not auth.armed or auth.plan_digest != plan_digest(settings):
		return PlotState.STALL_UNARMED
	return LOOP_RUNNABLE


## True when the effective Auto Harvest setting is on and the capability is owned.
static func auto_harvest_active(state: GameState, caps: Capabilities, plot_id: int) -> bool:
	return caps.has(Capabilities.AUTOMATIC_HARVESTING) and effective(state, plot_id).auto_harvest
