# ScoreManager.gd
extends Node

# Dictionnaire pour stocker les scores des joueurs
var player_scores: Dictionary = {
	1: 0,
	2: 0
}

# Liste pour stocker les références aux ScoreDisplay
var score_displays: Array = []

func _ready():
	# Connecter les pièces existantes
	connect_to_pieces()

	# Connecter aux futurs nœuds ajoutés
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func connect_to_pieces():
	var pieces = get_tree().get_nodes_in_group("pieces")
	for piece in pieces:
		if piece.has_method("connect"):
			piece.connect("piece_collected", Callable(self, "_on_piece_collected"))

func _on_node_added(node):
	if node.is_in_group("pieces"):
		if node.has_method("connect"):
			node.connect("piece_collected", Callable(self, "_on_piece_collected"))

# Fonction pour enregistrer un ScoreDisplay
func register_score_display(score_display: Node):
	if score_display not in score_displays:
		score_displays.append(score_display)
		# Initialiser l'affichage avec le score actuel
		if score_display is ScoreDisplay:
			score_display.set_score(player_scores[score_display.player_id])

# Fonction pour désenregistrer un ScoreDisplay
func unregister_score_display(score_display: Node):
	if score_display in score_displays:
		score_displays.erase(score_display)

func _on_piece_collected(by_player: String):
	# Déterminer l'ID du joueur à partir de son nom
	var player_id = get_player_id_from_name(by_player)
	if player_id != -1:
		player_scores[player_id] += 100
		update_score_display(player_id)
	else:
		push_warning("ID de joueur non trouvé pour le nom : %s" % by_player)
		
func on_respawn(player_id: int):
	if player_id != -1:
		player_scores[player_id] -= 200
		update_score_display(player_id)

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
			score_display.set_score(player_scores[player_id])

# Nouvelle Fonction : Réinitialiser les Scores
func reset_scores():
	# Réinitialiser les scores dans le dictionnaire
	for player_id in player_scores.keys():
		player_scores[player_id] = 0
	
	# Mettre à jour tous les ScoreDisplay enregistrés
	for score_display in score_displays:
		if score_display.player_id in player_scores:
			score_display.set_score(player_scores[score_display.player_id])
	
	# Optionnel : Afficher un message de réinitialisation
	print("Scores réinitialisés à zéro pour tous les joueurs.")
