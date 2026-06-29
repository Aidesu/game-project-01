extends Control

##########################
# PLAYER STATS
##########################

var xp = 0
var lvl_xp = 200
var xp_earn = 25
var money = 0
var lvl = 0

var earn_by_sec = 0

##########################
# INVENTORY SYSTEM
##########################

var inventory = {
	"mobo": {"count": 0, "max": 1, "power": 0},
	"ram": {"count": 0, "max": 2, "power": 0},
	"cpu": {"count": 0, "max": 1, "power": 0},
	"gpu": {"count": 0, "max": 2, "power": 0},
	"disk": {"count": 0, "max": 6, "power": 0}
}

##########################
# SHOP DATA
##########################

var shopping_items = [
	{
		"type": "ram",
		"name": "RAM 1GB",
		"price": 100,
		"texture": preload("res://ressources/textures/items/RAM-01.png"),
		"bonus": 1
	},
	{
		"type": "ram",
		"name": "RAM 2GB",
		"price": 500,
		"texture": preload("res://ressources/textures/items/RAM-02.png"),
		"bonus": 2
	},
	{
		"type": "ram",
		"name": "RAM 4GB",
		"price": 1200,
		"texture": preload("res://ressources/textures/items/RAM-03.png"),
		"bonus": 4
	},
	{
		"type": "ram",
		"name": "RAM 8GB",
		"price": 3000,
		"texture": preload("res://ressources/textures/items/RAM-04.png"),
		"bonus": 8
	},
##########################
# CPU
##########################
	{
		"type": "cpu",
		"name": "2 core CPU",
		"price": 500,
		"texture": preload("res://ressources/textures/items/CPU-02.png"),
		"bonus": 8
	},
	{
		"type": "cpu",
		"name": "4 core CPU",
		"price": 1000,
		"texture": preload("res://ressources/textures/items/CPU-01.png"),
		"bonus": 16
	},
##########################
# HDD
##########################
	{
		"type": "disk",
		"name": "256GB",
		"price": 250,
		"texture": preload("res://ressources/textures/items/HDD-01.png"),
		"bonus": 2
	},
	{
		"type": "disk",
		"name": "512GB",
		"price": 550,
		"texture": preload("res://ressources/textures/items/HDD-02.png"),
		"bonus": 2
	},
	{
		"type": "disk",
		"name": "1TB",
		"price": 850,
		"texture": preload("res://ressources/textures/items/HDD-03.png"),
		"bonus": 2
	},
	{
		"type": "disk",
		"name": "2TB",
		"price": 4000,
		"texture": preload("res://ressources/textures/items/HDD-04.png"),
		"bonus": 2
	},
##########################
# MotherBoard
##########################
	{
		"type": "mobo",
		"name": "Cheap Motherboard",
		"price": 100,
		"texture": preload("res://ressources/textures/items/MOBO-01.png"),
		"bonus": 1
	},
]

##########################
# NODES
##########################

@onready var lvl_label = $LvlLbl
@onready var xp_bar = $XpBar
@onready var money_label = $MoneyLbl
@onready var shop_list = $Shop/ScrollContainer/VBoxContainer
@onready var pc_label = $VBoxContainer/TotalPcLbl
@onready var cpu_label = $VBoxContainer/TotalCpuLbl
@onready var ram_label = $VBoxContainer/TotalRamLbl
@onready var gpu_label = $VBoxContainer/TotalFlopLbl
@onready var disk_label = $VBoxContainer/TotalStorageLbl

##########################
# READY
##########################

func _ready() -> void:
	$Shop.hide()
	build_shop()
	for i in inventory:
		update_ui(i)

	# idle income loop (PROPRE)
	while true:
		await get_tree().create_timer(1.0).timeout
		money += earn_by_sec
		money_refresh()

##########################
# INPUT / BUTTONS
##########################

func _on_work_btn_button_down() -> void:
	SoundManager.play_sound("pressing")
	money += 10
	xp += xp_earn
	money_refresh()
	refresh_xp()

func _on_shop_btn_button_down() -> void:
	$Shop.show()

func _on_exit_btn_button_down() -> void:
	$Shop.hide()

##########################
# MONEY UI
##########################

func money_refresh() -> void:
	money_label.text = "$" + str(money)

##########################
# XP SYSTEM
##########################

func refresh_xp() -> void:
	xp_bar.max_value = lvl_xp
	xp_bar.value = xp

	if xp >= lvl_xp:
		lvl += 1
		xp = 0
		lvl_xp *= 1.8

		SoundManager.play_sound("lvl_up")

		lvl_label.text = str(lvl)

##########################
# SHOP SYSTEM
##########################

func build_shop():
	for item in shopping_items:
		var card = Button.new()

		card.text = item.name + " - $" + str(item.price)
		card.icon = item.texture

		card.pressed.connect(func():
			buy_item(item)
		)

		shop_list.add_child(card)

##########################
# GENERIC BUY SYSTEM
##########################

func buy_item(item):

	var type = item.type
	var data = inventory[type]

	# check money
	if money < item.price:
		print("Not enough money")
		return

	# check max
	if data.count >= data.max:
		print("Max reached for", type)
		return

	# purchase
	SoundManager.play_sound("buying")
	money -= item.price
	money_refresh()

	data.count += 1
	data.power += item.bonus

	inventory[type] = data

	# recompute income
	update_earnings()

	# UI update (RAM only for now)
	update_ui(type)

	print("Bought:", item.name)

##########################
# ECONOMY CALCULATION
##########################

func update_earnings():
	earn_by_sec = 0

	for type in inventory:
		earn_by_sec += inventory[type].power

##########################
# UI UPDATE
##########################

func update_ui(type):

	if type == "ram":
		var data = inventory["ram"]
		ram_label.text = str(data.count) + "/" + str(data.max) + " RAM (" + str(data.power) + "Gb)"
	
	elif type == "mobo":
		var data = inventory["mobo"]
		pc_label.text = str(data.count) + "/" + str(data.max) + " PC (" + str(data.power) + " Unit)"

	elif type == "cpu":
		var data = inventory["cpu"]
		cpu_label.text = str(data.count) + "/" + str(data.max) + " CPU (" + str(data.power) + " cores)"

	elif type == "gpu":
		var data = inventory["gpu"]
		gpu_label.text = str(data.count) + "/" + str(data.max) + " GPU (" + str(data.power) + "TFLOPS)"
		
	elif type == "disk":
		var data = inventory["disk"]
		disk_label.text = str(data.count) + "/" + str(data.max) + " DISK (" + str(data.power) + "Gb)"
	else:
		print("type" + type + " not found")
