@tool

## Positions its children at arbitrary coordinates within its own bounds, similiar to a sprite.
## Not intended for use with an actual Sprite2D; use GGTextureRect or other Control types as
## children. Typically used with a single child node.
class_name GGOverlay
extends GGComponent

enum PositioningMode
{
	PROPORTIONAL,  ## Specify child position as a fraction between 0.0 and 1.0.
	FIXED,         ## Child position is a fixed pixel offset.
	PARAMETER      ## Use a parameter as the child's relative pixel offset.
}

enum ScaleFactor
{
	CONSTANT,      ## Scale using a fixed scale factor.
	PARAMETER      ## Scale using a subtree parameter.
}

@export_group("Child Position and Scale")

## The child positioning mode.
@export var positioning_mode := PositioningMode.PROPORTIONAL :
	set(value):
		if positioning_mode == value: return
		match value:
			PositioningMode.PROPORTIONAL:
				if positioning_mode == PositioningMode.FIXED:
					child_x /= size.x
					child_y /= size.y
				else:
					child_x = 0.5
					child_y = 0.5
			PositioningMode.FIXED:
				if positioning_mode == PositioningMode.PROPORTIONAL:
					child_x = int( child_x * size.x )
					child_y = int( child_y * size.y )
				else:
					child_x = int(size.x / 2.0)
					child_y = int(size.y / 2.0)
		positioning_mode = value
		request_layout()

## The child 'x' offset within this component. Use 0.0-1.0 for positioning mode [b]Proportional[/b] and integer values for [b]Fixed[/b].
@export_range(0.0,1.0,0.0001,"or_less","or_greater") var child_x:float = 0.5 :
	set(value):
		if child_x == value: return
		child_x = value
		request_layout()

## The child 'y' offset within this component. Use 0.0-1.0 for positioning mode [b]Proportional[/b] and integer values for [b]Fixed[/b].
@export_range(0.0,1.0,0.0001,"or_less","or_greater") var child_y:float = 0.5 :
	set(value):
		if child_y == value: return
		child_y = value
		request_layout()

## The parameter name to use for the child 'x' offset.
@export var child_x_parameter := "" :
	set(value):
		if child_x_parameter == value: return
		child_x_parameter = value
		request_layout()

## The parameter name to use for the child 'y' offset.
@export var child_y_parameter := "" :
	set(value):
		if child_y_parameter == value: return
		child_y_parameter = value
		request_layout()

## The horizontal scale mode.
@export var h_scale_factor := ScaleFactor.CONSTANT :
	set(value):
		if h_scale_factor == value: return
		h_scale_factor = value
		request_layout()

## The vertical scale mode.
@export var v_scale_factor := ScaleFactor.CONSTANT :
	set(value):
		if v_scale_factor == value: return
		v_scale_factor = value
		request_layout()

## The horizontal scale factor to use when [member h_scale_factor] is [b]Constant[/b].
@export_range(0.0,1.0,0.0001,"or_greater") var h_scale_constant:float = 1.0 :
	set(value):
		if h_scale_constant == value: return
		h_scale_constant = value
		request_layout()

## The vertical scale factor to use when [member v_scale_factor] is [b]Constant[/b].
@export_range(0.0,1.0,0.0001,"or_greater") var v_scale_constant:float = 1.0 :
	set(value):
		if v_scale_constant == value: return
		v_scale_constant = value
		request_layout()

## The horizontal scale factor to use when [member h_scale_factor] is [b]Parameter[/b].
@export var h_scale_parameter:String = "" :
	set(value):
		if h_scale_parameter == value: return
		h_scale_parameter = value
		request_layout()

## The vertical scale factor to use when [member v_scale_factor] is [b]Parameter[/b].
@export var v_scale_parameter:String = "" :
	set(value):
		if v_scale_parameter == value: return
		v_scale_parameter = value
		request_layout()

func _get_scale()->Vector2:
	var sx := 0.0
	var sy := 0.0

	match h_scale_factor:
		ScaleFactor.CONSTANT:
			sx = h_scale_constant
		ScaleFactor.PARAMETER:
			sx = get_parameter( h_scale_parameter )

	match v_scale_factor:
		ScaleFactor.CONSTANT:
			sy = v_scale_constant
		ScaleFactor.PARAMETER:
			sy = get_parameter( v_scale_parameter )

	return Vector2(sx,sy)

func _perform_child_layout( available_bounds:Rect2 ):
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child is Control or not child.visible: continue

		var x_pos := 0
		var y_pos := 0
		match positioning_mode:
			PositioningMode.PROPORTIONAL:
				x_pos = available_bounds.size.x * child_x
				y_pos = available_bounds.size.y * child_y
			PositioningMode.FIXED:
				x_pos = child_x
				y_pos = child_y
			PositioningMode.PARAMETER:
				x_pos = get_parameter( child_x_parameter, child_x )
				y_pos = get_parameter( child_y_parameter, child_y )

		# Adjust x_pos and y_pos for SIZE_SHRINK_X.
		if child.size_flags_horizontal & (SizeFlags.SIZE_SHRINK_CENTER | SizeFlags.SIZE_FILL):
			x_pos -= int(child.size.x / 2.0)
		elif child.size_flags_horizontal & SizeFlags.SIZE_SHRINK_END:
			x_pos -= int(child.size.x)

		if child.size_flags_vertical & (SizeFlags.SIZE_SHRINK_CENTER | SizeFlags.SIZE_FILL):
			y_pos -= int(child.size.y / 2.0)
		elif child.size_flags_vertical & SizeFlags.SIZE_SHRINK_END:
			y_pos -= int(child.size.y)

		_perform_component_layout( child, Rect2(Vector2(x_pos,y_pos),child.size) )

func _resolve_child_sizes( available_size:Vector2, limited:bool=false ):
	var scale = _get_scale()

	for i in range(get_child_count()):
		var child = get_child(i)
		if not child is Control or not child.visible: continue

		# Resolve once at full size to get the child's full size
		_resolve_child_size( child, available_size, limited )

		# Apply the scale factor to the child
		_resolve_child_size( child, floor( child.size * scale ), limited )

