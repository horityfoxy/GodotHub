extends ColorRect
class_name notification_label

@export var _count_label : Label

var _notifications_count : int = 0

func _ready() -> void:
	hide()

func _add_count() -> void:
	_notifications_count += 1
	_count_label.text = str(_notifications_count)
	_check_visible()

func _check_visible() -> void:
	if _notifications_count > 0: show()
	else: hide()

func _remove_notification() -> void:
	_notifications_count -= 1
	_check_visible()
