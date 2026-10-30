extends GutTest
## M01-T15 / V09: the gameplay core and content data import no scenes, audio, rendering, display,
## OS/time/file, SQL/native or test code, use no floats or randomness, and every script parses.
## Loading each script here also closes the gap that `--import` does not compile GDScript (S0).

const AUDITED_ROOTS: PackedStringArray = ["res://core", "res://data"]

## [pattern, reason] applied to code with comments and string literals removed.
const FORBIDDEN: Array[Array] = [
	["\\bextends\\s+(Node|Node2D|Node3D|Control|CanvasItem|Sprite2D|Object)\\b", "scene/engine object base class"],
	["\\b(get_tree|get_node|add_child|SceneTree|PackedScene|instantiate|queue_free)\\b", "scene tree access"],
	["\\b(Audio\\w*|DisplayServer|RenderingServer|Input|Viewport|Camera2D|Camera3D)\\b", "presentation/audio/input API"],
	["\\b(OS|Time|FileAccess|DirAccess|ResourceSaver|ResourceLoader|ProjectSettings|HTTPRequest|Thread|Mutex)\\b", "platform/OS/file/time API"],
	["\\b(SQLite|SQL|GDExtension|JavaClassWrapper|JavaScriptBridge)\\b", "native/SQL/platform bridge"],
	["\\bEngine\\.", "global engine state (e.g. Engine.time_scale)"],
	["\\b(preload|load)\\s*\\(", "dynamic resource loading"],
	["\\b(JSON|float|randf|randi|randf_range|randi_range|RandomNumberGenerator|pow|sqrt|snapped)\\b", "float/random/JSON in authoritative code"],
	["\\b(Gut\\w*|Fixtures|FakeTimeProvider|FakeCommitSink|ScenarioDriver|ManifestFixtures|OracleVectors)\\b", "test-only code"],
]

## Resource is allowed only for exported content definitions (M01 plan: "Exported content definitions extend Resource").
const RESOURCE_ALLOWED_DIR: String = "res://core/content/"


func _scripts() -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	for root: String in AUDITED_ROOTS:
		_collect(root, found)
	found.sort()
	return found


func _collect(dir_path: String, found: PackedStringArray) -> void:
	for file: String in DirAccess.get_files_at(dir_path):
		if file.ends_with(".gd"):
			found.append(dir_path.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir_path):
		_collect(dir_path.path_join(sub), found)


## Source with string literals blanked and comments removed, one entry per line.
func _code_lines(path: String) -> PackedStringArray:
	var strings: RegEx = RegEx.create_from_string("\"(?:[^\"\\\\]|\\\\.)*\"")
	var lines: PackedStringArray = PackedStringArray()
	for raw: String in FileAccess.get_file_as_string(path).split("\n"):
		var line: String = strings.sub(raw, "\"\"", true)
		var hash_at: int = line.find("#")
		if hash_at != -1:
			line = line.substr(0, hash_at)
		lines.append(line)
	return lines


func test_audit_covers_all_expected_modules() -> void:
	var scripts: PackedStringArray = _scripts()
	assert_gt(scripts.size(), 40, "core + data scripts discovered")
	for expected: String in ["res://core/simulation/simulation_engine.gd", "res://core/application/game_controller.gd",
			"res://core/state/game_state.gd", "res://data/manifests/content_m01_v1.gd"]:
		assert_true(scripts.has(expected), expected)


func test_every_core_and_data_script_parses() -> void:
	for path: String in _scripts():
		var script: GDScript = load(path) as GDScript
		assert_not_null(script, "%s loads" % path)
		if script != null:
			assert_true(script.can_instantiate() or script.is_abstract(), "%s compiled" % path)


func test_no_forbidden_dependencies() -> void:
	var violations: PackedStringArray = PackedStringArray()
	var compiled: Array[RegEx] = []
	for rule: Array in FORBIDDEN:
		compiled.append(RegEx.create_from_string(rule[0]))
	for path: String in _scripts():
		var lines: PackedStringArray = _code_lines(path)
		for n: int in lines.size():
			for i: int in compiled.size():
				if compiled[i].search(lines[n]) != null:
					violations.append("%s:%d %s: %s" % [path, n + 1, FORBIDDEN[i][1], lines[n].strip_edges()])
	assert_eq(violations, PackedStringArray(), "forbidden dependencies:\n" + "\n".join(violations))


func test_resource_base_class_only_for_content_definitions() -> void:
	var extends_resource: RegEx = RegEx.create_from_string("^extends\\s+Resource\\b")
	for path: String in _scripts():
		for line: String in _code_lines(path):
			if extends_resource.search(line) != null:
				assert_true(path.begins_with(RESOURCE_ALLOWED_DIR), "%s extends Resource outside content definitions" % path)


func test_every_core_class_is_refcounted_or_content_resource() -> void:
	var extends_rx: RegEx = RegEx.create_from_string("^extends\\s+(\\w+)")
	var allowed_bases: PackedStringArray = ["RefCounted", "Resource"]
	var known_classes: Dictionary = {}
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		known_classes[entry["class"]] = entry["path"]
	for path: String in _scripts():
		for line: String in _code_lines(path):
			var m: RegExMatch = extends_rx.search(line)
			if m == null:
				continue
			var base: String = m.get_string(1)
			var ok: bool = allowed_bases.has(base) or (known_classes.has(base) and (known_classes[base] as String).begins_with("res://core/"))
			assert_true(ok, "%s extends %s" % [path, base])
