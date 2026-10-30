class_name CanonicalCodec
extends RefCounted
## Canonical, lossless primitive encoding for state digests and snapshot round-trips (build plan P5).
##
## Godot JSON converts integers to floats, so it cannot carry int64 state. This codec accepts only
## null, bool, int, String, Array and Dictionary with String keys, and produces one byte sequence
## per logical value:
##   n | t | f | i<decimal> | s<utf8 byte length>:<utf8 bytes> | [v,v,...] | {s..:v,...}
## Dictionary keys are emitted in sorted order, so insertion order never affects the digest.
## Floats, objects, StringName and packed arrays are rejected rather than coerced.

const _N: int = 0x6E  # n
const _T: int = 0x74  # t
const _F: int = 0x66  # f
const _I: int = 0x69  # i
const _S: int = 0x73  # s
const _COLON: int = 0x3A
const _COMMA: int = 0x2C
const _LBRACKET: int = 0x5B
const _RBRACKET: int = 0x5D
const _LBRACE: int = 0x7B
const _RBRACE: int = 0x7D
const _MINUS: int = 0x2D
const _ZERO: int = 0x30
const _NINE: int = 0x39


## Returns the canonical bytes, or an empty array if `value` contains an unsupported type.
static func encode(value: Variant) -> PackedByteArray:
	var out: PackedByteArray = PackedByteArray()
	if not _encode_into(value, out):
		return PackedByteArray()
	return out


static func is_encodable(value: Variant) -> bool:
	return not encode(value).is_empty()


## SHA-256 hex digest of the canonical bytes, or "" if `value` is not encodable.
static func digest(value: Variant) -> String:
	var bytes: PackedByteArray = encode(value)
	if bytes.is_empty():
		return ""
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(bytes)
	return ctx.finish().hex_encode()


## Decodes canonical bytes. Returns {"ok": bool, "value": Variant}; trailing bytes, non-canonical
## forms (unsorted/duplicate keys, leading zeros, "-0") and out-of-range integers are rejected.
static func decode(bytes: PackedByteArray) -> Dictionary:
	var reader: _Reader = _Reader.new(bytes)
	var value: Variant = reader.read_value()
	if reader.failed or reader.pos != bytes.size():
		return {"ok": false, "value": null}
	return {"ok": true, "value": value}


static func _encode_into(value: Variant, out: PackedByteArray) -> bool:
	match typeof(value):
		TYPE_NIL:
			out.append(_N)
		TYPE_BOOL:
			out.append(_T if value else _F)
		TYPE_INT:
			out.append(_I)
			out.append_array(str(value).to_ascii_buffer())
		TYPE_STRING:
			_encode_string(value, out)
		TYPE_ARRAY:
			var items: Array = value
			out.append(_LBRACKET)
			for i: int in items.size():
				if i > 0:
					out.append(_COMMA)
				if not _encode_into(items[i], out):
					return false
			out.append(_RBRACKET)
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			var keys: Array = dict.keys()
			for key: Variant in keys:
				if typeof(key) != TYPE_STRING:
					return false
			keys.sort()
			out.append(_LBRACE)
			for i: int in keys.size():
				if i > 0:
					out.append(_COMMA)
				_encode_string(keys[i], out)
				out.append(_COLON)
				if not _encode_into(dict[keys[i]], out):
					return false
			out.append(_RBRACE)
		_:
			return false
	return true


static func _encode_string(text: String, out: PackedByteArray) -> void:
	var utf8: PackedByteArray = text.to_utf8_buffer()
	out.append(_S)
	out.append_array(str(utf8.size()).to_ascii_buffer())
	out.append(_COLON)
	out.append_array(utf8)


