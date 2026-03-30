extends notification_label
class_name notification_update

func _ready() -> void:
	EventBus.new_version_godot_hub_found.connect(_add_count)
	EventBus.new_version_godot_hub_install_start.connect(_remove_notification)
	_count_label.hide()
	super()
