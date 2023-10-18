@tool

## General-purpose layout box and base class to other GameGUI layout components. Children are
## stacked in layers.
##
## Nodes that do not extend [GGComponent] can still be children of GameGUI nodes in one of two
## ways.[br][br]
## First, GameGUI adapter code can be added to an extended class. See the [GGTextureRect] source
## code for an example that can be copy-pasted into other extended classes with only small
## modifications required.[br][br]
## Second, any non-[GGComponent] Control node that does not contain GameGUI adapter code will be
## treated as a component with [member horizontal_mode] and [member vertical_mode] both set to
## [b]Expand To Fill[/b]. The size of the node can be further managed by making it a child of
## a [GGComponent] that has other sizing modes.[br][br]
class_name GGComponent
extends Container

#-------------------------------------------------------------------------------
# SIGNALS
#-------------------------------------------------------------------------------

## Signals the beginning of the layout process for a GGComponent subtree.
## This signal is only emitted by the top-level root of a GGComponent subtree.
signal begin_layout

## Signals the end of the layout process for a GGComponent subtree.
## This signal is only emitted by the top-level root of a GGComponent subtree.
signal end_layout

#-------------------------------------------------------------------------------
# ENUMS
#-------------------------------------------------------------------------------

## The possible horizontal and vertical sizing modes for a GameGUI component.
enum ScalingMode
{
	EXPAND_TO_FILL, ## Fill all available space along this dimension.
	ASPECT_FIT,     ## Dynamically adjusts size to maintain aspect ratio [member layout_size].x:[member layout_size].y, just small enough to entirely fit available space.
	ASPECT_FILL,    ## Dynamically adjusts size to maintain aspect ratio [member layout_size].x:[member layout_size].y, just large enough to entirely fill available space.
	PROPORTIONAL,   ## The layout size represents a proportional fraction of 1) the available area or 2) the size of the [member reference_node] if defined.
	SHRINK_TO_FIT,  ## Make the size just large enough to contain all child nodes in their layout.
	FIXED,          ## Fixed pixel size along this dimension.
	PARAMETER       ## One of the subtree [member parameters] is used as the size.
}

## The text sizing mode for [GGLabel], [GGRichTextLabel], and [GGButton].
enum TextSizeMode
{
	DEFAULT,    ## Text size is whatever size you assign in the editor.
	SCALE,      ## Text scales with the size of a reference node.
	PARAMETER   ## Text size is set to the value of one of the defined [member parameters].
}

## The texture fill mode used by [method fill_texture].
enum FillMode
{
	STRETCH,  # Stretch or compress each patch to cover the available space.
	TILE,     # Repeatedly tile each patch at its original pixel size to cover the available space.
	TILE_FIT  # Tile each patche, stretching slightly as necessary to ensure a whole number of tiles fit in the available space.
}


#-------------------------------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------------------------------

@export_group("Component Layout")

## The horizontal scaling mode for this node.
@export var horizontal_mode := GGComponent.ScalingMode.EXPAND_TO_FILL:
	set(value):
		if horizontal_mode == value: return
		horizontal_mode = value
		if value in [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.ASPECT_FILL]:
			if vertical_mode in [GGComponent.ScalingMode.PROPORTIONAL,GGComponent.ScalingMode.FIXED,GGComponent.ScalingMode.PARAMETER]: vertical_mode = value
			if layout_size.x  < 0.0001: layout_size.x = 1
			if layout_size.y  < 0.0001: layout_size.y = 1
		elif vertical_mode in [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.ASPECT_FILL]:
			if not (value in [GGComponent.ScalingMode.EXPAND_TO_FILL,GGComponent.ScalingMode.SHRINK_TO_FIT,GGComponent.ScalingMode.PARAMETER]): vertical_mode = value
		if value == GGComponent.ScalingMode.PROPORTIONAL:
			if layout_size.x < 0.0001 or layout_size.x > 1: layout_size.x = 1
			if layout_size.y < 0.0001 or layout_size.x > 1: layout_size.y = 1
		request_layout()

