extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var utilitaries_instance = get_node("/root/Race/Utilitaries")
	var pause_menu = utilitaries_instance.get_node("PauseMenu/PauseMenu")
	if pause_menu:
		pause_menu.restart_scene_path = "res://main_scenes/race.tscn"
