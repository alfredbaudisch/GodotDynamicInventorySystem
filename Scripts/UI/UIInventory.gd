extends Control

const ScrollAnimationName = "ScrollItems"
const PagePadding = 0
const ItemsPerGrid = 20
const MaxAmountCategories = 7

@export var audio_stream_go_to_page: AudioStream
@export var audio_stream_item_hover: AudioStream
@export var audio_stream_item_pressed: AudioStream
@export var audio_stream_item_equip: AudioStream
@export var audio_stream_item_unequip: AudioStream
@export var audio_stream_item_context_menu_cancel: AudioStream
@onready var _audio_player := $AudioStreamPlayer
@onready var _audio_player_context_menu := $UIContextMenuContainer/AudioStreamPlayer

var _just_loaded := true

#
# Category members
#
@onready var _grid_categories := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/VBoxInventoryCategories/CenterContainer/GridContainer
@onready var _control_category_label_parent := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/VBoxInventoryCategories/ControlCategoryLabelParent
@onready var _label_category_name : Label = $HBoxMain/ControlItemsColumn/VBoxItemsColumn/VBoxInventoryCategories/ControlCategoryLabelParent/LabelCategoryName
@onready var _timer_category_name : Timer = $HBoxMain/ControlItemsColumn/VBoxItemsColumn/VBoxInventoryCategories/ControlCategoryLabelParent/TimerCategoryName

var _ui_inventory_category := preload("res://Scenes/UI/Elements/UIInventoryCategory.tscn")

var _category_displays_to_pages := {}
var _category_displays_to_ui := {}
var _pages_to_category_displays := {}
var _current_active_ui_inventory_category : Control
var _last_active_category_display : EntityItemCategoryDisplay

#
# Item members
#
@onready var _animation_player : AnimationPlayer = $HBoxMain/ControlItemsColumn/VBoxItemsColumn/HBoxInventoryItems/AnimationPlayer
@onready var _scroll_container := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/HBoxInventoryItems/ScrollContainerItemGrids
@onready var _item_grids_container := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/HBoxInventoryItems/ScrollContainerItemGrids/HBoxItemGridsContainer
@onready var _button_left := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/HBoxInventoryItems/ControlLeftColumn/ButtonLeft
@onready var _button_right := $HBoxMain/ControlItemsColumn/VBoxItemsColumn/HBoxInventoryItems/ControlRightColumn/ButtonRight
@onready var _context_menu_container := $UIContextMenuContainer
@onready var _context_menu := $UIContextMenuContainer/UIContextMenu
@onready var _ui_item_info := $HBoxMain/ControlInfoColumn/UIItemInfo

var _grid_template := preload("res://Scenes/UI/Elements/GridInventoryItems.tscn")
var _ui_inventory_grid_item := preload("res://Scenes/UI/Elements/UIInventoryGridItem.tscn")

# To keep track of item highlights with mouse hover
var _current_ui_inventory_item_selected : Node

var _current_scroll_page := 1
var _amount_scroll_pages := 1
var _page_size : float
var _scroll_animation : Animation
var _is_scrolling := false
var _scrolling_to_page := 1


func _ready() -> void:	
	Events.on_item_acquired.connect(_on_item_acquired)
	
	_reload()

				
func _reload() -> void:
	_context_menu_container.set_visible(false)
	
	_reload_items()
	await get_tree().process_frame
	
	var should_go_to_page := 0
	
	# If there's a category display that was active previously
	# and we are reloading the inventory, we should go back
	# to this previous active category	
	if _last_active_category_display:
		should_go_to_page = _category_displays_to_pages.get(_last_active_category_display, 0)
		if should_go_to_page > 1:
			_go_to_item_page(should_go_to_page)
	
	# Restart/setup the navigation
	if should_go_to_page <= 1:
		_update_navigation()
		
	await get_tree().process_frame

	if _just_loaded:
		_setup_context_menu()
	
	_just_loaded = false


