class_name ManifestFixtures
extends RefCounted
## Counterfactual manifests for AV-003 (DVS-019). They are separate, newly-identified manifests —
## never edits of content_m01_v1 — exactly as TRS §20.3 requires for changed-curve tests.


## Level 7 moved from 5,200 to 6,000 XP (AV-003-01).
static func level7_at_6000() -> ContentManifest:
	var m: ContentManifest = ContentM01V1.build_manifest()
	m.manifest_id = "test_l7_6000"
	m.level_curve.explicit_thresholds[6] = 6_000
	return m


## Lowered early thresholds and a reduced rank maximum (AV-003-02).
static func lowered_and_rank_changed() -> ContentManifest:
	var m: ContentManifest = ContentM01V1.build_manifest()
	m.manifest_id = "test_lowered"
	m.level_curve.explicit_thresholds[1] = 100
	m.level_curve.explicit_thresholds[2] = 200
	for skill: SkillDefinition in m.skills:
		if skill.id == "faster_germination":
			skill.max_ranks = 2
	return m


## Catalog supporting the given manifests (v1 included unless `include_v1` is false).
static func catalog(extra: Array[ContentManifest] = [], include_v1: bool = true) -> ManifestCatalog:
	var c: ManifestCatalog = ManifestCatalog.new()
	if include_v1:
		c.register(Fixtures.registry())
	for manifest: ContentManifest in extra:
		c.register(ContentRegistry.build(manifest))
	return c
