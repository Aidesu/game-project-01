extends Control

# ==========================================
# NODES
# ==========================================
@onready var money_label     = $TopBar/HBox/MoneyBox/MoneyLbl
@onready var earn_label      = $TopBar/HBox/MoneyBox/EarnLbl
@onready var lvl_label       = $TopBar/HBox/LevelBox/LvlLbl
@onready var xp_bar          = $TopBar/HBox/LevelBox/XpBar
@onready var earn_rate_label = $StatsSidebar/VBox/IncomeValueLbl
@onready var pc_label        = $StatsSidebar/VBox/BuildSection/MoboRow/MoboLbl
@onready var cpu_label       = $StatsSidebar/VBox/BuildSection/CpuRow/CpuLbl
@onready var ram_label       = $StatsSidebar/VBox/BuildSection/RamRow/RamLbl
@onready var gpu_label       = $StatsSidebar/VBox/BuildSection/GpuRow/GpuLbl
@onready var disk_label      = $StatsSidebar/VBox/BuildSection/DiskRow/DiskLbl
@onready var mobo_icon       = $StatsSidebar/VBox/BuildSection/MoboRow/MoboIcon
@onready var cpu_icon        = $StatsSidebar/VBox/BuildSection/CpuRow/CpuIcon
@onready var ram_icon        = $StatsSidebar/VBox/BuildSection/RamRow/RamIcon
@onready var gpu_icon        = $StatsSidebar/VBox/BuildSection/GpuRow/GpuIcon
@onready var disk_icon       = $StatsSidebar/VBox/BuildSection/DiskRow/DiskIcon
@onready var shop_list       = $Shop/Panel/VBox/ScrollContainer/VBoxContainer

# ==========================================
# ACCENT STYLES
# ==========================================
var _xp_fill    := StyleBoxFlat.new()
var _bar_style  : StyleBoxFlat
var _bbar_style : StyleBoxFlat
var _panel_style: StyleBoxFlat
var _shop_style : StyleBoxFlat

# ==========================================
# READY
# ==========================================
func _ready() -> void:
	$Shop.hide()
	_setup_styles()

	Systems.money_changed.connect(_on_money_changed)
	Systems.xp_changed.connect(_on_xp_changed)
	Systems.inventory_changed.connect(_on_inventory_changed)
	Systems.earn_rate_changed.connect(_on_earn_rate_changed)

	_on_money_changed(Systems.money)
	_on_xp_changed(Systems.xp, Systems.lvl, Systems.lvl_xp)
	_on_earn_rate_changed(Systems.earn_per_sec)
	for type in Systems.inventory:
		_on_inventory_changed(type)

	UITheme.accent_changed.connect(_apply_accent)
	_apply_accent(UITheme.accent)

	_build_shop()

