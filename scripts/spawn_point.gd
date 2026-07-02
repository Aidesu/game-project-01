class_name SpawnPoint
extends Marker2D

## Point d'apparition du joueur. Glisse-le où tu veux dans un niveau.
## - is_start : le joueur apparaît ici au lancement du niveau (un seul par niveau).
## - spawn_id : nom-cible visé par les portes (voir DoorZone.spawn_point).
@export var is_start: bool = false
@export var spawn_id: String = "start"

func _ready() -> void:
	add_to_group("spawn_points")
