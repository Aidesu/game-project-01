extends Node

## Base de cinématique / cutscene.
## Pendant une cinématique, `active` est vrai → le joueur ne bouge plus
## (player.gd lit ce flag).
##
## Une cinématique s'écrit comme une fonction, encadrée par begin()/end() :
##
##     func _ma_scene() -> void:
##         Cinematic.begin()
##         await Cinematic.fade_in()
##         await Cinematic.move_to($PNJ, cible.global_position, 2.0)
##         Cinematic.end()
##
## Important : appelle la fonction avec `await` (ex. `await _ma_scene()`),
## jamais via un Callable, sinon l'attente n'est pas garantie.

signal started
signal finished

var active: bool = false

func begin() -> void:
	active = true
	started.emit()

func end() -> void:
	active = false
	finished.emit()

# ==========================================
# HELPERS RÉUTILISABLES
# ==========================================
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func move_to(node: Node2D, target: Vector2, duration: float) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "global_position", target, duration)
	await tween.finished

func fade_out() -> void:
	await Transition.close()

func fade_in() -> void:
	await Transition.open()
