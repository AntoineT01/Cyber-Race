extends Area3D

signal piece_collected(by_player)

@export var rotation_speed: float = 2.0
@export var float_speed: float = 2.0  # Vitesse du mouvement de flottement
@export var float_amplitude: float = 0.3  # Amplitude du mouvement de flottement

var initial_y: float
var time: float = 0.0

func _ready():
	# Rotation aléatoire initiale pour la variété
	rotate_y(randf() * 2 * PI)
	initial_y = global_transform.origin.y

func _process(delta):
	# Rotation continue
	rotate_y(rotation_speed * delta)

	# Mouvement de flottement
	time += delta
	var new_y = initial_y + sin(time * float_speed) * float_amplitude
	global_transform.origin.y = new_y

func _on_body_entered(body):
	if body.is_in_group("players"):
		emit_signal("piece_collected", body.name)
		queue_free()  # Supprime la pièce après la collecte
