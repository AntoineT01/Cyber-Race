extends Node

@export var restart_scene_path: String

@onready var pause_menu = $PauseMenu/PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pause_menu:
		pause_menu.restart_scene_path = restart_scene_path
	else:
		print("Pause menu pas trouvé dans utilitaries")
