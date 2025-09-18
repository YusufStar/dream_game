class_name State_Dig
extends State

@onready var idle: State = $"../Idle"

func Enter() -> void:
	player.UpdateAnimation("dig")

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	return null