# ==========================================
# STYLE SETUP
# ==========================================
func _setup_styles() -> void:
	_bar_style   = ($TopBar.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	_bbar_style  = ($BottomBar.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	_panel_style = ($StatsSidebar.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	_shop_style  = ($Shop/Panel.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	$TopBar.add_theme_stylebox_override("panel", _bar_style)
	$BottomBar.add_theme_stylebox_override("panel", _bbar_style)
	$StatsSidebar.add_theme_stylebox_override("panel", _panel_style)
	$Shop/Panel.add_theme_stylebox_override("panel", _shop_style)
	xp_bar.add_theme_stylebox_override("fill", _xp_fill)

func _apply_accent(c: Color) -> void:
	_xp_fill.bg_color        = c
	_bar_style.border_color  = c
	_bbar_style.border_color = c
	_panel_style.border_color = c
	_shop_style.border_color  = Color(c.r, c.g, c.b, 0.55)

	earn_label.add_theme_color_override("font_color", c)
	lvl_label.add_theme_color_override("font_color", c)
	earn_rate_label.add_theme_color_override("font_color", c)
	$StatsSidebar/VBox/BuildTitle.add_theme_color_override("font_color", Color(c.r, c.g, c.b, 0.55))
	$Shop/Panel/VBox/Header/TitleLbl.add_theme_color_override("font_color", c)

	for btn: Button in shop_list.get_children():
		if not btn.disabled:
			btn.add_theme_color_override("font_color", c)
		_apply_btn_hover_style(btn, c)

# ==========================================
# SIGNAUX SYSTEMS
# ==========================================
func _on_money_changed(_amount: int) -> void:
	money_label.text = Systems.format_money()

func _on_xp_changed(xp: int, lvl: int, lvl_xp: int) -> void:
	xp_bar.max_value = lvl_xp
	xp_bar.value = xp
	lvl_label.text = "LVL " + str(lvl)

func _on_earn_rate_changed(_rate: float) -> void:
	var fmt := Systems.format_earn()
	earn_label.text = "+" + fmt
	earn_rate_label.text = "+" + fmt

func _on_inventory_changed(type: String) -> void:
	var inv    := Systems.inventory
	var dim    := Color(0.35, 0.30, 0.25, 0.45)
	var bright := Color(1.0, 1.0, 1.0, 1.0)
	var owned: bool
	match type:
		"mobo":
			owned = int(inv["mobo"]["count"]) > 0
			mobo_icon.modulate = bright if owned else dim
			pc_label.text = "PC: %d/1  (%d slots)" % [inv["mobo"]["count"], inv["mobo"]["ram_slots"]]
		"cpu":
			owned = int(inv["cpu"]["count"]) > 0
			cpu_icon.modulate = bright if owned else dim
			cpu_label.text = "CPU: %d/%d  (%dc)" % [inv["cpu"]["count"], Systems.MAX_CPU, inv["cpu"]["cores"]]
		"ram":
			owned = int(inv["ram"]["count"]) > 0
			ram_icon.modulate = bright if owned else dim
			ram_label.text = "RAM: %d/%d  (%dGB)" % [inv["ram"]["count"], Systems.get_ram_slots(), inv["ram"]["gb"]]
		"gpu":
			owned = int(inv["gpu"]["count"]) > 0
			gpu_icon.modulate = bright if owned else dim
			gpu_label.text = "GPU: %d/%d  (%dTF)" % [inv["gpu"]["count"], Systems.MAX_GPU, inv["gpu"]["tflops"]]
		"disk":
			owned = int(inv["disk"]["count"]) > 0
			disk_icon.modulate = bright if owned else dim
			disk_label.text = "DISK: %d/%d  (%dGB)" % [inv["disk"]["count"], Systems.MAX_DISK, inv["disk"]["gb"]]

# ==========================================
# BOUTONS HUD
# ==========================================
func _on_work_btn_button_down() -> void:
	SoundManager.play_sound("pressing")
	Systems.add_money(10)
	Systems.add_xp(25)

func _on_shop_btn_button_down() -> void:
	_build_shop()
	$Shop.show()

func _on_exit_btn_button_down() -> void:
	$Shop.hide()

# ==========================================
# SHOP
# ==========================================
func _build_shop() -> void:
	for child in shop_list.get_children():
		child.queue_free()

	var accent       := UITheme.accent
	var col_disabled := Color(0.42, 0.38, 0.32, 1.0)

	for item in Systems.CATALOG:
		var can := Systems.can_buy(item)
		var btn := Button.new()
		btn.text = "%-20s  $%d" % [item["name"], item["price"]]
		btn.disabled  = not can
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 12)

		var s_n := _make_item_box(Color(0.090, 0.085, 0.104, 1.0))
		btn.add_theme_stylebox_override("normal",   s_n)
		btn.add_theme_stylebox_override("disabled", s_n)
		_apply_btn_hover_style(btn, accent)

		btn.add_theme_color_override("font_color",
			accent if can else col_disabled)
		btn.add_theme_color_override("font_disabled_color", col_disabled)

		btn.pressed.connect(func(): _try_buy(item))
		shop_list.add_child(btn)

func _try_buy(item: Dictionary) -> void:
	if Systems.buy_item(item):
		_build_shop()

# ==========================================
# HELPERS
# ==========================================
func _make_item_box(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.content_margin_left   = 12.0
	s.content_margin_right  = 12.0
	s.content_margin_top    = 7.0
	s.content_margin_bottom = 7.0
	return s

func _apply_btn_hover_style(btn: Button, c: Color) -> void:
	btn.add_theme_stylebox_override("hover",   _make_item_box(Color(c.r, c.g, c.b, 0.10)))
	btn.add_theme_stylebox_override("pressed", _make_item_box(Color(c.r, c.g, c.b, 0.20)))
	btn.add_theme_stylebox_override("focus",   _make_item_box(Color(0, 0, 0, 0)))
