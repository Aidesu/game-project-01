extends Control

@onready var money_label     = $TopBar/HBox/MoneyBox/MoneyLbl
@onready var earn_label      = $TopBar/HBox/MoneyBox/EarnLbl
@onready var lvl_label       = $TopBar/HBox/LevelBox/LvlLbl
@onready var xp_bar          = $TopBar/HBox/LevelBox/XpBar
@onready var earn_rate_label = $StatsSidebar/VBox/IncomeValueLbl
@onready var pc_label        = $DataLabel/HBoxContainer/MoboRow/MoboLbl
@onready var cpu_label       = $DataLabel/HBoxContainer/CpuRow/CpuLbl
@onready var ram_label       = $DataLabel/HBoxContainer/RamRow/RamLbl
@onready var gpu_label       = $DataLabel/HBoxContainer/GpuRow/GpuLbl
@onready var disk_label      = $DataLabel/HBoxContainer/DiskRow/DiskLbl
@onready var mobo_icon       = $DataLabel/HBoxContainer/MoboRow/MoboIcon
@onready var cpu_icon        = $DataLabel/HBoxContainer/CpuRow/CpuIcon
@onready var ram_icon        = $DataLabel/HBoxContainer/RamRow/RamIcon
@onready var gpu_icon        = $DataLabel/HBoxContainer/GpuRow/GpuIcon
@onready var disk_icon       = $DataLabel/HBoxContainer/DiskRow/DiskIcon
@onready var shop_list       = $Shop/Panel/VBox/ScrollContainer/VBoxContainer

func _ready() -> void:
	$Shop.hide()

	Systems.money_changed.connect(_on_money_changed)
	Systems.xp_changed.connect(_on_xp_changed)
	Systems.inventory_changed.connect(_on_inventory_changed)
	Systems.earn_rate_changed.connect(_on_earn_rate_changed)

	_on_money_changed(Systems.money)
	_on_xp_changed(Systems.xp, Systems.lvl, Systems.lvl_xp)
	_on_earn_rate_changed(Systems.earn_per_sec)
	for type in Systems.inventory:
		_on_inventory_changed(type)

	_build_shop()

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
			pc_label.text = "%d/1  (%d slots)" % [inv["mobo"]["count"], inv["mobo"]["ram_slots"]]
		"cpu":
			owned = int(inv["cpu"]["count"]) > 0
			cpu_icon.modulate = bright if owned else dim
			cpu_label.text = "%d/%d  (%dc)" % [inv["cpu"]["count"], Systems.MAX_CPU, inv["cpu"]["cores"]]
		"ram":
			owned = int(inv["ram"]["count"]) > 0
			ram_icon.modulate = bright if owned else dim
			ram_label.text = "%d/%d  (%dGB)" % [inv["ram"]["count"], Systems.get_ram_slots(), inv["ram"]["gb"]]
		"gpu":
			owned = int(inv["gpu"]["count"]) > 0
			gpu_icon.modulate = bright if owned else dim
			gpu_label.text = "%d/%d  (%dTF)" % [inv["gpu"]["count"], Systems.MAX_GPU, inv["gpu"]["tflops"]]
		"disk":
			owned = int(inv["disk"]["count"]) > 0
			disk_icon.modulate = bright if owned else dim
			disk_label.text = "%d/%d  (%dGB)" % [inv["disk"]["count"], Systems.MAX_DISK, inv["disk"]["gb"]]

func _on_work_btn_button_down() -> void:
	SoundManager.play_sound("pressing")
	Systems.add_money(10)
	Systems.add_xp(25)

func _on_shop_btn_button_down() -> void:
	_build_shop()
	$Shop.show()

func _on_exit_btn_button_down() -> void:
	$Shop.hide()

func _build_shop() -> void:
	for child in shop_list.get_children():
		child.queue_free()

	for item in Systems.CATALOG:
		var can := Systems.can_buy(item)
		var btn := Button.new()
		btn.text = "%-20s  $%d" % [item["name"], item["price"]]
		btn.disabled  = not can
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _try_buy(item))
		shop_list.add_child(btn)

func _try_buy(item: Dictionary) -> void:
	if Systems.buy_item(item):
		_build_shop()
