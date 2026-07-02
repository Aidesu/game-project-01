extends Control

@onready var volume_slider: HSlider = $CenterContainer/Card/VBox/SoundSection/VolumeSlider

func _ready() -> void:
	var bus := AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus))
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_volume_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value <= 0.0)

func _on_back_btn_button_down() -> void:
	if get_tree().current_scene == self:
		# Ouvert comme scène principale (depuis le menu) → retour au menu.
		get_tree().change_scene_to_file("res://scenes/ui/screens/main_menu.tscn")
	else:
		# Ouvert en overlay (depuis le menu pause) → simple fermeture.
		queue_free()
