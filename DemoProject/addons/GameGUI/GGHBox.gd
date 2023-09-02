@tool

## A GameGUI layout that arranges its child elements in a horizontal row.
class_name GGHBox
extends GGComponent

var _min_widths:Array[int] = []
var _max_widths:Array[int] = []

func _resolve_child_sizes( available_size:Vector2, limited:bool=false ):
	# Resolve for and collect min and max sizes
	_max_widths.clear()
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is Control and child.visible:
			_resolve_child_size( child, available_size, true )
			_max_widths.push_back( int(child.size.x) )
		else:
			_max_widths.push_back( 0 )

	_min_widths.clear()
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is Control and child.visible:
			_resolve_child_size( child, Vector2(0,available_size.y), true )
			_min_widths.push_back( int(child.size.x) )
		else:
			_min_widths.push_back( 0 )

	var expand_count := 0
	var total_stretch_ratio := 0.0
	var fixed_width := 0
	var min_width := 0

	# Leave all children at their minimum width except for aspect-fit-width and
	# proportional nodes, which are set to their maximum size. Shrink-to-fit
	# children are treated as fixed size.
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue

		var has_mode = child is GGComponent or child.has_method("request_layout")
		if has_mode and child.horizontal_mode in [GGComponent.ScalingMode.ASPECT_FIT,GGComponent.ScalingMode.PROPORTIONAL]:
			_resolve_child_size( child, available_size, limited )
			var w = int(child.size.x)
			min_width += w
			fixed_width += w
			_min_widths[i] = w
			_max_widths[i] = w

		else:
			var w = _min_widths[i]
			min_width += w

			if _min_widths[i] == _max_widths[i]:
				fixed_width += w
				_resolve_child_size( child, child.size, limited )  # final resolve
			else:
				expand_count += 1
				total_stretch_ratio += child.size_flags_stretch_ratio

	if expand_count == 0 or total_stretch_ratio == 0.0 or min_width >= available_size.x: return

	var excess_width = int(available_size.x - fixed_width)
	var remaining_width = excess_width

	# Find children with a min width larger than their portion. Let them keep their min width and adjust remaining.
	var remaining_total_stretch_ratio = total_stretch_ratio
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_widths[i] == _max_widths[i]: continue

		var w := 0
		if expand_count == 1: w = remaining_width
		else:                 w = int( excess_width * child.size_flags_stretch_ratio / total_stretch_ratio )

		if w < _min_widths[i]:
			w = _min_widths[i]
			remaining_width -= w
			expand_count -= 1
			remaining_total_stretch_ratio -= child.size_flags_stretch_ratio
			_min_widths[i] = _max_widths[i]  # skip this node in the next pass
			_resolve_child_size( child, child.size, limited )  # final resolve

	excess_width = remaining_width
	total_stretch_ratio = remaining_total_stretch_ratio
	if expand_count == 0 or abs(total_stretch_ratio) < 0.0001: return

	# Distribute remaining width next to children with a max width smaller than their portion.
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_widths[i] == _max_widths[i]: continue

		var w := 0
		if expand_count == 1: w = remaining_width
		else:                 w = int( excess_width * child.size_flags_stretch_ratio / total_stretch_ratio )

		if w > _max_widths[i]:
			w = _max_widths[i]
			_resolve_child_size( child, Vector2(w,available_size.y), limited )
			remaining_width -= w
			expand_count -= 1
			remaining_total_stretch_ratio -= child.size_flags_stretch_ratio
			_min_widths[i] = _max_widths[i]  # skip this node in the next pass

	excess_width = remaining_width
	total_stretch_ratio = remaining_total_stretch_ratio
	if expand_count == 0 or abs(total_stretch_ratio) < 0.0001: return

	# If this GGHBox is shrink-to-fit width then we're done; don't add remaining space to
	# the children.
	if horizontal_mode == GGComponent.ScalingMode.SHRINK_TO_FIT:
		return

	# Distribute remaining width
	for i in range(get_child_count()):
		var child = get_child(i)
		if not child.visible or not child is Control: continue
		if _min_widths[i] == _max_widths[i]: continue

		var w := 0
		if expand_count == 1: w = remaining_width
		else:                 w = int( excess_width * child.size_flags_stretch_ratio / total_stretch_ratio )

		_resolve_child_size( child, Vector2(w,available_size.y), limited )
		remaining_width -= w
		expand_count -= 1

func _resolve_shrink_to_fit_width( _available_size:Vector2 ):
	size.x = _get_sum_of_child_sizes().x

func _resolve_shrink_to_fit_height( _available_size:Vector2 ):
	size.y = _get_largest_child_size().y

func _perform_layout( available_bounds:Rect2 ):
	_place_component( self, available_bounds )

	var inner_bounds = _with_margins( Rect2(Vector2(0,0),size) )

	for i in range(get_child_count()):
		var child = get_child(i)
		if not (child is Control) or not child.visible: continue
		if child is Control:
			_perform_component_layout( child, Rect2(inner_bounds.position,Vector2(child.size.x,inner_bounds.size.y)) )
			inner_bounds.position += Vector2( child.size.x, 0 )
