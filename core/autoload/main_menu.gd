extends Control

var _title_style : StyleBoxFlat
var _panel_style : StyleBoxFlat

func _ready() -> void:
	_title_style = ($CenterContainer/VBox/TitleBox.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	_panel_style = ($CenterContainer/VBox/ButtonPanel.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	$CenterContainer/VBox/TitleBox.add_theme_stylebox_override("panel", _title_style)
	$CenterContainer/VBox/ButtonPanel.add_theme_stylebox_override("panel", _panel_style)

	UITheme.accent_changed.connect(_apply_accent)
	_apply_accent(UITheme.accent)

func _apply_accent(c: Color) -> void:
	_title_style.border_color = c
	_panel_style.border_color = c
	$CenterContainer/VBox/TitleBox/TitleVBox/Title.add_theme_color_override("font_color", c)
	$CenterContainer/VBox/ButtonPanel/BtnVBox/PlayBtn.add_theme_color_override("font_color", c)
	_update_btn_hover($CenterContainer/VBox/ButtonPanel/BtnVBox/PlayBtn, c)
	_update_btn_hover($CenterContainer/VBox/ButtonPanel/BtnVBox/SettingsBtn, c)
	_update_btn_hover($CenterContainer/VBox/ButtonPanel/BtnVBox/QuitBtn, c)

func _update_btn_hover(btn: Button, c: Color) -> void:
	var s_h := StyleBoxFlat.new()
	s_h.bg_color = Color(c.r, c.g, c.b, 0.10)
	s_h.content_margin_left   = 24.0
	s_h.content_margin_right  = 24.0
	s_h.content_margin_top    = 10.0
	s_h.content_margin_bottom = 10.0
	var s_p := StyleBoxFlat.new()
	s_p.bg_color = Color(c.r, c.g, c.b, 0.20)
	s_p.content_margin_left   = 24.0
	s_p.content_margin_right  = 24.0
	s_p.content_margin_top    = 10.0
	s_p.content_margin_bottom = 10.0
	btn.add_theme_stylebox_override("hover", s_h)
	btn.add_theme_stylebox_override("pressed", s_p)

func _on_play_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_settings_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/screens/settings.tscn")

func _on_quit_btn_button_down() -> void:
	get_tree().quit()
