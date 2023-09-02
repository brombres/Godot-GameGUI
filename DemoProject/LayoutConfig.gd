@tool

extends GGLayoutConfig

func _on_begin_layout( display_size:Vector2 ):
	set_parameter( "half_width", int(display_size.x/2) )
	set_parameter( "half_height", int(display_size.y/2) )