## The vertical scaling mode for this node.
@export var vertical_mode := GGComponent.ScalingMode.EXPAND_TO_FILL:
	set(value):
		if vertical_mode == value: return
		vertical_mode = value
		if value in [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.ASPECT_FILL]:
			if horizontal_mode in [GGComponent.ScalingMode.PROPORTIONAL,GGComponent.ScalingMode.FIXED,GGComponent.ScalingMode.PARAMETER]: horizontal_mode = value
			if abs(layout_size.x)  < 0.0001: layout_size.x = 1
			if abs(layout_size.y)  < 0.0001: layout_size.y = 1
		elif horizontal_mode in [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.ASPECT_FILL]:
			if not (value in [GGComponent.ScalingMode.EXPAND_TO_FILL,GGComponent.ScalingMode.SHRINK_TO_FIT,GGComponent.ScalingMode.PARAMETER]): horizontal_mode = value
		if value == GGComponent.ScalingMode.PROPORTIONAL:
			if layout_size.x < 0.0001 or layout_size.x > 1: layout_size.x = 1
			if layout_size.y < 0.0001 or layout_size.x > 1: layout_size.y = 1
		request_layout()

## Pixel values for scaling mode [b]Fixed[/b], fractional values for [b]Proportional[/b], and aspect ratio values for [b]Aspect Fit[/b] and [b]Aspect Fill[/b].
@export var layout_size := Vector2(0,0):
	set(value):
		if layout_size == value: return
		# The initial Vector2(0,0) may come in as e.g. 0.00000000000208 for x and y
		if abs(value.x) < 0.00001: value.x = 0
		if abs(value.y) < 0.00001: value.y = 0
		layout_size = value
		request_layout()

## An optional node to use as a size reference for [b]Proportional[/b] scaling
## mode. The reference node must be in a subtree higher in the scene tree than
## this node. Often the size reference is an invisible root-level square-aspect
## component; this allows same-size horizontal and vertical proportional spacers.
@export var reference_node:Control = null :
	set(value):
		if reference_node != value:
			reference_node = value
			request_layout()

## The name of the parameter to use for the [b]Parameter[/b] horizontal scaling mode.
@export var width_parameter := "" :
	set(value):
		if width_parameter == value: return
		width_parameter = value
		if value != "" and has_parameter(value):
			request_layout()

## The name of the parameter to use for the [b]Parameter[/b] vertical_mode scaling mode.
@export var height_parameter := "" :
	set(value):
		if height_parameter == value: return
		height_parameter = value
		if value != "" and has_parameter(value):
			request_layout()

## Parameter definitions for nodes that use scaling mode PARAMETER. Parameters are stored
## the root of a GGComponent subtree. Use [method get_parameter], [method has_parameter], and
## [method set_parameter] to access parameters from any subtree nodes.
@export var parameters := {} :
	set(value):
		if parameters == value: return
		parameters = value
		request_layout()

# A top-level GGComponent is one that has no GGComponent parent.
# It oversees the layout of its descendent nodes.
var _is_top_level := false
var _layout_stage := 0 # top-level component use. 0=layout finished, 1=layout requested, 2=performing layout

#-------------------------------------------------------------------------------
# EXTERNAL API
#-------------------------------------------------------------------------------

