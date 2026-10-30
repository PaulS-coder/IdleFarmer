class_name ExpansionBand
extends Resource
## Provisional purchase requirements for a contiguous range of fourth-row plots (FRS §3).

## Fourth-row purchasable plot range (DEC-020): plots 25–32.
const FIRST_PURCHASABLE_PLOT: int = 25
const LAST_PURCHASABLE_PLOT: int = 32

@export var first_plot: int = 25
@export var last_plot: int = 25
@export var required_level: int = 1
@export var cost: int = 0
