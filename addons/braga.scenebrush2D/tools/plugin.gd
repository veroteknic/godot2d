###################################################################
# This Tool is HEAVILY based on Zylann's awesome Scatter 3D Plugin
# https://github.com/Zylann/godot_scatter_plugin
#
# So, I don't want to get much credits for this :)
###################################################################

tool
extends EditorPlugin

const SceneBrush2D = preload("res://addons/braga.scenebrush2D/SceneBrush2D.gd")
const PaletteControl = preload("res://addons/braga.scenebrush2D/tools/palette.tscn")
const Util = preload("res://addons/braga.scenebrush2D/tools/util.gd")

const ACTION_PAINT = 0
const ACTION_ERASE = 1

var _debug = false
var one_instance_per_press = true

var _node = null
var _pattern = null
var _mouse_pressed = false
#var _mouse_pressed_old = false
var _mouse_button = BUTTON_LEFT
var _pending_paint_completed = false
var _mouse_position = Vector2()
var _editor_camera = null
var _collision_mask = 1
var _placed_instances = []
var _removed_instances = []
var _disable_undo = false
var _pattern_margin = 0.0

var _palette = null
var _error_dialog = null


static func get_icon(name):
	return load("res://addons/braga.scenebrush2D/tools/icons/icon_" + name + ".svg")


func _enter_tree():
	_debugprint("SceneBrush plugin Enter tree")
	# The class is globally named but still need to register it just so the node creation dialog gets it
	# https://github.com/godotengine/godot/issues/30048
	add_custom_type("SceneBrush2D", "Node2D", SceneBrush2D, get_icon("SceneBrush2D"))
	
	var base_control = get_editor_interface().get_base_control()
	
	_palette = PaletteControl.instance()
	_palette.connect("pattern_selected", self, "_on_Palette_pattern_selected")
	_palette.connect("pattern_added", self, "_on_Palette_pattern_added")
	_palette.connect("pattern_removed", self, "_on_Palette_pattern_removed")
	_palette.hide()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT, _palette)
	_palette.set_preview_provider(get_editor_interface().get_resource_previewer())
	_palette.call_deferred("setup_dialogs", base_control)

	_error_dialog = AcceptDialog.new()
	_error_dialog.rect_min_size = Vector2(300, 200)
	_error_dialog.hide()
	_error_dialog.window_title = "Error"
	base_control.add_child(_error_dialog)
	

func _exit_tree():
	_debugprint("SceneBrush plugin Exit tree")
	edit(null)
	
	remove_custom_type("SceneBrush2D")
	
	_palette.queue_free()
	_palette = null
	
	_error_dialog.queue_free()
	_error_dialog = null


func handles(obj):
	return obj != null and obj is SceneBrush2D


func edit(obj):
	_node = obj
	_debugprint(_node)
	if _node:
		var patterns = _node.get_patterns()
		_debugprint(patterns)
		if len(patterns) > 0:
			set_pattern(patterns[0])
		else:
			set_pattern(null)
		_palette.load_patterns(patterns)
		set_physics_process(true)
	else:
		set_physics_process(false)


func make_visible(visible):
	_palette.set_visible(visible)
	# TODO Workaround https://github.com/godotengine/godot/issues/6459
	# When the user selects another node, I want the plugin to release its references.
	if not visible:
		edit(null)


func forward_canvas_gui_input(p_event):
	if _node == null:
		return false

	var captured_event = false
	
	if p_event is InputEventMouseButton:
		var mb = p_event
		
		if mb.button_index == BUTTON_LEFT or mb.button_index == BUTTON_RIGHT:
			if mb.pressed == false:
				_mouse_pressed = false

			# Need to check modifiers before capturing the event,
			# because they are used in navigation schemes
			if (not mb.control) and (not mb.alt):# and mb.button_index == BUTTON_LEFT:
				if mb.pressed:# and not _mouse_pressed_old:
					_mouse_pressed = true
					_mouse_button = mb.button_index
				
				captured_event = true

	elif p_event is InputEventMouseMotion:
		var mm = p_event
		_mouse_position = get_editor_interface().get_edited_scene_root().get_global_mouse_position()

	return captured_event


func _physics_process(delta):
	_pending_paint_completed = false
	
	if _node == null:
		return
	if _pattern == null:
		return
	
	var action = null
	match _mouse_button:
		BUTTON_LEFT:
			_debugprint("paint")
			action = ACTION_PAINT
		BUTTON_RIGHT:
			action = ACTION_ERASE
	
	if _mouse_pressed:
		if one_instance_per_press:
			_mouse_pressed = false
			
		if action == ACTION_PAINT:
			_debugprint("paint")
			var instance = _pattern.instance()
#			instance.position = _mouse_position
			instance.position = _mouse_position.round()
