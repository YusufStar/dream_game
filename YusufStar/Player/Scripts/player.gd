extends CharacterBody2D
class_name Player

# --- Movement ---
var acceleration: float = 25.0
var cardinal_direction: Vector2 = Vector2.DOWN
var is_input_disabled: bool = false
var is_action_in_progress: bool = false

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
	add_to_group("player")
	state_machine.Initialize(self)
	cursor.connect("cell_clicked", Callable(self, "_on_cell_clicked"))

	if tilemap and pathfinder_node:
		var cell_pos = Vector2i(0, 0)
		# Use the pathfinder's cell_to_world function to get proper center position
		global_position = pathfinder_node.cell_to_world(cell_pos)

func _unhandled_input(event: InputEvent) -> void:
	if is_input_disabled:
		return  # Ignore all inputs if disabled

	# Handle item switching for testing (you can remove this later)
	if event.is_action_pressed("num_0"):  # 0 key
		ItemManager.unequip_item()
	elif event.is_action_pressed("num_1"):  # 1 key
		ItemManager.equip_shovel()
	elif event.is_action_pressed("ui_accept"):  # Space key
		var active_item = ItemManager.get_active_item()
		if active_item != ItemManager.ItemType.NONE:
			var item_action_registry = ItemActionRegistry.new()
			var action = item_action_registry.get_action(active_item)
			if action and cursor and tilemap:
				var mouse_pos = cursor.ground_display.get_local_mouse_position()
				var cell = cursor.ground_display.local_to_map(mouse_pos)
				# Pass self as node for coroutine support
				action.execute(self, cell, tilemap, self)

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

# --- Animations ---
func UpdateAnimation(state: String) -> void:
	# If state is a full animation name (e.g. dig_down), play it directly
	if animation_player.has_animation(state):
		animation_player.play(state)
		return
	var animation_name = _build_animation_name(state)
	animation_player.play(animation_name)

func _build_animation_name(state: String) -> String:
	var item_prefix = ItemManager.get_animation_prefix()
	var anim_direction = AnimDirection()
	
	# If player has an item equipped, use item-specific animation
	if state == "idle":
		return "idle_" + anim_direction
	elif item_prefix != "":
		return item_prefix + "_" + state + "_" + anim_direction
	else:
		# Default animation without item
		return state + "_" + anim_direction

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

func on_action_finished() -> void:
	is_input_disabled = false
	is_action_in_progress = false
	if state_machine:
		state_machine.set_process(true)

func on_action_started() -> void:
	is_input_disabled = true
	is_action_in_progress = true
	if state_machine:
		state_machine.set_process(false)
