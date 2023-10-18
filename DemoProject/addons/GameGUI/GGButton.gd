@tool

class_name GGButton
extends Button

#-------------------------------------------------------------------------------
# GAMEGUI PROPERTIES
#-------------------------------------------------------------------------------

@export_group("Text Size")

## Check to lock in the current font size and reference node height as reference
## values that will be used to scale the font size.
@export var text_size_mode:GGComponent.TextSizeMode:
	set(value):
		if text_size_mode == value: return

		text_size_mode = value
		if not get_parent(): return  # resource loading is setting properties

		match value:
			GGComponent.TextSizeMode.DEFAULT:
				reference_node_height = 0
				reference_font_size = 0
			GGComponent.TextSizeMode.SCALE:
				if reference_node: reference_node_height = floor(reference_node.size.y)
				reference_font_size = get_theme_font_size( "font_size" )
			GGComponent.TextSizeMode.PARAMETER:
				reference_node_height = 0
				reference_font_size = 0
				if has_parameter( text_size_parameter ):
					add_theme_font_size_override( "font_size", int(get_parameter(text_size_parameter)) )

		request_layout()

## A node that will be used as a height reference for scaling this node's text.
@export var reference_node:Control :
	set(value):
		if reference_node == value: return

		reference_node = value
		if reference_node and reference_node_height == 0:
			reference_node_height = int(value.size.y)
			request_layout()

## The height of the [Button] node that the [member reference_font_size] was designed for.
## This is used to scale the font based on the current height of the reference node.
@export var reference_node_height := 0 :
	set(value):
		if reference_node_height == value: return
		reference_node_height = value
		request_layout()

## The original size of the font.
@export var reference_font_size := 0 :
	set(value):
		if reference_font_size == value: return
		reference_font_size = value
		request_layout()

## The name of the parameter to use when [member text_size_mode] is [b]Parameter[/b].
@export var text_size_parameter:String = "" :
	set(value):
		if text_size_parameter == value: return
		text_size_parameter = value
		if has_parameter( text_size_parameter ):
			add_theme_font_size_override( "font_size", int(get_parameter(text_size_parameter)) )

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

## Automatically set to indicate that default properties have been set
## for this node. Uncheck to reset those defaults.
@export var is_configured := false

# Internal editor use to detect font size changes and request an updated layout.
var _current_node_height := 0
var _current_font_size := 0

# GameGUI framework use
var is_width_resolved  := false  ## Internal GameGUI use.
var is_height_resolved := false  ## Internal GameGUI use.

#-------------------------------------------------------------------------------
# GGLABEL METHODS
#-------------------------------------------------------------------------------
func _ready():
	_configure()

func _process(_delta):
	_configure()
	_check_for_modified_font_size()

func _check_for_modified_font_size():
	if not Engine.is_editor_hint(): return

	match text_size_mode:
		GGComponent.TextSizeMode.DEFAULT:
			var cur_size = get_theme_font_size( "font_size" )
			if cur_size != _current_font_size:
				_current_font_size = cur_size
				request_layout()

		GGComponent.TextSizeMode.SCALE:
			if _current_font_size != reference_font_size:
				_current_font_size = reference_font_size
				request_layout()
			if reference_node:
				var h = int(reference_node.size.y)
				if _current_node_height != h:
					_current_node_height = h
					request_layout()

		GGComponent.TextSizeMode.PARAMETER:
			pass

func _configure():
	if not is_configured and size.y > 0:
		is_configured = true
		if text == "": text = "Button"

#-------------------------------------------------------------------------------
# GAMEGUI API
#-------------------------------------------------------------------------------

## Returns the specified parameter's value if it exists in a [GGComponent]
## parent or ancestor. If it doesn't exist, returns [code]0[/code] or a
## specified default result.
func get_parameter( parameter_name:String, default_result:Variant=0 )->Variant:
	var top = get_top_level_component()
	if top and top.parameters.has(parameter_name):
		return top.parameters[parameter_name]
	else:
		return default_result

## Returns the root of this [GGComponent] subtree.
func get_top_level_component()->GGComponent:
	var cur = self
	while cur and (not cur is GGComponent or not cur._is_top_level):
		cur = cur.get_parent()
	return cur

## Returns [code]true[/code] if the specified parameter exists in a
## [GGComponent] parent or ancestor.
func has_parameter( parameter_name:String )->bool:
	var top = get_top_level_component()
	if top:
		return top.parameters.has(parameter_name)
	else:
		return false

## Sets the named parameter's value in the top-level [GGComponent] root of this subtree.
func set_parameter( parameter_name:String, value:Variant ):
	var top = get_top_level_component()
	if top: top.parameters[parameter_name] = value

# Called when this component is about to compute its size. Any size computations
# relative to reference nodes higher in the tree should be performed here.
func _on_resolve_size( available_size:Vector2 ):
	if Engine.is_editor_hint():
		match text_size_mode:
			GGComponent.TextSizeMode.DEFAULT:
				# Save current font size theme override size to check for editor changes
				_current_font_size = get_theme_font_size( "font_size" )

			GGComponent.TextSizeMode.SCALE:
				# Save current font reference size to check for editor changes
				_current_font_size = reference_font_size
				if reference_node: _current_node_height = int( reference_node.size.y )

	match text_size_mode:
		GGComponent.TextSizeMode.SCALE:
			if reference_node and reference_node_height:
				var cur_scale = floor(reference_node.size.y) / reference_node_height

				# Override the size of the font to dynamically size it
				var cur_size = reference_font_size * cur_scale
				if cur_size:
					add_theme_font_size_override( "font_size", cur_size )

		GGComponent.TextSizeMode.PARAMETER:
			if has_parameter( text_size_parameter ):
				add_theme_font_size_override( "font_size", int(get_parameter(text_size_parameter)) )

## Layout is performed automatically in most cases, but request_layout() can be
## called for edge cases.
func request_layout():
	var top = get_top_level_component()
	if top: top.request_layout()
