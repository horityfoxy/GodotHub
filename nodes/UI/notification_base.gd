extends notification_label
class_name notification_update

func _ready() -> void:
	EventBus.new_version_godot_hub_found.connect(_add_count)
	_count_label.hide()
	super()
