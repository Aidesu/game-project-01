extends Node

signal accent_changed(color: Color)

const PRESETS: Array[Dictionary] = [
	{ "name": "Cyan",   "color": Color(0.00, 0.82, 1.00) },
	{ "name": "Green",  "color": Color(0.18, 0.92, 0.42) },
	{ "name": "Purple", "color": Color(0.68, 0.38, 1.00) },
	{ "name": "Amber",  "color": Color(1.00, 0.74, 0.00) },
	{ "name": "Rose",   "color": Color(1.00, 0.30, 0.45) },
]

var accent: Color = PRESETS[3]["color"]
var preset_index: int = 3

func set_accent(index: int) -> void:
	preset_index = index
	accent = PRESETS[index]["color"]
	accent_changed.emit(accent)
