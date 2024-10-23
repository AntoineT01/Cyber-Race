extends Camera3D

@export var target_name: String
@export var distance = 10.0        # Distance initiale derrière la voiture
@export var min_distance = 5.0     # Distance minimale pour le zoom
@export var max_distance = 20.0    # Distance maximale pour le zoom
@export var height = 4.5           # Hauteur au-dessus de la voiture
@export var smooth_speed = 5.0
@export var zoom_speed = 2.0       # Vitesse de zoom avec la molette
@export var rotation_speed = 0.005 # Sensibilité de la rotation avec la souris

var target: Node3D

# Variables pour les angles de rotation
var yaw: float = 0.0    # Rotation horizontale (en radians)
var pitch: float = 0.0  # Rotation verticale (en radians)

# Variable pour suivre l'état de la rotation
var is_rotating: bool = false

# Définition des constantes des boutons de la souris
const BUTTON_LEFT = 1
const BUTTON_RIGHT = 2
const BUTTON_MIDDLE = 3
const BUTTON_WHEEL_UP = 4
const BUTTON_WHEEL_DOWN = 5

func _ready():
	await get_tree().create_timer(0.1).timeout
	find_target()

func find_target():
	var root = get_tree().root
	target = root.find_child(target_name, true, false)
	if not target:
		print("Cible non trouvée : ", target_name)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				# Commence la rotation
				is_rotating = true
				# Capture le curseur pour éviter de le perdre pendant la rotation
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				# Termine la rotation
				is_rotating = false
				# Libère le curseur
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif event.button_index == BUTTON_WHEEL_UP:
			if event.pressed:
				# Zoom avant
				distance = max(min_distance, distance - zoom_speed)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if event.pressed:
				# Zoom arrière
				distance = min(max_distance, distance + zoom_speed)
	elif event is InputEventMouseMotion:
		if is_rotating:
			# Ajuster les angles en fonction du mouvement de la souris
			yaw -= event.relative.x * rotation_speed
			pitch -= event.relative.y * rotation_speed
			# Limiter le pitch pour éviter des rotations complètes verticales
			pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	if target:
		# Calculer la position cible de la caméra en coordonnées sphériques
		var target_pos = target.global_transform.origin

		# Appliquer les rotations
		var direction = Vector3(
			distance * cos(pitch) * sin(yaw),
			distance * sin(pitch),
			distance * cos(pitch) * cos(yaw)
		)

		var camera_pos = target_pos - direction + Vector3.UP * height

		# Interpolation douce de la position de la caméra
		global_transform.origin = global_transform.origin.lerp(camera_pos, smooth_speed * delta)

		# Faire regarder la caméra vers la voiture
		look_at(target_pos, Vector3.UP)
	else:
		find_target()
