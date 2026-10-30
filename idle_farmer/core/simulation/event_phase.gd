class_name EventPhase
extends RefCounted
## Due-event phases at one simulated timestamp (TRS §4.2, DEC-006), as numeric scheduler codes
## (build plan P9). Only phases 1 and 2 are queued events; 3–9 are steps inside a logical batch.

const RESEARCH_COMPLETION: int = 1
const MATURITY_AND_AUTO_HARVEST: int = 2
const CREDIT_COINS_XP: int = 3
const LEVELS_CONTRACTS_ACCOUNTING: int = 4
const COLLECT_REPLANT_RETRY: int = 5
const ALLOCATE_SEEDS: int = 6
const ALLOCATE_FERTILIZER: int = 7
const APPLY_AND_SCHEDULE: int = 8
const PUBLISH_NOTIFICATIONS: int = 9

## All M01 events use the default configured priority (build plan B7; spending priority is M02).
const DEFAULT_PRIORITY: int = 0
