class_name ConfigureBudgetCommand
extends TermsCommand
## Set the farm-wide reserve R and Budget Protection percentage p (M02-T10, FRS §7.1, DEC-010/011).
## Farm-only fields; they need the Smart Fertilizer capability. The seed-protection toggle is M05.

const SCHEMA: Dictionary = {"reserve": TYPE_INT, "protection_percent": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_CONFIGURE_BUDGET, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> ConfigureBudgetCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "ConfigureBudget.args")
	return null if terms == null else ConfigureBudgetCommand.new(id, time_us, order, terms)


func reserve() -> int:
	return _terms["reserve"]


func protection_percent() -> int:
	return _terms["protection_percent"]


func _args_valid() -> bool:
	return _terms.has("reserve") and _terms.has("protection_percent")
