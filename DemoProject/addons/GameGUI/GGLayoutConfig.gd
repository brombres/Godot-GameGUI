@tool

## Extend this node and override [method _on_begin_layout] to set GameGUI parameters
## prior to each layout via [method set_parameter]. Ensure the extended node
## begins with the [code]@tool[/code] annotation.
class_name GGLayoutConfig
extends Node2D

func _enter_tree():
	var top = get_top_level_component()
	if top:
		top.begin_layout.connect( _dispatch_on_begin_layout )

func _exit_tree():
	var top = get_top_level_component()
	if top:
		top._disconnect( top.begin_layout, _dispatch_on_begin_layout )

func _dispatch_on_begin_layout():
	var viewport = get_viewport()
	if not viewport: return

	var display_size = viewport.get_visible_rect().size
	var top = get_top_level_component()
	if Engine.is_editor_hint() and top: display_size = top.size

	_on_begin_layout( display_size )

## Layout for the [GGComponent] subtree this node is attached to is about to begin.
## Override this method and set parameters or other configuration needs.
func _on_begin_layout( display_size:Vector2 ):
	pass

## Returns the specified parameter's value if it exists in the [member parameters]
## of the [GGComponent] subtree this node is attached to. If it doesn't exist, returns
## [code]0[/code] or a specified default result.
func get_parameter( parameter_name:String, default_result:Variant )->Variant:
	var cur = get_parent()
	while cur and not cur is GGComponent:
		cur = cur.get_parent()
	if cur: return cur.get_parameter( parameter_name, default_result )
	else:   return default_result

## Returns the root of the [GGComponent] subtree this node is attached to.
func get_top_level_component()->GGComponent:
	var cur = get_parent()
	while cur and not cur is GGComponent:
		cur = cur.get_parent()
	if cur: return cur.get_top_level_component()
	else:   return null

## Returns [code]true[/code] if the specified parameter exists in the
## [member parameters] of the [GGComponent] subtree this node is attached to.
func has_parameter( parameter_name:String )->bool:
	var cur = get_parent()
	while cur and not cur is GGComponent:
		cur = cur.get_parent()
	if cur: return cur.has_parameter( parameter_name )
	else:   return false

## Sets the named parameter's value in the top-level root of the [GGComponent]
## subtree this node is attached to.
func set_parameter( parameter_name:String, value:Variant ):
	var cur = get_parent()
	while cur and not cur is GGComponent:
		cur = cur.get_parent()
	if cur: cur.set_parameter( parameter_name, value )
