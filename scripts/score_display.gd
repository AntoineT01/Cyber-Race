# ScoreDisplay.gd
extends Control

# Enregistrer la classe globalement
class_name ScoreDisplay

# Variables exportées pour le nom et l'ID du joueur
@export var player_name: String = "Player"  # Nom du joueur (modifiable dans l'éditeur)
@export var player_id: int = 1  # Identifiant unique pour chaque joueur

# Référence au label UI unique
@onready var score_label: Label = $ScoreLabel

# Variables pour stocker les scores et l'objectif
var piece_score: int = 0
var lap_score: int = 0
var victory_target: int = 0

# Variable pour stocker le type de victoire actuel
enum VictoryType { PIECES, LAPS }
var current_victory_type: VictoryType = VictoryType.PIECES

func _ready():
	# Initialiser le label avec les valeurs actuelles
	update_score_label()

	# Enregistrer ce ScoreDisplay auprès de ScoreManager
	if ScoreManager:
		ScoreManager.register_score_display(self)

func _exit_tree():
	# Désenregistrer ce ScoreDisplay auprès de ScoreManager
	if ScoreManager:
		ScoreManager.unregister_score_display(self)

# Fonction pour mettre à jour le score des pièces
func set_piece_score(new_score: int):
	piece_score = new_score
	update_score_label()

# Fonction pour mettre à jour le score des tours
func set_lap_score(new_lap: int):
	lap_score = new_lap
	update_score_label()

# Fonction pour définir et mettre à jour l'objectif de victoire
func set_victory_target(target: int):
	victory_target = target
	update_score_label()

# Fonction pour définir le type de victoire
func set_victory_type(victory_type: String):
	if victory_type.to_lower() == "pieces":
		current_victory_type = VictoryType.PIECES
	elif victory_type.to_lower() == "laps":
		current_victory_type = VictoryType.LAPS
	else:
		push_warning("Type de victoire inconnu: %s" % victory_type)
	update_score_label()

# Mise à jour du label avec les informations conditionnelles
func update_score_label():
	var display_text: String = ""
	if current_victory_type == VictoryType.PIECES:
		display_text += "Pièces: %d / %d" % [piece_score, victory_target]
	elif current_victory_type == VictoryType.LAPS:
		display_text += "Tours: %d / %d" % [lap_score, victory_target]
	score_label.text = display_text
