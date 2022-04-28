extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var data : MockedPersistedUserInventory
	var loaded := false
	
	if ResourceLoader.exists("user://godot_test_inventory.tres"):
		data = ResourceLoader.load("user://godot_test_inventory.tres", "Resource")
		
		if data is MockedPersistedUserInventory:
			loaded = true
			print("found data file and it's valid")
			
#			var rare_sword = MockedInventoryItem.new()
#			rare_sword.type = MockedInventoryItem.TestItemTypes.WEAPON
#			rare_sword.price = 998.66			
#			data.items.append(rare_sword)
			
			# To update a position, a duplicate needs to be made,
			# otherwise a reference to the base Resource will be saved without changes
			var first = data.items[0].duplicate()
			first.price = 665
			data.items[0] = first
			
#			var sword = load("res://Mockups/TestSwordItem.tres")
#			data.items.append(sword)
			
			ResourceSaver.save("user://godot_test_inventory.tres", data)
			
			for i in data.items:
				print(i.price)
		
	
	
	if not loaded:
		data = load("res://Mockups/PreloadTestInventory.tres")
	
		if data is MockedPersistedUserInventory:
			ResourceSaver.save("user://godot_test_inventory.tres", data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
