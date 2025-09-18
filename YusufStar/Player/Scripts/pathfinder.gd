extends Node
class_name Pathfinder

@export var tilemap: TileMapLayer
var astar := AStar2D.new()

var x_offset: int = 0
var y_offset: int = 0
var id_stride: int = 10000
var id_to_cell_map: Dictionary = {}
var cell_to_id_map: Dictionary = {}

func _ready() -> void:
	BuildAStar()

func BuildAStar() -> void:
	if not tilemap:
		return
	
	astar.clear()
	id_to_cell_map.clear()
	cell_to_id_map.clear()
	var used_rect = tilemap.get_used_rect()
	# Normalize IDs to non-negative space to avoid modulo/division issues
	x_offset = -used_rect.position.x
	y_offset = -used_rect.position.y
	id_stride = max(1, used_rect.size.x + 1)
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell = Vector2i(x, y)
			var tile_data = tilemap.get_cell_tile_data(cell)
			if tile_data and tile_data.get_custom_data("walkable") == true:
				var id = _cell_to_id(cell)
				if not astar.has_point(id):
					astar.add_point(id, Vector2(cell.x, cell.y))
					id_to_cell_map[id] = cell
					cell_to_id_map[cell] = id


	# Connect neighbors
	for id in astar.get_point_ids():
		var cell = _id_to_cell(id)
		for n in _get_neighbors(cell):
			var nid = _cell_to_id(n)
			if astar.has_point(nid) and not astar.are_points_connected(id, nid, true):
				astar.connect_points(id, nid, true)

func _cell_to_id(cell: Vector2i) -> int:
	return (cell.y + y_offset) * id_stride + (cell.x + x_offset)

func _id_to_cell(id: int) -> Vector2i:
	if id_to_cell_map.has(id):
		return id_to_cell_map[id]
	# Fallback to formula (should rarely be needed)
	var x = (id % id_stride) - x_offset
	var y = int(floor(float(id) / float(id_stride))) - y_offset
	return Vector2i(x, y)

func _get_neighbors(cell: Vector2i) -> Array:
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	var res = []
	for d in dirs:
		res.append(cell + d)
	return res

func GetPath(start: Vector2i, goal: Vector2i) -> Array:
	var sid = _cell_to_id(start)
	var gid = _cell_to_id(goal)
	var start_ok = astar.has_point(sid)
	var goal_ok = astar.has_point(gid)
	
	if not start_ok:
		var closest_s = astar.get_closest_point(Vector2(start))
		if closest_s != -1:
			sid = closest_s
			start_ok = true
	if not goal_ok:
		var closest_g = astar.get_closest_point(Vector2(goal))
		if closest_g != -1:
			gid = closest_g
			goal_ok = true
	
	if not start_ok or not goal_ok:
		return []
	
	var path_ids = astar.get_id_path(sid, gid)
	if path_ids.is_empty():
		return []
	
	# Convert IDs back to Vector2i cells
	var cell_path: Array = []
	for id in path_ids:
		cell_path.append(_id_to_cell(id))
	
	return cell_path

func world_to_cell(pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(pos))

func cell_to_world(cell: Vector2i) -> Vector2:
	# Get the local position of the cell
	var local_pos = tilemap.map_to_local(cell)
	# Convert to global and ensure it's centered in the cell
	return tilemap.to_global(local_pos)

func GetPathWorld(start_global: Vector2, goal_global: Vector2) -> PackedVector2Array:
	var start_cell = world_to_cell(start_global)
	var goal_cell = world_to_cell(goal_global)
	var raw_path: PackedVector2Array = GetPath(start_cell, goal_cell)
	var world_path: PackedVector2Array = []
	for p in raw_path:
		var c = Vector2i(round(p.x), round(p.y))
		world_path.append(cell_to_world(c))
	return world_path
