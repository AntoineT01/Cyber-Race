extends Node

func _ready() -> void:
	ScoreManager.set_victory_condition("pieces", ScoreManager.total_pieces * 0.5)
