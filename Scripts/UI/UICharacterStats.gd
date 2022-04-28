extends Control

onready var _label_level := $VBoxContainer/LabelLevel
onready var _progress_bar_exp := $VBoxContainer/ProgressBarExp


func _on_UICharacterStats_draw() -> void:
	var level = GameState.player_data.level
	_label_level.set_text("Level " + str(level))
	
	var needed_next_level = level * 100
	var progress = clamp(GameState.player_data.experience / needed_next_level, 0.0, 1.0)	
	_progress_bar_exp.set_value(progress)
	_progress_bar_exp.set_tooltip(str(progress * 100) + "%")
