extends CanvasLayer

@onready var panel: Control = $Panel

var _settings: Node = null

func _ready() -> void:
	panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	# Tant que les Settings sont ouverts en overlay, on laisse leur bouton BACK gérer.
	if _settings != null:
		return
	if event.is_action_pressed("ui_cancel"):
		if panel.visible:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()

func _pause() -> void:
	panel.show()
	get_tree().paused = true

func _resume() -> void:
	panel.hide()
	get_tree().paused = false

# ==========================================
# BUTTONS
# ==========================================
func _on_resume_pressed() -> void:
	_resume()

func _on_settings_pressed() -> void:
	_settings = preload("res://scenes/ui/screens/settings.tscn").instantiate()
	_settings.tree_exited.connect(_on_settings_closed)
	add_child(_settings)

func _on_settings_closed() -> void:
	_settings = null

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/screens/main_menu.tscn")
