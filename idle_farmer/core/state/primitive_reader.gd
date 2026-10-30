class_name PrimitiveReader
extends RefCounted
## Strict typed field access for `from_primitive` decoders. Every missing, mistyped or unexpected
## key is recorded in `errors`; decoders return null when `ok()` is false so malformed snapshots
## never become partially-constructed state (AV-001-04).

var errors: PackedStringArray = PackedStringArray()
var _data: Dictionary = {}
var _context: String = ""


func _init(data: Variant, context: String) -> void:
	_context = context
	if typeof(data) != TYPE_DICTIONARY:
		errors.append("%s: expected dictionary, got %s" % [context, type_string(typeof(data))])
		return
	_data = data


func ok() -> bool:
	return errors.is_empty()


## Records an error for any key not in `allowed` (canonical snapshots carry no unknown fields).
func expect_only(allowed: PackedStringArray) -> void:
	for key: Variant in _data.keys():
		if typeof(key) != TYPE_STRING or not allowed.has(key):
			errors.append("%s: unexpected key '%s'" % [_context, str(key)])


func int_field(key: String) -> int:
	if _check(key, TYPE_INT):
		return _data[key]
	return 0


func string_field(key: String) -> String:
	if _check(key, TYPE_STRING):
		return _data[key]
	return ""


func bool_field(key: String) -> bool:
	if _check(key, TYPE_BOOL):
		return _data[key]
	return false


func dict_field(key: String) -> Dictionary:
	if _check(key, TYPE_DICTIONARY):
		return _data[key]
	return {}


func array_field(key: String) -> Array:
	if _check(key, TYPE_ARRAY):
		return _data[key]
	return []


## Value that may be null or a dictionary (nullable nested record).
func nullable_field(key: String) -> Variant:
	if not _data.has(key):
		errors.append("%s: missing '%s'" % [_context, key])
		return null
	var value: Variant = _data[key]
	if value != null and typeof(value) != TYPE_DICTIONARY:
		errors.append("%s: '%s' must be null or dictionary" % [_context, key])
		return null
	return value


## Array whose every element is a String.
func string_array_field(key: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for item: Variant in array_field(key):
		if typeof(item) != TYPE_STRING:
			errors.append("%s: '%s' must contain only strings" % [_context, key])
			return PackedStringArray()
		result.append(item)
	return result


## Dictionary whose every value is an int (keys are strings by construction of the codec).
func int_map_field(key: String) -> Dictionary[String, int]:
	var result: Dictionary[String, int] = {}
	var source: Dictionary = dict_field(key)
	for k: Variant in source.keys():
		if typeof(k) != TYPE_STRING or typeof(source[k]) != TYPE_INT:
			errors.append("%s: '%s' must map strings to ints" % [_context, key])
			return {}
		result[k] = source[k]
	return result


## Folds nested decoder errors into this reader.
func absorb(nested_errors: PackedStringArray) -> void:
	errors.append_array(nested_errors)


func _check(key: String, type: int) -> bool:
	if not _data.has(key):
		errors.append("%s: missing '%s'" % [_context, key])
		return false
	if typeof(_data[key]) != type:
		errors.append("%s: '%s' must be %s" % [_context, key, type_string(type)])
		return false
	return true


## Deep copy of a primitive value with every Array/Dictionary rebuilt untyped, so exported
## primitives never carry typed-container restrictions (e.g. Dictionary[String, int]).
static func plain(value: Variant) -> Variant:
	match typeof(value):
		TYPE_ARRAY:
			var items: Array = []
			for item: Variant in value:
				items.append(plain(item))
			return items
		TYPE_DICTIONARY:
			var dict: Dictionary = {}
			for key: Variant in (value as Dictionary).keys():
				dict[key] = plain(value[key])
			return dict
	return value
