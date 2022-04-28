extends Control

onready var _label_gold := $LabelGold

func _reload() -> void:
	_label_gold.set_text(str(GameState.player_data.gold))

func _on_HBoxGold_draw() -> void:
	_reload()
