extends Node

const ItemsPath = "res://Data/Items"
const ItemCategoryDisplaysPath = "res://Data/ItemCategoryDisplays"
const SaveFileName = "user://SavedEntityPlayer.tres"

var state : int = Types.GameStates.Active
var player_data : EntityPlayer: get = get_player_data
var item_category_displays : Array = []: get = get_item_category_displays


# You can define multiple player presets
var _default_player := preload("res://Data/DefaultPlayer.tres")


func _init() -> void:
	item_category_displays = FileUtils.load_resources_from_path(ItemCategoryDisplaysPath)
	
	#
	# WARNING: Implement load/save only after adding dynamic data everywhere
	#
	player_data = _default_player.duplicate()
	player_data.make_inventory_unique()
	
	return
	# Load saved data or initialize default data
	var got_persisted_data := load_game()	
	
	if not got_persisted_data and not player_data:
		player_data = _default_player.duplicate()
		player_data.make_inventory_unique()
	
	save_game()
	

func load_game() -> bool:
	if ResourceLoader.exists(SaveFileName):
		var data = ResourceLoader.load(SaveFileName, "Resource")
		
		# Valid data loaded
		if data is EntityPlayer:
			player_data = data
			return true
	
	return false
		
		
func save_game() -> bool:
	var res = ResourceSaver.save(player_data, SaveFileName)
	
	if res != OK:
		printerr("Could not save game. Error: ", res)
		
	return res == OK


func get_player_data() -> EntityPlayer:
	return player_data


func get_item_category_displays() -> Array:
	return item_category_displays
	
	
func get_inventory_items_from_category(category : int) -> Array:
	return player_data.get_inventory_by_category().get(category, [])
			

func count_inventory_items_from_category_display(display : EntityItemCategoryDisplay) -> int:
	var inventory_by_category = player_data.get_inventory_by_category()
	var count := 0
	
	for category in display.types:
		if inventory_by_category.has(category):
			count += inventory_by_category[category].size()
	
	return count


func player_equip_item(item : EntityItem) -> void:
	# Before equipping the item, you could check here whether
	# the player has the item in the inventory. 
	# But for the purpose of this project, this is not necessary,
	# because this function is used internally.
	
	var property = player_data.get_equipped_property_for_item(item)
	var currently_equipped = player_data.get(property)
	
	if currently_equipped and currently_equipped != item:
		player_unequip_item(currently_equipped)
		
	player_data.set(property, item)
	Events.emit_signal("on_item_equipped", item)
	
	var has_equipped_two_handed = player_data.equipped_weapon and player_data.equipped_weapon.is_two_handed()	
	var is_equipping_two_handed = item.is_two_handed()
	
	# TwoHandedWeapon has been just equipped, but the player has a OffHand equipped,
	# unequip the off hand (currently only Shield)
	if (is_equipping_two_handed and player_data.equipped_off_hand):
		player_unequip_item(player_data.equipped_off_hand)
		
	# Shield has been just equipped, but the player has a TwoHandedWeapon equipped,
	# unequip the weapon
	elif (item.category_type == Types.ItemCategoryTypes.Shields and has_equipped_two_handed):
		player_unequip_item(player_data.equipped_weapon)
	
	
func player_unequip_item(item : EntityItem) -> void:
	var property = player_data.get_equipped_property_for_item(item)
	player_data.set(property, null)
	Events.emit_signal("on_item_unequipped", item)
	

func player_check_is_item_equipped(item : EntityItem) -> bool:
	var property = player_data.get_equipped_property_for_item(item)	
	return player_data.get(property) == item


func is_item_in_inventory(item : EntityItem) -> bool:
	return player_data.inventory.find(item) != -1


# We're not dealing with countable items in the inventory
# so for now just add the item into the inventory
# (multiple entries of the same item will be listed)
func acquire_item(item : EntityItem) -> void:
	player_data.append_to_inventory(item.duplicate())
	Events.emit_signal("on_item_acquired", item)


func acquire_gold(amount : int) -> void:
	player_data.gold += amount
	Events.emit_signal("on_gold_acquired", amount)
