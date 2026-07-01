extends Node

@onready var lvl_up = $LvlUpSnd
@onready var buying = $BuySnd
@onready var pressing = $PressSnd

func play_sound(key):
	var sound = get(key)
	if sound is AudioStreamPlayer:
		sound.play()
	else:
		print("Sound ", key, " not found!")
