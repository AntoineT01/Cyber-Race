extends Area3D

signal piece_collected(by_player)

@export var collection_distance = 2.0  # Ajustez cette valeur selon la taille de vos voitures

func _ready():
	rotate_y(randf() * 2 * PI)  # Rotation aléatoire pour la variété

func _process(delta):
	rotate_y(delta)  # Rotation continue
	check_collection()

func check_collection():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		if distance < collection_distance:
			emit_signal("piece_collected", player.name)
			queue_free()  # Supprime la pièce après la collecte
			break
