extends Control
class_name ControlWithItem

var item : EntityItem: get = get_item, set = set_item


func set_item(value : EntityItem) -> void:
	item = value


func get_item() -> EntityItem:
	return item
