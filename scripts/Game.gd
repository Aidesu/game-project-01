extends Node

var spawn_point = ""

func change_scene(scene_path: String, spawn: String):
	spawn_point = spawn
	get_tree().change_scene_to_file(scene_path)