func _reload_categories() -> void:
	# Clear all categories
	for child in _grid_categories.get_children():
		_grid_categories.remove_child(child)
	
	# First implement without sorting, then talk about how
	# to display in a certain order: rename category display data files
	# with numbers, example: 01_Armors
	
	# Dynamically load and place the category buttons	
	for category_display in GameState.get_item_category_displays():
		var ui = _ui_inventory_category.instantiate()
		ui.set_name(category_display.display_name)
		_grid_categories.add_child(ui)
		
		# Only add button events if the categories involved in this display
		# have any item, otherwise, show the display, but with disabled
		# behaviour.
		if GameState.count_inventory_items_from_category_display(category_display) > 0:
			# It has to be done here, after add_child,
			# because then the node is ready
			var button = ui.get_button()			
			button.mouse_entered.connect(_on_button_category_mouse_entered.bind(ui))
			button.mouse_exited.connect(_on_button_category_mouse_exited.bind(ui))
			button.pressed.connect(_on_button_category_pressed.bind(ui, _category_displays_to_pages.get(category_display)))
		
		ui.set_category(category_display)
		_category_displays_to_ui[category_display] = ui


func _set_active_category_display() -> void:
	if _pages_to_category_displays.is_empty():
		_label_category_name.set_visible(false)
		return
	
	var category_display = _pages_to_category_displays[_current_scroll_page]
	var ui = _category_displays_to_ui.get(category_display)
		
	if not ui:
		return
	
	if _current_active_ui_inventory_category and ui != _current_active_ui_inventory_category:
		_current_active_ui_inventory_category.set_active(false)
	
	ui.set_active(true)	
	_current_active_ui_inventory_category = ui
	_last_active_category_display = category_display
	_show_category_display_label(ui)
	

func _show_category_display_label(ui_inventory_category : Node = null) -> void:
	if not ui_inventory_category:
		if not _current_active_ui_inventory_category:
			return
			
		ui_inventory_category = _current_active_ui_inventory_category 
		
	_label_category_name.set_text(ui_inventory_category.get_category().display_name)
	
	var button = ui_inventory_category.get_button()
	
	# We have to wait for a frame, otherwise button.get_global_position()
	# would still return the local position instead of global position
	await get_tree().process_frame
	
	var icon_center_global_x = button.get_global_position().x + button.get_rect().size.x / 2		
	var label_half_width = _label_category_name.get_rect().size.x / 2
	var label_position = Vector2(icon_center_global_x - label_half_width, _label_category_name.get_global_position().y)	

	_label_category_name.set_global_position(label_position, true)	
	_label_category_name.set_visible(true)
	
	ui_inventory_category.highlight(true)
	

# Show the active category label
func _on_TimerCategoryName_timeout() -> void:
	_show_category_display_label(_current_active_ui_inventory_category)


func _on_button_category_mouse_entered(ui_inventory_category : Node) -> void:
	_timer_category_name.stop()
	_show_category_display_label(ui_inventory_category)
	
	
func _on_button_category_mouse_exited(ui_inventory_category : Node) -> void:
	# Avoid flashing the icon when the inventory is scrolling and
	# the mouse exits the button before the scroll finishes
	# Since _scrolling_to_page also represents the current page, this
	# works when there's also no scrolling.
	var category_display = _pages_to_category_displays[_scrolling_to_page]
	var ui = _category_displays_to_ui.get(category_display)	
	if ui and ui == ui_inventory_category:
		return
		
	ui_inventory_category.dehighlight()
	
	# Show the active category label again
	_timer_category_name.stop()
	_timer_category_name.start()
	
	
func _on_button_category_pressed(ui_inventory_category : Node, go_to_page : int) -> void:
	_go_to_item_page(go_to_page)
	_play_audio(audio_stream_go_to_page)


