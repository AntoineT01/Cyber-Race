extends Control  # Le script est attaché au root node de la scène PauseMenu

# On récupère les boutons
@onready var resume_button = $CenterContainer2/VBoxContainer/ResumeButton
@onready var home_button = $CenterContainer2/VBoxContainer/HomeButton

func _ready() -> void:
	# Cache le menu au démarrage
	self.visible = false

	# Continue à fonctionner même en pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Applique le mode de process aux boutons pour qu'ils fonctionnent en pause
	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	home_button.process_mode = Node.PROCESS_MODE_ALWAYS

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

# Bouton "Reprendre"
func _on_resume_button_pressed() -> void:
	resume_game()

# Bouton "Quitter"
func _on_quit_button_pressed() -> void:
	# Changement de scène, reset des variables pour que si on revient dessus c'est ok
	self.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
