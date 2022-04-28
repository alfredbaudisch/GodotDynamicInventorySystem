extends ControlWithItem

onready var _label_item_name : Label = $VBoxContainer/VBoxNameAndTypeContainer/HBoxNameAndTypeContainer/LabelItemName
onready var _label_item_type : Label = $VBoxContainer/VBoxNameAndTypeContainer/HBoxNameAndTypeContainer/LabelItemType
onready var _label_attack : Label = $VBoxContainer/HBoxMainStats/HBoxAttack/LabelAttack
onready var _label_defense : Label = $VBoxContainer/HBoxMainStats/HBoxDefense/LabelDefense
onready var _label_price : Label = $VBoxContainer/HBoxMainStats/HBoxPrice/LabelPrice
onready var _label_special : Label = $VBoxContainer/HBoxSpecialStats/HBoxSpecial/LabelSpecial
onready var _label_effect : Label = $VBoxContainer/HBoxSpecialStats/HBoxEffect/LabelEffect
onready var _label_description : RichTextLabel = $VBoxContainer/LabelDescription


func _ready() -> void:
	_label_item_name.set_text("Browse, Equip and Unequip Items")	
	_label_item_type.set_text("")	
	
	_label_attack.get_parent().set_visible(false)
	_label_defense.get_parent().set_visible(false)
	_label_price.get_parent().set_visible(false)
		
	_label_special.get_parent().set_visible(false)
	_label_effect.get_parent().set_visible(false)
	_label_description.set_visible(false)


func set_item(value : EntityItem) -> void:
	.set_item(value)
	
	_label_item_name.set_text(item.name)	
	_label_item_type.set_text("(" + Types.ItemCategoryTypes.keys()[item.category_type] + ")")
	
	_label_attack.set_text(str(item.attack_power))
	_label_attack.get_parent().set_visible(true)
	
	
	_label_defense.set_text(str(item.defense_value))
	_label_defense.get_parent().set_visible(true)
	
	_label_price.set_text(str(item.price))
	_label_price.get_parent().set_visible(true)
		
	if item.special_trait:
		_label_special.set_text(item.special_trait)
		_label_special.get_parent().set_visible(true)
	else:
		_label_special.get_parent().set_visible(false)
		
	if item.effect:
		_label_effect.set_text(item.effect)
		_label_effect.get_parent().set_visible(true)
	else:
		_label_effect.get_parent().set_visible(false)
		
	if item.description:
		_label_description.set_bbcode("[i]" + item.description + "[/i]")
		_label_description.set_visible(true)
	else:
		_label_description.set_visible(false)
