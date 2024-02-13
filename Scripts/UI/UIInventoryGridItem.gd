extends Control

@onready var _ui_inventory_item := $HBoxContainer/UIInventoryItem


func get_ui_inventory_item() -> Node:
	return _ui_inventory_item
