extends Control

func _on_play_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_settings_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/screens/settings.tscn")

func _on_quit_btn_button_down() -> void:
	get_tree().quit()
