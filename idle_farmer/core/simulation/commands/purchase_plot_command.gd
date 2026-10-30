class_name PurchasePlotCommand
extends TermsCommand
## Buy the next fourth-row plot (M02-T03, FR-FARM-06/08, DEC-020). Terms bind the exact target
## (must be N+1) and its cost, so a re-delivered intent cannot buy a second plot.

const SCHEMA: Dictionary = {"plot_id": TYPE_INT, "cost": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_PURCHASE_PLOT, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> PurchasePlotCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "PurchasePlot.args")
	return null if terms == null else PurchasePlotCommand.new(id, time_us, order, terms)


func plot_id() -> int:
	return _terms["plot_id"]


func cost() -> int:
	return _terms["cost"]


func _args_valid() -> bool:
	return _terms.has("plot_id") and _terms.has("cost") and _terms["cost"] >= 0
