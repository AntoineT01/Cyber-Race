extends Control

@export var map1: String
@export var map2: String
@export var map3: String

@onready var Map1Button = $CenterContainer/VBoxContainer/Map1
@onready var Map2Button = $CenterContainer/VBoxContainer/Map2
@onready var Map3Button = $CenterContainer/VBoxContainer/Map3

@onready var menu = $"../Node"

func _on_map_1_pressed() -> void:
	print("Switching to : ", map1)
	get_tree().change_scene_to_file(map1)


func _on_map_2_pressed() -> void:
	get_tree().change_scene_to_file(map2)

func _on_map_3_pressed() -> void:
	get_tree().change_scene_to_file(map3)
	
func _on_quit_button_pressed() -> void:
	self.visible = false
	menu.visible = true
