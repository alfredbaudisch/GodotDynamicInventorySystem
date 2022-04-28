extends Area2D
class_name CollectableItemTile

export(Resource) var item setget ,get_item


func get_item() -> EntityItem:
	return item


func collect() -> void:
	queue_free()
