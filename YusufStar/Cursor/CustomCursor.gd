extends Sprite2D
class_name Cursor

signal cell_clicked(cell : Vector2i)

@export var ground_display: TileMapLayer
@export var cell_size: int = 32

var target_position: Vector2
var overlay_rect: ColorRect
var current_cell: Vector2i

func _input(event):
	if not ground_display:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local = ground_display.get_local_mouse_position()
		var cell = ground_display.local_to_map(local)
		emit_signal("cell_clicked", cell)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_setup_overlay()
	
	# Connect to ItemManager signals
	if ItemManager:
		ItemManager.active_item_changed.connect(_on_item_changed)

func _setup_overlay() -> void:
	# Create overlay rectangle for showing tile validity
	overlay_rect = ColorRect.new()
	overlay_rect.size = Vector2(cell_size, cell_size)
	overlay_rect.color = Color.TRANSPARENT
	overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay_rect)
	
	# Center the overlay relative to cursor
	overlay_rect.position = Vector2(-cell_size/2.0, -cell_size/2.0)

func _process(_delta: float) -> void:
	if not ground_display:
		return
	
	var mouse_pos: Vector2 = ground_display.get_local_mouse_position()
	var cell: Vector2i = ground_display.local_to_map(mouse_pos)
	var snapped_pos: Vector2 = ground_display.map_to_local(cell)
	target_position = ground_display.to_global(snapped_pos)
	global_position = target_position
	
	# Update overlay if cell changed
	if cell != current_cell:
		current_cell = cell
		_update_overlay()

func _update_overlay() -> void:
	if not overlay_rect or not ItemManager:
		return

	# Check if current item should show overlay
	if not ItemManager.should_show_mouse_color():
		overlay_rect.color = Color.TRANSPARENT
		return

	# Get tile data name to check
	var tile_data_name = ItemManager.get_tile_data_name()
	if tile_data_name == "":
		overlay_rect.color = Color.TRANSPARENT
		return

	# Check if current cell has the required custom data
	var tile_data = ground_display.get_cell_tile_data(current_cell)
	var is_valid = false
	if tile_data and tile_data.has_custom_data(tile_data_name):
		is_valid = tile_data.get_custom_data(tile_data_name)

	# --- NEW: Check adjacency to player ---
	var player = get_tree().get_first_node_in_group("player")
	var is_adjacent = false
	if player:
		var player_cell = player.pathfinder_node.world_to_cell(player.global_position)
		var delta = current_cell - player_cell
		# Only allow direct neighbors (no diagonals, and not self)
		is_adjacent = ((abs(delta.x) == 1 and delta.y == 0) or (abs(delta.y) == 1 and delta.x == 0)) and not (delta == Vector2i.ZERO)

	# Set overlay color based on validity and adjacency
	var color_hex = ItemManager.get_active_color() if is_valid and is_adjacent else ItemManager.get_deactive_color()
	overlay_rect.color = Color(color_hex)

func _on_item_changed(_new_item: ItemManager.ItemType, _old_item: ItemManager.ItemType) -> void:
	# Update overlay when item changes
	_update_overlay()
