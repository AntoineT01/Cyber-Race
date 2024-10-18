extends Node

func _ready():
	for piece in $World/Pieces.get_children():
		piece.connect("piece_collected", Callable(self, "_on_piece_collected"))

func _on_piece_collected(player_name):
	var player = get_node("World/" + player_name)
	if player:
		player.collect_piece()
