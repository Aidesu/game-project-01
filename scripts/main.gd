extends Control

@onready var money_label     = $DataLabel/NinePatchRect/MoneyBox/MoneyLbl
@onready var earn_label      = $DataLabel/NinePatchRect/MoneyBox/EarnLbl
@onready var lvl_label       = $DataLabel/NinePatchRect/LvlLbl
@onready var xp_bar          = $DataLabel/NinePatchRect/XpBar
@onready var pc_label        = $DataLabel/NinePatchRect/HBoxContainer/MoboRow/MoboLbl
@onready var cpu_label       = $DataLabel/NinePatchRect/HBoxContainer/CpuRow/CpuLbl
@onready var ram_label       = $DataLabel/NinePatchRect/HBoxContainer/RamRow/RamLbl
@onready var gpu_label       = $DataLabel/NinePatchRect/HBoxContainer/GpuRow/GpuLbl
@onready var disk_label      = $DataLabel/NinePatchRect/HBoxContainer/DiskRow/DiskLbl
@onready var mobo_icon       = $DataLabel/NinePatchRect/HBoxContainer/MoboRow/MoboIcon
@onready var cpu_icon        = $DataLabel/NinePatchRect/HBoxContainer/CpuRow/CpuIcon
@onready var ram_icon        = $DataLabel/NinePatchRect/HBoxContainer/RamRow/RamIcon
@onready var gpu_icon        = $DataLabel/NinePatchRect/HBoxContainer/GpuRow/GpuIcon
@onready var disk_icon       = $DataLabel/NinePatchRect/HBoxContainer/DiskRow/DiskIcon
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

func _on_inventory_changed(type: String) -> void:
	var inv    := Systems.inventory
	var dim    := Color(0.35, 0.30, 0.25, 0.45)
	var bright := Color(1.0, 1.0, 1.0, 1.0)
	var owned: bool
	match type:
		"mobo":
			owned = int(inv["mobo"]["count"]) > 0
			mobo_icon.modulate = bright if owned else dim
			pc_label.text = "%d/%d" % [inv["mobo"]["count"], Systems.MAX_MOBO]
		"cpu":
			owned = int(inv["cpu"]["count"]) > 0
			cpu_icon.modulate = bright if owned else dim
			cpu_label.text = "%d/%d  (%dc)" % [inv["cpu"]["count"], Systems.get_cpu_slots(), inv["cpu"]["cores"]]
		"ram":
			owned = int(inv["ram"]["count"]) > 0
			ram_icon.modulate = bright if owned else dim
			ram_label.text = "%d/%d  (%s)" % [inv["ram"]["count"], Systems.get_ram_slots(), Systems.format_storage(inv["ram"]["gb"])]
		"gpu":
			owned = int(inv["gpu"]["count"]) > 0
			gpu_icon.modulate = bright if owned else dim
			gpu_label.text = "%d/%d  (%dTF)" % [inv["gpu"]["count"], Systems.get_gpu_slots(), inv["gpu"]["tflops"]]
		"disk":
			owned = int(inv["disk"]["count"]) > 0
			disk_icon.modulate = bright if owned else dim
			disk_label.text = "%d/%d  (%s)" % [inv["disk"]["count"], Systems.get_disk_slots(), Systems.format_storage(inv["disk"]["gb"])]

func _on_work_btn_button_down() -> void:
	SoundManager.play_sound("pressing")
	Systems.add_money(1000)
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
