extends Node2D

# ─── NPC CONFIG ───────────────────────────────────────────────
@export var npc_name: String = "PNJ"
@export var story_lines: Array[String] = [
	"C'est une belle journée...",
	"Je suis là depuis longtemps.",
	"Tu as besoin d'aide ?"
]

# ─── NODES ────────────────────────────────────────────────────
@onready var interaction_zone: Area2D  = $InteractionZone
@onready var use_button: Button        = $UseButton
@onready var dialogue_panel: Panel     = $DialogueUI/DialoguePanel
@onready var trade_panel: Panel        = $DialogueUI/TradePanel
@onready var story_panel: Panel        = $DialogueUI/StoryPanel
@onready var story_label: Label        = $DialogueUI/StoryPanel/StoryLabel
@onready var next_button: Button       = $DialogueUI/StoryPanel/NextButton

# ─── STATE ────────────────────────────────────────────────────
var player_nearby: bool = false
var story_index: int = 0

# ──────────────────────────────────────────────────────────────
func _ready() -> void:
	use_button.hide()
	dialogue_panel.hide()
	trade_panel.hide()
	story_panel.hide()

	interaction_zone.body_entered.connect(_on_player_entered)
	interaction_zone.body_exited.connect(_on_player_exited)

	use_button.pressed.connect(_open_dialogue)

	$DialogueUI/DialoguePanel/VBox/BtnTrade.pressed.connect(_open_trade)
	$DialogueUI/DialoguePanel/VBox/BtnStory.pressed.connect(_open_story)
	$DialogueUI/DialoguePanel/VBox/BtnBye.pressed.connect(_close_all)

	$DialogueUI/TradePanel/BtnBack.pressed.connect(_back_to_dialogue)
	next_button.pressed.connect(_next_story_line)


func _input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		_open_dialogue()


# ─── ZONE DETECTION ───────────────────────────────────────────
func _on_player_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		use_button.show()


func _on_player_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		use_button.hide()
		_close_all()


# ─── PANELS ───────────────────────────────────────────────────
func _open_dialogue() -> void:
	dialogue_panel.show()
	trade_panel.hide()
	story_panel.hide()


func _open_trade() -> void:
	dialogue_panel.hide()
	trade_panel.show()


func _open_story() -> void:
	story_index = 0
	_show_story_line()
	dialogue_panel.hide()
	story_panel.show()


func _close_all() -> void:
	dialogue_panel.hide()
	trade_panel.hide()
	story_panel.hide()


func _back_to_dialogue() -> void:
	trade_panel.hide()
	dialogue_panel.show()


# ─── STORY ────────────────────────────────────────────────────
func _show_story_line() -> void:
	if story_index < story_lines.size():
		story_label.text = story_lines[story_index]
	else:
		_open_dialogue()


func _next_story_line() -> void:
	story_index += 1
	_show_story_line()
