extends Control

@export var winner_id: int = 1  # Par défaut, joueur 1

@onready var victory_label = $VBoxContainer/VictoryLabel
@onready var restart_button = $VBoxContainer/CenterContainer/VBoxContainer/Restart
@onready var main_menu_button = $VBoxContainer/CenterContainer/VBoxContainer/Home

func _ready():
	# Mettre à jour le message de victoire
	victory_label.text = "Le joueur " + str(winner_id) + " a gagné !"
	
		# Continue à fonctionner même en pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Applique le mode de process aux boutons pour qu'ils fonctionnent en pause
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_restart_pressed():
	# Réinitialiser les scores
	ScoreManager.reset_scores()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://piece_race.tscn")

func _on_home_pressed() -> void:
	ScoreManager.reset_scores()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Interface/main_menu.tscn")
