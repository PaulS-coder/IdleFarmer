class_name ContentManifest
extends Resource
## One complete, immutable content/progression manifest (FR-AUD-003, TRS §20.3). A saved profile
## binds to `manifest_id`; published manifests are never edited in place.

@export var manifest_id: String = ""
@export var crops: Array[CropDefinition] = []
@export var research: Array[ResearchDefinition] = []
@export var skills: Array[SkillDefinition] = []
@export var level_curve: LevelCurveDefinition
## Crops unlocked at new game without research (DEC-003: Wheat only).
@export var start_unlocked_crop_ids: PackedStringArray = PackedStringArray()
## M02 tables (absent in content_m01_v1, whose profiles therefore have no equipment, fertilizers,
## expansion purchases or skill effects).
@export var upgrades: Array[UpgradeDefinition] = []
@export var fertilizers: Array[FertilizerDefinition] = []
@export var expansion_bands: Array[ExpansionBand] = []
@export var economy: EconomyParameters = null
