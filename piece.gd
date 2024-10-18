extends Area3D

signal piece_collected(by_player)

@export var rotation_speed: float = 2.0

func _ready():
	# Rotation aléatoire initiale pour la variété
	rotate_y(randf() * 2 * PI)

func _process(delta):
	# Rotation continue
	rotate_y(rotation_speed * delta)

func _on_body_entered(body):
	if body.is_in_group("players"):
		emit_signal("piece_collected", body.name)
		queue_free()  # Supprime la pièce après la collecte
