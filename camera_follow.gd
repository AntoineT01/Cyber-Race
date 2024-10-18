extends Camera3D

@export var target_name: String
@export var distance = 10.0  # Distance derrière la voiture
@export var height = 4.5    # Hauteur au-dessus de la voiture
@export var smooth_speed = 5.0

var target: Node3D

func _ready():
	await get_tree().create_timer(0.1).timeout
	find_target()

func find_target():
	var root = get_tree().root
	target = root.find_child(target_name, true, false)
	if not target:
		print("Cible non trouvée : ", target_name)

func _physics_process(delta):
	if target:
		# Calculer la position cible de la caméra
		var target_pos = target.global_transform.origin
		var target_basis = target.global_transform.basis

		# Position derrière et au-dessus de la voiture
		var camera_pos = target_pos - target_basis.z * distance + Vector3.UP * height

		# Interpolation douce de la position de la caméra
		global_transform.origin = global_transform.origin.lerp(camera_pos, smooth_speed * delta)

		# Faire regarder la caméra vers la voiture
		look_at(target_pos, Vector3.UP)
	else:
		find_target()
