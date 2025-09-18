extends Node

# Global singleton to manage the player's active item
# This script should be added as an AutoLoad in Project Settings

enum ItemType {
	NONE,
	SHOVEL,
	PICKAXE,
	WATERING_CAN,
	SWORD,
	# Add more items as needed
}

# Current active item
var active_item: ItemType = ItemType.NONE

# Item names for animation prefixes
var item_names: Dictionary = {
	ItemType.NONE: "",
	ItemType.SHOVEL: "dig",
	ItemType.PICKAXE: "mine",
	ItemType.WATERING_CAN: "water",
	ItemType.SWORD: "attack",
	# Add more items as needed
}

# Cursor overlay settings for each item
var item_cursor_settings: Dictionary = {
	ItemType.NONE: {
		"enable_mouse_color": false,
		"tile_data_name": "",
		"active_color": "#FFFFFF",
		"deactive_color": "#FF0000"
	},
	ItemType.SHOVEL: {
		"enable_mouse_color": true,
		"tile_data_name": "excavable",
		"active_color": "#0044ffff", # Green with low opacity
		"deactive_color": "#ff00003f" # Red with low opacity
	},
	ItemType.PICKAXE: {
		"enable_mouse_color": false,
		"tile_data_name": "mineable",
		"active_color": "#0044ffff", # Green with low opacity
		"deactive_color": "#ff00003f" # Red with low opacity
	},
	ItemType.WATERING_CAN: {
		"enable_mouse_color": false,
		"tile_data_name": "waterable",
		"active_color": "#0044ffff", # Green with low opacity
		"deactive_color": "#ff00003f" # Red with low opacity
	},
	ItemType.SWORD: {
		"enable_mouse_color": false,
		"tile_data_name": "",
		"active_color": "#FFFFFF",
		"deactive_color": "#FF0000"
	}
}

# Signals for when the active item changes
signal active_item_changed(new_item: ItemType, old_item: ItemType)

func _ready() -> void:
	# Set default item if needed
	set_active_item(ItemType.NONE)

# Set the active item
func set_active_item(item: ItemType) -> void:
	var old_item = active_item
	active_item = item
	active_item_changed.emit(active_item, old_item)
	print("Active item changed to: ", ItemType.keys()[active_item])

# Get the current active item
func get_active_item() -> ItemType:
	return active_item

# Get the animation prefix for the current item
func get_animation_prefix() -> String:
	if active_item in item_names:
		return item_names[active_item]
	return ""

# Check if player has a specific item equipped
func has_item_equipped(item: ItemType) -> bool:
	return active_item == item

# Get item name as string
func get_item_name() -> String:
	return ItemType.keys()[active_item]

# Get cursor settings for current item
func get_cursor_settings() -> Dictionary:
	if active_item in item_cursor_settings:
		return item_cursor_settings[active_item]
	return item_cursor_settings[ItemType.NONE]

# Get specific cursor setting
func get_cursor_setting(setting_name: String):
	var settings = get_cursor_settings()
	if setting_name in settings:
		return settings[setting_name]
	return null

# Check if current item should show mouse color overlay
func should_show_mouse_color() -> bool:
	return get_cursor_setting("enable_mouse_color")

# Get tile data name to check for current item
func get_tile_data_name() -> String:
	return get_cursor_setting("tile_data_name")

# Get active color for current item
func get_active_color() -> String:
	return get_cursor_setting("active_color")

# Get deactive color for current item  
func get_deactive_color() -> String:
	return get_cursor_setting("deactive_color")

# Utility function to cycle through items (for testing/demo purposes)
func cycle_to_next_item() -> void:
	var current_index = active_item as int
	var max_index = ItemType.size() - 1
	var next_index = (current_index + 1) % (max_index + 1)
	set_active_item(next_index as ItemType)

# Example functions for specific items
func equip_shovel() -> void:
	set_active_item(ItemType.SHOVEL)

func equip_pickaxe() -> void:
	set_active_item(ItemType.PICKAXE)

func equip_watering_can() -> void:
	set_active_item(ItemType.WATERING_CAN)

func equip_sword() -> void:
	set_active_item(ItemType.SWORD)

func unequip_item() -> void:
	set_active_item(ItemType.NONE)