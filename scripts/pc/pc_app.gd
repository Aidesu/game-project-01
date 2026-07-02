class_name PcApp
extends Resource

## Décrit une application du PC. Crée une ressource PcApp (clic droit dans
## FileSystem → New Resource → PcApp), renseigne le nom + la scène, puis
## ajoute-la au tableau "apps" du PcInterface.
@export var app_name: String = "App"
@export var icon: Texture2D
@export var scene: PackedScene
