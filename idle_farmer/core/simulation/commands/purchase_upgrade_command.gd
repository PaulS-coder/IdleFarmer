class_name PurchaseUpgradeCommand
extends TermsCommand
## Buy the next rank of an equipment family (M02-T06, FR-AUD-006). Terms bind the family, target
## rank (owned + 1) and its exact cost.

const SCHEMA: Dictionary = {"family_id": TYPE_STRING, "target_rank": TYPE_INT, "cost": TYPE_INT}


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, GameCommand.TYPE_PURCHASE_UPGRADE, p_accepted_time_us, p_accepted_order, p_terms)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> PurchaseUpgradeCommand:
	var terms: Variant = TermsCommand.decode_terms(args, SCHEMA, "PurchaseUpgrade.args")
	return null if terms == null else PurchaseUpgradeCommand.new(id, time_us, order, terms)


func family_id() -> String:
	return _terms["family_id"]


func target_rank() -> int:
	return _terms["target_rank"]


func cost() -> int:
	return _terms["cost"]


func _args_valid() -> bool:
	return _terms.has("family_id") and not (_terms["family_id"] as String).is_empty() \
		and _terms.get("target_rank", 0) >= 1 and _terms.get("cost", -1) >= 0