## Utility method that draws a texture with any combination of horizontal and vertical fill modes: Stretch, Tile, Tile Fit.
## Used primarily by [GGComponent].
func fill_texture( texture:Texture2D, dest_rect:Rect2, src_rect:Rect2, horizontal_fill_mode:FillMode=FillMode.STRETCH,
		vertical_fill_mode:FillMode=FillMode.STRETCH, modulate:Color=Color(1,1,1,1) ):
	if dest_rect.size.x <= 0 or dest_rect.size.y <= 0: return

	if horizontal_fill_mode == FillMode.TILE and src_rect.size.x > dest_rect.size.x:
		horizontal_fill_mode = FillMode.TILE_FIT

	if vertical_fill_mode == FillMode.TILE and src_rect.size.y > dest_rect.size.y:
		vertical_fill_mode = FillMode.TILE_FIT

	match horizontal_fill_mode:
		FillMode.TILE:
			var tile_size = src_rect.size
			var dest_pos  = dest_rect.position
			var dest_w = dest_rect.size.x
			var dest_h = dest_rect.size.y
			while dest_w > 0:
				if tile_size.x <= dest_w:
					var _dest_rect = Rect2( dest_pos, Vector2(tile_size.x,dest_h) )
					fill_texture( texture, _dest_rect, src_rect, FillMode.STRETCH, vertical_fill_mode, modulate )
				else:
					var _dest_rect = Rect2( dest_pos, Vector2(dest_w,dest_h) )
					var _src_rect = Rect2( src_rect.position, Vector2(dest_w,src_rect.size.y) )
					fill_texture( texture, _dest_rect, _src_rect, FillMode.STRETCH, vertical_fill_mode, modulate )
					return

				dest_pos += Vector2( tile_size.x, 0 )
				dest_w   -= tile_size.x
			return

		FillMode.TILE_FIT:
			var n = int( (dest_rect.size.x / src_rect.size.x) + 0.5 )
			if n == 0:
				fill_texture( texture, dest_rect, src_rect, FillMode.STRETCH, vertical_fill_mode, modulate )
			else:
				var tile_size = Vector2( dest_rect.size.x / n, src_rect.size.y )
				var dest_pos  = dest_rect.position
				var dest_w = dest_rect.size.x
				var dest_h = dest_rect.size.y
				while dest_w > 0:
					if tile_size.x <= dest_w:
						var _dest_rect = Rect2( dest_pos, Vector2(tile_size.x,dest_h) )
						fill_texture( texture, _dest_rect, src_rect, FillMode.STRETCH, vertical_fill_mode, modulate )
					else:
						var _dest_rect = Rect2( dest_pos, Vector2(dest_w,dest_h) )
						fill_texture( texture, _dest_rect, src_rect, FillMode.STRETCH, vertical_fill_mode, modulate )
						return

					dest_pos += Vector2( tile_size.x, 0 )
					dest_w   -= tile_size.x
			return

	match vertical_fill_mode:
		FillMode.TILE:
			var tile_size = src_rect.size
			var dest_pos  = dest_rect.position
			var dest_w = dest_rect.size.x
			var dest_h = dest_rect.size.y
			while dest_h > 0:
				if tile_size.y <= dest_h:
					var _dest_rect = Rect2( dest_pos, Vector2(dest_w, tile_size.y) )
					fill_texture( texture, _dest_rect, src_rect, horizontal_fill_mode, FillMode.STRETCH, modulate )
				else:
					var _dest_rect = Rect2( dest_pos, Vector2(dest_w,dest_h) )
					var _src_rect = Rect2( src_rect.position, Vector2(src_rect.size.x,dest_h) )
					fill_texture( texture, _dest_rect, _src_rect, horizontal_fill_mode, FillMode.STRETCH, modulate )
					return

				dest_pos += Vector2( 0, tile_size.y )
				dest_h   -= tile_size.y
			return

		FillMode.TILE_FIT:
			var n = int( (dest_rect.size.y / src_rect.size.y) + 0.5 )
			if n == 0:
				fill_texture( texture, dest_rect, src_rect, horizontal_fill_mode, FillMode.STRETCH, modulate )
			else:
				var tile_size = Vector2( src_rect.size.x, dest_rect.size.y / n )
				var dest_pos  = dest_rect.position
				var dest_w = dest_rect.size.x
				var dest_h = dest_rect.size.y
				while dest_h > 0:
					if tile_size.y <= dest_h:
						var _dest_rect = Rect2( dest_pos, Vector2(dest_w, tile_size.y) )
						fill_texture( texture, _dest_rect, src_rect, horizontal_fill_mode, FillMode.STRETCH, modulate )
					else:
						var _dest_rect = Rect2( dest_pos, Vector2(dest_w,dest_h) )
						fill_texture( texture, _dest_rect, src_rect, horizontal_fill_mode, FillMode.STRETCH, modulate )
						return

					dest_pos += Vector2( 0, tile_size.y )
					dest_h   -= tile_size.y
			return

	# Horizontal and vertical fill are both STRETCH
	draw_texture_rect_region( texture, dest_rect, src_rect, modulate )

