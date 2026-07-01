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
var inventory: Dictionary = {
	"mobo": { "count": 0, "cpu_slots": 0, "gpu_slots": 0, "ram_slots": 0, "disk_slots": 0 },
	"cpu":  { "count": 0, "cores": 0 },
	"ram":  { "count": 0, "gb": 0 },
	"gpu":  { "count": 0, "tflops": 0 },
	"disk": { "count": 0, "gb": 0 },
}

const MAX_MOBO: int = 5
const MAX_DISK: int = 6

# ==========================================
# SHOP CATALOG
# ==========================================
const CATALOG: Array = [
	# MOBO
	{ "type": "mobo", "name": "Basic Mobo",    "price": 100,   "cpu_slots": 1, "gpu_slots": 1, "ram_slots": 2,  "disk_slots": 2  },
	{ "type": "mobo", "name": "Standard Mobo", "price": 800,   "cpu_slots": 1, "gpu_slots": 2, "ram_slots": 4,  "disk_slots": 4  },
	{ "type": "mobo", "name": "Pro Mobo",      "price": 2500,  "cpu_slots": 2, "gpu_slots": 2, "ram_slots": 6,  "disk_slots": 6  },
	{ "type": "mobo", "name": "Server Mobo",   "price": 8000,  "cpu_slots": 2, "gpu_slots": 4, "ram_slots": 12, "disk_slots": 12 },
	# CPU
	{ "type": "cpu",  "name": "2-core CPU",    "price": 500,   "cores": 2  },
	{ "type": "cpu",  "name": "4-core CPU",    "price": 1500,  "cores": 4  },
	{ "type": "cpu",  "name": "8-core CPU",    "price": 5000,  "cores": 8  },
	# RAM
	{ "type": "ram",  "name": "RAM 1GB",       "price": 100,   "gb": 1  },
	{ "type": "ram",  "name": "RAM 2GB",       "price": 300,   "gb": 2  },
	{ "type": "ram",  "name": "RAM 4GB",       "price": 700,   "gb": 4  },
	{ "type": "ram",  "name": "RAM 8GB",       "price": 1800,  "gb": 8  },
	# DISK
	{ "type": "disk", "name": "HDD 256GB",     "price": 150,   "gb": 256  },
	{ "type": "disk", "name": "HDD 512GB",     "price": 300,   "gb": 512  },
	{ "type": "disk", "name": "HDD 1TB",       "price": 600,   "gb": 1024 },
	{ "type": "disk", "name": "HDD 2TB",       "price": 1500,  "gb": 2048 },
	# GPU
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
	_apply_item({ "type": "mobo", "cpu_slots": 1, "gpu_slots": 1, "ram_slots": 2, "disk_slots": 2 })
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
# PASSIVE TICK
# ==========================================
func _passive_tick() -> void:
	_earn_accumulator += earn_per_sec
	var earned := int(_earn_accumulator)
	if earned > 0:
		_earn_accumulator -= earned
		add_money(earned)

	add_xp(max(1, int(earn_per_sec * 0.1)))

# ==========================================
# INCOME FORMULA
# ==========================================
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

	var t: String = item["type"]

	if t == "mobo":
		return inventory["mobo"]["count"] < MAX_MOBO

	elif t == "cpu":
		return inventory["cpu"]["count"]  < inventory["mobo"]["cpu_slots"]
	elif t == "ram":
		return inventory["ram"]["count"]  < inventory["mobo"]["ram_slots"]
	elif t == "gpu":
		return inventory["gpu"]["count"]  < inventory["mobo"]["gpu_slots"]
	elif t == "disk":
		return inventory["disk"]["count"] < inventory["mobo"]["disk_slots"]

	return false

func buy_item(item: Dictionary) -> bool:
	if not can_buy(item):
		return false
	add_money(-item.get("price", 0))
	_apply_item(item)
	SoundManager.play_sound("buying")
	return true

# ==========================================
# APPLY ITEM
# ==========================================
func _apply_item(item: Dictionary) -> void:
	match item["type"]:
		"mobo":
			inventory["mobo"]["count"]      += 1
			inventory["mobo"]["cpu_slots"]  += item.get("cpu_slots",  1)
			inventory["mobo"]["gpu_slots"]  += item.get("gpu_slots",  1)
			inventory["mobo"]["ram_slots"]  += item.get("ram_slots",  2)
			inventory["mobo"]["disk_slots"] += item.get("disk_slots", 2)
		"cpu":
			inventory["cpu"]["count"] += 1
			inventory["cpu"]["cores"] += item.get("cores", 0)
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
	if item["type"] == "mobo":
		for t in inventory:
			inventory_changed.emit(t)
	else:
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
func get_cpu_slots() -> int:
	return inventory["mobo"]["cpu_slots"]

func get_cpu_slots_used() -> int:
	return inventory["cpu"]["count"]

func get_gpu_slots() -> int:
	return inventory["mobo"]["gpu_slots"]

func get_gpu_slots_used() -> int:
	return inventory["gpu"]["count"]

func get_ram_slots() -> int:
	return inventory["mobo"]["ram_slots"]

func get_ram_slots_used() -> int:
	return inventory["ram"]["count"]

func get_disk_slots() -> int:
	return inventory["mobo"]["disk_slots"]

func get_disk_slots_used() -> int:
	return inventory["disk"]["count"]

func format_storage(gb: int) -> String:
	if gb >= 1000:
		return "%.1fTB" % (gb / 1000.0)
	return "%dGB" % gb

func format_money() -> String:
	return "$%d" % money

func format_earn() -> String:
	return "%.1f$/s" % earn_per_sec
