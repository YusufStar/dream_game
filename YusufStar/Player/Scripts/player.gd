extends CharacterBody2D
class_name Player

# --- Movement ---
var acceleration: float = 15.0
var cardinal_direction: Vector2 = Vector2.DOWN
var move_speed: float = 75.0

# --- Nodes ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $PlayerSprite
@onready var state_machine: PlayerStateMachine = $StateMachine
@export var tilemap: TileMapLayer
@export var pathfinder_node: Pathfinder
@export var cursor: Cursor

# --- Pathfinding ---
var path: Array = []
var path_index: int = 0
var arrive_threshold: float = 2.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	state_machine.Initialize(self)
	cursor.connect("cell_clicked", Callable(self, "_on_cell_clicked"))

	if tilemap:
		var cell_pos = Vector2i(0, 0)
		# Use the pathfinder's cell_to_world function to get proper center position
		global_position = pathfinder_node.cell_to_world(cell_pos)

func _physics_process(_delta: float) -> void:
	# Movement is handled in states; just slide here.
	move_and_slide()

# --- Cursor click handler ---
func _on_cell_clicked(target_cell: Vector2i) -> void:
	if not tilemap:
		return

	var player_cell = pathfinder_node.world_to_cell(global_position)
	var goal_cell = target_cell  # Use the actual clicked cell instead of cursor position
	path = pathfinder_node.GetPath(player_cell, goal_cell)
	path_index = 0

	print("Player cell:", player_cell, "Target cell:", goal_cell, "Path size:", path.size())

# --- Animations ---
func UpdateAnimation(state: String) -> void:
	animation_player.play(state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	elif cardinal_direction == Vector2.RIGHT:
		return "right"
	return "down"

func update_cardinal_from_direction(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0.0:
			cardinal_direction = Vector2.RIGHT
		else:
			cardinal_direction = Vector2.LEFT
	else:
		if dir.y > 0.0:
			cardinal_direction = Vector2.DOWN
		else:
			cardinal_direction = Vector2.UP
