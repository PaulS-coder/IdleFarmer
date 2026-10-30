class_name ManifestCatalog
extends RefCounted
## The set of supported immutable manifests in this build (TRS §20.3). A profile resolves its bound
## `content_version` here before validation, quotes or input; an unknown ID is a recoverable error
## and is never replaced by the latest manifest.

var _registries: Dictionary[String, ContentRegistry] = {}


## Registers a valid registry. Returns "" on success or an error string; never replaces an
## already-registered manifest ID (published manifests are not edited in place).
func register(registry: ContentRegistry) -> String:
	if registry == null or not registry.is_valid():
		return "MANIFEST_INVALID: cannot register an invalid registry"
	if _registries.has(registry.manifest_id()):
		return "MANIFEST_ALREADY_REGISTERED: '%s'" % registry.manifest_id()
	_registries[registry.manifest_id()] = registry
	return ""


func is_supported(manifest_id: String) -> bool:
	return _registries.has(manifest_id)


## The registry bound to `manifest_id`, or null when unsupported.
func resolve(manifest_id: String) -> ContentRegistry:
	return _registries.get(manifest_id, null)


func supported_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray(_registries.keys())
	ids.sort()
	return ids
