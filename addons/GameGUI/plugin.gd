@tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type( "GGButton",               "Button",        preload("GGButton.gd"), preload("Icons/GGButton.svg") )
	add_custom_type( "GGComponent",            "Container",     preload("GGComponent.gd"), preload("Icons/GGComponent.svg") )
	add_custom_type( "GGFiller",               "GGComponent",   preload("GGFiller.gd"), preload("Icons/GGFiller.svg") )
	add_custom_type( "GGHBox",                 "GGComponent",   preload("GGHBox.gd"), preload("Icons/GGHBox.svg") )
	add_custom_type( "GGInitialWindowSize",    "GGComponent",   preload("GGInitialWindowSize.gd"), preload("Icons/GGInitialWindowSize.svg") )
	add_custom_type( "GGLabel",                "Label",         preload("GGLabel.gd"), preload("Icons/GGLabel.svg") )
	add_custom_type( "GGLayoutConfig",         "Node2D",        preload("GGLayoutConfig.gd"), preload("Icons/GGLayoutConfig.svg") )
	add_custom_type( "GGLimitedSizeComponent", "GGComponent",   preload("GGLimitedSizeComponent.gd"), preload("Icons/GGLimitedSizeComponent.svg") )
	add_custom_type( "GGMarginLayout",         "GGComponent",   preload("GGMarginLayout.gd"), preload("Icons/GGMarginLayout.svg") )
	add_custom_type( "GGNinePatchRect",        "GGComponent",   preload("GGNinePatchRect.gd"), preload("Icons/GGNinePatchRect.svg") )
	add_custom_type( "GGParameterSetter",      "GGComponent",   preload("GGParameterSetter.gd"), preload("Icons/GGParameterSetter.svg") )
	add_custom_type( "GGOverlay",              "GGComponent",   preload("GGOverlay.gd"), preload("Icons/GGOverlay.svg") )
	add_custom_type( "GGRichTextLabel",        "RichTextLabel", preload("GGRichTextLabel.gd"), preload("Icons/GGRichTextLabel.svg") )
	add_custom_type( "GGTextureRect",          "TextureRect",   preload("GGTextureRect.gd"), preload("Icons/GGTextureRect.svg") )
	add_custom_type( "GGVBox",                 "GGComponent",   preload("GGVBox.gd"), preload("Icons/GGVBox.svg") )

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type( "GGButton" )
	remove_custom_type( "GGComponent" )
	remove_custom_type( "GGFiller" )
	remove_custom_type( "GGHBox" )
	remove_custom_type( "GGInitialWindowSize" )
	remove_custom_type( "GGLabel" )
	remove_custom_type( "GGLayoutConfig" )
	remove_custom_type( "GGLimitedSizeComponent" )
	remove_custom_type( "GGMarginLayout" )
	remove_custom_type( "GGNinePatchRect" )
	remove_custom_type( "GGParameterSetter" )
	remove_custom_type( "GGOverlay" )
	remove_custom_type( "GGRichTextLabel" )
	remove_custom_type( "GGTextureRect" )
	remove_custom_type( "GGVBox" )
