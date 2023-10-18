@tool

## Extends TextureRect and adapts it to work painlessly with the GameGUI layout system.
class_name GGTextureRect
extends TextureRect

#-------------------------------------------------------------------------------
# GAMEGUI PROPERTIES
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

## Automatically set to indicate that GameGUI-related properties have been set
## for this node. Uncheck to automatically reconfigure those properties.
@export var is_configured := false

# GameGUI framework use
var is_width_resolved  := false  ## Internal GameGUI use.
var is_height_resolved := false  ## Internal GameGUI use.

#-------------------------------------------------------------------------------
# CONFIGURATION METHODS
#-------------------------------------------------------------------------------
func _ready():
	_configure()

func _process(_delta):
	_configure()

func _configure():
	if not is_configured and texture:
		is_configured = true
		horizontal_mode  = GGComponent.ScalingMode.ASPECT_FIT
		vertical_mode = GGComponent.ScalingMode.ASPECT_FIT
		layout_size   = texture.get_size()  # TextureRect-specific

		# Let the GG framework and wrapper handle the sizing (TextureRect-specific)
		expand_mode   = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE

#-------------------------------------------------------------------------------
# GAMEGUI API METHODS
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
	pass

# Called at the beginning of GGLayout. Adjust 'horizontal_mode',
# 'vertical_mode', and/or 'layout_size'. Other nodes may not have their sizes set yet,
# so defer relative size computations to _on_resolve_size(available_size:Vector2).
func _on_update_size():
	pass

## Layout is performed automatically in most cases, but request_layout() can be
## called for edge cases.
func request_layout():
	var top = get_top_level_component()
	if top: top.request_layout()

