extends Area2D

@export_file("*.tscn") var target_scene
@export var spawn_point: String

signal player_entered(target_scene, spawn_point)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_entered.emit(target_scene, spawn_point)
