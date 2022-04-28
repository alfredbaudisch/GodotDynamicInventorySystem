extends Object
class_name FileUtils


static func get_dir_names_from_path(path) -> Array:
	var contents = []	
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()		
		while file_name != "":			
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				contents.append(file_name)
				
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
		
	return contents


static func get_file_names_from_path(path, extension := "all") -> Array:
	var contents = []	
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		
		var file_name = dir.get_next()		
		while file_name != "":			
			if not dir.current_is_dir() and (extension == "all" or extension == file_name.get_extension()):
				contents.append(file_name)
				
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")
		
	return contents


static func load_resources_from_path(path) -> Array:
	var resources = []
	
	for filename in get_file_names_from_path(path, "tres"):
		resources.append(load(path + "/" + filename))
		
	return resources	
	
