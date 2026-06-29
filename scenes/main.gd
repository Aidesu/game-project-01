extends Control

var xp = 0
var lvl_xp = 200
var xp_earn = 25
var money = 0
var earn_by_sec = 0
var lvl = 0

@onready var lvl_label = $LvlLbl
@onready var xp_bar = $XpBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Shop.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_work_btn_button_down() -> void:
	money +=1
	xp += xp_earn
	$MoneyLbl.text = ("$" + str(money))
	refresh_xp()


func _on_shop_btn_button_down() -> void:
	$Shop.show()


func _on_exit_btn_button_down() -> void:
	$Shop.hide()
	
	
	
	
	
func refresh_xp() -> void:
	xp_bar.max_value = lvl_xp
	xp_bar.value = xp
	if xp >= lvl_xp:
		lvl += 1
		lvl_label.text = str(lvl)
		print(lvl)
		lvl_xp *= 1.8
		xp = 0