## Returns the specified parameter's value if it exists in the [member parameters]
## of this node or a [GGComponent] ancestor. If it doesn't exist, returns
## [code]0[/code] or a specified default result.
func get_parameter( parameter_name:String, default_result:Variant=0 )->Variant:
	var top = get_top_level_component()
	if top and top.parameters.has(parameter_name):
		return top.parameters[parameter_name]
	else:
		return default_result

## Returns the root of this GGComponent subtree.
func get_top_level_component()->GGComponent:
	var cur = self
	while cur and (not cur is GGComponent or not cur._is_top_level):
		cur = cur.get_parent()
	return cur

## Returns [code]true[/code] if the specified parameter exists in the
## [member parameters] of this node or one of its ancestors.
func has_parameter( parameter_name:String )->bool:
	var top = get_top_level_component()
	if top:
		return top.parameters.has(parameter_name)
	else:
		return false

## Sets the named parameter's value in the top-level root of this subtree.
func set_parameter( parameter_name:String, value:Variant ):
	var top = get_top_level_component()
	if top: top.parameters[parameter_name] = value

## Layout is performed automatically in most cases, but request_layout() can be
## called for edge cases.
func request_layout():
	if _is_top_level:
		if _layout_stage == 0:
			_layout_stage = 1
			queue_sort()
	else:
		var top = get_top_level_component()
		if top: top.request_layout()

#-------------------------------------------------------------------------------
# KEY OVERRIDES
#-------------------------------------------------------------------------------
func _on_resolve_size( available_size:Vector2 ):
	# Overrideable.
	# Called just before this component's size is resolved.
	# Override and adjust this component's size if desired.
	pass

func _on_update_size():
	# Overrideable.
	# Called at the beginning of layout.
	# Override and adjust this GGComponent's size if desired.
	pass

func _perform_child_layout( available_bounds:Rect2 ):
	for i in range(get_child_count()):
		_perform_component_layout( get_child(i), available_bounds )

func _resolve_child_sizes( available_size:Vector2, limited:bool=false ):
	for i in range(get_child_count()):
		_resolve_child_size( get_child(i), available_size, limited )

func _resolve_shrink_to_fit_height( _available_size:Vector2 ):
	# Override in extended classes.
	size.y = _get_largest_child_size().y

func _resolve_shrink_to_fit_width( _available_size:Vector2 ):
	# Override in extended classes.
	size.x = _get_largest_child_size().x

func _with_margins( rect:Rect2 )->Rect2:
	return rect

#-------------------------------------------------------------------------------
# INTERNAL GAMEGUI API
#-------------------------------------------------------------------------------

func _get_largest_child_size()->Vector2:
	# 'x' and 'y' will possibly come from different children.
	var max_w := 0.0
	var max_h := 0.0
	for i in range(get_child_count()):
		var child = get_child(i)
		if not (child is Control) or not child.visible: continue
		if child is Control:  # includes GGComponent
			max_w = max( max_w, child.size.x )
			max_h = max( max_h, child.size.y )
	return Vector2(max_w,max_h)

func _get_sum_of_child_sizes()->Vector2:
	var sum := Vector2(0,0)
	for i in range(get_child_count()):
		var child = get_child(i)
		if not (child is Control) or not child.visible: continue
		sum += child.size
	return sum

func _perform_layout( available_bounds:Rect2 ):
	_place_component( self, available_bounds )
	var bounds = _with_margins( Rect2(Vector2(0,0),size) )
	_perform_child_layout( bounds )

func _place_component( component:Control, available_bounds:Rect2 ):
	component.position = _rect_position_within_parent_bounds( component, component.size, available_bounds )

func _rect_position_within_parent_bounds( component:Control, rect_size:Vector2, available_bounds:Rect2 )->Vector2:
	var pos = available_bounds.position

	if component is Control:  # includes GGComponent
		if component.size_flags_horizontal & (SizeFlags.SIZE_SHRINK_CENTER | SizeFlags.SIZE_FILL):
			pos.x += floor( (available_bounds.size.x - rect_size.x) / 2 )
		elif component.size_flags_horizontal & SizeFlags.SIZE_SHRINK_END:
			pos.x += available_bounds.size.x - rect_size.x

		if component.size_flags_vertical & (SizeFlags.SIZE_SHRINK_CENTER | SizeFlags.SIZE_FILL):
			pos.y += floor( (available_bounds.size.y - rect_size.y) / 2 )
		elif component.size_flags_vertical & SizeFlags.SIZE_SHRINK_END:
			pos.y += available_bounds.size.y - rect_size.y

	return pos

