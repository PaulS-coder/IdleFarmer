class_name ResearchDefinition
extends Resource
## Crop research project content (FRS §8). M01 holds the data only; the research flow is M02.

@export var id: String = ""
@export var crop_id: String = ""
@export var required_level: int = 1
@export var cost: int = 0
@export var duration_us: int = 0
