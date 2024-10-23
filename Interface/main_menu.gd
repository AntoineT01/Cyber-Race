extends Control  # Le script est attaché au root node de la scène PauseMenu

# On récupère les boutons
@onready var piece_race_button = $CenterContainer/VBoxContainer/PiecesRaceButton
@onready var race_button = $CenterContainer/VBoxContainer/RaceButton
@onready var settings_button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:

	# Continue à fonctionner même en pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Applique le mode de process aux boutons pour qu'ils fonctionnent en pause
	piece_race_button.process_mode = Node.PROCESS_MODE_ALWAYS
	race_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	# Vérifie si le joueur appuie sur la touche pause (Échap)
	if Input.is_action_just_pressed("ui_pause"):
		toggle_pause()

# Fonction pour basculer entre pause et reprise
func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	# Affiche le menu de pause
	self.visible = true
	# Mets le jeu en pause (tout sauf les éléments en PROCESS_MODE_ALWAYS)
	get_tree().paused = true

func resume_game():
	# Cache le menu de pause
	self.visible = false
	# Reprend le jeu
	get_tree().paused = false

# Bouton "Quitter"
func _on_quit_button_pressed() -> void:
	get_tree().quit()  # Quitte le jeu


func _on_pieces_race_button_pressed() -> void:
	get_tree().change_scene_to_file("res://piece_race.tscn")


func _on_race_button_pressed() -> void:
	get_tree().change_scene_to_file("res://screenshot_scene.tscn")


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Interface//settings_menu.tscn")