func _resolve_child_size( child:Node, available_size:Vector2, limited:bool=false ):
	if not child.visible or not child is Control: return

	if child is GGComponent:
		child._resolve_size( available_size, limited )
	else:
		_resolve_component_size( child, available_size )
		_resolve_shrink_to_fit_size( child, available_size )

func _resolve_component_size( component:Node, available_size:Vector2 )->Vector2:
	var component_size := available_size

	var is_gg = component is GGComponent

	if is_gg or component.has_method("_on_resolve_size"):
		component._on_resolve_size( available_size )

	var has_mode = is_gg or component.has_method("request_layout")
	var h_mode = component.horizontal_mode if has_mode else ScalingMode.EXPAND_TO_FILL
	var v_mode = component.vertical_mode if has_mode else ScalingMode.EXPAND_TO_FILL

	match h_mode:
		ScalingMode.EXPAND_TO_FILL:
			pass # use available width
		ScalingMode.SHRINK_TO_FIT:
			if not component is GGComponent: component_size.x = component.size.x
		ScalingMode.ASPECT_FIT:
			if v_mode == ScalingMode.ASPECT_FILL:
				component_size.x = floor( (available_size.y / component.layout_size.y) * component.layout_size.x )
			else:
				var fit_x = floor( (available_size.y / component.layout_size.y) * component.layout_size.x )
				if fit_x <= available_size.x: component_size.x = fit_x
		ScalingMode.ASPECT_FILL:
			if v_mode != ScalingMode.ASPECT_FIT:
				var scale_x = (available_size.x / component.layout_size.x)
				var scale_y = (available_size.y / component.layout_size.y)
				component_size.x = floor( max(scale_x,scale_y) * component.layout_size.x )
		ScalingMode.FIXED:
			component_size.x = component.layout_size.x
		ScalingMode.PARAMETER:
			component_size.x = get_parameter( component.width_parameter, component.layout_size.x )
		ScalingMode.PROPORTIONAL:
			if reference_node:
				component_size.x = int(component.layout_size.x * reference_node.size.x)
			else:
				component_size.x = int(component.layout_size.x * available_size.x)

	match v_mode:
		ScalingMode.EXPAND_TO_FILL:
			pass # use available height
		ScalingMode.SHRINK_TO_FIT:
			if not component is GGComponent: component_size.y = component.size.y
		ScalingMode.ASPECT_FIT:
			if h_mode == ScalingMode.ASPECT_FILL:
				component_size.y = floor( (available_size.x / component.layout_size.x) * component.layout_size.y )
			else:
				var fit_y = floor( (available_size.x / component.layout_size.x) * component.layout_size.y )
				if fit_y <= available_size.y: component_size.y = fit_y
		ScalingMode.ASPECT_FILL:
			if h_mode != ScalingMode.ASPECT_FIT:
				var scale_x = (available_size.x / component.layout_size.x)
				var scale_y = (available_size.y / component.layout_size.y)
				component_size.y = floor( max(scale_x,scale_y) * component.layout_size.y )
		ScalingMode.FIXED:
			component_size.y = component.layout_size.y
		ScalingMode.PARAMETER:
			component_size.y = get_parameter( component.height_parameter, component.layout_size.y )
		ScalingMode.PROPORTIONAL:
			if reference_node:
				component_size.y = int(component.layout_size.y * reference_node.size.y)
			else:
				component_size.y = int(component.layout_size.y * available_size.y)

	if not component is GGComponent or not component._is_top_level: component.size = component_size

	return component_size

func _perform_component_layout( component:Node, available_bounds:Rect2 ):
	if component is GGComponent:
		component._perform_layout(available_bounds)

	elif component is Control:
		_place_component( component, available_bounds )

