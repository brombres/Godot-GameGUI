@tool

## A GameGUI layout that arranges its child elements in a vertical column.
class_name GGVBox
extends GGComponent

enum VerticalContentAlignment
{
	TOP,     ## Top-align the content.
	CENTER,  ## Center the content.
	BOTTOM   ## Bottom-align the content.
}

## Specify the vertical alignment of the content as a whole.
@export var content_alignment := VerticalContentAlignment.CENTER :
	set(value):
		content_alignment = value
		request_layout()

var _min_heights:Array[int] = []
var _max_heights:Array[int] = []

func _resolve_child_sizes( available_size:Vector2, limited:bool=false ):
	# Resolve for and collect min and max sizes
	_max_heights.clear()
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is Control and child.visible:
			_resolve_child_size( child, available_size, true )
			_max_heights.push_back( int(child.size.y) )
		else:
			_max_heights.push_back( 0 )

	_min_heights.clear()
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is Control and child.visible:
			_resolve_child_size( child, Vector2(available_size.x,0), true )
			_min_heights.push_back( int(child.size.y) )
		else:
			_min_heights.push_back( 0 )

	var expand_count := 0
	var total_stretch_ratio := 0.0
	var fixed_height := 0
	var min_height := 0

	# Leaving other children at their minimum height, set aspect-fit, proportional,
	# and shrink-to-fit height nodes to their maximum size.
	var modes = [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.PROPORTIONAL,GGComponent.ScalingMode.SHRINK_TO_FIT]
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue

		var has_mode = child is GGComponent or child.has_method("request_layout")
		if has_mode and child.vertical_mode in modes:
			_resolve_child_size( child, available_size, limited )
			var h = int(child.size.y)
			min_height += h
			fixed_height += h
			_min_heights[i] = h
			_max_heights[i] = h

		else:
			var h = _min_heights[i]
			min_height += h

			if _min_heights[i] == _max_heights[i]:
				fixed_height += h
				_resolve_child_size( child, child.size, limited )  # final resolve
			else:
				expand_count += 1
				total_stretch_ratio += child.size_flags_stretch_ratio

	if expand_count == 0 or total_stretch_ratio == 0.0 or min_height >= available_size.y: return

	var excess_height = int(available_size.y - fixed_height)
	var remaining_height = excess_height

	# Find children with a min height larger than their portion. Let them keep their min height and adjust remaining.
	var remaining_total_stretch_ratio = total_stretch_ratio
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_heights[i] == _max_heights[i]: continue

		var h := 0
		if expand_count == 1: h = remaining_height
		else:                 h = int( excess_height * child.size_flags_stretch_ratio / total_stretch_ratio )

		if h < _min_heights[i]:
			h = _min_heights[i]
			remaining_height -= h
			expand_count -= 1
			remaining_total_stretch_ratio -= child.size_flags_stretch_ratio
			_min_heights[i] = _max_heights[i]  # skip this node in the next pass
			_resolve_child_size( child, child.size, limited )  # final resolve

	excess_height = remaining_height
	total_stretch_ratio = remaining_total_stretch_ratio
	if expand_count == 0 or abs(total_stretch_ratio) < 0.0001: return

	# Distribute remaining height next to children with a max height smaller than their portion.
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_heights[i] == _max_heights[i]: continue

		var h := 0
		if expand_count == 1: h = remaining_height
		else:                 h = int( excess_height * child.size_flags_stretch_ratio / total_stretch_ratio )

		if h > _max_heights[i]:
			h = _max_heights[i]
			_resolve_child_size( child, Vector2(available_size.x,h), limited )
			remaining_height -= h
			expand_count -= 1
			remaining_total_stretch_ratio -= child.size_flags_stretch_ratio
			_min_heights[i] = _max_heights[i]  # skip this node in the next pass

	excess_height = remaining_height
	total_stretch_ratio = remaining_total_stretch_ratio
	if expand_count == 0 or abs(total_stretch_ratio) < 0.0001: return

	# If this GGVBox is shrink-to-fit height then we're done; don't add remaining space to
	# the children.
	if vertical_mode == GGComponent.ScalingMode.SHRINK_TO_FIT:
		return

	# Distribute remaining height
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_heights[i] == _max_heights[i]: continue

		var h := 0
		if expand_count == 1: h = remaining_height
		else:                 h = int( excess_height * child.size_flags_stretch_ratio / total_stretch_ratio )

		_resolve_child_size( child, Vector2(available_size.x,h), limited )
		remaining_height -= h
		expand_count -= 1

func _resolve_shrink_to_fit_height( _available_size:Vector2 ):
	size.y = _get_sum_of_child_sizes().y

func _resolve_shrink_to_fit_width( _available_size:Vector2 ):
	size.x = _get_largest_child_size().x

func _perform_layout( available_bounds:Rect2 ):
	_place_component( self, available_bounds )

	var inner_bounds = _with_margins( Rect2(Vector2(0,0),size) )
	var pos = inner_bounds.position
	var sz = inner_bounds.size

	var diff = sz.y - _get_sum_of_child_sizes().y
	match content_alignment:
		VerticalContentAlignment.TOP:    pass
		VerticalContentAlignment.CENTER: pos.y += int(diff/2.0)
		VerticalContentAlignment.BOTTOM: pos.y += diff

	for i in range(get_child_count()):
		var child = get_child(i)
		if not (child is Control) or not child.visible: continue
		if child is Control:
			_perform_component_layout( child, Rect2(pos,Vector2(sz.x,child.size.y)) )
			pos += Vector2( 0, child.size.y )

