extends Control

export var item_active_modulate_color := Color(1.0, 1.0, 1.0, 1.0)
export var item_inactive_modulate_color := Color(1.0, 1.0, 1.0, 0.3)
export var is_active := false

onready var _button := $CenterContainerIcon/ButtonCategoryIcon
onready var _separator := $ColorRectSeparator

var category : EntityItemCategoryDisplay setget set_category,get_category


func _ready() -> void:
	# Force to be dehighlighted...
	dehighlight(true)
	# ...and then set as highlighted if this is the active category display.
	highlight()


func set_category(value : EntityItemCategoryDisplay) -> void:
	category = value
	_button.set_normal_texture(category.texture_icon)
	
	
func get_category() -> EntityItemCategoryDisplay:
	return category
	

func set_active(active : bool = true) -> void:
	is_active = active
	highlight() if is_active else dehighlight()


func highlight(force : bool = false) -> void:
	if force or is_active:
		set_modulate(item_active_modulate_color)


func dehighlight(force : bool = false) -> void:
	if force or not is_active:
		set_modulate(item_inactive_modulate_color)


func get_button() -> Node:
	return _button


func _on_UIInventoryCategory_hide() -> void:
	dehighlight()
