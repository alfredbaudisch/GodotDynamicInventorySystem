extends Object
class_name DevUtils

static func get_name_from_sprite_file_name(file_name : String) -> String:
	var regex = RegEx.new()
	regex.compile("[A-Z]{1}[a-z]*") # Ex: WoodenMace, OldPoleaxe
	
	var results : PoolStringArray = []
	for result in regex.search_all(file_name):
		results.push_back(result.get_string())
		
	if not results.empty():
		return results.join(" ")
	else:
		return file_name
	
# Create Resource files from every item sprite
# DevUtils.create_item_resources()
static func create_item_resources() -> void:
	return # already executed
	randomize()
	
	var resources_path := "res://Data/Items/"
	var sprites_path := "res://Assets/Sprites/"
	var sprite_folders := FileUtils.get_dir_names_from_path(sprites_path)
	
	for sprite_folder in sprite_folders:
		var path = sprites_path + sprite_folder + "/"
		var sprites := FileUtils.get_file_names_from_path(path)
		
		for sprite in sprites:
			if sprite.get_extension() == "import":
				continue
				
			var sprite_with_path = path + sprite
			var resource = EntityItem.new()		
			resource.category_type = Types.ItemCategoryTypes[sprite_folder]
			resource.name = get_name_from_sprite_file_name(sprite.get_basename())
			
			var texture = Resource.new()
			texture.set_path(sprite_with_path) 
			resource.texture_icon = texture
			
			match resource.category_type:
				Types.ItemCategoryTypes.OneHandedWeapons:
					resource.attack_power = randi() % 61 + 2
					
				Types.ItemCategoryTypes.TwoHandedWeapons:
					resource.attack_power = randi() % 120 + 20
					resource.defense_value = randi() % 25
					
				Types.ItemCategoryTypes.Arrows:
					resource.attack_power = randi() % 20 + 1
					
				Types.ItemCategoryTypes.Bows:
					resource.attack_power = randi() % 51 + 10
					
				Types.ItemCategoryTypes.Armors:
					resource.defense_value = randi() % 40 + 1
					
				Types.ItemCategoryTypes.Helmets, Types.ItemCategoryTypes.Gloves, Types.ItemCategoryTypes.Boots:
					resource.defense_value = randi() % 21 + 5
					
				Types.ItemCategoryTypes.Shields:
					resource.defense_value = randi() % 101 + 11
					
			resource.price = randi() % 1000
			resource.description = "Random description " + str(randi() % 1000)			
			
			if ((randi() % 10000) % 2) == 0:
				resource.special_trait = "Rand " + str(randi() % 1000)
				
			if ((randi() % 10000) % 3) == 0:
				resource.effect = "Rand " + str(randi() % 1000)
			
			var resource_file = resources_path + sprite_folder + "/" + sprite.get_basename() + "_" + sprite_folder + ".tres"
			var res = ResourceSaver.save(resource_file, resource)			
			
			if res != OK:
				printerr("Could not save resource for: ", path, ", ", sprite, ". Error: ", res)
				assert(false)

# Remove "_[Paint]" from item sprite names
# DevUtils.sanitize_sprite_names("res://Assets/Sprites")
static func sanitize_sprite_names(path) -> void:
	return # already executed
	
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()		
		while file_name != "":			
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				sanitize_sprite_names(path + "/" + file_name)
			else:
				dir.rename(path + "/" + file_name, path + "/" + file_name.replace("_[Paint]", ""))
				dir.rename(path + "/" + file_name, path + "/" + file_name.replace(" [Paint]", ""))

			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
