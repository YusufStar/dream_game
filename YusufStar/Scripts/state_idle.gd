class_name State_Idle
extends State

@onready var walk: State = $"../Walk"

func Enter() -> void:
    player.UpdateAnimation("idle")
    pass

func Exit() -> void:
    pass

func Process(_delta: float) -> State:
    if player.direction != Vector2.ZERO:
        return walk

    # Smooth stop
    player.velocity = player.velocity.lerp(Vector2.ZERO, player.acceleration * _delta)

    return null


func Physics(_delta: float) -> State:
    return null

func HandleInput(_event: InputEvent) -> State:
    return null