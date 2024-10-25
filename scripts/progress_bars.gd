# ProgressBar.gd
extends Control

@onready var respawn_timer_label_player1 = $CanvasLayer/HBoxContainer/VBoxContainer_Player1/RespawnProgressBarPlayer1
@onready var respawn_timer_label_player2 = $CanvasLayer/HBoxContainer/VBoxContainer_Player2/RespawnProgressBarPlayer2

func _ready():
	# Trouver tous les nœuds dans le groupe "cars"
	var cars = get_tree().get_nodes_in_group("cars")
	var car1
	var car2
	# Vérifier qu'il y a au moins deux voitures dans le groupe
	if cars.size() >= 2:
		# Assigner les deux premières voitures trouvées à car1 et car2
		car1 = cars[0] as VehicleBody3D
		car2 = cars[1] as VehicleBody3D

		if !car1 or !car2:
			push_warning("Les nœuds trouvés dans le groupe 'cars' ne sont pas des VehicleBody3D.")
	else:
		push_warning("Pas assez de voitures trouvées dans le groupe 'cars'. Au moins deux voitures sont nécessaires.")
		
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