func _resolve_shrink_to_fit_size( component:Node, available_size:Vector2 )->Vector2:
	if not (component is GGComponent or component.has_method("request_layout")): return available_size

	var component_size := available_size

	match component.horizontal_mode:
		ScalingMode.SHRINK_TO_FIT:
			if component is GGComponent:
				_resolve_shrink_to_fit_width( available_size )
			else:
				component_size.x = component.size.x

	match component.vertical_mode:
		ScalingMode.SHRINK_TO_FIT:
			if component is GGComponent:
				_resolve_shrink_to_fit_height( available_size )
			else:
				component_size.y = component.size.y

	return component_size

func _resolve_size( available_size:Vector2, limited:bool=false ):
	# limited
	#   Don't recurse to children unless necessary (Shrink to Fit mode). limited==true indicates
	#   that several sizing options are being checked by GGHBox/GGVBox/etc., so we only need
	#   to figure out the size of this node.
	available_size = _resolve_component_size( self, available_size )
	var inner_size = _with_margins( Rect2(Vector2(0,0), available_size) ).size
	if not limited or ScalingMode.SHRINK_TO_FIT in [horizontal_mode,vertical_mode]:
		_resolve_child_sizes( inner_size, limited )
		_resolve_shrink_to_fit_size( self, available_size )

func _update_layout():
	if not _is_top_level or _layout_stage == 2: return
	_layout_stage = 2

	_update_safe_area()

	begin_layout.emit()

	_update_size()
	_resolve_size( size )
	_perform_layout( _with_margins(Rect2(Vector2(0,0),size)) )

	end_layout.emit()
	_layout_stage = 0

func _update_size():
	_on_update_size()

	for i in range(get_child_count()):
		var child = get_child(i)
		if child is GGComponent:
			child._update_size()
		elif child.has_method("_on_update_size"):
			child._on_update_size()

#-------------------------------------------------------------------------------
# INTERNAL NODE API
#-------------------------------------------------------------------------------
func _disconnect( sig:Signal, callback:Callable ):
	if sig.is_connected(callback):
		sig.disconnect( callback )

func _enter_tree():
	_is_top_level = not (get_parent() is GGComponent)
	if _is_top_level:
		resized.connect( request_layout )
		sort_children.connect( _on_sort_children )
		_update_safe_area()

	child_entered_tree.connect( _on_child_entered_tree )
	child_exiting_tree.connect( _on_child_exiting_tree )
	child_order_changed.connect( request_layout )

	request_layout()

func _exit_tree():
	if _is_top_level:
		_disconnect( resized, request_layout )
		_disconnect( sort_children, _on_sort_children )

	_disconnect( child_entered_tree, _on_child_entered_tree )
	_disconnect( child_exiting_tree, _on_child_exiting_tree )
	_disconnect( child_order_changed, request_layout )

	request_layout()

func _on_child_entered_tree( child:Node ):
	if child is Control: child.visibility_changed.connect( request_layout )
	if Engine.is_editor_hint() and child is Control:
		child.minimum_size_changed.connect( request_layout )
		child.resized.connect( request_layout )
		child.size_flags_changed.connect( request_layout )

	request_layout()

func _on_child_exiting_tree( child:Node ):
	if child is Control: _disconnect( child.visibility_changed, request_layout )
	if Engine.is_editor_hint() and child is Control:
		_disconnect( child.minimum_size_changed, request_layout )
		_disconnect( child.resized, request_layout )
		_disconnect( child.size_flags_changed, request_layout )

	request_layout()

func _on_child_visibility_changed():
	request_layout()

func _on_sort_children():
	_update_layout()

func _update_safe_area():
	var viewport = get_viewport()
	if viewport:
		var display_size = viewport.get_visible_rect().size
		var safe_area = Rect2( Vector2(0,0), display_size )

		match DisplayServer.window_get_mode():
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN, \
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				safe_area = DisplayServer.get_display_safe_area()

		set_parameter( "safe_area_left_margin", safe_area.position.x )
		set_parameter( "safe_area_top_margin", safe_area.position.y )
		set_parameter( "safe_area_right_margin", display_size.x - safe_area.end.x )
		set_parameter( "safe_area_bottom_margin", display_size.y - safe_area.end.y )

