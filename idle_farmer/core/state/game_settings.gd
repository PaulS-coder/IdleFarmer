class_name GameSettings
extends RefCounted
## Profile-owned versioned preferences (DEC-021, TRS §3.5). Debug speed is deliberately absent:
## it resets to 1× every launch and is never persisted. Default values are provisional.

const CURRENT_VERSION: int = 1

var version: int = CURRENT_VERSION
var sound_enabled: bool = true
var music_volume: int = 80
var sfx_volume: int = 80


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if version != CURRENT_VERSION:
		errors.append("SETTINGS_VERSION_UNSUPPORTED: %d" % version)
	if music_volume < 0 or music_volume > 100 or sfx_volume < 0 or sfx_volume > 100:
		errors.append("SETTINGS_VOLUME_RANGE: volumes must be 0–100")
	return errors


func to_primitive() -> Dictionary:
	return {"version": version, "sound_enabled": sound_enabled, "music_volume": music_volume, "sfx_volume": sfx_volume}


static func from_primitive(value: Variant) -> GameSettings:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "GameSettings")
	reader.expect_only(PackedStringArray(["version", "sound_enabled", "music_volume", "sfx_volume"]))
	var settings: GameSettings = GameSettings.new()
	settings.version = reader.int_field("version")
	settings.sound_enabled = reader.bool_field("sound_enabled")
	settings.music_volume = reader.int_field("music_volume")
	settings.sfx_volume = reader.int_field("sfx_volume")
	if not reader.ok():
		return null
	return settings
