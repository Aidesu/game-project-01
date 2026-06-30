extends CharacterBody2D

var speed = 150

@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta):
	var dir = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1

	velocity = dir.normalized() * speed
	move_and_slide()

	update_animation(dir)


func update_animation(dir: Vector2):
	if dir == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 0
		return

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("walk_r")
		else:
			sprite.play("walk_l")
	else:
		if dir.y > 0:
			sprite.play("walk_b")
		else:
			sprite.play("walk_u")