func _reload_items() -> void:
	var pages := 0
		
	# Clear all current items
	for child in _item_grids_container.get_children():
		_item_grids_container.remove_child(child)
	
	for category_display in GameState.get_item_category_displays():
		var starting_page := pages
		var category_display_amount_items := 0
		
		if GameState.count_inventory_items_from_category_display(category_display) > 0:	
			# Which category types are linked to this category display?
			var category_types = category_display.types
			
			# Do not instantiate a grid for this display yet,
			# only if any of the categories in this display
			# contain assigned items
			var grid
			
			# Get items from these categories and add them
			# into GridInventoryItems
			for category in category_types:
				for item in GameState.get_inventory_items_from_category(category):
					category_display_amount_items += 1
					
					# A) At least one of the categories in this display contains
					# items. A grid can be created.
					# B) Or we reached the maximum amount of items in the current
					# grid, so create a new one.
					#
					# Why items - 1? Because it means we are already at item position ItemsPerGrid,
					# it means it's time to create a new grid to place this item/a new page
					if not grid or (grid and ((category_display_amount_items - 1) % ItemsPerGrid == 0)):
						pages += 1						
						grid = _grid_template.instantiate()
						
						for child in grid.get_children():
							grid.remove_child(child)
						
						grid.set_name(category_display.display_name)
						_item_grids_container.add_child(grid)
						
					var ui_grid_item = _ui_inventory_grid_item.instantiate()
					ui_grid_item.set_name(item.name + "-" + item.identifier)
					grid.add_child(ui_grid_item)				
					
					var ui_inventory_item = ui_grid_item.get_ui_inventory_item()
					ui_inventory_item.set_item(item)
					
					var button = ui_inventory_item.get_button()
					button.mouse_entered.connect(_on_button_item_mouse_entered.bind(ui_inventory_item))
					button.mouse_exited.connect(_on_button_item_mouse_exited.bind(ui_inventory_item))
					button.pressed.connect(_on_button_item_mouse_pressed.bind(ui_inventory_item))
	
			# Before moving to another CategoryDisplay, assign the
			# starting page for the current CategoryDisplay
			_category_displays_to_pages[category_display] = starting_page + 1
			
			# Assign all pages number to this category display (this is necessary,
			# because a single category display may have multiple pages of items)
			var pages_to_assign = pages - starting_page			
			while pages_to_assign > 0:
				_pages_to_category_displays[pages_to_assign + starting_page] = category_display
				pages_to_assign -= 1
	
	# HACK: This is needed so the container can have
	# its size updated after the children grids were added dynamically
	_item_grids_container.set_visible(false)
	await get_tree().process_frame
	_item_grids_container.set_visible(true)
	
	# Scrolling setup
	_current_scroll_page = 1
	_amount_scroll_pages = _item_grids_container.get_child_count()
	
	if _amount_scroll_pages > 0:
		_page_size = (_item_grids_container.get_size().x / _amount_scroll_pages) + PagePadding
		
	_scroll_container.set_h_scroll(0)
	_scroll_animation = _animation_player.get_animation(ScrollAnimationName)
	
	_reload_categories()
	

func _update_navigation() -> void:			
	if _current_scroll_page == 1:
		_button_left.set_visible(false)
	else:
		_button_left.set_visible(true)
		
	# show possibility of shorter code _button_left.set_visible(_current_scroll_page == 1)
		
	if _current_scroll_page == _amount_scroll_pages or _amount_scroll_pages == 0:
		_button_right.set_visible(false)
	elif _amount_scroll_pages > 1:
		_button_right.set_visible(true)
	
	_set_active_category_display()
	_is_scrolling = false


func _go_to_item_page(go_to_page : int) -> void:
	if _is_scrolling:
		return
		
	go_to_page = int(clamp(go_to_page, 1, _amount_scroll_pages))	
		
	if go_to_page == _current_scroll_page:
		return
		
	var from := 0.0
	var to := 0.0
	var is_forward := go_to_page >_current_scroll_page
		
	# Forward/Right
	if is_forward:		
		if _current_scroll_page > 1:
			from = _page_size * (_current_scroll_page - 1)		
		
		if _current_scroll_page < _amount_scroll_pages:
			to = _page_size * (go_to_page - 1)
	
	# Backward/Left
	else:
		var amount_pages_to_go = _current_scroll_page - go_to_page 		
		to = _page_size * (_current_scroll_page - 1)
		from = _page_size * (_current_scroll_page - amount_pages_to_go - 1)
		
	_scroll_animation.track_set_key_value(0, 0, int(from))
	_scroll_animation.track_set_key_value(0, 1, int(to))
	
	_scrolling_to_page = go_to_page
	_is_scrolling = true
	
	if is_forward:
		_animation_player.play(ScrollAnimationName)
	else:
		_animation_player.play_backwards(ScrollAnimationName)		


