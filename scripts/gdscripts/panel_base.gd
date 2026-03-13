extends Node
class_name panel_base

@export var _label_name : Label
@export var _icon_texture : TextureRect
@export var _remove_button : Button

func _ready() -> void:
	if _remove_button: _remove_button.pressed.connect(remove)
	else: printerr("ERROR: _remove_button is not assigned in the Inspector!")

func set_text(value : String = "") -> void:
	if _label_name: _label_name.text = value
	else: printerr("ERROR: _label_name is not assigned in the Inspector!")

func set_icon(value : Texture2D) -> void:
	if _icon_texture: _icon_texture.texture = value
	else: printerr("ERROR: _icon_texture is not assigned in the Inspector!")

func remove() -> void:
	queue_free()
