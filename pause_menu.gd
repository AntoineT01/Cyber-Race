extends Control  # Le script est attaché au root node de la scène PauseMenu

# On récupère les boutons
@onready var resume_button = $ResumeButton
@onready var quit_button = $QuitButton
@onready var settings_button = $SettingsButton

func _ready() -> void:
	# Cache le menu au démarrage
	self.visible = false

	# Continue à fonctionner même en pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Applique le mode de process aux boutons pour qu'ils fonctionnent en pause
	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
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
	print("resume")
	resume_game()

# Bouton "Quitter"
func _on_quit_button_pressed() -> void:
	get_tree().quit()  # Quitte le jeu

# Bouton "Paramètres"
func _on_SettingsButton_pressed():
	print("Ouvrir le menu des paramètres")  # Action à définir pour les paramètres
