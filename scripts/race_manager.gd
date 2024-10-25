# RaceManager.gd
extends Node

@export var total_laps = 3
var cars = {}
var checkpoints = []
var laps = {}
var current_checkpoint = {}

func _ready():
	print("RaceManager ready")
	# Trouver le nœud Checkpoints
	var checkpoints_node = get_parent().get_node("Checkpoints") # Ajustez le chemin selon votre hiérarchie
	if not checkpoints_node:
		print("Checkpoints node not found!")
		return

	# Initialiser la liste des checkpoints
	checkpoints = checkpoints_node.get_children()

	print("Checkpoints trouvés: ", checkpoints.size())
	print("Liste des checkpoints :", checkpoints)

	# Initialiser les voitures
	for car in get_tree().get_nodes_in_group("cars"):
		cars[car] = 0
		laps[car] = 0
		current_checkpoint[car] = 0
		print("Voiture initialisée: ", car.name)

	# Connecter les signaux des checkpoints
	for cp in checkpoints:
		cp.connect("checkpoint_passed", Callable(self, "on_checkpoint_passed"))
		print("Signal connecté pour ", cp.name)

	# Définir la condition de victoire sur les tours
	ScoreManager.set_victory_condition("laps", total_laps)

func on_checkpoint_passed(car, checkpoint):
	print("Signal reçu de ", car.name, " pour le checkpoint ", checkpoint.name)

	# Récupérer l'index du checkpoint attendu pour cette voiture
	var cp_index = current_checkpoint[car]

	# Vérifier si l'index est hors limites et le réinitialiser si nécessaire
	if cp_index >= checkpoints.size():
		cp_index = 0

	var expected_cp = checkpoints[cp_index]

	# Vérifier que le checkpoint passé est le checkpoint attendu
	if expected_cp == checkpoint:
		print(car.name, " a passé le checkpoint attendu: ", expected_cp.name)
		current_checkpoint[car] += 1

		# Vérifier si la voiture a complété un tour
		if current_checkpoint[car] >= checkpoints.size():
			current_checkpoint[car] = 0
			laps[car] += 1
			print(car.name, " a complété le tour ", laps[car])

			# Mettre à Jour le Score de Tours dans ScoreManager
			var player_id = ScoreManager.get_player_id_from_name(car.name)
			if player_id != -1:
				ScoreManager.set_lap_score(player_id, laps[car])
				print("Score de tours mis à jour pour le joueur ", player_id, ": ", laps[car], " tours")
			else:
				print("ID de joueur non trouvé pour la voiture : ", car.name)

			# Vérifier si la voiture a gagné la course
			if laps[car] >= total_laps:
				print(car.name, " a gagné la course!")
				end_race(car)
	else:
		print(car.name, " a passé un checkpoint incorrect: ", checkpoint.name, " attendu: ", expected_cp.name)

func end_race(winner):
	# Gérer la fin de la course, afficher le gagnant, etc.
	print("Course terminée! Gagnant: ", winner.name)
	var player_id = ScoreManager.get_player_id_from_name(winner.name)
	if player_id != -1:
		ScoreManager.emit_signal("player_victory", player_id)
	else:
		print("ID de joueur non trouvé pour le gagnant : ", winner.name)
	get_tree().paused = true
	# Charger l'écran de fin de course ou afficher une interface utilisateur

func reset_car_counters(car):
	if car in current_checkpoint:
		current_checkpoint[car] = 0
	print("Compteurs réinitialisés pour ", car.name)
