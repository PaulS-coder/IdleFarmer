class_name TermsCommand
extends GameCommand
## Accepted command whose confirmed terms are a flat, typed dictionary (purchase-style commands,
## M02 build plan §3.3). Subclasses declare a SCHEMA {key: Variant.Type} and range checks; the
## terms are copied at construction and only readable afterwards, so the envelope stays immutable.

var _terms: Dictionary = {}


func _init(p_command_id: CommandId, p_type: String, p_accepted_time_us: int, p_accepted_order: int, p_terms: Dictionary) -> void:
	super(p_command_id, p_type, p_accepted_time_us, p_accepted_order)
	_terms = p_terms.duplicate(true)


## Strictly decoded terms (exact keys, exact types), or null when malformed.
static func decode_terms(args: Dictionary, schema: Dictionary, context: String) -> Variant:
	var reader: PrimitiveReader = PrimitiveReader.new(args, context)
	reader.expect_only(PackedStringArray(schema.keys()))
	var terms: Dictionary = {}
	for key: String in schema:
		match schema[key]:
			TYPE_INT:
				terms[key] = reader.int_field(key)
			TYPE_STRING:
				terms[key] = reader.string_field(key)
			TYPE_BOOL:
				terms[key] = reader.bool_field(key)
	return terms if reader.ok() else null


func term(key: String) -> Variant:
	return _terms.get(key)


func terms() -> Dictionary:
	return _terms.duplicate(true)


func _args_primitive() -> Dictionary:
	return PrimitiveReader.plain(_terms)
