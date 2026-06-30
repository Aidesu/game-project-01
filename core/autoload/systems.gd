extends Node

# ==========================================
# SIGNALS
# ==========================================
signal money_changed(amount: int)
signal xp_changed(xp: int, lvl: int, lvl_xp: int)
signal inventory_changed(type: String)
signal earn_rate_changed(rate: float)
signal level_up(new_lvl: int)

# ==========================================
# ECONOMY STATE
# ==========================================
var money: int = 0
var xp: int = 0
var lvl: int = 1
var lvl_xp: int = 200
var earn_per_sec: float = 0.0

var _earn_accumulator: float = 0.0

# ==========================================
# INVENTORY
# ==========================================
# mobo  : count (0|1), ram_slots (2/4/6/8)
# cpu   : count (0|1), cores (int)
# ram   : count (0..mobo.ram_slots), gb (int)
# gpu   : count (0..MAX_GPU), tflops (int)
# disk  : count (0..MAX_DISK), gb (int)
var inventory: Dictionary = {
	"mobo": { "count": 0, "ram_slots": 0 },
	"cpu":  { "count": 0, "cores": 0 },
	"ram":  { "count": 0, "gb": 0 },
	"gpu":  { "count": 0, "tflops": 0 },
	"disk": { "count": 0, "gb": 0 },
}

const MAX_CPU:  int = 1
const MAX_GPU:  int = 2
const MAX_DISK: int = 6

# ==========================================
# SHOP CATALOG (pure data — no textures)
# UI layer maps names/types to textures itself
#
# Fields per type:
#   mobo → ram_slots
#   cpu  → cores
#   ram  → gb
#   gpu  → tflops
#   disk → gb
# ==========================================
const CATALOG: Array = [
	# MOBO — max 1, can be upgraded to one with more ram_slots
	{ "type": "mobo", "name": "Basic Mobo",    "price": 100,   "ram_slots": 2 },
	{ "type": "mobo", "name": "Standard Mobo", "price": 800,   "ram_slots": 4 },
	{ "type": "mobo", "name": "Pro Mobo",      "price": 2500,  "ram_slots": 6 },
	{ "type": "mobo", "name": "Server Mobo",   "price": 8000,  "ram_slots": 8 },
	# CPU — max 1
	{ "type": "cpu",  "name": "2-core CPU",    "price": 500,   "cores": 2  },
	{ "type": "cpu",  "name": "4-core CPU",    "price": 1500,  "cores": 4  },
	{ "type": "cpu",  "name": "8-core CPU",    "price": 5000,  "cores": 8  },
	# RAM — max = mobo.ram_slots sticks, each stick independent
	{ "type": "ram",  "name": "RAM 1GB",       "price": 100,   "gb": 1  },
	{ "type": "ram",  "name": "RAM 2GB",       "price": 300,   "gb": 2  },
	{ "type": "ram",  "name": "RAM 4GB",       "price": 700,   "gb": 4  },
	{ "type": "ram",  "name": "RAM 8GB",       "price": 1800,  "gb": 8  },
	# DISK — max 6 slots
	{ "type": "disk", "name": "HDD 256GB",     "price": 150,   "gb": 256  },
	{ "type": "disk", "name": "HDD 512GB",     "price": 300,   "gb": 512  },
	{ "type": "disk", "name": "HDD 1TB",       "price": 600,   "gb": 1024 },
	{ "type": "disk", "name": "HDD 2TB",       "price": 1500,  "gb": 2048 },
	# GPU — max 2 slots
	{ "type": "gpu",  "name": "Entry GPU",     "price": 2000,  "tflops": 2  },
	{ "type": "gpu",  "name": "Mid GPU",       "price": 6000,  "tflops": 6  },
	{ "type": "gpu",  "name": "High-End GPU",  "price": 15000, "tflops": 15 },
]

# ==========================================
# LIFECYCLE
# ==========================================
func _ready() -> void:
	_give_starting_gear()
	_recompute_earn()
	_start_passive_timer()

func _give_starting_gear() -> void:
	_apply_item({ "type": "mobo", "ram_slots": 2 })
	_apply_item({ "type": "cpu",  "cores": 2 })
	_apply_item({ "type": "ram",  "gb": 2 })
	_apply_item({ "type": "disk", "gb": 256 })

func _start_passive_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_passive_tick)
	add_child(timer)

