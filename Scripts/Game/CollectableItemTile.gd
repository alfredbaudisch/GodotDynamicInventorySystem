extends Area2D
class_name CollectableItemTile

@export var item: Resource: get = get_item


func get_item() -> EntityItem:
	return item


func collect() -> void:
	queue_free()
