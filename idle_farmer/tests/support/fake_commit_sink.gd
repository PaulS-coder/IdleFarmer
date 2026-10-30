class_name FakeCommitSink
extends CommitSink
## Scriptable commit outcomes for AV-002 fault injection. Each commit consumes the next scripted
## mode (default "commit"):
##   "commit"            — written, returns COMMITTED
##   "reject"            — definitely not written, returns NOT_COMMITTED
##   "lost_ack"          — written, but returns UNKNOWN (receipt lost: AV-002-01 rev 41 case)
##   "unknown_unwritten" — not written, returns UNKNOWN
## `unreadable` makes read_back() fail ({}), as for an unsettled/failed read (AV-002-02).

const MODE_COMMIT: String = "commit"
const MODE_REJECT: String = "reject"
const MODE_LOST_ACK: String = "lost_ack"
const MODE_UNKNOWN_UNWRITTEN: String = "unknown_unwritten"

var script_modes: Array[String] = []
var unreadable: bool = false
var commit_attempts: int = 0


func commit(prepared: Dictionary) -> String:
	commit_attempts += 1
	var mode: String = MODE_COMMIT if script_modes.is_empty() else script_modes.pop_front()
	match mode:
		MODE_REJECT, MODE_UNKNOWN_UNWRITTEN:
			return NOT_COMMITTED if mode == MODE_REJECT else UNKNOWN
		MODE_LOST_ACK:
			var outcome: String = super(prepared)
			return UNKNOWN if outcome == COMMITTED else outcome
	return super(prepared)


func read_back() -> Dictionary:
	if unreadable:
		return {}
	return super()


func durable_revision() -> int:
	return read_back().get("durable_revision", -1)
