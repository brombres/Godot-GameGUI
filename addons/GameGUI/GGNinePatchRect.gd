@tool

class_name GGNinePatchRect
extends GGComponent

@export var texture:Texture2D :
	set(value):
		texture = value
		if not texture: return

		_texture_region = Rect2( 0, 0, texture.get_width(), texture.get_height() )

		_update_piece_rects()

@export var draw_center := true :
	set(value):
		draw_center = value
		queue_redraw()

@export_group("Patch Margin")

@export var left   := 0:
	set(value):
		left = clamp( value, 0, _texture_region.size.x )
		_update_piece_rects()

@export var top    := 0:
	set(value):
		top = clamp( value, 0, _texture_region.size.y )
		_update_piece_rects()

@export var right  := 0:
	set(value):
		right = clamp( value, 0, _texture_region.size.x )
		_update_piece_rects()

@export var bottom := 0:
	set(value):
		bottom = clamp( value, 0, _texture_region.size.y )
		_update_piece_rects()

@export_group("Fill Mode")

@export var horizontal_fill := FillMode.STRETCH :
	set(value):
		horizontal_fill = value
		queue_redraw()

@export var vertical_fill   := FillMode.STRETCH :
	set(value):
		vertical_fill = value
		queue_redraw()

var _texture_region:Rect2
var _piece_rects:Array[Rect2] = []

func _draw():
	if size.x == 0 or size.y == 0 or not texture: return

	var _left = left
	var _right = right
	var _top = top
	var _bottom = bottom

	if left + right > size.x or top + bottom > size.y:
		var scale_x = size.x / (_left + _right)
		var scale_y = size.y / (_top + _bottom)
		var scale = min( scale_x, scale_y )

		_left = floor( _left * scale )
		_right = ceil( _right * scale )
		_top = floor( _top * scale )
		_bottom = ceil( _bottom * scale )

	var mid_w = max( size.x - (_left+_right), 0 )
	var mid_h = max( size.y - (_top+_bottom), 0 )

	var pos = position
	if _top > 0:
		if _left > 0:   draw_texture_rect_region( texture, Rect2(pos,Vector2(_left,_top)), _piece_rects[0], modulate )
		pos += Vector2( _left, 0 )
		fill_texture( texture, Rect2(pos,Vector2(mid_w,_top)), _piece_rects[1], horizontal_fill, vertical_fill, modulate )
		pos += Vector2( mid_w, 0 )
		if _right > 0:  draw_texture_rect_region( texture, Rect2(pos,Vector2(_right,_top)), _piece_rects[2], modulate )

	pos = Vector2( position.x, pos.y + _top )
	if mid_h > 0:
		fill_texture( texture, Rect2(pos,Vector2(_left,mid_h)), _piece_rects[3], horizontal_fill, vertical_fill, modulate )
		pos += Vector2( _left, 0 )
		if draw_center and mid_w > 0:  fill_texture( texture, Rect2(pos,Vector2(mid_w,mid_h)), _piece_rects[4], horizontal_fill, vertical_fill, modulate )
		pos += Vector2( mid_w, 0 )
		fill_texture( texture, Rect2(pos,Vector2(_right,mid_h)), _piece_rects[5], horizontal_fill, vertical_fill, modulate )

	pos = Vector2( position.x, pos.y + mid_h )
	if _bottom > 0:
		if _left > 0:   draw_texture_rect_region( texture, Rect2(pos,Vector2(_left,_bottom)), _piece_rects[6], modulate )
		pos += Vector2( _left, 0 )
		fill_texture( texture, Rect2(pos,Vector2(mid_w,_bottom)), _piece_rects[7], horizontal_fill, vertical_fill, modulate )
		pos += Vector2( mid_w, 0 )
		if _right > 0:  draw_texture_rect_region( texture, Rect2(pos,Vector2(_right,_bottom)), _piece_rects[8], modulate )

func _update_piece_rects():
	var x = _texture_region.position.x
	var y = _texture_region.position.y
	var w = _texture_region.size.x
	var h = _texture_region.size.y
	var mid_w = max( w - (left+right), 0 )
	var mid_h = max( h - (top+bottom), 0 )

	_piece_rects = []

	_piece_rects.push_back( Rect2     (      x, y, left,  top) )  # TL
	_piece_rects.push_back( Rect2(      x+left, y, mid_w, top) )  # T
	_piece_rects.push_back( Rect2( x+(w-right), y, right, top) )  # TR

	_piece_rects.push_back( Rect2(           x, y+top, left,  mid_h) )  # L
	_piece_rects.push_back( Rect2(      x+left, y+top, mid_w, mid_h) )  # M
	_piece_rects.push_back( Rect2( x+(w-right), y+top, right, mid_h) )  # R

	_piece_rects.push_back( Rect2(           x, y+(h-bottom), left,  bottom) )  # BL
	_piece_rects.push_back( Rect2(      x+left, y+(h-bottom), mid_w, bottom) )  # B
	_piece_rects.push_back( Rect2( x+(w-right), y+(h-bottom), right, bottom) )  # BR

	queue_redraw()
