# ScoreManager.gd
extends Node

# Déclaration des signaux
@warning_ignore("unused_signal")
signal player_victory(player_id: int)

# Dictionnaires pour stocker les scores des joueurs
var piece_scores: Dictionary = {
								   1: 0,
								   2: 0
							   }

var lap_scores: Dictionary = {
								 1: 0,
								 2: 0
							 }

# Liste pour stocker les références aux ScoreDisplay
var score_displays: Array = []

# Nombre total de pièces dans le jeu
var total_pieces: int = 0

# Variables pour définir l'objectif de victoire
enum VictoryType { PIECES, LAPS }
var victory_type: VictoryType = VictoryType.PIECES
var victory_target: int = 10  # Par défaut, 10 pièces

# Variable pour empêcher les victoires multiples
var game_over: bool = false

func _ready():
	# Connecter les pièces existantes de manière différée
	call_deferred("connect_to_pieces")

	# Connecter aux futurs nœuds ajoutés
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

	# Connecter le signal de victoire
	connect("player_victory", Callable(self, "_on_player_victory"))

func connect_to_pieces():
	var pieces = get_tree().get_nodes_in_group("pieces")
	for piece in pieces:
		if piece.has_method("connect"):
			piece.connect("piece_collected", Callable(self, "_on_piece_collected"))

func _on_node_added(node):
	if node.is_in_group("pieces"):
		if node.has_method("connect"):
			node.connect("piece_collected", Callable(self, "_on_piece_collected"))
			total_pieces += 1
			print("Nouvelle pièce ajoutée. Nombre total de pièces: ", total_pieces)
	
# Fonction pour enregistrer un ScoreDisplay
func register_score_display(score_display: ScoreDisplay):
	if score_display not in score_displays:
			score_displays.append(score_display)
	# Initialiser l'affichage avec les scores actuels
	score_display.set_piece_score(piece_scores.get(score_display.player_id, 0))
	score_display.set_lap_score(lap_scores.get(score_display.player_id, 0))
	score_display.set_victory_target(victory_target)
	# Informer ScoreDisplay du type de victoire actuel
	if victory_type == VictoryType.PIECES:
		score_display.set_victory_type("pieces")
		victory_target = int(total_pieces * 0.5)
		score_display.set_victory_target(victory_target)
	elif victory_type == VictoryType.LAPS:
		score_display.set_victory_type("laps")

# Fonction pour désenregistrer un ScoreDisplay
func unregister_score_display(score_display: ScoreDisplay):
	if score_display in score_displays:
		score_displays.erase(score_display)

func _on_piece_collected(by_player: String):
	# Déterminer l'ID du joueur à partir de son nom
	var player_id = get_player_id_from_name(by_player)
	if player_id != -1:
		piece_scores[player_id] += 1
		update_score_display(player_id)
		check_victory_condition()
	else:
		push_warning("ID de joueur non trouvé pour le nom : %s" % by_player)

# Nouvelle Fonction pour Mettre à Jour les Scores de Tours
func set_lap_score(player_id: int, lap_count: int):
	if player_id in lap_scores:
		lap_scores[player_id] = lap_count
		update_score_display(player_id)
		check_victory_condition()
	else:
		push_warning("ID de joueur invalide : %d" % player_id)

# Fonction pour définir l'objectif de victoire
func set_victory_condition(type: String, target: int):
	if type.to_lower() == "pieces":
		victory_type = VictoryType.PIECES
	elif type.to_lower() == "laps":
		victory_type = VictoryType.LAPS
	else:
		push_warning("Type de victoire inconnu : %s" % type)
		return
	victory_target = target
	# Mettre à jour les affichages pour refléter le nouvel objectif et le type de victoire
	for score_display in score_displays:
		score_display.set_victory_target(victory_target)
		score_display.set_victory_type(type)
	print("Condition de victoire mise à jour : %s %d" % [type, target])

func get_player_id_from_name(player_name: String) -> int:
	# Mapper les noms des joueurs à leurs IDs
	if player_name == "Voiture1":
		return 1
	elif player_name == "Voiture2":
		return 2
	else:
		return -1

func update_score_display(player_id: int):
	for score_display in score_displays:
		if score_display.player_id == player_id:
			score_display.set_piece_score(piece_scores[player_id])
			score_display.set_lap_score(lap_scores[player_id])
# Victory target déjà mis à jour lors de l'enregistrement

# Nouvelle Fonction : Réinitialiser les Scores
func reset_scores():
	# Réinitialiser les scores dans les dictionnaires
	for player_id in piece_scores.keys():
		piece_scores[player_id] = 0
	for player_id in lap_scores.keys():
		lap_scores[player_id] = 0

	# Mettre à jour tous les ScoreDisplay enregistrés
	for score_display in score_displays:
		score_display.set_piece_score(piece_scores.get(score_display.player_id, 0))
		score_display.set_lap_score(lap_scores.get(score_display.player_id, 0))

	# Optionnel : Afficher un message de réinitialisation
	print("Scores réinitialisés à zéro pour tous les joueurs.")
	game_over = false
	total_pieces = 0

# Vérifier la condition de victoire
func check_victory_condition():
	if game_over:
		return
	for player_id in piece_scores.keys():
		if victory_type == VictoryType.PIECES:
			if piece_scores[player_id] >= victory_target:
				game_over = true
				emit_signal("player_victory", player_id)
				print("Le joueur %d a atteint %d pièces et a gagné !" % [player_id, victory_target])
				break
		elif victory_type == VictoryType.LAPS:
			if lap_scores[player_id] >= victory_target:
				game_over = true
				emit_signal("player_victory", player_id)
				print("Le joueur %d a complété %d tours et a gagné !" % [player_id, victory_target])
				break

# Fonction pour gérer l'affichage du Victory Screen
func _on_player_victory(player_id: int):
	var victory_screen_scene = preload("res://Interface/victory_screen.tscn")
	var victory_screen = victory_screen_scene.instantiate()
	victory_screen.winner_id = player_id
	get_tree().current_scene.add_child(victory_screen)
	# Mettre le jeu en pause pour éviter d'autres interactions
	get_tree().paused = true
	print("Le joueur ", player_id, " a gagné !")
