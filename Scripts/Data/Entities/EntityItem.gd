tool # do not add tool in the 1st version
extends Resource
class_name EntityItem

export(Types.ItemCategoryTypes) var category_type
export(String) var name setget set_name # do not add setget in the 1st version
export(String) var identifier setget set_identifier # do not add setget in the 1st version, make the user input the name manually
export(Texture) var texture_icon
export(int) var attack_power = 0
export(int) var defense_value = 0
export(float) var price = 0.0
export(String) var special_trait
export(String) var effect
export(String) var description

#
# Setting an unique identifier automatically
# Show this in an update or advanced video
#

func set_name(value : String) -> void:
	name = value.trim_prefix(" ").trim_suffix(" ")

	if not (name and name != ""):
		identifier = ""
	elif not identifier or identifier == "":
		_generate_identifier()


func set_identifier(value : String) -> void:
	identifier = value.trim_prefix(" ").trim_suffix(" ")
	
	var has_valid_name = name and name != ""
		
	if has_valid_name and (not identifier or identifier == ""):
		_generate_identifier()

		
func _generate_identifier() -> void:
	identifier = (str(category_type) + name).md5_text()


func is_two_handed() -> bool:
	match category_type:
		Types.ItemCategoryTypes.TwoHandedWeapons, Types.ItemCategoryTypes.Bows:
			return true
		_:
			return false
	
