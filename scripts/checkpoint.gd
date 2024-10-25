# Checkpoint.gd
extends Area3D

@warning_ignore("unused_signal")
signal checkpoint_passed(car, checkpoint)

func _ready():
	print("Checkpoint ", self.name, " prêt")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("cars"):
		print("OUI ", body.name, " a passé le checkpoint ", self.name)
		emit_signal("checkpoint_passed", body, self)
