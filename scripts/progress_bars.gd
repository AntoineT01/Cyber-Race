# ProgressBar.gd
extends Control

@onready var respawn_timer_label_player1 = $CanvasLayer/HBoxContainer/VBoxContainer_Player1/RespawnProgressBarPlayer1
@onready var respawn_timer_label_player2 = $CanvasLayer/HBoxContainer/VBoxContainer_Player2/RespawnProgressBarPlayer2

func _ready():
	# Trouver les nœuds des voitures. Ajustez les chemins selon votre arborescence de scène.
	var car1 = get_node("../World/Voiture1")
	var car2 = get_node("../World/Voiture2")

	if car1:
		car1.connect("respawn_timer_started", Callable(self, "_on_respawn_timer_started"))
		car1.connect("respawn_timer_updated", Callable(self, "_on_respawn_timer_updated"))
		car1.connect("respawn_timer_finished", Callable(self, "_on_respawn_timer_finished"))
		car1.connect("respawn_timer_cancelled", Callable(self, "_on_respawn_timer_cancelled"))  # Connexion du nouveau signal

	if car2:
		car2.connect("respawn_timer_started", Callable(self, "_on_respawn_timer_started"))
		car2.connect("respawn_timer_updated", Callable(self, "_on_respawn_timer_updated"))
		car2.connect("respawn_timer_finished", Callable(self, "_on_respawn_timer_finished"))
		car2.connect("respawn_timer_cancelled", Callable(self, "_on_respawn_timer_cancelled"))  # Connexion du nouveau signal

	# Initialiser les ProgressBars
	respawn_timer_label_player1.visible = false
	respawn_timer_label_player2.visible = false

func _on_respawn_timer_started(player_id, time_left):
	if player_id == 1:
		respawn_timer_label_player1.visible = true
		respawn_timer_label_player1.max_value = time_left
		respawn_timer_label_player1.value = time_left
	elif player_id == 2:
		respawn_timer_label_player2.visible = true
		respawn_timer_label_player2.max_value = time_left
		respawn_timer_label_player2.value = time_left

func _on_respawn_timer_updated(player_id, time_left):
	if player_id == 1:
		respawn_timer_label_player1.value = time_left
	elif player_id == 2:
		respawn_timer_label_player2.value = time_left

func _on_respawn_timer_finished(player_id):
	print("Finished ", player_id)
	if player_id == 1:
		respawn_timer_label_player1.visible = false
	elif player_id == 2:
		respawn_timer_label_player2.visible = false

func _on_respawn_timer_cancelled(player_id):
	if player_id == 1:
		respawn_timer_label_player1.visible = false
	elif player_id == 2:
		respawn_timer_label_player2.visible = false
