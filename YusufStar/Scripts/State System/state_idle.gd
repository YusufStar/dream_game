class_name State_Idle
extends State

@onready var walk: State = $"../Walk"

func Enter() -> void:
	player.UpdateAnimation("idle")

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	if player.path_index < player.path.size():
		return walk
	player.direction = Vector2.ZERO
	player.velocity = player.velocity.lerp(Vector2.ZERO, player.acceleration * _delta)
	return null
