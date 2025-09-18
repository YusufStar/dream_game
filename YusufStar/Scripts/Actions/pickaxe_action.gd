extends ItemAction
class_name PickaxeAction

# Pickaxe (Kazma) item action

func execute(_player: Player, target_cell: Vector2i, tilemap: TileMapLayer, user_data: Node) -> void:
	# Check if the tile is mineable
	var tile_data = tilemap.get_cell_tile_data(target_cell)
	if tile_data and tile_data.has_custom_data("mineable") and tile_data.get_custom_data("mineable"):
		print("⛏️ PICKAXE ACTION: Mining at cell ", target_cell, " - SUCCESS!")
		# Add mining logic here
	else:
		print("⛏️ PICKAXE ACTION: Cannot mine at cell ", target_cell, " - Not mineable!")

func can_execute(_player: Player, target_cell: Vector2i, tilemap: TileMapLayer) -> bool:
	var tile_data = tilemap.get_cell_tile_data(target_cell)
	if tile_data and tile_data.has_custom_data("mineable"):
		return tile_data.get_custom_data("mineable")
	return false

func get_item_type() -> ItemManager.ItemType:
	return ItemManager.ItemType.PICKAXE

func get_description() -> String:
	return "Mine Action - Mines tiles marked as mineable"