#			instance.rotate_y(rand_range(-PI, PI))
			_node.add_child(instance)
			instance.owner = get_editor_interface().get_edited_scene_root()
			_placed_instances.append(instance)
			_pending_paint_completed = true
			
		elif action == ACTION_ERASE:
			var _closest_child = null
			var _max_distance = _node.erase_max_distance
			var _closest_child_distance = _max_distance + 1.0
			
			for child in _node.get_children():
				var child_distance_to_mouse = child.position.distance_to(_mouse_position)
				if child_distance_to_mouse < _max_distance and \
						child_distance_to_mouse < _closest_child_distance:
					_closest_child = child
					_closest_child_distance = child_distance_to_mouse
					
			if _closest_child != null:
				_debugprint("erasing" + str(_closest_child))
				_node.remove_child(_closest_child)
				_removed_instances.append(_closest_child)
				_pending_paint_completed = true


	if _pending_paint_completed:
		if action == ACTION_PAINT:
			# TODO This will creep memory until the scene is closed...
			# Because in Godot, undo/redo of node creation/deletion is done by NOT deleting them.
			# To stay in line with this, I have to do the same...
			var ur = get_undo_redo()
			ur.create_action("Paint scenes")
			for instance in _placed_instances:
				# This is what allows nodes to be freed
				ur.add_do_reference(instance)
			_disable_undo = true
			ur.add_do_method(self, "_redo_paint", _node.get_path(), _placed_instances.duplicate(false))
			ur.add_undo_method(self, "_undo_paint", _node.get_path(), _placed_instances.duplicate(false))
			ur.commit_action()
			_disable_undo = false
			_placed_instances.clear()
			
		elif action == ACTION_ERASE:
			var ur = get_undo_redo()
			ur.create_action("Erase painted scenes")
			for instance in _removed_instances:
				ur.add_undo_reference(instance)
			_disable_undo = true
			ur.add_do_method(self, "_redo_erase", _node.get_path(), _removed_instances.duplicate(false))
			ur.add_undo_method(self, "_undo_erase", _node.get_path(), _removed_instances.duplicate(false))
			ur.commit_action()
			_disable_undo = false
			_removed_instances.clear()
		
		_pending_paint_completed = false


func _redo_paint(parent_path, instances_data):
	if _disable_undo:
		return
	var parent = get_node(parent_path)
	for instance in instances_data:
		parent.add_child(instance)


func _undo_paint(parent_path, instances_data):
	if _disable_undo:
		return
	var parent = get_node(parent_path)
	for instance in instances_data:
		parent.remove_child(instance)


func _redo_erase(parent_path, instances_data):
	if _disable_undo:
		return
	var parent = get_node(parent_path)
	for instance in instances_data:
		instance.get_parent().remove_child(instance)


func _undo_erase(parent_path, instances_data):
	if _disable_undo:
		return
	var parent = get_node(parent_path)
	for instance in instances_data:
		parent.add_child(instance)


# Goes up the tree from the given node and finds the first SceneBrush layer,
# then return the immediate child of it from which the node is child of
static func get_brush_child_instance(node, brush_root):
	var parent = node
	while parent != null:
		parent = node.get_parent()
		if parent != null and parent == brush_root:
			return node
		node = parent
	return null


func set_pattern(pattern):
	if _pattern != pattern:
		_pattern = pattern
		var temp = pattern.instance()
		# TODO This causes errors because of accessing `global_transform` outside the tree... Oo
		# See https://github.com/godotengine/godot/issues/30445
		var aabb = Util.get_scene_aabb(temp)
		_pattern_margin = aabb.size.length() * 0.4
		temp.free()
		_debugprint("Pattern margin is " + str(_pattern_margin))


func _on_Palette_pattern_selected(pattern_index):
	var patterns = _node.get_patterns()
	set_pattern(patterns[pattern_index])


func _on_Palette_pattern_added(path):
	if not verify_scene(path):
		return
	# TODO Duh, may not work if the file was moved or renamed... I'm tired of this
	var ur = get_undo_redo()
	ur.create_action("Add brush pattern")
	ur.add_do_method(self, "add_pattern", path)
	ur.add_undo_method(self, "remove_pattern", path)
	ur.commit_action()


func _on_Palette_pattern_removed(path):
	var ur = get_undo_redo()
	ur.create_action("Remove brush pattern")
	ur.add_do_method(self, "remove_pattern", path)
	ur.add_undo_method(self, "add_pattern", path)
	ur.commit_action()


func add_pattern(path):
	_debugprint("Adding pattern " + path)
	_node.add_pattern(path)
	_palette.add_pattern(path)


func remove_pattern(path):
	_debugprint("Removing pattern " + path)
	_node.remove_pattern(path)
	_palette.remove_pattern(path)


func verify_scene(fpath):
	# Check it can be loaded
	var scene = load(fpath)
	if scene == null:
		_show_error(tr("Could not load the scene. See the console for more info."))
		return false
	
	# Check it's not already in the list
	if _node.has_pattern(fpath):
		_palette.select_pattern(fpath)
		_show_error(tr("The selected scene is already in the palette"))
		return false
	
	# Check it's not the current scene itself
	if Util.is_self_or_parent_scene(fpath, _node):
		_show_error("The selected scene can't be added recursively")
		return false
	
	# Check it inherits Node2D
	# Aaaah screw this
	var scene_instance = scene.instance()
	if not (scene_instance is Node2D):
		_show_error(tr("The selected scene is not a Spatial, it can't be painted in a 3D scene."))
		scene_instance.free()
		return false
	scene_instance.free()
	
	return true


func _show_error(msg):
	_error_dialog.dialog_text = msg
	_error_dialog.popup_centered_minsize()


func _debugprint(_msg):
	if _debug:
		print(_msg)

