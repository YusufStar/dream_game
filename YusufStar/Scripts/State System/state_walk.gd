class_name State_Walk
extends State

@export var move_speed: float = 100.0
@onready var idle: State = $"../Idle"

func Enter() -> void:
	player.UpdateAnimation("walk")

func Exit() -> void:
	pass

func Process(_delta: float) -> State:
	if player.path_index < player.path.size():
		var next_cell: Vector2i = player.path[player.path_index]
		# Get the world position of the cell center using pathfinder
		var global_next = player.pathfinder_node.cell_to_world(next_cell)
		var delta_pos = global_next - player.global_position

		if delta_pos.length() < player.arrive_threshold:
			player.path_index += 1
			player.direction = Vector2.ZERO
		else:
			player.direction = delta_pos.normalized()
			player.update_cardinal_from_direction(player.direction)
	else:
		player.direction = Vector2.ZERO
		return idle

	# Move
	player.velocity = player.velocity.lerp(player.direction * move_speed, player.acceleration * _delta)

	# Update animation
	if player.direction != Vector2.ZERO:
		player.UpdateAnimation("walk")

	return null
