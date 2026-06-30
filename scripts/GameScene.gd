extends Node

@onready var world_root: Node2D = $World
@onready var player: CharacterBody2D = $World/Player

var current_level: Node = null

func _ready() -> void:
	current_level = $World/World
	Game.travel_requested.connect(_on_travel_requested)
	if Game.spawn_point != "":
		_place_player_at(Game.spawn_point)
		Game.spawn_point = ""

func _on_travel_requested(scene_path: String, spawn_name: String) -> void:
	var packed: PackedScene = load(scene_path)
	if not packed:
		push_error("GameScene: cannot load scene: " + scene_path)
		return
	current_level.queue_free()
	current_level = packed.instantiate()
	world_root.add_child(current_level)
	world_root.move_child(current_level, 0)
	await get_tree().process_frame
	_place_player_at(spawn_name)

func _place_player_at(spawn_name: String) -> void:
	var marker: Node = current_level.get_node_or_null(spawn_name)
	if marker:
		player.global_position = marker.global_position
	else:
		push_warning("GameScene: spawn point not found: " + spawn_name)
