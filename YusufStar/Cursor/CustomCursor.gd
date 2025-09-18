extends Sprite2D
class_name Cursor

signal cell_clicked(cell : Vector2i)

@export var ground_display: TileMapLayer
@export var cell_size: int = 32

var target_position: Vector2

func _input(event):
	if not ground_display:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local = ground_display.get_local_mouse_position()
		var cell = ground_display.local_to_map(local)
		print("Cursor clicked cell:", cell)
		emit_signal("cell_clicked", cell)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	if not ground_display:
		return
	
	var mouse_pos: Vector2 = ground_display.get_local_mouse_position()
	var cell: Vector2i = ground_display.local_to_map(mouse_pos)
	var snapped_pos: Vector2 = ground_display.map_to_local(cell)
	target_position = ground_display.to_global(snapped_pos)
	global_position = target_position
