extends Control

func _on_play_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_btn_button_down() -> void:
	get_tree().quit()
