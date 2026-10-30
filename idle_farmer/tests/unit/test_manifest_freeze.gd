extends GutTest
## M02-T18 (E1, TRS §20.3): published manifests are never edited in place. Each frozen manifest's
## complete content (every script field of every definition, in manifest order) is pinned by its
## canonical digest, so any change fails here and needs a new manifest ID instead.

const FROZEN: Dictionary = {
	"content_m01_v1": "4c9e212fe1aab50b004cc2ad9075d709afd12edc0142cabcbb392c90ac34a924",
	"content_m02_v1": "423e21da5a0d942ebb47d63226b2e610c1ba80a7e7899bc48dceed78bca2a1d9",  # frozen at M02-T18
}


## Every script variable of `value`, recursively, as canonical primitives.
static func _primitive(value: Variant) -> Variant:
	if value is Object:
		var out: Dictionary = {}
		for property: Dictionary in (value as Object).get_property_list():
			if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
				out[property["name"]] = _primitive((value as Object).get(property["name"]))
		return out
	if value is Array:
		var items: Array = []
		for item: Variant in value:
			items.append(_primitive(item))
		return items
	if value is PackedStringArray or value is PackedInt64Array or value is PackedInt32Array:
		return Array(value)
	if value is Dictionary:
		var copy: Dictionary = {}
		for key: Variant in value:
			copy[key] = _primitive(value[key])
		return copy
	return value


static func manifest_digest(manifest: ContentManifest) -> String:
	return CanonicalCodec.digest(_primitive(manifest))


func test_frozen_manifests_are_unchanged() -> void:
	var built: Dictionary = {"content_m01_v1": ContentM01V1.build_manifest(), "content_m02_v1": ContentM02V1.build_manifest()}
	for id: String in FROZEN:
		var manifest: ContentManifest = built[id]
		assert_eq(manifest.manifest_id, id)
		assert_eq(manifest_digest(manifest), FROZEN[id], "%s is frozen; publish a new manifest ID instead" % id)


func test_digest_covers_every_table() -> void:
	var before: String = manifest_digest(ContentM02V1.build_manifest())
	var edits: Dictionary = {
		"crop": func(m: ContentManifest) -> void: m.crops[0].base_coins += 1,
		"research": func(m: ContentManifest) -> void: m.research[0].cost += 1,
		"skill": func(m: ContentManifest) -> void: m.skills[0].effect_bp_per_rank += 1,
		"curve": func(m: ContentManifest) -> void: m.level_curve.explicit_thresholds[5] += 1,
		"upgrade": func(m: ContentManifest) -> void: m.upgrades[0].cost += 1,
		"fertilizer": func(m: ContentManifest) -> void: m.fertilizers[1].price_coef_bp += 1,
		"band": func(m: ContentManifest) -> void: m.expansion_bands[0].cost += 1,
		"economy": func(m: ContentManifest) -> void: m.economy.growth_cap_bp += 1,
	}
	for table: String in edits:
		var manifest: ContentManifest = ContentM02V1.build_manifest()
		(edits[table] as Callable).call(manifest)
		assert_ne(manifest_digest(manifest), before, table)
