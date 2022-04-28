extends ControlWithItem

export(Array, Types.ItemCategoryTypes) var item_category_type = []

onready var _texture_background := $UIFrame/TextureRect

var _texture_background_normal := preload("res://Assets/UI/ButtonBackgrounds/Highlight-Normal.png")
var _texture_background_equipped := preload("res://Assets/UI/ButtonBackgrounds/Highlight-Equipped.png")


func _ready() -> void:
	Events.connect("on_item_equipped", self, "_on_item_equipped")
	Events.connect("on_item_unequipped", self, "_on_item_unequipped")
	
	for category_type in item_category_type:
		var equipped_item = GameState.get_player_data().get_equipped_item_for_category_type(category_type)
		
		# If an item is equipped in at least one of the categories
		# assigned to this slot, set it as the item of the slot,
		# because it's not necessary to check the other categories
		# assigned to this slot (the slot is shared accross multiple
		# categories, but can have only one item at a time equipped)
		if equipped_item:
			set_item(equipped_item)
			break


func set_item(value : EntityItem) -> void:
	.set_item(value)
	_sync_item_equipped()


func _sync_item_equipped() -> void:
	var texture : Texture
	
	if item and GameState.player_check_is_item_equipped(item):
		texture = _texture_background_equipped
	else:
		texture = _texture_background_normal
		
	_texture_background.set_texture(texture)	


func _on_item_equipped(_item : EntityItem) -> void:
	for category_type in item_category_type:
		# The item received in the signal matches one of the categories
		# of this slot. Set it as the item of the slot.
		if _item.category_type == category_type:
			set_item(_item)
			break
				
	
func _on_item_unequipped(_item : EntityItem) -> void:
	if _item == item:
		set_item(null)
