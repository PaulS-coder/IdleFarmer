extends GutTest
## M01-T05 groundwork / P5: canonical encoding, digest and lossless round-trip (AV-001-04 codec part).


func _bytes(text: String) -> PackedByteArray:
	return text.to_utf8_buffer()


func test_encoding_and_digest_match_independent_oracle() -> void:
	for c: Array in OracleVectors.CODEC:
		var encoded: PackedByteArray = CanonicalCodec.encode(c[0])
		assert_eq(encoded.get_string_from_utf8(), c[1], "encoding of %s" % str(c[0]))
		assert_eq(CanonicalCodec.digest(c[0]), c[2], "digest of %s" % str(c[0]))


func test_round_trip_is_lossless_at_int64_bounds() -> void:
	for c: Array in OracleVectors.CODEC:
		var decoded: Dictionary = CanonicalCodec.decode(CanonicalCodec.encode(c[0]))
		assert_true(decoded["ok"], "decode %s" % c[1])
		assert_eq(CanonicalCodec.digest(decoded["value"]), c[2], "round-trip digest %s" % c[1])
	var decoded_max: Dictionary = CanonicalCodec.decode(_bytes("i9223372036854775807"))
	assert_eq(typeof(decoded_max["value"]), TYPE_INT, "int stays int (never float)")
	assert_eq(decoded_max["value"], IntegerMath.INT64_MAX)
	assert_eq(CanonicalCodec.decode(_bytes("i-9223372036854775808"))["value"], IntegerMath.INT64_MIN)


func test_key_insertion_order_does_not_change_digest() -> void:
	var first: Dictionary = {"a": 1, "b": [1, 2], "c": {"y": null, "x": true}}
	var second: Dictionary = {"c": {"x": true, "y": null}, "b": [1, 2], "a": 1}
	assert_eq(CanonicalCodec.digest(first), CanonicalCodec.digest(second))


func test_digest_distinguishes_type_and_order() -> void:
	assert_ne(CanonicalCodec.digest(1), CanonicalCodec.digest("1"), "int vs string")
	assert_ne(CanonicalCodec.digest([1, 2]), CanonicalCodec.digest([2, 1]), "array order matters")
	assert_ne(CanonicalCodec.digest(null), CanonicalCodec.digest(false), "null vs false")


func test_rejects_unsupported_values() -> void:
	var rejected: Array = [
		1.5, 0.0, Vector2.ZERO, &"name", PackedInt64Array([1]), RefCounted.new(),
		{1: "int key"}, {&"sn": 1}, [1, 2.0], {"nested": [{"bad": 3.0}]},
	]
	for value: Variant in rejected:
		assert_false(CanonicalCodec.is_encodable(value), "reject %s" % type_string(typeof(value)))
		assert_eq(CanonicalCodec.digest(value), "", "no digest for %s" % type_string(typeof(value)))


func test_decode_rejects_malformed_and_noncanonical_input() -> void:
	var bad: PackedStringArray = [
		"", "x", "i", "i-", "i-0", "i01", "i9223372036854775808", "i-9223372036854775809",
		"s3:ab", "s01:a", "s1a", "[i1", "[i1,]", "[,]", "{s1:a:i1", "{s1:b:i1,s1:a:i2}",
		"{s1:a:i1,s1:a:i2}", "{i1:i1}", "nn", "t ", "[i1]x",
	]
	for text: String in bad:
		assert_false(CanonicalCodec.decode(_bytes(text))["ok"], "reject '%s'" % text)
	var invalid_utf8: PackedByteArray = PackedByteArray([0x73, 0x31, 0x3A, 0xFF])
	assert_false(CanonicalCodec.decode(invalid_utf8)["ok"], "reject invalid UTF-8")
