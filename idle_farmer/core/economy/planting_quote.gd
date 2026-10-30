class_name PlantingQuote
extends RefCounted
## Exact economic terms of planting one crop under given modifiers (TRS §4.4, §20.4). The same
## calculation backs UI previews and command execution, so a confirmed quote can be compared
## term-by-term at acceptance (STALE_TERMS on any difference).

var ok: bool = false
var crop_id: String = ""
var manifest_id: String = ""
var seed_cost: int = 0
var growth_us: int = 0
var gross_coins: int = 0
var xp: int = 0
## Applied modifier inputs, recorded into the cycle snapshot.
var modifiers: Dictionary[String, int] = {}


## True when every confirmed term equals this quote.
func matches(command: PlantCropCommand) -> bool:
	return ok and command.crop_id() == crop_id and command.manifest_id() == manifest_id \
		and command.seed_cost() == seed_cost and command.growth_us() == growth_us \
		and command.gross_coins() == gross_coins and command.xp() == xp
