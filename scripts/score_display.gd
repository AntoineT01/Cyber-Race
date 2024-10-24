# ScoreDisplay.gd
extends Control

class_name ScoreDisplay  # Définir la classe globalement

@export var player_name: String = "Player"  # Nom du joueur (modifiable dans l'éditeur)
@export var player_id: int = 1  # Identifiant unique pour chaque joueur

@onready var score_label = $ScoreLabel

var score: int = 0 

func _ready():
	update_score_label()
	# Enregistrer ce ScoreDisplay auprès de ScoreManager
	if ScoreManager:
		ScoreManager.register_score_display(self)

func _exit_tree():
	# Désenregistrer ce ScoreDisplay auprès de ScoreManager
	if ScoreManager:
		ScoreManager.unregister_score_display(self)

func set_score(new_score: int):
	score = new_score
	update_score_label()

func update_score_label():
	score_label.text = "%s: %d" % [player_name, score]
