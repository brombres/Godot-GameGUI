@tool

extends GGRichTextLabel

func _on_gg_button__layout_pressed():
	text = "[b]GGComponent[/b] - GameGUI base node type. Useful as container, sizer, filler, spacer. Lays out children in a layered stack.\n" \
	     + "[b]GGHBox[/b] - Lays out children in a horizontal row.\n" \
	     + "[b]GGVBox[/b] - Lays out children in a vertical column.\n" \
	     + "[b]GGInitialWindowSize[/b] - IF it is the root node of a scene, sets the window size to its own size on launch. Useful for testing independent UI component scenes at typical aspect ratios.\n" \
	     + "[b]GGMarginLayout[/b] - Adds inside margins to the layout of its child content.\n" \
	     + "[b]GGOverlay[/b] - Positions its child content arbitrarily within its layout area in a sprite-like manner.\n" \
	     + "[b]GGLimitedSizeComponent[/b] - Applies minimum and/or maximum sizes to its child content.\n" \
	     + "[b]GGFiller[/b] - A GGComponent with an icon and default name that indicates it's purpose is to fill up extra space."

func _on_gg_button__text_pressed():
	text = "[b]GGLabel[/b] - A Label that can auto-scale its text size.\n" \
	     + "[b]GGRichTextLabel[/b] - A RichTextLabel that can auto-scale its text size.\n" \
	     + "[b]GGButton[/b] - A Button that can auto-scale its text size.\n"

func _on_gg_button__images_pressed():
	text = "[b]GGTextureRect[/b] - A TextureRect that uses the GameGUI layout system and automatically configures itself with appropriate defaults.\n"

func _on_gg_button__misc_pressed():
	text = "[b]GGLayoutConfig[/b] - Place this near the root of the scene, extend the script, make it a @tool, override [code]func _on_begin_layout(display_size:Vector2)[/code], and call [code]set_parameter(name,value)[/code] with various computed values related to the current display size. Those parameters can be automatically used by other GameGUI nodes by setting their sizing mode to [b]Parameter[/b] and supplying the desired parameter name.\n" \
	     + "[b]GGParameterSetter[/b] - Sets specified subtree parameters to its own width and/or height, which can then be used to set the size of other components when they're in [b]Parameter[/b] sizing mode.\n\n" \
	     + "Any Godot control node can be the child of a GameGUI component. They are automatically scaled to fit available width and height. Their size can be controlled by wrapping them in various GameGUI components.\n\n"

