extends Control
class_name ControlWithItem

var item : EntityItem setget set_item,get_item


func set_item(value : EntityItem) -> void:
	item = value


func get_item() -> EntityItem:
	return item
