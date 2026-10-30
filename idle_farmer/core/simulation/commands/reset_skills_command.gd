class_name ResetSkillsCommand
extends TermsCommand
## Paid complete skill reset (M02-T05, FRS §5.5). Terms bind the level, its exact derived price and
## the points being refunded (FR-AUD-004 / AV-004-04): any change requires a refreshed quote.

const SCHEMA: Dictionary = {"level": TYPE_INT, "price": TYPE_INT, "allocated_points": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_RESET_SKILLS, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> ResetSkillsCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "ResetSkills.args")
	return null if terms == null else ResetSkillsCommand.new(id, time_us, order, terms)


func level() -> int:
	return _terms["level"]


func price() -> int:
	return _terms["price"]


func allocated_points() -> int:
	return _terms["allocated_points"]


func _args_valid() -> bool:
	return _terms.get("level", 0) >= 1 and _terms.get("price", -1) >= 0 and _terms.get("allocated_points", -1) >= 0
