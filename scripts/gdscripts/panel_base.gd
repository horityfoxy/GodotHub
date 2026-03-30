extends Node
class_name panel_base

@export var MAX_TEXT_LENGTH : int = 110

@export var _label_name : RichTextLabel
@export var _icon_texture : TextureRect
@export var _remove_button : Button

var _normal_text : String = ""

func _ready() -> void:
	if _remove_button: 
		_remove_button.pressed.connect(remove)
		_remove_button.hide()
	else: printerr("ERROR: _remove_button is not assigned in the Inspector!")

func set_text(value : String = "") -> void:
	_normal_text = value
	if _normal_text.length() > MAX_TEXT_LENGTH: _normal_text = _normal_text.left(MAX_TEXT_LENGTH) + "..."
	_label_name.text = _normal_text

func set_icon(value : Texture2D) -> void:
	if _icon_texture: _icon_texture.texture = value
	else: printerr("ERROR: _icon_texture is not assigned in the Inspector!")

func remove() -> void:
	queue_free()

func set_strikethrough_text() -> void:
	_label_name.text = "[s]" + _normal_text + "[/s]"

func set_destroy_icon() -> void:
	_icon_texture.modulate = Color("ffffff78")
