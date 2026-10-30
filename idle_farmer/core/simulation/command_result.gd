class_name CommandResult
extends RefCounted
## Structured command outcome (TRS §4.1). `commit_status` is filled by the controller after the
## commit sink answers; the engine leaves it NONE. Serializable for the bounded response cache.

const COMMIT_NONE: String = "NONE"
const COMMIT_COMMITTED: String = "COMMITTED"
const COMMIT_NOT_COMMITTED: String = "NOT_COMMITTED"
const COMMIT_UNKNOWN: String = "UNKNOWN"

var success: bool = false
var failure_code: String = FailureCode.NONE
var failure_detail: String = ""
var command_id: CommandId = null
var affected_plot_ids: Array[int] = []
var events: Array[SimulationEvent] = []
var transactions: Array[EconomicTransaction] = []
var state_sequence: int = 0
var commit_status: String = COMMIT_NONE


static func failed(code: String, detail: String, p_command_id: CommandId, p_state_sequence: int) -> CommandResult:
	var result: CommandResult = CommandResult.new()
	result.success = false
	result.failure_code = code
	result.failure_detail = detail
	result.command_id = p_command_id
	result.state_sequence = p_state_sequence
	return result


func to_primitive() -> Dictionary:
	var event_items: Array = []
	for event: SimulationEvent in events:
		event_items.append(event.to_primitive())
	var tx_items: Array = []
	for tx: EconomicTransaction in transactions:
		tx_items.append(tx.to_primitive())
	return {
		"success": success,
		"failure_code": failure_code,
		"failure_detail": failure_detail,
		"command_id": null if command_id == null else command_id.to_primitive(),
		"affected_plot_ids": PrimitiveReader.plain(affected_plot_ids),
		"events": event_items,
		"transactions": tx_items,
		"state_sequence": state_sequence,
		"commit_status": commit_status,
	}


static func from_primitive(value: Variant) -> CommandResult:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "CommandResult")
	reader.expect_only(PackedStringArray(["success", "failure_code", "failure_detail", "command_id", "affected_plot_ids",
		"events", "transactions", "state_sequence", "commit_status"]))
	var result: CommandResult = CommandResult.new()
	result.success = reader.bool_field("success")
	result.failure_code = reader.string_field("failure_code")
	result.failure_detail = reader.string_field("failure_detail")
	var id_value: Variant = reader.nullable_field("command_id")
	if id_value != null:
		result.command_id = CommandId.from_primitive(id_value)
		if result.command_id == null:
			reader.absorb(PackedStringArray(["CommandResult: malformed command_id"]))
	for item: Variant in reader.array_field("affected_plot_ids"):
		if typeof(item) != TYPE_INT:
			reader.absorb(PackedStringArray(["CommandResult: plot ids must be ints"]))
			continue
		result.affected_plot_ids.append(item)
	for item: Variant in reader.array_field("events"):
		var event: SimulationEvent = SimulationEvent.from_primitive(item)
		if event == null:
			reader.absorb(PackedStringArray(["CommandResult: malformed event"]))
			continue
		result.events.append(event)
	for item: Variant in reader.array_field("transactions"):
		var tx: EconomicTransaction = EconomicTransaction.from_primitive(item)
		if tx == null:
			reader.absorb(PackedStringArray(["CommandResult: malformed transaction"]))
			continue
		result.transactions.append(tx)
	result.state_sequence = reader.int_field("state_sequence")
	result.commit_status = reader.string_field("commit_status")
	return result if reader.ok() else null
