extends ItemAction
class_name ShovelAction

# Shovel (Kürek) item action

func execute(player: Player, target_cell: Vector2i, tilemap: TileMapLayer, _node: Node) -> void:
	if can_execute(player, target_cell, tilemap):
		# Find the player node from group for consistent adjacency logic
		var player_node = player
		if not is_instance_valid(player_node):
			var tree = player.get_tree() if player.has_method("get_tree") else null
			if tree:
				player_node = tree.get_first_node_in_group("player")
		if not player_node:
			return
		var player_cell = player_node.pathfinder_node.world_to_cell(player_node.global_position)
		var delta = target_cell - player_cell
		var direction = ""
		if abs(delta.x) > abs(delta.y):
			if delta.x > 0:
				direction = "right"
			else:
				direction = "left"
		else:
			if delta.y > 0:
				direction = "down"
			else:
				direction = "up"

		# If adjacent (not diagonal), just rotate and dig
		if ((abs(delta.x) == 1 and delta.y == 0) or (abs(delta.y) == 1 and delta.x == 0)) and not (delta == Vector2i.ZERO):
			player_node.update_cardinal_from_direction(target_cell - player_cell)
			player_node.on_action_started()
			var anim_name_adj = "dig_" + direction
			if player_node.animation_player.has_animation(anim_name_adj):
				player_node.UpdateAnimation(anim_name_adj)
				# Wait for first 0.4s (animation only)
				await player_node.get_tree().create_timer(0.4).timeout
				# Paint the tile as dug (terrain index 1) and update neighbors
				if tilemap:
					var cell = target_cell
					# 1 = kazılmış toprak terrain ID'si
					tilemap.set_cells_terrain_connect([cell], 0, 1)
				# Wait for remaining 0.4s
				await player_node.get_tree().create_timer(0.4).timeout
				player_node.UpdateAnimation("idle")
				player_node.on_action_finished()
			else:
				player_node.on_action_finished()
			return

		# Only allow digging if the target is adjacent (no pathfinding for non-adjacent)
		return

func can_execute(_player: Player, target_cell: Vector2i, tilemap: TileMapLayer) -> bool:
	var tile_data = tilemap.get_cell_tile_data(target_cell)
	if tile_data and tile_data.has_custom_data("excavable"):
		return tile_data.get_custom_data("excavable")
	return false

func get_item_type() -> ItemManager.ItemType:
	return ItemManager.ItemType.SHOVEL

func get_description() -> String:
	return "Dig Action - Excavates tiles marked as excavable"
