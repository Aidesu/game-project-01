extends Control

## App d'exemple : affiche l'état du PC en direct depuis l'autoload Systems.

@onready var label: Label = $Label

func _ready() -> void:
	Systems.money_changed.connect(_on_changed)
	Systems.inventory_changed.connect(_on_changed)
	_refresh()

func _on_changed(_arg = null) -> void:
	_refresh()

func _refresh() -> void:
	var inv := Systems.inventory
	label.text = "Money : %s\nEarn  : %s\n\nCPU  : %d cores\nRAM  : %s\nGPU  : %d TF\nDisk : %s" % [
		Systems.format_money(),
		Systems.format_earn(),
		inv["cpu"]["cores"],
		Systems.format_storage(inv["ram"]["gb"]),
		inv["gpu"]["tflops"],
		Systems.format_storage(inv["disk"]["gb"]),
	]
