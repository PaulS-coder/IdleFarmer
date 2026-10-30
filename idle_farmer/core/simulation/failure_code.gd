class_name FailureCode
extends RefCounted
## Structured command failure codes (TRS §4.1, build plan P11). `PRECEDENCE` lists them in the
## order checks run; the first failing check determines the reported code.

const NONE: String = ""
const MALFORMED_ENVELOPE: String = "MALFORMED_ENVELOPE"
const INVALID_COMMAND_TIME: String = "INVALID_COMMAND_TIME"
const STALE_COMMAND: String = "STALE_COMMAND"
const DUPLICATE_COMMAND: String = "DUPLICATE_COMMAND"
const PERSISTENCE_UNAVAILABLE: String = "PERSISTENCE_UNAVAILABLE"
## Command exists but is not available for this profile's manifest or this milestone (M02 E9).
const FEATURE_UNAVAILABLE: String = "FEATURE_UNAVAILABLE"
const UNKNOWN_PLOT: String = "UNKNOWN_PLOT"
const UNKNOWN_CROP: String = "UNKNOWN_CROP"
const UNKNOWN_FERTILIZER: String = "UNKNOWN_FERTILIZER"
const UNKNOWN_SKILL: String = "UNKNOWN_SKILL"
const UNKNOWN_UPGRADE: String = "UNKNOWN_UPGRADE"
const UNKNOWN_RESEARCH: String = "UNKNOWN_RESEARCH"
const PLOT_LOCKED: String = "PLOT_LOCKED"
const PLOT_UNLOCK_ORDER_REQUIRED: String = "PLOT_UNLOCK_ORDER_REQUIRED"
const PLOTS_FULL: String = "PLOTS_FULL"
const PLOT_OCCUPIED: String = "PLOT_OCCUPIED"
const NO_CYCLE: String = "NO_CYCLE"
const CYCLE_MISMATCH: String = "CYCLE_MISMATCH"
const CROP_NOT_READY: String = "CROP_NOT_READY"
const SKILL_MAX_RANK: String = "SKILL_MAX_RANK"
const UPGRADE_MAX_RANK: String = "UPGRADE_MAX_RANK"
const UPGRADE_PREDECESSOR_REQUIRED: String = "UPGRADE_PREDECESSOR_REQUIRED"
## Research target states (M02-T07, build plan §3.8): another run is active, the project is already
## completed, a boost names no active run, the run's one boost is spent, or halving saves no time.
const RESEARCH_ACTIVE: String = "RESEARCH_ACTIVE"
const RESEARCH_DONE: String = "RESEARCH_DONE"
const NO_ACTIVE_RESEARCH: String = "NO_ACTIVE_RESEARCH"
const BOOST_USED: String = "BOOST_USED"
const NO_TIME_SAVED: String = "NO_TIME_SAVED"
const NOTHING_TO_RESET: String = "NOTHING_TO_RESET"
const LEVEL_REQUIRED: String = "LEVEL_REQUIRED"
const RESEARCH_REQUIRED: String = "RESEARCH_REQUIRED"
const SKILL_PREREQUISITE_REQUIRED: String = "SKILL_PREREQUISITE_REQUIRED"
const INSUFFICIENT_POINTS: String = "INSUFFICIENT_POINTS"
const STALE_TERMS: String = "STALE_TERMS"
const INSUFFICIENT_COINS: String = "INSUFFICIENT_COINS"
const NUMERIC_LIMIT: String = "NUMERIC_LIMIT"
## Automation commands (S4): an invalid setting/budget value (target-state step), and a missing
## capability (gate step).
const INVALID_CONFIGURATION: String = "INVALID_CONFIGURATION"
const SKILL_NOT_UNLOCKED: String = "SKILL_NOT_UNLOCKED"

## Check order (M02 build plan §3.3): envelope/replay → availability → unknown targets → target
## state → gates → confirmed terms → coins → numeric limits. The first failure is reported.
const PRECEDENCE: PackedStringArray = [
	MALFORMED_ENVELOPE, INVALID_COMMAND_TIME, STALE_COMMAND, DUPLICATE_COMMAND, PERSISTENCE_UNAVAILABLE,
	FEATURE_UNAVAILABLE,
	UNKNOWN_PLOT, UNKNOWN_CROP, UNKNOWN_FERTILIZER, UNKNOWN_SKILL, UNKNOWN_UPGRADE, UNKNOWN_RESEARCH,
	PLOT_LOCKED, PLOT_UNLOCK_ORDER_REQUIRED, PLOTS_FULL, PLOT_OCCUPIED, NO_CYCLE, CYCLE_MISMATCH, CROP_NOT_READY,
	SKILL_MAX_RANK, UPGRADE_MAX_RANK, UPGRADE_PREDECESSOR_REQUIRED,
	RESEARCH_ACTIVE, RESEARCH_DONE, NO_ACTIVE_RESEARCH, BOOST_USED, NO_TIME_SAVED, NOTHING_TO_RESET, INVALID_CONFIGURATION,
	LEVEL_REQUIRED, RESEARCH_REQUIRED, SKILL_PREREQUISITE_REQUIRED, SKILL_NOT_UNLOCKED, INSUFFICIENT_POINTS,
	STALE_TERMS, INSUFFICIENT_COINS, NUMERIC_LIMIT,
]
