extends Resource
class_name EntityPlayer

export(int) var level = 1
export(int) var gold = 0
export(float) var experience = 0
export(Array, Resource) var inventory = []
var equipped_helmet : Resource
var equipped_armor : Resource
var equipped_gloves : Resource
var equipped_boots : Resource
var equipped_off_hand : Resource
var equipped_weapon : Resource
var equipped_ammo : Resource

var inventory_by_category : Dictionary setget ,get_inventory_by_category

# Make inventory items of the same type
# to not share instances. Each item instance must be unique.
# For example: if the inventory has 4x Broad Swords,
# if the player equips a broad sword, without
# unique instances, all 4 broad swords will be marked in the 
# inventory as equipped.
func make_inventory_unique() -> void:
	if not inventory.empty():
		for idx in range(inventory.size()):
			if inventory[idx]:
				inventory[idx] = inventory[idx].duplicate()


func get_equipped_property_for_item(item : EntityItem) -> String:
	return get_equipped_property_for_category_type(item.category_type)
		

func get_equipped_property_for_category_type(category_type : int) -> String:
	var property := ""
	
	match category_type:
		Types.ItemCategoryTypes.Helmets: property = "equipped_helmet"
		Types.ItemCategoryTypes.Armors: property = "equipped_armor"
		Types.ItemCategoryTypes.Gloves: property = "equipped_gloves"
		Types.ItemCategoryTypes.Boots: property = "equipped_boots"
		Types.ItemCategoryTypes.Shields: property = "equipped_off_hand"		
		Types.ItemCategoryTypes.OneHandedWeapons: property = "equipped_weapon"
		Types.ItemCategoryTypes.TwoHandedWeapons: property = "equipped_weapon"
		Types.ItemCategoryTypes.Bows: property = "equipped_weapon"
		Types.ItemCategoryTypes.Arrows: property = "equipped_ammo"
	
	return property
	
	
func get_equipped_item_for_category_type(category_type : int) -> EntityItem:
	var property := get_equipped_property_for_category_type(category_type)	
	return get(property)


func index_inventory() -> void:
	inventory_by_category = {}
	
	for item in inventory:
		if item is EntityItem:
			if inventory_by_category.has(item.category_type):
				inventory_by_category[item.category_type].append(item)
			else:
				inventory_by_category[item.category_type] = [item]

		
func get_inventory_by_category() -> Dictionary:
	if not inventory_by_category:
		index_inventory()
		
	return inventory_by_category


func append_to_inventory(item : EntityItem) -> void:
	inventory.append(item)
	index_inventory()
