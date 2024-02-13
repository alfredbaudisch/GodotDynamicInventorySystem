@tool # do not add tool in the 1st version
extends Resource
class_name EntityItem

@export var category_type : Types.ItemCategoryTypes
@export var name: String: set = set_item_name
@export var identifier: String: set = set_identifier
@export var texture_icon: Texture2D
@export var attack_power: int = 0
@export var defense_value: int = 0
@export var price: float = 0.0
@export var special_trait: String
@export var effect: String
@export var description: String

#
# Setting an unique identifier automatically
# Show this in an update or advanced video
#

func set_item_name(value : String) -> void:
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
	