func _on_ButtonLeft_pressed() -> void:	
	_go_to_item_page(_current_scroll_page - 1)
	_play_audio(audio_stream_go_to_page)
	

func _on_ButtonRight_pressed() -> void:	
	_go_to_item_page(_current_scroll_page + 1)
	_play_audio(audio_stream_go_to_page)


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:	
	_current_scroll_page = _scrolling_to_page
	_update_navigation() 


func _on_button_item_mouse_entered(ui_inventory_item : Node) -> void:	
	if _is_scrolling: return
	
	# Another item is already selected (probably because of opening the
	# context menu), so deselect it first.
	if _current_ui_inventory_item_selected and _current_ui_inventory_item_selected != ui_inventory_item:
		_current_ui_inventory_item_selected.deselect()
	
	ui_inventory_item.select()
	_current_ui_inventory_item_selected = ui_inventory_item
	
	_play_audio(audio_stream_item_hover)
	_show_item_info(ui_inventory_item.get_item())
	
	
func _on_button_item_mouse_exited(ui_inventory_item : Node) -> void:
	if _is_scrolling: return	
	
	# Context menu is currently open for the same item
	# from this button, so do not deselect the button if the mouse
	# leaves the button
	if _context_menu.get_ui_inventory_item() and _context_menu.get_ui_inventory_item() == ui_inventory_item:
		return
	
	ui_inventory_item.deselect()	
	
	
func _on_button_item_mouse_pressed(ui_inventory_item : Node) -> void:
	if _is_scrolling: return
	ui_inventory_item.highlight()
	
	_play_audio(audio_stream_item_pressed)
	_open_context_menu(ui_inventory_item)


func _setup_context_menu() -> void:
	# Position Context Menu in the center of the inventory
	# (aligned with the middle category icon)
	
	var middle_idx = int(ceil(_grid_categories.get_child_count() / 2))
	var middle_category = _grid_categories.get_children()[middle_idx]
	var x = middle_category.get_global_position().x + (middle_category.get_size().x / 2) - (_context_menu.get_size().x / 2)	
	_context_menu.set_deferred("global_position", Vector2(x, _context_menu.get_global_position().y))
		
	if not _context_menu.get_button_equip().is_connected("pressed", _on_context_menu_button_equip_pressed):
		_context_menu.get_button_equip().pressed.connect(_on_context_menu_button_equip_pressed)
		_context_menu.get_button_cancel().pressed.connect(_on_context_menu_button_cancel_pressed)


func _open_context_menu(ui_inventory_item : Node) -> void:
	_context_menu.set_ui_inventory_item(ui_inventory_item)
	_context_menu_container.set_visible(true)
	

func _on_context_menu_button_equip_pressed() -> void:
	if _context_menu.get_ui_inventory_item():
		var item = _context_menu.get_ui_inventory_item().get_item()
		
		if GameState.player_check_is_item_equipped(item):
			_play_audio_context_menu(audio_stream_item_unequip)
			GameState.player_unequip_item(item)
		else:		
			_play_audio_context_menu(audio_stream_item_equip)
			GameState.player_equip_item(item)
			
	_context_menu_close()


func _on_context_menu_button_cancel_pressed() -> void:
	_play_audio_context_menu(audio_stream_item_context_menu_cancel)
	_context_menu_close()


func _context_menu_close() -> void:
	if _context_menu.get_ui_inventory_item():
		_context_menu.get_ui_inventory_item().dehighlight()
		_context_menu.set_ui_inventory_item(null)
		
	_context_menu_container.set_visible(false)


func _show_item_info(item : EntityItem) -> void:
	_ui_item_info.set_item(item)
	_ui_item_info.set_visible(true)


func _on_item_acquired(item : EntityItem) -> void:
	_reload()
	

func _on_UIInventory_hide() -> void:
	_context_menu_close()


func _on_UIInventory_draw() -> void:		
	_show_category_display_label()


func _play_audio(stream : AudioStream) -> void:
	if not stream: return
	_audio_player.set_stream(stream)
	_audio_player.play(0.0)


func _play_audio_context_menu(stream : AudioStream) -> void:
	if not stream: return
	_audio_player_context_menu.set_stream(stream)
	_audio_player_context_menu.play(0.0)
