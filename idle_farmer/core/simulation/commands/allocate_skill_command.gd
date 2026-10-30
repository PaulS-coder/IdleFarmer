class_name AllocateSkillCommand
extends TermsCommand
## Spend one unallocated point on the next rank/node of a skill (M02-T04, DEC-004). Terms bind the
## target rank (current + 1).

const SCHEMA: Dictionary = {"skill_id": TYPE_STRING, "target_rank": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_ALLOCATE_SKILL, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> AllocateSkillCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "AllocateSkill.args")
	return null if terms == null else AllocateSkillCommand.new(id, time_us, order, terms)


func skill_id() -> String:
	return _terms["skill_id"]


func target_rank() -> int:
	return _terms["target_rank"]


func _args_valid() -> bool:
	return _terms.has("skill_id") and not (_terms["skill_id"] as String).is_empty() and _terms.get("target_rank", 0) >= 1
