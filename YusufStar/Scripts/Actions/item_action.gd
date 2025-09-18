class_name ItemAction
extends RefCounted

# Base class for all item actions
# Each item type should have its own action script that extends this class
var disable_input_during_action: bool = true

# Virtual function to be overridden by specific item actions
func execute(player: Player, target_cell: Vector2i, tilemap: TileMapLayer, node: Node) -> void:
    if disable_input_during_action:
        player.on_action_started()
    # Perform the action
    # Simulate action duration (e.g., animation length)
    await node.get_tree().create_timer(1.0).timeout  # Example: 1 second delay
    if disable_input_during_action:
        player.on_action_finished()

# Virtual function to check if action can be performed
func can_execute(_player: Player, _target_cell: Vector2i, _tilemap: TileMapLayer) -> bool:
    # Override this in specific item action classes for validation
    return true

# Get the item type this action belongs to
func get_item_type() -> ItemManager.ItemType:
    # Override this in specific item action classes
    return ItemManager.ItemType.NONE

# Get action description for debugging
func get_description() -> String:
    # Override this in specific item action classes
    return "Base Action"