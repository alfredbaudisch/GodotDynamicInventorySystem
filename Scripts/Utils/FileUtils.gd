extends Object
class_name FileUtils


static func get_dir_names_from_path(path) -> Array:
	var contents = []	
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		
		var file_name = dir.get_next()		
		while file_name != "":			
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				contents.append(file_name)
				
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
		
	return contents


static func get_file_names_from_path(path, extensions : Array = []) -> Array:
	var contents = []	
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		
		var file_name = dir.get_next()		
		while file_name != "":
			if not dir.current_is_dir() and (extensions.is_empty() or extensions.has(file_name.get_extension())):
				contents.append(file_name)
				
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")

	return contents


static func load_resources_from_path(path) -> Array:
	var resources = []
	
	for filename in get_file_names_from_path(path, ["tres", "remap"]):
		# TODO: temp fix due to https://github.com/godotengine/godot/issues/66014
		# Another solution is to change editor/export/convert_text_resources_to_binary
		if filename.ends_with(".remap"):
			filename = filename.trim_suffix(".remap")
			
		resources.append(load(path + "/" + filename))
		
	return resources	
	
