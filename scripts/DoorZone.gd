extends Area2D

@export_file("*.tscn") var target_scene: String
@export var spawn_point: String

var _triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.is_in_group("player"):
		_triggered = true
		Game.travel_to(target_scene, spawn_point)
