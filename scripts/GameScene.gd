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
	else:
		_place_player_at_start()
		_play_intro()

func _on_travel_requested(scene_path: String, spawn_name: String) -> void:
	await Transition.close()

	var packed: PackedScene = load(scene_path)
	if not packed:
		push_error("GameScene: cannot load scene: " + scene_path)
		Transition.open()
		return
	current_level.queue_free()
	current_level = packed.instantiate()
	world_root.add_child(current_level)
	world_root.move_child(current_level, 0)
	await get_tree().process_frame
	_place_player_at(spawn_name)

	Transition.open()

func _place_player_at(spawn_name: String) -> void:
	var marker: Node = current_level.get_node_or_null(spawn_name)
	if marker == null:
		for sp in get_tree().get_nodes_in_group("spawn_points"):
			if sp is SpawnPoint and sp.spawn_id == spawn_name:
				marker = sp
				break
	if marker:
		player.global_position = marker.global_position
	else:
		push_warning("GameScene: spawn point not found: " + spawn_name)

func _place_player_at_start() -> void:
	# Prend le SpawnPoint marqué is_start ; sinon le premier trouvé.
	var chosen: SpawnPoint = null
	for sp in get_tree().get_nodes_in_group("spawn_points"):
		if sp is SpawnPoint:
			if sp.is_start:
				chosen = sp
				break
			elif chosen == null:
				chosen = sp
	if chosen:
		player.global_position = chosen.global_position
	else:
		push_warning("GameScene: aucun SpawnPoint dans le niveau.")

# ==========================================
# CINÉMATIQUE D'INTRO (à remplir)
# ==========================================
func _play_intro() -> void:
	Cinematic.begin()
	await _intro_sequence()
	Cinematic.end()

func _intro_sequence() -> void:
	# Base visible : écran noir puis ouverture en iris.
	# Remplace/complète par ta mise en scène, par ex :
	#   await Cinematic.move_to(player, marker.global_position, 2.0)
	#   await Cinematic.wait(0.5)
	Transition.snap_closed()
	await Cinematic.wait(0.3)
	await Cinematic.fade_in()
