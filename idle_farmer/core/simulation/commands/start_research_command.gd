class_name StartResearchCommand
extends TermsCommand
## Start one research project (M02-T07, FRS §8, DEC-007). Terms bind the project, its cost and its
## duration, so a content change between quote and acceptance gives STALE_TERMS.

const SCHEMA: Dictionary = {"project_id": TYPE_STRING, "cost": TYPE_INT, "duration_us": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_START_RESEARCH, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> StartResearchCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "StartResearch.args")
	return null if terms == null else StartResearchCommand.new(id, time_us, order, terms)


func project_id() -> String:
	return _terms["project_id"]


func cost() -> int:
	return _terms["cost"]


func duration_us() -> int:
	return _terms["duration_us"]


func _args_valid() -> bool:
	return _terms.has("project_id") and not (_terms["project_id"] as String).is_empty() \
		and _terms.get("cost", -1) >= 0 and _terms.get("duration_us", 0) >= 1
