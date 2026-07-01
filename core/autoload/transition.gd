extends CanvasLayer

@onready var _rect: ColorRect = $ColorRect

const DURATION := 0.2

func _ready() -> void:
	_set_progress(1.0)

func close() -> void:
	await _animate(1.0, 0.0)

func open() -> void:
	await _animate(0.0, 1.0)

func _animate(from: float, to: float) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_method(_set_progress, from, to, DURATION)
	await tween.finished

func _set_progress(v: float) -> void:
	(_rect.material as ShaderMaterial).set_shader_parameter("progress", v)
