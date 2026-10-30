class_name CommitSink
extends RefCounted
## Durable-commit boundary (TRS §20.2, AUD-002). M01 provides only this in-memory implementation;
## M03 supplies the SQLite repository behind the same contract.
##
## `commit(prepared)` receives a prepared checkpoint dictionary:
##   {"commit_id": {"epoch", "counter"}, "expected_parent_revision": int,
##    "new_revision": int, "state": <GameState primitive>}
## and answers COMMITTED, NOT_COMMITTED (definitely not written; parent unchanged) or UNKNOWN.
## `read_back()` returns the settled durable checkpoint {"durable_revision", "commit_id", "state"},
## or {} when it cannot be read. An empty store reads back as revision 0 with no commit.

const COMMITTED: String = "COMMITTED"
const NOT_COMMITTED: String = "NOT_COMMITTED"
const UNKNOWN: String = "UNKNOWN"

var _durable: Dictionary = {}


func commit(prepared: Dictionary) -> String:
	var parent: int = _durable.get("durable_revision", 0)
	if prepared["expected_parent_revision"] != parent:
		return NOT_COMMITTED
	_store(prepared)
	return COMMITTED


func read_back() -> Dictionary:
	if _durable.is_empty():
		return {"durable_revision": 0, "commit_id": null, "state": null}
	return _durable.duplicate(true)


func _store(prepared: Dictionary) -> void:
	_durable = {
		"durable_revision": prepared["new_revision"],
		"commit_id": (prepared["commit_id"] as Dictionary).duplicate(true),
		"state": (prepared["state"] as Dictionary).duplicate(true),
	}
