extends Control

@onready var swatch_row: HBoxContainer = $CenterContainer/Card/VBox/AccentSection/SwatchRow
@onready var card: PanelContainer      = $CenterContainer/Card

var _swatches: Array[Button] = []
var _card_style: StyleBoxFlat

func _ready() -> void:
	_card_style = (card.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	card.add_theme_stylebox_override("panel", _card_style)

	_build_swatches()
	UITheme.accent_changed.connect(_on_accent_changed)
	_on_accent_changed(UITheme.accent)

func _build_swatches() -> void:
	for i in UITheme.PRESETS.size():
		var preset: Dictionary = UITheme.PRESETS[i]
		var color: Color = preset["color"]

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(40, 40)
		btn.tooltip_text = preset["name"]

		var s_n := _swatch_style(color, false)
		var s_h := _swatch_style(color, true)
		btn.add_theme_stylebox_override("normal",   s_n)
		btn.add_theme_stylebox_override("hover",    s_h)
		btn.add_theme_stylebox_override("pressed",  s_h)
		btn.add_theme_stylebox_override("focus",    s_n)
		btn.add_theme_stylebox_override("disabled", s_n)

		var idx := i
		btn.pressed.connect(func(): UITheme.set_accent(idx))
		swatch_row.add_child(btn)
		_swatches.append(btn)

func _swatch_style(color: Color, bright: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color.darkened(0.3 if not bright else 0.0)
	s.border_width_left   = 2
	s.border_width_right  = 2
	s.border_width_top    = 2
	s.border_width_bottom = 2
	s.border_color = Color(color.r, color.g, color.b, 0.0)
	return s

func _on_accent_changed(c: Color) -> void:
	_card_style.border_color = c
	_highlight_selected()
	_update_back_hover(c)

func _update_back_hover(c: Color) -> void:
	var back := $CenterContainer/Card/VBox/BackBtn
	var s_h := StyleBoxFlat.new()
	s_h.bg_color = Color(c.r, c.g, c.b, 0.12)
	s_h.content_margin_left   = 20.0
	s_h.content_margin_right  = 20.0
	s_h.content_margin_top    = 8.0
	s_h.content_margin_bottom = 8.0
	var s_p := StyleBoxFlat.new()
	s_p.bg_color = Color(c.r, c.g, c.b, 0.22)
	s_p.content_margin_left   = 20.0
	s_p.content_margin_right  = 20.0
	s_p.content_margin_top    = 8.0
	s_p.content_margin_bottom = 8.0
	back.add_theme_stylebox_override("hover", s_h)
	back.add_theme_stylebox_override("pressed", s_p)

func _highlight_selected() -> void:
	for i in _swatches.size():
		var btn  := _swatches[i]
		var col  : Color = UITheme.PRESETS[i]["color"]
		var is_sel := (i == UITheme.preset_index)

		var s_n := _swatch_style(col, false)
		if is_sel:
			s_n.border_color = col
			s_n.border_width_left   = 2
			s_n.border_width_right  = 2
			s_n.border_width_top    = 2
			s_n.border_width_bottom = 2
		btn.add_theme_stylebox_override("normal", s_n)
		btn.add_theme_stylebox_override("focus",  s_n)

func _on_back_btn_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/screens/main_menu.tscn")
