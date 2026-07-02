class_name PcInterface
extends CanvasLayer

## Bureau du PC : affiche une grille d'applications, ouvre l'app sélectionnée
## dans une fenêtre, et signale la fermeture du PC via `closed`.
## Les apps sont fournies dans `apps` (voir PcApp).

signal closed

@export var apps: Array[PcApp] = []

@onready var app_grid: GridContainer = $Screen/Launcher/AppGrid
@onready var window: Panel           = $Screen/AppWindow
@onready var window_title: Label     = $Screen/AppWindow/VBox/TitleBar/Title
@onready var app_host: Control       = $Screen/AppWindow/VBox/AppHost

var _current_app: Node = null

func _ready() -> void:
	visible = false
	if apps.is_empty():
		apps = _default_apps()
	_build_launcher()
	_show_desktop()

# Apps d'exemple si aucune n'est renseignée dans l'inspecteur.
func _default_apps() -> Array[PcApp]:
	var list: Array[PcApp] = []
	list.append(_make_app("Notes", preload("res://scenes/pc/apps/notes_app.tscn")))
	list.append(_make_app("System", preload("res://scenes/pc/apps/system_app.tscn")))
	return list

func _make_app(title: String, scene: PackedScene) -> PcApp:
	var app := PcApp.new()
	app.app_name = title
	app.scene = scene
	return app

func open() -> void:
	_show_desktop()
	visible = true

# ==========================================
# LAUNCHER
# ==========================================
func _build_launcher() -> void:
	for child in app_grid.get_children():
		child.queue_free()
	for app in apps:
		var btn := Button.new()
		btn.text = app.app_name
		btn.custom_minimum_size = Vector2(120, 96)
		if app.icon:
			btn.icon = app.icon
			btn.expand_icon = true
		btn.pressed.connect(_open_app.bind(app))
		app_grid.add_child(btn)

# ==========================================
# WINDOW
# ==========================================
func _open_app(app: PcApp) -> void:
	_clear_app()
	window_title.text = app.app_name
	if app.scene:
		_current_app = app.scene.instantiate()
		app_host.add_child(_current_app)
	window.show()

func _show_desktop() -> void:
	window.hide()
	_clear_app()

func _clear_app() -> void:
	if _current_app:
		_current_app.queue_free()
		_current_app = null

# ==========================================
# SIGNALS
# ==========================================
func _on_app_close_pressed() -> void:
	_show_desktop()

func _on_power_pressed() -> void:
	closed.emit()
