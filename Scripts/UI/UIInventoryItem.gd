extends ControlWithItem

onready var _button : TextureButton = $UIFrame/ButtonSelection setget ,get_button
onready var _texture_item_sprite := $UIFrame/TextureItemBackground/TextureItemSprite
onready var _texture_background := $UIFrame/TextureItemBackground
onready var _animation_player := $UIFrame/AnimationPlayer

var _texture_background_normal := preload("res://Assets/UI/ButtonBackgrounds/Highlight-Normal.png")
var _texture_background_equipped := preload("res://Assets/UI/ButtonBackgrounds/Highlight-Equipped.png")

var _is_higlighted := false


func _ready() -> void:	
	deselect()	
	_button.set_visible(true)
	
	Events.connect("on_item_equipped", self, "_on_item_equipped")
	Events.connect("on_item_unequipped", self, "_on_item_unequipped")
	
	
func set_item(value : EntityItem) -> void:
	.set_item(value)
	_texture_item_sprite.set_texture(item.texture_icon)
	_sync_item_equipped()

func select() -> void:
	_button.set_modulate(Color(1.0, 1.0, 1.0, 1.0))


func deselect() -> void:
	_button.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	dehighlight()
	

func highlight() -> void:	
	_animation_player.play("Highlight")
	_is_higlighted = true


func dehighlight() -> void:
	if _is_higlighted:
		_animation_player.play("DeHighlight")
		_is_higlighted = false


func get_button() -> TextureButton:
	return _button


func _sync_item_equipped() -> void:
	var texture : Texture
	
	if GameState.player_check_is_item_equipped(item):
		texture = _texture_background_equipped
	else:
		texture = _texture_background_normal
		
	_texture_background.set_texture(texture)	


func _on_UIInventoryItem_hide() -> void:
	deselect()


func _on_item_equipped(_item : EntityItem) -> void:
	if _item == item:
		_sync_item_equipped()
	
	
func _on_item_unequipped(_item : EntityItem) -> void:
	if _item == item:
		_sync_item_equipped()
