class_name AccelerateResearchCommand
extends TermsCommand
## Buy the active run's one boost (M02-T07, FRS §8, AV-004-03). Terms bind the run identity (its
## EntityId key), the fixed charge ceil(C/2) and the half-remaining rule. The remaining time is not a
## term: the preview ages naturally and the accepted-time result is recomputed at acceptance.

const RULE_HALVE_REMAINING: String = "halve_remaining"
const SCHEMA: Dictionary = {"run_id": TYPE_STRING, "charge": TYPE_INT, "rule": TYPE_STRING}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_ACCELERATE_RESEARCH, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> AccelerateResearchCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "AccelerateResearch.args")
	return null if terms == null else AccelerateResearchCommand.new(id, time_us, order, terms)


func run_id() -> String:
	return _terms["run_id"]


func charge() -> int:
	return _terms["charge"]


func _args_valid() -> bool:
	return _terms.has("run_id") and not (_terms["run_id"] as String).is_empty() \
		and _terms.get("charge", -1) >= 0 and _terms.get("rule", "") == RULE_HALVE_REMAINING
