extends Node
class_name ItemActionRegistry

# Only shovel for now
var actions: Dictionary = {
    ItemManager.ItemType.NONE: null,
    ItemManager.ItemType.SHOVEL: ShovelAction.new(),
    ItemManager.ItemType.WATERING_CAN: WateringCanAction.new(),
    ItemManager.ItemType.PICKAXE: PickaxeAction.new(),
}

func get_action(item_type: ItemManager.ItemType):
	if item_type in actions:
		return actions[item_type]
	return null