# ==========================================
# PASSIVE TICK — fires every second
# ==========================================
func _passive_tick() -> void:
	_earn_accumulator += earn_per_sec
	var earned := int(_earn_accumulator)
	if earned > 0:
		_earn_accumulator -= earned
		add_money(earned)

	# XP passif proportionnel au revenu (1 xp minimum)
	add_xp(max(1, int(earn_per_sec * 0.1)))

# ==========================================
# INCOME FORMULA
# ==========================================
# earn/s = (cores * 3) * (1 + ram_gb * 0.2) + tflops * 5 + disk_gb / 512
# La mobo est un prérequis : sans elle, aucun revenu.
# Le RAM agit comme multiplicateur du CPU (pas comme revenu additionnel plat).
# Le GPU apporte un gros bonus fixe.
# Le disk apporte un micro-bonus de stockage.
func _recompute_earn() -> void:
	if inventory["mobo"]["count"] == 0:
		earn_per_sec = 0.0
		earn_rate_changed.emit(earn_per_sec)
		return

	var cpu_base: float   = inventory["cpu"]["cores"]  * 1.0
	var ram_mult: float   = 1.0 + inventory["ram"]["gb"] * 0.2
	var gpu_bonus: float  = inventory["gpu"]["tflops"] * 2.0
	var disk_bonus: float = inventory["disk"]["gb"] / 512.0

	earn_per_sec = (cpu_base * ram_mult) + gpu_bonus + disk_bonus
	earn_rate_changed.emit(earn_per_sec)

# ==========================================
# SHOP
# ==========================================
func can_buy(item: Dictionary) -> bool:
	if money < item.get("price", 0):
		return false
	match item["type"]:
		"mobo":
			# Upgrade possible si la nouvelle mobo a plus de slots
			return item.get("ram_slots", 0) > inventory["mobo"]["ram_slots"]
		"cpu":
			# Upgrade possible si le nouveau CPU a plus de cores
			return inventory["cpu"]["count"] < MAX_CPU or \
				   item.get("cores", 0) > inventory["cpu"]["cores"]
		"ram":
			return inventory["ram"]["count"] < inventory["mobo"]["ram_slots"]
		"gpu":
			return inventory["gpu"]["count"] < MAX_GPU
		"disk":
			return inventory["disk"]["count"] < MAX_DISK
	return false

func buy_item(item: Dictionary) -> bool:
	if not can_buy(item):
		return false
	add_money(-item.get("price", 0))
	_apply_item(item)
	SoundManager.play_sound("buying")
	return true

# ==========================================
# APPLY ITEM (achat ou setup initial)
# ==========================================
func _apply_item(item: Dictionary) -> void:
	match item["type"]:
		"mobo":
			inventory["mobo"]["count"]     = 1
			inventory["mobo"]["ram_slots"] = item.get("ram_slots", 2)
		"cpu":
			inventory["cpu"]["count"] = 1
			inventory["cpu"]["cores"] = item.get("cores", 0)
		"ram":
			inventory["ram"]["count"] += 1
			inventory["ram"]["gb"]    += item.get("gb", 0)
		"gpu":
			inventory["gpu"]["count"]  += 1
			inventory["gpu"]["tflops"] += item.get("tflops", 0)
		"disk":
			inventory["disk"]["count"] += 1
			inventory["disk"]["gb"]    += item.get("gb", 0)

	_recompute_earn()
	inventory_changed.emit(item["type"])

# ==========================================
# MONEY
# ==========================================
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

# ==========================================
# XP / NIVEAU
# ==========================================
func add_xp(amount: int) -> void:
	xp += amount
	_check_level_up()

func _check_level_up() -> void:
	while xp >= lvl_xp:
		xp  -= lvl_xp
		lvl += 1
		lvl_xp = int(lvl_xp * 1.8)
		SoundManager.play_sound("lvl_up")
		level_up.emit(lvl)
	xp_changed.emit(xp, lvl, lvl_xp)

# ==========================================
# HELPERS LECTURE
# ==========================================
func get_ram_slots() -> int:
	return inventory["mobo"]["ram_slots"]

func get_ram_slots_used() -> int:
	return inventory["ram"]["count"]

func format_money() -> String:
	return "$%d" % money

func format_earn() -> String:
	return "%.1f$/s" % earn_per_sec
