extends Node2D

## Poste informatique interactif. Le joueur entre dans la zone → bouton "Use"
## + touche `interact` pour ouvrir l'interface du PC. Fige le joueur pendant
## l'utilisation, le libère à la fermeture.

@onready var interaction_zone: Area2D = $InteractionZone
@onready var use_button: Button       = $UseButton
@onready var pc_interface: PcInterface = $PCInterface

var _player: Node2D = null
var _player_nearby: bool = false
var _pc_open: bool = false

func _ready() -> void:
	use_button.hide()
	interaction_zone.body_entered.connect(_on_player_entered)
	interaction_zone.body_exited.connect(_on_player_exited)
	use_button.pressed.connect(_open_pc)
	pc_interface.closed.connect(_close_pc)

func _input(event: InputEvent) -> void:
	if _player_nearby and not _pc_open and event.is_action_pressed("interact"):
		_open_pc()

# ==========================================
# ZONE DETECTION
# ==========================================
func _on_player_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		_player_nearby = true
		use_button.show()

func _on_player_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		use_button.hide()
		if _pc_open:
			_close_pc()
		_player = null

# ==========================================
# OPEN / CLOSE
# ==========================================
func _open_pc() -> void:
	if _pc_open:
		return
	_pc_open = true
	use_button.hide()
	if _player:
		_player.set_physics_process(false)
	pc_interface.open()

func _close_pc() -> void:
	if not _pc_open:
		return
	_pc_open = false
	pc_interface.visible = false
	if _player:
		_player.set_physics_process(true)
	if _player_nearby:
		use_button.show()