class _Reader:
	extends RefCounted

	var bytes: PackedByteArray
	var pos: int = 0
	var failed: bool = false

	func _init(p_bytes: PackedByteArray) -> void:
		bytes = p_bytes

	func read_value() -> Variant:
		if failed or pos >= bytes.size():
			failed = true
			return null
		var tag: int = bytes[pos]
		pos += 1
		match tag:
			CanonicalCodec._N:
				return null
			CanonicalCodec._T:
				return true
			CanonicalCodec._F:
				return false
			CanonicalCodec._I:
				return _read_int()
			CanonicalCodec._S:
				return _read_string_body()
			CanonicalCodec._LBRACKET:
				return _read_array()
			CanonicalCodec._LBRACE:
				return _read_dict()
		failed = true
		return null

	func _read_int() -> int:
		var negative: bool = false
		if pos < bytes.size() and bytes[pos] == CanonicalCodec._MINUS:
			negative = true
			pos += 1
		var start: int = pos
		# Accumulate as a negative number so INT64_MIN is representable.
		var acc: int = 0
		while pos < bytes.size() and bytes[pos] >= CanonicalCodec._ZERO and bytes[pos] <= CanonicalCodec._NINE:
			var digit: int = bytes[pos] - CanonicalCodec._ZERO
			var scaled: MathResult = IntegerMath.mul(acc, 10)
			var next: MathResult = IntegerMath.sub(scaled.value, digit) if scaled.ok else scaled
			if not next.ok:
				failed = true
				return 0
			acc = next.value
			pos += 1
		var digits: int = pos - start
		var leading_zero: bool = digits > 1 and bytes[start] == CanonicalCodec._ZERO
		if digits == 0 or leading_zero or (negative and acc == 0):
			failed = true
			return 0
		if negative:
			return acc
		if acc == IntegerMath.INT64_MIN:
			failed = true
			return 0
		return -acc

	func _read_length() -> int:
		var start: int = pos
		var length: int = 0
		while pos < bytes.size() and bytes[pos] >= CanonicalCodec._ZERO and bytes[pos] <= CanonicalCodec._NINE:
			length = length * 10 + (bytes[pos] - CanonicalCodec._ZERO)
			pos += 1
			if length > bytes.size():
				failed = true
				return 0
		var digits: int = pos - start
		if digits == 0 or (digits > 1 and bytes[start] == CanonicalCodec._ZERO):
			failed = true
			return 0
		if pos >= bytes.size() or bytes[pos] != CanonicalCodec._COLON:
			failed = true
			return 0
		pos += 1
		return length

	func _read_string_body() -> String:
		var length: int = _read_length()
		if failed or pos + length > bytes.size():
			failed = true
			return ""
		var text: String = bytes.slice(pos, pos + length).get_string_from_utf8()
		if text.to_utf8_buffer() != bytes.slice(pos, pos + length):
			failed = true
			return ""
		pos += length
		return text

	func _read_array() -> Array:
		var items: Array = []
		if pos < bytes.size() and bytes[pos] == CanonicalCodec._RBRACKET:
			pos += 1
			return items
		while not failed:
			items.append(read_value())
			if failed or pos >= bytes.size():
				failed = true
				return []
			var sep: int = bytes[pos]
			pos += 1
			if sep == CanonicalCodec._RBRACKET:
				return items
			if sep != CanonicalCodec._COMMA:
				failed = true
		return []

	func _read_dict() -> Dictionary:
		var dict: Dictionary = {}
		if pos < bytes.size() and bytes[pos] == CanonicalCodec._RBRACE:
			pos += 1
			return dict
		var previous_key: String = ""
		var first: bool = true
		while not failed:
			if pos >= bytes.size() or bytes[pos] != CanonicalCodec._S:
				failed = true
				return {}
			pos += 1
			var key: String = _read_string_body()
			if failed or pos >= bytes.size() or bytes[pos] != CanonicalCodec._COLON:
				failed = true
				return {}
			pos += 1
			if not first and not (previous_key < key):
				failed = true
				return {}
			first = false
			previous_key = key
			dict[key] = read_value()
			if failed or pos >= bytes.size():
				failed = true
				return {}
			var sep: int = bytes[pos]
			pos += 1
			if sep == CanonicalCodec._RBRACE:
				return dict
			if sep != CanonicalCodec._COMMA:
				failed = true
		return {}
