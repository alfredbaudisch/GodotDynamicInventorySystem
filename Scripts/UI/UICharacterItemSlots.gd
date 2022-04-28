extends Control

onready var _placeholder_helmet := $SlotHelmet/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_helmet : TextureRect = $SlotHelmet/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_armor := $SlotArmor/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_armor : TextureRect = $SlotArmor/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_gloves := $SlotGloves/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_gloves : TextureRect = $SlotGloves/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_weapon := $SlotWeapon/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_weapon : TextureRect = $SlotWeapon/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_ammo := $SlotAmmo/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_ammo : TextureRect = $SlotAmmo/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_off_hand := $SlotOffHand/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_off_hand : TextureRect = $SlotOffHand/UIFrame/TextureRect/TextureEquipped
onready var _placeholder_boots := $SlotBoots/UIFrame/TextureRect/TexturePlaceholder
onready var _equipped_boots : TextureRect = $SlotBoots/UIFrame/TextureRect/TextureEquipped


func _ready():
	_sync_equipped_items()
	Events.connect("on_item_equipped", self, "_on_item_equipped")
	Events.connect("on_item_unequipped", self, "_on_item_unequipped")

	
func _sync_equipped_items() -> void:

# Show repeated code then show _sync_item function	
#	if player.equipped_helmet:
#		_equipped_helmet.set_texture(player.equipped_helmet.texture_icon)	
#	_placeholder_helmet.set_visible(not player.equipped_helmet)
#	_equipped_helmet.set_visible(bool(player.equipped_helmet))	
#	if player.equipped_armor:
#		_equipped_armor.set_texture(player.equipped_armor.texture_icon)	
#	_placeholder_armor.set_visible(not player.equipped_armor)
#	_equipped_armor.set_visible(bool(player.equipped_armor))

	_sync_item("helmet")
	_sync_item("armor")
	_sync_item("gloves")
	_sync_item("weapon")
	_sync_item("ammo")
	_sync_item("off_hand")
	_sync_item("boots")

func _sync_item(item_type_property_suffix : String) -> void:
	var item : EntityItem = GameState.player_data.get("equipped_" + item_type_property_suffix)
	var equipped_property := "_equipped_" + item_type_property_suffix
	var placeholder_property := "_placeholder_" + item_type_property_suffix	
	
	if item:
		get(equipped_property).set_texture(item.texture_icon)
		
	get(placeholder_property).set_visible(not item)
	get(equipped_property).set_visible(item != null)


func _on_item_equipped(_item : EntityItem) -> void:
	_sync_equipped_items()
	
	
func _on_item_unequipped(_item : EntityItem) -> void:
	_sync_equipped_items()
	
