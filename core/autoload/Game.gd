extends Node

signal travel_requested(scene_path: String, spawn_name: String)

var spawn_point: String = ""

func change_scene(scene_path: String, spawn: String) -> void:
	spawn_point = spawn
	get_tree().change_scene_to_file(scene_path)

func travel_to(scene_path: String, spawn_name: String) -> void:
	spawn_point = spawn_name
	travel_requested.emit(scene_path, spawn_name)
