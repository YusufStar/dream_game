extends ItemAction
class_name WateringCanAction

# Watering Can (Sulama Kabı) item action

func execute(_player: Player, target_cell: Vector2i, tilemap: TileMapLayer, node: Node) -> void:
	# Check if the tile is waterable
	var tile_data = tilemap.get_cell_tile_data(target_cell)
	if tile_data and tile_data.has_custom_data("waterable") and tile_data.get_custom_data("waterable"):
		print("💧 WATERING CAN ACTION: Watering at cell ", target_cell, " - SUCCESS!")
		# Add watering logic here
	else:
		print("💧 WATERING CAN ACTION: Cannot water at cell ", target_cell, " - Not waterable!")

func can_execute(_player: Player, target_cell: Vector2i, tilemap: TileMapLayer) -> bool:
	var tile_data = tilemap.get_cell_tile_data(target_cell)
	if tile_data and tile_data.has_custom_data("waterable"):
		return tile_data.get_custom_data("waterable")
	return false

func get_item_type() -> ItemManager.ItemType:
	return ItemManager.ItemType.WATERING_CAN

func get_description() -> String:
	return "Water Action - Waters tiles marked as waterable"
