class_name CropCatalogV1
extends RefCounted
## Provisional crop and research source data, transcribed from FRS §4.2 (crops) and §8 (research).
## Durations are whole minutes here and converted to microseconds by the manifest builder.
## All values are provisional development data, not final balance (FRS §4.2).

## [id, display name, class, required level, growth minutes, seed cost, gross coins, XP]
const CROPS: Array[Array] = [
	["wheat", "Wheat", "basic", 1, 8, 0, 16, 6],
	["carrots", "Carrots", "basic", 2, 15, 0, 36, 12],
	["corn", "Corn", "advanced", 4, 30, 18, 110, 32],
	["tomatoes", "Tomatoes", "advanced", 7, 60, 55, 270, 70],
	["pumpkins", "Pumpkins", "advanced", 10, 180, 300, 1200, 230],
	["sunflowers", "Sunflowers", "advanced", 12, 90, 230, 810, 125],
	["strawberries", "Strawberries", "advanced", 12, 45, 185, 445, 105],
	["blueberries", "Blueberries", "advanced", 15, 120, 450, 1600, 180],
	["soybeans", "Soybeans", "advanced", 15, 60, 300, 785, 185],
	["grapes", "Grapes", "advanced", 18, 240, 2000, 5900, 480],
	["coffee", "Coffee", "advanced", 18, 180, 1900, 4400, 750],
	["cotton", "Cotton", "advanced", 22, 300, 4500, 12500, 950],
	["rice", "Rice", "advanced", 22, 75, 1150, 2900, 370],
	["vanilla", "Vanilla", "advanced", 26, 360, 7200, 24500, 1900],
	["saffron", "Saffron", "advanced", 26, 120, 6000, 10000, 1100],
]

## [crop id, required level, research cost, research minutes]; research ID is "unlock_<crop id>".
## Wheat is a start unlock and has no research project (DEC-003).
const RESEARCH: Array[Array] = [
	["carrots", 2, 150, 8],
	["corn", 4, 800, 20],
	["tomatoes", 7, 2800, 45],
	["pumpkins", 10, 9000, 120],
	["sunflowers", 12, 10000, 60],
	["strawberries", 12, 12000, 45],
	["blueberries", 15, 24000, 90],
	["soybeans", 15, 26000, 60],
	["grapes", 18, 55000, 120],
	["coffee", 18, 55000, 120],
	["cotton", 22, 120000, 180],
	["rice", 22, 110000, 150],
	["vanilla", 26, 300000, 300],
	["saffron", 26, 250000, 240],
]

const START_UNLOCKED: PackedStringArray = ["wheat"]

## FRS §2.1 stage names; references are labeled placeholders until M04 art exists.
const STAGE_NAMES: PackedStringArray = ["planted", "sprouting", "growing", "ripening", "ready"]
